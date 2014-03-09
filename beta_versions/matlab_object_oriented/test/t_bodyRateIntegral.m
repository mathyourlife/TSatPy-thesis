disp('Testing body rate integral class')

args = struct; args.w = [0 0 0]';
w = bodyRate(args);
tb=testBase;

global t
start_time = t.now();
bri = bodyRateIntegral();

tb.assertEquals(w, bri.value,'Validate initial value.');

bri.reset();
wait = 3*rand()+0.5;
pause(wait)
w = mock().gen_random_body_rate;
args = struct; args.value = w;
end_time = t.now();
bri = bri.update(args);

tb.assertMaxError(w * (end_time - start_time), bri.value, 2, 'Check integral of quaternion vector.');
