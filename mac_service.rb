#!/usr/bin/env ruby

require 'yaml'

script_location = File.dirname(__FILE__)
config_name = 'mac_service.yml'
services = YAML.load_file( File.join( script_location, config_name ) )

class Services
  def initialize ( services={} )
    @services=services
  end
  def get_cmd( action, service_name )
    print "#{service_name} not defined" unless service_name
    print "#{action} not defined for #{service_name}" unless action
    ( @services[service_name]["sudo"] ? "sudo ": "" ) + "#{ @services[service_name][action] } >/dev/null 2>&1 &"
  end
  def start ( service_name )
    return if self.status( service_name )
    print "Starting #{service_name}\n"
    if cmd = get_cmd( "start", service_name )
      `#{cmd}` 
    end
    self.status( service_name )
  end
  def stop ( service_name )
    pids = self.status( service_name ) || []
    return if pids.length == 0
    pids.each do |pid|
      print "Killing #{pid}...\n"
      if cmd = get_cmd( "stop", service_name )
        `#{cmd % pid}`     
      end
    end
  end
  def reload ( service_name )
    pids = self.status( service_name ) || []
    return if pids.length == 0
    pids.each do |pid|
      print "Reloading #{pid}...\n"
      if cmd = get_cmd( "reload", service_name )
        `#{cmd % pid}` 
      end
    end
  end
  def list ( service_name = '' )
    print "Services:\n"
    @services.keys.each do |service_name|
      print "  #{service_name} - "
      status( service_name )      
    end
  end
  def status ( service_name )
    pids = self.getPids( service_name ) 
    return print "Process not running.\n" unless pids.length > 0
    print "Process running at pids: #{pids.join(", ")}.\n"
    pids 
  end
  def running? ( service_name )
    pids = self.getPids( service_name )
    pids.length > 0
  end 
  def getPids ( service_name )
    `pgrep -f '#{ @services[service_name]["start"] }'`.split("\n") 
  end
end

service = Services.new( services )

action = ARGV[0] || 'list'
service_name = ARGV[1] || ''

service.send( action, service_name )
