function varargout = tablesat3(varargin)
% TABLESAT3 M-file for tablesat3.fig
%  TABLESAT3, by itself, creates a new TABLESAT3 or raises the existing
%  singleton*.
%
%  H = TABLESAT3 returns the handle to a new TABLESAT3 or the handle to
%  the existing singleton*.
%
%  TABLESAT3('CALLBACK',hObject,eventData,handles,...) calls the local
%  function named CALLBACK in TABLESAT3.M with the given input arguments.
%
%  TABLESAT3('Property','Value',...) creates a new TABLESAT3 or raises the
%  existing singleton*.  Starting from the left, property value pairs are
%  applied to the GUI before tablesat3_OpeningFunction gets called.  An
%  unrecognized property name or invalid value makes property application
%  stop.  All inputs are passed to tablesat3_OpeningFcn via varargin.
%
%  *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%  instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tablesat3

% Last Modified by GUIDE v2.5 28-Jul-2008 14:14:14

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @tablesat3_OpeningFcn, ...
                       'gui_OutputFcn',  @tablesat3_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
% End initialization code - DO NOT EDIT


% --- Executes just before tablesat3 is made visible.
function tablesat3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tablesat3 (see VARARGIN)

    % Choose default command line output for tablesat3
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes tablesat3 wait for user response (see UIRESUME)
    % uiwait(handles.fig_tablesat);

    set_parameters
    display_plant('solid')
    set_default_disturbances()
    PID = evalin('base','PID');
    set(handles.pid_kp,'String',PID.Kp);
    set(handles.pid_ki,'String',PID.Ki);
    set(handles.pid_kd,'String',PID.Kd);
    
    %figure_position = get(handles.fig_tablesat,'position');
    %pnl_position = get(handles.pnl_model,'position');
    %text_position(1) = pnl_position(1) + pnl_position(3) + 20;
    %text_position(2) = 25;
    %text_position(3) = figure_position(3) - text_position(1) -20;
    %text_position(4) = figure_position(4) - 40; %651
    %set(handles.axes1,'position',text_position);

    draw_all_equations(handles)

% --- Outputs from this function are returned to the command line.
function varargout = tablesat3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;



%% Tab Control

function tab_model_Callback(hObject, eventdata, handles)
    switch_panel('model')
    set(hObject,'Value',1)

function tab_controller_Callback(hObject, eventdata, handles)
    switch_panel('controller')
    set(hObject,'Value',1)

function tab_noise_Callback(hObject, eventdata, handles)
    switch_panel('noise')
    set(hObject,'Value',1)

function tab_estimation_Callback(hObject, eventdata, handles)
    switch_panel('estimation')
    set(hObject,'Value',1)

function tab_analyses_Callback(hObject, eventdata, handles)
    switch_panel('analyses')
    set(hObject,'Value',1)

function tab_run_Callback(hObject, eventdata, handles)
    switch_panel('run')
    set(hObject,'Value',1)

function switch_panel(str_panel)
    handles=guihandles();

    %hide all panels first
    set(handles.pnl_model,'Visible','off')
    set(handles.pnl_controller,'Visible','off')
    set(handles.pnl_noise,'Visible','off')
    set(handles.pnl_analyses,'Visible','off')
    set(handles.pnl_run,'Visible','off')
    
    %deselect all tab commands
    set(handles.tab_model,'Value',0)
    set(handles.tab_controller,'Value',0)
    set(handles.tab_noise,'Value',0)
    set(handles.tab_estimation,'Value',0)
    set(handles.tab_analyses,'Value',0)
    set(handles.tab_run,'Value',0)
    
    switch str_panel
        case 'model'
            set(handles.pnl_model,'Visible','on')
        case 'controller'
            set(handles.pnl_controller,'Visible','on')
        case 'noise'
            set(handles.pnl_noise,'Visible','on')
        case 'analyses'
            set(handles.pnl_analyses,'Visible','on')
        case 'run'
            set(handles.pnl_run,'Visible','on')
        otherwise
            set(handles.pnl_model,'Visible','on')
    end
    

