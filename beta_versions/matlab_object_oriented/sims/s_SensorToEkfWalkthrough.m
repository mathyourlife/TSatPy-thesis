function r = v_sensor_to_ekf_video()
	
	% Plot 3D representation of satellite motion
	css_visualization(1, 30)
	
	% Plot raw CSS voltages
	plot_css_voltages(20)
	
	% Plot calculated CSS Angle
	plot_css_angle(30)
	
	% Plot 3D representation of satellite with 
	% estimated css angle.
	css_visualization(3, 30)
	
	% Plot 3D representation of satellite with 
	% ekf estimate based on css angle.
	css_visualization(5, 30)
	
	% Plot raw CSS and Magnetometer voltages
	plot_css_mag_voltages(30)
	
	% Visualize what the measured satellite attitude
	% with CSS for spin angle and Magnetometer for
	% nutation.
	plot_ekf_nutation(2,30)
	
	% Juxtapose of true satellite attitude and
	% the mesaured state that is corrupted by noise.
	plot_ekf_nutation(3,60)
	
	% Assess the ability of the ekf to filter out
	% the noise of the measurements and match
	% the true state of the system.
	plot_ekf_nutation(5,240)
	
end

function p = setup_plant()
	args = struct; args.I = eye(3);
	p = plant(args);
	args = struct; args.state = state();
	args.state.q.normalize();
	args.state.w.w = [0.01 -0.02 -0.5]';
	p.set_state(args);
end

function tsat_plot = setup_tsat_plot(graph_name, color)
	args = struct; args.show_thrusters = 0;
	tsat_plot = tsatModel(args);
	plot_args = struct; plot_args.graph = graph_name; plot_args.color = color;
	tsat_plot.setupPlot(plot_args);
	
	plot_args = struct; plot_args.graph = graph_name;
	tsat_plot.addAxesLabels(plot_args);
end

function plot_css_voltages(duration)
	
	global t
	
	graph_name = 'video_sensor_to_ekf';
	args = struct; args.name = graph_name; args.action = 'create';
	fig_id = graphManager(args);
	figure(fig_id)
	
	for css_num = 1:6
		item = struct; item.name = sprintf('css_%d', css_num); item.type = 'plot';
		data = struct; data.x = 0; data.y = 0; item.data = data;
		args = struct; args.action = 'addseries'; args.graph = graph_name; args.item = item;
		graphManager(args);
	end
	
	args = struct; args.action = 'format'; args.graph = graph_name;
	args.item = struct;
	args.item.title = '6 Photo Diode Voltage Readings';
	args.item.xlabel = 'Time (sec)';
	args.item.ylabel = 'Photo Diode Volts';
	graphManager(args);
	
	args = struct; args.action = 'grid'; args.graph = graph_name;
	args.item = struct;
	args.item.all = 'on';
	graphManager(args);
	
	cur_time = t.now();
	start_sim = t.now();
	pause_time = 0.02;
	
	args = struct;
	args.historylen = floor(10 / pause_time);
	h=hist(args);
	
	truth_tsat = truthModel();
	
	p = setup_plant();
	
	while start_sim + duration > t.now()
		pause(pause_time)
		p.propagate();
		
		args = struct; args.state = p.state;
		V = truth_tsat.generate_voltages(args);
		
		args = struct; args.var = 'css'; args.value = V.css';
		h = h.log(args);
		
		for css_num = 1:6
			item = struct; item.name = sprintf('css_%d', css_num); item.type = 'plot';
			data = struct; data.x = h.logs.css(:,1)-cur_time; data.y = h.logs.css(:,css_num + 1); item.data = data;
			args = struct; args.action = 'updateseries'; args.graph = graph_name; args.item = item;
			graphManager(args);
		end
		
	end
	
end

