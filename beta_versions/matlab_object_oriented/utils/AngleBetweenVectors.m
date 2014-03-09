function angle = AngleBetweenVectors(vec1,vec2)


% Baseline testing shows 13x improvement using sqrt(^2) instead of norm
n_vec1 = sqrt(vec1(1)^2 + vec1(2)^2 + vec1(3)^2);
n_vec2 = sqrt(vec2(1)^2 + vec2(2)^2 + vec2(3)^2);
if n_vec1 == 0 || n_vec2 == 0
	angle = 0;
else
	c = cross(vec1,vec2);
	minor_angle = asin(sqrt(c(1)^2 + c(2)^2 + c(3)^2) / (n_vec1 * n_vec2))*180/pi;
	if dot(vec1,vec2) < 0
		angle = 180 - minor_angle;
	else
		angle = minor_angle;
	end
end

