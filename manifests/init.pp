# == Class: nsd
#
# Full description of class nsd here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'nsd':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class nsd (
    $ensure                     = 'latest',
    $ip_address                 = undef,
    $ip_transient               = undef,
    $hide_version               = undef,
    $debug_mode                 = undef,
    $ipv4_only                  = undef,
    $ipv6_only                  = undef,
    $database                   = undef,
    $identity                   = undef,
    $server_count               = undef,
    $statistics                 = undef,
    $zone_stats_file            = undef,
    $chroot                     = undef,
    $pidfile                    = undef,
    $username                   = undef,
    $zonesdir                   = undef,
    $difffile                   = undef,
    $xfrdfile                   = undef,
    $xfrd_reload_timeout        = undef,
    $verbosity                  = undef,
    $rrl_size                   = undef,
    $rrl_ratelimit              = undef,
    $rrl_slip                   = undef,
    $rrl_ipv4_prefix_length     = undef,
    $rrl_ipv6_prefix_length     = undef,
    $rrl_whitelist_ratelimit    = undef,
    $control_enable             = undef,
    $control_interface          = undef,
    $server_key_file            = '../nsd_server.key',
    $server_cert_file           = '../nsd_server.pem',
    $control_key_file           = undef,
    $control_cert_file          = undef,
) {

    $os = downcase($::operatingsystem)
    case $os {
        centos, redhat, debian, ubuntu: {
            $nsd_package = 'nsd'
        }
        default:  {
            fail("I've got not idea what the package is called on your operating system, please raise a bug and tell me.")
        }
    }

    package { 'nsd':
        ensure  => $ensure,
        name    => $nsd_package,
    }

    file { '/etc/nsd':
        ensure  => directory,
        owner   => 'root',
        group   => 'nsd',
        mode    => '0750',
    }

    file { '/etc/nsd/zones':
        ensure  => directory,
        owner   => 'root',
        group   => 'nsd',
        mode    => '0770',
        require => [ File['/etc/nsd'], ],
    }

    file { '/etc/nsd/zones/zones.conf':
        ensure  => file,
        replace => 'no',
        owner   => 'nsd',
        group   => 'nsd',
        mode    => '0640',
        content => '# Placeholder file, replace with version controlled version.',
        require => [ File['/etc/nsd/zones'], ],
    }

    file { '/etc/nsd/scripts':
        ensure  => directory,
        recurse => true,
        owner   => 'root',
        group   => 'nsd',
        mode    => '0750',
        source  => 'puppet:///modules/nsd/scripts',
        require => [ File['/etc/nsd'], ],
    }

    file { '/etc/nsd/nsd.conf':
        ensure  => file,
        owner   => 'root',
        group   => 'nsd',
        mode    => '0640',
        content => template('nsd/nsd.conf.erb'),
        require => [ File['/etc/nsd'], ],
    }

    exec { 'Create_nsd_control_keys':
        command => '/usr/sbin/nsd-control-setup && chown root:nsd /etc/nsd/nsd_*.{pem,key}',
        creates => '/etc/nsd/nsd_server.pem',
    }

    service { 'nsd':
        ensure  => running,
        enable  => true,
        require => [ Package['nsd'], File['/etc/nsd/nsd.conf', '/etc/nsd/zones/zones.conf'], ],
    }
}
