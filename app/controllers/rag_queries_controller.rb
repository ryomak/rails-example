# frozen_string_literal: true

class RagQueriesController < ApplicationController
  def index
    @api1_path = '/rag_queries/search'
    @api2_path = '/rag_queries/search_normal_by_langchain'
    @api3_path = '/rag_queries/search_custom_by_langchain'
  end

  def search
    rag_service = RagService.new
    response = rag_service.search(params[:text])
    pp response
    render json: {
      message: response
    }
  end

  def search_normal_by_langchain
    qa = Qa.new
    response = qa.ask_normal(params[:text])
    render json: {
      message: response.raw_response.dig("choices", 0, "message", "content")
    }
  end

  def search_custom_by_langchain
    qa = Qa.new
    response = qa.ask_custom(params[:text])
    render json: {
      message: response
    }
  end
end
