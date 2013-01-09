class logstash::service {
  service { 'logstash-service':
	name => 'logstash',
	ensure => 'running',
	hasstatus => 'false',
	pattern => 'logstash',
  }
}
