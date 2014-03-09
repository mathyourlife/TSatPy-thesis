disp('Testing derivative class')

d = derivative();
tb=testBase;

tb.assertEquals(0,d.rate,'Default derivative rate value.');
tb.assertEquals(0,d.lastValue,'Default derivative last value.');

d = d.reset();
pause(2)
args = struct;
args.value = 10;
d = d.update(args);
rate = d.rate;
tb.assertMaxError(5,rate,0.5,'Derivative value from 0 to 10 after 2 seconds.');

global t
t.speed = 4;
d = d.reset();
pause(2)
args = struct;
args.value = 10;
d = d.update(args);
rate = d.rate;
tb.assertMaxError(5/4,rate,0.5,'Derivative value after 2 real seconds with the clock sped up 4x and value updated from 0 to 10.');
t.speed = 1;

d = d.reset();
pause(2)
val = [10 20; 30 40];
args = struct;
args.value = val;
d = d.update(args);
rate = d.rate;
tb.assertMaxError(val/2,rate,0.5,'Derivative for a matrix value.');
