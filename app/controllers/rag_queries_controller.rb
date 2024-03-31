class RagQueriesController < ApplicationController
  def index
  end

  def search
    @rag_service = RagService.new
    response = @rag_service.search(params[:text], params[:image_url])
    render json: {
      res: response
    }
  end
end
