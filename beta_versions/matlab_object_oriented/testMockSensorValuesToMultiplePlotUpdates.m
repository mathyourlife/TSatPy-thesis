function r = testMockSensorValuesToMultiplePlotUpdates(args)
  if (nargin == 0); args = struct; end
  
  global tsat
  tsat.sensorGraph=[];

  tsat.sensors.css.noise = 0.2;
  args = struct; args.action = 'init';
  timerManager(args);
  args = struct; args.action = 'start'; args.name = 'Buffer->Sensor';
  timerManager(args);
  args = struct; args.action = 'start'; args.name = 'Sensor->Graph';
  timerManager(args);

end