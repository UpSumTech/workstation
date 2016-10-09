#!/usr/bin/env python2.7
import os
import os.path
import socket
from fabric.api import local
import sys
import pprint
import json
import re
from datetime import datetime
import uuid
import time
import urllib2
import collections
import traceback
import logging
import base64
from distutils.version import StrictVersion
import dateutil.parser
import yaml
import schema
from random import randint
import csv

__doc__="""Get OS Info
Usage:
  get_os_info.py
  get_os_info.py network -i <interface> -p <port>
  get_os_info.py -h

Options:
  -h    You are looking at this option.
  -i    The interface you are trying to get information on.
  -p    The port you are trying to scan.
"""
from docopt import docopt

def die(msg):
    sys.stderr.write("Error : %s\n" % msg)
    sys.exit(1)

## sanity check for correct virtualenv
if not 'workstation' in os.environ.get('VIRTUAL_ENV',''):
    die("Load the virtualenv by cd ing out and back into the root of the workstation")

os_type_regex = re.compile('^(Darwin|Linux)$')

def get_host_type():
    os_type = local('uname -s', capture=True)
    assert os_type_regex.match(os_type)
    return os_type

def get_timestamp():
    return datetime.utcnow().isoformat()

def fetch_network_details():
    return None

def main(args=None):
    os_type = get_host_type()
    timestamp=get_timestamp()
    ret_val = dict(os_type=os_type,
        timestamp=timestamp)

    if args['network']:
        fetch_network_details()

    print(ret_val)

if __name__ == '__main__':
    args = docopt(__doc__, argv=sys.argv[1:])
    main(args)
