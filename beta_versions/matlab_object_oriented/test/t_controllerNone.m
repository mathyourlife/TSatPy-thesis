disp('Testing None Controller class')

c = controllerNone();
tb=testBase;

tb.assertEquals([0 0 0]',c.M,'Default moment value.');
tb.assertEquals(state(),c.state,'Default state value.');

% Mess up the class then reset
m = mock();
c.M = [1 2 3]';
c.state = m.gen_random_state;

c = c.reset();

tb.assertEquals([0 0 0]',c.M,'Moment value was reset.');
tb.assertEquals(state(),c.state,'State value was reset.');

try
	c = c.update();
	tb.fail('An exception should have been thrown');
catch
	msg = lasterror.message;
	e_msg = 'Missing "state" argument in controllerNone';
	tb.assertErrorMsg(e_msg,msg,'Did not specify the state on the none controller');
end

s = m.gen_random_state;
args = struct; args.state = s;
c = c.update(args);

tb.assertEquals(s,c.state,'Update sets the state correctly');
tb.assertEquals([0 0 0]',c.M,'Update zeros out the moment');
