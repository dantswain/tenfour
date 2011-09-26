#!/usr/bin/ruby

# these should be standard
require "resolv-replace"
require "ping"
require "net/http"
require "uri"
require "yaml"

require "rubygems"
require "bundler/setup"

class TenFour

  def initialize
    load_config
  end

  def install_cronjob
    %x[bundle exec whenever --update-cron]
  end
  
  def uninstall_cronjob
    %x[bundle exec whenever --clear-crontab]
  end
  
  def check_sites
    init_output    
    unless internet_connection?
      error_out "No internet connection"
      return
    end
    @config[:sites].each do |name, url|
      if (check_server url) && (check_site url)
        ok_out "Site at #{url} appears to be running fine"
      end
    end
    done
  end

  def check_server site
    unless server_alive? site
      error_out "Site #{site} is down:  The server does not respond at all."
      return false
    end
    return true
  end

  def check_site site
    code = http_response_code site
    unless code_ok? code
      error_out "Site #{site} is down:  Got HTTP response code #{code}"
      return false
    end
    return true
  end

  def internet_connection?
    server_alive? @config[:truth]
  end
  
  def server_alive? host
    Ping.pingecho URI.parse(host).host, 1, 80  
  end

  def http_response_code url
    Net::HTTP.get_response(URI.parse(url)).code.to_i
  end

  def done
    @outfile.puts output_footer if @outfile
  end

  private

  def ten4_dir
    File.dirname(File.expand_path(__FILE__))
  end

  def config_file
    ten4_dir + "/config/config.yml"
  end

  def ten4_tag
    "10-4: "
  end

  def ok_status
    "[OK] "
  end

  def alert_status
    "[ALERT] "
  end

  def ok_out msg
    @outfile.puts ten4_tag + ok_status + msg
  end

  def error_out msg
    @outfile.puts ten4_tag + alert_status + msg
  end

  def load_config
    begin
      @config = YAML::load_file(config_file)
    rescue
      raise "Could not load config file #{config_file}."
    end

    @config = {
      :truth => "http://google.com",
      :output => {}
    }.merge(@config)

    unless @config[:output][:filename]
      @config[:output][:filename] = "status.txt"
    end

    unless @config[:output][:rewrite]
      @config[:output][:rewrite] = false
    end

    unless @config[:sites]
      raise "No sites configured"
    end

  end

  def absolute_path? path
    !path.match(/^[~\/]/).nil?
  end

  def init_output
    output_filename = @config[:output][:filename]

    unless absolute_path?(output_filename)
      output_filename = File.expand_path(ten4_dir + "/" + output_filename)
    end

    if File.exist?(output_filename) && !File.writable?(output_filename)
      raise "Cannot write to output file #{output_filename}"
    end

    begin
      @outfile = File.open(output_filename, @config[:output][:rewrite] ? "w" : "a")
    rescue
      raise "Could not open output file #{output_filename}"
    end 

    @outfile.puts output_header
  end

  def output_header
    ["--- Begin TenFour output: #{Time.now}",
     "      Config file #{config_file}"]
  end

  def output_footer
    "--- End TenFour output: #{Time.now}"
  end

  def code_ok? code, expect_range = (200..206)
    expect_range.include? code
  end
  
end

ten4 = TenFour.new
  
if ARGV[0] && ARGV[0].match(/^install/i)
  puts "Updating cron"
  ten4.install_cronjob
elsif ARGV[0] && ARGV[0].match(/^uninstall/i)
  puts "Removing cron jobs"
  ten4.uninstall_cronjob
else
  ten4.check_sites
end

exit

