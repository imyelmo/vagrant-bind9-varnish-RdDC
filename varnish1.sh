!/bin/bash
sudo apt-get update
sudo sudo apt-get install curl gnupg apt-transport-https -y
curl -L https://packagecloud.io/varnishcache/varnish41/gpgkey | sudo apt-key add -
sudo echo "deb https://packagecloud.io/varnishcache/varnish41/ubuntu/ precise main" | sudo tee -a /etc/apt/sources.list.d/varnish-cache.list
sudo apt-get update -y
sudo apt-get install varnish vim -y

# Overwrite DHCP DNS 
sudo cat > /tmp/dhclient <<EOD
# Configuration file for /sbin/dhclient, which is included in Debian's
#	dhcp3-client package.
#
# This is a sample configuration file for dhclient. See dhclient.conf's
#	man page for more information about the syntax of this file
#	and a more comprehensive list of the parameters understood by
#	dhclient.
#
# Normally, if the DHCP server provides reasonable information and does
#	not leave anything out (like the domain name, for example), then
#	few changes must be made to this file, if any.
#

option rfc3442-classless-static-routes code 121 = array of unsigned integer 8;

send host-name "<hostname>";
#send dhcp-client-identifier 1:0:a0:24:ab:fb:9c;
#send dhcp-lease-time 3600;
#supersede domain-name "fugue.com home.vix.com";
prepend domain-name-servers 192.168.2.15;

request subnet-mask, broadcast-address, time-offset, routers,
	domain-name, domain-name-servers, domain-search, host-name,
	netbios-name-servers, netbios-scope, interface-mtu,
	rfc3442-classless-static-routes, ntp-servers,
	dhcp6.domain-search, dhcp6.fqdn,
	dhcp6.name-servers, dhcp6.sntp-servers;
#require subnet-mask, domain-name-servers;
#timeout 60;
#retry 60;
#reboot 10;
#select-timeout 5;
#initial-interval 2;
#script "/etc/dhcp3/dhclient-script";
#media "-link0 -link1 -link2", "link0 link1";
#reject 192.33.137.209;

#alias {
#  interface "eth0";
#  fixed-address 192.5.5.213;
#  option subnet-mask 255.255.255.255;
#}

#lease {
#  interface "eth0";
#  fixed-address 192.33.137.200;
#  medium "link0 link1";
#  option host-name "andare.swiftmedia.com";
#  option subnet-mask 255.255.255.0;
#  option broadcast-address 192.33.137.255;
#  option routers 192.33.137.250;
#  option domain-name-servers 127.0.0.1;
#  renew 2 2000/1/12 00:00:01;
#  rebind 2 2000/1/12 00:00:01;
#  expire 2 2000/1/12 00:00:01;
#}
EOD

sudo cat > /tmp/varnish_default <<EOD
# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
#
# Default backend definition.  Set this to point to your content
# server.
#
backend default {
    .host = "192.168.2.11";
    .port = "80";
}
#
# Below is a commented-out copy of the default VCL logic.  If you
# redefine any of these subroutines, the built-in logic will be
# appended to your code.
 sub vcl_recv {
     if (req.restarts == 0) {
 	if (req.http.x-forwarded-for) {
 	    set req.http.X-Forwarded-For =
 		req.http.X-Forwarded-For + ", " + client.ip;
 	} else {
 	    set req.http.X-Forwarded-For = client.ip;
 	}
     }
     if (req.request != "GET" &&
       req.request != "HEAD" &&
       req.request != "PUT" &&
       req.request != "POST" &&
       req.request != "TRACE" &&
       req.request != "OPTIONS" &&
       req.request != "DELETE") {
#         /* Non-RFC2616 or CONNECT which is weird. */
         return (pipe);
     }
     if (req.request != "GET" && req.request != "HEAD") {
#         /* We only deal with GET and HEAD by default */
         return (pass);
     }
     if (req.http.Authorization || req.http.Cookie) {
#         /* Not cacheable by default */
         return (pass);
     }
     if (req.http.Cache-Control ~ "(private|no-cache|no-store)" || req.http.Pragma == "no-cache") {
	 return (pass);
     }
     return (lookup);
 }
#
# sub vcl_pipe {
#     # Note that only the first request to the backend will have
#     # X-Forwarded-For set.  If you use X-Forwarded-For and want to
#     # have it set for all requests, make sure to have:
#     # set bereq.http.connection = "close";
#     # here.  It is not set by default as it might break some broken web
#     # applications, like IIS with NTLM authentication.
#     return (pipe);
# }
#
# sub vcl_pass {
#     return (pass);
# }
#
# sub vcl_hash {
#     hash_data(req.url);
#     if (req.http.host) {
#         hash_data(req.http.host);
#     } else {
#         hash_data(server.ip);
#     }
#     return (hash);
# }
#
# sub vcl_hit {
#     return (deliver);
# }
#
# sub vcl_miss {
#     return (fetch);
# }
#
  sub vcl_fetch {
     if (beresp.http.Cache-Control ~ "(private|no-cache|no-store)" || beresp.http.Pragma == "no-cache") {
	return (hit_for_pass);
     }
     if (beresp.ttl <= 0s ||
         beresp.http.Set-Cookie ||
         beresp.http.Vary == "*") {
# 		/*
# 		 * Mark as "Hit-For-Pass" for the next 2 minutes
# 		 */
 		set beresp.ttl = 120 s;
 		return (hit_for_pass);
     }
     return (deliver);
 }
