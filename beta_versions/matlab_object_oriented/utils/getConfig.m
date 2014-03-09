function val = getConfig(varargin)
% getConfig - Retrieve a value from the global config structure
%
% Input:
%    varargin - Pass a series of names to path out the config
%               Ex to graph config.some.thing.here call
%               getConfig('some','thing','here')
% Output:
%    return the value/structure stored.
%    If the path does not exist, return false.
	global config
	
	try
		tmp = config;
		for i=1:nargin
			tmp = tmp.(varargin{i});
		end
		val = tmp;
	catch
		val = false;
	end
	return
