function r = testMovingAvgFilter(args)

  global tsat
  
  args = struct; args.type = 'MOVAVG';
  tsat.estimator=tsat.estimator.switchEstimator(args)
    
  for i=1:6
  disp('==========================================================')
    s=state;
    args = struct; args.vector = ones(1,3)*i; args.scalar = i;
    q=quaternion(args);
    disp(q.str)
    args = struct; args.w = ones(1,3)*i;
    w=bodyRate(args);
    disp(w.str)
    args = struct; args.q = q; args.w = w;
    s2=state(args);
    disp(s2.str)
    args = struct; args.state = s2;
    tsat.estimator=tsat.estimator.update(args)
  end

end