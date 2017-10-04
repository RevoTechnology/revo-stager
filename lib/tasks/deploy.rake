namespace :stager do
  task :deploy do
    RevoStager::Deploy.new.run
  end

  task :help do
    puts 'help'
  end
end