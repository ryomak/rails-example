# frozen_string_literal: true

class RagQueriesController < ApplicationController
  def index
  end

  def search
    rag_service = RagService.new
    response = rag_service.search(params[:text], params[:image_url])
    pp response
    render json: {
      message: response
    }
  end
end
