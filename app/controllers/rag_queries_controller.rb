# frozen_string_literal: true

class RagQueriesController < ApplicationController
  def index
    @api1_path = '/rag_queries/search'
    @api2_path = '/rag_queries/langchain_search'
    @api3_path = '/rag_queries/search'
  end

  def search
    rag_service = RagService.new
    response = rag_service.search(params[:text], params[:image_url])
    render json: {
      message: response
    }
  end

  def langchain_search
    qa = Qa.new
    response = qa.ask(params[:text])
    render json: {
      message: response.raw_response.dig("choices", 0, "message", "content")
    }
  end
end