%% Run Simulation
function run_simulation_Callback(hObject, eventdata, handles)

    sim_time = get(handles.sim_time,'String');

    sim_model = 'live_run';
    
    % Flag model as simulation or live run
    if get(handles.model3,'Value')
        flag.live = 1;
    else
        flag.live = 0;
    end
    
    % Assign plant variable to the base workspace to be
    % read by the simulink model.
    plant.A = str2num(get(handles.plant_a,'String'));
    plant.B = str2num(get(handles.plant_b,'String'));
    plant.C = str2num(get(handles.plant_c,'String'));
    plant.D = str2num(get(handles.plant_d,'String'));
    plant.ic = str2num(get(handles.plant_ic,'String'));

    assignin('base','plant',plant);

    % Redimension noise vectors to match the size of the output states.
    if get(handles.chk_process_noise,'Value')
        if get(handles.process_rand,'Value')
            flag.process_noise = 1;
        elseif get(handles.process_uniform,'Value')
            flag.process_noise = 2;
        else
            flag.process_noise = 0;
        end
    else
        flag.process_noise = 0;
    end
    flag.process_noise = get(handles.chk_process_noise,'Value');
    process_noise.no_noise = zeros(num_outputs(), 1);
    process_noise.random.mean = ones(num_outputs(), 1)* ...
        str2num(get(handles.process_rand_mean,'String'));
    process_noise.random.variance = ones(num_outputs(), 1)* ...
        str2num(get(handles.process_rand_var,'String'));
    process_noise.uniform.min = ones(num_outputs(), 1)* ...
        str2num(get(handles.process_uniform_min,'String'));
    process_noise.uniform.max = ones(num_outputs(), 1)* ...
        str2num(get(handles.process_uniform_max,'String'));
    assignin('base','process_noise',process_noise);

    if get(handles.chk_measurement_noise,'Value')
        if get(handles.measurement_rand,'Value')
            flag.measurement_noise = 1;
        elseif get(handles.measurement_uniform,'Value')
            flag.measurement_noise = 2;
        else
            flag.measurement_noise = 0;
        end
    else
        flag.measurement_noise = 0;
    end
    measurement_noise.no_noise = zeros(num_outputs(), 1);
    measurement_noise.random.mean = ones(num_outputs(), 1)* ...
        str2num(get(handles.measurement_rand_mean,'String'));
    measurement_noise.random.variance = ones(num_outputs(), 1)* ...
        str2num(get(handles.measurement_rand_var,'String'));
    measurement_noise.uniform.min = ones(num_outputs(), 1)* ...
        str2num(get(handles.measurement_uniform_min,'String'));
    measurement_noise.uniform.max = ones(num_outputs(), 1)* ...
        str2num(get(handles.measurement_uniform_max,'String'));
    assignin('base','measurement_noise',measurement_noise);
    
    % Set desired states according to the system states
    desired_states = str2num(get(handles.set_points,'String'));
    assignin('base','desired_states',desired_states);    
    
    % Set controller flag
    if get(handles.controller0,'Value')
        flag.controller = 0;
    elseif get(handles.controller1,'Value')
        flag.controller = 1;
    elseif get(handles.controller2,'Value')
        flag.controller = 2;
    elseif get(handles.controller3,'Value')
        flag.controller = 3;
    else
        flag.controller = 0;
    end;

    % Set controller gains
    PID.Kp = str2num(get(handles.pid_kp,'String'));
    PID.Ki = str2num(get(handles.pid_ki,'String'));
    PID.Kd = str2num(get(handles.pid_kd,'String'));
    assignin('base','PID',PID);

    % Set all flags before simulation begins
    assignin('base','flag',flag);

    % Run the simulation
    find_system('Name',sim_model);
    open_system(sim_model);
    %set_param('sumar/Constant','Value','15');
    %set_param('sumar/Constant1','Value','-6');
    set_param(gcs,'SimulationCommand','Start');

    %options = simset('SrcWorkspace','base');
    %[timeVector,stateVector,outputVector] = ...
    %    sim(sim_model, str2num(sim_time), options);

    %Run analysis on simulation.
    if get(handles.analysis1,'Value')
        plot_outputs(timeVector,outputVector)
    end;
    if get(handles.analysis2,'Value')
        plot_bode_mag(plant)
    end;
    if get(handles.analysis3,'Value')
        plot_bode_phase(plant)
    end;
    if get(handles.analysis4,'Value')
        root_locus(plant)
    end;

    
