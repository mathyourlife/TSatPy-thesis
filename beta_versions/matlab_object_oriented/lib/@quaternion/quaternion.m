classdef quaternion < handle
%QUATERNION - quaternion class for attitude representation
%
%You can define a quaternion by specifying the vector and scalar
%values.  If the scalar is not provided, a theta can be specified
%to create a quaternion based on a the specified rotation
%about a axis.
%
% Properties:
% @vector
%   value - Vector portion of the quaternion
%   type  - 3x1 matrix double
% @scalar
%   value - Scalar portion of the quaternion
%   type  - double
%
% Input:
% @args
%   value - args structure of field => values
%   type  - struct
%   @.vector (optional default [0 0 0]')
%     value - Define the vector portion of the quaternion
%     type  - 3x1 matrix double
%   @.scalar (optional default 1)
%     value - Define the scalar portion of the quaternion
%     type  - double
%   @.theta - If scalar value is not provided the vector and theta
%             can be passed to the .fromRotation method to create a
%             rotational quaternion from these values.
%
% Return:
% @self
%   value - instance of a quaternion class
%   type  - quaternion

  properties
    vector
    scalar
  end

  methods
    % Class construction method
    function self = quaternion(args)
      if (nargin == 0); args = struct; end

      try
        self.vector = makeVec(args.vector);
      catch
        self.vector = [0 0 0]';
      end

      self.scalar = 1;
      % Use the scalar value for the quaternion or create
      % using the fromRotation if theta passed.
      try
        self.scalar = args.scalar;
        return;
      catch
      end

      % Scalar value was not defined, see if there
      % was a theta specified.
      try
        r_args = struct;
        r_args.vector = self.vector;
        r_args.theta = args.theta;
        self = self.fromRotation(r_args);
      catch
      end
    end

    %Create a quaternion that represents the rotation parameters passed
    %NOTE:  direction specifies if the frame of reference is
    %       rotating or if the points are rotating with
    %-theta is for the rotation of the coordinate axes
    %+theta is for the rotation of points with respect to the fixed coordinate axes
    function q = fromRotation(self, args)
      if (nargin == 1); args = struct; end

      try
        vec = makeVec(args.vector);
        vec = vec/sqrt(vec(1)^2 + vec(2)^2 + vec(3)^2);
      catch
        error('Missing "vector" argument in %s',mfilename())
      end

      try
        theta = args.theta;
      catch
        error('Missing "theta" argument in %s',mfilename())
      end

      vector = vec*sin(-theta/2);
      scalar = cos(-theta/2);
      args = struct; args.vector = vector; args.scalar = scalar;
      q = quaternion(args);
    end

    %From the current quaternion instance, calculate an equivalent
    %rotation that would result in this quaternion.
    function [vector, theta] = toRotation(self)
      theta = acos(self.scalar) * 2;
      vector = -self.vector/sin(theta/2);
    end

    % Calculate the product of the two quaternions.
    % THIS FUNCTION IS NOT COMMUTATIVE!
    function q = mtimes(a,b)
      if isa(a,'quaternion') && isa(b,'quaternion')
        av = a.vector;
        bv = b.vector;
        s = a.scalar * b.scalar - (av(1)*bv(1)+av(2)*bv(2)+av(3)*bv(3));
        v = av * b.scalar + bv * a.scalar + cross(av,bv);
      elseif isa(a,'quaternion')
        s = a.scalar * b;
        v = a.vector * b;
      elseif isa(b,'quaternion')
        s = b.scalar * a;
        v = b.vector * a;
      end
      args = struct; args.scalar = s; args.vector = v;
      q = quaternion(args);
    end

    % Determine if the two quaternions are equivalent
    % Equivalent quaternions have equivalent scalar and vector components
    function b = eq(q1, q2)
      b = q1.scalar == q2.scalar & (sum(q1.vector == q2.vector) == 3);
    end

    % Only really used for test cases.
    % quaternion q1 >= quaternion q2 if
    %    q1.vector >= q2.vector
    %    q1.scalar >= q2.scalar
    function b = ge(q1, q2)
      b = q1.scalar >= q2.scalar & (sum(q1.vector >= q2.vector) == 3);
    end

    % Only really used for test cases.
    % quaternion q1 > quaternion q2 if
    %    q1.vector > q2.vector
    %    q1.scalar > q2.scalar
    function b = gt(q1, q2)
      b = q1.scalar > q2.scalar & (sum(q1.vector > q2.vector) == 3);
    end

    % Only really used for test cases.
    % quaternion q1 < quaternion q2 if
    %    q1.vector < q2.vector
    %    q1.scalar < q2.scalar
    function b = lt(q1, q2)
      b = q1.scalar < q2.scalar & (sum(q1.vector < q2.vector) == 3);
    end

    % Only really used for test cases.
    % quaternion q1 <= quaternion q2 if
    %    q1.vector <= q2.vector
    %    q1.scalar <= q2.scalar
    function b = le(q1, q2)
      b = q1.scalar <= q2.scalar & (sum(q1.vector<=q2.vector) == 3);
    end

    % Calculate the quotient of the quaternion and a scalar.
    function q = mrdivide(a, b)
      vector = a.vector / b;
      scalar = a.scalar / b;
      args = struct; args.vector = vector; args.scalar = scalar;
      q = quaternion(args);
    end

    % Calculate the sum of two quaternions.
    function q = plus(a, b)
      vector = a.vector + b.vector;
      scalar = a.scalar + b.scalar;
      args = struct; args.vector = vector; args.scalar = scalar;
      q = quaternion(args);
    end

    % Calculate the sum of two quaternions.
    function q = minus(a, b)
      vector = a.vector - b.vector;
      scalar = a.scalar - b.scalar;
      args = struct; args.vector = vector; args.scalar = scalar;
      q = quaternion(args);
    end

    % Calculate the sum of two quaternions.
    function q = uminus(a)
      vector = -a.vector;
      scalar = -a.scalar;
      args = struct; args.vector = vector; args.scalar = scalar;
      q = quaternion(args);
    end

    %Create a matrix by concatenating the vector and
    %scalar portions.  NOTE: IN SOME APPLICATIONS THE SCALAR
    %AND VECTOR ORDER CAN BE REVERSED.
    function q_matrix = matrix(self)
      q_matrix = [self.vector; self.scalar];
    end

    % Determine the norm of the quaternion
    function m = mag(self)
      v=self.vector;
      s=self.scalar;
      m = sqrt(v(1)^2 + v(2)^2 + v(3)^2 + s^2);
    end

    % Is the quaternion a unit quaternion?  Norm == 1
    function b = isunit(self, args)
      if (nargin == 1); args = struct; end

      try
        threshold = args.threshold;
      catch
        threshold = 1e-012;
      end

      b = (abs(self.mag - 1) < threshold);
    end

    %Is the quaternion the identity quaternion? scalar = 1 and
    %vector = <0 0 0> s = s * q_i = q_i * s
    function u = isidentity(self,args)
      if (nargin == 1); args = struct; end

      try
        threshold = args.threshold;
      catch
        threshold = 1e-012;
      end

      % With rounding error, set the threshold
      error = abs(self.scalar - 1) + sum(abs(self.vector));
      u = error < threshold;
    end

    % Scale the quaternion up/down to a unit quaternion
    function normalize(self)
      m = self.mag();
      self.vector = self.vector/m;
      self.scalar = self.scalar/m;
    end

    % Calculate the conjugate of the quaternion
    function q = conj(self)
      vector = -self.vector;
      scalar = self.scalar;
      args = struct; args.vector = vector; args.scalar = scalar;
      q = quaternion(args);
    end

    % Calculate the inverse of the quaternion
    function q_inv = inv(self)
      c = self.conj();
      n2 = self.mag()^2;
      args = struct;
      args.vector = c.vector / n2;
      args.scalar = c.scalar / n2;
      q_inv = quaternion(args);
    end

    % Create the skew-symmetric cross product matrix from a quaternion vector.
    function x = x(self)
      v = self.vector;
      x = [ 0    -v(3)  v(2); ...
            v(3)   0   -v(1); ...
           -v(2)  v(1)    0];
    end

    % Create the rotation matrix that is associated with the defined quaternion
    function m = rmatrix(self)
      s = self.scalar;
      v = self.vector;
      x1 = (s^2 - (v(1)^2  +v(2)^2+ v(3)^2)) * eye(3);
      x2 = 2 * self.vector * self.vector';
      x3 = 2 * s * self.x;

      m = x1 + x2 - x3;
    end

    %Given a list of points in R3, returned their new position
    %after being rotated by this quaternion instance.
    function pts = rotate_points(self,args)
      if (nargin == 1); args = struct; end

      try
        points = args.points;
      catch
        points = [];
      end

      newPoints = zeros(size(points));
      R = self.rmatrix;
      for i=1:size(points,1)
        pt = points(i,:);
        newpt = R * pt';
        newPoints(i,:) = newpt';
      end
      pts = newPoints;

    end

    %Surface plots have an matrix of x,y,z points. Itterate
    %through the matrix and rotate each point.
    function data = rotate_surf_points(self,args)
      if (nargin == 1); args = struct; end

      data = struct;
      try
        data.x = args.x;
      catch
        error('Missing "x" argument in %s',mfilename())
      end
      try
        data.y = args.y;
      catch
        error('Missing "y" argument in %s',mfilename())
      end
      try
        data.z = args.z;
      catch
        error('Missing "z" argument in %s',mfilename())
      end

      [rows, cols] = size(data.x);

      R = self.rmatrix;
      for row=1:rows;
        for col=1:cols;
          pt = [data.x(row,col) data.y(row,col) data.z(row,col)]';
          newpt = R * pt;
          data.x(row,col) = newpt(1);
          data.y(row,col) = newpt(2);
          data.z(row,col) = newpt(3);
        end
      end

    end

    function [q_n, q_r] = decompose(self)

      Q = (self.scalar*self.vector(1)-self.vector(2)*self.vector(3))/ ...
        (self.scalar*self.vector(2)+self.vector(1)*self.vector(3));
      n0 = sqrt(self.scalar^2 + self.vector(3)^2);
      r0 = self.scalar / n0;
      r3 = self.vector(3) / n0;
      n2 = sqrt((1 - n0^2) / (Q^2 + 1));
      n1 = Q * n2;
      args = struct;
      args.scalar = r0;
      args.vector = [0 0 r3]';
      q_r = quaternion(args);
      args = struct;
      args.scalar = n0;
      args.vector = [n1 n2 0]';
      q_n = quaternion(args);
      q_check = q_n * q_r;
      if (sum(sign(q_check.vector(1:2)) ~= sign(self.vector(1:2))) > 0)
        q_n.vector = -q_n.vector;
      end

    end

    % I can't believe I need to make a method that copy's
    % the object instead of just using a=b
    function q = copy(self)
      vector = self.vector;
      scalar = self.scalar;
      args = struct; args.vector = vector; args.scalar = scalar;
      q = quaternion(args);
    end

    % Create a string output of the quaternion value
    function str = str(self, format)
      if nargin == 1; format = ''; end

      if strcmp(format, '')
        str = sprintf('<%+0.5f %+0.5f %+0.5f> %+0.5f',self.vector(1), ...
          self.vector(2),self.vector(3),self.scalar);
      elseif strcmp(format, 'html')
        str = sprintf('&lt%+0.5f %+0.5f %+0.5f&gt %+0.5f',self.vector(1), ...
          self.vector(2),self.vector(3),self.scalar);
      end
    end

    function str = latex(self, compact)
      if (nargin == 1) compact = 1; end

      q = round([self.vector; self.scalar] .* 10^5) ./ 10^5;
      if (compact)
        str = sprintf('[%0.5f, %0.5f, %0.5f]^T, %0.5f',q(1),q(2),q(3),q(4));
      else
        str = sprintf(['\\begin{bmatrix} %0.5f \\\\ %0.5f \\\\ %0.5f \\\\ %0.5f ' ...
          .\\end{bmatrix}'],q(1),q(2),q(3),q(4));
      end
    end
  end
end