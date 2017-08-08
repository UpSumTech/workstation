#!/usr/bin/env python

######## Imports ###########

import sys
from docopt import docopt
import os
import re
import json
from fabric.api import local
import urllib2
from tempfile import NamedTemporaryFile
from ansible.parsing.dataloader import DataLoader
from ansible.vars import VariableManager
from ansible.inventory import Inventory
from ansible.executor import playbook_executor

######### Wrapper OS Classes ##################
class MacOS:
    def __init__(self):
        self.name = 'Darwin'

class Linux:
    def __init__(self):
        self.name = 'Linux'

class Ec2Linux:
    def __init__(self, hostname):
        self.name = 'Ec2Linux'
        self.hostname = hostname

######### Utility functions ##################

def die(msg):
    sys.stderr.write("Error : %s\n" % msg)
    sys.exit(1)

os_type_regex = re.compile('^(Darwin|Linux)$')
def get_host_type():
    os_type = local('uname -s', capture=True)
    assert os_type_regex.match(os_type)
    if os_type == 'Darwin':
        os_object = MacOS()
    else:
        try:
            ec2_machine_hostname = urllib2.urlopen('http://169.254.169.254/latest/meta-data/hostname').read()
            os_object = Ec2Linux(ec2_machine_hostname)
        except (urllib2.URLError):
            os_object = Linux()
    return os_object

######### Error classes ######################

class BadArgument(Exception):
    pass

############# Classes required for ansible playbook ###############

class Options(object):
    """
    Options class to replace Ansible OptParser
    """
    def __init__(self, verbosity=None, inventory=None, listhosts=None, subset=None, module_paths=None, extra_vars=None,
                 forks=None, ask_vault_pass=None, vault_password_files=None, new_vault_password_file=None,
                 output_file=None, tags=None, skip_tags=None, one_line=None, tree=None, ask_sudo_pass=None, ask_su_pass=None,
                 sudo=None, sudo_user=None, become=None, become_method=None, become_user=None, become_ask_pass=None,
                 ask_pass=None, private_key_file=None, remote_user=None, connection=None, timeout=None, ssh_common_args=None,
                 sftp_extra_args=None, scp_extra_args=None, ssh_extra_args=None, poll_interval=None, seconds=None, check=None,
                 syntax=None, diff=None, force_handlers=None, flush_cache=None, listtasks=None, listtags=None, module_path=None):
        self.verbosity = verbosity
        self.inventory = inventory
        self.listhosts = listhosts
        self.subset = subset
        self.module_paths = module_paths
        self.extra_vars = extra_vars
        self.forks = forks
        self.ask_vault_pass = ask_vault_pass
        self.vault_password_files = vault_password_files
        self.new_vault_password_file = new_vault_password_file
        self.output_file = output_file
        self.tags = tags
        self.skip_tags = skip_tags
        self.one_line = one_line
        self.tree = tree
        self.ask_sudo_pass = ask_sudo_pass
        self.ask_su_pass = ask_su_pass
        self.sudo = sudo
        self.sudo_user = sudo_user
        self.become = become
        self.become_method = become_method
        self.become_user = become_user
        self.become_ask_pass = become_ask_pass
        self.ask_pass = ask_pass
        self.private_key_file = private_key_file
        self.remote_user = remote_user
        self.connection = connection
        self.timeout = timeout
        self.ssh_common_args = ssh_common_args
        self.sftp_extra_args = sftp_extra_args
        self.scp_extra_args = scp_extra_args
        self.ssh_extra_args = ssh_extra_args
        self.poll_interval = poll_interval
        self.seconds = seconds
        self.check = check
        self.syntax = syntax
        self.diff = diff
        self.force_handlers = force_handlers
        self.flush_cache = flush_cache
        self.listtasks = listtasks
        self.listtags = listtags
        self.module_path = module_path

######### Internal function ###########

