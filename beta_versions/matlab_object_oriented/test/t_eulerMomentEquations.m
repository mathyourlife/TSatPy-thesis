disp('Testing Euler Moment Equations class')

global t
tb = testBase;

% Start with defaut initialization values for the Euler Moment Equations.
args = struct;
args.I = [1.2 0 0; 0 4.3 0; 0 0 7.6];
create_time = t.now();
e = eulerMomentEquations(args);

tb.assertEquals(bodyRate(),e.w,'Default body rate loaded');
tb.assertEquals(bodyRateDot(),e.w_dot,'Default body rate dot loaded');
tb.assertBetween(create_time,t.now(),e.lastUpdate,'Set last update time to the current global clock');
tb.assertEquals(args.I,e.I,'Inertia tensor is loaded correctly');

e = e.propagate();

tb.assertEquals(bodyRate(),e.w,'Propagate w/ no force. Zero body rate.');
tb.assertEquals(bodyRateDot(),e.w_dot,'Propagate w/ no force. Zero body rate dot.');


% Initialize the Euler Moment Equations with a body rate and propagate with no applied force.
args = struct;
args.I = [1.2 0 0; 0 4.3 0; 0 0 7.6];
m = mock();
args.w = m.gen_random_body_rate;
start_time = t.now();
e = eulerMomentEquations(args);

tb.assertEquals(args.w,e.w,'Initialize with a set non-zero body rate');

pause(3*rand()+0.5)

end_time = t.now();
e = e.propagate();

w_dot_calc = [];
w_dot_calc(1,1) = -(e.I(3,3) - e.I(2,2)) * args.w.w(2) * args.w.w(3) / e.I(1,1);
w_dot_calc(2,1) = -(e.I(1,1) - e.I(3,3)) * args.w.w(1) * args.w.w(3) / e.I(2,2);
w_dot_calc(3,1) = -(e.I(2,2) - e.I(1,1)) * args.w.w(1) * args.w.w(2) / e.I(3,3);

tb.assertEquals(w_dot_calc,e.w_dot.w,'Unforced propagation of an initial body rate dot.');
w_new = args.w.w + (end_time - start_time) * w_dot_calc;
tb.assertEquals(w_new,e.w.w,'Unforced propagation of an initial body rate.');

% Initialize the Euler Moment Equations with a body rate and propagate with no applied force.
args = struct;
args.I = [1.2 0 0; 0 4.3 0; 0 0 7.6];
start_time = t.now();
e = eulerMomentEquations(args);

pause(3*rand()+0.5)
args = struct;
args.M = [-1 2.1 3.4]';
end_time = t.now();
e = e.propagate(args);

w_dot_calc = [];
w_dot_calc(1,1) = args.M(1) / e.I(1,1);
w_dot_calc(2,1) = args.M(2) / e.I(2,2);
w_dot_calc(3,1) = args.M(3) / e.I(3,3);

tb.assertEquals(w_dot_calc,e.w_dot.w,'Forced propagation of an initial body rate dot.');
w_new = (end_time - start_time) * w_dot_calc;
tb.assertEquals(w_new,e.w.w,'Forced propagation of an initial body rate.');
