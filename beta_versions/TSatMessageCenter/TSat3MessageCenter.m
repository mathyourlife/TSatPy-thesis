function varargout = TSat3MessageCenter(varargin)
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @TSat3MessageCenter_OpeningFcn, ...
                       'gui_OutputFcn',  @TSat3MessageCenter_OutputFcn, ...
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

% --- Executes just before TSat3MessageCenter is made visible.
function TSat3MessageCenter_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for TSat3MessageCenter
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes TSat3MessageCenter wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    TSsock=tsat_init(9877,'192.168.3.126');
    assignin('base','TSsock',TSsock);
    assignin('base','TSatMC_handles',handles);
    
function varargout = TSat3MessageCenter_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

function shutdown_Callback(hObject, eventdata, handles)
    global tsat_msg_waits tsat_timer_state tsat_timer tsat_data_fcn_call

    TSsock=evalin('base','TSsock');
    
    tsat_send_msg(4,{uint8(0)},TSsock);
    set(handles.display_info,'String', ...
        'SENDING COMMAND CLOSE TSAT PROGRAM')

    %Set # of waits to 0
    tsat_msg_waits{104}{1}=0;

    %Set max # waits before lost packet assumed
    tsat_msg_waits{104}{2}=10;

    %Turn on appropriate timer
    tsat_timer_state{104}=1;
    
    %Set flag for which function handles the call back 
    tsat_data_fcn_call{104} = 4;

    %If timer is off, then turn on timer
    if strcmp(get(tsat_timer,'Running'),'off')
        start(tsat_timer);
    end
    
    
function sendvolts_Callback(hObject, eventdata, handles)

    global tsat_msg_waits tsat_timer_state tsat_timer tsat_data_fcn_call

    TSsock=evalin('base','TSsock');
    
    fan1 = str2num(get(handles.fan1volt,'String'))*0.4 + 0.1522;
    fan2 = str2num(get(handles.fan2volt,'String'))*0.4 + 0.1522;
    fan3 = str2num(get(handles.fan3volt,'String'))*0.4 + 0.1522;
    fan4 = str2num(get(handles.fan4volt,'String'))*0.4 + 0.1522;
    
    tsat_send_msg(18,{fan1, fan2, fan3, fan4},TSsock);
    set(handles.display_info,'String', ...
        'SENDING COMMAND FOR NEW VOLTAGE SETTINGS')

    %Set # of waits to 0
    tsat_msg_waits{118}{1}=0;

    %Set max # waits before lost packet assumed
    tsat_msg_waits{118}{2}=10;

    %Turn on appropriate timer
    tsat_timer_state{118}=1;
    
    %Set flag for which function handles the call back 
    tsat_data_fcn_call{118} = 2;

    %If timer is off, then turn on timer
    if strcmp(get(tsat_timer,'Running'),'off')
        start(tsat_timer);
    end

function zerofans_Callback(hObject, eventdata, handles)

    global tsat_msg_waits tsat_timer_state tsat_timer tsat_data_fcn_call

    TSsock=evalin('base','TSsock');
    
    tsat_send_msg(4,{uint8(2)},TSsock);
    set(handles.display_info,'String', ...
        'SENDING COMMAND TO ZERO OUT ACTUATORS')

    %Set # of waits to 0
    tsat_msg_waits{104}{1}=0;

    %Set max # waits before lost packet assumed
    tsat_msg_waits{104}{2}=10;

    %Turn on appropriate timer
    tsat_timer_state{104}=1;
    
    %Set flag for which function handles the call back 
    tsat_data_fcn_call{104} = 3;

    %If timer is off, then turn on timer
    if strcmp(get(tsat_timer,'Running'),'off')
        start(tsat_timer);
    end

function requestsensordata_Callback(hObject, eventdata, handles)
    
    global tsat_msg_waits tsat_timer_state tsat_timer tsat_data_fcn_call
    
    TSsock=evalin('base','TSsock');
    
    tsat_send_msg(20,{uint8(0)},TSsock)
    set(handles.display_info,'String','SENDING REQUEST FOR SENSOR SCAN')

    %Set # of waits to 0
    tsat_msg_waits{63}{1}=0;

    %Set max # waits before lost packet assumed
    tsat_msg_waits{63}{2}=10;

    %Turn on appropriate timer
    tsat_timer_state{63}=1;
    
    %Set flag for which function handles the call back 
    tsat_data_fcn_call{63} = 1;

    %If timer is off, then turn on timer
    if strcmp(get(tsat_timer,'Running'),'off')
        start(tsat_timer);
    end

