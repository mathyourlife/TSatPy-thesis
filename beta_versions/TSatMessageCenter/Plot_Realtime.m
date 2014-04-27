function Plot_Realtime(data, flag)

    persistent lh ylimit lb n x y
    np=200;
    
    switch flag
        case 1
            % prepare the plot
            num_plots = size(data,2);
            realtime_plot = figure( ...
                'Name','Realtime Sensor Data', ...
                'Color',[0.95 0.95 0.95]);
            for i=1:num_plots
                subplot(num_plots,1,i) 
                h(i)=get(gcf,'CurrentAxes');
                set(h(i),'xlim',[1,np])
                x=[1:np];
                y=-inf*ones(num_plots,size(x,2));
                lh(i)=line(x,y(i,1:end),...
                    'marker','.',...
                    'markersize',5,...
                    'linestyle','-');
                %lb=line([inf,inf],ylimit);
                ylimit(i,1)=inf;
                ylimit(i,2)=-inf;
                lb(i)=line([inf,inf],[-inf,inf]);
                grid on
            end
            %cmap=jet(nt);
            shg;
            n=0;
        otherwise
            n=n+1;
            % gather the data and plot in <real-time>...
             for i=1:1
                 ix=rem(n-1,np)+1;
                 if ix==1
                    ylimit(i,1)=inf;
                    ylimit(i,2)=-inf;
                 end
                 y(i,ix)= data(1,i); %.5*fix(i/np)+rand; % <- new data

                 if data(1,i) > ylimit(i,2)
                     ylimit(i,2) = data(1,i);
                 end
                 if data(1,i) < ylimit(i,1)
                     ylimit(i,1) = data(1,i)*.999;
                 end 

                 set(lh(i),...
                     'xdata',x,...
                     'ydata',y(i,1:end));
                 set(lb(i),...
                     'xdata',[ix,ix],...
                     'ydata',[ylimit(i,1), ylimit(i,2)]');
                 pause(.0001); % <- a time consuming OP
             end
        end

