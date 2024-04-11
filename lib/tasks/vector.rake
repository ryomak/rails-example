namespace :vector do
  desc <<~MSG
    dataをvectorに入れる
  MSG

  task :insert, ['dir'] => :environment do |task, args|
    Rails.logger.info '===============vector:inert Start==============='
    qa = CodeAi.new
    docs = qa.load_from_dir(args[:dir] || "tmp/code", extensions: ['rb'])
    docs.each do |doc|
      qa.input(doc.value)
    end
    Rails.logger.info '===============End==============='
  end
end
