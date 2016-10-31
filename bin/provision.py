#!/usr/bin/env python

######## Imports ###########

import sys
from docopt import docopt
import os
import json
from tempfile import NamedTemporaryFile
from ansible.parsing.dataloader import DataLoader
from ansible.vars import VariableManager
from ansible.inventory import Inventory
from ansible.executor import playbook_executor

######### Utility functions ##################

def die(msg):
    sys.stderr.write("Error : %s\n" % msg)
    sys.exit(1)

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

def _run_playbook(host, extra_vars={}, dry_run=True):
    """Runs the ansible playbook
    Instead of running ansible as a executable, run ansible through it's API
    """

    #  Initialize objects required for the playbook execution
    variable_manager = VariableManager()
    variable_manager.extra_vars = extra_vars
    loader = DataLoader()
    options = Options()
    playbook = os.path.join(os.getcwd(), 'ansible/main.yml')
    passwords = {'become_pass': None}

    options.check=dry_run
    options.connection = 'ssh'
    options.become = True
    options.become_method = 'sudo'
    options.become_user = 'developer'

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
    create.py --host=<host> [--ignore-dry-run]
    create.py (-h | --help)

Options:
    -h --help                                        You are looking at this option right now.
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
        ansible_python_interpreter="/usr/bin/env python")

    if args['--host']:
        extra_vars['homebrew_github_api_token'] = os.environ.get('HOMEBREW_GITHUB_API_TOKEN')
        _run_playbook(
                args['--host'],
                extra_vars=extra_vars,
                dry_run=dry_run)

    else:
        raise BadArgument('You need to provide a host ip for setup.')

######### Entrypoint ###########

## sanity check for correct virtualenv
if not 'workstation' in os.environ.get('VIRTUAL_ENV',''):
    die("Load the virtualenv by cd ing out and back into the root of the workstation")

if not os.environ.get('HOMEBREW_GITHUB_API_TOKEN'):
    die("You need to set a github token for homebrew to use")

## call main
if __name__ == '__main__':
    args = docopt(__doc__, argv=sys.argv[1:])
    main(args)
