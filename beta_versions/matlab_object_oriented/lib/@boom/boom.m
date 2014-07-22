classdef boom
  properties
    name
    plot_name
    mount
    direction
    length
    pts
  end

  methods
    function self = boom(args)
      if (nargin == 0); args = struct; end

      try
        self.name = args.name;
      catch
        self.name = random_string(10);
      end
      self.plot_name = lower(strrep(self.name,' ',''));

      try
        self.mount = makeVec(args.mount);
      catch
        error('Trying to create a boom without specifying mount (a mount point)')
      end

      try
        dir = makeVec(args.direction);
        % Baseline testing shows 13x improvement using sqrt(^2) instead of norm
        self.direction = dir/sqrt(dir(1)^2+dir(2)^2+dir(3)^2);
      catch
        error(['Trying to create a boom without specifying direction ' ...
          '(the direction the boom extends from the mount point)'])
      end

      try
        self.length = args.length;
      catch
        error(['Trying to create a boom without specifying lengh (the ' ...
          'direction the boom length)'])
      end

      % Calculate the points to plot the boom in 3D
      end_pt = self.mount + self.length * self.direction;
      pts = [...
        self.mount';
        end_pt'];

      self.pts = pts;
    end
  end
end