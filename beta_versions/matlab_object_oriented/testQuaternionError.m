args = struct; args.vector = [0,0,1]; args.scalar = 0;
q_hat=quaternion(args);

args = struct; args.vector = [1,0,1]; args.theta = 2*pi/360*90;
q_meas=quaternion(args);

% Calculate the error quaternion
e = q_meas.conj * q_hat;

% Ensure that numerical drift gets normalized back to a unit vector.
e.normalize();

disp(sprintf('q_hat = %s',q_hat.str))
disp(sprintf('q_meas = %s',q_meas.str))
disp(sprintf('e = %s',e.str))

disp('Check error quaternion')
n = q_meas * e;
disp(sprintf('q_meas * e = q_hat = %s',n.str))
n = e * q_hat;
disp(sprintf('e * q_hat = q_meas = %s',n.str))

args = struct;
args.q_hat = q_hat;
args.q = q_meas;
e = quaternionError(args);
disp(sprintf('e = %s',e.str))
