classdef controller
%CONTROLLER Class
%
%This class is in charge of managing which controller 
%techniques are provided with with the recent estimator
%state and which will provide a command to the actuators.  
%Any controllers in self.active.{type}=1 will receive a 
%call to its update method with the estimator's state.  
%Multiple estimators can receive the same estimated state 
%update.  The self.output.{type} struct determines out of 
%all the controllers, which will be passed to the controller.M
%property.  Only one controller should be set to output.
%
%This setup will allow multiple controllers to run in parallel
%and programatically switch between control techniques without
%needing to wait for them to start from a clean instance.
  
  properties
    types
    active
    output
    M
    estimated_state
    desired_state
    state_error
    none
    pid
    smc
    lqr
  end
  
  methods
    function self = controller(args)
      if (nargin == 0); args = struct; end
      
      try
        type = args.type;
      catch
        type = 'none';
      end
      
      % Populate the estimator types
      self.types = {'none','pid','smc','lqr'};
      
      self = self.reset();
      
      args = struct; args.type = type;
      self = self.run(args);
      self = self.setOutput(args);
    end
    
    function self = reset(self)
      
      self.M = [0 0 0]';
      self.estimated_state = state();
      self.state_error = state();
      
      % Load filter instances
      self.none = controllerNone();
      self.pid = controllerPID();
      %self.smc = controllerSMC();
      %self.lqr = controllerLQR();
      
      for i = 1:numel(self.types)
        self.active = setArg(self.types(i),0,self.active);
        self.output = setArg(self.types(i),0,self.output);
      end
      self.active.none = 1;
      self.output.none = 1;
    end
    
    function self = setDesired(self,args)
      
      try
        self.desired_state = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
    end
    
    function self = run(self,args)
      if (nargin == 1); args = struct; end
      
      try
        type = lower(args.type);
      catch
        type = 'none';
      end
      
      self.active = setArg(type,1,self.active);
    end
    
    function self = stop(self,args)
      if (nargin == 1); args = struct; end
      
      try
        type = lower(args.type);
      catch
        type = 'none';
      end
      
      self.active = setArg(type,0,self.active);
    end
    
    function self = setOutput(self,args)
      if (nargin == 1); args = struct; end
      
      try
        type = lower(args.type);
      catch
        type = 'none';
      end
      
      for i = 1:numel(self.types)
        if (strcmp(type,self.types(i)))
          onoff = 1;
        else
          onoff = 0;
        end
        self.output = setArg(self.types(i),onoff,self.output);
      end
    end
    
    % Get the passed measurment state and feed it into the appropriate estimator
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        s = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
      % Assuming a desired attitude with body z-axis aligned with the
      % global Z axis, adjust the desired state of the system
      [q_n, q_r] = s.q.decompose();
      
      try
        ds = args.desired_state;
        ds.q = q_r;
        self.desired_state = ds;
      catch
        self.desired_state.q = q_r;
      end
      
      args = struct;
      args.state = s;
      args.desired_state = self.desired_state;
      
      for i = 1:numel(self.types)
        if (self.active.(char(self.types(i))))
          self.(char(self.types(i))) = self.(char(self.types(i))).update(args);
        end
        
        if (self.output.(char(self.types(i))))
          self.M = self.(char(self.types(i))).M;
          self.state_error = self.(char(self.types(i))).state_error;
        end
      end
    end
  end
end