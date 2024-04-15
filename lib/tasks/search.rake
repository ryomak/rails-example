namespace :search do
  desc <<~MSG
    dataをvectorに入れる
  MSG

  task :normal, ['question'] => :environment do |task, args|
    Rails.logger.info '===============search normal Start==============='
    qa = CodeAi.new
    result = qa.ask_normal(args[:question])

    Rails.logger.info '===============output-start==============='
    puts result
    Rails.logger.info '===============output-end==============='
    Rails.logger.info '===============End==============='
  end

  task :fusion, ['question'] => :environment do |task, args|
    Rails.logger.info '===============search fusion Start==============='

    qa = CodeAi.new custom: true

    Rails.logger.info '===============output-start==============='
    result = qa.ask_rag_fusion(args[:question])
    Rails.logger.info '===============output-end==============='

    puts result
    Rails.logger.info '===============End==============='
  end

  task :custom, ['question'] => :environment do |task, args|
    Rails.logger.info '===============search custom Start==============='

    qa = CodeAi.new custom: true

    Rails.logger.info '===============output-start==============='
    result = qa.ask_custom(args[:question])
    Rails.logger.info '===============output-end==============='

    puts result
    Rails.logger.info '===============End==============='
  end
end
