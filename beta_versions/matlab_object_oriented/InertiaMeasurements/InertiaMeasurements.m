%% Moment of Inertia Calculation

%Mass of Table Sat
M = 4.2; %kg

%Gravity
g = 9.81;   %m/s^2

%Radius for center of Table Sat to string
R = 7.3125*.0245;   %meters

%Length of String
L = 27.37375*.0245;   %meters

%Period
t= 12.81/10;  %s

%Equation
I = (M*g*R^2*t^2)/(4*pi^2*L);

%% Thrust Calculation

%Volumetric Flow Rate
VF = .0202; %m^3/sec

%Density
rho_air = 1.29;   %kg/m^3

%Area of Disk
Area = pi*((3.94/2)*.0245)^2; %m^2

%Equation
Thrust = (rho_air*VF^2)/Area;  %(kg*m)/sec^2 or N


%% Static Friction Fan

f_fan = 2.98;  %Volts

%% Static Friction Table Sat

f_tsat = 7.75;  %Volts
%% Kvw - Voltage to Change in Fan Speed Constant

%Fan Time Constant
alpha = 2;

%Max Fan Speed
v = 15000;

%Max Fan Voltage Applied
Vn = 12; %Volts

%Equation
Kvw = (alpha*v)/(Vn-f_fan);

%% Kwf - Fan Speed to Fan Force Constant

Kwf = Thrust/v;


%% Force of Fan Applied to a Moment Arm (Single Fan)
Arm_1 = 5.3125*.0245;  %m
Arm_2 = 7.0625*.0245;  %m
Arm_3 = 8.8125*.0245;  %m
Arm_4 = 10.5625*.0245; %m
Arm_5 = 12.3125*.0245; %m

%Torque
torque_1 = Thrust * Arm_1; %Nm
torque_2 = Thrust * Arm_2; %Nm
torque_3 = Thrust * Arm_3; %Nm
torque_4 = Thrust * Arm_4; %Nm
torque_5 = Thrust * Arm_5; %Nm

%% 


