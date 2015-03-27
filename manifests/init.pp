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
    $ip_address                 = undef;
    $ip_transient               = undef;
    $hide_version               = undef;
    $debug_mode                 = undef;
    $ipv4_only                  = undef;
    $ipv6_only                  = undef;
    $database                   = undef;
    $identity                   = undef;
    $server_count               = undef;
    $statistics                 = undef;
    $zone_stats_file            = undef;
    $chroot                     = undef;
    $username                   = undef;
    $zonesdir                   = undef;
    $difffile                   = undef;
    $xfrdfile                   = undef;
    $xfrd_reload_timeout        = undef;
    $verbosity                  = undef;
    $rrl_size                   = undef;
    $rrl_ratelimit              = undef;
    $rrl_slip                   = undef;
    $rrl_ipv4_prefix_length     = undef;
    $rrl_ipv6_prefix_length     = undef;
    $rrl_whitelist_ratelimit    = undef;
) {

    $os = downcase($::operatingsystem)
    case $os {
        centos, redhat, debian, ubuntu: {
            $nsd_package = 'nsd',
        }
        default:  {
            fail("I've got not idea what the package is called on your operating system, please raise a bug and tell me.")
        }
    }

    package { 'nsd':
        name    => $nsd_package,
        ensure  => '>4',
    }

    file { '/etc/nsd':
        ensure  => directory,
        owner   => 'root',
        group   => 'nsd',
        mode    => '0750',
    }

    file { '/etc/nsd/nsd.conf':
        ensure  => file,
        owner   => 'root',
        group   => 'nsd',
        mode    => '0640',
        source  => template('nsd/nsd.conf.erb'),
        require => [ File['/etc/nsd'], ],
    }

    service { 'nsd':
        ensure  => running,
        enabled => true,
        require => [ Package['nsd'], File['/etc/nsd/nsd.conf'], ],
    }
}
