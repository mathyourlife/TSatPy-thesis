classdef tsatModel < handle
  properties
    name
    scale
    series
    body_axes
    show_thrusters
    disturbance
  end

  methods
    function self = tsatModel(args)
      if (nargin == 0); args = struct; end

      try
        self.name = args.name;
      catch
        self.name = random_string();
      end

      try
        self.scale = args.scale;
      catch
        self.scale = 1;
      end

      try
        self.show_thrusters = args.show_thrusters;
      catch
        self.show_thrusters = 1;
      end

      % Setup the data series for the base model
      self.series = struct;
      self.body_axes = struct;
      self = self.setupAxesSeries();
      self = self.setupDisturbanceSeries();

    end

    function setupPlot(self,args)
      if (nargin == 1); args = struct; end

      global tsat;

      try
        graph = args.graph;
      catch
        error('Missing "graph" argument in %s',mfilename())
      end
      try
        color = args.color;
      catch
        color = 'r';
      end

      f = fieldnames(tsat.scBody.series);
      for i=1:numel(f)
        item = struct;
        item.name = sprintf('%s_%s',self.name,tsat.scBody.series.(f{i}).plot_name);
        if (strcmp('sc_body',tsat.scBody.series.(f{i}).plot_name))
          item.type = 'surf';
          item_data = struct;
          item_data.x = tsat.scBody.series.(f{i}).surf.x;
          item_data.y = tsat.scBody.series.(f{i}).surf.y;
          item_data.z = tsat.scBody.series.(f{i}).surf.z;
          item.data = item_data;
          item.color = color;
          item.style = [color '-'];
        else
          item.type = 'plot3';
          item.LineWidth = 2;
          item_data = struct;
          item_data.x = tsat.scBody.series.(f{i}).pts(:,1);
          item_data.y = tsat.scBody.series.(f{i}).pts(:,2);
          item_data.z = tsat.scBody.series.(f{i}).pts(:,3);
          item.data = item_data;
          item.color = color;
          item.style = [color '-'];
        end

        args = struct;
        args.action = 'addseries'; args.graph = graph;
        args.item = item;
        graphManager(args);

      end

      if (self.show_thrusters)
        f = fieldnames(tsat.actuators.thrusters);
        for i=1:numel(f)
          item = struct;
          item.name = sprintf('%s_%s',self.name,tsat.actuators.thrusters.(f{i}).plot_name);
          item.type = 'plot3';
          item.LineWidth = 2;
          item_data = struct;
          item_data.x = tsat.actuators.thrusters.(f{i}).pts(:,1);
          item_data.y = tsat.actuators.thrusters.(f{i}).pts(:,2);
          item_data.z = tsat.actuators.thrusters.(f{i}).pts(:,3);
          item.data = item_data;
          item.color = color;
          item.style = [color '-'];

          args = struct;
          args.action = 'addseries'; args.graph = graph;
          args.item = item;
          graphManager(args);

          % Add thrust series for this thruster
          item.name = [item.name '_thrust'];
          item.LineWidth = 10;
          item.rgb_color = [255/255 100/255 0];
          item_data.x = [0 0]';
          item_data.y = [0 0]';
          item_data.z = [0 0]';
          item.data = item_data;

          args = struct;
          args.action = 'addseries'; args.graph = graph;
          args.item = item;
          graphManager(args);
        end
      end

      f = fieldnames(self.series);
      for i=1:numel(f)
        item = struct;
        item.name = sprintf('%s_%s',self.name,f{i});
        item.type = 'plot3';
        item.LineWidth = 2;
        item_data = struct;
        item_data.x = self.series.(f{i}).pts(:,1);
        item_data.y = self.series.(f{i}).pts(:,2);
        item_data.z = self.series.(f{i}).pts(:,3);
        item.data = item_data;
        if strcmp('disturbance',f{i})
          item.color = 'r';
        else
          item.color = color;
        end
        if (strcmp(self.series.(f{i}).type,'axis'))
          item.style = [item.color 'o'];
          item.size = 0.01;
        else
          item.style = [item.color '-'];
        end

        args = struct;
        args.action = 'addseries'; args.graph = graph;
        args.item = item;
        graphManager(args);
      end

      [x,y,z] = sphere;
      item = struct;
      item.name = 'sun';
      item.type = 'sphere';
      item_data = struct;
      item_data.x = 0.1*x+1.05;
      item_data.y = 0.1*y;
      item_data.z = 0.1*z;
      item.data = item_data;

      args = struct;
      args.action = 'addseries'; args.graph = graph;
      args.item = item;
      graphManager(args);

      item = struct;
      item.DataAspectRatio = [1 1 1]';
      item.xgrid = 'on';
      item.ygrid = 'on';
      item.zgrid = 'on';
      item.xlabel = 'x-axis';
      item.ylabel = 'y-axis';
      item.zlabel = 'z-axis';
      lim = 1.1;
      item.xlim = [-1 1]*lim;
      item.ylim = [-1 1]*lim;
      item.zlim = [-1 1]*lim;

      args = struct;
      args.action = 'format'; args.graph = graph;
      args.item = item;
      graphManager(args);
    end

    function addAxesLabels(self,args)
      if (nargin == 1); args = struct; end

      try
        graph = args.graph;
      catch
        error('Missing "graph" argument in %s',mfilename())
      end

      data.pt = [0.8 0 0];
      data.text = '+x';
      self.body_axes.(sprintf('%s_x',self.name)) = data;

      data.pt = [0 0.8 0];
      data.text = '+y';
      self.body_axes.(sprintf('%s_y',self.name)) = data;

      data.pt = [0 0 0.8];
      data.text = '+z';
      self.body_axes.(sprintf('%s_z',self.name)) = data;

      f = fieldnames(self.body_axes);
      for i=1:numel(f)
        x = self.body_axes.(f{i}).pt(1);
        y = self.body_axes.(f{i}).pt(1);
        z = self.body_axes.(f{i}).pt(1);
        args = struct; args.graph = graph; args.action = 'graph_id';
        graph_id = graphManager(args);
        self.body_axes.(f{i}).lh = text(x,y,z,self.body_axes.(f{i}).text,'Parent',graph_id);
      end
    end

    function self = update(self,args)
      if (nargin == 1); args = struct; end

      try
        name = args.name;
      catch
        error('Missing "name" argument in %s',mfilename())
      end

      args = struct; args.points = self.tsatRef;
      self.tsatSensor = s.q.rotate_points(args);

      item = struct;
      item.name = sprintf('%s_%s',self.name,name);
      item.type = 'plot3';
      item.style = 'r-o';
      item.LineWidth = 2;
      data = struct; data.x = self.tsatSensor(:,1); data.y = ...
        self.tsatSensor(:,2); data.z = self.tsatSensor(:,3);
      item.data = data;

      self = self.addSeries(item);
    end

    function updatePlot(self, args)
      if (nargin == 1); args = struct; end

      global tsat;

      try
        graph = args.graph;
      catch
        error('Missing "graph" argument in %s',mfilename())
      end
      try
        s = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end

      f = fieldnames(self.body_axes);
      for i=1:numel(f)
        args = struct; args.points = self.body_axes.(f{i}).pt;
        data = s.q.rotate_points(args);
        set(self.body_axes.(f{i}).lh,'Position',data);
      end


      args = struct; args.action = 'labels'; args.graph = graph;
      labels = graphManager(args);
      f = fieldnames(labels);
      for i=1:numel(f)
        args = struct; args.points = labels(f{i}).pt;
        data = s.q.rotate_points(args);
        set(labels(f{i}).lh,'Position',data);
      end

      if (self.show_thrusters)
        f = fieldnames(tsat.actuators.thrusters);
        for i=1:numel(f)

          args = struct; args.points = tsat.actuators.thrusters.(f{i}).pts;
          data = s.q.rotate_points(args);

          item = struct;
          item.name = sprintf('%s_%s',self.name,tsat.actuators.thrusters.(f{i}).plot_name);
          item.type = 'plot3';
          item.LineWidth = 2;
          item_data = struct;
          item_data.x = data(:,1);
          item_data.y = data(:,2);
          item_data.z = data(:,3);
          item.data = item_data;

          args = struct;
          args.action = 'updateseries'; args.graph = graph;
          args.item = item;
          graphManager(args);


          item.name = [item.name '_thrust'];
          item.LineWidth = 10;
          item.rgb_color = [255/255 100/255 0];
          args = struct; args.scale = 10;
          tsat.actuators.thrusters.(f{i}) = ...
            tsat.actuators.thrusters.(f{i}).set_thrust_plot_pts(args);
          args = struct; args.points = tsat.actuators.thrusters.(f{i}).thrust_pts;
          data = s.q.rotate_points(args);

          item_data.x = data(:,1);
          item_data.y = data(:,2);
          item_data.z = data(:,3);
          item.data = item_data;

          args = struct;
          args.action = 'updateseries'; args.graph = graph;
          args.item = item;
          graphManager(args);
        end
      end


      f = fieldnames(tsat.scBody.series);
      for i=1:numel(f)
        if (strcmp('sc_body',tsat.scBody.series.(f{i}).plot_name))
          data = s.q.rotate_surf_points(tsat.scBody.series.(f{i}).surf);

          item = struct;
          item.name = sprintf('%s_%s',self.name,tsat.scBody.series.(f{i}).plot_name);
          item.type = 'surf';
          item.data = data;
        else
          args = struct;
          args.points = tsat.scBody.series.(f{i}).pts;
          data = s.q.rotate_points(args);

          item = struct;
          item.name = sprintf('%s_%s',self.name,tsat.scBody.series.(f{i}).plot_name);
          item.type = 'plot3';
          item.LineWidth = 2;
          item_data = struct;
          item_data.x = data(:,1);
          item_data.y = data(:,2);
          item_data.z = data(:,3);
          item.data = item_data;
        end

        args = struct;
        args.action = 'updateseries'; args.graph = graph;
        args.item = item;
        graphManager(args);
      end

      f = fieldnames(self.series);
      for i=1:numel(f)
        % Don't update the dots that set the max on the axes.
        if strcmp(self.series.(f{i}).type,'axis')
          continue;
        end
        args = struct; args.points = self.series.(f{i}).pts;
        data = s.q.rotate_points(args);

        item = struct;
        item.name = sprintf('%s_%s',self.name,f{i});
        item.type = 'plot3';
        item.color = 'r';
        item.style = 'r-o';
        item.LineWidth = 2;
        item_data = struct;
        item_data.x = data(:,1);
        item_data.y = data(:,2);
        item_data.z = data(:,3);
        item.data = item_data;

        args = struct;
        args.action = 'updateseries'; args.graph = graph;
        args.item = item;
        graphManager(args);
      end
    end

    function self = setupAxesSeries(self,args)
      if (nargin == 1); args = struct; end

      pts = [
        1 0 0;
        0 1 0;
        0 0 1;
        -1 0 0;
        0 -1 0;
        0 0 -1;
        0 0 0];
      data = struct;
      data.name = 'Axes';
      data.type = 'axis';
      data.pts = pts;
      self.series.axes = data;

    end

    function self = updateDisturbance(self,args)
      if (nargin == 1); args = struct; end

      try
        F = args.F;
      catch
        error('Missing "F" argument in %s',mfilename())
      end

      global tsat

      % Assign a random spot on the deck to place the disturbance
      theta = 2 * pi * rand();
      self.series.disturbance.center = [cos(theta) sin(theta) 0]' * tsat.scBody.body_radius;

      % Create a random direction for the disturbance
      dir = rand(3,1) * 2 - 1;
      % Baseline testing shows 13x improvement using sqrt(^2) instead of norm
      dir = dir / sqrt(dir(1)^2 + dir(2)^2 + dir(3)^2);
      self.series.disturbance.direction = dir;

      pts = [
        self.series.disturbance.center';
        self.series.disturbance.center' + F * self.series.disturbance.direction'
        ];
      self.series.disturbance.pts = pts;

    end

    function M = getDisturbanceMoment(self,args)
      if (nargin == 1); args = struct; end

      try
        F = args.F;
      catch
        error('Missing "F" argument in %s',mfilename())
      end

      M = cross(self.series.disturbance.center,F * self.series.disturbance.direction);
    end

    function self = setupDisturbanceSeries(self,args)
      if (nargin == 1); args = struct; end

      data = struct;
      data.name = 'disturbance';
      data.type = 'force';
      self.series.disturbance = data;

      args = struct; args.F = 0;
      self = self.updateDisturbance(args);
    end
  end
end