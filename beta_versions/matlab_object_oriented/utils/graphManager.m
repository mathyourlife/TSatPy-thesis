function ret = graphManager(args)
	ret = struct;
	if nargin == 0; return; end
	
	global graphs
	
	try
		action = args.action;
	catch
		return;
	end
	
	if (strcmp(action,'create'))
		ret = createGraph(args);
	elseif (strcmp(action,'focus'))
		focusGraph(args);
	elseif (strcmp(action,'close'))
		closeGraph(args);
	elseif (strcmp(action,'addseries'))
		addSeries(args);
	elseif (strcmp(action,'updateseries'))
		updateSeries(args);
	elseif (strcmp(action,'format'))
		format(args);
	elseif (strcmp(action,'labels'))
		ret = labels(args);
	elseif (strcmp(action,'graph_id'))
		ret = graph_id(args);
	elseif (strcmp(action,'fig_id'))
		ret = fig_id(args);
	elseif (strcmp(action,'grid'))
		grid(args);
	else
		error('here')
	end
end

function grid(args)
	global graphs
	graphs.(args.graph).obj.grid(args.item);
end

function ret = fig_id(args)
	global graphs
	ret = get(graphs.(args.graph).obj.plot_id,'Parent');
end

function ret = graph_id(args)
	global graphs
	ret = graphs.(args.graph).obj.plot_id;
end

function ret = labels(args)
	global graphs
	ret = graphs.(args.graph).obj.labels;
end

function format(args)
	global graphs
	graphs.(args.graph).obj.format(args.item);
end

function addSeries(args)
	global graphs
	graphs.(args.graph).obj.addSeries(args.item);
end

function updateSeries(args)
	global graphs
	graphs.(args.graph).obj.updateSeries(args.item);
end

% Close a graph by name
function closeGraph(args)
	global graphs
	
	try
		name = args.name;
	catch
		error('Missing "name" argument in %s',mfilename())
	end
	
	if (isfield(graphs,name))
		% graph exists, attempt a close
		try
			close(graphs.(name).obj.fig_id)
		catch
			% already closed
		end
		
		try
			graphs = rmfield(graphs,name);
		catch
			% no field exists
		end
	else
		% Not an active graph
	end
end

% Set the focus on a particular graph
function focusGraph(args)
	global graphs
	try
		name = args.name;
	catch
		error('Missing "name" argument in %s',mfilename())
	end
	if (isfield(graphs,name))
		% Already a graph by this name, try a close and recreate
		figure(graphs.(name).obj.fig_id)
	else
		% Not an active graph
		error('The %s graph does not exist so can not be closed',name)
	end
end

% Create a graph with a specific id and 
function fig_id = createGraph(args)
	global graphs
	try
		name = args.name;
	catch
		error('Missing "name" argument in %s',mfilename())
	end
	
	if (isfield(graphs,name))
		% Already a graph by this name, try to clear it's contents
		fig_id = graphs.(name).obj.fig_id;
		plot_id = graphs.(name).obj.plot_id;
		try
			l=get(get(fig_id,'Children'),'Children');
			delete(l(1:numel(l)))
		catch
			try
				close(fig_id)
			catch
				% Must be closed already
			end
		end
		args = struct; args.fig_id = fig_id; args.plot_id = plot_id;
		graphs.(name).obj = tPlot(args);
	else
		% No graph by this name, make one
		fig_id = graphs.fig_id + 1;
		graphs.fig_id = fig_id;
		args = struct; args.fig_id = fig_id;
		graphs.(name).obj = tPlot(args);
	end
end


