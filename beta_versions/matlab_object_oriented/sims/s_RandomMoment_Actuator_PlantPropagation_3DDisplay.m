function t_RandomMoment_Actuator_PlantPropagation_3DDisplay()

global t tsat graphs;

disp('Testing the connection between Desired Moment - Thruster Activation - Effective Moment - Plant Propagation - 3D Display')

args = struct;
args.name = 'sim_random_moment';
args.action = 'create';
fig_id = graphManager(args);
figure(fig_id);

tm_prop = tsatModel();
args = struct; args.graph = 'sim_random_moment'; args.color = 'b';
tm_prop.setupPlot(args);

title('Euler Moment Equations and Quaternion Dynamics with Random Thruster Moment Requests')

plant_args = struct;
plant_args.I = 100*eye(3); % Required for plant initialization.
p = plant(plant_args);

thruster_pulse_duration = 2;
pause_time = 0.2;
run_time = 6;
last_thrust = t.now();
desired_moment = (rand(3,1)*2.-1).*10;
info = text(0.5,0.5,0.5,sprintf('$$RequestedMoment = \\left( {\\matrix{ %0.2f \\cr %0.2f \\cr %0.2f } } \\right)$$',desired_moment(1),desired_moment(2),desired_moment(3)),'interpreter','latex','VerticalAlignment','bottom','FontSize',12);
for i=0:ceil(run_time/pause_time)
  % increment frame counter
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
  args = struct; args.graph = 'sim_random_moment'; args.state = p.state;
  tm_prop.updatePlot(args);
end
close(graphs.sim_random_moment.obj.fig_id)