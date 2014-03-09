%function t_plant_jacobian()
return;
disp('Testing Jacobian')

tb=testBase;

I1 = 1; I2 = 2; I3 = 4;

args = struct; args.I = [I1 0 0; 0 I2 0; 0 0 I3];
p = plant(args);
start_time = t.now();
disp('Original Plant State')
disp(p.state.str)

pause(3)

M = 8;
args = struct; args.M = [0 0 M]';
p.propagate(args);
sleep_time = t.now() - start_time;


disp('Next Plant State')
disp(p.state.str)

j = p.jacobian();

w3 = M / I3 * sleep_time;

exp_jacobian = zeros(7);
exp_jacobian(1, 2) = -w3;
exp_jacobian(2, 1) = w3;
exp_jacobian(3, 4) = w3;
exp_jacobian(4, 3) = -w3;
exp_jacobian(5, 6) = (I3-I2)/I1*(M/I3*sleep_time);
exp_jacobian(6, 5) = (I1-I3)/I2*(M/I3*sleep_time);

tb.assertMaxError(exp_jacobian, j.matrix, 1, 'Jacobian');