%% System Models

function model0_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.model1,'Value',0);
    set(handles.model2,'Value',0);
    display_plant('solid')

    draw_all_equations(handles)

function model1_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.model0,'Value',0);
    set(handles.model2,'Value',0);
    display_plant('linearized')

    draw_all_equations(handles)

function model2_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.model0,'Value',0);
    set(handles.model1,'Value',0);
    display_plant('udf')

    draw_all_equations(handles)


%% Plants

% --- Display the plant values for the selected plant
function display_plant(sPlant)
    handles = guihandles();
    switch sPlant
        case 'solid'
            solid = evalin('base','solid');
            set(handles.plant_a,'String',mat2str(solid.A));
            set(handles.plant_b,'String',mat2str(solid.B));
            set(handles.plant_c,'String',mat2str(solid.C));
            set(handles.plant_d,'String',mat2str(solid.D));
            set(handles.plant_ic,'String',mat2str(solid.ic));
        case 'linearized'
            linearized = evalin('base','linearized');
            set(handles.plant_a,'String',mat2str(linearized.A));
            set(handles.plant_b,'String',mat2str(linearized.B));
            set(handles.plant_c,'String',mat2str(linearized.C));
            set(handles.plant_d,'String',mat2str(linearized.D));
            set(handles.plant_ic,'String',mat2str(linearized.ic));
        case 'udf'
            set(handles.plant_a,'String','[ ]');
            set(handles.plant_b,'String','[ ]');
            set(handles.plant_c,'String','[ ]');
            set(handles.plant_d,'String','[ ]');
            set(handles.plant_ic,'String','[ ]');
    end

function [int_count] = num_states()
    handles = guihandles();
    int_count = size(get(handles.plant_a,'String'),1);
    
function [int_count] = num_outputs()
    handles = guihandles();
    int_count = size(get(handles.plant_c,'String'),1);
    
function [int_count] = num_inputs()
    handles = guihandles();
    int_count = size(get(handles.plant_b,'String'),2);
        
function plant_a_Callback(hObject, eventdata, handles)
    draw_state_space(handles.axes2)
    
function plant_b_Callback(hObject, eventdata, handles)
    draw_state_space(handles.axes2)

function plant_c_Callback(hObject, eventdata, handles)
    draw_state_space(handles.axes2)

function plant_d_Callback(hObject, eventdata, handles)
    draw_state_space(handles.axes2)

function set_points_Callback(hObject, eventdata, handles)
    draw_ic_set_point(handles.axes1)

function plant_ic_Callback(hObject, eventdata, handles)
    draw_ic_set_point(handles.axes1)

    
%% Controllers

function controller0_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.controller1,'Value',0);
    set(handles.controller2,'Value',0);
    set(handles.controller3,'Value',0);
    display_controller('none')
    draw_control('none',handles.axes5);

function controller1_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.controller0,'Value',0);
    set(handles.controller2,'Value',0);
    set(handles.controller3,'Value',0);
    display_controller('none')
    draw_control('error',handles.axes5);

function controller2_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.controller0,'Value',0);
    set(handles.controller1,'Value',0);
    set(handles.controller3,'Value',0);
    display_controller('pid')
    draw_control('pid',handles.axes5);

function controller3_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.controller0,'Value',0);
    set(handles.controller1,'Value',0);
    set(handles.controller2,'Value',0);
    display_controller('lqr')
    draw_control('lqr',handles.axes5);

function display_controller(sController)
    handles = guihandles();
    switch sController
        case 'none'
            set(handles.pnl_pid,'Visible','off');
            set(handles.pnl_lqr,'Visible','off');
        case 'pid'
            set(handles.pnl_pid,'Visible','on');
            set(handles.pnl_lqr,'Visible','off');
        case 'lqr'
            set(handles.pnl_pid,'Visible','off');
            set(handles.pnl_lqr,'Visible','on');
    end

    
%% PID Controller

function pid_kp_Callback(hObject, eventdata, handles)
    draw_control('pid', handles.axes5)

