module RevoStager
  class Deploy
    def run
      #get app name
      puts app_name
      #get branch name
      puts current_branch
      #get stage name
      puts stage_name
      #create flynn app
      create_flynn_app
      #add mysql resource
      #TODO: use another db resources from config
      add_mysql_resource
      #patch mysql env
      #TODO: check for db resource type
      patch_mysql_connection_string
      #set envs
      set_env_variables
      #run tasks(schema, seeds, etc)
    end

    private

    def config
      @config ||= ::YAML.load(ERB.new(File.read(CONFIG_FILE)).result)
    end

    def app_name
      config['app_name']
    end

    def flynn_cli
      @flynn_cli ||= RevoStager::FlynnCli.new(stage_name)
    end

    def current_branch
      #TODO: move to helper
      @current_branch ||= `git rev-parse --abbrev-ref HEAD`.strip
    end

    def stage_name
      [app_name, current_branch].join('-')
    end

    def create_flynn_app
      #TODO: check for app exists
      puts '==Creating stage'

      result = flynn_cli.create_app
      printf result.output
      puts result.code.success? ? 'Flynn stage successfully created' : 'Flynn stage failed to create'
    end

    def add_mysql_resource
      #TODO: check for resource exists
      puts '==Adding mysql resource'

      result = flynn_cli.add_resource('mysql')
      printf result.output
      puts result.code.success? ? 'Flynn resource successfully added' : 'Flynn resource failed to added'
    end

    def patch_mysql_connection_string
      puts '==Patch mysql env string'

      env_key = 'DATABASE_URL'

      #get mysql env
      result = flynn_cli.get_env(env_key)
      current_value = result.std_out

      #set updated
      if current_value
        current_value.gsub!('mysql:', 'mysql2:')

        result = flynn_cli.set_env(env_key, current_value)
        printf result.output
        puts result.code.success? ? "Flynn env #{env_key} successfully set" : "Flynn env #{env_key} failed to set"
      end
    end

    def set_env_variables
      puts '==Setting env variables'
      config['env'].each do |name, val|
        result = flynn_cli.set_env(name, val)
        printf result.output
        puts result.code.success? ? "Flynn env #{name} successfully set" : "Flynn env #{name} failed to set"
      end
    end
  end
end