require 'revo_stager/version'
require 'revo_stager/railtie' if defined?(Rails)
require 'revo_stager/deploy'
require 'revo_stager/flynn_cli'

module RevoStager
  CONFIG_DIR = Pathname.new("config")
  CONFIG_FILE = CONFIG_DIR.join('stager.yml')
end
