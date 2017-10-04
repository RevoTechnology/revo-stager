require 'revo_stager'
require 'rails'
module RevoStager
  class Railtie < Rails::Railtie
    railtie_name :revo_stager

    rake_tasks do
      load 'tasks/deploy.rake'
      load 'tasks/setup.rake'
    end
  end
end
