
I = eye(3);

p_meas = tPlot;
item = struct;
item.name = 'q0';
item.type = 'plot';
item.style = 'b-';
data = struct; data.x = 0; data.y = 0;
item.data = data;
p_meas=p_meas.addSeries(item);
for i = 1:3
	item = struct;
	item.name = sprintf('q%d',i);
	item.type = 'plot';
	item.style = 'g-';
	data = struct; data.x = 0; data.y = 0;
	item.data = data;
	p_meas=p_meas.addSeries(item);
end

h=hist();

for i=1:1000
	pause(0.1)
	Buffer2Sensor;
	
	args = struct;
	args.var = 'q';
	args.value = tsat.sensors.state.q;
	h = h.log(args);
	
	
	item = struct;
	item.name = 'q0';
	item.type = 'plot';
	data = struct; data.x = h.values.q(:,1); data.y = h.values.q(:,5);
	item.data = data;
	p_meas=p_meas.updateSeries(item);
	for i = 1:3
		item = struct;
		item.name = sprintf('q%d',i);
		item.type = 'plot';
		data = struct; data.x = h.values.q(:,1); data.y = h.values.q(:,i+1);
		item.data = data;
		p_meas=p_meas.updateSeries(item);
	end

	% A quaternion based adaptive attitude tracking crontroller without velocity measurements
	% Estimator
	% J * wdot = -tsat.sensors.state.w.wx*J*tsat.sensors.state.w.w
	qvdot = 0.5 * (tsat.sensors.state.q.x*tsat.sensors.state.w.w + tsat.sensors.state.q.scalar*tsat.sensors.state.w.w);
	psdot = -0.5*tsat.sensors.state.q.vector'*tsat.sensors.state.w.w;
	
	
end
