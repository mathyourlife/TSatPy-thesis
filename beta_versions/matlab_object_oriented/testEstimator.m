
disp('Depricated')
return;
%Testing estimator

% qdot = q(n+1) - q(n) / delta t
% w = 2*(qs * qdotv - qv * qdots) - 2 qx * qdotv
% wxdot = (Iy-Iz)/Ix) wy wz
% wydot = (Iz-Ix)/Iy) wx wz
% wzdot = (Ix-Iy)/Iz) wx wy
 
% Plant
% qdotv = 1/2 ( qx * w + qs * w)
% qdots = -1/2 (q^T w)

% wxdot = (Iy-Iz)/Ix) wy wz
% wydot = (Iz-Ix)/Iy) wx wz
% wzdot = (Ix-Iy)/Iz) wx wy

%util quaternion
disp('test conversion to euler for rates')
disp('1/4 turn around z')
args = struct; args.vector = [0 0 1]'; args.theta = pi/2;
q=quaternion(args);
disp(q.str);
disp('quaternion rotation matrix')
disp(q.rmatrix)
e = q.euler;




return;
wztrue = 2*pi*3/60;

disp('Setting Initial Conditions')
args = struct; args.vector = [0 0 1]; args.theta = wztrue;
estimator.qhat=quaternion(args);
args = struct; args.w = [0 0 wztrue];
estimator.what=bodyRate(args);
%args = struct; args.q = estimator.qhat; args.w = estimator.what;
%estimator.xhat = state(args);
disp(estimator.qhat.str)
disp(estimator.what.str)
estimator.I = eye(3);

estimator.lastUpdateTime=now*24*3600;

pause(0.3)

disp(' ')
disp('Beginning estimator state update script')
curtime=now*24*3600;

disp(' ')
disp('Updating plant state change estimates')
% qdotv = 1/2 ( qx * w + qs * w)
% qdots = -1/2 (q^T w)
qpdotv = 1/2 * (estimator.qhat.x*estimator.what.w + estimator.qhat.scalar*estimator.what.w);
qpdots = -1/2 * (estimator.qhat.vector'*estimator.what.w);
args = struct; args.vector = qpdotv; args.scalar = qpdots;
estimator.plant.qdot = quaternion(args);
disp(estimator.plant.qdot.str)
disp(estimator.plant.qdot.mag)

% wxdot = (Iy-Iz)/Ix) wy wz
% wydot = (Iz-Ix)/Iy) wx wz
% wzdot = (Ix-Iy)/Iz) wx wy
Ix = estimator.I(1,1);
Iy = estimator.I(2,2);
Iz = estimator.I(3,3);
wx = estimator.what.w(1);
wy = estimator.what.w(2);
wz = estimator.what.w(3);

wpdotx = (Iy - Iz)/Ix * wy * wz;
wpdoty = (Iz - Ix)/Iy * wx * wz;
wpdotz = (Ix - Iy)/Iz * wx * wy;

args = struct; args.w = [wpdotx wpdoty wpdotz];
estimator.plant.wdot = bodyRate(args);
disp(estimator.plant.wdot.str)
return;

disp('Setting next sensor reading')
args = struct; args.vector = [0 0 1]; args.theta = 2*pi/8;
sensor.q = quaternion(args);
disp(sensor.q.str)



disp(' ')
disp('Calculating quaternion rate change measured')
td = estimator.lastUpdateTime-curtime;
disp(sprintf('delta t = %0.4f',td))
sensor.deltaq = sensor.q - estimator.qhat;
disp(sprintf('delta q = %s',sensor.deltaq.str))
args = struct; args.vector = sensor.deltaq.vector/td; args.scalar = sensor.deltaq.scalar/td;
estimator.sensor.qdot = quaternion(args);
disp(sprintf('delta q/t = %s',estimator.sensor.qdot.str))
disp(sprintf('|delta q/t| = %0.4f',estimator.sensor.qdot.mag))


disp(' ')
disp('Combining for estimator xdot')
estimator.qdot = estimator.plant.qdot + estimator.sensor.qdot;
disp(estimator.qdot.str)
estimator.wdot = estimator.plant.wdot; % + input force?	
disp(estimator.wdot.str)

disp(' ')
disp('Updating estimator state estimate')
estimator.qhat = estimator.qhat * estimator.qdot;
estimator.what = estimator.what + estimator.wdot;
args = struct; args.q = estimator.qhat; args.w = estimator.what;
estimator.xhat = state(args);
disp(estimator.xhat.str);