function sensorpolling_Callback(hObject, eventdata, handles)

    global tsat_msg_waits tsat_timer_state tsat_data_fcn_call
    global tsat_timer tsat_polling_timer
    
    TSsock=evalin('base','TSsock');
    
    %If the polling timer is not active, activiate it and set flags for
    %packet receipt.  If the polling timer is running, stop it.
    if strcmp(get(tsat_polling_timer,'Running'),'off')
        set(handles.sensorpolling,'String','Continuous Polling Off');
        
        tsat_send_msg(20,{uint8(0)},TSsock)

        %Set # of waits to 0
        tsat_msg_waits{63}{1}=0;

        %Set max # waits before lost packet assumed
        tsat_msg_waits{63}{2}=10;

        %Turn on appropriate timer
        tsat_timer_state{63}=1;

        %Set flag for which function handles the call back 
        tsat_data_fcn_call{63} = 1;

        %If timer is off, then turn on timer
        if strcmp(get(tsat_timer,'Running'),'off')
            start(tsat_timer);
        end
        polling_rate = str2num(get(handles.pollingrate,'String'));
        set(tsat_polling_timer,'Period',polling_rate);
        start(tsat_polling_timer);
        reply=sprintf('Sensor polling started every %d seconds.',polling_rate);
        set(handles.display_info,'String',reply)
    else
        set(handles.sensorpolling,'String','Continuous Polling On');
        set(handles.display_info,'String','Stopping Sensor Polling')
        stop(tsat_polling_timer);
    end

function setsensorrate_Callback(hObject, eventdata, handles)
    global tsat_msg_waits tsat_timer_state tsat_timer tsat_data_fcn_call

    TSsock=evalin('base','TSsock');
    
    tsat_send_msg(33,{str2num(get(handles.sensorrate,'String'))},TSsock)
    set(handles.display_info,'String', ...
        'SET SENSOR LOG RATE')

    %Set # of waits to 0
    tsat_msg_waits{133}{1}=0;

    %Set max # waits before lost packet assumed
    tsat_msg_waits{133}{2}=10;

    %Turn on appropriate timer
    tsat_timer_state{133}=1;
    
    %Set flag for which function handles the call back 
    tsat_data_fcn_call{133} = 5;

    %If timer is off, then turn on timer
    if strcmp(get(tsat_timer,'Running'),'off')
        start(tsat_timer);
    end
    
function startlog_Callback(hObject, eventdata, handles)
    
    global tsat_msg_waits tsat_timer_state tsat_timer TSatSensorLog tsat_data_fcn_call

    TSsock=evalin('base','TSsock');
    
    TSatSensorLog = [];

    tsat_send_msg(19,{uint8(1)},TSsock)
    set(handles.display_info,'String', ...
        'MESSAGE SENT TO START DETAILED SENSOR LOG')

    %Set # of waits to 0
    tsat_msg_waits{119}{1}=0;

    %Set max # waits before lost packet assumed
    tsat_msg_waits{119}{2}=10;

    %Turn on appropriate timer
    tsat_timer_state{119}=1;
    
    %Set flag for which function handles the call back 
    tsat_data_fcn_call{119} = 6;

    %If timer is off, then turn on timer
    if strcmp(get(tsat_timer,'Running'),'off')
        start(tsat_timer);
    end

function endlog_Callback(hObject, eventdata, handles)
    global tsat_msg_waits tsat_timer_state tsat_timer tsat_data_fcn_call

    TSsock=evalin('base','TSsock');
    
    tsat_send_msg(19,{uint8(0)},TSsock)
    set(handles.display_info,'String', ...
        'MESSAGE SENT TO END DETAILED SENSOR LOG')

    %Set # of waits to 0
    tsat_msg_waits{119}{1}=0;

    %Set max # waits before lost packet assumed
    tsat_msg_waits{119}{2}=10;

    %Turn on appropriate timer
    tsat_timer_state{119}=1;
    
    %Set flag for which function handles the call back 
    tsat_data_fcn_call{119} = 6;

    %If timer is off, then turn on timer
    if strcmp(get(tsat_timer,'Running'),'off')
        start(tsat_timer);
    end

