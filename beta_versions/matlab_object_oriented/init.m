

addpath(pwd)
addpath([pwd '\lib'])
display('Including utility directory');
addpath([pwd '\utils'])
display('Including mex directory');
addpath([pwd '\mex'])
display('Including timerFunctions directory');
addpath([pwd '\timerFunctions'])
display('Clearing memory, deleting timers and closing graphs')
close all
clear all
clear java
clear classes
clear functions
delete(timerfind)
display('Use the "pack" command to run java garbage collection')
display('Initializing TableSat Instance')
global t;
t = time();
global config;
config.debug = false;
global tsat;
global graphs;
graphs = struct;
graphs.fig_id = 0;
tsat = tsat_obj();
args = struct; args.action = 'init';
timerManager(args);
global calibration_data
load('logs/mag_calibration_volts.mat')
%cmd calibration pull data