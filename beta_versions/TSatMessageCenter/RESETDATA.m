%Reset Data
%[data, result]= readtext('sensor_log.txt', ' ', '','','numeric');
%plot_sensors(data(1:end,2:end))

tam_max(1)=max(data(1:end,14));
tam_max(2)=max(data(1:end,15));
tam_max(3)=max(data(1:end,16));
tam_min(1)=min(data(1:end,14));
tam_min(2)=min(data(1:end,15));
tam_min(3)=min(data(1:end,16));
tam_bias(1)=(tam_max(1)+tam_min(1))/2;
tam_bias(2)=(tam_max(2)+tam_min(2))/2;
tam_bias(3)=(tam_max(3)+tam_min(3))/2;

X=(data(1:end,14)-tam_bias(1))/(tam_max(1)-tam_min(1));
Y=(data(1:end,15)-tam_bias(2))/(tam_max(2)-tam_min(2));
Z=(data(1:end,16)-tam_bias(3))/(tam_max(3)-tam_min(3));

tam_theta=zeros(1,size(data,1));
for n=1:size(data,1)
    tam_theta(n) = atan(Y(n)/Z(n));
    if Y(n) < 0
        tam_theta(n) = tam_theta(n)+pi();
    end
    if tam_theta(n) < 0
        tam_theta(n) = tam_theta(n) + 2*pi();
    end
end

css_theta=zeros(1,size(data,1));
for n=1:size(data,1)
    css_theta(n) = conv_css_to_theta([data(n,3) data(n,4) ...
        data(n,5) data(n,6) data(n,7) data(n,8)]');
end
