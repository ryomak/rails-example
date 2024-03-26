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

  end
end