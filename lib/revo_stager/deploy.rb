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
      #add resources
      add_resources
      #push changes
      push_changes
      #set envs
      set_env_variables
      #run tasks(schema, seeds, etc)
      run_tasks
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

    def add_resources
      puts '==Adding resources'
      return if config['resources'].nil?
      config['resources'].each do |resource|
        #removing resources
        puts "====Removing #{resource}"
        flynn_cli.delete_resource(resource)

        #add resource
        puts "====Adding #{resource} resource"

        result = flynn_cli.add_resource(resource)
        printf result.output
        puts result.code.success? ? 'Flynn resource successfully added' : 'Flynn resource failed to added'
        #run hooks
        hook_name = "run_#{resource}_resource_hook".to_sym
        send(hook_name) if respond_to?(hook_name, true)
      end
    end

    def set_env_variables
      puts '==Setting env variables'
      return if config['env'].nil?
      config['env'].each do |name, val|
        result = flynn_cli.set_env(name, val)
        printf result.output
        puts result.code.success? ? "Flynn env #{name} successfully set" : "Flynn env #{name} failed to set"
      end
    end

    def push_changes
      puts '==Pushing changes'
      puts `git push #{stage_name} #{current_branch}:master`
    end

    def run_tasks
      puts '==Running tasks'
      return if config['tasks'].nil?
      config['tasks'].each do |task|
        puts "====Running #{task}"
        result = flynn_cli.run_task(task)
        printf result.output
        puts result.code.success? ? 'Flynn task complete' : 'Flynn task failed to run'
      end
    end

    #hooks
    def run_mysql_resource_hook
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
  end
end