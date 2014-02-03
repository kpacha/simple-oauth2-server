class oauth_mysql{
  class { '::mysql::server':
    root_password    => 'root.admin',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
    databases        => {
      'oauth' => {
        ensure  => 'present',
        charset => 'utf8',
        collate => 'utf8_unicode_ci',
      },
    },
    grants           => {
      'oauthuser@localhost/oauth.*' => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
        table      => 'oauth.*',
        user       => 'oauthuser@localhost',
      },
    },
    users            => {
      'oauthuser@localhost' => {
        ensure                   => 'present',
        max_connections_per_hour => '0',
        max_queries_per_hour     => '0',
        max_updates_per_hour     => '0',
        max_user_connections     => '0',
        password_hash            => '*935D5F5707C45580035F46480A22A8C93E646591',
      },
    },
  }

  class{ 'mysql::client':
  }

  exec { 'import mysql':
    command => 'mysql -uroot -proot.admin -D oauth < /vagrant/sql/oauth.sql',
    require => [ Class['::mysql::server'], Class['mysql::client']],
  }
}