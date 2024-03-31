class RagService
  def initialize
    @vector_store = VectorStore::Client.new
    @llm = LLM::Client.new
  end

  def search(text, image_url)
    response = @llm.summarize(text, image_url)
    mm = @vector_store.search(response,1)
    @llm.bot(text, mm)
  end
end