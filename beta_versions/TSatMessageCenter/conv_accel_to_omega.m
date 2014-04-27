function [accel_x, accel_y, accel_z] = conv_accel_to_omega(accel_voltages)

%constants
conv=evalin('base','conv');
baseline=evalin('base','baseline');
accel_gain = conv.sensor_to_rpm.accel;
accel_baseline = baseline.accel;

%Normalized values
for n = 1:4
    accel_rpm(n) = accel_gain(n)*(accel_voltages(n)-accel_baseline(n));
end

%Note
%reading 1 is sensor 1Y
%reading 2 is sensor 1X
%reading 3 is sensor 2Y
%reading 4 is sensor 2X

%Determine here which way sensors are facing
%Assumed readings 1 and 3 detect rotation about the major z axis
accel_z = (accel_rpm(2) - accel_rpm(4))/2;
%Assumed reading 2 detect rotation about the x axis
accel_x = accel_rpm(1);
%Assumed reading 4 detect rotation about the x axis
accel_y = accel_rpm(2);
