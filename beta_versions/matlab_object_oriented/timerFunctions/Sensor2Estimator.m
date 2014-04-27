function r = Sensor2Estimator(args)
  if (nargin == 0); args = struct; end

  global tsat
  
  args = struct;
  args.state = tsat.sensors.state;
  tsat.estimator=tsat.estimator.update(args);

end