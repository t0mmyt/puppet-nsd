class nsd::git (
    $keyname   = undef,
    $pubkey    = undef
) {
    file {'/etc/nsd/.ssh':
        ensure  => directory,
        owner   => 'nsd',
        group   => 'root',
        mode    => '0700',
    }

    user { 'nsd':
        ensure  => present,
        shell   => '/bin/sh',
    }

    package { 'git':
        ensure  => latest,
    }

    ssh_authorized_key { $keyname:
        ensure  => present,
        user    => 'nsd',
        type    => 'rsa',
        key     => $pubkey,
        options => [ 'command="/etc/nsd/scripts/update_zones.py"' ] ,
        require => [ File['/etc/nsd/.ssh'], ],
    }

    file { '/etc/nsd/.ssh/id_rsa':
        ensure  => file,
        owner   => 'nsd',
        group   => 'root',
        mode    => '0600',
        source  => 'puppet:///modules/nsd/id_nameserver',
        require => [ File['/etc/nsd/.ssh'], ],
    }
}
