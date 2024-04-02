# frozen_string_literal: true

require_relative '../lib/llm/client'

class RagService
  def initialize
    @vector_store = VectorStore::Client.new
    @llm = LLM::Client.new
  end

  def search(text, image_url)
    response = @llm.summarize(text, image_url)
    vector = @llm.create_vector(response)
    pp vector
    mm = @vector_store.search(vector,10)
    pp mm
    @llm.bot(text, mm)
  end
end