

args = struct;
args.x0 = [1; 0.2];
l_meas=linearSystem(args);

p_meas = tPlot;
item = struct;
item.name = 'measured_pos';
item.type = 'plot';
item.style = 'b-';
data = struct; data.x = 0; data.y = 0;
item.data = data;
p_meas=p_meas.addSeries(item);
args.name = 'measured_vel';
args.style = 'g-';
p_meas=p_meas.addSeries(item);
args.name = 'pos';
args.style = 'b--';
p_meas=p_meas.addSeries(item);
args.name = 'vel';
args.style = 'g--';
p_meas=p_meas.addSeries(item);


l=linearSystem();

for i=1:1000
	pause(0.1)
	l_meas=l_meas.update();
	time=l_meas.history.y(:,1)-min(l_meas.history.y(:,1));
	
	item = struct;
	item.name = 'measured_pos';
	item.type = 'plot';
	data = struct; data.x = time; data.y = l_meas.history.y(:,2);
	item.data = data;
	p_meas=p_meas.updateSeries(item);
	item = struct;
	item.name = 'measured_vel';
	item.type = 'plot';
	data = struct; data.x = time; data.y = l_meas.history.y(:,3);
	item.data = data;
	p_meas=p_meas.updateSeries(item);


	l=l.update();
	time=l.history.y(:,1)-min(l.history.y(:,1));
	
	item = struct;
	item.name = 'pos';
	item.type = 'plot';
	data = struct; data.x = time; data.y = l.history.y(:,2);
	item.data = data;
	p_meas=p_meas.updateSeries(item);
	item = struct;
	item.name = 'vel';
	item.type = 'plot';
	data = struct; data.x = time; data.y = l.history.y(:,3);
	item.data = data;
	p_meas=p_meas.updateSeries(item);
	
	error = (l_meas.x - l.x) * 0.02;
	r = (rand() + rand() + rand() + rand())/4;
	r = r * 6 - 3;
	error(1) = error(1) + (r * error(1));
	
	l.x = l.x + error;

end
