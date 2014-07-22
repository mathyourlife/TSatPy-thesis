classdef tsat_obj
  properties
    scBody
    calibration
    sensors
    estimator
    controller
    actuators
    sensorGraph
    stateGraph
  end
  
  methods
    function self = tsat_obj(args)
      if (nargin == 0); args = struct; end
      
      % Initialize the TableSat instance
      self.calibration = calibration();
      
      %Establish the geometry of the TableSat
      try
        body_args = args.scBody_args;
      catch
        body_args = struct;
      end
      self.scBody = scBody(body_args);
      
      assignin('base','tsat',self)
      
      %Establish the array of sensors available to
      %collect data from.
      try
        sensor_args = args.sensor_args;
      catch
        sensor_args = struct;
      end
      self.sensors = sensors(sensor_args);
      
      assignin('base','tsat',self)
      
      %Initialize the main estimator object that
      %controls which estimation techniques are actively
      %updated and which provide an estimated state
      %to the controller
      try
        est_args = args.estimator_args;
      catch
        est_args = struct;
      end
      self.estimator = estimator(est_args);
      
      assignin('base','tsat',self)
      
      %Initialize the bank of actuators the controller
      %will pass desired moment torques to.
      try
        act_args = args.actuator_args;
      catch
        act_args = struct;
      end
      self.actuators = actuators(act_args);
      
      %Initialize the bank of actuators the controller
      %will pass desired moment torques to.
      try
        ctrl_args = args.controller_args;
      catch
        ctrl_args = struct;
      end
      self.controller = controller(ctrl_args);
      
    end
  end
end