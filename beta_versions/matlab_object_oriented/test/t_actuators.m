disp('Testing actuators class')

tb = testBase;

% Establish thruster arrangement
thrusters = struct;

args = struct;
args.center = [2 2 0]';
% thrust pushes down and to the right (when viewed from the x-y plane)
% causing a positive rotation about z.
args.direction = [1 -1 0]';
args.name = 'test_thruster';
thrusters.test_thruster = thruster(args);

args.thrusters = thrusters;
a = actuators(args);

tb.assertEquals([0 0 0]',a.requested_moment,'Actuators have no initial requested moment');
tb.assertEquals([0 0 0]',a.effective_moment,'Actuators have no initial effective moment');

f = fieldnames(a.thrusters);

tb.assertEquals(1,numel(f),'Single thruster was mounted');

try
  a = a.requestMoment();
  tb.fail('An exception should have been thrown');
catch
  msg = lasterror.message;
  e_msg = 'Missing "M" argument in actuators';
  tb.assertErrorMsg(e_msg,msg,'Did not request a moment torque from the actuators.');
end

args = struct;
args.M = [0 0 10]';
a = a.requestMoment(args);

tb.assertEquals(args.M,a.requested_moment,'Actuators have the right requested moment');
tb.assertEquals(args.M,a.effective_moment,'Actuators have the right effective moment');

args = struct;
args.M = [0 0 -10]';
a = a.requestMoment(args);

tb.assertEquals(args.M,a.requested_moment,'Actuators have the right requested moment');
tb.assertEquals([0 0 0]',a.effective_moment,'No mounted thruster has the ability to thrust in the requested direction');
