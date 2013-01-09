class logstash (
  $syslog_port = params_lookup('syslog_port'),
  $logstash_directory = params_lookup('logstash_directory'),
  $logstash_init_template = params_lookup('logstash_init_template'),
  $logstash_user = params_lookup('logstash_user'),
  $logstash_group = params_lookup('logstash_group'),
  $logstash_java_package = params_lookup('logstash_java_package'),
  $logstash_download_url = params_lookup('logstash_download_url'),
  $logstash_config_file = params_lookup('logstash_config_file'),
  $logstash_config_file_template = params_lookup('logstash_config_file_template')
) inherits logstash::params {
  
  include stdlib


  # create user and group for logstash
  group { 'logstash-group':
    ensure => 'present',
    name => $logstash::logstash_group,
  }
  
  user { 'logstash-user':
   ensure => 'present',
   name => $logstash::logstash_user,
   gid => $logstash::logstash_group,
   home => $logstash::logstash_directory,
   require => Group['logstash-group'],
  }

  file  { 'logstash-directory':
	ensure => 'directory',
	name => $logstash::logstash_directory,
	owner => $logstash::logstash_user,
	group => $logstash::logstash_group,
	require => User['logstash-user'],
  }

  # ensure an java environment is installed
  package { 'logstash-java-package':
	name => $logstash::logstash_java_package,
	ensure => 'installed',
  }

  # download logstash
  exec { "wget $logstash::logstash_download_url -O $logstash::logstash_directory/logstash.jar > /dev/null 2>&1":
    alias => 'download-logstash',
    creates => "$logstash::logstash_directory/logstash.jar",
    require => File['logstash-directory'],
    path    => ["/usr/bin", "/usr/sbin"],
  }->
    file { 'logstash-permission-check':
      ensure => 'present',
      name => "$logstash::logstash_directory/logstash.jar",
      owner => $logstash::logstash_user,
      group => $logstash::logstash_group,
      mode => '0755'
   }

  file { 'logstash-config-file':
	name => "$logstash::logstash_directory/$logstash::logstash_config_file",
	ensure => 'present',
        owner => $logstash::logstash_user,
        group => $logstash::logstash_group,
        content => template("logstash/$logstash::logstash_config_file_template"),
        mode => '0644',
	require => [ File['logstash-directory'], Exec['download-logstash'] ],
  }

  file { 'logstash-start-script':
	name => "$logstash::logstash_directory/logstash-start.sh",
	ensure => 'present',
        owner => $logstash::logstash_user,
        group => $logstash::logstash_group,
        content => template("logstash/logstash-start.sh.erb"),
        mode => '0755',
	require => [ File['logstash-directory'], Exec['download-logstash'] ],
  }

  file { 'logstash-init-script':
	name => "/etc/init.d/logstash",
	ensure => 'present',
	owner => 'root',
	group => 'root',
	mode => '555',
        content => template("logstash/$logstash::logstash_init_template"),
	require => File['logstash-start-script'],
  }

  class { "logstash::service": stage => 'deploy_infra' }
}