function pid_ki_Callback(hObject, eventdata, handles)
    draw_control('pid', handles.axes5)

function pid_kd_Callback(hObject, eventdata, handles)
    draw_control('pid', handles.axes5)


%% Analysis



%% Latex

function draw_all_equations(handles)
    draw_ic_set_point(handles.axes1);
    draw_state_space(handles.axes2);
    draw_measured_states(handles.axes3);
    draw_error_signal(handles.axes4);

    if get(handles.controller0,'Value')
        draw_control('none',handles.axes5);
    elseif get(handles.controller1,'Value')
        draw_control('error',handles.axes5);
    elseif get(handles.controller2,'Value')
        draw_control('pid',handles.axes5);
    else 
        draw_control('none',handles.axes5);
    end

function draw_error_signal(axes_handle);
    str_equation = create_latex_error;
    font_size = 15;
    cla(axes_handle,'reset')
    %set(axes_handle,'Color',get(0,'defaultUicontrolBackgroundColor'));
    set(axes_handle,'Visible','off');
    display_text = text(.5,.9,'','Interpreter','latex',...
        'VerticalAlignment','top','HorizontalAlignment','center',...
        'FontSize',font_size,'Parent',axes_handle);
    str_equation(str_equation==10)=' ';
    if isempty(str_equation)
        str_equation = ' ';
    end
    set(display_text,'String',['$$' str_equation '$$']);
    resize_equation(display_text,font_size);
    
    
function draw_measured_states(axes_handle)
    str_equation = create_latex_measured;
    font_size = 15;
    cla(axes_handle,'reset')
    %set(axes_handle,'Color',get(0,'defaultUicontrolBackgroundColor'));
    set(axes_handle,'Visible','off');
    display_text = text(.5,.9,'','Interpreter','latex',...
        'VerticalAlignment','top','HorizontalAlignment','center',...
        'FontSize',font_size,'Parent',axes_handle);
    str_equation(str_equation==10)=' ';
    if isempty(str_equation)
        str_equation = ' ';
    end
    set(display_text,'String',['$$' str_equation '$$']);
    resize_equation(display_text,font_size);
    
function draw_ic_set_point(axes_handle)
%    str_equation = '\alpha x_1^2 + \beta x_2^2';
    str_equation = ['\begin{array}{ll}' char(10) ...
        create_latex_ic '\ &' char(10) ...
        create_latex_set_points ' \\' char(10)  ...
        '\end{array}'];

    font_size = 15;
    cla(axes_handle,'reset')
    %set(axes_handle,'Color',get(0,'defaultUicontrolBackgroundColor'));
    set(axes_handle,'Visible','off');
    display_text = text(.5,.9,'','Interpreter','latex',...
        'VerticalAlignment','top','HorizontalAlignment','center',...
        'FontSize',font_size,'Parent',axes_handle);
    str_equation(str_equation==10)=' ';
    if isempty(str_equation)
        str_equation = ' ';
    end
    set(display_text,'String',['$$' str_equation '$$']);
    resize_equation(display_text,font_size);
    
function draw_state_space(axes_handle)
%    str_equation = '\alpha x_1^2 + \beta x_2^2';
    str_equation = ['\begin{array}{l}' char(10) ...
        create_latex_plant ' \\' char(10) ...
        ' \\' char(10) ...
        create_latex_output ' \\' char(10)  ...
        '\end{array}'];

    font_size = 15;
    cla(axes_handle,'reset')
    %set(axes_handle,'Color',get(0,'defaultUicontrolBackgroundColor'));
    set(axes_handle,'Visible','off');
    display_text = text(.5,.9,'','Interpreter','latex',...
        'VerticalAlignment','top','HorizontalAlignment','center',...
        'FontSize',font_size,'Parent',axes_handle);
    str_equation(str_equation==10)=' ';
    if isempty(str_equation)
        str_equation = ' ';
    end
    set(display_text,'String',['$$' str_equation '$$']);
    resize_equation(display_text,font_size);

