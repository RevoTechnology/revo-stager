module RevoStager
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/revo_stager.rake'
    end
  end
end