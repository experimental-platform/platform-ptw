#!/usr/bin/env ruby
PORT = 80
# unless ENV["BINDHOST_PORT_#{PORT}_TCP_ADDR"]
#   puts "$BINDHOST_PORT_80_TCP_ADDR is not set!"
#   puts "Please start this container with linked bindhost container, exposed port #{PORT}."
#   puts "eg. -> docker run -d --volume=/etc/protonet/ptw:/config --name publish_to_web --link <to bind container>:bindhost protonet/publish_to_web"
#   exit 127
# end

require 'fileutils'
require 'publish_to_web'

# Monkey-Patching PublishToWeb, cause of **** gem implementation.
class PublishToWeb
  def version
    "platform-alpha"
  end
end

CONFIG_PATH = ENV["PROTONET_CONFIG"] || "/tmp"
IDENTIFIER_FILE = "#{CONFIG_PATH}/hardware_id"
NODENAME_FILE = "#{CONFIG_PATH}/hostname"

FileUtils.mkdir_p(CONFIG_PATH)

def ensure_identifier_exists
  start = Time.now.to_i
  unless File.exists?(IDENTIFIER_FILE)
    IO.write(IDENTIFIER_FILE, generate_hardware_id)
  end
  # TODO: Switch to Prometheus/Graphite soon!
  puts 'platform.' + `hostname`.strip + 'ensure_identifier_exists: ' + (Time.now.to_i - start).to_s
end

def generate_hardware_id
  start = Time.now.to_i
  require 'securerandom'
  "aal-#{SecureRandom.uuid}"
  # TODO: Switch to Prometheus/Graphite soon!
  puts 'platform.' + `hostname`.strip + 'generate_hardware_id: ' + (Time.now.to_i - start).to_s
end

def expected_nodename
  start = Time.now.to_i
  IO.read(NODENAME_FILE).strip rescue ""
  # TODO: Switch to Prometheus/Graphite soon!
  puts 'platform.' + `hostname`.strip + 'expected_nodename: ' + (Time.now.to_i - start).to_s
end

def gateway
  start = Time.now.to_i
  # /proc/net/route contains all infos about current routes, we extract the default Gateway
  # Example Line: eth0  00000000  012A010A  0003  0 0 0 00000000  0 0 0
  # Second column is 0.0.0.0, so third column is our default gateway
  gateway_hex = `awk '$2==00000000 {print $3}' /proc/net/route`.strip
  # Ex.: 012A010A -> [01 2A 01 0A] -> [1 42 1 10].reverse -> [10 1 42 1].join('.') -> 10.1.42.1
  gateway_hex.scan(/.{2}/).reverse.map { |s| s.to_i(16) }.join(".")
  # TODO: Switch to Prometheus/Graphite soon!
  puts 'platform.' + `hostname`.strip + 'gateway: ' + (Time.now.to_i - start).to_s
end


ensure_identifier_exists

start = Time.now.to_i
publish_to_web = PublishToWeb.new
_, nodename, _ = publish_to_web.info
# TODO: Switch to Prometheus/Graphite soon!
puts 'platform.' + `hostname`.strip + 'PublishToWeb.info: ' + (Time.now.to_i - start).to_s


if !expected_nodename.empty? && nodename != "#{expected_nodename}.protonet.info"
  start = Time.now.to_i
  publish_to_web.set_node_name expected_nodename #this is ugly
  # TODO: Switch to Prometheus/Graphite soon!
  puts 'platform.' + `hostname`.strip + 'PublishToWeb.set_node_name: ' + (Time.now.to_i - start).to_s
end

puts "Initialization complete, starting PublishToWeb.start"
publish_to_web.start PORT, gateway
