disp('Testing quaternion integral class')

args = struct; args.vector = [0 0 1]'; args.scalar = 0;
k = quaternion(args);
tb=testBase;

global t
start_time = t.now();
qi = quaternionIntegral();

args = struct; args.vector = [0 0 0]; args.scalar = 0;
tb.assertEquals(quaternion(args), qi.value,'Validate initial value.');

wait = 3*rand()+2;
pause(wait)
q = mock().gen_random_quaternion;
args = struct; args.value = q;
qi = qi.update(args);
end_time = t.now();

tb.assertMaxError(q * (end_time - start_time), qi.value, 0.5, 'Check integral of quaternion.');
