disp('Testing quaternion class')

tb = testBase;

%=======================================================================================
% Test intstance
%
q = quaternion();
tb.assertEquals(1, q.scalar, 'Default quaternion scalar');
tb.assertEquals([0 0 0]', q.vector, 'Default quaternion vector');

args = struct;
args.scalar = rand();
q = quaternion(args);
tb.assertEquals(args.scalar, q.scalar, 'Quaternion scalar set');
tb.assertEquals([0 0 0]', q.vector, 'Default quaternion vector');

args = struct;
args.vector = rand(3,1);
q = quaternion(args);
tb.assertEquals(1, q.scalar, 'Quaternion scalar set');
tb.assertEquals(args.vector, q.vector, 'Default quaternion vector');

args = struct;
args.vector = rand(3,1);
args.scalar = rand();
args.theta = rand();
q = quaternion(args);
tb.assertEquals(args.scalar, q.scalar, 'Quaternion scalar value chosen over theta');
tb.assertEquals(args.vector, q.vector, 'Quaternion vector set');

args = struct;
args.vector = rand(3,1);
args.theta = 32/180*pi;
q = quaternion(args);

t_vec = (args.vector / norm(args.vector)) * sin(-args.theta/2);
t_sca = cos(-args.theta/2);
tb.assertEquals(t_sca, q.scalar, 'From rotation has the correct scalar');
tb.assertEquals(t_vec, q.vector, 'From rotation has the correct vector');

%
% END Test intstance
%=======================================================================================

%=======================================================================================
% Test quaternion definitions
%

args = struct; args.vector = [1 0 0]'; args.scalar = 0;
i = quaternion(args);
args = struct; args.vector = [0 1 0]'; args.scalar = 0;
j = quaternion(args);
args = struct; args.vector = [0 0 1]'; args.scalar = 0;
k = quaternion(args);
args = struct; args.vector = [0 0 0]'; args.scalar = -1;
q_neg = quaternion(args);

testResult = i*i;
tb.assertEquals(q_neg,testResult,'i*i=-1');

testResult = j*j;
tb.assertEquals(q_neg,testResult,'j*j=-1');

testResult = k*k;
tb.assertEquals(q_neg,testResult,'k*k=-1');

testResult = i*j*k;
tb.assertEquals(q_neg,testResult,'i*j*k=-1');

testResult = i*j;
tb.assertEquals(k,testResult,'i*j=k');

testResult = j*k;
tb.assertEquals(i,testResult,'j*k=i');

testResult = k*i;
tb.assertEquals(j,testResult,'k*i=j');

%
% END Test quaternion definitions
%=======================================================================================

%=======================================================================================
% Test quaternion fromRotation
%

q_b = quaternion();
q_t = quaternion();

try
  q = q_b.fromRotation();
  tb.fail('An exception should have been thrown');
catch
  arg = 'vector';
  e_msg = sprintf('Missing "%s" argument in quaternion',arg);
  tb.assertErrorMsg(e_msg,lasterror.message,sprintf('Accurately rejected a missing argument "%s"',arg));
end

args = struct;
args.vector = rand(3,1);
try
  q = q_b.fromRotation(args);
  tb.fail('An exception should have been thrown');
catch
  arg = 'theta';
  e_msg = sprintf('Missing "%s" argument in quaternion',arg);
  tb.assertErrorMsg(e_msg,lasterror.message,sprintf('Accurately rejected a missing argument "%s"',arg));
end

for i=0:pi/4:2*pi
  args = struct;
  args.vector = rand(3,1);
  args.theta = i;
  q = q_b.fromRotation(args);

  q_t.vector = (args.vector / norm(args.vector)) * sin(-args.theta/2);
  q_t.scalar = cos(-args.theta/2);
  tb.assertEquals(q_t, q, sprintf('fromRotation produced the correct quaternion for angle %0.4f',i));
end

vec = rand(3,1);
args = struct;
args.vector = vec;
args.theta = pi/2;
q_1 = q_b.fromRotation(args);

args = struct;
args.vector = vec;
args.theta = pi/2 + 2*pi;
q_2 = q_b.fromRotation(args);
q_2.scalar = -q_2.scalar;
q_2.vector = -q_2.vector;

args = struct;
args.vector = vec;
args.theta = pi/2 - 4*pi;
q_3 = q_b.fromRotation(args);

tb.assertMaxError(q_1, q_2, 0.0001, 'Verifying full rotation');
tb.assertMaxError(q_1, q_3, 0.0001, 'Verifying full rotation');

%
% Test quaternion fromRotation
%=======================================================================================

%=======================================================================================
% Test quaternion toRotation
%

for e_theta = -5*pi:pi/4:5*pi
  
  vector = rand(3,1)*2 - 1;
  vector = vector / norm(vector);
  
  args = struct;
  args.vector = vector;
  args.theta = e_theta;
  
  q1 = quaternion(args);
  
  [r_vector, r_theta] = q1.toRotation();
  
  args2 = struct;
  args2.theta = r_theta;
  args2.vector = r_vector;
  
  q2 = quaternion(args2);
  
  q1.vector = round(q1.vector .* 10000000) ./ 10000000;
  q2.vector = round(q2.vector .* 10000000) ./ 10000000;
  q1.scalar = round(q1.scalar .* 10000000) ./ 10000000;
  q2.scalar = round(q2.scalar .* 10000000) ./ 10000000;
  
  msg = sprintf('Converted back and forth between angle and quaternion representation for a %0.1f degrees',e_theta/pi*180);
  tb.assertMaxError(q1,q2,0.1,msg);
end

%
% END Test quaternion toRotation
%=======================================================================================

%=======================================================================================
% quaternion multiplication
%

q = mock().gen_random_quaternion;
r = mock().gen_random_quaternion;

s = q * 3;

tb.assertEquals(q.scalar * 3, s.scalar, 'Scalar value of right product of scalar');
tb.assertEquals(q.vector * 3, s.vector, 'Vector value of right product of scalar');

s = 6 * q;

tb.assertEquals(q.scalar * 6, s.scalar, 'Scalar value of left product of scalar');
tb.assertEquals(q.vector * 6, s.vector, 'Vector value of left product of scalar');

s = q * r;

scalar = q.scalar * r.scalar - dot(q.vector, r.vector);
vector = q.vector * r.scalar + r.vector * q.scalar + cross(q.vector,r.vector);

tb.assertEquals(scalar, s.scalar, 'Checking scalar of quaternion');
tb.assertEquals(vector, s.vector, 'Checking vector of quaternion');

s2 = r * q;

tb.assertEquals(s.scalar, s2.scalar, 'Commutative does not effect scalar');
tb.assertEquals(3, sum(s.vector ~= s2.vector), 'Commutative have different vector values');
%
% END quaternion multiplication
%=======================================================================================

%=======================================================================================
% quaternion equality comparison
%

q = mock().gen_random_quaternion;
r = q.copy();

tb.assertEquals(true,q==r,'Quaternions are equal');
r.vector = r.vector .* 0.9;
tb.assertEquals(false,q==r,'Quaternions have unequal vectors');

r = q.copy();
r.scalar = 0.9 * r.scalar;
tb.assertEquals(false,q==r,'Quaternions have unequal scalars');

%
% END quaternion equality comparison
%=======================================================================================

%=======================================================================================
% quaternion >= comparison
%

q = mock().gen_random_quaternion;
r = q.copy();

tb.assertEquals(true, r>=q, '>= Equality holds');

r.scalar = r.scalar + 0.001;
tb.assertEquals(true, r>=q, '>= Equality holds');

r = q.copy();
r.vector(2) = r.vector(2) + 0.001;
tb.assertEquals(true, r>=q, '>= Equality holds');

r = q.copy();
r.scalar = r.scalar - 0.001;
tb.assertEquals(false, r>=q, '>= Equality does not hold');

r = q.copy();
r.vector(3) = r.vector(3) - 0.001;
tb.assertEquals(false, r>=q, '>= Equality does not hold');

%
% END quaternion >= comparison
%=======================================================================================

%=======================================================================================
% quaternion > comparison
%

q = mock().gen_random_quaternion;
r = q.copy();

tb.assertEquals(false, r>q, '> Equality holds');

r.scalar = r.scalar + 0.001;
tb.assertEquals(false, r>q, '> Equality holds');

r = q.copy();
r.scalar = r.scalar + 0.001;
r.vector = r.vector + 0.001;
tb.assertEquals(true, r>q, '> Equality holds');

r = q.copy();
r.scalar = r.scalar - 0.001;
tb.assertEquals(false, r>q, '> Equality does not hold');

r = q.copy();
r.vector = r.vector - 0.001;
tb.assertEquals(false, r>q, '> Equality does not hold');

%
% END quaternion > comparison
%=======================================================================================

%=======================================================================================
% quaternion <= comparison
%

q = mock().gen_random_quaternion;
r = q.copy();

tb.assertEquals(true, r<=q, '<= Equality holds');

r.scalar = r.scalar + 0.001;
tb.assertEquals(false, r<=q, '<= Equality holds');

r = q.copy();
r.vector(2) = r.vector(2) + 0.001;
tb.assertEquals(false, r<=q, '<= Equality holds');

r = q.copy();
r.scalar = r.scalar - 0.001;
tb.assertEquals(true, r<=q, '<= Equality does not hold');

r = q.copy();
r.vector(3) = r.vector(3) - 0.001;
tb.assertEquals(true, r<=q, '<= Equality does not hold');

%
% END quaternion >= comparison
%=======================================================================================

%=======================================================================================
% quaternion < comparison
%

q = mock().gen_random_quaternion;
r = q;

tb.assertEquals(false, r<q, '< Equality holds');

r.scalar = r.scalar - 0.001;
tb.assertEquals(false, r<q, '< Equality holds');

r = quaternion();
r.vector = q.vector;
r.scalar = q.scalar;
r.scalar = r.scalar - 0.001;
r.vector = r.vector - 0.001;
tb.assertEquals(true, r<q, '< Equality holds');

r = q;
r.scalar = r.scalar + 0.001;
tb.assertEquals(false, r<q, '< Equality does not hold');

r = q;
r.vector = r.vector + 0.001;
tb.assertEquals(false, r<q, '< Equality does not hold');

%
% END quaternion > comparison
%=======================================================================================

%=======================================================================================
% quaternion quotient
%

args = struct; args.vector = [18 -4 2]; args.scalar = -2;
q=quaternion(args);
args = struct; args.vector = [9 -2 1]; args.scalar = -1;
r=quaternion(args);
tb.assertEquals(r,q/2,'check quotient of quaternion / scalar');

try
  2/q;
  tb.fail('An exception should have been thrown');
catch
  e_msg = 'Attempt to reference field of non-structure array.';
  tb.assertErrorMsg(e_msg,lasterror.message,'Error thown when attempting to divide scalar / quaternion');
end

try
  q/q;
  tb.fail('An exception should have been thrown');
catch
  e_msg = 'Attempt to reference field of non-structure array.';
  tb.assertErrorMsg(e_msg,lasterror.message,'Error thown when attempting to divide quaternion / quaternion');
end

%
% END quaternion quotient
%=======================================================================================

%=======================================================================================
% quaternion sum
%

args = struct; args.vector = [3 -5 2]'; args.scalar = 3;
q=quaternion(args);
args = struct; args.vector = [1 4 -6]'; args.scalar = 1;
r=quaternion(args);

s=q+r;
args = struct; args.vector = [4 -1 -4]'; args.scalar = 4;
v=quaternion(args);
tb.assertEquals(v,s,'sum of two quaternions.');

try
  q + 3;
  tb.fail('An exception should have been thrown');
catch
  e_msg = 'Attempt to reference field of non-structure array.';
  tb.assertErrorMsg(e_msg,lasterror.message,'Error thown when attempting to sum a quaternion and a scalar');
end

try
  4 + q;
  tb.fail('An exception should have been thrown');
catch
  e_msg = 'Attempt to reference field of non-structure array.';
  tb.assertErrorMsg(e_msg,lasterror.message,'Error thown when attempting to sum a scalar and a quaternion');
end

%
% END quaternion sum
%=======================================================================================

%=======================================================================================
% quaternion difference
%

args = struct; args.vector = [3 -5 2]'; args.scalar = 3;
q=quaternion(args);
args = struct; args.vector = [1 4 -6]'; args.scalar = 1;
r=quaternion(args);

s=q-r;
args = struct; args.vector = [2 -9 8]'; args.scalar = 2;
v=quaternion(args);
tb.assertEquals(v,s,'difference of two quaternions.');

try
  q - 3;
  tb.fail('An exception should have been thrown');
catch
  e_msg = 'Attempt to reference field of non-structure array.';
  tb.assertErrorMsg(e_msg,lasterror.message,'Error thown when attempting to find the difference a quaternion and a scalar');
end

try
  4 - q;
  tb.fail('An exception should have been thrown');
catch
  e_msg = 'Attempt to reference field of non-structure array.';
  tb.assertErrorMsg(e_msg,lasterror.message,'Error thown when attempting to find the difference a scalar and a quaternion');
end

%
% quaternion difference
%=======================================================================================

%=======================================================================================
% quaternion negative
%

q = mock().gen_random_quaternion;

r = -q;

tb.assertEquals(-q.scalar, r.scalar, 'Scalar quantity is negated');
tb.assertEquals(-q.vector, r.vector, 'Vector quantity is negated');

%
% quaternion negative
%=======================================================================================

%=======================================================================================
% quaternion matrix
%

q = mock().gen_random_quaternion;

m = q.matrix();

tb.assertEquals([q.vector; q.scalar], m, 'Quaternion matrix assembled as [vector; scalar]');

%
% END quaternion matrix
%=======================================================================================

%=======================================================================================
% quaternion mag (norm)
%

q = mock().gen_random_quaternion;

tb.assertEquals(norm([q.vector; q.scalar]),q.mag,'Calculate the quaternion magnitude');

%
% END quaternion mag (norm)
%=======================================================================================

%=======================================================================================
% quaternion isunit
%

q = mock().gen_random_quaternion;
tb.assertEquals(true,q.isunit(),'Is a unit quaternion');

q.scalar = q.scalar * 1.1;
tb.assertEquals(false,q.isunit(),'Is not a unit quaternion');

args = struct;
args.threshold = 5;

q.scalar = 2;
q.vector = [2 2 2]';
tb.assertEquals(true,q.isunit(args),'Unit quaternion inside large threshold');

args = struct;
args.threshold = 3;
tb.assertEquals(false,q.isunit(args),'Unit quaternion not inside large threshold');

%
% END quaternion isunit
%=======================================================================================

%=======================================================================================
% quaternion isidentity
%

q = quaternion();
q.vector = [0 0 0]';
q.scalar = 1;
tb.assertEquals(true,q.isidentity(),'Identity is found');

q.vector = [2 2 2]';
q.scalar = 3;

args = struct;
args.threshold = 9;
tb.assertEquals(true,q.isidentity(args),'Identity for a large threshold');

args.threshold = 7;
tb.assertEquals(false,q.isidentity(args),'Not an identity for a large threshold');

%
% END quaternion isidentity
%=======================================================================================

%=======================================================================================
% quaternion normalize
%

args = struct; args.vector = [1 2 3]'; args.scalar = 5;
q = quaternion(args);

mag = q.mag();
q.normalize();

tb.assertEquals(args.scalar / mag, q.scalar, 'Scalar was normalized');
tb.assertEquals(args.vector ./ mag, q.vector, 'Vector was normalized');

q.scalar = 0;
q.vector = [0 0 0]';

q.normalize();

tb.assertEquals(4, isnan(q.scalar) + sum(isnan(q.vector)), 'Zero quaternion nans on normalize');

%
% END quaternion normalize
%=======================================================================================

%=======================================================================================
% quaternion conj
%

q = mock().gen_random_quaternion;
r = q.conj();

tb.assertEquals(q.scalar,r.scalar,'Conjugate does not switch scalar');
tb.assertEquals(-q.vector,r.vector,'Conjugate negates the vector');

%
% quaternion conj
%=======================================================================================

%=======================================================================================
% quaternion inverse
%

q = quaternion();
q.scalar = 5;
q.vector = [2 3 4]';

qi = q.inv();

mag = q.mag();

vec = -q.vector ./ (mag^2);
sca  = q.scalar / (mag^2);

r = quaternion();
r.vector = vec;
r.scalar = sca;

tb.assertEquals(r, qi, 'Inverse quaternion');

%
% END quaternion inverse
%=======================================================================================

%=======================================================================================
% quaternion cross product matrix
%

q = quaternion();
q.scalar = 333;
q.vector = [2 3 4]';

m = q.x();

r = [ 0            -q.vector(3)   q.vector(2); ...
      q.vector(3)            0   -q.vector(1); ...
     -q.vector(2)   q.vector(1)            0];

tb.assertEquals(r,m,'Cross product is good');

q.vector = zeros(3,1);
m = q.x();
tb.assertEquals(zeros(3),m,'Cross product is all zeros');

%
% END quaternion cross product matrix
%=======================================================================================

%=======================================================================================
% quaternion rmatrix
%

args = struct;
args.vector = [0 0 1]';
args.theta = pi/2;
q = quaternion(args);
m = q.rmatrix();

tb.assertMaxError([0 1 0]',m*[1 0 0]',0.1,'Rotated a point');
tb.assertMaxError([-1 0 0]',m*[0 1 0]',0.1,'Rotated a point');
tb.assertMaxError([0 0 1]',m*[0 0 1]',0.1,'Rotated a point');

args = struct;
args.vector = [1 0 0]';
args.theta = -pi/4;
q = quaternion(args);
m = q.rmatrix();

tb.assertMaxError([1 0 0]',m*[1 0 0]',0.1,'Rotated a point backwards');
tb.assertMaxError([0 1/sqrt(2) -1/sqrt(2)]',m*[0 1 0]',0.1,'Rotated a point backwards');

%
% END quaternion rmatrix
%=======================================================================================

%=======================================================================================
% quaternion rotate_points
%

args = struct;
args.vector = [0 0 1]';
args.theta = pi/2;
q = quaternion(args);

pts = q.rotate_points();
tb.assertEquals([],pts,'Empty set returned');

args = struct;
args.points = [
  1 0 0;
  0 1 0;
  0 0 1
  ];

pts = q.rotate_points(args);

r_pts = [
  0 1 0;
  -1 0 0;
  0 0 1
  ];

tb.assertMaxError(r_pts, pts, 0.1, 'Rotate a set of points');

args = struct;
args.vector = [1 0 0]';
args.theta = -pi/4;
q = quaternion(args);

args = struct;
args.points = [
  1 0 0;
  0 1 0
  ];

pts = q.rotate_points(args);

r_pts = [
  1 0 0;
  0 1/sqrt(2) -1/sqrt(2)
  ];

tb.assertMaxError(r_pts, pts, 0.1, 'Rotate a set of points negative angle');

%
% END quaternion rotate_points
%=======================================================================================

%=======================================================================================
% quaternion rotate_surf_points
%

q = quaternion();
try
  q.rotate_surf_points();
  tb.fail('An exception should have been thrown');
catch
  arg = 'x';
  e_msg = sprintf('Missing "%s" argument in quaternion',arg);
  tb.assertErrorMsg(e_msg,lasterror.message,sprintf('Accurately rejected a missing argument "%s"',arg));
end

args = struct;
args.x = [];

try
  q.rotate_surf_points(args);
  tb.fail('An exception should have been thrown');
catch
  arg = 'y';
  e_msg = sprintf('Missing "%s" argument in quaternion',arg);
  tb.assertErrorMsg(e_msg,lasterror.message,sprintf('Accurately rejected a missing argument "%s"',arg));
end

args.y = [];

try
  q.rotate_surf_points(args);
  tb.fail('An exception should have been thrown');
catch
  arg = 'z';
  e_msg = sprintf('Missing "%s" argument in quaternion',arg);
  tb.assertErrorMsg(e_msg,lasterror.message,sprintf('Accurately rejected a missing argument "%s"',arg));
end

args = struct;
args.vector = [0 0 1]';
args.theta = pi/2;
q = quaternion(args);

pts = q.rotate_points();
tb.assertEquals([],pts,'Empty set returned');

args = struct;
args.x = [1 0; 0 -1];
args.y = [0 1; 0 0];
args.z = [0 0; 1 0];

pts = q.rotate_surf_points(args);

r_args = struct;
r_args.x = [0 -1; 0 0];
r_args.y = [1 0; 0 -1];
r_args.z = [0 0; 1 0];

tb.assertMaxError(r_args.x, pts.x, 0.1, 'x values are rotated');
tb.assertMaxError(r_args.y, pts.y, 0.1, 'y values are rotated');
tb.assertMaxError(r_args.z, pts.z, 0.1, 'z values are rotated');

%
% END quaternion rotate_surf_points
%=======================================================================================

%=======================================================================================
% quaternion decompose
%

args = struct;
args.vector = [0 0 1]';
args.theta = pi/4;
qr = quaternion(args);

args = struct;
args.vector = [3 1 0]';
args.theta = pi/10;
qn = quaternion(args);

q = qn * qr;

[qn2, qr2] = q.decompose();

tb.assertMaxError(qn, qn2, 0.1, 'Decompose produced the nutation quaternion');
tb.assertMaxError(qr, qr2, 0.1, 'Decompose produced the rotation quaternion');

q = mock().gen_random_quaternion;

[qn, qr] = q.decompose();

qc = qn * qr;

tb.assertMaxError(q, qc, 0.1, 'Decomposed the quaternion and reconstruct');

%
% END quaternion decompose
%=======================================================================================

%=======================================================================================
% quaternion str
%

q = quaternion();
q.scalar = 4;
q.vector = [-1 3 0]';

tb.assertEquals('<-1.00000 +3.00000 +0.00000> +4.00000',q.str,'Verify string printout');

%
% END quaternion str
%=======================================================================================

%=======================================================================================
% quaternion latex
%

q = quaternion();
q.scalar = 4;
q.vector = [-1 3 0]';

tb.assertEquals('[-1.00000, 3.00000, 0.00000]^T, 4.00000',q.latex(),'compact LaTeX string');
tb.assertEquals('[-1.00000, 3.00000, 0.00000]^T, 4.00000',q.latex(true),'compact LaTeX string');
tb.assertEquals('\begin{bmatrix} -1.00000 \\ 3.00000 \\ 0.00000 \\ 4.00000 \end{bmatrix}',q.latex(false),'non-compact LaTeX string');

%
% END quaternion latex
%=======================================================================================
