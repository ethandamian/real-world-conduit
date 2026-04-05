# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController

      before_action :authenticate_request!, only: [:show, :update]

      def login
        parsed_email = login_params[:email].downcase

        user = User.find_by!(email: parsed_email)

        raise ActiveRecord::RecordNotFound if user.nil?

        if user.authenticate(login_params[:password])
          token = JwtService.encode(user_id: user.id)
          render json: UserBlueprint.render(user, view: :auth, root: :user, token: token), status: :ok

        else
          render json: {errors: {body: ["Invalid email or password"]}}, status: :unauthorized
        end

      end

      def create
        user = User.new(registration_params)

        if user.save
          token = JwtService.encode(user_id: user.id)
          render json: UserBlueprint.render(user, view: :auth, root: :user, token: token), status: :created

        else
          render json: {errors: {body: [user.errors.full_messages]}}, status: :unprocessable_entity
        end

      end


      def show
        token = extract_token_from_header

        render json: UserBlueprint.render(current_user, view: :auth, root: :user, token: token), status: :ok

      end

      def update

        if current_user.update(update_params)
          token = extract_token_from_header
          render json: UserBlueprint.render(current_user, view: :auth, root: :user, token: token), status: :ok

        else
          render json: {errors: current_user.errors.full_messages}, status: :unprocessable_entity
        end



      end

      private
      def login_params
        params.require(:user).permit(:email, :password)
      end

      def registration_params

        params.expect(user:[:username, :email, :password])

      end

      def update_params
        params.expect(user:[:email, :password, :bio, :image])
      end
    end
  end
end
