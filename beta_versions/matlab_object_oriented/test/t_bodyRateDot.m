disp('Testing bodyRateDot class')

tb = testBase;

br_dot = bodyRateDot();

tb.assertEquals([0 0 0]',br_dot.w,'BodyRateDot was initialized with the correct vector.');

args = struct;
args.w = rand(3,1);
br_dot = bodyRate(args);

tb.assertEquals(args.w, br_dot.w, 'BodyRateDot was instantiated with the correct vector.');
