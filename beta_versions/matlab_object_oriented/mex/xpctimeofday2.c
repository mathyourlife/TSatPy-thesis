/* $Revision: 1.3 $ $Date: 2002/03/25 03:57:47 $ */
/* xpctimeinfo.c - xPC Target, non-inlined S-function driver for xPC kernel timing information */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	xpctimeofday2

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef 	MATLAB_MEX_FILE
#include 	<windows.h>
#include 	"time_xpcimport.h"
#endif



/* Input Arguments */
#define NUMBER_OF_ARGS          (0)



#define NO_I_WORKS              (0)

#define NO_R_WORKS              (0)


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

	int i;

#ifndef MATLAB_MEX_FILE
#include "time_xpcimport.c"
#endif

   	ssSetNumSFcnParams(S, 0);
	if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		return; /* Parameter mismatch will be reported by Simulink */
	}
  ssSetNumContStates(S, 0);
  ssSetNumDiscStates(S, 0);
  ssSetNumOutputPorts(S, 1);
  ssSetOutputPortWidth(S, 0, 8);
  ssSetNumInputPorts(S, 0);
        
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{
   
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
	ssSetOffsetTime(S, 0, 0.0);
	ssSetModelReferenceSampleTimeDefaultInheritance(S);
}
 

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	real_T *y;
    SYSTEMTIME st;
	GetSystemTime(&st);
	
    y=ssGetOutputPortSignal(S,0);
    y[0]=st.wYear*1.0;
    y[1]=st.wMonth*1.0;
    y[2]=st.wDay*1.0;
    
    y[3]=(st.wDayOfWeek%7)*1.0;
    y[4]=st.wHour*1.0;
    y[5]=st.wMinute*1.0;
    y[6]=st.wSecond*1.0;
    y[7]=st.wMilliseconds*1.0;
  
    
    


	

#endif
        
}

static void mdlTerminate(SimStruct *S)
{   
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


