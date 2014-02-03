# Set a default $PATH for all execs http- ://www.puppetcookbook.com/posts/set-global-exec-path.html
Exec { path => [
    "/usr/local/sbin",
    "/usr/local/bin",
    "/usr/sbin",
    "/usr/bin",
    "/sbin:/bin",
  ]
}

stage { 'prepare': before => Stage['main'] }

# Update
class apt-keys{
	exec {'apt-get update':}
	class{'apt':
	  always_apt_update => true,
	  require           => Exec['apt-get update'],
	}
	apt::ppa { 'ppa:gwibber-daily/ppa':
	  require => Exec['apt-get update'],
	}
}

class{
	'apt-keys': stage => prepare;
	'common': stage => main;
	'apache': stage => main;
	'oauth_mysql': stage => main;
	'php': stage => main;
}

################################################################################
# Reload apache - http://projects.puppetlabs.com/projects/1/wiki/Debian_Apache2_Recipe_Patterns
################################################################################

exec {'reload apache':
  command => "/etc/init.d/apache2 reload",
  refreshonly => true,
}

# Apache modules
apache::loadmodule{'rewrite':}

# Apache hosts
apache::ensite{'oauth2-server-php':}

import 'classes/common.pp'
import 'classes/mysql.pp'
import 'classes/php.pp'