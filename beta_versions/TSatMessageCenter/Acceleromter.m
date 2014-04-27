function [accel_x, accel_y, accel_z] = conv_accel_to_omega(accel_voltages)


%





%% Accelerometer Voltage conversion to Theta
double output_voltage_x;
double output_voltage_y;

%constants
resting_x = 2.48;
resting_y = 2.49;
max_volt = 3.206;

%% Equations

%Sensitivity
converstion_x = max_volt - resting_x;
converstion_y = max_volt - resting_y;

%Theta
theta_x = (output_voltage_x - resting_x)/(conversion_x);
theta_y = (output_voltage_y - resting_y)/(conversion_y);

%% Radians

%Radian
rad_x = arcsin(theta_x);
rad_y = arcsin(theta_y);