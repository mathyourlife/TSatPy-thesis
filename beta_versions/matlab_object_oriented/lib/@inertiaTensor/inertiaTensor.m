classdef inertiaTensor
  properties
    I
    class
    attributes
  end
  
  methods
    function self = inertiaTensor(args)
      if (nargin == 0); args = struct; end
      
      try
        self.class = args.class;
      catch
        self.class = 'cylinder';
      end
      
      if (strcmp(self.class,'cylinder'))
        try
          self.attributes.mass = args.mass;
        catch
          self.attributes.mass = 42;
        end
        try
          self.attributes.radius = args.radius;
        catch
          self.attributes.radius = 0.1;
        end
        try
          self.attributes.height = args.height;
        catch
          self.attributes.height = 0.02;
        end
        self = self.cylinder();
      end
    end
    
    function self = cylinder(self)
      m = self.attributes.mass;
      r = self.attributes.radius;
      h = self.attributes.height;
      
      Ix = 1/12 * m *(3*r^2 + h^2);
      Iy = 1/12 * m *(3*r^2 + h^2);
      Iz = 1/2 * m * r^2;
      self.I = [Ix 0 0; 0 Iy 0; 0 0 Iz];
    end
  end
end