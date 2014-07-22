classdef estimator
%ESTIMATOR Class
%
%This class is in charge of managing which estimation 
%techniques are provided with with the recent measurement
%state and which will provide an output.  Any estimators 
%in self.active.{type}=1 will receive a call to its update 
%method with the measurement state.  Multiple estimators
%can receive the same measurement state update.  The
%self.output.{type} struct determines out of all the
%estimators, which will be passed to the estimator.state
%property.  Only one estimator should be set to output.
%
%This setup will allow multiple estimators to run in parallel
%and programatically switch between estimators without
%needing to wait for them to start from a clean instance.
  
  properties
    types
    active
    output
    none
    luenberger
    pid
    movingaveragefilter
    %ekf
    %smo
    state
  end
  
  methods
    function self = estimator(args)
      if (nargin == 0); args = struct; end
      
      try
        type = lower(args.type);
      catch
        type = 'none';
      end
      
      % Populate the estimator types
      self.types = {'none','luenberger','pid','movingaveragefilter'};
      
      self = self.reset();
      
      args = struct; args.type = type;
      self = self.run(args);
      self = self.setoutput(args);
    end
    
    function self = reset(self)
      
      self.state = state();
      
      % Load filter instances
      self.none = observerNone();
      self.luenberger = observerLuenberger();
      self.pid = observerPID();
      self.movingaveragefilter = movingAverageFilter();
      %self.ekf = ekf;
      %self.smo = smo;
      
      for i = 1:numel(self.types)
        self.active = setArg(self.types(i),0,self.active);
        self.output = setArg(self.types(i),0,self.output);
      end
      self.active.none = 1;
      self.output.none = 1;
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
    
    function self = setoutput(self,args)
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
      
      for i = 1:numel(self.types)
        if (self.active.(char(self.types(i))))
          args = struct; args.state = s;
          self.(char(self.types(i))) = self.(char(self.types(i))).update(args);
        end
        
        if (self.output.(char(self.types(i))))
          self.state = self.(char(self.types(i))).state;
        end
      end
    end
    
    function str = str(self)
      str = sprintf('%s',self.state.str);
    end
  end
end