classdef quaternionError < quaternion
  %{
  ERROR QUATERNION class
  
  Properties:
    vector: Vector portion of the quaternion
    scalar: Scalar portion of the quaternion
  
  Use:
  Creates an error quaternion from the comparison of 
  estimated and measured quaternions
    q_e = q* x q_hat
  
  To specify a quaternion at initiation pass a cell array of arguments
  in a key value pair.  Unspecified keys will use default values of
  a unit quaternion.
    args.q_hat
    args.q
    e = quaternionError(args);
  
  see: quaternion
  %}
  
  properties
  end
  
  methods
    % Class construction method
    function self = quaternionError(args)
      if (nargin == 0); args = struct; end
      
      try
        q_hat = args.q_hat;
      catch
        error('Missing "q_hat" argument in %s',mfilename())
      end
      
      try
        q = args.q;
      catch
        error('Missing "q" argument in %s',mfilename())
      end
      
      qe = q.conj * q_hat;
      
      % Normalize here ??
      qe.normalize();
      
      if (qe.scalar < 0)
        q_adj = quaternion();
        q_adj.vector = [0 0 0]';
        q_adj.scalar = -1;
        qe = q_adj * qe;
      end
      
      self.vector = qe.vector;
      self.scalar = qe.scalar;
    end
  end
end