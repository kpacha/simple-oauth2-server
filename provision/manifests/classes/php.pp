################################################################################
# PHP 5.x
################################################################################
class php{
  package { 'php5':
    ensure => latest,
  }

  $php5_packages = [
    'php-apc',
    'php-pear',
    'php-console-table',
    'php5-cli',
    'php5-common',
    'php5-curl',
    'php5-dev',
    'php5-gd',
    'php5-odbc',
    'php5-mysql',
    'php5-mcrypt',
    'php5-ldap',
    'php5-tidy',
    'php5-xdebug',
  ]
  package { $php5_packages:
    ensure => installed,
    require => Package['php5']
  }

  # phpmyadmin
  package { 'phpmyadmin':
    ensure => installed,
    require => [Package['php5'], Class['::mysql::server']]
  }
  file { "/var/www/phpmyadmin" :
    ensure => link,
    target => "/usr/share/phpmyadmin",
    require => Package["phpmyadmin"],
    notify => Service[apache2]
  }

  # APC
  file { '/etc/php5/conf.d/apc.ini':
    ensure => 'present',
    content => 'apc.shm_size="64M"',
    mode => 644,
    require => Package['php-apc'],
  }

  # PHP info (for debugging)
  file { '/var/www/phpinfo.php':
    ensure => 'present',
    content => '<?php phpinfo(); ?>',
    require => Package['php5'],
    owner => "www-data",
    group => "www-data",
  }
}