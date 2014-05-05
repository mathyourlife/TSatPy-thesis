disp('Testing Use of the Luenberger Observer with Noisy Measurements')

record_it = 0;
args = struct;
args.name = 'sim_noisy_luenberger';
args.action = 'create';
fig_id = graphManager(args);
figure(fig_id)

tm_luenberger = tsatModel();
plot_args = struct; plot_args.plot = graphs.sim_noisy_luenberger.obj; plot_args.color = 'k';
graphs.sim_noisy_luenberger.obj = tm_luenberger.setupPlot(plot_args);
plot_args = struct; plot_args.plot = graphs.sim_noisy_luenberger.obj;
tm_luenberger.addAxesLabels(plot_args);

tm_true = tsatModel();
plot_args = struct; plot_args.plot = graphs.sim_noisy_luenberger.obj; plot_args.color = 'g';
graphs.sim_noisy_luenberger.obj = tm_true.setupPlot(plot_args);
plot_args = struct; plot_args.plot = graphs.sim_noisy_luenberger.obj;
tm_true.addAxesLabels(plot_args);

args = struct;
args.title = 'Luenberger Observer Tracking Attitude Changes With Measurement Noise';
graphs.sim_noisy_luenberger.obj.format(args);

scrsz = get(0,'ScreenSize');
width = 600;
y = 50;
x = 500;
scrsz = [x y width width];
set(fig_id,'Position',scrsz);

pause_time = 0.02;
end_frame = 400;
switch_frame = end_frame/2;
tb = testBase;
o = observerLuenberger();
o.Kq.Ks = 15;

% Construct initial "true" state
args = struct; args.vector = [0.1 0.1 1]'; args.theta = -pi/4;
q = quaternion(args);
args = struct;
args.q = q;
args.w = bodyRate();
true_state1 = state(args);

% Construct second "true" state
args = struct; args.vector = [0.1 1 1]'; args.theta = -pi/2;
q = quaternion(args);
args = struct;
args.q = q;
args.w = bodyRate();
true_state2 = state(args);

last_true_plot = 0;
args = struct;
args.plant_state = state();
if (record_it)
  clear mov;
end

qa_label = text(0.5,0.5,0.5,sprintf(['$$q_a = \\left( {\\matrix{ %0.4f \\cr %0.4f ' ...
  '\\cr %0.4f \\cr %0.4f } } \\right) $$'],true_state1.q.vector(1), ...
  true_state1.q.vector(2),true_state1.q.vector(3),true_state1.q.scalar), ...
  'interpreter','latex','VerticalAlignment','bottom','FontSize',12);

qm_label = text(-0.9,0.9,0.8,sprintf(['$$q_m = \\left( {\\matrix{ %0.4f \\cr %0.4f ' ...
  '\\cr %0.4f \\cr %0.4f } } \\right) $$'],true_state1.q.vector(1), ...
  true_state1.q.vector(2),true_state1.q.vector(3),true_state1.q.scalar), ...
  'interpreter','latex','VerticalAlignment','bottom','FontSize',12);

ql_label = text(-0.5,-0.5,-0.9,sprintf(['$$q_l = \\left( {\\matrix{ %0.4f \\cr ' ...
  '%0.4f \\cr %0.4f \\cr %0.4f } } \\right) $$'],0,0,0,1),'interpreter','latex', ...
  'VerticalAlignment','bottom','FontSize',12);

for frame=1:end_frame
  pause(pause_time)

  if (frame < switch_frame)
    args.state = true_state1;
  else
    args.state = true_state2;
  end
  set(qa_label,'String',sprintf(['$$q_a = \\left( {\\matrix{ %0.4f \\cr %0.4f ' ...
    '\\cr %0.4f \\cr %0.4f } } \\right) $$'],args.state.q.vector(1), ...
    args.state.q.vector(2),args.state.q.vector(3),args.state.q.scalar));

  args.state.q.scalar = args.state.q.scalar * (rand()*0.2+.9);
  args.state.q.vector = args.state.q.vector .* (rand(3,1)*0.2+.9);
  args.state.q.normalize();
  set(qm_label,'String',sprintf(['$$q_m = \\left( {\\matrix{ %0.4f \\cr %0.4f \\cr ' ...
    '%0.4f \\cr %0.4f } } \\right) $$'],args.state.q.vector(1),args.state.q.vector(2), ...
    args.state.q.vector(3),args.state.q.scalar));
  plot_args = struct; plot_args.plot = graphs.sim_noisy_luenberger.obj;
  plot_args.state = args.state;
  graphs.sim_noisy_luenberger.obj = tm_true.updatePlot(plot_args);
  o = o.update(args);

  plot_args = struct; plot_args.plot = graphs.sim_noisy_luenberger.obj;
  plot_args.state = o.state;
  graphs.sim_noisy_luenberger.obj = tm_luenberger.updatePlot(plot_args);

  args.plant_state = o.state;
  set(ql_label,'String',sprintf(['$$q_l = \\left( {\\matrix{ %0.4f \\cr %0.4f \\cr ' ...
    '%0.4f \\cr %0.4f } } \\right) $$'],o.state.q.vector(1),o.state.q.vector(2), ...
    o.state.q.vector(3),o.state.q.scalar));

  if (record_it)
    mov(frame)=getframe(fig_id);
  end
end

if (record_it)
  movie2avi(mov,'luenberger_observer_with_noise.avi', 'COMPRESSION', 'Cinepak', 'FPS', 8);
  clear mov;
end

close(fig_id)