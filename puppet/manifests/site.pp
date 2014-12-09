node default {
  file { '/var/www/':
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
  }
  file { '/var/www/oauth2-server-php':
    source  => '/vagrant/src/oauth2-server-php',
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    recurse => true,
    require => File['/var/www/'],
  }

  class {'::varnish':
    varnish_listen_port => 80,
    varnish_storage_size => '10M',
  }
  class { '::varnish::vcl': }

  class { 'nginx': }
  nginx::resource::vhost { 'oauth2-server.local':
    www_root    => '/var/www/oauth2-server-php/public',
    listen_port => 8080,
    require     => File['/var/www/oauth2-server-php'],
  }
  nginx::resource::location { "${name}_root":
     ensure          => present,
     vhost           => "oauth2-server.local",
     www_root        => "/var/www/oauth2-server-php/public/",
     location        => '~ \.php$',
     index_files     => ['index.php', 'index.html', 'index.htm'],
     proxy           => undef,
     fastcgi         => 'unix:/var/run/php5-fpm.sock',
     fastcgi_script  => undef,
     location_cfg_append => {
       fastcgi_connect_timeout => '3m',
       fastcgi_read_timeout    => '3m',
       fastcgi_send_timeout    => '3m'
     }
   }

  include ::php
  class { ['::php::fpm', '::php::extension::mysql']: }
  php::fpm::config { 'Disable cgi.fix_pathinfo':
    setting => 'cgi.fix_pathinfo',
    value   => '0'
  }

  class { '::mysql::server': }
  mysql::db { 'oauth':
    user     => 'oauthuser',
    password => 'oauthpassword',
    host     => 'localhost',
    grant    => ['ALL'],
    sql      => '/vagrant/puppet/files/oauth.sql',
  }
}
