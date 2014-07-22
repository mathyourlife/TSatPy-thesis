classdef actuators
  properties
    requested_moment
    effective_moment
    thrusters
  end
  
  methods
    function self = actuators(args)
      if (nargin == 0); args = struct; end
      
      self.requested_moment = [0 0 0]';
      self.effective_moment = [0 0 0]';
      self = self.mountThrusters(args);
    end
    
    %{
    Establish the arrangement of the thrusters
    on TableSat.  If an arrangement is not provided
    use the default mounting arrangement.
    %}
    function self = mountThrusters(self,args)
      if (nargin == 1); args = struct; end
      
      global tsat;
      
      try
        thrusters = args.thrusters;
      catch
        
        % Initialize thruster structure
        thrusters = struct;
        
        b_rad = tsat.scBody.body_radius;
        
        %{
        REMOVED UNTIL CAPABLE OF COMPOUND THRUSTER MOMENTS
        % Create a nutation thruster that pushes in +z
        args = struct;
        args.center = [cos(30/180*pi)*(b_rad) sin(30/180*pi)*(b_rad) 0]';
        args.direction = [0 0 1]';
        args.name = 'Nutation Pos z';
        thrusters.n_pos_z = thruster(args);
        
        % Create a nutation thruster that pushes in -z
        args = struct;
        args.center = [cos(30/180*pi)*(b_rad) -sin(30/180*pi)*(b_rad) 0]';
        args.direction = [0 0 1]';
        args.name = 'Nutation Neg z';
        thrusters.n_neg_z = thruster(args);
        %}
        
        args = struct;
        args.center = [0 b_rad 0]';
        args.direction = [0 0 -1]';
        args.name = 'wx_pos';
        thrusters.wx_pos = thruster(args);
        args = struct;
        args.center = [0 -b_rad 0]';
        args.direction = [0 0 -1]';
        args.name = 'wx_neg';
        thrusters.wx_neg = thruster(args);
        args = struct;
        args.center = [b_rad 0 0]';
        args.direction = [0 0 -1]';
        args.name = 'wy_neg';
        thrusters.wy_neg = thruster(args);
        args = struct;
        args.center = [-b_rad 0 0]';
        args.direction = [0 0 -1]';
        args.name = 'wy_pos';
        thrusters.wy_pos = thruster(args);
        
        args = struct;
        args.center = [b_rad/sqrt(2) b_rad/sqrt(2) 0]';
        args.direction = [-1 1 0]';
        args.name = 'wz_pos';
        thrusters.wz_pos = thruster(args);
        
        args = struct;
        args.center = [-b_rad/sqrt(2) -b_rad/sqrt(2) 0]';
        args.direction = [-1 1 0]';
        args.name = 'wz_neg';
        thrusters.wz_neg = thruster(args);
        
      end
      
      % replace/create the struct of thrusters property
      self.thrusters = thrusters;
    end
    
    %This method should be the primary call when a
    %actuator change is requested.  Based on the moment
    %vector provided [Mx My Mz]', this class will determine
    %based on the current actuator arrangement, which
    %combination of thrusters (or potentially other
    %actuators) would provide the best representation of
    %the requested moment.
    function self = requestMoment(self,args)
      if (nargin == 1); args = struct; end
      
      try
        M = args.M;
      catch
        error('Missing "M" argument in %s',mfilename())
      end
      
      f = fieldnames(self.thrusters);
      M_applied = [0 0 0]';
      for i=1:numel(f)
        if (dot(self.thrusters.(f{i}).moment_potential,M) > 0)
          F = M ./ self.thrusters.(f{i}).moment_potential;
          F(F == Inf) = 0;
          F(F == -Inf) = 0;
          F(isnan(F)) = 0;
          F = sum(F);
        else
          F = 0;
        end
        args = struct;
        args.F = F;
        self.thrusters.(f{i}) = self.thrusters.(f{i}).update(args);
        M_applied = M_applied + self.thrusters.(f{i}).moment;
      end
      
      self.requested_moment = M;
      self.effective_moment = M_applied;
    end
    
  end
end