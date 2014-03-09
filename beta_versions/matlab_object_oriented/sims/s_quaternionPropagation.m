
record_it = 0;

args = struct; args.vector = [0,0,1]; args.scalar = 0;
q_hat=quaternion(args);

scrsz = get(0,'ScreenSize');
width = 200;
y = (scrsz(4) - width)/2;
x = (scrsz(3) - width*1.6)/2;
scrsz = [x y width*1.6 width];

args = struct;
args.name = 'sim_q_propagation';
args.action = 'create';
fig_id = graphManager(args);
figure(fig_id)

set(fig_id,'Position',scrsz);

% Setup estimator series
item = struct; item.name = 'q_hat0'; item.type = 'plot';
data = struct; data.x = 0; data.y = 0; item.data = data;
args = struct; args.action = 'addseries'; args.graph = 'sim_q_propagation'; args.item = item;
graphManager(args);
for i = 1:3
	item = struct; item.name = sprintf('q_hat%d',i); item.type = 'plot';
	data = struct; data.x = 0; data.y = 0; item.data = data;
	args = struct; args.action = 'addseries'; args.graph = 'sim_q_propagation'; args.item = item;
	graphManager(args);
end
legend('q0','q1','q2','q3','Location','EastOutside');
title 'Quaternion Dynamics Propagation'
xlabel 'Time (s)'

prop_args = struct;
prop_args.w = [0 0 -3*2*pi/60]';
prop_args.w = bodyRate(prop_args);
prop_args.w = mock().gen_random_body_rate;
qd = quaternionDynamics();

h=hist();
% Preallocate movie structure.
nFrames = 80;
if record_it
	clear mov;
end
rate = 0.25;
for increment=1:nFrames
	pause(rate)

	qd.propagate(prop_args);
	args = struct; args.var = 'q_hat'; args.value = qd.q;
	h = h.log(args);
	
	item = struct; item.name = 'q_hat0'; item.type = 'plot';
	data = struct; data.x = h.logs.q_hat(:,1); data.y = h.logs.q_hat(:,5); item.data = data;
	args = struct; args.action = 'updateseries'; args.graph = 'sim_q_propagation'; args.item = item;
	graphManager(args);
	for i = 1:3
		item = struct; item.name = sprintf('q_hat%d',i); item.type = 'plot';
		data = struct; data.x = h.logs.q_hat(:,1); data.y = h.logs.q_hat(:,i+1); item.data = data;
		args = struct; args.action = 'updateseries'; args.graph = 'sim_q_propagation'; args.item = item;
		graphManager(args);
	end
	if record_it
		mov(increment)=getframe(fh);
	end
end

if record_it
	movie2avi(mov,'filename.avi', 'COMPRESSION', 'Cinepak','FPS',floor(1/rate));
end