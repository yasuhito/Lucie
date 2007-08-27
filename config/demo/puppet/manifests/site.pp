case $operatingsystem {
	default: {
		package { 'sudo':
			ensure => installed
		}
	}
}

file { 'sudoers':
	path	=>	$operatingsystem ? {
		default	=>	'/etc/sudoers'
	},
	source	=>	'puppet://lucie-server.localdomain.com/files/sudoers',
	mode	=>	0440,
	owner	=>	root,
	group	=>	$operatingsystem ? {
		default => root
	}
}

node 'lucie-client.localdomain.com' {
}
