classdef thruster
  properties
    center
    direction
    scale
    force
    moment
    moment_potential
    name
    plot_name
    pts
    thrust_pts
    thruster_radius
  end
  
  methods
    function self = thruster(args)
      if (nargin == 0); args = struct; end
      
      try
        self.name = args.name;
      catch
        self.name = random_string();
      end
      self.plot_name = lower(strrep(self.name,' ',''));
      
      
      try
        self.thruster_radius = args.thruster_radius;
      catch
        self.thruster_radius = 0.07;
      end
      
      try
        center = args.center;
        % Baseline testing shows 13x improvement using sqrt(^2) instead of norm
        center_adj = center / sqrt(center(1)^2 + center(2)^2 + center(3)^2);
        center_adj = center_adj * self.thruster_radius;
        self.center = center + center_adj;
      catch
        error('Missing "center" argument in %s',mfilename())
      end
      
      try
        dir = makeVec(args.direction);
        % Baseline testing shows 13x improvement using sqrt(^2) instead of norm
        self.direction = dir/sqrt(dir(1)^2 + dir(2)^2 + dir(3)^2);
      catch
        error('Missing "direction" argument in %s',mfilename())
      end
      
      %{
      Calculate the potential moment torque of an applied force.
      This will be used to determine which thrusters would be most
      effective to use in creating a desired moment.
      %}
      self.moment_potential = makeVec(cross(self.direction,self.center));
      
      self.force = 0;
      self.moment = [0 0 0]';
      
      % Initialize the scale to be used when creating plot points
      try
        self.scale = args.scale;
      catch
        self.scale = 0.1;
      end
      
      % Get the points to plot a circle that will represent the thruster.
      % Get two vectors orthogonal to the direction
      o1 = [0 0 0];
      while (sum(o1 == [0 0 0]) == 3)
        % Add while loop here just in case the random vector
        % is the same as the direction so the cross comes up zeros.
        % Very unlikely, but possible.
        o1 = cross(self.direction,rand(1,3));
      end
      % Baseline testing shows 13x improvement using sqrt(^2) instead of norm
      o1 = (o1/sqrt(o1(1)^2 + o1(2)^2 + o1(3)^2))';
      o2 = cross(self.direction,o1);
      
      steps = 12;
      pts = zeros(steps+1,3);
      for i=0:steps
        size = 360 / steps;
        rads = (i*size)/180*pi;
        pt = (cos(rads)*o1 + sin(rads)*o2) * self.thruster_radius + self.center;
        pts(i+1,:) = pt';
      end
      
      self.pts = pts;
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        self.force = makeVec(args.F);
      catch
        error('Missing "F" argument in %s',mfilename())
      end
      self.moment = makeVec(cross(self.force*self.direction,self.center));
    end
    
    function self = set_thrust_plot_pts(self,args)
      if (nargin == 1); args = struct; end
      
      % Adjust the scale if passed, if not use the existing value.
      try
        self.scale = makeVec(args.scale);
      catch
        error('Missing "scale" argument in %s',mfilename())
      end
      
      initial_pt = self.center;
      terminal_pt = self.center + self.force * self.scale * self.direction;
      
      self.thrust_pts = [initial_pt'; terminal_pt'];
    end
    
    function str = str(self)
      str = sprintf('Thruster %s',self.name);
    end
  end
end