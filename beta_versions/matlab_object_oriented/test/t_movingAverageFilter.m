disp('Testing body rate integral class')

ma = movingAverageFilter();
tb=testBase;

tb.assertEquals(5, ma.avgLen,'Validate initial value of filter length.');
tb.assertEquals(state(), ma.state,'Validate initial moving avg state.');

m = mock();
s_1 = m.gen_random_state;

args = struct; args.state = s_1;
ma = ma.update(args);
tb.assertEquals(s_1, ma.state,'First state passed in is the estimated state.');

s=state();
args = struct;
args.state = s;
ma = ma.update(args);
ma = ma.update(args);
ma = ma.update(args);
ma = ma.update(args);

s_2 = s_1 / 5;
s_2.q.scalar = (s_1.q.scalar + 4) / 5;

tb.assertMaxError(s_2, ma.state, 0.5,'The moving average calucation is correct.');

args = struct; args.state = state();
ma = ma.update(args);
tb.assertEquals(state(), ma.state,'After 6th update the first state is pushed out of the window.');
