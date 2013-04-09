utilities
=========

misc utils


mac_service.rb: simple service controller for homebrew apps ( or anything else )

jbrenner@imac:~/projects/Utilities$ ./mac_service.rb start nginx
Process not running.
Starting nginx
Process running at pids: 50178.
jbrenner@imac:~/projects/Utilities$ ./mac_service.rb reload nginx
Process running at pids: 50178.
Reloading 50178...
jbrenner@imac:~/projects/Utilities$ ./mac_service.rb stop nginx
Process running at pids: 50178.
Killing 50178...
jbrenner@imac:~/projects/Utilities$ ./mac_service.rb status nginx
Process not running.

Services are currently a ruby hash but will probably be moved to a json config file.

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
