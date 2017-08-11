namespace :stager do
  task :deploy do
    RevoStager::Deploy.new.run
  end
end