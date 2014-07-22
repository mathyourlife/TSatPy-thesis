classdef tPlot < handle
  properties
    fig_id
    plot_id
    series
    labels
  end
  
  methods
    function self = tPlot(args)
      if (nargin == 0); args = struct; end
      
      self.series = {};
      self.labels = struct;
      try
        self.fig_id = args.fig_id;
      catch
        error('Missing "fig_id" argument in %s',mfilename())
      end
      try
        self.plot_id = args.plot_id;
      catch
      end
    end
    
    function removeSeries(self,args)
      if (nargin == 1); args = struct; end
      
      try
        name = args.name;
      catch
        name = 'all';
      end
      
      if (strcmp(name,'all'))
        self.series = {};
      else
        self = self.checkIfOpen();
        
        for i=1:numel(self.series)
          item = self.series{i};
          if(strcmp(name,item.name))
            delete(item.id);
            self.series(i)=[];
            break;
          end
        end
        
      end
      
    end
    
    function addSeries(self,args)
      if (nargin == 1); args = struct; end
      
      try
        type = args.type;
      catch
        error('Missing "type" argument in %s',mfilename())
      end
      try
        name = args.name;
      catch
        error('Missing "name" argument in %s',mfilename())
      end
      
      % Check if the series already exists and is drawn
      for i=1:numel(self.series)
        item = self.series{i};
        try
          if (strcmp(item.name,name)) 
            self=self.updateSeries(args);
            return;
          end
        catch
        end
      end
      
      figure(self.fig_id)
      hold on;
      
      try
        style = args.style;
      catch
        colors = 'bgrcmyk';
        pos = numel(self.series)+1;
        pos = mod(pos,7);
        if (pos == 0) pos = 7; end
        style = [colors(pos) '-'];
      end
      try
        data = args.data;
      catch
        error('Missing "data" argument in %s',mfilename())
      end
      
      try
        rgb_color = args.rgb_color;
      catch
        rgb_color = -1;
      end
      
      plotted = self.series;
      if(strcmp('plot3',type) || strcmp('sphere',type) || strcmp('surf',type))
        try
          x = args.data.x;
        catch
          error('Missing "x" argument in %s',mfilename())
        end
        try
          y = args.data.y;
        catch
          error('Missing "y" argument in %s',mfilename())
        end
        try
          z = args.data.z;
        catch
          error('Missing "z" argument in %s',mfilename())
        end
      elseif (strcmp('plot',type))
        try
          x = args.data.x;
        catch
          error('Missing "x" argument in %s',mfilename())
        end
        try
          y = args.data.y;
        catch
          error('Missing "y" argument in %s',mfilename())
        end
      end
      if (strcmp('plot3',type))
        if isempty(style)
          id = plot3(x,y,z);
        else
          if (rgb_color == -1)
            id = plot3(x,y,z,style);
          else
            id = plot3(x,y,z,style,'Color',rgb_color);
          end
        end
      elseif (strcmp('sphere',type) || strcmp('surf',type))
        id = surf(x,y,z);
        if (strcmp('surf',type))
          set(id,'FaceColor',[150/255 150/255 150/255]);
        end
      elseif (strcmp('plot',type))
        if isempty(style)
          id = plot(x,y);
        else
          id = plot(x,y,style);
        end
      end
      self.plot_id = get(id,'Parent');
      
      if (strcmp('plot3',type))
        set(self.plot_id, 'View', [322.5 15]);
      end
      try
        size = args.size;
        set(id,'Markersize',size*get(id,'Markersize'));
      catch
      end
      try
        color = args.color;
        set(id,'Margerfacecolor',color);
      catch
        colors = 'bgrcmyk';
        pos = numel(self.series)+1;
        pos = mod(pos,7);
        if (pos == 0); pos = 7; end
        set(id,'Markerfacecolor',colors(pos));
      end
      try
        set(id,'LineWidth',args.LineWidth);
      catch
      end
      
      args.id = id;
      plotted = arr_push(plotted,args);
      self.series = plotted;
      hold off;
    end
    
    function format(self,args)
      if (nargin == 1); args = struct; end
      
      try
        p_title = get(self.plot_id,'title');
        set(p_title,'string',args.title);
      catch
      end
      
      try
        set(self.plot_id,'DataAspectRatio',args.DataAspectRatio);
      catch
        set(self.plot_id,'DataAspectRatio',[1 1 1]);
      end
      
      try
        set(self.plot_id,'xgrid',args.xgrid);
      catch
      end
      try
        set(self.plot_id,'ygrid',args.ygrid);
      catch
      end
      try
        set(self.plot_id,'zgrid',args.zgrid);
      catch
      end
      
      try
        set(get(self.plot_id,'xlabel'),'string',args.xlabel);
      catch
      end
      try
        set(get(self.plot_id,'ylabel'),'string',args.ylabel);
      catch
      end
      try
        set(get(self.plot_id,'zlabel'),'string',args.zlabel);
      catch
      end
      
      try
        set(self.plot_id,'XLim',args.xlim);
      catch
      end
      try
        set(self.plot_id,'YLim',args.ylim);
      catch
      end
      try
        set(self.plot_id,'ZLim',args.zlim);
      catch
      end
      
    end
    
    function updateSeries(self,args)
      if (nargin == 1); args = struct; end
      
      try
        name = args.name;
      catch
        error('Missing "name" argument in %s',mfilename())
      end
      try
        data = args.data;
      catch
        error('Missing "data" argument in %s',mfilename())
      end
      for i=1:numel(self.series)
        item = self.series{i};
        if(~strcmp(name,item.name))
          continue
        end
        try
          type = item.type;
        catch
          error('Missing "type" argument in %s',mfilename())
        end
        try
          id = item.id;
        catch
          error('Missing "id" argument in %s',mfilename())
        end
        
        try
          findobj(id);
        catch
          newArgs={};
          for j=1:size(args,2)
            if (~strcmp(args{j}{1},'id'))
              newArgs = arr_push(newArgs,args{j});
            end
          end
          self = self.addSeries(newArgs);
          return;
        end
        
        if (strcmp('plot3',type))
          try
            x = data.x;
          catch
            error('Missing "x" argument in %s',mfilename())
          end
          try
            y = data.y;
          catch
            error('Missing "y" argument in %s',mfilename())
          end
          try
            z = data.z;
          catch
            error('Missing "z" argument in %s',mfilename())
          end
          
          set(id,'xdata',x);
          set(id,'ydata',y);
          set(id,'zdata',z);
        elseif (strcmp('sphere',type) || strcmp('surf',type))
          try
            x = data.x;
          catch
            error('Missing "x" argument in %s',mfilename())
          end
          try
            y = data.y;
          catch
            error('Missing "x" argument in %s',mfilename())
          end
          try
            z = data.z;
          catch
            error('Missing "x" argument in %s',mfilename())
          end
          
          set(id,'xdata',x);
          set(id,'ydata',y);
          set(id,'zdata',z);
        elseif (strcmp('plot',type))
          try
            x = data.x;
          catch
            error('Missing "x" argument in %s',mfilename())
          end
          try
            y = data.y;
          catch
            error('Missing "x" argument in %s',mfilename())
          end
          
          set(id,'xdata',x);
          set(id,'ydata',y);
        end
      end
      
    
    end
    
    function title(self,args)
      if (nargin == 1); args = struct; end
      
      try
        text = args.text;
      catch
        text = '';
      end
      
      set(get(self.plot_id,'title'),'String',text)
    end
    
    function axes(self,args)
      if (nargin == 1); args = struct; end
      
      try
        set(get(self.plot_id,'xlabel'),'String',args.xlabel);
      catch
      end
      try
        set(get(self.plot_id,'ylabel'),'String',args.ylabel);
      catch
      end
      try
        set(get(self.plot_id,'zlabel'),'String',args.zlabel);
      catch
      end
      try
        set(self.plot_id,'xlim',args.xlimit);
      catch
      end
      try
        set(self.plot_id,'ylim',args.ylimit);
      catch
      end
      try
        set(self.plot_id,'zlim',args.zlimit);
      catch
      end
    
    end
    
    function grid(self,args)
      if (nargin == 0); args = struct; end
      
      try
        if (strcmp(args.x,'on'))
          set(self.plot_id,'xgrid','on')
        else
          set(self.plot_id,'xgrid','off')
        end
      catch
      end
      try
        if (strcmp(args.y,'on'))
          set(self.plot_id,'ygrid','on')
        else
          set(self.plot_id,'ygrid','off')
        end
      catch
      end
      try
        if (strcmp(args.z,'on'))
          set(self.plot_id,'zgrid','on')
        else
          set(self.plot_id,'zgrid','off')
        end
      catch
      end
      try
        if (strcmp(args.all,'on'))
          set(self.plot_id,'xgrid','on')
          set(self.plot_id,'ygrid','on')
          set(self.plot_id,'zgrid','on')
        else
          set(self.plot_id,'xgrid','off')
          set(self.plot_id,'ygrid','off')
          set(self.plot_id,'zgrid','off')
        end
      catch
      end
    end
  end
end
