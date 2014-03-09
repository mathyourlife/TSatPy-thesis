#include "mex.h"


/*
 * timestwoalt.c - example found in API guide
 *
 * use mxGetScalar to return the values of scalars instead of pointers
 * to copies of scalar variables.
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2000 The MathWorks, Inc.
 */
 
/* $Revision: 1.6 $ */

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  //double *y;
  //time_t seconds;
  //seconds = time (NULL);
  //printf ("%ld hours since January 1, 1970", seconds/3600);

//	real_T *y;
    SYSTEMTIME st;
	GetSystemTime(&st);
	
	printf("%g", st.wYear);
  /* create a 1-by-1 matrix for the return argument */
  plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
  //y = mxGetPr(plhs[0]);
    //y[0]=st.wYear*1.0;
    //y[1]=st.wMonth*1.0;
    //y[2]=st.wDay*1.0;
    
    //y[3]=(st.wDayOfWeek%7)*1.0;
    //y[4]=st.wHour*1.0;
    //y[5]=st.wMinute*1.0;
    //y[6]=st.wSecond*1.0;
    //y[7]=st.wMilliseconds*1.0;

  /* Check arguments */
    
  if (nrhs != 1) { 
    mexErrMsgTxt("One input argument required."); 
  } else if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments."); 
  } else if (!mxIsNumeric(prhs[0])) {
    mexErrMsgTxt("Argument must be numeric.");
  } else if (mxGetNumberOfElements(prhs[0]) != 1 || mxIsComplex(prhs[0])) {
    mexErrMsgTxt("Argument must be non-complex scalar.");
  }

  /* assign a pointer to the output */
  //y = mxGetPr(plhs[0]);

  //*y = tmb.time + tmb.millitm;
}

