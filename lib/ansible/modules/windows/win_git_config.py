#!/usr/bin/python
# -*- coding: utf-8 -*-

# This file is part of Ansible
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'supported_by': 'community',
    'status': ['preview']
}

DOCUMENTATION = '''
---
module: win_git_config
version_added: "0.0"
author: U. Bruhin
short_description: Read and write git configuration
description:
  - The C(win_git_config) module changes git configuration by invoking 
    'git config'. This is needed if you don't want to use M(template) for the
    entire git config file (e.g. because you need to change just C(user.email)).
    Solutions involving M(command) are cumbersone or don't work correctly in
    check mode.
notes:
  - Git for Windows needs to be installed and available in the PATH
options:
  name:
    description:
      - The name of the setting.
    required: true
    default: null
  scope:
    description:
      - Specify which scope to read/set values from. This is required
        when setting config values.
    required: false
    choices: [ "local", "global", "system" ]
    default: null
  value:
    description:
      - The value which will be set for the specified setting.
    required: true
    default: null
'''

EXAMPLES = '''
# Set some settings in ~/.gitconfig
- win_git_config:
    name: core.autocrlf
    scope: global
    value: false
- win_git_config:
    name: alias.st
    scope: global
    value: status
# Or system-wide:
- win_git_config:
    name: core.longpaths
    scope: system
    value: true
- git_config:
    name: core.editor
    scope: global
    value: vim
'''

RETURN = '''
---
'''

