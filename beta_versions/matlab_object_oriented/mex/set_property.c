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
	double *ptr2;
	char *fname;
	double handle;
	const mxArray *color_array_ptr;
	mxArray *value;
	double *color, *color_org;
	
	/* Check for proper number of arguments. 
	if (nrhs != 3) { 
		mexErrMsgTxt("One input argument required."); 
	}*/
	/* Get the handle */
	handle = mxGetScalar(prhs[0]);
	
	printf("%g\n", handle);
	
	color_array_ptr = mexGet(handle, "scalar");
	
	printf("%g\n", color_array_ptr);
	color_org = mxGetPr(color_array_ptr);
	
	color_org[0]=5;
	
	/* Make copy of "Color" propery */
	value = mxDuplicateArray(color_array_ptr);
	printf("%g\n", value);
	/* The returned "Color" property is a 1-by-3 matrix of 
	primary colors. */ 
	color = mxGetPr(value);
	printf("%g\n", color[0]);
	
}
