function r = updateEstimatorStateModel(args)
  if (nargin == 0); args = struct; end

  global tsat
  
  try
    findobj(tsat.tsatModelEstimator.myPlot.p);
    item = struct;
    item.state = tsat.estimator.xHat;
    tsat.tsatModelEstimator=tsat.tsatModelEstimator.update(item);
  catch
    display('No graph loaded skipping update')
  end

end