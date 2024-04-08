class Qa

  def initialize
    @llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"], llm_options:{
      model: "gpt-4-vision-preview",
    })
    @vector_search =  Langchain::Vectorsearch::Weaviate.new(
      url: 'http://localhost:8080',
      api_key: '',
      index_name: "Langchain",
      llm: @llm,
    )

  end

  def create_schema
    @vector_search.create_default_schema
  end
  def input(texts)
    @vector_search.add_texts(texts: texts)
  end

  def ask(text)
    @vector_search.ask(question: text)
  end

end