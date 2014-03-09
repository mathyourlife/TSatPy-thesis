function r = Sensor2Model(args)
	if (nargin == 0); args = struct; end

	global tsat
	
	css_state = tsat.sensors.css.state;
	item = struct;
	item.state = tsat.sensors.css.state;
	item.name = 'tsatSensor';
	item.style = 'ro';
	item.size = 0.1;
	tsat.tsatModel=tsat.tsatModel.update(item);

end