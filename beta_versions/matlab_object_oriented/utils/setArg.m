function args = setArg(key,value,args)
% setArg sets the field value on the structure passed.  Not
% particularly useful right now, but may want to add preprocessing
% for specific field names.
%
% in: string key     Name of the field to retrieve
% in: mized  value   Value to be stored in the structure's field
% in: struct args    Structure to add/modify value to
% out: struct        Passed struct + new/modified field

	if (strcmp('cell',class(key)))
		key = char(key);
	end
	args.(key) = value;
end