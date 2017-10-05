module RevoStager
  class FlynnCli
    def initialize(app_name = nil)
      @app_name = app_name
    end

    def create_app
      cmd = "flynn create -r #{app_name} -y #{app_name}"
      exec_cmd(cmd)
    end

    def set_env(key, value)
      cmd = "flynn -a #{app_name} env set #{key}=#{value}"
      exec_cmd(cmd)
    end

    def get_env(key)
      cmd = "flynn -a #{app_name} env get #{key}"
      exec_cmd(cmd)
    end

    def add_resource(name)
      cmd = "flynn -a #{app_name} resource add #{name}"
      exec_cmd(cmd)
    end

    def delete_resource(name)
      resources = list_resources name
      resources.each do |r|
        cmd = "flynn -a #{app_name} resource remove #{name} #{r[:id]}"
        exec_cmd(cmd)
      end
    end

    def run_task(task_cmd)
      cmd = "flynn -a #{app_name} run #{task_cmd}"
      exec_cmd(cmd)
    end

    private

    attr_reader :app_name

    def exec_cmd(cmd)
      exit_code = nil
      std_out = nil
      output = nil

      Open3.popen3 cmd do |_stdin, stdout, stderr, wait_thr|
        std_out = stdout.read
        output = [std_out, stderr.read].reject(&:empty?).join
        exit_code = wait_thr.value
      end
      OpenStruct.new(code: exit_code, output: output, std_out: std_out)
    end

    def list_resources(name)
      cmd = "flynn -a #{app_name} resource"
      result = exec_cmd cmd
      list = result.std_out.split("\n")
      list.shift
      values = list.map do |item|
        Hash[[:id, :provider_id, :type].zip(item.split(' '))]
      end
      values.select{|i| i[:type] == name}
    end
  end
end