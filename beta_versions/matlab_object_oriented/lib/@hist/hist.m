classdef hist
  % Hist (history) class
  %
  % Added functionality to log variable history data with timestamps
  % if extended into other classes
  properties
    logs
    historylen
  end
  
  methods
    % No code here since this class is being used as an "abstract"
    % class and the constructor will not be called
    function self = hist(args)
      if (nargin == 0); args = struct; end
      
      try
        self.historylen = args.historylen;
      catch
        self.historylen = 500;
      end
    end
    
    function self = log(self,args)
      global t
      
      try
        var = args.var;
      catch
        error('Missing "var" argument in %s',mfilename())
      end
      try
        value = args.value;
      catch
        error('Missing "value" argument in %s',mfilename())
      end
      
      % Determine if history has started for this variable
      if (~isfield(self.logs,var))
        self.logs.(var) = [];
      end
      
      if (isa(value,'quaternion'))
        value = [value.vector' value.scalar];
      elseif (isa(value,'bodyRate'))
        value = value.w';
      elseif (isa(value,'state'))
        value = [value.q.vector' value.q.scalar value.w.w'];
      end
      
      if (size(self.logs.(var),1) >= self.historylen)
        startRow = size(self.logs.(var),1) - self.historylen + 2;
      else
        startRow = 1;
      end
      
      % Record a vector value
      if ((size(value,1) == 1) || (size(value,2)==1))
        % Make a single row
        if (size(value,2) == 1)
          value = value';
        end
        self.logs.(var) = [self.logs.(var)(startRow:end,:); t.now() value];
        return;
      end
      
      % Record a scalar value
      if (numel(value) == 1)
        self.logs.(var) = [self.logs.(var)(startRow:end,:); t.now() value];
        return;
      end
    end
  end
end