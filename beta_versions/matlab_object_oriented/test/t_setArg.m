disp('Testing setArg utility')

tb=testBase;

args = struct;
args = setArg('new',1,args);
tb.assertEquals(1,args.new,'Set a field value.');

args = struct;
args.already = 1;
args = setArg('already',2,args);
tb.assertEquals(2,args.already,'Reassign a field');

args = struct;
args.unused = 1;
args = setArg('cell_stuff',{'some','here'},args);
tb.assertEquals({'some','here'},args.cell_stuff,'Assign a cell array');

