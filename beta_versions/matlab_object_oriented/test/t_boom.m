disp('Testing boom class')

tb=testBase;
try
  b = boom();
  tb.fail('An exception should have been thrown');
catch
  msg = lasterror.message;
  e_msg = 'Trying to create a boom without specifying mount (a mount point)';
  tb.assertErrorMsg(e_msg,msg,'Did not specify a mount point');
end

args = struct;
args.mount = rand(3,1);
try
  b = boom(args);
  tb.fail('An exception should have been thrown');
catch
  msg = lasterror.message;
  e_msg = 'Trying to create a boom without specifying direction (the direction the boom extends from the mount point)';
  tb.assertErrorMsg(e_msg,msg,'Did not specify a direction');
end

args.direction = rand(3,1);
try
  b = boom(args);
  tb.fail('An exception should have been thrown');
catch
  msg = lasterror.message;
  e_msg = 'Trying to create a boom without specifying lengh (the direction the boom length)';
  tb.assertErrorMsg(e_msg,msg,'Did not specify a length');
end

args.length = rand();
args.name = 'This is my boom stick';
b = boom(args);

tb.assertEquals(args.mount,b.mount,'Boom was mounted correctly');
tb.assertEquals(args.direction/norm(args.direction),b.direction,'Boom points in the correct direction');
tb.assertEquals(args.length,b.length,'Boom was assigned the correct length');
tb.assertEquals(args.name,b.name,'Boom was assigned the correct name');
tb.assertEquals('thisismyboomstick',b.plot_name,'Boom was assigned the correct plot name');


args = struct;
args.mount = [1 2 3];
args.direction = [1 0 0];
args.length = 15;
b = boom(args);

pts = [1 2 3; 16 2 3];
tb.assertEquals(pts,b.pts,'The boom has the correct points to be plotted');