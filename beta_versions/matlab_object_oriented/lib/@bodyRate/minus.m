function br = plus(a,b)
% Calculate the sum of two body rates.

w = a.w - b.w;

args = struct; args.w = w;
br = bodyRate(args);