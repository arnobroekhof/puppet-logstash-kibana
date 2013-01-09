puppet-logstash-kibana
======================

Module for creating a logstash and kibana syslog server

this module creates a default syslog server listener on port 5000


NOTE:
currently the init scripts included are only for debian and ubuntu


howto use:


node "node-name" {
 class { "logstash": }
 class { "kibana": }
}


configure rsyslog on the hosts

*.* @@<ipaddress>:5000


