class kibana::service {
  service { 'kibana-service':
	name => 'kibana',
	ensure => 'running',
	hasstatus => 'false',
	pattern => 'kibana',
  }
}
