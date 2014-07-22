classdef stateMatrix < handle
  % STATEMATRIX class
  % 
  properties
    qq
    qw
    wq
    ww
  end
  
  methods
    % Class construction method
    function self = stateMatrix(args)
      if (nargin == 0); args = struct; end
      
      self.qq = struct;
      self.qw = struct;
      self.wq = struct;
      self.ww = zeros(3, 3);
      
      self.qq.vv = zeros(3, 3);
      self.qq.vs = zeros(3, 1);
      self.qq.sv = zeros(1, 3);
      self.qq.ss = 0;
      
      self.qw.vw = zeros(3, 3);
      self.qw.sw = zeros(1, 3);
      
      self.wq.wv = zeros(3, 3);
      self.wq.ws = zeros(3, 1);
      
      
    end
    
    function jacobian(self, args)
      
      try
        s = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
      try
        I = args.I;
      catch
        error('Missing "I" argument in %s',mfilename())
      end
      
      self.qq.vv = s.q.x();
      self.qq.vs = s.q.vector;
      self.qq.sv = -s.q.vector';
      
      self.ww = zeros(3, 3);
      I_1 = (I(3, 3) - I(2, 2)) / I(1, 1);
      I_2 = (I(1, 1) - I(3, 3)) / I(2, 2);
      I_3 = (I(2, 2) - I(1, 1)) / I(3, 3);
      self.ww(1, 2) = s.w.w(3) * I_1;
      self.ww(1, 3) = s.w.w(2) * I_1;
      self.ww(2, 1) = s.w.w(3) * I_2;
      self.ww(2, 3) = s.w.w(1) * I_2;
      self.ww(3, 1) = s.w.w(2) * I_3;
      self.ww(3, 2) = s.w.w(1) * I_3;
      self.ww
    end
    
    function A = matrix(self)
      Aqq = [self.qq.vv self.qq.vs; self.qq.sv self.qq.ss];
      Aqw = [self.qw.sw; self.qw.vw];
      Awq = [self.wq.wv self.wq.ws];
      Aww = self.ww;
      A = [Aqq Aqw; Awq Aww];
    end
    
    function s = mtimes(self, a)
      s = state();
      s.q.vector = self.qq.vv * a.q.vector + self.qq.vs * a.q.scalar + self.qw.vw * a.w.w;
      s.q.scalar = self.qq.sv * a.q.vector + self.qq.ss * a.q.scalar + self.qw.sw * a.w.w;
      s.w.w = self.wq.wv * a.q.vector + self.wq.ws * a.q.scalar + self.ww * a.w.w;
      
      
    end
  end
end