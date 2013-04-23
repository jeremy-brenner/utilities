#!/usr/bin/env ruby

require 'yaml'

class Services
  def initialize ( config_file = nil )
    @config_file = !config_file ? File.join( File.dirname(__FILE__), 'mac_service.yml' )  : config_file
    read_service_defs
    load_services
  end

  def read_service_defs
    @service_defs = YAML.load_file( @config_file ) 
  end

  def load_services
    @services = {}
    @service_defs.each do |service,service_def|
      @services[service] = Service.new( service, service_def, self )
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
        if has_service_and_action?( ARGV[0], ARGV[1] )
          service_name, action = ARGV
        end
        if has_service_and_action?( ARGV[1], ARGV[0] )
          service_name, action = ARGV.reverse
        end
    end 
    [ service_name, action ] 
  end

  def do( args )
    service_name, action = parse_args( args )
    return send(action,service_name) if respond_to? action.to_s
    if service(service_name).respond_to? action.to_s
      service(service_name).send(action) 
      print_status(service_name)
    else
      return "Invalid arguments\n"
    end
  end

  def has_service_and_action? ( service_name, action )
    has_service?(service_name) && service(service_name).has_action?(action)
  end

  def service ( service_name )
    @services[service_name]
  end

  def actions
    [ 'list', 'status' ]
  end

  def list ( service_name = nil )
    service_name ? print_actions(service_name) : print_services
  end

  def print_services
    print "Services:\n"
    @services.keys.each do |service_name|
      print "  #{service_name} - "
      print_status( service_name )      
    end
  end

  def print_actions ( service_name )
    s = service(service_name)
    print "Available actions for #{service_name} are: #{ s.actions.join(", ") }\n"
    print "#{service_name} needs sudo to run.\n" if s.uses_sudo?
  end

  def print_status ( service_name )
    s = service(service_name)
    return print "Process not running.\n" unless s.running?
    print "Process running at pids: #{s.pids.join(", ")}.\n"
  end
  
  alias_method :status, :print_status

  def has_service? ( service_name )
    @services.has_key? service_name
  end
end

class Service
  def initialize( name, actions, parent )
    @name = name
    @actions = actions
    @parent = parent
  end

  def actions 
    @parent.actions + @actions.keys.select { |k| k != 'sudo' }
  end

  def uses_sudo?
    @actions.has_key? 'sudo'
  end
  def has_action? ( action )
    actions.include?(action)
  end
  def pids 
    `pgrep -f '#{ @actions["start"] }'`.split("\n") 
  end
  def running?
    pids.length > 0
  end 
  def run_cmd  ( action, *args )
    return unless has_action? action
    cmd = ( uses_sudo? ? "sudo ": "" ) + "#{ @actions[action] } >/dev/null 2>&1 &"
    if args.length > 0
      `#{cmd % args}` 
    else
      `#{cmd}` 
    end
  end
  def start
    return print "Already running\n" if running?
    print "Starting #{@name}...\n"
    run_cmd("start")
  end
  def stop 
    pids.each do |pid|
      print "Killing #{pid}...\n"
      run_cmd("stop", pid)
    end
  end
  def reload 
    pids.each do |pid|
      print "Reloading #{pid}...\n"
      run_cmd("reload", pid)
    end
  end
end

services = Services.new
services.do( ARGV )
