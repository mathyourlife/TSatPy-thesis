function vec = makeVec(test)
%Helper function to verify that the 
%argument passed is a N x 1 vector.  If a 1 x N,
%return the transposed data.

  if (size(test,2) > 1)
    vec = test';
  else
    vec = test;
  end
end