function draw_control(control_type, axes_handle)
%    str_equation = '\alpha x_1^2 + \beta x_2^2';
    switch control_type
        case 'none'
            str_equation = ['\begin{array}{l}' char(10) ...
                create_latex_no_control ' \\' char(10) ...
                '\end{array}'];
        case 'error'
            str_equation = ['\begin{array}{l}' char(10) ...
                create_latex_error_signal ' \\' char(10) ...
                '\end{array}'];
        case 'pid'
            str_equation = ['\begin{array}{l}' char(10) ...
                create_latex_pid ' \\' char(10) ...
                '\end{array}'];
        case 'lqr'
            
        case 'smo'
            
        otherwise
            str_equation = ['\begin{array}{l}' char(10) ...
                create_latex_pid ' \\' char(10) ...
                '\end{array}'];
    end

    font_size = 15;
    cla(axes_handle,'reset')
    %set(axes_handle,'Color',get(0,'defaultUicontrolBackgroundColor'));
    set(axes_handle,'Visible','off');
    display_text = text(.5,.9,'','Interpreter','latex',...
        'VerticalAlignment','top','HorizontalAlignment','center',...
        'FontSize',font_size,'Parent',axes_handle);
    str_equation(str_equation==10)=' ';
    if isempty(str_equation)
        str_equation = ' ';
    end
    set(display_text,'String',['$$' str_equation '$$']);
    resize_equation(display_text,font_size);

function resize_equation(t,font_size)
    fsize = font_size;
    set(t,'FontSize',fsize);
    ex = get(t,'Extent');
    if ex(3) > 1
        fsize = fsize/ex(3);
        set(t,'FontSize',fsize);
    end
    ex = get(t,'Extent');
    if ex(4) > 1
        fsize = fsize/ex(4);
        set(t,'FontSize',fsize);
    end
    
function [latex_string] = create_latex_measured()
    handles = guihandles();
    str_main_equation = ['\begin{array}{l}' char(10) ...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'ym', 'normal', 't', 1) ' = '...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'y', 'normal', 't', 1)];
    
    str_conditions = '';
    if get(handles.chk_process_noise,'Value')
        if get(handles.process_rand,'Value')
            str_main_equation = [str_main_equation ' + ' ...
                create_latex_vector( ...
                    eye(size(str2num(get(handles.plant_c,'String')) ...
                    ,1)), 'p', 'normal', '\gamma', 1)];
            str_conditions = ['\overline{\gamma}=' ...
                get(handles.process_rand_mean,'String') ...
                ', \gamma_{\sigma^2}=' ...
                get(handles.process_rand_var,'String') ...
                '\ '];
            
        elseif get(handles.process_uniform,'Value')
            str_main_equation = [str_main_equation ' + ' ...
                create_latex_vector( ...
                    eye(size(str2num(get(handles.plant_c,'String')) ...
                    ,1)), 'p', 'normal', '\gamma', 1)];
            str_conditions = ['\gamma_{min}=' ...
                get(handles.process_uniform_min,'String') ...
                ', \gamma_{max}=' ...
                get(handles.process_uniform_max,'String') ...
                '\ '];
            
        end
    end
    if get(handles.chk_measurement_noise,'Value')
        if get(handles.measurement_rand,'Value')
            str_main_equation = [str_main_equation ' + ' ...
                create_latex_vector( ...
                    eye(size(str2num(get(handles.plant_c,'String')) ...
                    ,1)), 'm', 'normal', '\xi', 1)];
            str_conditions = [str_conditions '\overline{\xi}=' ...
                get(handles.measurement_rand_mean,'String') ...
                ', \xi_{\sigma^2}=' ...
                get(handles.measurement_rand_var,'String') ...
                '\ '];
            
        elseif get(handles.measurement_uniform,'Value')
            str_main_equation = [str_main_equation ' + ' ...
                create_latex_vector( ...
                    eye(size(str2num(get(handles.plant_c,'String')) ...
                    ,1)), 'm', 'normal', '\xi', 1)];
            str_conditions = [str_conditions '\xi_{min}=' ...
                get(handles.measurement_uniform_min,'String') ...
                ', \xi_{max}=' ...
                get(handles.measurement_uniform_max,'String') ...
                '\ '];
            
        end
    end
    latex_string = [str_main_equation '\\' char(10) ...
        str_conditions '\end{array}'];

    if get(handles.chk_measurement_noise,'Value')
        if get(handles.measurement_rand,'Value')
            flag.measurement_noise = 1;
        elseif get(handles.measurement_uniform,'Value')
            flag.measurement_noise = 2;
        else
            flag.measurement_noise = 0;
        end
    else
        flag.measurement_noise = 0;
    end
    
