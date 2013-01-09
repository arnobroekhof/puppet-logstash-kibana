class kibana (
  $kibana_port = params_lookup('kibana_port'),
  $kibana_bind_address = params_lookup('kibana_bind_address'),
  $kibana_directory = params_lookup('kibana_directory'),
  $kibana_init_template = params_lookup('kibana_init_template'),
  $kibana_download_url = params_lookup('kibana_download_url'),
  $kibana_user = params_lookup('kibana_user'),
  $kibana_group = params_lookup('kibana_group'),
  $elasticsearch = params_lookup('elasticsearch'),
  $gem_bin_path = params_lookup('gem_bin_path')
) inherits kibana::params {
 include stdlib

 # create user and group for kibana
  group { 'kibana-group':
    ensure => 'present',
    name => $kibana::kibana_group,
  }

  user { 'kibana-user':
   ensure => 'present',
   name => $kibana::kibana_user,
   gid => $kibana::kibana_group,
   home => $kibana::kibana_directory,
   require => Group['kibana-group'],
  }

  file  { 'kibana-directory':
        ensure => 'directory',
	recurse => 'true',
        name => $kibana::kibana_directory,
        owner => $kibana::kibana_user,
        group => $kibana::kibana_group,
        require => User['kibana-user'],
  }

  package { "gem-bundler":
	name => 'bundler',
	ensure => 'installed',
	provider => 'gem',
  }
  package { "git-kibana":
	name => 'git',
	ensure => 'installed',
  }

  exec { "git clone $kibana::kibana_download_url $kibana::kibana_directory":
	creates => "$kibana::kibana_directory/kibana.rb",
	user => $kibana::kibana_user,
	alias => 'git-clone-kibana',
	require => Package['git-kibana'],
        path    => ["/usr/bin", "/usr/sbin"],
  }

  file { "kibana-config-file":
       ensure => 'present',
       name => "$kibana::kibana_directory/KibanaConfig.rb",
       owner => $kibana::kibana_user,
       group => $kibana::kibana_group,
       mode => '644',
       require => Exec['git-clone-kibana'],
       content => template('kibana/KibanaConfig.rb.erb'),
  }

  exec { "bundle install":
	alias => 'create-kibana-bundle',
	cwd => $kibana::kibana_directory,
	unless => "bundle show kibana | grep kibana",
	require => Exec['git-clone-kibana'],
        path    => ["/usr/bin", "/sbin", "/bin", "$kibana::gem_bin_path" , "/usr/sbin"],
  }
  file { 'kibana-init-script':
        name => "/etc/init.d/kibana",
        ensure => 'present',
        owner => 'root',
        group => 'root',
        mode => '555',
        content => template("kibana/$kibana::kibana_init_template"),
        require => Exec['create-kibana-bundle'],
  }
  file { 'kibana-start-script':
        name => "$kibana::kibana_directory/kibana-start",
        ensure => 'present',
        owner => 'root',
        group => 'root',
        mode => '555',
        content => template("kibana/kibana-start.sh.erb"),
        require => Exec['create-kibana-bundle'],
  }
  file { 'kibana-stop-script':
        name => "$kibana::kibana_directory/kibana-stop",
        ensure => 'present',
        owner => 'root',
        group => 'root',
        mode => '555',
        content => template("kibana/kibana-stop.sh.erb"),
        require => Exec['create-kibana-bundle'],
  }

  class { "kibana::service": stage => 'deploy_infra' }

}
