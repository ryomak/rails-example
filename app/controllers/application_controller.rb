class ApplicationController < ActionController::Base
    skip_before_action :verify_authenticity_token

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from StandardError, with: :handle_standard_error
    private
    def record_not_found(error)
        render json: { error: error.message }, status: :not_found
    end
    def handle_standard_error(error)
        render json: { error: error.message }, status: :internal_server_error
    end


end

