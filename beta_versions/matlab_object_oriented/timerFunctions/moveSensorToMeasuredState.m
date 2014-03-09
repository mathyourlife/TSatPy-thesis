function r = moveSensorToMeasuredState(args)
	if (nargin == 0); args = struct; end
	
	global tsat
	
	args = struct;
	args.volts = rand(1,14);
	tsat.sensors=tsat.sensors.updateSensorVoltages(args);

end