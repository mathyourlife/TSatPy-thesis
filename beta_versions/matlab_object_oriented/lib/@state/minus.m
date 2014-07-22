function s = minus(a,b)
% Calculate the of two state variables.

q = a.q - b.q;
w = a.w - b.w;

args = struct;
args.q = q;
args.w = w;
s = state(args);