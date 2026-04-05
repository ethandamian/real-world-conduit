class ApplicationController < ActionController::API
  include ExceptionHandler

  rescue_from ExceptionHandler::AuthenticationError, with: :unauthorized_request
  rescue_from ExceptionHandler::ExpiredToken, with: :token_expired
  rescue_from ExceptionHandler::MissingToken, with: :missing_token
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameters

  private

  def extract_token_from_header
    token_header = request.headers["Authorization"]

    return nil unless token_header && token_header.start_with?("Token ")

    token_header.split(" ").last
  end

  def decode_user_from_token
    token = extract_token_from_header
    raise ExceptionHandler::MissingToken if token.nil?

    decoded_token = JwtService.decode(token)
    User.find(decoded_token[:user_id])
  end

  def authenticate_request!
    @current_user = decode_user_from_token

  end

  def current_user
    @current_user
  end

  def unauthorized_request(error)
    render json: {errors: {body: [error.message]}}, status: :unauthorized
  end

  def token_expired(_error)
    render json: {errors: {body: ["Token expired",_error]}}, status: :unauthorized

  end


  def missing_token(_error)
    render json: {errors: {body: ["Token is missing"]}}, status: :not_found
  end

  def not_found(error)
    render json: {errors: {body: ["Resource not found"]}}, status: :not_found
  end

  def unprocessable_entity(error)
    render json: {errors: {body: [error.record.errors]}}, status: :unprocessable_entity
  end

  def handle_missing_parameters(exception)
    render json: { error: {body: ["Missing parameter: #{exception.param}"] } }, status: :bad_request
  end
end