function plot_css_angle(duration)
	
	global t
	
	graph_name = 'video_sensor_to_ekf';
	args = struct; args.name = graph_name; args.action = 'create';
	fig_id = graphManager(args);
	figure(fig_id)
	
	item = struct; item.name = 'css_angle'; item.type = 'plot';
	data = struct; data.x = 0; data.y = 0; item.data = data;
	args = struct; args.action = 'addseries'; args.graph = graph_name; args.item = item;
	graphManager(args);
	
	args = struct; args.action = 'format'; args.graph = graph_name;
	args.item = struct;
	args.item.title = 'CSS Angle Calculation';
	args.item.xlabel = 'Time (sec)';
	args.item.ylabel = 'Angle (Radians)';
	graphManager(args);
	
	args = struct; args.action = 'grid'; args.graph = graph_name;
	args.item = struct;
	args.item.all = 'on';
	graphManager(args);
	
	cur_time = t.now();
	start_sim = t.now();
	pause_time = 0.02;
	
	args = struct;
	args.historylen = floor(10 / pause_time);
	h=hist(args);
	
	truth_tsat = truthModel();
	
	p = setup_plant();
	
	s_array = sensors();
	
	while start_sim + duration > t.now()
		pause(pause_time)
		p.propagate();
		
		args = struct; args.state = p.state;
		V = truth_tsat.generate_voltages(args);
		
		args = struct; args.volts = V;
		s_array.update(args);
		
		args = struct; args.var = 'css_theta'; args.value = s_array.css.theta;
		h = h.log(args);
		
		item = struct; item.name = 'css_angle'; item.type = 'plot';
		data = struct; data.x = h.logs.css_theta(:, 1) - cur_time; data.y = h.logs.css_theta(:, 2); item.data = data;
		args = struct; args.action = 'updateseries'; args.graph = graph_name; args.item = item;
		graphManager(args);
		
	end
	
end

function css_visualization(flags, duration)
	
	global t
	
	graph_name = 'video_sensor_to_ekf_3d';
	args = struct; args.name = graph_name; args.action = 'create';
	fig_id = graphManager(args);
	figure(fig_id)
	
	if bitand(flags, 1)
		plant_plot = setup_tsat_plot(graph_name, 'b');
	end
	
	if bitand(flags, 2)
		meas_plot = setup_tsat_plot(graph_name, 'g');
	end
	
	if bitand(flags, 4)
		ekf_plot = setup_tsat_plot(graph_name, 'r');
	end
	
	cur_time = t.now();
	start_sim = t.now();
	pause_time = 0.05;
	
	p = setup_plant();
	
	if bitand(flags, 6)
		truth_tsat = truthModel();
		s_array = sensors();
	end
	
	if bitand(flags, 4)
		args = struct;
		args.Q_k = zeros(7);
		args.Q_k(1:3, 1:3) = eye(3) * 0.0001;
		args.Q_k(4, 4) = 1 * 0.0001;
		args.Q_k(5:7, 5:7) = eye(3) * 0.005;
		args.R_k = zeros(7);
		args.R_k(1:3, 1:3) = eye(3) * 0.002;
		args.R_k(4, 4) = 1 * 0.002;
		args.R_k(5:7, 5:7) = eye(3) * 0.1;
		args.I = p.vel.I;
		
		ekf_est = ekf(args);
	end
	
	while start_sim + duration > t.now()
		pause(pause_time)
		p.propagate();
		
		if bitand(flags, 6)
			args = struct; args.state = p.state;
			V = truth_tsat.generate_voltages(args);
			
			V.accel = NaN;
			V.gyro = NaN;
			V.mag = NaN;
			
			args = struct; args.volts = V;
			s_array.update(args);
		end
		
		if bitand(flags, 4)
			args = struct; args.state = s_array.state;
			ekf_est.update(args);
		end
		
		if bitand(flags, 1)
			plot_args = struct; plot_args.graph = graph_name; plot_args.state = p.state;
			plant_plot.updatePlot(plot_args);
		end
		
		if bitand(flags, 2)
			plot_args = struct; plot_args.graph = graph_name; plot_args.state = s_array.state;
			meas_plot.updatePlot(plot_args);
		end
		
		if bitand(flags, 4)
			plot_args = struct; plot_args.graph = graph_name; plot_args.state = ekf_est.state;
			ekf_plot.updatePlot(plot_args);
		end
		
	end
	
end

