

args = struct;
args.name = 'test_mag';
args.action = 'create';
graphManager(args);

args = struct; args.show_thrusters = 0;
xpos_tm = tsatModel(args);
plot_args = struct; plot_args.plot = graphs.test_mag.obj;
plot_args.color = 'b';
graphs.test_mag.obj = xpos_tm.setupPlot(plot_args);
plot_args = struct; plot_args.plot = graphs.test_mag.obj;
xpos_tm.addAxesLabels(plot_args);

s = state();

l = logProcessing();
[xpos, result] = l.read_log('save/xpos_mag.log');

sensors_args = struct;
for r=1:size(xpos.css,1)
	pause(0.1)
	plot_args = struct; plot_args.plot = graphs.test_mag.obj;
	
	sensors_args.volts.css = xpos.css(r,:);
	sensors_args.volts.accel = xpos.accel(r,:);
	sensors_args.volts.gyro = xpos.gyro(r,:);
	sensors_args.volts.mag = xpos.mag(r,:);
	tsat.sensors = tsat.sensors.update(sensors_args);
	s.q = tsat.sensors.state.q;
	plot_args.state = s;
	graphs.test_mag.obj = xpos_tm.updatePlot(plot_args);
	
end
