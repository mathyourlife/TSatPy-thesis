disp('Testing thruster class')

tb=testBase;
try
	th = thruster();
	tb.fail('An exception should have been thrown');
catch
	msg = lasterror.message;
	e_msg = 'Missing "center" argument in thruster';
	tb.assertErrorMsg(e_msg,msg,'Did not specify a thruster center');
end

args = struct;
args.center = rand(3,1);
try
	th = thruster(args);
	tb.fail('An exception should have been thrown');
catch
	msg = lasterror.message;
	e_msg = 'Missing "direction" argument in thruster';
	tb.assertErrorMsg(e_msg,msg,'Did not specify a thruster direction');
end

args.direction = rand(3,1);
args.name = 'This pushes things';
th = thruster(args);

center_chk = args.center / norm(args.center);
center_chk = center_chk * th.thruster_radius + args.center;
tb.assertEquals(center_chk, th.center, 'Thruster has the correct center point for thrust');
tb.assertEquals(args.direction/norm(args.direction), th.direction, 'Thruster has the correct thrust direction');
tb.assertEquals(0,th.force,'Thruster initialized as off');
tb.assertEquals([0 0 0]',th.moment,'Thruster initialized with no applied moment');
tb.assertEquals(args.name, th.name, 'Thruster was well named');
tb.assertEquals('thispushesthings',th.plot_name,'Thruster was given a safe plot name');

% Check that the plot points make a circle around the thruster's center
t_radius = -1;
for i=1:size(th.pts,1)
	if (t_radius ~= -1)
		tb.assertMaxError(t_radius,norm(th.pts(i,:) - th.center'),0.5,sprintf('Consistent plotting radius between points %d and %d',i-1,i	));
	end
	t_radius = norm(th.pts(i,:) - th.center');
end



args = struct;
args.center = [3 0 0]';
args.direction = [0 0 0.5]';
th = thruster(args);
center_chk = args.center / norm(args.center);
center_chk = center_chk * th.thruster_radius + args.center;
tb.assertEquals([0 norm(center_chk) 0]',th.moment_potential,'Thruster moment per unit force is correct');

args = struct;
args.F = 20;
th = th.update(args);
tb.assertEquals([0 norm(center_chk)*20 0]',th.moment,'Thruster force provides the correct moment torque');

args = struct;
args.scale = 0.25;
th = th.set_thrust_plot_pts(args);
tb.assertEquals(0.25,th.scale,'Scale was set for plotting of the thruster force');
tb.assertEquals([norm(center_chk) 0 0; norm(center_chk) 0 5], th.thrust_pts, 'Plot points for the active thrusting force');

