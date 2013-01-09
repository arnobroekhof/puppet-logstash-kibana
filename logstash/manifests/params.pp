class logstash::params {


$syslog_port = '5000'
$logstash_directory = '/opt/logstash'
$logstash_user = 'logstash'
$logstash_group = 'logstash'
$logstash_download_url = 'https://logstash.objects.dreamhost.com/release/logstash-1.1.7-monolithic.jar'
$logstash_config_file = 'logstash.conf'
$logstash_config_file_template = 'logstash.syslog.conf.erb'


$logstash_init_template = $::operatingsystem ? {
  Debian => 'debian.init.erb',
  Ubuntu => 'debian.init.erb',
  CentOS => 'redhat.init.erb',
  RedHat => 'redhat.init.erb',
}

$logstash_java_package = $::operatingsystem ? {
  debian => 'openjdk-6-jre-headless',
  ubuntu => 'openjdk-6-jre-headless',
  redhat => 'openjdk-6-jre-headless',
  centos => 'openjdk-6-jre-headless',
  default => 'jdk',
}

}
