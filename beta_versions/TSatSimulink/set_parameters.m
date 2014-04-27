function set_parameters()
%SETPARAMETERS Setup the system characteristics and run parameters
%   System characteristics, initial conditions, input parameters
%   and output characteristics are set here.

clear all

%System Characteristics
m_total = 4;     % kg
r_avg = 0.2;    % m
Izz = m_total*r_avg^2/2;   % kg m^2
damping_coeff = .04;    % kg m^2 / sec
solid.A = [0 1; 0 -damping_coeff/Izz];
solid.B = [0 0; 0 1/Izz];
linearized.A = [0 1 0; 0 0 8.784e-4; 0 0 -2];
linearized.B = [0 0; 0 0; 0 3242];

%Initial Conditions
solid.ic = [0; 0];
linearized.ic = [0; 0; 0];

%Input Parameters
fan_thrust = 0.025;      % N (Estimated from 24 cfm on 80 mm diameter fan)
fan_radius = 0.15;   % m 
input.torque = (fan_thrust * fan_radius)*2;  % Nm  torque caused by 2 coupled fans


%Output Characteristics
solid.C = [1 0; 0 1];  %Output position and velocity
solid.D = [0 0; 0 0];
linearized.C = eye(3);
linearized.D = [0 0; 0 0; 0 0];

%Specify default set points
set_point.theta = 0;
set_point.omega = 0;
desired_states = [set_point.theta; set_point.omega];

%Set simulation flags
flag.controller = 0;
flag.measurement_noise = 0;
flag.process_noise = 0;

%Set Default PID Gains
PID.Kp = '[10 0; 0 10]';
PID.Ki = '[5 0; 0 5]';
PID.Kd = '[2 0; 0 2]';

% Set default process noise parameters
process_noise.random.mean = 5;
process_noise.random.variance = 6;
process_noise.uniform.min = -7;
process_noise.uniform.max = 8;

% Set default measurement noise parameters
measurement_noise.random.mean = 1;
measurement_noise.random.variance = 2;
measurement_noise.uniform.min = -3;
measurement_noise.uniform.max = 4;

% Assign all necessary variable to the base workspace
assignin('base','solid',solid);
assignin('base','linearized',linearized);
assignin('base','input',input);
assignin('base','flag',flag);
assignin('base','set_point',set_point);
assignin('base','desired_states',desired_states);
assignin('base','PID',PID);
assignin('base','process_noise',process_noise);
assignin('base','measurement_noise',measurement_noise);
