namespace :stager do

  desc 'Configurates app'
  task :install do
    puts 'Creates settings file'
    config_dir = Pathname.new("config")
    config_template = File.expand_path("../../templates/stager.yml", __FILE__)
    config_destination = config_dir.join('stager.yml')

    if File.exist?(config_destination)
      warn "[skip] stager.yml already exists"
    else
      File.open(config_destination, "w+") do |f|
        f.write(ERB.new(File.read(config_template)).result(binding))
      end
    end
  end
end