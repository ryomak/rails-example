# frozen_string_literal: true

require 'weaviate'

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

    def search(vector, limit)
      @client.query.get(
        class_name: 'Question',
        fields: "answer",
        near_vector: "{ vector: #{vector} }",
        limit: limit.to_s,
        offset: "0",
      )
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

    def create_data(question, answer, vector)
      @client.objects.create(
        class_name: 'Question',
        vector: vector,
        properties: {
          answer: answer,
          question: question,
        }
      )
    end
  end
end