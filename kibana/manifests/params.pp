class kibana::params {

$kibana_port = '5601'
$kibana_bind_address = '0.0.0.0'
$kibana_directory = '/opt/kibana'
$kibana_user = 'kibana'
$kibana_group = 'kibana'
$kibana_download_url = 'https://github.com/rashidkpc/Kibana.git'
$elasticsearch = 'localhost:9200'

$gem_bin_path = $::operatingsystem ? {
  Debian => '/var/lib/gems/1.8/bin',
  Ubuntu => '/var/lib/gems/1.8/bin',
  CentOS => '/var/lib/gems/1.8/bin',
  RedHat => '/var/lib/gems/1.8/bin',
}


$kibana_init_template = $::operatingsystem ? {
  Debian => 'debian.init.erb',
  Ubuntu => 'debian.init.erb',
  CentOS => 'redhat.init.erb',
  RedHat => 'redhat.init.erb',
}

}