function [latex_string] = create_latex_no_control()
    handles = guihandles();
    latex_string = [ ...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'u', 'normal', 't', 1) ' = '...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'r', 'normal', 't', 2)];    

function [latex_string] = create_latex_error_signal()
    handles = guihandles();
    latex_string = [ ...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'u', 'normal', 't', 1) ' = '...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'e', 'normal', 't', 2)];    

function [latex_string] = create_latex_pid()
    handles = guihandles();
    latex_string = [ ...
        create_latex_vector(str2num(get(handles.pid_kp,'String')), ...
            'u', 'normal', 't', 1) ' = '...
        create_latex_matrix(str2num(get(handles.pid_kp,'String'))) ...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'e', 'normal', 't', 2) ' + '...
        create_latex_matrix(str2num(get(handles.pid_ki,'String'))) ...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'e', 'int', 't', 2) ' + '...
        create_latex_matrix(str2num(get(handles.pid_kd,'String'))) ...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'e', 'deriv', 't', 2)];    

function [latex_string] = create_latex_plant()
    handles = guihandles();
    latex_string = [ ...
        create_latex_vector(str2num(get(handles.plant_a,'String')), ...
            'x', 'deriv', 't', 1) ' = '...
        create_latex_matrix(str2num(get(handles.plant_a,'String'))) ...
        create_latex_vector(str2num(get(handles.plant_a,'String')), ...
            'x', 'normal', 't', 2) ' + '...
        create_latex_matrix(str2num(get(handles.plant_b,'String'))) ...
        create_latex_vector(str2num(get(handles.plant_b,'String')), ...
            'u', 'normal', 't', 2)];

function [latex_string] = create_latex_output()
    handles = guihandles();
    latex_string = [ ...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'y', 'normal', 't', 1) ' = '...
        create_latex_matrix(str2num(get(handles.plant_c,'String'))) ...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'x', 'normal', 't', 2) ' + '...
        create_latex_matrix(str2num(get(handles.plant_d,'String'))) ...
        create_latex_vector(str2num(get(handles.plant_d,'String')), ...
            'u', 'normal', 't', 2)];

function [latex_string] = create_latex_error()
    handles = guihandles();
    latex_string = [ ...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'e', 'normal', 't', 1) ' = '...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'r', 'normal', 't', 1) ' - '...
        create_latex_vector(str2num(get(handles.plant_c,'String')), ...
            'ym', 'normal', 't', 1)];
        
function [latex_string] = create_latex_set_points()
    handles = guihandles();
    if strcmp(get(handles.set_points,'String'),'[ ]')==1
        latex_string = [ ...
            create_latex_vector(str2num(get(handles.plant_c, ...
                'String')), 'r', 'normal', 't', 1) ' = '...
            create_latex_matrix(zeros(size(str2num( ...
                get(handles.plant_c,'String')),1),1))];
    else
        latex_string = [ ...
            create_latex_vector(str2num(get(handles.plant_c, ...
                'String')), 'r', 'normal', 't', 1) ' = '...
            create_latex_matrix(str2num( ...
                get(handles.set_points,'String')))];
    end
    
function [latex_string] = create_latex_ic()
    handles = guihandles();
    if strcmp(get(handles.plant_ic,'String'),'[ ]') == 1
        latex_string = [ ...
            create_latex_vector(str2num(get(handles.plant_c, ...
                'String')), 'y', 'normal', '0', 1) ' = '...
            create_latex_matrix(zeros(size( ...
                str2num(get(handles.plant_c,'String')),1),1))];
    else
        latex_string = [ ...
            create_latex_vector(str2num(get(handles.plant_c, ...
                'String')), 'y', 'normal', '0', 1) ' = '...
            create_latex_matrix(str2num(get(handles.plant_ic,'String')))];
    end

