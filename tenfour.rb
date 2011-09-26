#!/usr/bin/ruby

# these should be standard
require "resolv-replace"
require "ping"
require "net/http"
require "uri"

require "rubygems"
require "bundler/setup"

require "colorize"

def ok_status
  "[OK]".green + " "
end

def alert_status
  "[ALERT]".red + " "
end
  
# a 'truth' site - a site that should always be available
TruthSite = "http://google.com"

if ARGV[0] && ARGV[0].match(/^install/i)
  puts "Updating cron"
  %x[bundle exec whenever --update-cron]
  exit
end

queryurl = "http://publicissueindex.org/"
if ARGV[0]
  # TODO: should check if url is valid
  queryurl = ARGV[0]
end

def internet_connection?
  server_alive? TruthSite
end

def server_alive? host
  Ping.pingecho URI.parse(host).host, 1, 80  
end

def http_response_code url
  Net::HTTP.get_response(URI.parse(url)).code.to_i
end

def code_ok? code, expect_range = (200..206)
  expect_range.include? code
end

unless internet_connection?
  abort alert_status + "No internet connection. Aborting."
end

unless server_alive? queryurl
  abort alert_status + "Site is down:  The server does not respond at all."
end

code = http_response_code queryurl
unless code_ok? code
  abort alert_status + "Site is down:  Got HTTP response code #{code} from #{url}"
end

puts ok_status

exit

