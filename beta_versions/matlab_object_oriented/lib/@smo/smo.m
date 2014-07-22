classdef smo
  properties
    state
    history
    historylen
  end
  
  methods
    function self = smo(args)
      if (nargin == 0); args = struct; end
      
      try
        self.historylen = args.historylen;
      catch
        self.historylen = 500;
      end
      
    end
    
    function self = update(self,args)
      if (nargin == 1); args = struct; end
      
      try
        s = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
    end
    
    function self = updateHistory(self,args)
      
    end
    
    function str = str(self)
      str = 'Sliding Mode Observer';
    end
  end
end
    