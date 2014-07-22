#!/usr/bin/env python

import os
import re
import subprocess

module_path = ''
module_name = 'TSatPy'

def get_init_contents(init):
    """ Read the contents of the __init__ file"""
    with open(init) as f:
        return f.read()

def get_version(contents):
    """ Pull the current version """
    p = subprocess.Popen(['git', 'describe', '--tags', '--abbrev=0'],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    contents, err = [str.strip(i) for i in p.communicate()]
    print("current tag: %s" % contents)
    if err:
        print(err)
        exit()

    return [int(i) for i in contents.split('.')]

def verify_branch():
    """ Make sure we're on the master branch """
    p = subprocess.Popen(['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    branch, err = map(str.strip, p.communicate())

    if err:
        print(err)
        exit()
    if not branch == 'master':
        print('Action not allowed on branch: %s' % branch)
        exit()

def calc_next_ver(ver):
    """ Determine the next version number """
    p = subprocess.Popen([
        'git', 'log',
        '%s..HEAD' % '.'.join([str(i) for i in ver]), '--oneline'],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    log, err = [str.strip(i) for i in p.communicate()]

    if not log:
        print("No commits since last tag")
        exit()

    if '#major' in log:
        bump_type = 'major'
        ver[0] += 1
        ver[1] = 0
        ver[2] = 0
    elif '#minor' in log:
        bump_type = 'minor'
        ver[1] += 1
        ver[2] = 0
    else:
        bump_type = 'patch'
        ver[2] += 1
    return ver, bump_type

def git_commit_bump(init, contents, new_ver, bump_type):
    """ Bumping tag """
    bumped = '.'.join([str(i) for i in new_ver])

    new_contents = re.sub(
        r"__version__\s*=\s*['\"][\d.]+['\"]",
        "__version__ = '%s'" % bumped,
        contents)

    with open(init, 'w') as f:
        f.write(new_contents)

    p = subprocess.Popen([
        'git', 'commit',
        '-m', 'bump version: %s' % bump_type, init],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    p.communicate()

    p = subprocess.Popen([
        'git', 'tag',
        '-a', bumped,
        '-m', 'version bump (' + bump_type + ')'],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    p.communicate()

    print("Bumped: %s (%s)" % (bumped, bump_type))

if __name__ == '__main__':
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), '../'))
    init = os.path.join(root, module_path, '%s/__init__.py' % module_name)

    init_contents = get_init_contents(init)
    ver = get_version(init_contents)
    verify_branch()
    new_ver, bump_type = calc_next_ver(ver)
    git_commit_bump(init, init_contents, new_ver, bump_type)
