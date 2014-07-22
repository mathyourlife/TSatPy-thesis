function br = plus(a)
% Calculate the sum of two body rates.

w = -a.w;

args = struct; args.w = w;
br = bodyRate(args);