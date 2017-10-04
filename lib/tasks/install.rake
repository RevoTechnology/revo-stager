namespace :stager do

  desc 'Configurates app'
  task :install => [:copy_config_file, :install_flynn_agent, :add_flynn_cluster] do

  end

  desc 'Prepares config file'
  task :copy_config_file do
    puts '==Creating settings file'
    config_template = File.expand_path("../../templates/stager.yml", __FILE__)

    if File.exist?(CONFIG_FILE)
      puts '[skip] stager.yml already exists'
    else
      File.open(CONFIG_FILE, "w+") do |f|
        f.write(ERB.new(File.read(config_template)).result(binding))
      end
      puts 'Settings file created'
    end
  end

  task :install_flynn_agent do
    puts '==Installing flynn'

    exit_code = nil
    install_cmd = "L=/usr/local/bin/flynn && curl -sSL -A \"`uname -sp`\" https://dl.flynn.io/cli | zcat >$L && chmod +x $L"

    Open3.popen3 install_cmd do |_stdin, stdout, stderr, wait_thr|
      printf [stdout.read, stderr.read].reject(&:empty?).join
      exit_code = wait_thr.value
    end
    puts exit_code.success? ? 'Flynn cli successfully installed' : 'Flynn cli failed to install'
  end

  task :add_flynn_cluster do
    puts '==Adding flynn cluster'

    exit_code = nil
    cluster_add_cmd = "flynn cluster add -p 4opJKdE21dKIud1SWAqLkcBTrdXvSi7yRoEhoJzsdjs= default st.revoup.ru a2185eabce7013f5aa649d009dcb1e6a"

    Open3.popen3 cluster_add_cmd do |_stdin, stdout, stderr, wait_thr|
      printf [stdout.read, stderr.read].reject(&:empty?).join
      exit_code = wait_thr.value
    end
    puts exit_code.success? ? 'Flynn cluster successfully added' : 'Flynn cluster failed to add'
  end
end