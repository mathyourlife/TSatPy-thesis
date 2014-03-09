disp('Testing Use of the Luenberger Observer')

record_it = 0;
args = struct;
args.name = 'sim_luenberger';
args.action = 'create';
fig_id = graphManager(args);
figure(fig_id)

tm_luenberger = tsatModel();
plot_args = struct; plot_args.graph = 'sim_luenberger'; plot_args.color = 'k';
tm_luenberger.setupPlot(plot_args);
plot_args = struct; plot_args.graph = 'sim_luenberger';
tm_luenberger.addAxesLabels(plot_args);

tm_true = tsatModel();
plot_args = struct; plot_args.graph = 'sim_luenberger'; plot_args.color = 'g';
tm_true.setupPlot(plot_args);
plot_args = struct; plot_args.graph = 'sim_luenberger';
tm_true.addAxesLabels(plot_args);

args = struct;
args.title = 'Luenberger Observer Tracking Two Attitude Changes';
graphs.sim_luenberger.obj.format(args);

scrsz = get(0,'ScreenSize');
width = 600;
y = 50;
x = 500;
scrsz = [x y width width];
set(fig_id,'Position',scrsz);

pause_time = 0.02;
end_frame = 600;
switch_frame = end_frame/2;
tb = testBase;
o = observerLuenberger();
o.Kq.Ks = 90;

% Construct initial "true" state
args = struct; args.vector = [0 0 1]'; args.theta = -pi/4;
q = quaternion(args);
args = struct;
args.q = q;
args.w = bodyRate();
true_state1 = state(args);

% Construct second "true" state
args = struct; args.vector = [0 1 1]'; args.theta = -pi/2;
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

qa_label = text(0.5,0.5,0.5,sprintf('$$q_a = \\left( {\\matrix{ %0.4f \\cr %0.4f \\cr %0.4f \\cr %0.4f } } \\right) $$',true_state1.q.vector(1),true_state1.q.vector(2),true_state1.q.vector(3),true_state1.q.scalar),'interpreter','latex','VerticalAlignment','bottom','FontSize',12);

ql_label = text(-0.5,-0.5,-0.9,sprintf('$$q_l = \\left( {\\matrix{ %0.4f \\cr %0.4f \\cr %0.4f \\cr %0.4f } } \\right) $$',0,0,0,1),'interpreter','latex','VerticalAlignment','bottom','FontSize',12);

for frame=1:end_frame
	pause(pause_time)
	
	if (frame < switch_frame)
		args.state = true_state1;
		if (last_true_plot ~= 1)
			last_true_plot = 1;
			plot_args = struct; plot_args.graph = 'sim_luenberger'; plot_args.state = true_state1;
			tm_true.updatePlot(plot_args);
		end
	else
		args.state = true_state2;
		if (last_true_plot ~= 2)
			set(qa_label,'String',sprintf('$$q_a = \\left( {\\matrix{ %0.4f \\cr %0.4f \\cr %0.4f \\cr %0.4f } } \\right) $$',true_state2.q.vector(1),true_state2.q.vector(2),true_state2.q.vector(3),true_state2.q.scalar));
			last_true_plot = 2;
			plot_args = struct; plot_args.graph = 'sim_luenberger'; plot_args.state = true_state2;
			tm_true.updatePlot(plot_args);
		end
	end
	
	o = o.update(args);
	
	plot_args = struct; plot_args.graph = 'sim_luenberger'; plot_args.state = o.state;
	tm_luenberger.updatePlot(plot_args);
	
	args.plant_state = o.state;
	set(ql_label,'String',sprintf('$$q_l = \\left( {\\matrix{ %0.4f \\cr %0.4f \\cr %0.4f \\cr %0.4f } } \\right) $$',o.state.q.vector(1),o.state.q.vector(2),o.state.q.vector(3),o.state.q.scalar));
	
	if (record_it)
		mov(frame)=getframe(fig_id);
	end
end

if (record_it)
	movie2avi(mov,'luenberger_observer.avi', 'COMPRESSION', 'Cinepak', 'FPS', 24);
	clear mov;
end
