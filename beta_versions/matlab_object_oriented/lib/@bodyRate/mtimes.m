function br = mtimes(a,b)
% Define basic multiplication of bodyRates with scalars

if isa(a,'bodyRate')
  w = a.w * b;
elseif isa(b,'bodyRate')
  w = b.w * a;
end
args = struct; args.w = w;
br = bodyRate(args);
