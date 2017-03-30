# vagrant-bind9-varnish-RdDC

Skeleton for demo of Varnish caching and DNS using Vagrant.

This project sets up the following VMs on a private network in VirtualBox:

* web1 (192.168.2.11)
* web2 (192.168.2.12)
* varnish1 (192.168.2.13)
* varnish2 (192.168.2.14)
* bind9 (192.168.2.15)
* firefox (192.168.2.16)

# Prerequisites

1.  Install [Vagrant](http://www.vagrantup.com/downloads.html)
2.  Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
3.  Either clone this repo, or download the zip file and extract it to an empty directory.

# Getting started

* From the root directory, run `vagrant up`


## Configuring DNS server

Bind9 DNS server is unconfigured. You must configure it properly to serve de IP addresses of varnish and web servers

## Scenarios to investigate

First, you have to investigate when varnish servers are caching or not caching some of the web servers content depending on the existing .htaccess configuration of the stored website.

Second, you have to modify varnish servers to attend both servers.

Third, you have to modify previous DNS configuration to performa load balancing between the varnish servers.


# Shutting down

* `vagrant halt` turns off vms
* `vagrant destroy` destroys all traces of the VMs, but leaves the
  cached images
* `vagrant box remove ...` removes the downloaded image file.

