# frozen_string_literal: true

class CodeAiController < ApplicationController
  def index
    @api1_path = '/code_ai/search_normal_by_langchain'
    @api2_path = '/code_ai/search_custom_by_langchain'
  end

  def search
    rag_service = RagService.new
    response = rag_service.search(params[:text])
    render json: {
      message: response
    }
  end

  def search_normal_by_langchain
    ai = CodeAi.new
    response = ai.ask_normal(params[:text])
    render json: {
      message: response
    }
  end

  def search_custom_by_langchain
    ai = CodeAi.new
    response = ai.ask_rag_fusion(params[:text])
    render json: {
      message: response
    }
  end
end
