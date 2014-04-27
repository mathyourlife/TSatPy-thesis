function nutationArray = CalculateNutationArray()

% Find the center
TAMcenter(1) = mean(calibration.steady_data(1:end,14));
TAMcenter(2) = mean(calibration.steady_data(1:end,15));
TAMcenter(3) = mean(calibration.steady_data(1:end,16));
calibration.TAMcenter = TAMcenter


% Find the TAM reading that corresponds wih 0 degrees on the CSS reading
TAMzero(1) = 0;
TAMzero(2) = 0;
TAMzero(3) = 0;
TAM90(1) = 0;
TAM90(2) = 0;
TAM90(3) = 0;
count = 0;
bufer = 10;
for i=1:size(calibration.steady_data,1)
  [ css_mag, css_theta ] = conv_css_to_theta( calibration.steady_data(i, 1:6));
  css_deg = css_theta * 180 / pi
  if css_deg < buffer || css_deg > 360 - buffer 
    TAMzero(1) = TAMzero(1) + calibration.steady_data(i, 14);
    TAMzero(2) = TAMzero(2) + calibration.steady_data(i, 15);
    TAMzero(3) = TAMzero(3) + calibration.steady_data(i, 16);
    count = count + 1;
  end
  if css_deg < 90 + buffer && css_deg > 90 - buffer 
    TAM90(1) = TAM90(1) + calibration.steady_data(i, 14);
    TAM90(2) = TAM90(2) + calibration.steady_data(i, 15);
    TAM90(3) = TAM90(3) + calibration.steady_data(i, 16);
    count = count + 1;
  end
end
TAMzero(1) = TAMzero(1)/count;
TAMzero(2) = TAMzero(2)/count;
TAMzero(3) = TAMzero(3)/count;
TAM90(1) = TAM90(1)/count;
TAM90(2) = TAM90(2)/count;
TAM90(3) = TAM90(3)/count;
calibration.TAMzero = TAMzero;
calibration.TAM90 = TAM90;

calibartion.TAMzVec = cross(TAMzero,TAM90);


% Vector from TAM center to the TAMzero
TAMzeroVec= TAMzero - TAMcenter;
calibration.TAMzeroVec = TAMzeroVec;


bufer = 10;
for i=1:size(calibration.steady_data,1)
  pt = calibration.steady_data(i,14:16);
  vec1 = pt - TAMcenter;
  angle = AngleBetweenVectors(TAMzero,vec1)
  angle = round(atan2(pt(2),pt(1))/pi*180);
  for j=angle-buffer:angle+buffer
      if j<=0
          baseline(j+360) = pt(3); 
    elseif j>360
      baseline(j-360) = pt(3);
      else
          baseline(j) = pt(3); 
      end
  end

end