function plot_css_mag_voltages(duration)
	global t
	
	graph_name = 'video_sensor_to_ekf';
	args = struct; args.name = graph_name; args.action = 'create';
	fig_id = graphManager(args);
	figure(fig_id)
	
	for css_num = 1:6
		item = struct; item.name = sprintf('css_%d', css_num); item.type = 'plot';
		data = struct; data.x = 0; data.y = 0; item.data = data;
		args = struct; args.action = 'addseries'; args.graph = graph_name; args.item = item;
		graphManager(args);
	end
	
	for css_num = 1:3
		item = struct; item.name = sprintf('mag_%d', css_num); item.type = 'plot';
		data = struct; data.x = 0; data.y = 0; item.data = data;
		args = struct; args.action = 'addseries'; args.graph = graph_name; args.item = item;
		graphManager(args);
	end
	
	args = struct; args.action = 'format'; args.graph = graph_name;
	args.item = struct;
	args.item.title = '6 Photo Diode, 3 Magnetometer Voltage Readings';
	args.item.xlabel = 'Time (sec)';
	args.item.ylabel = 'Volts';
	graphManager(args);
	
	args = struct; args.action = 'grid'; args.graph = graph_name;
	args.item = struct;
	args.item.all = 'on';
	graphManager(args);
	
	cur_time = t.now();
	start_sim = t.now();
	pause_time = 0.02;
	
	args = struct;
	args.historylen = floor(10 / pause_time);
	h=hist(args);
	
	p = setup_plant();
	
	truth_tsat = truthModel();
	
	while start_sim + duration > t.now()
		pause(pause_time)
		p.propagate();
		
		args = struct; args.state = p.state;
		V = truth_tsat.generate_voltages(args);
		
		args = struct; args.var = 'css'; args.value = V.css';
		h = h.log(args);
		args = struct; args.var = 'mag'; args.value = V.mag';
		h = h.log(args);
		
		for css_num = 1:6
			item = struct; item.name = sprintf('css_%d', css_num); item.type = 'plot';
			data = struct; data.x = h.logs.css(:,1)-cur_time; data.y = h.logs.css(:,css_num + 1); item.data = data;
			args = struct; args.action = 'updateseries'; args.graph = graph_name; args.item = item;
			graphManager(args);
		end
		
		for mag_num = 1:3
			item = struct; item.name = sprintf('mag_%d', mag_num); item.type = 'plot';
			data = struct; data.x = h.logs.mag(:,1)-cur_time; data.y = h.logs.mag(:,mag_num + 1); item.data = data;
			args = struct; args.action = 'updateseries'; args.graph = graph_name; args.item = item;
			graphManager(args);
		end
		
	end
	
end

function plot_ekf_nutation(flags, duration)
	global t
	
	graph_name = 'video_sensor_to_ekf_3d';
	args = struct; args.name = graph_name; args.action = 'create';
	fig_id = graphManager(args);
	figure(fig_id)
	
	if bitand(flags, 1)
		plant_plot = setup_tsat_plot(graph_name, 'b');
	end
	
	if bitand(flags, 2)
		meas_plot = setup_tsat_plot(graph_name, 'g');
	end
	
	if bitand(flags, 4)
		ekf_plot = setup_tsat_plot(graph_name, 'r');
	end
	
	cur_time = t.now();
	start_sim = t.now();
	pause_time = 0.02;
	
	p = setup_plant();
	
	if bitand(flags, 6)
		truth_tsat = truthModel();
		s_array = sensors();
	end
	
	if bitand(flags, 4)
		args = struct;
		args.Q_k = zeros(7);
		args.Q_k(1:3, 1:3) = eye(3) * 0.0001;
		args.Q_k(4, 4) = 1 * 0.01;
		args.Q_k(5:7, 5:7) = eye(3) * 5;
		args.Q_k = eye(7);
		args.R_k = zeros(7);
		args.R_k(1:3, 1:3) = eye(3) * 0.002;
		args.R_k(4, 4) = 1 * 0.002;
		args.R_k(5:7, 5:7) = eye(3) * 0.000001;
		args.R_k = eye(7);
		args.I = p.vel.I;
		
		ekf_est = ekf(args);
	end
	
	while start_sim + duration > t.now()
		pause(pause_time)
		p.propagate();
		
		if bitand(flags, 6)
			args = struct; args.state = p.state;
			V = truth_tsat.generate_voltages(args);
			args = struct; args.volts = V;
			s_array.update(args);
		end
		
		if bitand(flags, 4)
			args = struct; args.state = s_array.state;
			ekf_est.update(args);
		end
		
		if bitand(flags, 1)
			plot_args = struct; plot_args.graph = graph_name; plot_args.state = p.state;
			plant_plot.updatePlot(plot_args);
		end
		
		if bitand(flags, 2)
			plot_args = struct; plot_args.graph = graph_name; plot_args.state = s_array.state;
			meas_plot.updatePlot(plot_args);
		end
		
		if bitand(flags, 4)
			plot_args = struct; plot_args.graph = graph_name; plot_args.state = ekf_est.state;
			ekf_plot.updatePlot(plot_args);
		end
		
	end
end