#
# sub vcl_deliver {
#     return (deliver);
# }
#
# sub vcl_error {
#     set obj.http.Content-Type = "text/html; charset=utf-8";
#     set obj.http.Retry-After = "5";
#     synthetic {"
# <?xml version="1.0" encoding="utf-8"?>
# <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
#  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
# <html>
#   <head>
#     <title>"} + obj.status + " " + obj.response + {"</title>
#   </head>
#   <body>
#     <h1>Error "} + obj.status + " " + obj.response + {"</h1>
# This is a basic VCL configuration file for varnish.  See the vcl(7)
#     <p>"} + obj.response + {"</p>
#     <h3>Guru Meditation:</h3>
#     <p>XID: "} + req.xid + {"</p>
#     <hr>
#     <p>Varnish cache server</p>
#   </body>
# </html>
# "};
#     return (deliver);
# }
#
# sub vcl_init {
# 	return (ok);
# }
#
# sub vcl_fini {
# 	return (ok);
# }
EOD

sudo cat > /tmp/varnish <<EOD

# Configuration file for varnish
#
# /etc/init.d/varnish expects the variables $DAEMON_OPTS, $NFILES and $MEMLOCK
# to be set from this shell script fragment.
#

# Should we start varnishd at boot?  Set to "no" to disable.
START=yes

# Maximum number of open files (for ulimit -n)
NFILES=131072

# Maximum locked memory size (for ulimit -l)
# Used for locking the shared memory log in memory.  If you increase log size,
# you need to increase this number as well
MEMLOCK=82000

# Default varnish instance name is the local nodename.  Can be overridden with
# the -n switch, to have more instances on a single server.
# INSTANCE=$(uname -n)

# This file contains 4 alternatives, please use only one.

## Alternative 1, Minimal configuration, no VCL
#
# Listen on port 6081, administration on localhost:6082, and forward to
# content server on localhost:8080.  Use a 1GB fixed-size cache file.
#
# DAEMON_OPTS="-a :6081 \
#              -T localhost:6082 \
# 	     -b localhost:8080 \
# 	     -u varnish -g varnish \
#            -S /etc/varnish/secret \
# 	     -s file,/var/lib/varnish/$INSTANCE/varnish_storage.bin,1G"


## Alternative 2, Configuration with VCL
#
# Listen on port 6081, administration on localhost:6082, and forward to
# one content server selected by the vcl file, based on the request.  Use a 1GB
# fixed-size cache file.
#
DAEMON_OPTS="-a :80 \
             -T localhost:6082 \
             -f /etc/varnish/default.vcl \
             -S /etc/varnish/secret \
             -s malloc,256m"


## Alternative 3, Advanced configuration
#
# See varnishd(1) for more information.
#
# # Main configuration file. You probably want to change it :)
# VARNISH_VCL_CONF=/etc/varnish/default.vcl
#
# # Default address and port to bind to
# # Blank address means all IPv4 and IPv6 interfaces, otherwise specify
# # a host name, an IPv4 dotted quad, or an IPv6 address in brackets.
# VARNISH_LISTEN_ADDRESS=
# VARNISH_LISTEN_PORT=6081
#
# # Telnet admin interface listen address and port
# VARNISH_ADMIN_LISTEN_ADDRESS=127.0.0.1
# VARNISH_ADMIN_LISTEN_PORT=6082
#
# # The minimum number of worker threads to start
# VARNISH_MIN_THREADS=1
#
# # The Maximum number of worker threads to start
# VARNISH_MAX_THREADS=1000
#
# # Idle timeout for worker threads
# VARNISH_THREAD_TIMEOUT=120
#
# # Cache file location
# VARNISH_STORAGE_FILE=/var/lib/varnish/$INSTANCE/varnish_storage.bin
#
# # Cache file size: in bytes, optionally using k / M / G / T suffix,
# # or in percentage of available disk space using the % suffix.
# VARNISH_STORAGE_SIZE=1G
#
# # File containing administration secret
# VARNISH_SECRET_FILE=/etc/varnish/secret
# 
# # Backend storage specification
# VARNISH_STORAGE="file,${VARNISH_STORAGE_FILE},${VARNISH_STORAGE_SIZE}"
#
# # Default TTL used when the backend does not specify one
# VARNISH_TTL=120
#
# # DAEMON_OPTS is used by the init script.  If you add or remove options, make
# # sure you update this section, too.
# DAEMON_OPTS="-a ${VARNISH_LISTEN_ADDRESS}:${VARNISH_LISTEN_PORT} \
#              -f ${VARNISH_VCL_CONF} \
#              -T ${VARNISH_ADMIN_LISTEN_ADDRESS}:${VARNISH_ADMIN_LISTEN_PORT} \
#              -t ${VARNISH_TTL} \
#              -w ${VARNISH_MIN_THREADS},${VARNISH_MAX_THREADS},${VARNISH_THREAD_TIMEOUT} \
# 	       -S ${VARNISH_SECRET_FILE} \
#              -s ${VARNISH_STORAGE}"
#


## Alternative 4, Do It Yourself
#
# DAEMON_OPTS=""
EOD

sudo cp /tmp/dhclient /etc/dhcp/dhclient.conf
sudo cp /tmp/varnish /etc/default/varnish
sudo cp /tmp/varnish_default /etc/varnish/default.vcl

sudo ifdown eth0; sudo ifup eth0
sudo service varnish restart
