function plot_tam(tam_data,tag)

    if nargin == 1, tag = ''; end

    global TAM

    scrsz = get(0,'ScreenSize');
    if tag == ''
        figure( ...
            'Name','3D TAM Plot', ...
            'Color',[0.95 0.95 0.95], ...
            'Position',[1 scrsz(4)/3 scrsz(4)/2 scrsz(4)/2]);
    else
        figure( ...
            'Name','3D Tam Plot', ...
            'Color',[0.95 0.95 0.95], ...
            'Position',[1 scrsz(4)/3 scrsz(4)/2 scrsz(4)/2], ...
            'Tag',tag);
    end

    % Calculate the fitted plane
    A=[tam_data(:,1),tam_data(:,2),ones(size(tam_data(:,1)))];
    coeff=A\tam_data(:,3);
    % The normal vector for the fitted plane
    normal=[-coeff(1) -coeff(2) 1];
    % Rotate the normal vector
    normal = TAM.R3*TAM.R2*TAM.R1*normal';
    normal = normal'.*0.02;
    
    % Rotate points from the fitted plane to the X-Y plane according to the
    % rotation matrices calculated in the calibration routine.
    for k = 1:size(tam_data,1)
        pt = tam_data(k,:)';
        pt = TAM.R3*TAM.R2*TAM.R1*pt;
        tam_data(k,:) = pt';
    end
    
    % Calculate the center of the rotated data, and translate points.
    center = [mean(tam_data(:,1)) mean(tam_data(:,2)) mean(tam_data(:,3))];

%    for k = 1:size(tam_data,1)
%        pt = tam_data(k,:);
%       pt = pt-center;
%        tam_data(k,:) = pt;
%    end

    % Plot the rotated points in 3D space
    plot3(tam_data(:,1),tam_data(:,2),tam_data(:,3),'color','b')
    grid on;
    hold on

    % Plot the normal vector to simulate the ADP of the TSat
    data_n=[center; center+normal];
    x=data_n(:,1);
    y=data_n(:,2);
    z=data_n(:,3);
    plot3(x,y,z,'color','k','LineWidth',3)
    
    hold off