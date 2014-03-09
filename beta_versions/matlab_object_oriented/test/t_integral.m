disp('Testing integral class')

global t;

i = integral();
tb=testBase;

tb.assertEquals(0,i.sum,'Default integral value.');

start_time = t.now();
i = i.reset();
wait = 3*rand()+0.5;
pause(wait)
value = 10;
args = struct;
args.value = value;
end_time = t.now();
i = i.update(args);
tb.assertMaxError((end_time-start_time) * value,i.sum,0.5,sprintf('Integral value after %0.3f seconds at a value of %d.',wait,value));

t.speed = 4;
start_time = t.now();
i = i.reset();
wait = 3*rand()+0.5;
pause(wait)
value = 10;
args = struct;
args.value = value;
end_time = t.now();
i = i.update(args);
tb.assertMaxError((end_time-start_time) * value,i.sum,0.5,sprintf('Integral value after %0.3f real seconds with the system clock at 4x at a value of %d.',wait,value));
t.speed = 1;

start_time = t.now();
i = i.reset();
wait = 3*rand()+0.5;
pause(wait)
value=[1 2; 3 4];
args = struct;
args.value = value;
end_time = t.now();
i = i.update(args);
tb.assertMaxError((end_time-start_time) * value,i.sum,0.5,'Integral of a matrix value.');
