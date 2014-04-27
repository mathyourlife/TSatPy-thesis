disp('Testing estimator class')

e = estimator();
tb=testBase;

tb.assertEquals(1,e.active.none,'Estimator type running "none" by default.');
tb.assertEquals(1,e.output.none,'Estimator type output "none" by default.');
tb.assertEquals(state(),e.state,'Estimator loads a default state.');
tb.assertEquals({'none','luenberger','pid','movingaveragefilter'},e.types,'Estimator types are correct');

% Run reset routine
e=e.reset();

args = struct; args.type = 'luenberger';
e=e.run(args);
tb.assertEquals(1,e.active.luenberger,'Estimator "luenberger" is running.');
args = struct; args.type = 'pid';
e=e.run(args);
tb.assertEquals(1,e.active.pid,'Estimator "pid" is running.');
args = struct; args.type = 'movingAverageFilter';
e=e.run(args);
tb.assertEquals(1,e.active.movingaveragefilter,'Estimator "movingAverageFilter" is running.');

args = struct; args.type = 'none';
e=e.stop(args);
tb.assertEquals(0,e.active.none,'Estimator "none" is stopped.');
args = struct; args.type = 'pid';
e=e.stop(args);
tb.assertEquals(0,e.active.pid,'Estimator "pid" is stopped.');

checktype = 'pid';
args = struct; args.type = checktype;
e=e.setoutput(args);
for i = 1:numel(e.types)
  if (strcmp(checktype,e.types(i)))
    shouldbe = 1;
  else
    shouldbe = 0;
  end
  tb.assertEquals(shouldbe,e.output.(char(e.types(i))),['Estimator "' char(e.types(i)) '" has the correct output setting.']);
end

%{
Test the main estimator class with the "none" estimator active.
Updates of any state should just be passed through the estimator
without modification.
%}

e=e.reset();
s=mock().gen_random_state;
args = struct; args.state = s;
e=e.update(args);
tb.assertEquals(s,e.state,'Estimator updates the "none" observer correctly');

%{
Test the main estimator class with just the moving average active.

Starting with a clean estimator.
Activate the moving average filter.
Set filter history length to 5.
Pass a random state and then 4 default states.
Pass a fifth default state should push out the first random state.
%}

e = estimator();

args = struct; args.type = 'movingAverageFilter';
e = e.setoutput(args);
e = e.run(args);
s_rand = mock().gen_random_state;

args = struct; args.state = s_rand;
e = e.update(args);

tb.assertEquals(s_rand, e.state,'First state passed in is the estimated state.');

args = struct;
args.state = state();
e = e.update(args);
e = e.update(args);
e = e.update(args);
e = e.update(args);

v_avg = s_rand.q.vector / 5;
s_avg = (s_rand.q.scalar + 4) / 5;
w_avg = s_rand.w.w / 5;
args = struct;
args.vector = v_avg;
args.scalar = s_avg;
q = quaternion(args);
args = struct; args.w = w_avg;
br = bodyRate(args);
args = struct;
args.q = q;
args.w = br;
s = state(args);

tb.assertMaxError(s, e.state, 0.5,'The moving average calucation is correct.');

args = struct; args.state = state();
e = e.update(args);
tb.assertEquals(state(), e.state,'After 6th update the first state is pushed out of the window.');

