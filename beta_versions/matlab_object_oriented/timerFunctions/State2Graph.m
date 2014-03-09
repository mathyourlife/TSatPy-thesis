function r = State2Graph(args)
	if (nargin == 0); args = struct; end
	
	global tsat
	tsat.system=tsat.system.update();
	addFlag = false;
	if (isempty(tsat.stateGraph) || size(tsat.stateGraph.series,2)==0)
		addFlag = true;
		tsat.stateGraph = tPlot;
	end
	
	item = struct;
	item.type = 'plot';
	for i=1:2
		item.name = sprintf('x%d', i);
		item.data.x = tsat.system.history.y(:,1);
		item.data.y = tsat.system.history.y(:,i+1);
		if (addFlag)
			tsat.stateGraph=tsat.stateGraph.addSeries(item);
		else
			tsat.stateGraph=tsat.stateGraph.updateSeries(item);
		end
	end
end