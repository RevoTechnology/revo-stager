module RevoStager
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/install.rake'
      load 'tasks/deploy.rake'
    end
  end
end