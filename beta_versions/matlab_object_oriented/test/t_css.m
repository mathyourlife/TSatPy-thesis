disp('Testing css class')

c = css();
tb=testBase;

tb.assertEquals(0.2,c.noise,'Default measurement noise.');

volts = [0 1 1 0 0 0]';
args = struct; args.volts = volts;
c = c.update(args);

tb.assertEquals(volts,c.volts,'Set css voltages 90 degrees.');
tb.assertEquals(pi/2,c.theta,'Check calculated theta 90 degrees.');

volts = [1 0 0 0 0 0]';
args = struct; args.volts = volts;
c = c.update(args);

tb.assertEquals(volts,c.volts,'Set css voltages 0 Degrees.');
tb.assertEquals(0,c.theta,'Check calculated theta 0 Degrees.');

volts = [0 0 0 0 0 1]';
args = struct; args.volts = volts;
c = c.update(args);

tb.assertEquals(volts,c.volts,'Set css voltages 300 Degrees.');
tb.assertEquals(300/180*pi,c.theta,'Check calculated theta 300 Degrees.');

volts = [2 0 0 0 0 2]';
args = struct; args.volts = volts;
c = c.update(args);

tb.assertEquals(volts,c.volts,'Set css voltages 330 Degrees.');
tb.assertEquals(330/180*pi,c.theta,'Check calculated theta 330 Degrees.');
