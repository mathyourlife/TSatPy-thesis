function s = mrdivide(a,b)
% Calculate the quotient of the state a and a scalar b.

q = a.q / b;
w = a.w / b;

args = struct;
args.q = q;
args.w = w;
s = state(args);