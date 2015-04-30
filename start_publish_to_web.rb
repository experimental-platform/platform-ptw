#!/usr/bin/ruby
PORT = 80
unless ENV["BINDHOST_PORT_#{PORT}_TCP_ADDR"] || ENV["HOSTNAME"]
  puts "$BINDHOST_PORT_80_TCP_ADDR or $HOSTNAME is not set!"
  puts "Please start this container with linked bindhost container, exposed port #{PORT} and defined hostname."
  puts "eg. -> docker run -d --name publish_to_web --hostname foobar.protonet.info --link <to bind container>:bindhost protonet/publish_to_web"
  exit 127
end

require 'fileutils'
require 'publish_to_web'

CONFIG_PATH = ENV["PROTONET_CONFIG"] || "/tmp"
IDENTIFIER_FILE = "#{CONFIG_PATH}/hardware_id"

FileUtils.mkdir_p(CONFIG_PATH)

def ensure_identifier_exists
  unless File.exists?(IDENTIFIER_FILE)
    IO.write(IDENTIFIER_FILE, generate_hardware_id)
  end
end

def generate_hardware_id
  require 'securerandom'
  "aal-#{SecureRandom.uuid}"
end

ensure_identifier_exists

publish_to_web = PublishToWeb.new
_, nodename, _ = publish_to_web.info

expected_nodename = ENV["HOSTNAME"]
if !expected_nodename.empty? && nodename != expected_nodename
  publish_to_web.set_node_name expected_nodename.gsub(/\.protonet\.info$/, "") #this is ugly
end

publish_to_web.start PORT, ENV["BINDHOST_PORT_#{PORT}_TCP_ADDR"]
