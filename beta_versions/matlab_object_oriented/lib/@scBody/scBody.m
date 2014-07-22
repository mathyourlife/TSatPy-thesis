classdef scBody
  properties
    body_radius
    booms
    series
  end
  
  methods
    function self = scBody(args)
      if (nargin == 0); args = struct; end
      
      self = self.build(args);
    end
    
    function self = build(self,args)
      if (nargin == 1); args = struct; end
      
      try
        self.body_radius = args.body_radius;
      catch
        self.body_radius = 0.3;
      end
      
      try
        sdp_len = args.sdp_len;
      catch
        sdp_len = 0.5;
      end
      
      try
        adp_len = args.adp_len;
      catch
        adp_len = 0.6;
      end
      
      booms = struct;
      
      args = struct;
      args.name = 'SDP Pos X';
      args.mount = [self.body_radius 0 0];
      args.direction = [1 0 0];
      args.length = sdp_len;
      booms.x_pos = boom(args);
      
      args = struct;
      args.name = 'SDP Pos Y';
      args.mount = [0 self.body_radius 0];
      args.direction = [0 1 0];
      args.length = sdp_len;
      booms.y_pos = boom(args);
      
      args = struct;
      args.name = 'SDP Neg X';
      args.mount = [-self.body_radius 0 0];
      args.direction = [-1 0 0];
      args.length = sdp_len;
      booms.x_neg = boom(args);
      
      args = struct;
      args.name = 'SDP Neg Y';
      args.mount = [0 -self.body_radius 0];
      args.direction = [0 -1 0];
      args.length = sdp_len;
      booms.y_neg = boom(args);
      
      args = struct;
      args.name = 'ADP Pos Z';
      args.mount = [0 0 0];
      args.direction = [0 0 1];
      args.length = adp_len;
      booms.z_pos = boom(args);
      
      args = struct;
      args.name = 'ADP Neg Z';
      args.mount = [0 0 0];
      args.direction = [0 0 -1];
      args.length = adp_len;
      booms.z_neg = boom(args);
      
      self.booms = booms;
      self.series = self.plotSeries();
    end
    
    function data = bodySeries(self)
      radius = 0:self.body_radius:self.body_radius;
      theta = (pi/180)*[0:45:360];
      [R,T] = meshgrid(radius,theta); % Make radius/theta grid
      surf = struct;
      surf.x = R.*cos(T);
      surf.y = R.*sin(T);
      surf.z = zeros(size(R));
      
      data = struct;
      data.name = 'SC Body';
      data.plot_name = 'sc_body';
      data.type = 'sc_body';
      data.surf = surf;
    end
    
    function series = plotSeries(self)
      series = struct;
      
      series.sc_body = self.bodySeries();
      
      f = fieldnames(self.booms);
      for i=1:numel(f)
        data = struct;
        data.plot_name = self.booms.(f{i}).plot_name;
        data.name = self.booms.(f{i}).name;
        data.type = 'boom';
        data.pts = self.booms.(f{i}).pts;
        series.(data.plot_name) = data;
      end
    end
  end
end