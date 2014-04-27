disp('Testing bodyRate class')

tb = testBase;

br = bodyRate();

tb.assertEquals([0 0 0]',br.w,'BodyRate was initialized with the correct vector.');

args = struct;
args.w = rand(3,1);
br = bodyRate(args);

tb.assertEquals(args.w, br.w, 'BodyRate was instantiated with the correct vector.');

wx = [0 -args.w(3) args.w(2); args.w(3) 0 -args.w(1); -args.w(2) args.w(1) 0];
tb.assertEquals(wx, br.wx, 'Correct cross product matrix');

br2 = br * 2;
tb.assertEquals(args.w * 2, br2.w, 'Body rate multiplied by a scalar');

br3 = br2 / 4;
tb.assertEquals(args.w / 2, br3.w, 'Body rate divided by a scalar');

args.w = rand(3,1);
a = bodyRate(args);
args.w = rand(3,1);
b = bodyRate(args);

c = a + b;
tb.assertEquals(c.w, a.w + b.w, 'Sum of two body rates');

c = a - b;
tb.assertEquals(c.w, a.w - b.w, 'Difference of two body rates');

args.w = rand(3,1);
a = bodyRate(args);
b = a * 2;

msg = 'Comparison of the two body rates (lt)';
if (a < b)
  tb.pass(msg);
else
  tb.fail(msg);
end

msg = 'Comparison of the two body rates (gt)';
if (b > a)
  tb.pass(msg);
else
  tb.fail(msg);
end

msg = 'Comparison of the two body rates (le)';
if (a <= a)
  tb.pass(msg);
else
  tb.fail(msg);
end

msg = 'Comparison of the two body rates (ge)';
if (b >= b)
  tb.pass(msg);
else
  tb.fail(msg);
end

