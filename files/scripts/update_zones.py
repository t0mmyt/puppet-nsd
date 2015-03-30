#!/usr/bin/env python
import os
import sys
import socket
import subprocess
import re

working_dir = '/etc/nsd/zones'

class zone:
    def __init__(self):
        self.name = None
        self.zonefile = None

    def is_complete(self):
        if self.name and self.zonefile:
            return True

    def check_zone(self):
        do_command(['/usr/sbin/nsd-checkzone', self.name, self.zonefile])


def fatal(s):
    for line in s.rstrip().split('\n'):
        print "%10s: %s" % (s_host, line)
    sys.exit(1)

def output(s):
    for line in s.rstrip().split('\n'):
        print "%10s: %s" % (s_host, line)

def do_command(command):
    ''' function to run a command and return output or die with output '''
    output("RUNNING: " + " ".join(command))

    p = subprocess.Popen(command, stdout=subprocess.PIPE)
    out, err = p.communicate()

    if out:
        output(out)
    if err:
        output(err)

    if p.returncode != 0:
        fatal("Nonzero return code: %d" % p.returncode)

# cd to working dir
try:
    os.chdir(working_dir)
except OSError as e:
    fatal("Error: %s" % e)

# Store our hostname for verbose output
f_host = socket.gethostname()
s_host = f_host[:f_host.find('.')]

# Are we root? (bad!)
if os.getuid() == 0:
    fatal("You don't really want to be running this as root!!!")

# Git pull
#do_command(['/bin/sh', '-c', 'eval $(ssh-agent) && ssh-add ../.ssh/id_nameserver && git pull >/dev/null'])
do_command(['/usr/bin/git', 'pull'])

# Check nsd.conf
do_command(['/usr/sbin/nsd-checkconf', '/etc/nsd/nsd.conf'])

try:
    with open('/etc/nsd/zones/zones.conf') as zoneconfig:
        is_zone_start = re.compile('^zone:')
        is_zone_name = re.compile('\s+name: "(.*)"')
        is_zone_file = re.compile('\s+zonefile: "(.*)"')
        this_zone = None
        for line in zoneconfig:
            # Are we starting a zone definition?
            m = is_zone_start.match(line)
            if m:
                this_zone = zone()
            # Is this the name of a zone?
            m = is_zone_name.match(line)
            if this_zone and m:
                this_zone.name = m.group(1)
            # Is this the filename of a zone?
            m = is_zone_file.match(line)
            if this_zone and m:
                this_zone.zonefile = m.group(1)
            # Is the zone definition complete?  If so then check
            if this_zone and this_zone.is_complete():
                this_zone.check_zone()
                this_zone = None
except OSError as e:
    fatal("Error: %s" % e)

# Got this far ... must be good for a reload
do_command(['/usr/sbin/nsd-control', 'reconfig'])
do_command(['/usr/sbin/nsd-control', 'reload'])