def _run_playbook(provision_type, host, playbook_file, extra_vars={}, dry_run=True):
    """Runs the ansible playbook
    Instead of running ansible as a executable, run ansible through it's API
    """

    #  Initialize objects required for the playbook execution
    variable_manager = VariableManager()
    variable_manager.extra_vars = extra_vars
    loader = DataLoader()
    options = Options()

    #  import pdb; pdb.set_trace()
    if provision_type == 'developer':
        playbook = os.path.join(os.getcwd(), playbook_file)
        options.become_user = 'developer'
    else:
        raise BadArgument('The playbook type provided is not valid')

    passwords = {'become_pass': None}
    options.check=dry_run
    options.connection = 'ssh'
    options.become = True
    options.verbosity = True
    options.become_method = 'sudo'

    hosts = NamedTemporaryFile(delete=False)
    hosts.write("""[workstation]
    %s
    """ % host)
    hosts.close()

    inventory = Inventory(loader=loader, variable_manager=variable_manager, host_list=hosts.name)
    variable_manager.set_inventory(inventory)

    #  Run the playbook
    pbex = playbook_executor.PlaybookExecutor(
        playbooks=[playbook],
        inventory=inventory,
        variable_manager=variable_manager,
        loader=loader,
        options=options,
        passwords=passwords)
    pbex.run()

######### Public API documentation ###########

__doc__="""Configures a workstation on a virtual machine or localhost
Usage:
    provision.py developer --host=<host> --playbook=<playbook> [--ignore-dry-run]
    provision.py (-h | --help)

Options:
    -h --help                                        You are looking at this option right now.
    --playbook=<playbook>                                    The ip address of the host or 'localhost' to run the playbook on. If not specified this will be the localhost.
    --host=<host>                                    The ip address of the host or 'localhost' to run the playbook on. If not specified this will be the localhost.
    --ignore-dry-run                                 This option will ignore the dry run and execute the playbooks
"""

######### Public API ###########

def main(args=None):
    """Entrypoint
    This is the main entrypoint of the program
    The public API for running this file is defined above with docopts
    The playbook executes as a dry run by default.
    """
    dry_run = False if args['--ignore-dry-run'] else True

    extra_vars = dict(
        playbook_type=os.environ.get('PLAYBOOK_TYPE'),
        ansible_python_interpreter="/usr/bin/env python"
        )

    host_type = get_host_type()
    if isinstance(host_type, MacOS):
        if not 'workstation' in os.environ.get('VIRTUAL_ENV',''):
            die("Load the virtualenv by cd ing out and back into the root of the workstation")
        if not os.environ.get('AWS_ACCESS_KEY_ID'):
            die("You need to set a aws access key id for aws cli and credstash to use")
        if not os.environ.get('AWS_SECRET_ACCESS_KEY'):
            die("You need to set a aws secret access key for aws cli and credstash to use")
        aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID'),
        aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY'),
    elif isinstance(host_type, Linux):
        if not 'workstation' in os.environ.get('VIRTUAL_ENV',''):
            die("Load the virtualenv by cd ing out and back into the root of the workstation")
        if not os.environ.get('AWS_ACCESS_KEY_ID'):
            die("You need to set a aws access key id for aws cli and credstash to use")
        if not os.environ.get('AWS_SECRET_ACCESS_KEY'):
            die("You need to set a aws secret access key for aws cli and credstash to use")
        extra_vars['aws_access_key_id'] = os.environ.get('AWS_ACCESS_KEY_ID'),
        extra_vars['aws_secret_access_key'] = os.environ.get('AWS_SECRET_ACCESS_KEY'),
    elif isinstance(host_type, Ec2Linux):
        print('No aws cli config needed Ec2 Linux machines. The machines should be launched with the correct role.')
    else:
        die('Not ready to handle this type of OS right now')

    if args['developer']:
        _run_playbook('developer', args['--host'], args['--playbook'], extra_vars=extra_vars, dry_run=dry_run)
    else:
        raise BadArgument('You need to provide a valid provision type. It can only be of type developer.')

######### Entrypoint ###########

## call main
if __name__ == '__main__':
    args = docopt(__doc__, argv=sys.argv[1:])
    main(args)
