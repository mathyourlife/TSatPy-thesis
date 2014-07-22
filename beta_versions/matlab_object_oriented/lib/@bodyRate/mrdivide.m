function w = mrdivide(a,b)
% Calculate the quotient of the body rate a and a scalar b.

vals = a.w / b;

args = struct;
args.w = vals;
w = bodyRate(args);