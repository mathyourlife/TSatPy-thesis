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

	const char **fnames;       /* pointers to field names */
	int        ifield, nfields, val, i;
	mxArray    *tmp, *fout;

	/* Check for proper number of arguments. */
	if (nrhs != 1) { 
		mexErrMsgTxt("One input argument required."); 
	}
	
	nfields = mxGetNumberOfFields(prhs[0]);
	fnames = mxCalloc(nfields, sizeof(*fnames));
	for (ifield=0; ifield< nfields; ifield++){
		fnames[ifield] = mxGetFieldNameByNumber(prhs[0],ifield);
		mexPrintf("%s\n", fnames[ifield]);
		ptr = mxGetPr(mxGetField(prhs[0], 0, fnames[ifield]));  
		printf("%f\n", *ptr);
		ptr[0]++;
		printf("%f\n", *ptr);
	}
	
}
