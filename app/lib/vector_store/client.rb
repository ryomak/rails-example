module VectorStore
  class Client
    def initialize
      @client = Weaviate::Client.new(
        url: 'http://localhost:8080',  # Replace with your endpoint
        model_service: :openai,
        api_key: '',
        model_service_api_key: ENV['OPENAI_API_KEY'] # Either OpenAI, Azure OpenAI, Cohere, Hugging Face or Google PaLM api key
      )
    end

    def search(msg, limit)
      near_text = `{ concepts: ["#{msg}"] }`
      sort_obj = '{ path: ["category"], order: desc }'
      where_obj = '{ path: ["id"], operator: Equal, valueString: "..." }'
      with_hybrid = '{ query: "Sweets", alpha: 0.5 }'

      response = @client.query.get(
        class_name: 'Question',
        fields: "question answer category _additional { answer { result hasAnswer property startPosition endPosition } }",
        limit: limit,
        offset: "0",
        after: "id",
        sort: sort_obj,
        where: where_obj,

        # To use this parameter you must have created your schema by setting the `vectorizer:` property to
        # either 'text2vec-transformers', 'text2vec-contextionary', 'text2vec-openai', 'multi2vec-clip', 'text2vec-huggingface' or 'text2vec-cohere'
        near_text: near_text,

        with_hybrid: with_hybrid,
      )

      pp response
      response
    end


    def create_schema
      begin
        res =@client.schema.create(
          class_name: 'Question',
          description: 'Information from a Jeopardy! question',
          vector_index_config: {
            "distance": "cosine",
          },
          properties: [
            {
              "dataType": ["text"],
              "description": "The question",
              "name": "question"
            }, {
              "dataType": ["text"],
              "description": "The answer",
              "name": "answer"
            }
          ],
        )
        pp res
      rescue => e
        p e #=> RuntimeError
      end

    end

    def list
      puts @client.schema.list
    end
  end
end