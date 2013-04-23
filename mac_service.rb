#!/usr/bin/env ruby

require 'yaml'

class Services
  def initialize ( services={} )
    @script_location = File.dirname(__FILE__)
    @config_name = 'mac_service.yml'
    @services = YAML.load_file( File.join( @script_location, @config_name ) )    
  end
  def do( args )
    service_name, action = parse_args( args )
    if !action 
      print "Invalid arguments\n"
    else
      send(action,service_name)
    end
  end
  def parse_args( args )
    service_name = nil
    action = nil
    case ARGV.length
      when 0 
        action = 'list'
      when 1
        if has_service? ARGV[0]
          service_name, action = [ ARGV[0], 'list' ]
        else 
          action = ARGV[0]
        end
      when 2
        if has_action?( ARGV[0], ARGV[1] )
          service_name, action = ARGV
        end
        if has_action?( ARGV[1], ARGV[0] )
          service_name, action = ARGV.reverse
        end
    end 
    [ service_name, action ] 
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
  def list ( service_name = nil )
    service_name ? list_actions(service_name) : list_services
  end
  def list_services
    print "Services:\n"
    @services.keys.each do |service_name|
      print "  #{service_name} - "
      status( service_name )      
    end
  end
  def list_actions ( service_name )
    print "Available actions for #{service_name} are: #{ actions(service_name).join(", ") }\n"
    print "#{service_name} needs sudo to run.\n" if uses_sudo?(service_name)
  end
  def actions ( service_name )
    [ 'list' ] + @services[service_name].keys.select { |k| k != 'sudo' }
  end
  def has_action? ( service_name, action )
    has_service?(service_name) && actions(service_name).include?(action)
  end
  def uses_sudo? ( service_name )
    @services[service_name].has_key? 'sudo'
  end
  def status ( service_name )
    pids = self.get_pids( service_name ) 
    return print "Process not running.\n" unless pids.length > 0
    print "Process running at pids: #{pids.join(", ")}.\n"
    pids 
  end
  def running? ( service_name )
    pids = self.get_pids( service_name )
    pids.length > 0
  end 
  def get_pids ( service_name )
    `pgrep -f '#{ @services[service_name]["start"] }'`.split("\n") 
  end
  def has_service? ( service_name )
    @services.has_key? service_name
  end
end

services = Services.new
services.do( ARGV )
