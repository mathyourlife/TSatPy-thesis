function r = Estimator2Model(args)
	if (nargin == 0); args = struct; end

	global tsat
	
	item = struct;
	item.state = tsat.estimator.state;
	item.name = 'tsatEstimator';
	item.style = 'bo';
	item.size = 0.1;
	tsat.tsatModel=tsat.tsatModel.update(item);

end