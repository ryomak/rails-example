# frozen_string_literal: true

require_relative '../lib/llm/client'

class RagService
  def initialize
    @vector_store = VectorStore::Client.new
    @llm = LLM::Client.new
  end

  def search(text, image_url=nil)
    response = @llm.summarize(text, image_url)
    vector = @llm.create_vector(response)
    mm = @vector_store.search(vector,10)
    @llm.bot(text, mm)
  end
end