function getlog_Callback(hObject, eventdata, handles)
    
    global tsat_msg_waits tsat_timer_state tsat_timer tsat_data_fcn_call

    TSsock=evalin('base','TSsock');
    
    %Send request for log size
    tsat_send_msg(23,{[0]},TSsock);

    set(handles.display_info,'String', ...
        'MESSAGE SENT TO END DETAILED SENSOR LOG')

    %Delete the current sensor log text file
    delete 'sensor_log.txt'

    %Set # of waits to 0
    tsat_msg_waits{65}{1}=0;

    %Set max # waits before lost packet assumed
    tsat_msg_waits{65}{2}=10;

    %Turn on appropriate timer
    tsat_timer_state{65}=1;
    
    %Set flag for which function handles the call back 
    tsat_data_fcn_call{65} = 8;

    %If timer is off, then turn on timer
    if strcmp(get(tsat_timer,'Running'),'off')
        start(tsat_timer);
    end

function closeconnection_Callback(hObject, eventdata, handles)
    assignin('base','TSsock','');
    assignin('base','TSatMC_handles','');
    clear pnet;

function calibrate_Callback(hObject, eventdata, handles)
    CalibrateTSat(0)

%% PID CONTROL

function pidcontrol_Callback(hObject, eventdata, handles)

    global tsat_control_timer tsat_timer_state
    
    %Initialize PID control
    control_pid(1)
    
    tsat_timer_state{63} = 1;
    
    %If timer is off, then turn on timer
    if strcmp(get(tsat_control_timer,'Running'),'off')
        start(tsat_control_timer);
    end

function pidcontrolstop_Callback(hObject, eventdata, handles)
    
    global tsat_control_timer tsat_timer_state
    
    tsat_timer_state{63} = 0;
    
    %If timer is on, then turn off timer
    if strcmp(get(tsat_control_timer,'Running'),'on')
        stop(tsat_control_timer);
    end
    zerofans_Callback(hObject, eventdata, handles)
    
%% Unused function calls

function sensordata_Callback(hObject, eventdata, handles)

function sensordata_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function sensorrate_Callback(hObject, eventdata, handles)

function sensorrate_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function fan1volt_Callback(hObject, eventdata, handles)

function fan1volt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function fan2volt_Callback(hObject, eventdata, handles)

function fan2volt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function fan3volt_Callback(hObject, eventdata, handles)

function fan3volt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function fan4volt_Callback(hObject, eventdata, handles)

function fan4volt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pollingrate_Callback(hObject, eventdata, handles)

function pollingrate_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pid_p_Callback(hObject, eventdata, handles)

function pid_p_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pid_i_Callback(hObject, eventdata, handles)

function pid_i_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pid_d_Callback(hObject, eventdata, handles)

function pid_d_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function desired_rpm_Callback(hObject, eventdata, handles)

function desired_rpm_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end







function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function control_fan_1_Callback(hObject, eventdata, handles)
% hObject    handle to control_fan_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of control_fan_1 as text
%        str2double(get(hObject,'String')) returns contents of control_fan_1 as a double


% --- Executes during object creation, after setting all properties.
function control_fan_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to control_fan_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function control_fan_2_Callback(hObject, eventdata, handles)
% hObject    handle to control_fan_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of control_fan_2 as text
%        str2double(get(hObject,'String')) returns contents of control_fan_2 as a double


% --- Executes during object creation, after setting all properties.
function control_fan_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to control_fan_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function control_fan_3_Callback(hObject, eventdata, handles)
% hObject    handle to control_fan_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of control_fan_3 as text
%        str2double(get(hObject,'String')) returns contents of control_fan_3 as a double


% --- Executes during object creation, after setting all properties.
function control_fan_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to control_fan_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function control_fan_4_Callback(hObject, eventdata, handles)
% hObject    handle to control_fan_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of control_fan_4 as text
%        str2double(get(hObject,'String')) returns contents of control_fan_4 as a double


% --- Executes during object creation, after setting all properties.
function control_fan_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to control_fan_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measured_omega_Callback(hObject, eventdata, handles)
% hObject    handle to measured_omega (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measured_omega as text
%        str2double(get(hObject,'String')) returns contents of measured_omega as a double


% --- Executes during object creation, after setting all properties.
function measured_omega_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measured_omega (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in chkMovingAverage.
function chkMovingAverage_Callback(hObject, eventdata, handles)
% hObject    handle to chkMovingAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkMovingAverage


% --- Executes on button press in chkRealtime.
function chkRealtime_Callback(hObject, eventdata, handles)
