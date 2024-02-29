class RequestLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    start = Time.now
    status, headers, response = @app.call(env)
    duration = Time.now - start

    Rails.logger.info "Request took #{duration} seconds"
    [status, headers, response]
  end
end