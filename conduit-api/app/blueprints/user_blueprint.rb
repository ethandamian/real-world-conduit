# frozen_string_literal: true

class UserBlueprint < Blueprinter::Base
  view :auth do
    fields :email, :username, :bio, :image
    field :token do |user, options|
      options[:token]
    end
  end
end
