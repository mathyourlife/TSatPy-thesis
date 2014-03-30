#!/usr/bin/env python

import os
import sys
import glob
import fnmatch


def TSatPyTeX():
    tsat_dir = os.path.realpath(os.path.join(os.path.dirname(__file__), '../TSatPy'))
    src_tex = os.path.join(os.path.dirname(__file__), 'sections/TSatPySource.tex')

    header = """
\chapter{TSatPy Source Code}
\label{chap:tsatpy_source}

\linespread{1}
"""

    with open(src_tex, 'w') as tex:
        tex.write(header)

        for f in sorted(glob.glob('%s/*.py' % tsat_dir)):
            fn = f[len(tsat_dir)+1:]
            tex.write('\n')
            tex.write('\pagebreak\n')
            tex.write('\section{TSatPy/%s}\label{code:TSatPy/%s}' % (fn.replace('_', '\_'), fn))
            tex.write('\inputminted[linenos,fontsize=\scriptsize]{python}{%s}\n' % f)

        for f in sorted(glob.glob('%s/tests/*.py' % tsat_dir)):
            fn = f[len(tsat_dir)+1:]
            tex.write('\n')
            tex.write('\pagebreak\n')
            tex.write('\section{TSatPy/%s}\label{code:TSatPy/%s}\n' % (fn.replace('_', '\_'), fn))
            tex.write('\inputminted[linenos,fontsize=\scriptsize]{python}{%s}\n' % f)

def MatlabOOTeX():
    code_dir = os.path.realpath(os.path.join(os.path.dirname(__file__), '../beta_versions/matlab_object_oriented'))
    src_tex = os.path.join(os.path.dirname(__file__), 'sections/MatlabOOSource.tex')

    header = """
\chapter{Matlab Object Oriented Source Code}
\label{ch:MatlabObjectOrientedSourceCode}

\linespread{1}
"""

    with open(src_tex, 'w') as tex:
        tex.write(header)

        for f in sorted([os.path.join(dirpath, fname)
            for dirpath, dirnames, files in os.walk(code_dir)
            for fname in fnmatch.filter(files, '*.m')]):

            fn = f[len(code_dir)+1:]
            tex.write('\n')
            tex.write('\pagebreak\n')
            tex.write('\section{MatlabOO/%s}\label{code:MatlabOO/%s}\n' % (fn.replace('_', '\_'), fn))
            tex.write('\inputminted[linenos,fontsize=\scriptsize]{matlab}{%s}\n' % f)

            # tex.write('\section{MatlabOO/%s}\label{code:MatlabOO/%s}\n' % (fn.replace('_', '\_'), fn))
            # tex.write('\lstinputlisting{%s}\n' % f)


if __name__ == "__main__":
    TSatPyTeX()
    MatlabOOTeX()
