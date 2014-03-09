

figure(1)
fig = tPlot();
% Setup estimator series
item = struct;
item.name = 'q0';
item.type = 'plot';
item.style = 'b--';
item.data.x = 0;
item.data.y = 0;
fig =fig.addSeries(item);
for i = 1:3
	item.name = sprintf('q%d',i);
	item.style = 'g--';
	fig = fig.addSeries(item);
end


disp('Testing the functionality of the quaternion system equations')

disp('Quaternion kinematics q_dot = 1/2 q_w x q')

w = [0 0 -3*2*pi/60]';

qd = quaternionDynamics();

qd.w.w = w;

ts = datenummx(clock)*24*3600;

h = hist();
while datenummx(clock)*24*3600 < ts + 40
	pause(0.1)
	qd.propagate();
	args = struct; args.var = 'q'; args.value = qd.q;
	h = h.log(args);

	item.name = 'q0';
	item.data.x = h.values.q(:,1);
	item.data.y = h.values.q(:,5);
	fig = fig.updateSeries(item);
	for i = 1:3
		item.name = sprintf('q%d',i);
		item.data.x = h.values.q(:,1);
		item.data.y = h.values.q(:,i+1);
		fig = fig.updateSeries(item);
	end
end