% Create a state matrix in latex based on the passed matlab matrix
function [latex_matrix] = create_latex_vector(mat_matrix, variable, ...
    var_op, var_time, index)

    cols='';
    for n = 1:size(mat_matrix,index)
        cols = [cols 'c'];
    end
    str_matrix=[char(10) '\left[ \begin{array}{' cols '}' char(10)];
    space = ' ';
    for n = 1:size(mat_matrix,index)
        if strcmp(var_op,'normal')
            str_matrix = [str_matrix variable '_' num2str(n) ...
                '(' var_time ')' space '\\' char(10)];
        elseif strcmp(var_op,'int')
            str_matrix = [str_matrix '\int ' variable '_' num2str(n) ...
                '(' var_time ') d' var_time space '\\' char(10)];
        elseif strcmp(var_op,'deriv')
            str_matrix = [str_matrix '\dot{' variable '}_' num2str(n) ...
                '(' var_time ')' space '\\' char(10)];
        else
            str_matrix = [str_matrix variable '_' num2str(n) ...
                '(' var_time ')' space '\\' char(10)];
        end
    end
    latex_matrix = [str_matrix ' \end{array} \right]' space];

% Convert a matlab matrix to a latex string code.
function [latex_matrix] = create_latex_matrix(mat_matlab)
    cols = '';
    for n=1:size(mat_matlab,2)
       cols = [cols 'c'];
    end
    str_matrix = [char(10) '\left[ \begin{array}{' cols '} ' char(10)];
    space = ' ';
    for m = 1:size(mat_matlab,1)
        for n = 1:size(mat_matlab,2)
            if n == size(mat_matlab,2)
                str_matrix = [str_matrix space ...
                    num2str(mat_matlab(m,n)) space '\\' char(10)];
            else
                str_matrix = [str_matrix num2str(mat_matlab(m,n)) '\ &'];
            end
        end
    end
    latex_matrix = [str_matrix ' \end{array} \right]' space];
    
%% Noise and Disturbances

function set_default_disturbances()
    handles = guihandles();
    process_noise = evalin('base','process_noise');
    measurement_noise = evalin('base','measurement_noise');

    set(handles.process_rand_mean,'String',process_noise.random.mean);
    set(handles.process_rand_var,'String',process_noise.random.variance);
    set(handles.process_uniform_min,'String',process_noise.uniform.min);
    set(handles.process_uniform_max,'String',process_noise.uniform.max);

    set(handles.measurement_rand_mean,'String', ...
        measurement_noise.random.mean);
    set(handles.measurement_rand_var,'String', ...
        measurement_noise.random.variance);
    set(handles.measurement_uniform_min,'String', ...
        measurement_noise.uniform.min);
    set(handles.measurement_uniform_max,'String', ...
        measurement_noise.uniform.max);

function tab_process_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1);
    set(handles.tab_measurement,'Value',0)
    display_noise('process')

function tab_measurement_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.tab_process,'Value',0)
    display_noise('measurement')

function display_noise(sNoise)
    handles = guihandles();
    switch sNoise 
        case 'process'
            set(handles.pnl_process_noise,'Visible','on')
            set(handles.pnl_measurement_noise,'Visible','off')
        case 'measurement'
            set(handles.pnl_process_noise,'Visible','off')
            set(handles.pnl_measurement_noise,'Visible','on')
        otherwise
            set(handles.pnl_process_noise,'Visible','off')
            set(handles.pnl_measurement_noise,'Visible','off')
    end

function chk_process_noise_Callback(hObject, eventdata, handles)
    if get(hObject,'Value')
        set(handles.pnl_process_noise_on,'Visible','on')
    else
        set(handles.pnl_process_noise_on,'Visible','off')
    end
    draw_measured_states(handles.axes3);
    
function process_rand_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.process_uniform,'Value',0)
    display_process_noise('random')
    draw_measured_states(handles.axes3);

function process_uniform_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.process_rand,'Value',0)
    display_process_noise('uniform')
    draw_measured_states(handles.axes3);

function display_process_noise(sNoise)
    handles = guihandles();
    switch sNoise 
        case 'random'
            set(handles.pnl_process_rand,'Visible','on')
            set(handles.pnl_process_uniform,'Visible','off')
        case 'uniform'
            set(handles.pnl_process_rand,'Visible','off')
            set(handles.pnl_process_uniform,'Visible','on')
        otherwise
            set(handles.pnl_process_rand,'Visible','off')
            set(handles.pnl_process_uniform,'Visible','off')
    end

