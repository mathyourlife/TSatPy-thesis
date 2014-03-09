#include "mex.h"
#include <stdio.h>
#include <time.h>

/*
 * epoch.c
 *
 * Return of time since January 1, 1970
 *
 * This is a MEX-file for MATLAB.
 */
 
/* $Revision: 0.0.1 $ */

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *x;
  double *ptr;

    const char **fnames;       /* pointers to field names */
  int        ifield, nfields, val, i;
    mxArray    *tmp, *fout;

  /* Check for proper number of arguments. */
  if (nrhs != 2) { 
    mexErrMsgTxt("One input argument required."); 
  } else if (!mxIsNumeric(prhs[0])) {
    mexErrMsgTxt("Argument must be numeric.");
  } else if (mxGetNumberOfElements(prhs[0]) != 1 || mxIsComplex(prhs[0])) {
    mexErrMsgTxt("Argument must be non-complex scalar.");
  }

  nfields = mxGetNumberOfFields(prhs[1]);
  fnames = mxCalloc(nfields, sizeof(*fnames));
	for (ifield=0; ifield< nfields; ifield++){
		fnames[ifield] = mxGetFieldNameByNumber(prhs[1],ifield);
		mexPrintf("%s\n", fnames[ifield]);
		ptr = mxGetPr(mxGetField(prhs[1], 0, fnames[ifield]));  
		printf("%f\n", *ptr);
		ptr[0]++;
		printf("%f\n", *ptr);
	}

  /* Create matrix for the return argument. */
  plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
  
  /* Assign pointers to each input and output. */
  x = mxGetPr(prhs[0]);

  /* Call the timestwo subroutine. */
  x[0] *= 5.0;
}
