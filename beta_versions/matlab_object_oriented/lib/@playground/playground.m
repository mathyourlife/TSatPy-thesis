classdef playground < handle
  properties
    a
  end
  
  methods
    function self = playground(args)
    end
    
    function self = set_a(self, dt)
      self.a = dt;
    end
    
    function str = str(self)
      str = sprintf('playground');
    end
  end
end