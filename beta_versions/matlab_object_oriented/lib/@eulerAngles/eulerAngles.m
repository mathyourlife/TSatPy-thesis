classdef eulerAngles
  properties
    rotations
  end
  
  methods
    function self = eulerAngles(args)
      if (nargin == 0); args = struct; end
      
      self = self.update(args);
    end
    
    function self = useDefaults(self)
      default = {};
      args = struct;
      args.seq = 1; args.axis = 3; args.angle = 0;
      default = arr_push(default, args);
      args = struct;
      args.seq = 2; args.axis = 1; args.angle = 0;
      default = arr_push(default, args);
      args = struct;
      args.seq = 3; args.axis = 3; args.angle = 0;
      default = arr_push(default, args);
      self.rotations = default;
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      % Validate number of rotations
      if (size(args,2) ~= 3)
        self = self.useDefaults();
        return;
      end
      
      self.rotations = args;
    end
    
    function rmatrix = rmatrix(self)
      m = eye(3);
      for i=1:3;
        args = struct; args.seq = i;
        item = self.getSeqNum(args);
        m = m * self.getSingleRmatrix(item);
      end
      rmatrix = m;
    end

    function rmatrix = getSingleRmatrix(self,args)
      
      try
        axis = args.axis;
      catch
        error('Missing "axis" argument in %s',mfilename())
      end
      try
        a = -args.angle;
      catch
        error('Missing "angle" argument in %s',mfilename())
      end
      
      if (axis==1)
        rmatrix = [1 0 0; 0 cos(a) sin(a); 0 -sin(a) cos(a)];
      elseif (axis==2)
        rmatrix = [cos(a) 0 -sin(a); 0 1 0; sin(a) 0 cos(a)];
      elseif (axis==3)
        rmatrix = [cos(a) sin(a) 0; -sin(a) cos(a) 0; 0 0 1];
      end
    
    end
    
    function q = toQuaternion(self)
      m = self.rmatrix();
      qs = 1/2 * sqrt(1 + m(1,1) + m(2,2) + m(3,3));
      qv = 1/(4*qs) * [(m(2,3) - m(3,2)); ...
              (m(3,1) - m(1,3)); ...
              (m(1,2) - m(2,1))];
      
      args = struct;
      args.vector = qv;
      args.scalar = qs;
      q=quaternion(args);
    end
    
    function item = getSeqNum(self,args)
      if (nargin == 1); args = struct; end
      
      try
        seq = args.seq;
      catch
        seq = 1;
      end
      
      for i=1:size(self.rotations,2)
        row = self.rotations(i);
        row = row{1};
        try
          val = row.seq;
          if (val == seq)
            item = row;
            return;
          end
        catch
        end
      end
    end
    
    function euler_matrix = matrix(self)
      euler_matrix = [self.phi self.theta self.psi]';
    end
    
    function str = str(self)
      str = '';
      for i=1:3
        args = struct; args.seq = i;
        item = self.getSeqNum(args);
        try
          axis = args.axis;
        catch
          error('Missing "axis" argument in %s',mfilename())
        end
        try
          angle = args.angle;
        catch
          error('Missing "angle" argument in %s',mfilename())
        end
        
        str = sprintf('%s%d -> %0.4f\n',str,axis,angle);
      end
    end
  end
end