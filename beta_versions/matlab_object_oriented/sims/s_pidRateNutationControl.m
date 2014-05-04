disp('Running simulation of PID control from a static position')
record_it = 0;
show_desired = 0;
show_subplot = 0;

graph_name = 'sim_pid_control';

args = struct;
args.name = graph_name;
args.action = 'create';
fig_id = graphManager(args);
figure(fig_id);
if (show_subplot)
  subplot(1,2,1)
end

args = struct;
tm_ctrl = tsatModel(args);
plot_args = struct; plot_args.graph = graph_name; plot_args.color = 'b';
tm_ctrl.setupPlot(plot_args);
plot_args = struct; plot_args.graph = graph_name;
tm_ctrl.addAxesLabels(plot_args);

if (show_desired)
  args = struct; args.show_thrusters = 0;
  tm_tmp = tsatModel(args);
  plot_args = struct; plot_args.graph = graph_name; plot_args.color = 'b';
  tm_tmp.setupPlot(plot_args);
  plot_args = struct; plot_args.graph = graph_name;
  tm_tmp.addAxesLabels(plot_args);
end

fh=figure(fig_id);
args = struct;
args.title = 'Quaternion-Based Body Rate and Nutation PID Control';
graphs.sim_pid_control.obj.format(args);

scrsz = get(0,'ScreenSize');
scrsz(1) = 400;
scrsz(2) = 40;
size = 800;
scrsz(3) = size;
scrsz(4) = size/4*3;
set(fh,'Position',scrsz);

if (record_it)
  clear mov;
end

args = struct;
args.vector = [0 0 1];
args.theta = 45/180*pi;
qr = quaternion(args);

args = struct;
args.vector = [1 0 0];
args.theta = 30/180*pi;
qn = quaternion(args);

%q0 = qn * qr;
q0 = mock().gen_random_quaternion;

args = struct;
args.I = eye(3)*10;
args.q = q0;
p_ctrl = plant(args);

tsat.controller = tsat.controller.reset();
args = struct; args.type = 'pid';
tsat.controller = tsat.controller.run(args);

args = struct;
args.Kp.Kq = 0.05;
args.Kp.Kw = [2 0 0; 0 2 0; 0 0 4];
%args.Kd.Kq = 0.1;
args.Ki.Kw = [0.0005 0 0; 0 0.005 0; 0 0 0.001];
tsat.controller.pid = tsat.controller.pid.setGain(args);
args = struct; args.type = 'pid';
tsat.controller = tsat.controller.run(args);
tsat.controller = tsat.controller.setOutput(args);

args = struct;
args.M = [0 0 0]';
tsat.actuators = tsat.actuators.requestMoment(args);

plot_args = struct; plot_args.graph = 'sim_pid_control'; plot_args.state = p_ctrl.state;
tm_ctrl.updatePlot(plot_args);

txt_M = text(-0.9,0.9,0.9,sprintf(['$$RequestedMoment = \\left( {\\matrix{ %0.2f ' ...
  '\\cr %0.2f \\cr %0.2f } } \\right)$$'],tsat.actuators.effective_moment(1)*1000, ...
  tsat.actuators.effective_moment(2)*1000,tsat.actuators.effective_moment(3)*1000), ...
  'interpreter','latex','VerticalAlignment','bottom','FontSize',12);

txt_err = text(-1,0,-0.9,sprintf('State Error = %s',tsat.controller.state_error.str), ...
  'VerticalAlignment','bottom','FontSize',12);

if (show_subplot)
  subplot(1,2,2)
  item = struct; item.name = 'Mp'; item.type = 'plot'; item.style = 'b';
  data = struct; data.x = 0; data.y = 0; item.data = data;
  args = struct; args.action = 'addseries'; args.graph = 'sim_pid_control'; args.item = item;
  graphManager(args);
  item.name = 'Mi'; item.style = 'k';
  args = struct; args.action = 'addseries'; args.graph = 'sim_pid_control'; args.item = item;
  graphManager(args);
  item.name = 'Md'; item.style = 'g';
  args = struct; args.action = 'addseries'; args.graph = 'sim_pid_control'; args.item = item;
  graphManager(args);
  item.name = 'M'; item.style = 'r';
  args = struct; args.action = 'addseries'; args.graph = 'sim_pid_control'; args.item = item;
  graphManager(args);
  grid on;
end

h=hist();

stage_frame_count = 20;
frame_count = 1000;
if (record_it)
  clear mov;
  %mov(1:frame_count) = struct('cdata', [],'colormap', []);
end

args = struct;
args.w = [0 0 0.05]';
desired_body_rate = bodyRate(args);
args = struct;
args.q = quaternion();
args.w = desired_body_rate;
desired_state = state(args);

for frame=1:stage_frame_count
  mov(frame)=getframe(fh);
  pause(0.01)
end

pushes = 0;
push_limit = 8;

