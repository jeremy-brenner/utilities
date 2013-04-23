utilities
=========

misc utils


* mac_service.rb: simple service controller for homebrew apps ( or anything else )

```
$ ./mac_service.rb start nginx
Process not running.
Starting nginx
Process running at pids: 50178.

$ ./mac_service.rb reload nginx
Process running at pids: 50178.
Reloading 50178...

$ ./mac_service.rb stop nginx
Process running at pids: 50178.
Killing 50178...

$ ./mac_service.rb status nginx
Process not running.

$ ./mac_service.rb list
Services:
  postgres - Process running at pids: 231.
  nginx - Process running at pids: 1794.
  redis - Process running at pids: 1846.


```

* Services are stored in yaml

```
postgres:
  start: "/usr/local/opt/postgresql/bin/postgres -D /usr/local/var/postgres -r /usr/local/var/postgres/server.log"
  stop: "kill -INT %s"
nginx:
  sudo: true
  start: "/usr/local/opt/nginx/sbin/nginx"
  stop: "kill -QUIT %s"
  reload: "kill -HUP %s" 
redis:
  start: "redis-server /usr/local/etc/redis.conf"
  stop: "kill %s"
```

* TODO
give each service its own object 
