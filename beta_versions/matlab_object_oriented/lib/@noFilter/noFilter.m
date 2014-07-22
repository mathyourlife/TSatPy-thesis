classdef noFilter
  properties
    history
    historylen
    state
  end
  
  methods
    function self = noFilter(args)
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
        self.state = args.state;
      catch
        error('Missing "state" argument in %s',mfilename())
      end
      
    end
    
    function self = updateHistory(self,args)
      
    end
    
    function str = str(self)
      str = 'No Filter Selected';
    end
  end
end
    