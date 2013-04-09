#!/usr/bin/env ruby


services = {
  postgres: {
    start: "/usr/local/opt/postgresql/bin/postgres -D /usr/local/var/postgres -r /usr/local/var/postgres/server.log",
    stop: "kill -INT %s"
  },
  nginx: {
    start: "/usr/local/opt/nginx/sbin/nginx",
    stop: "kill -QUIT %s",
    reload: "kill -HUP %s" 
  }   
}        



class Services
  def initialize ( services={} )
    @services=services
  end
  def start ( service_name )
    return if self.status( service_name )
    print "Starting #{service_name}\n"
    `#{ @services[service_name.to_sym][:start] } >/dev/null 2>&1 &`
    self.status( service_name )
  end
  def stop ( service_name )
    pids = self.status( service_name ) 
    return if pids.length == 0
    pids.each do |pid|
      print "Killing #{pid}...\n"
      `#{ @services[service_name.to_sym][:stop] % pid }`
    end
  end
  def reload ( service_name )
    pids = self.status( service_name ) 
    return if pids.length == 0
    pids.each do |pid|
      print "Reloading #{pid}...\n"
      `#{ @services[service_name.to_sym][:reload] % pid }`
    end
  end
  def list ( service_name = '' )
    print "Available services: #{ @services.keys.join(", ") }\n"
  end
  def status ( service_name )
    pids = self.getPids( service_name ) 
    return print "Process not running.\n" unless pids.length > 0
    print "Process running at pids: #{pids.join(", ")}.\n"
    pids 
  end
  def getPids ( service_name )
    `pgrep -f '#{ @services[service_name.to_sym][:start] }'`.split("\n")
  end
end

service = Services.new( services )

service.send( ARGV[0], ARGV[1] )