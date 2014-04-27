function r = Sensor2Graph(args)
  if (nargin == 0); args = struct; end
  
  global tsat
  global graphs
  
  addFlag = false;
  if (isempty(tsat.sensorGraph) || size(tsat.sensorGraph.series,2)==0)
    addFlag = true;
    graphs.sensor.obj = tPlot()
    graphs.sensor.plot = 'css-volts';
    graphs.sensor.prev_plot = 'css-volts';
  end
  changed = ~strcmp(graphs.sensor.plot,graphs.sensor.prev_plot);
  if (changed)
    tsat.config.sensorGraph.lastplot=tsat.config.sensorGraph.plot;
    tsat.sensorGraph = tPlot;
    addFlag = true;
  end
  
  if (strcmp('css-volts',graphs.sensor.plot))
    item = struct;
    item.type = 'plot';
    for i=1:6
      item.name = ['css-' num2str(i)];
      item.data.x = tsat.sensors.css.history.volts(:,1);
      item.data.x = tsat.sensors.css.history.volts(:,i+1);
      
      if (addFlag)
        tsat.sensorGraph=tsat.sensorGraph.addSeries(item);
      else
        tsat.sensorGraph=tsat.sensorGraph.updateSeries(item);
      end
    
    end
  end
  
end