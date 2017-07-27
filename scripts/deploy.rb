require 'thor'

DEFAULT_COMMAND_NAME = "deploy.rb"
DEFAULT_APP_NAME = "puff"
DEFAULT_SERVICE_ENV = "staging"
DEFAULT_SERVICE_NAME = "web"

class AWSUtil < Thor

  desc "deploy [SERVICE_NAME]", "ex) #{DEFAULT_COMMAND_NAME} deploy web --env production"
  option :env, :type => :string
  option :app, :type => :string
  def deploy(name)
    check_option(name)
    ips = get_ips
    ips.each_with_index do |ec2_ip, index|
      target = "ec2-user@#{ec2_ip}"
      puts "#{index} starting deploy: #{ec2_ip}"
      system("ssh -i #{@pem} #{target} \"/bin/bash --login -c './startup_rails.sh'\"")
    end
  end

  desc "ips [SERVICE_NAME]", "ex) #{DEFAULT_COMMAND_NAME} ips web --env production"
  option :env, :type => :string
  option :app, :type => :string
  def ips(name)
    check_option(name)
    puts "#{@tag}: get ec2 instance addresses."
    ips = get_ips
    ips.each_with_index do |ip, index|
      puts "#{index}: #{ip}"
    end
  end

  desc "logs [SERVICE_NAME]", "ex) #{DEFAULT_COMMAND_NAME} logs web --env production --seq 0"
  option :env, :type => :string
  option :app, :type => :string
  option :log, :type => :string
  option :seq, :type => :numeric
  def logs(name)
    check_option(name)

    seq = options[:seq].nil? ? 0 : options[:seq]
    log_type = options[:log].nil? ? "out" : options[:log]
    ips = get_ips

    ec2_ip = ips[seq]
    target = "ec2-user@#{ec2_ip}"
    puts "target: #{target}"
    system("ssh -i #{@pem} #{target} \"/bin/bash --login -c 'tail -f ~/log/#{log_type}'\"")
  end

  desc "ssh [SERVICE_NAME] --seq [SEQ]", "ex) #{DEFAULT_COMMAND_NAME} ssh web --env production --seq 0"
  option :env, :type => :string
  option :app, :type => :string
  option :seq, :type => :numeric
  def ssh(name)
    check_option(name)
    seq = options[:seq].nil? ? 0 : options[:seq]
    ips = get_ips
    ec2_ip = ips[seq]
    target = "ec2-user@#{ec2_ip}"
    puts "target: #{target}"
    system("ssh -i #{@pem} #{target}")
  end

  private

  def check_option(name)
    if options[:app]
      service_app = options[:app]
    else
      puts "please input <app>, default is #{DEFAULT_APP_NAME}"
      service_app = DEFAULT_APP_NAME
    end

    if options[:env]
      service_env = options[:env]
    else
      puts "please input <env>, default is #{DEFAULT_SERVICE_ENV}"
      service_env = DEFAULT_SERVICE_ENV
    end

    service_name = name

    @tag="#{service_app}-#{service_env}-#{service_name}"
    @pem='~/.ssh/puff.pem'

    puts "tag: #{@tag}"
    puts "pem: #{@pem}"
  end

  def get_ips
    pub_ips = %x( aws ec2 describe-instances --filters "Name=tag:Name,Values=#{@tag}" --query "Reservations[*].Instances[*].NetworkInterfaces[*].Association.PublicIp" --output text )

    pub_ips.split("\n")
  end
end

AWSUtil.start(ARGV)