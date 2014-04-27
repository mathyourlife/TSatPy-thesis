function [tau, R] = autocorrelation(data,flag)
% bit flags [plot plot_titles]
R = xcorr(data-mean(data));
tau = [-(size(R)-1)/2:1:(size(R)-1)/2]';

if bitand(flag,1)>0
    plot(tau,R)
    hold on
    grid on
    if bitand(flag,2)>0
        index=find(R==max(R));
        strMsg = sprintf('Stationary Autocorrelation (Max %0.2f)',R(index));
        title(strMsg)
        xlabel('Lag')
    end
    hold off
end