while (frame < stage_frame_count+frame_count) && (pushes < push_limit)
  frame = frame + 1;
  pause(1);

  cur_time = t.now();

  args = struct;
  args.state = p_ctrl.state;
  args.desired_state = desired_state;

  tsat.controller = tsat.controller.update(args);

  if (show_desired)
    plot_args = struct; plot_args.plot = graphs.sim_pid_control.obj;
    plot_args.state = tsat.controller.desired_state;
    graphs.sim_pid_control.obj = tm_tmp.updatePlot(plot_args);
  end

  args = struct;
  max_moment = 0.01;
  % Baseline testing shows 13x improvement using sqrt(^2) instead of norm
  mag = abs(sqrt(tsat.controller.M.total(1)^2 + tsat.controller.M.total(2)^2 + ...
    tsat.controller.M.total(3)^2));
  if (mag > max_moment)
    args.M = tsat.controller.M.total .* max_moment / mag;
  else
    args.M = tsat.controller.M.total;
  end

  %args.M = tsat.controller.M.total ./ min(max_moment,abs(norm(tsat.controller.M.total)));
  %args.M = min(abs(tsat.controller.M.total),max_moment).*sign(tsat.controller.M.total);
  %args.M = tsat.controller.M.total;
  tsat.actuators = tsat.actuators.requestMoment(args);

  % Push effective moment to plant propagation
  args = struct;
  % Add disturbance
  if (frame > stage_frame_count + 10) && ( ...
    max(abs(tsat.controller.state_error.w.w)) < 0.0015) && ( ...
    abs(dot([0 0 1]',p_ctrl.state.q.vector/norm(p_ctrl.state.q.vector))) > 0.999)

    pushes = pushes + 1;
    if pushes > push_limit
      return;
    end
    args = struct;
    args.F = 0.3 * rand() + 0.4;
    tm_ctrl = tm_ctrl.updateDisturbance(args);
    M = tm_ctrl.getDisturbanceMoment(args);
    args.M = tsat.actuators.effective_moment + M;
  else
    args = struct;
    args.F = 0;
    tm_ctrl = tm_ctrl.updateDisturbance(args);
    args.M = tsat.actuators.effective_moment;
  end
  p_ctrl.propagate(args);

  plot_args = struct; plot_args.graph = 'sim_pid_control'; plot_args.state = p_ctrl.state;
  tm_ctrl.updatePlot(plot_args);

  args = struct; args.var = 'M'; args.value = sum(tsat.controller.M.total);
  h = h.log(args);

  if (show_subplot)
    args = struct; args.var = 'Mp';
  args.value = sum(tsat.controller.pid.M.Kp.Kq+tsat.controller.pid.M.Kp.Kw);
    h = h.log(args);
    item = struct; item.name = 'Mp'; item.type = 'plot';
    data = struct; data.x = h.logs.Mp(:,1)-cur_time-1; data.y = h.logs.Mp(:,2);
    item.data = data;
    graphs.sim_pid_control.obj = graphs.sim_pid_control.obj.updateSeries(item);

    args = struct; args.var = 'Mi';
    args.value = sum(tsat.controller.pid.M.Ki.Kq+tsat.controller.pid.M.Ki.Kw);
    h = h.log(args);
    item = struct; item.name = 'Mi'; item.type = 'plot';
    data = struct; data.x = h.logs.Mi(:,1)-cur_time-1; data.y = h.logs.Mi(:,2);
    item.data = data;
    graphs.sim_pid_control.obj = graphs.sim_pid_control.obj.updateSeries(item);

    args = struct; args.var = 'Md';
    args.value = sum(tsat.controller.pid.M.Kd.Kq+tsat.controller.pid.M.Kd.Kw);
    h = h.log(args);
    item = struct; item.name = 'Md'; item.type = 'plot';
    data = struct; data.x = h.logs.Md(:,1)-cur_time-1; data.y = h.logs.Md(:,2);
    item.data = data;
    graphs.sim_pid_control.obj = graphs.sim_pid_control.obj.updateSeries(item);

    args = struct; args.var = 'M'; args.value = sum(tsat.controller.pid.M.total);
    h = h.log(args);
    item = struct; item.name = 'M'; item.type = 'plot';
    data = struct; data.x = h.logs.M(:,1)-cur_time; data.y = h.logs.M(:,2);
    item.data = data;
    graphs.sim_pid_control.obj = graphs.sim_pid_control.obj.updateSeries(item);
  end

  set(txt_M,'String',sprintf(['$$RequestedMoment = \\left( {\\matrix{ %0.2f \\cr ' ...
    '%0.2f \\cr %0.2f } } \\right)$$'],tsat.actuators.effective_moment(1)*1000, ...
    tsat.actuators.effective_moment(2)*1000,tsat.actuators.effective_moment(3)*1000));

  set(txt_err,'String',sprintf('State Error = %s',tsat.controller.state_error.str));

  if (record_it)
    mov(frame)=getframe(fh);
  end
end

if (record_it)
  movie2avi(mov,'pid-nutation-br-controller.avi', 'FPS', 24);
  clear mov;
end
