function r = Buffer2Sensor(args)
	if (nargin == 0); args = struct; end

	global tsat

	%Use the system time to simulate the 3rpm rotation
	
	%3rpm = 3*2*pi/60 sec
	
	radPerSec = 3*2*pi/60;
	
	theta = rem(now,1)*24*3600*radPerSec;
	
	v=[cos(theta) sin(theta)];	
	
	amp = 6;
	noise = tsat.sensors.css.noise;
	css_v(1) = amp * max(0,dot(v,[cos(deg2rad(  0)) sin(deg2rad(  0))]));
	css_v(2) = amp * max(0,dot(v,[cos(deg2rad( 60)) sin(deg2rad( 60))]));
	css_v(3) = amp * max(0,dot(v,[cos(deg2rad(120)) sin(deg2rad(120))]));
	css_v(4) = amp * max(0,dot(v,[cos(deg2rad(180)) sin(deg2rad(180))]));
	css_v(5) = amp * max(0,dot(v,[cos(deg2rad(240)) sin(deg2rad(240))]));
	css_v(6) = amp * max(0,dot(v,[cos(deg2rad(300)) sin(deg2rad(300))]));

	css_v = css_v + (noise * randn(1,6));
	css_v = max(css_v, zeros(1,6));
	css_v = min(css_v, 6*ones(1,6));
	
	args = struct; args.volts = [css_v 7 8 9 10 11 12 13 14];
	tsat.sensors=tsat.sensors.updateSensorVoltages(args);
	
end