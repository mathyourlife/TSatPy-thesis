#!/usr/bin/env python
# This file is managed by Chef any changes made will be overwritten
from __future__ import print_function

import os
import re
import sys

ROOT_DIR = os.path.dirname(os.path.realpath(__file__))
README_FILE = os.path.join(ROOT_DIR, '../README.md')

START_TAG = '<!--- start_TOC -->'
END_TAG = '<!--- end_TOC -->'


def usage():
    args = {
        'f': __file__,
        'start_tag': START_TAG,
        'end_tag': END_TAG,
    }
    print('Create a table of contents into a github markdown file (README.md)\n' \
        'The TOC will be created between start and end tags\n\n' \
        'start tag: {start_tag}\n'
        'end tag: {end_tag}\n\n'
        'usage: {f} [README.md]'.format(**args))
    exit(1)


def make_toc(readme, start_pos, end_pos):
    regex = re.compile('(?P<level>^#+)\s(?P<item>.+)$', re.MULTILINE)
    r = regex.search(readme)

    new_readme = readme[:start_pos]
    new_readme += START_TAG + '\n\n'

    def make_link(title):
        link = title.lower().replace(' ', '-')
        link = re.sub(r'[^a-z1-9\-]', '', link)
        return '[%s](#%s)' % (title, link)

    for m in regex.findall(readme):
        line = '%s* %s\n' % (
            '\t' * (len(m[0]) - 1),
            make_link(m[1])
        )
        new_readme += line

    new_readme += '\n' + readme[end_pos:]

    return new_readme


def main():
    try:
        sys.argv[1]
    except IndexError:
        usage()

    readme_file = os.path.realpath(os.path.join(os.getcwd(), sys.argv[1]))
    with open(readme_file) as f:
        readme = f.read()

    start_pos = readme.find(START_TAG)
    end_pos = readme.find(END_TAG)

    if end_pos <= start_pos:
        usage()

    new_readme = make_toc(readme, start_pos, end_pos)

    with open(readme_file, 'w') as f:
        f.write(new_readme)
    return 0

if __name__ == '__main__':
    exit(main())
