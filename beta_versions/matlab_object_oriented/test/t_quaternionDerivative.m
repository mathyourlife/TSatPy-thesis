disp('Testing quaternion derivative class')

tb = testBase;

global t
start_time = t.now();
qd = quaternionDerivative();

args = struct; args.vector = [0 0 0]; args.scalar = 0;
tb.assertEquals(quaternion(args), qd.value,'Validate initial value.');

wait = 2*rand()+2;
pause(wait)
q = mock().gen_random_quaternion;
args = struct; args.value = q;
end_time = t.now();
qd = qd.update(args);

tb.assertMaxError(q / (end_time - start_time), qd.value, 0.5, 'Check quaternion derivative.');
