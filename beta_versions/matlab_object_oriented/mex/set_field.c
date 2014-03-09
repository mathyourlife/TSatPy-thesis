#include "mex.h"
#include "string.h"
#include "matrix.h"

/*
 * timestwo.c - example found in API guide
 *
 * Computational function that takes a scalar and double it.
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2006 The MathWorks, Inc.
 */
 
/* $Revision: 1.8.6.2 $ */

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
	double *ptr;
	char *fname;
	
	/* Check for proper number of arguments. */
	if (nrhs != 3) { 
		mexErrMsgTxt("One input argument required."); 
	}
	
	fname = mxArrayToString(prhs[1]);
	ptr = mxGetPr(mxGetField(prhs[0], 0, fname));
	ptr[0] = mxGetPr(prhs[2])[0];
}
