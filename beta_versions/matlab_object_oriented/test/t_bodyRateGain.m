disp('Testing bodyRateGain class')

tb = testBase;
brg = bodyRateGain();

tb.assertEquals(eye(3),brg.K,'Body rate gain has the initial value.');

br = mock().gen_random_body_rate;
r = brg * br;

tb.assertEquals(br,r,'Multiplied a random body rate by a identity body rate gain.');

args = struct;
args.K = rand(3,3);
brg = bodyRateGain(args);

br = mock().gen_random_body_rate;
r = brg * br;

args_check = struct;
args_check.w = args.K * br.w;
br_check = bodyRate(args_check);

tb.assertEquals(br_check, r, 'Multiplied a random body rate by a non-identity body rate gain.');
