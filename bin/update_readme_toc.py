#!/usr/bin/env python

import os
import re

ROOT_DIR = os.path.dirname(os.path.realpath(__file__))
README_FILE = os.path.join(ROOT_DIR, '../README.md')

start_tag = '<!--- start_TOC -->'
end_tag = '<!--- end_TOC -->'

with open(README_FILE) as f:
    readme = f.read()

start_pos = readme.find(start_tag)
end_pos = readme.find(end_tag)

def make_toc(readme, start_pos, end_pos):

    regex = re.compile('(?P<level>^#+)\s(?P<item>.+)$', re.MULTILINE)
    r = regex.search(readme)

    new_readme = readme[:start_pos]
    new_readme += start_tag + '\n\n'

    def make_link(title):
        link = title.lower().replace(' ', '-')
        link = re.sub(r'[^a-z\-]', '', link)
        return '[%s](#%s)' % (title, link)

    for m in regex.findall(readme):
        line = '%s* %s\n' % (
            '\t' * (len(m[0]) - 1),
            make_link(m[1])
        )
        new_readme += line

    new_readme += '\n' + readme[end_pos:]

    return new_readme

new_readme = make_toc(readme, start_pos, end_pos)

with open(README_FILE, 'w') as f:
    f.write(new_readme)