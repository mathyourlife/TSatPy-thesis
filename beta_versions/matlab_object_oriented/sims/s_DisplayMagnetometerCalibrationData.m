function s_DisplayMagnetometerCalibrationData()
	disp('Display Magnetometer Calibration Data')
	
	global graphs calibration_data
	
	record_it = 0;
	
	graph_name = 'sim_mag_calib_data';
	
	args = struct;
	args.name = graph_name;
	args.action = 'create';
	fig_id = graphManager(args);
	figure(fig_id)
	
	item = struct;
	item.name = 'steady';
	item.type = 'plot3';
	item.style = 'b-';
	item.LineWidth = 2;
	data = struct;
	data.x = calibration_data.volts.steady(:,1);
	data.y = calibration_data.volts.steady(:,2);
	data.z = calibration_data.volts.steady(:,3);
	item.data = data;
	args = struct; args.item = item; args.action = 'addseries'; args.graph = graph_name;
	graphManager(args);
	
	item.name = 'xpos';
	item.style = 'r-';
	item.data.x = calibration_data.volts.xpos(:,1);
	item.data.y = calibration_data.volts.xpos(:,2);
	item.data.z = calibration_data.volts.xpos(:,3);
	args = struct; args.item = item; args.action = 'addseries'; args.graph = graph_name;
	graphManager(args);
	
	item.name = 'ypos';
	item.style = 'k-';
	item.data.x = calibration_data.volts.ypos(:,1);
	item.data.y = calibration_data.volts.ypos(:,2);
	item.data.z = calibration_data.volts.ypos(:,3);
	args = struct; args.item = item; args.action = 'addseries'; args.graph = graph_name;
	graphManager(args);
	
	item.name = 'xneg';
	item.style = 'g-';
	item.data.x = calibration_data.volts.xneg(:,1);
	item.data.y = calibration_data.volts.xneg(:,2);
	item.data.z = calibration_data.volts.xneg(:,3);
	args = struct; args.item = item; args.action = 'addseries'; args.graph = graph_name;
	graphManager(args);
	
	item.name = 'yneg';
	item.style = 'm-';
	item.data.x = calibration_data.volts.yneg(:,1);
	item.data.y = calibration_data.volts.yneg(:,2);
	item.data.z = calibration_data.volts.yneg(:,3);
	args = struct; args.item = item; args.action = 'addseries'; args.graph = graph_name;
	graphManager(args);
	
	args = struct; args.action = 'format'; args.graph = graph_name;
	args.item = struct;
	args.item.title = 'Magnetometer Calibration Data';
	args.item.DataAspectRatio = [1 1 1];
	graphManager(args);
	
	args = struct; args.action = 'grid'; args.graph = graph_name;
	args.item = struct;
	args.item.all = 'on';
	graphManager(args);
	
	item.name = 'xpos_series';
	item.style = 'r-';
	item.LineWidth = 4;
	data = [calibration_data.volts.steady(1,:); calibration_data.volts.xpos(1,:)];
	item.data.x = data(:,1);
	item.data.y = data(:,2);
	item.data.z = data(:,3);
	args = struct; args.item = item; args.action = 'addseries'; args.graph = graph_name;
	graphManager(args);
	
	item.name = 'ypos_series';
	item.style = 'k-';
	data = [calibration_data.volts.steady(1,:); calibration_data.volts.ypos(1,:)];
	item.data.x = data(:,1);
	item.data.y = data(:,2);
	item.data.z = data(:,3);
	args = struct; args.item = item; args.action = 'addseries'; args.graph = graph_name;
	graphManager(args);
	
	item.name = 'xneg_series';
	item.style = 'g-';
	data = [calibration_data.volts.steady(1,:); calibration_data.volts.xneg(1,:)];
	item.data.x = data(:,1);
	item.data.y = data(:,2);
	item.data.z = data(:,3);
	args = struct; args.item = item; args.action = 'addseries'; args.graph = graph_name;
	graphManager(args);
	
	item.name = 'yneg_series';
	item.style = 'm-';
	data = [calibration_data.volts.steady(1,:); calibration_data.volts.yneg(1,:)];
	item.data.x = data(:,1);
	item.data.y = data(:,2);
	item.data.z = data(:,3);
	args = struct; args.item = item; args.action = 'addseries'; args.graph = graph_name;
	graphManager(args);
	
	if (record_it)
		fh=figure(fig_id);
		clear mov;
		frame = 0;
	end
	
	pause(10);
	
	item = struct;
	for i=1:1
		for n=1:2:360
			
			if (record_it)
				frame = frame + 1;
			end
			
			item.name = 'xpos_series';
			data = [calibration_data.volts.steady(n,:); calibration_data.volts.xpos(n,:)];
			item.data.x = data(:,1);
			item.data.y = data(:,2);
			item.data.z = data(:,3);
			args = struct; args.item = item; args.action = 'updateseries'; args.graph = graph_name;
			graphManager(args);
			
			item.name = 'ypos_series';
			data = [calibration_data.volts.steady(n,:); calibration_data.volts.ypos(n,:)];
			item.data.x = data(:,1);
			item.data.y = data(:,2);
			item.data.z = data(:,3);
			args = struct; args.item = item; args.action = 'updateseries'; args.graph = graph_name;
			graphManager(args);
			
			item.name = 'xneg_series';
			data = [calibration_data.volts.steady(n,:); calibration_data.volts.xneg(n,:)];
			item.data.x = data(:,1);
			item.data.y = data(:,2);
			item.data.z = data(:,3);
			args = struct; args.item = item; args.action = 'updateseries'; args.graph = graph_name;
			graphManager(args);
			
			item.name = 'yneg_series';
			data = [calibration_data.volts.steady(n,:); calibration_data.volts.yneg(n,:)];
			item.data.x = data(:,1);
			item.data.y = data(:,2);
			item.data.z = data(:,3);
			args = struct; args.item = item; args.action = 'updateseries'; args.graph = graph_name;
			graphManager(args);
			
			if (record_it)
				mov(frame)=getframe(fh);
			end
			pause(0.1)
		end
	end
	
	if (record_it)
		movie2avi(mov,'magnetometer_calibration_data.avi', 'COMPRESSION', 'Cinepak', 'FPS', 20);
		clear mov;
	end
end