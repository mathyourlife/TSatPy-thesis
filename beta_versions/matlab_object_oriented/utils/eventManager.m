function returned = eventManager(event_type,event_name,arg)
%eventManager Controls the storing and dispatching of event handlers
%
%	returned = eventManager(event_type,event_name,arg)
%
% Event types: (addlistener, dispatchevent, removelistener, clearall, showall)
	persistent events
	
	if (nargin<3)
		arg = {};
	end

	if (nargin>=2)
		idx = lookupEventName(events,event_name);
	end
	if(strcmp(lower(event_type),'addlistener'))
		if (idx == -1)
			events = arr_push(events,{event_name,{arg}});
		else
			%display(sprintf('Adding function handler if needed'))
			handlers = events{idx}{2};
			handlers = push_handler(handlers,arg);
			events{idx}{2} = handlers;
		end
	elseif(strcmp(lower(event_type),'dispatchevent'))
		if (idx > 0)
			evalin('base',events{idx}{2}{1} )
		end
	elseif(strcmp(lower(event_type),'removelistener'))
		if (idx > 0)
			%display(sprintf('Removing function handler if needed'))
			handlers = events{idx}{2};
			%display('Attempting to remove the handler')
			handlers = remove_handler(handlers,arg);
			if(size(handlers,2)==0)
				%display(sprintf('Empty handler list so remove the event name'))
				events(idx) = [];
			else
				events{idx}{2} = handlers;
			end
		end
	elseif(strcmp(lower(event_type),'clearall'))
		events = {};
	elseif(strcmp(lower(event_type),'showall'))
		index = 0;
		for event = events
			index = index + 1;
			display(sprintf('Listening for: %s',event{1}{1}));
		end
	end
end

function handlers = remove_handler(handlers,fnct)
	index=0;
	for handler = handlers
		index=index+1;
		class(handler{1})
		if (isequal(handler{1},fnct))
			%display(sprintf('Found the function to remove'))
			handlers(index)=[];
			return;
		end
	end
end

function result = dispatch_events(handlers,event_data)
	if (nargin == 1)
		event_data = {};
	end
	result = {};
	for handler = handlers
		%display(sprintf('Calling function handler'))
		toCall=handler{1};
		if (iscell(event_data) & isempty(event_data))
			item = {toCall, toCall()};
			result = arr_push(result,item);
		else
			item = {toCall, toCall(event_data)};
			result = arr_push(result,item);
		end
	end
end

function handlers = push_handler(handlers,fnct)
	for handler = handlers
		if (isequal(handler{1},fnct))
			%display(sprintf('handler is already loaded'))
			return;
		end
	end
	%display(sprintf('Adding handler'))
	handlers = arr_push(handlers,fnct);
end

function idx = lookupEventName(events,event_name)
	idx = -1;
	index = 0;
	for event = events
		index = index + 1;
		%display(sprintf('Does event index %d ',index))
		if (strcmp(event_name,event{1}{1}))
			%display(sprintf('Found event %s at index %d',event_name,index))
			idx = index;
			return
		end
	end

end