disp('Testing hist class')

h = hist();
tb=testBase;

tb.assertEquals(0,numel(h.logs),'history has an empty values structure');

args = struct;
args.var = 'my_scalar';
args.value = 3;
h = h.log(args);

tb.assertEquals(3,h.logs.my_scalar(:,2),'single scalar value in history');

args.value = -5;
h = h.log(args);

tb.assertEquals([3; -5],h.logs.my_scalar(:,2),'multiple scalar values in history');

h.historylen = 5;
for i = 1:20
  h = h.log(args);
end

tb.assertEquals(5,size(h.logs.my_scalar,1),'checking history length is observed for scalar history');

args = struct;
args.var = 'my_vector';
args.value = [1 2 3 4];
h = h.log(args);

tb.assertEquals([1 2 3 4],h.logs.my_vector(:,2:end),'single vector history');

h = h.log(args);

tb.assertEquals([1 2 3 4; 1 2 3 4],h.logs.my_vector(:,2:end),'multiple vector values in history');

args.value = [5 5 5 5]';
h = h.log(args);

tb.assertEquals([1 2 3 4; 1 2 3 4; 5 5 5 5],h.logs.my_vector(:,2:end),'flip a vector to record');

args = struct;
args.var = 'my_q';
q_args = struct;
q_args.scalar = 5;
q_args.vector = [3 12 2];
args.value = quaternion(q_args);
h=h.log(args);

tb.assertEquals([3 12 2 5],h.logs.my_q(:,2:end),'log a quaternion value');

args = struct;
args.var = 'my_w';
w_args = struct;
w_args.w = [4 6 8];
args.value = bodyRate(w_args);
h=h.log(args);

tb.assertEquals([4 6 8],h.logs.my_w(:,2:end),'log a body rate value');

args = struct;
args.var = 'my_state';
s=state();
s.q=quaternion(q_args);
s.w=bodyRate(w_args);
args.value = s;
h=h.log(args);

tb.assertEquals([3 12 2 5 4 6 8],h.logs.my_state(:,2:end),'log a state value');