function chk_measurement_noise_Callback(hObject, eventdata, handles)
    if get(hObject,'Value')
        set(handles.pnl_measurement_noise_on,'Visible','on')
    else
        set(handles.pnl_measurement_noise_on,'Visible','off')
    end
    draw_measured_states(handles.axes3);
    
function measurement_rand_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.measurement_uniform,'Value',0)
    display_measurement_noise('random')
    draw_measured_states(handles.axes3);

function measurement_uniform_Callback(hObject, eventdata, handles)
    set(hObject,'Value',1)
    set(handles.measurement_rand,'Value',0)
    display_measurement_noise('uniform')
    draw_measured_states(handles.axes3);

function display_measurement_noise(sNoise)
    handles = guihandles();
    switch sNoise 
        case 'random'
            set(handles.pnl_measurement_rand,'Visible','on')
            set(handles.pnl_measurement_uniform,'Visible','off')
        case 'uniform'
            set(handles.pnl_measurement_rand,'Visible','off')
            set(handles.pnl_measurement_uniform,'Visible','on')
        otherwise
            set(handles.pnl_measurement_rand,'Visible','off')
            set(handles.pnl_measurement_uniform,'Visible','off')
    end

function process_rand_mean_Callback(hObject, eventdata, handles)
    draw_measured_states(handles.axes3);

function process_rand_var_Callback(hObject, eventdata, handles)
    draw_measured_states(handles.axes3);

function process_uniform_min_Callback(hObject, eventdata, handles)
    draw_measured_states(handles.axes3);

function process_uniform_max_Callback(hObject, eventdata, handles)
    draw_measured_states(handles.axes3);

function measurement_rand_mean_Callback(hObject, eventdata, handles)
    draw_measured_states(handles.axes3);

function measurement_rand_var_Callback(hObject, eventdata, handles)
    draw_measured_states(handles.axes3);

function measurement_uniform_min_Callback(hObject, eventdata, handles)
    draw_measured_states(handles.axes3);

function measurement_uniform_max_Callback(hObject, eventdata, handles)
    draw_measured_states(handles.axes3);

%% Unused function calls

%---- Run Simulation
function sim_time_Callback(hObject, eventdata, handles)

function sim_time_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

%---- Plants

function plant_ic_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function plant_d_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function plant_c_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function plant_b_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function plant_a_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function set_points_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

%---- PID Controller
function pid_kp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function pid_ki_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function pid_kd_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

%---- Analysis
function analysis1_Callback(hObject, eventdata, handles)

function analysis2_Callback(hObject, eventdata, handles)

function analysis3_Callback(hObject, eventdata, handles)

function analysis4_Callback(hObject, eventdata, handles)


%---- Noise and Disturbance
function noise_process_Callback(hObject, eventdata, handles)

function noise_measurement_Callback(hObject, eventdata, handles)

function process_rand_mean_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function process_rand_var_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function process_uniform_min_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function process_uniform_max_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function measurement_rand_mean_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function measurement_rand_var_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function measurement_uniform_min_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end

function measurement_uniform_max_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        
        set(hObject,'BackgroundColor','white');
    end






% --- Executes on button press in controller4.
function controller4_Callback(hObject, eventdata, handles)
% hObject    handle to controller4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of controller4




% --- Executes on button press in model3.
function model3_Callback(hObject, eventdata, handles)
% hObject    handle to model3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of model3








% --- Executes on button press in plot_it.
function plot_it_Callback(hObject, eventdata, handles)
% hObject    handle to plot_it (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes7)

tablesat_time_stamp = evalin('base','tablesat_time_stamp');
css_theta = evalin('base','css_theta');
plot(tablesat_time_stamp-tablesat_time_stamp(1),css_theta)
guidata(hObject, handles);

% --- Executes on button press in fans_off.
function fans_off_Callback(hObject, eventdata, handles)

% Initialize connection to connection
TSsock=tsat_init(9877,'192.168.1.110');
% Send zero voltage to fans.
tsat_send_msg(4,{uint8(2)},TSsock);


