function visualizeQuaternion(q,s,tracking_pt)
	if nargin < 3
		tracking_pt = [0.4 0 0]';
	end
	if nargin < 2
		s = state();
	end
	global graphs
	
	if isa(q,'quaternion')
		q_arr = {};
		q_arr{1} = q;
	elseif isa(q,'cell')
		q_arr = q;
	end
	
	args = struct;
	args.name = 'q_viz';
	args.action = 'create';
	graphManager(args);
	
	% Initialize plot
	args = struct; args.show_thrusters = 0;
	tm = tsatModel(args);
	plot_args = struct; plot_args.graph = 'q_viz'; plot_args.color = 'b';
	tm.setupPlot(plot_args);
	
	plot_args = struct; plot_args.graph = 'q_viz';
	tm.addAxesLabels(plot_args);
	
	% Set plant to starting state
	plot_args = struct; plot_args.graph = 'q_viz'; plot_args.state = s;
	tm.updatePlot(plot_args);
	
	% Setup the rotation trace
	trace_pts = zeros(0,0);
	
	args = struct;
	args.action = 'addseries'; args.graph = 'q_viz';
	item = struct; item.name = 'rot'; item.type = 'plot3'; item.style = 'g-'; item.LineWidth = 2;
	data = struct; data.x = 0; data.y = 0; data.z = 0;
	item.data = data;
	args.item = item;
	graphManager(args);
	
	info = text(-0.9,0.9,0.8,' ','VerticalAlignment','bottom','FontSize',12,'FontWeight','bold');
	
	s = state();
	for i=1:numel(q_arr)
		q = q_arr{i};
		disp(sprintf('Visualizing quaternion for %s',q.str))
		
		[vec, theta] = q.toRotation();
		vec = vec / norm(vec);
		set(info,'String',sprintf('Rotation Axis: [%0.2f %0.2f %0.2f]\nAngle: %d deg\nQuaternion: [%0.4f %0.4f %0.4f], %0.4f',vec(1),vec(2),vec(3),floor(theta*180/pi),q.vector(1),q.vector(2),q.vector(3),q.scalar));
		
		vec_disp = vec / norm(vec);
		args = struct;
		args.points = vec_disp';
		
		vec_disp = s.q.rotate_points(args);
		v_data = [vec_disp; -vec_disp];
		
		args = struct;
		args.action = 'addseries'; args.graph = 'q_viz';
		args.item = struct;
		args.item.name = sprintf('q_axis_%d',i); args.item.type = 'plot3'; args.item.style = 'r--'; args.item.LineWidth = 2;
		data = struct; data.x = v_data(:,1); data.y = v_data(:,2); data.z = v_data(:,3);
		args.item.data = data;
		graphManager(args);
		
		% Setup for rotation
		steps = 20;
		
		args = struct;
		args.vector = vec;
		args.theta = theta / steps;
		q_min = quaternion(args);
		
		% Perform the rotation
		for step=1:steps
			pause(0.2)
			
			q1 = q_min * s.q;
			
			args = struct;
			args.points = tracking_pt';
			
			pt = q1.rotate_points(args);
			trace_pts(size(trace_pts,1)+1,:) = pt';
			
			% Update the trace
			args = struct;
			args.action = 'updateseries'; args.graph = 'q_viz';
			item = struct; item.name = 'rot'; item.type = 'plot3';
			item_data = struct; item_data.x = trace_pts(:,1); item_data.y = trace_pts(:,2); item_data.z = trace_pts(:,3);
			item.data = item_data;
			args.item = item;
			graphManager(args);
			
			s.q = q1;
			plot_args = struct; plot_args.graph = 'q_viz'; plot_args.state = s;
			tm.updatePlot(plot_args);
		end
	end
end