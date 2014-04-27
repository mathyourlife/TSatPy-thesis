function r = testCompareQuaternionAndEulerMatrices();
  disp('Testing relationship between Quaternion and Euler rotations')
  
  tb=testBase;

  a1 = pi/6;
  a2 = pi/8;
  a3 = pi/8;
  
  default = {};
  args = struct; args.seq = 1; args.axis = 3; args.angle = a1;
  default = arr_push(default, args);
  args = struct; args.seq = 2; args.axis = 1; args.angle = a2;
  default = arr_push(default, args);
  args = struct; args.seq = 3; args.axis = 3; args.angle = a3;
  default = arr_push(default, args);
  ea = eulerAngles(default);
  disp('Euler Rotations')
  disp(ea.str)
  disp('Euler Rotation matrix')
  eam = ea.rmatrix;
  disp(eam)

  disp('Quaternion Rotations');
  args = struct; args.vector = [0 0 1]; args.theta = a1;
  q1 = quaternion(args);
  disp(q1.str);
  args = struct; args.vector = [1 0 0]; args.theta = a2;
  q2 = quaternion(args);
  disp(q2.str);
  args = struct; args.vector = [0 0 1]; args.theta = a3;
  q3 = quaternion(args);
  disp(q3.str);

  disp(' ')
  disp('Resultant Quaternion');
  qt = q3*q2*q1;
  disp(qt.str);
  disp('Quaternion Rotation Matrix');
  qtm = qt.rmatrix;
  disp(qtm);

  disp('Error Matrix')
  em = (eam-qtm)./max(max(qtm));
  disp(em);
  disp('Max Error')
  maxerror = max(max(em))

  tb.assertLessThan(maxerror,1E-10,'Check difference between quaternion and Euler rotation matrices');
end