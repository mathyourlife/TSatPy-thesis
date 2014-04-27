
record_it = 0;

scrsz = get(0,'ScreenSize');
width = 700;
y = 50;
x = 500;
scrsz = [x y width width];

fig = tPlot();
tm_prop = tsatModel();
args = struct; args.plot = fig; args.color = 'b';
fig=tm_prop.setupPlot(args);

fh=figure(fig.fig_id);
title('Euler Moment Equations and Quaternion Dynamics with Random Thruster Moment Requests')
set(fh,'Position',scrsz);

plant_args = struct;
plant_args.I = 1000*eye(3); % Required for plant initialization.
p = plant(plant_args);

if (record_it)
  clear mov;
  frame = 0;
end
thruster_pulse_duration = 12;
pause_time = 0.2;
run_time = 40;
last_thrust = t.now();
desired_moment = (rand(3,1)*2.-1).*10;
info = text(0.5,0.5,0.5,sprintf('$$RequestedMoment = \\left( {\\matrix{ %0.2f \\cr %0.2f \\cr %0.2f } } \\right)$$',desired_moment(1),desired_moment(2),desired_moment(3)),'interpreter','latex','VerticalAlignment','bottom','FontSize',12);
for i=0:ceil(run_time/pause_time)
  % increment frame counter
  if (record_it)
    frame = frame + 1;
  end
  % Allow for redraw
  pause(pause_time);
  if last_thrust + thruster_pulse_duration < t.now()
    last_thrust = t.now();
    desired_moment = (rand(3,1)*2.-1).*10;
    
    set(info,'String',sprintf('$$RequestedMoment = \\left( {\\matrix{ %0.2f \\cr %0.2f \\cr %0.2f } } \\right)$$',desired_moment(1),desired_moment(2),desired_moment(3)));
  end
  
  args = struct;
  args.M = desired_moment;
  tsat.actuators = tsat.actuators.requestMoment(args);
  
  
  % Push effective moment to plant propagation
  args = struct;
  args.M = tsat.actuators.effective_moment;
  p.propagate(args);
  args = struct; args.plot = fig; args.state = p.state;
  fig = tm_prop.updatePlot(args);
  if (record_it)
    mov(frame)=getframe(fh);
  end
end
if (record_it)
  movie2avi(mov,'random_moments_with_euler_and_quaternion_propagation.avi', 'COMPRESSION', 'Cinepak', 'FPS', floor(1/pause_time));
  clear mov;
end
