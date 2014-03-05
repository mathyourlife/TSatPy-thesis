#!/usr/bin/env python

import sys
import os
import glob

tsat_dir = os.path.realpath(os.path.join(os.path.dirname(__file__), '../TSatPy'))
src_tex = os.path.join(os.path.dirname(__file__), 'sections/TSatPySource.tex')

header = """
\chapter{TSatPy Source Code}\label{ch:tsatpy_source}

\linespread{1}
"""

with open(src_tex, 'w') as tex:
    tex.write(header)

    for f in sorted(glob.glob('%s/*.py' % tsat_dir)):
        fn = f[len(tsat_dir)+1:]
        tex.write('\n')
        tex.write('\section{TSatPy/%s}\label{code:TSatPy/%s}' % (fn.replace('_', '\_'), fn))
        tex.write('\inputminted[linenos,fontsize=\scriptsize]{python}{%s}\n' % f)

    for f in sorted(glob.glob('%s/tests/*.py' % tsat_dir)):
        fn = f[len(tsat_dir)+1:]
        tex.write('\n')
        tex.write('\section{TSatPy/%s}\label{code:TSatPy/%s}' % (fn.replace('_', '\_'), fn))
        tex.write('\inputminted[linenos,fontsize=\scriptsize]{python}{%s}\n' % f)

