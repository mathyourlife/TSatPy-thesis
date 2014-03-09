disp('Demonstrate decomposition of a quaternion')

%Build a resultant quaternion from two known rotational 
%quaternions through quaternion multiplication.

% Rotational quaternion
qr_args = struct;
qr_args.vector = [0 0 1]';
qr_args.theta = -135/180*pi;
q_r = quaternion(qr_args);

% Nutation quaternion
qn_args = struct;
qn_args.vector = [0 1 0]';
qn_args.theta = 45/180*pi;
q_n = quaternion(qn_args);

q_arr = {};
q_arr{1} = q_r;
q_arr{2} = q_n;
visualizeQuaternion(q_arr);

% Craete resultant quaternion 
q = q_n * q_r;

disp('Demonstrating a single quaternion rotation')
q_arr = {};
q_arr{1} = q;
visualizeQuaternion(q_arr);

%{
pause(2)

[q_n2, q_r2] = q.decompose();
q_arr = {};
q_arr{1} = q_r2;
q_arr{2} = q_n2;
visualizeQuaternion(q_arr);
%}

