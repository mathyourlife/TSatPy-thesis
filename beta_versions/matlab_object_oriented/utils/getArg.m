function val = getArg(args,key,default)
% getArg attempts to retrieve the field value of the args
% structure.
%
% in: string key   Name of the field to retrieve
% in: struct args  Structure to retrieve value from
% out: struct   Fields status (T/F) for success, and val for value.
  if nargin == 2
    has_default = false;
  else
    has_default = true;
  end
  % If the field exists, return the value
  try
    val = args.(key);
    return
  catch
    if has_default
      val = default;
    else
      error('Missing "%s" argument',key)
    end
    return
  end
end