
record_it = 0;
args = struct;
args.name = 'sim_p_control';
args.action = 'create';
fig_id = graphManager(args);

figure(fig_id);
subplot(1,2,1)

args = struct;
tm_ctrl = tsatModel(args);
plot_args = struct; plot_args.graph = 'sim_p_control'; plot_args.color = 'b';
tm_ctrl.setupPlot(plot_args);
plot_args = struct; plot_args.plot = graphs.sim_p_control.obj;
tm_ctrl.addAxesLabels(plot_args);

args = struct; args.show_thrusters = 0;
tm_desired = tsatModel(args);
plot_args = struct; plot_args.graph = 'sim_p_control'; plot_args.color = 'k';
tm_desired.setupPlot(plot_args);
plot_args = struct; plot_args.plot = graphs.sim_p_control.obj;
tm_desired.addAxesLabels(plot_args);

fh=figure(fig_id);
args = struct;
args.title = 'Quaternion Attitude P-Controller';
graphs.sim_p_control.obj.format(args);

scrsz = get(0,'ScreenSize');
scrsz(1) = 10;
scrsz(2) = 10;
scrsz(3) = scrsz(3) - 20;
scrsz(4) = scrsz(4) - 80;
set(fh,'Position',scrsz);

if (record_it)
  clear mov;
end

args = struct;
args.vector = [0 0 1];
args.theta = rand()*pi;
q = quaternion(args);
args = struct;
args.w = [0 0 0.05];
br = bodyRate(args);
args = struct;
args.q = q;
args.w = br;
args.I = eye(3)*10;
p_desired = plant(args);
desired = p_desired.state.q;

args = struct;
args.I = eye(3)*10;
p_ctrl = plant(args);
current = p_ctrl.state.q;

args = struct;
args.q = desired;
args.q_hat = current;
e = quaternionError(args);

tsat.controller = tsat.controller.reset();
args = struct; args.type = 'pid';
tsat.controller = tsat.controller.run(args);

args = struct;
%args.Kp.Kq = 0.001;
args.Kp.Kw = 0.1 * eye(3);
%args.Ki.Kq = 0.00001;
args.Ki.Kw = 0.001 * eye(3);
tsat.controller.pid = tsat.controller.pid.setGain(args);

args = struct;
args.M = [0 0 0]';
tsat.actuators = tsat.actuators.requestMoment(args);

subplot(1,2,2)
item = struct; item.name = 'Mp'; item.type = 'plot'; item.style = 'b';
data = struct; data.x = 0; data.y = 0; item.data = data;
args = struct; args.action = 'addseries'; args.graph = 'sim_p_control'; args.item = item;
graphManager(args);

item.name = 'Mi'; item.style = 'k';
args = struct; args.action = 'addseries'; args.graph = 'sim_p_control'; args.item = item;
graphManager(args);

item.name = 'Md'; item.style = 'g';
args = struct; args.action = 'addseries'; args.graph = 'sim_p_control'; args.item = item;
graphManager(args);

item.name = 'M'; item.style = 'r';
args = struct; args.action = 'addseries'; args.graph = 'sim_p_control'; args.item = item;
graphManager(args);

h=hist();

frame_count = 1000;
mov(1:frame_count) = struct('cdata', [],'colormap', []);
for frame=1:frame_count
  pause(1);

  cur_time = t.now();

  args = struct;
  args.state = p_ctrl.state;
  args.desired_state = p_desired.state;
  tsat.controller.pid = tsat.controller.pid.update(args);

  args = struct;
  %max_moment = [1 1 1]'*0.1;
  %args.M = min(abs(tsat.controller.pid.M.total),max_moment).*sign(tsat.controller.pid.M.total);
  args.M = tsat.controller.pid.M.total;
  tsat.actuators = tsat.actuators.requestMoment(args);

  % Push effective moment to plant propagation
  args = struct;
  args.M = tsat.actuators.effective_moment;
  p_ctrl.propagate(args);

  p_desired.propagate();

  plot_args = struct; plot_args.graph = 'sim_p_control'; plot_args.state = p_desired.state;
  tm_desired.updatePlot(plot_args);

  plot_args = struct; plot_args.graph = 'sim_p_control'; plot_args.state = p_ctrl.state;
  tm_ctrl.updatePlot(plot_args);

  args = struct; args.var = 'Mp';
  args.value = sum(tsat.controller.pid.M.Kp.Kq+tsat.controller.pid.M.Kp.Kw);
  h = h.log(args);
  item = struct; item.name = 'Mp'; item.type = 'plot';
  data = struct; data.x = h.logs.Mp(:,1)-cur_time-1; data.y = h.logs.Mp(:,2); item.data = data;
  args = struct; args.action = 'updateseries'; args.graph = 'sim_p_control'; args.item = item;
  graphManager(args);

  args = struct; args.var = 'Mi';
  args.value = sum(tsat.controller.pid.M.Ki.Kq+tsat.controller.pid.M.Ki.Kw);
  h = h.log(args);
  item = struct; item.name = 'Mi'; item.type = 'plot';
  data = struct; data.x = h.logs.Mi(:,1)-cur_time-1; data.y = h.logs.Mi(:,2); item.data = data;
  args = struct; args.action = 'updateseries'; args.graph = 'sim_p_control'; args.item = item;
  graphManager(args);

  args = struct; args.var = 'Md';
  args.value = sum(tsat.controller.pid.M.Kd.Kq+tsat.controller.pid.M.Kd.Kw);
  h = h.log(args);
  item = struct; item.name = 'Md'; item.type = 'plot';
  data = struct; data.x = h.logs.Md(:,1)-cur_time-1; data.y = h.logs.Md(:,2); item.data = data;
  args = struct; args.action = 'updateseries'; args.graph = 'sim_p_control'; args.item = item;
  graphManager(args);

  args = struct; args.var = 'M'; args.value = sum(tsat.controller.pid.M.total);
  h = h.log(args);
  item = struct; item.name = 'M'; item.type = 'plot';
  data = struct; data.x = h.logs.M(:,1)-cur_time; data.y = h.logs.M(:,2); item.data = data;
  args = struct; args.action = 'updateseries'; args.graph = 'sim_p_control'; args.item = item;
  graphManager(args);

  if (record_it)
    mov(frame)=getframe(fh);
  end
end

%if (record_it)
%  movie2avi(mov,'p-controller.avi', 'FPS', 24);
%  clear mov;
%end
