function gyro_rpm = conv_gyro_to_omega(gyro_voltage)

%constants
conv=evalin('base','conv');
baseline=evalin('base','baseline');
gyro_gain = conv.sensor_to_rpm.gyro;
gyro_baseline = baseline.gyro;

%Calculate RPM based on baseline constants
gyro_rpm = gyro_gain*(gyro_voltage-gyro_baseline);
