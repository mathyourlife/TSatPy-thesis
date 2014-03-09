disp('Testing Luenberger Observer class')

l = observerLuenberger();
tb = testBase;

tb.assertEquals(state(),l.state,'Default state value.');

args = struct;
update_state = mock().gen_random_state;
args.state = update_state;
args.plant_state = state();
l = l.update(args);

tb.assertMaxError(update_state,l.state,0.001,'Luenberger updates state with gains of 1');

l = l.reset();

l.Kq.Kv = [3 0 0; 0 4 0; 0 0 5];
l.Kq.Ks = 2;
l.Kw.K = rand(3) .* eye(3);

args = struct;
update_state = mock().gen_random_state;
args.state = update_state;
args.plant_state = state();
l = l.update(args);

s = l.Kq.Ks * update_state.q.scalar;
v = l.Kq.Kv * update_state.q.vector;
args = struct; args.vector = v; args.scalar = s;
q = quaternion(args);
q.normalize();

tb.assertMaxError(q, l.state.q, 0.5, 'Luenberger updates has correct quaternion with gains <> 1');
tb.assertMaxError(l.Kw.K*update_state.w.w, l.state.w.w, 0.5, 'Luenberger updates has correct body rate with gains <> 1');

