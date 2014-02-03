class apache {
	package { "apache2": 
		ensure => "latest",
		require => Class["apt"],
	}
	service { "apache2": 
		ensure => "running",
		require => Package["apache2"],
	}
}

################################################################################
# Load module - http://snowulf.com/2012/04/05/puppet-quick-tip-enabling-an-apache-module/
################################################################################

define apache::loadmodule () {
  exec { "/usr/sbin/a2enmod $name" :
    unless => "/bin/readlink -e /etc/apache2/mods-enabled/${name}.load",
    require => Package["apache2"],
    notify => Service[apache2]
  }
}
define apache::ensite () {
  file { "/var/www/${name}" :
  	ensure => link,
    target => "/vagrant/src/${name}",
    require => Package["apache2"],
    notify => Service[apache2]
  }
}