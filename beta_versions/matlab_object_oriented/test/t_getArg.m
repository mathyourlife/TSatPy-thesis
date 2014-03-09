disp('Testing getArg utility')

tb=testBase;

args = struct;
args.n = 3;
args.new = 1;
args.newer = 14;
r = getArg(args,'new');
tb.assertEquals(1,r,'getting an int returned correct value');

args = struct;
args.new = 1;
try
	r = getArg(args,'new_one');
	tb.fail('An exception should have been thrown');
catch
	msg = lasterror.message;
	e_msg = 'Missing "new_one" argument';
	tb.assertErrorMsg(e_msg,msg,'Did not request a moment torque from the actuators.');
end

args = struct;
args.new.sub = 1;
r = getArg(args.new,'sub');
tb.assertEquals(1,r,'getting an sub field returned correct value');

args = struct;
args.new = {'some','cell','array'};
r = getArg(args,'new');
tb.assertEquals({'some','cell','array'},r,'getting a cell array value');

args = struct;
args.new = 1;
r = getArg(args,'new_one','this is default');
tb.assertEquals('this is default',r,'getArg returns a default');
