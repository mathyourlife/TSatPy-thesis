


t = tPlot();
tm_est = tsatModel();
args = struct; args.plot = t;
t=tm_est.setupPlot(args);
tm_meas = tsatModel();
args = struct; args.plot = t;
t=tm_meas.setupPlot(args);

s=state;
for i=1:10
	wait = 0.5;
	pause(wait)
	
	args = struct; args.vector = [0 0 1]; args.theta = wait*i;
	s.q=quaternion(args);
	args = struct; args.plot = t; args.state = s;
	t=tm_meas.updatePlot(args);
	
end

