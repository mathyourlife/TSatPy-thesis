classdef mock
  properties
  end
  
  methods
    function self = mock()
    end
    
    function q = gen_random_quaternion(self)
      vector = [1*rand() 2*rand() 3*rand()]';
      scalar = 4*rand();
      args = struct;
      args.vector = vector;
      args.scalar = scalar;
      q=quaternion(args);
      q.normalize();
    end
    
    function w = gen_random_body_rate(self)
      vector = randn(3,1) * 0.5;
      args = struct; args.w = vector;
      w = bodyRate(args);
    end
    
    function s = gen_random_state(self)
      args = struct;
      args.q = self.gen_random_quaternion();
      args.w = self.gen_random_body_rate();
      s = state(args);
    end
  end
end