# frozen_string_literal: true

require 'openai'

module LLM
  class Client
    def initialize
      @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    end

    def test_chat(msg)
      @client.chat(
        parameters: {
          model: "gpt-4-vision-preview",
          messages: [{ role: "user", content: msg}],
        }).dig("choices", 0, "message", "content")
    end

    def summarize(text, image_url)
      user_messages = [{ type: "text", text: text}]
      user_messages << { type: "image_url", image_url: image_url } if image_url.present?


      @client.chat(
        parameters: {
          model: "gpt-4-vision-preview",
          messages: [
            { role: "system", content: "ユーザが入力した質問文と画像から、ユーザが相談していることを端的に単語にして" },
            { role: "user", content: user_messages },
          ],
        }).dig("choices", 0, "message", "content")
    end

    def bot(question, vector_data)
      @client.chat(
        parameters: {
          model: "gpt-4-vision-preview",
          messages: [
            { role: "system", content: "あなたはQ&Aボットです。ユーザが質問したことに対して、下記コンテキストを元に回答を返すようにしてください。関西弁で返して
コンテキストにない質問に対しては、「わかりません」と答えてください
## コンテキスト
#{vector_data}"},
            { role: "user", content: [{ type: "text", text: question}] },
          ],
        }).dig("choices", 0, "message", "content")
    end

    def create_vector(text)
      @client.embeddings(
        parameters: {
          model: "text-embedding-ada-002",
          input: text,
        }
      ).dig("data", 0, "embedding")
    end
  end
end