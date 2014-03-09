function pos = nutation_position(volts, css_deg)
	
	global calibration_data
	
	flat = calibration_data.volts.steady(css_deg,:)'
	volt_offset = volts - flat
	
	xp = calibration_data.volts.xpos(css_deg,:)' - flat
	yp = calibration_data.volts.ypos(css_deg,:)' - flat
	xn = calibration_data.volts.xneg(css_deg,:)' - flat
	yn = calibration_data.volts.yneg(css_deg,:)' - flat
	
	if check(xp, volt_offset, yp) > 0
		quadrant = 1;
		x = xp; y = yp; z = cross(x, y);
	elseif check(yp, volt_offset, xn) > 0
		quadrant = 2;
		x = yp; y = xn; z = cross(x, y);
	elseif check(xn, volt_offset, yn) > 0
		quadrant = 3;
		x = xn; y = yn; z = cross(x, y);
	else
		quadrant = 4;
		x = yn; y = xp; z = cross(x, y);
	end
	
	A = [x';y';z']
	pt = A^-1 * volt_offset
	pos = (quadrant - 1) * 90 + (atan2(pt(2), pt(1)) / pi * 180);
	
end

function ret = check(a, volts, b)

	if (dot(a,volts) < 0) & (dot(b,volts) < 0)
		ret = -1;
		return
	end
	c1 = cross(a, volts);
	c2 = cross(volts, b);
	
	ret = dot(c1, c2);
end