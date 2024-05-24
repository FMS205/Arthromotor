%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%       Usage: Artromotor_presentation
%      Author: V. Canals, F. Mestre, M. Roca, I. Riquelme
%   Copyright: Universitat de les Illes Balears
% Description: Bloque encargado de comunicarse con el artromotor e
% incorporar las marcas en el programa de monitorización
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Versions
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 1.0: 12/03/2023 -> Version inicial operativa 
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%--------------------------------------------------------------------------
% Inicializamos el espacio de memoria 
%--------------------------------------------------------------------------
close all; 
clear all; 
clc; 
t_start = cputime;
date_start = now;

disp(' ');
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp('+++    Artromotor Presentation                                  +++');
disp('+++    V. Canals, F. Mestre, M. Roca, I. Riquelme               +++');
disp('+++    Universitat de les Illes Balears                         +++');
disp('+++    V1.1                                                     +++');
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(' ');

%--------------------------------------------------------------------------
% Inicialización del script de Matlab
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Configuramos el acceso al puerto paralelo
% LPT1 = 0xEEFC
% Driver descargado de "https://sites.google.com/a/brown.edu/lncc/home/Lab-Wiki/eeg/exp_setup"
%--------------------------------------------------------------------------
ioObj = io64;
status = io64(ioObj);
address = hex2dec('3EFC');                                                  % LPT1
data_out = 0;
io64(ioObj,address,data_out);                                               % Al inicilizar el programa borramos cualquier valor que hubiere

%--------------------------------------------------------------------------
% Configuramos el puerto serie (COMX) 
%--------------------------------------------------------------------------
Puerto='COM6';                                                              % Serial port access
s2 = serial(Puerto,'BaudRate',115200,'DataBits',8, 'TimeOut', 30, 'StopBits', 1);
serialWait = 0.001;
%--------------------------------------------------------------------------
% display the properties of serial port object in MATLAB Window
%--------------------------------------------------------------------------
disp(get(s2,{'Type','Name','Port','BaudRate','Parity','DataBits','StopBits'}));
warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
fopen(s2);                                                                  % Open serial port 
%----------------------------------------------------------------------
% Enviamos la orden de inicializacion al artromotor (Serial Port) 
%----------------------------------------------------------------------    
serial_msg_01 = [64,48,48,48,35];                                           % trama a enviar a través del puerto serie (orden de voler a posicion de equilibrio)
fwrite(s2, serial_msg_01(1), 'uint8');                                      % Use the command fwrite to send 1 byte of binary data
pause(serialWait);
fwrite(s2, serial_msg_01(2), 'uint8');                                      % Use the command fwrite to send 1 byte of binary data
pause(serialWait);
fwrite(s2, serial_msg_01(3), 'uint8');                                      % Use the command fwrite to send 1 byte of binary data
pause(serialWait);
fwrite(s2, serial_msg_01(4), 'uint8');                                      % Use the command fwrite to send 1 byte of binary data
pause(serialWait);
fwrite(s2, serial_msg_01(5), 'uint8');                                      % Use the command fwrite to send 1 byte of binary data
pause(serialWait);

%--------------------------------------------------------------------------
% cargamos las imagenes (inicilizaciones)
%--------------------------------------------------------------------------
str_app_dir=pwd;                                                            % Ruta del directorio actual
str_img_dir = [str_app_dir,'/','img'];                                      % Creamos la ruta de acceso al directorio donde se encuentran las imagenes
file_type = '*.jpg';                                                        % Tipo de fichero a leer para su fusion
list_dir_img=dir(fullfile(str_img_dir, file_type));                         % leemos todos los ficheros ubicados en dicha carpeta
files_img=char({list_dir_img.name});                                        % Listado de nombres de ficheros
files_img_size={list_dir_img.bytes};                                        % Tamaño de los ficheros ubicados en dicha carpeta

%--------------------------------------------------------------------------
% Listado de lso nombres de los ficheros de imagenes a representar en la
% pantalla
%--------------------------------------------------------------------------
list_img_files = ['2000.jpg';'2010.jpg';'2020.jpg';'2040.jpg';'2045.jpg';'2050.jpg';'2035.jpg';'2306.jpg';'2395.jpg';'8540.jpg';'2165.jpg';'2158.jpg';'2224.jpg';'2341.jpg';'2274.jpg';...  % Imagenes agradable
                  '8191.jpg';'7512.jpg';'7509.jpg';'7508.jpg';'5030.jpg';'5720.jpg';'7018.jpg';'7182.jpg';'7211.jpg';'7224.jpg';'7236.jpg';'7247.jpg';'7249.jpg';'7510.jpg';'8531.jpg';...  % Imagenes neutras
                  '2399.jpg';'2101.jpg';'2104.jpg';'2095.jpg';'2800.jpg';'2457.jpg';'9041.jpg';'2301.jpg';'2795.jpg';'2397.jpg';'2456.jpg';'2900.jpg';'9429.jpg';'2455.jpg';'2703.jpg'];    % Imagenes desagradable

black_screen_image_file = ['black_screen.jpg'];
hand_screen_image_file = ['mano.jpg'];
[f1, c1] = size(list_img_files);                                            % detectamos cuantas imagenes tenemos en la lista para respresentar


%--------------------------------------------------------------------------
% Generamos una secuencia aleatoria de numeros entre 0 y 1, de tantos
% numeros como imagenes (esto se puede cambiar por secuencia aleatoria fija
%--------------------------------------------------------------------------
srand2 = RandStream('mt19937ar');
%r1 = rand(srand2,1,f1);
%r1 = [0.97;0.957166948242946;0.485375648722841;0.800280468888800;0.141886338627215;0.421761282626275;0.915735525189067;0.792207329559554;0.959492426392903;0.655740699156587;0.0357116785741896;0.849129305868777;0.933993247757551;0.678735154857774;0.75774013057833;0.743132468124916;0.392227019534168;0.655477890177557;0.171186687811562;0.706046088019609;0.0318328463774207;0.276922984960890;0.0461713906311539;0.0971317812358475;0.823457828327293;0.694828622975817;0.317099480060861;0.950222048838355;0.0344460805029088;0.438744359656398;0.381558457093008;0.765516788149002;0.795199901137063;0.186872604554379;0.489764395788231;0.445586200710900;0.646313010111265;0.709364830858073;0.754686681982361;0.276025076998578;0.679702676853675;0.655098003973841;0.162611735194631];
load rand_sequence;
r1 = z22;

%--------------------------------------------------------------------------
% Secuencia de retraso entre la presentacion de la diferentes imagenes 
%--------------------------------------------------------------------------
                     %[Negra,Imagen,Mano,Negra]
delays_img_show_sequence = [3,2,4,5,3];                                      % Tiempos de retraso para las diferentes imagenes que se presentan en pantalla, en [s]

%--------------------------------------------------------------------------
% Indices de control (Marcas) asociados a las diferentes imagenes
% 5: pleasant
% 7: neutral
% 9: unpleasant
% 1: hand
%--------------------------------------------------------------------------
index_img_files = [5;5;5;5;5;5;5;5;5;5;5;5;5;5;5;...
                   7;7;7;7;7;7;7;7;7;7;7;7;7;7;7;...
                   9;9;9;9;9;9;9;9;9;9;9;9;9;9;9];
%--------------------------------------------------------------------------
% Aqui el programa inicia la secuencia de presentación
%--------------------------------------------------------------------------
fig = figure('Position', get(0, 'Screensize'));
WindowAPI(fig,'Position','work');
str_img_show = [str_img_dir,'/',black_screen_image_file];
imshow(str_img_show,'Border','tight','InitialMagnification','fit');
%----------------------------------------------------------------------
% % Tiempo antes del ciclo (s) 
%----------------------------------------------------------------------
pause(180);                                                                % pausa de 3 minutos

for i=1:1:f1
    %----------------------------------------------------------------------
    % Empezamos con una pantalla en negro 
    %----------------------------------------------------------------------
    str_img_show = [str_img_dir,'/',black_screen_image_file];
    imshow(str_img_show,'Border','tight','InitialMagnification','fit');
    pause(delays_img_show_sequence(1));
    %----------------------------------------------------------------------
    % Presentamos la imagen elegida 
    %----------------------------------------------------------------------
    str_img_show = [str_img_dir,'/',list_img_files(i,:)];
    imshow(str_img_show,'Border','tight','InitialMagnification','fit');
    %----------------------------------------------------------------------
    % Escribimos la marca del tipo de imagen sobre el puerto paralelo
    %----------------------------------------------------------------------
    data_out = index_img_files(i);
    io64(ioObj,address,data_out);                                           % send a mark
    pause(0.01);                                                            % dejamos fija la marca 10 ms
    %pause(2);
    data_out = 0;
    io64(ioObj,address,data_out);                                           % stop sending a signal
    pause(delays_img_show_sequence(2));
    %----------------------------------------------------------------------
    % Aqui queremos realizar el movimiento del artromotor
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    % Enviamos la orden al artromotor (Serial Port)
    %----------------------------------------------------------------------
    if (r1(i) >= 0.5)   %['@',Dir,1,Vel,'#']
        serial_msg_01 = [64,45,49,105,35];                                   % trama a enviar a través del puerto serie (bajada)
    else 
        serial_msg_01 = [64,43,49,105,35];                                   % trama a enviar a través del puerto serie (subida)
    end
    % fopen(s2);                                                              % Open serial port 
    fwrite(s2, serial_msg_01(1), 'uint8');                                  % Use the command fwrite to send 1 byte of binary data
    pause(serialWait);
    fwrite(s2, serial_msg_01(2), 'uint8');                                  % Use the command fwrite to send 1 byte of binary data
    pause(serialWait);
    fwrite(s2, serial_msg_01(3), 'uint8');                                  % Use the command fwrite to send 1 byte of binary data
    pause(serialWait);
    fwrite(s2, serial_msg_01(4), 'uint8');                                  % Use the command fwrite to send 1 byte of binary data
    pause(serialWait);
    fwrite(s2, serial_msg_01(5), 'uint8');                                  % Use the command fwrite to send 1 byte of binary data
    pause(serialWait);
    %fclose(s2);                                                             % Close serial port   
    %----------------------------------------------------------------------
    % Escribimos la marca de mano sobre el puerto paralelo
    %----------------------------------------------------------------------
    if (r1(i) >= 0.5)   %['@',Dir,1,Vel,'#']
        data_out = 2;                                                       % Enviamos la marca de la mano un "2" (sube el artromotor)
    else
        data_out = 1;                                                       % Enviamos la marca de la mano un "1" (baja el artromotor)
    end
    io64(ioObj,address,data_out);                                           % send the mark
    pause(0.01);                                                            % dejamos fija la marca 100ms
    data_out = 0;
    io64(ioObj,address,data_out);                                           % stop sending a signal 
    pause(delays_img_show_sequence(3))                                      % NUevo retraso

    %---------------------------------------------------------------------- 
    % Presentamos la imagen de la mano
    %----------------------------------------------------------------------
    str_img_show = [str_img_dir,'/',hand_screen_image_file];
    imshow(str_img_show,'Border','tight','InitialMagnification','fit');
    %----------------------------------------------------------------------
    % Debemos leer que boton del raton se ha apretado para enviar la marca
    % Para el control del raton hay que usar la funciones integradas en Figure
    %
    % You can determine which mouse event has occurred by examining the 
    % 'SelectionType' property of the figure. The property can take the 
    % following values:
    % 1. normal: left mouse button
    % 2. extend: right mouse button on a 2-button mouse;
    %            middle mouse button on a 3-button mouse
    % 3. alt:    left+right buttons on a 2-button mouse;
    %            right mouse button on a 3-button mouse
    %----------------------------------------------------------------------
    set(gcf,'WindowButtonDownFcn', @(src,event)call_send_mouse_button(fig,src,0,ioObj,address));

    uiwait(fig,delays_img_show_sequence(4));                                % Espera el tiempo hasta que apretan o que el timeout se ha alcanzado

    %----------------------------------------------------------------------
    % Presentamos una pantalla en negro
    %----------------------------------------------------------------------
    str_img_show = [str_img_dir,'/',black_screen_image_file];
    imshow(str_img_show,'Border','tight','InitialMagnification','fit');
    %----------------------------------------------------------------------
    % Enviamos la orden al artromotor (Serial Port) para voler a la
    % posición inicial
    %----------------------------------------------------------------------   

    serial_msg_01 = [64,48,49,101,35];                                       % trama a enviar a través del puerto serie (orden de voler a posicion de equilibrio)
    %fopen(s2);                                                              % Open serial port 
    fwrite(s2, serial_msg_01(1), 'uint8');                                  % Use the command fwrite to send 1 byte of binary data
    pause(serialWait);
    fwrite(s2, serial_msg_01(2), 'uint8');                                  % Use the command fwrite to send 1 byte of binary data
    pause(serialWait);
    fwrite(s2, serial_msg_01(3), 'uint8');                                  % Use the command fwrite to send 1 byte of binary data
    pause(serialWait);
    fwrite(s2, serial_msg_01(4), 'uint8');                                  % Use the command fwrite to send 1 byte of binary data
    pause(serialWait);
    fwrite(s2, serial_msg_01(5), 'uint8');                                  % Use the command fwrite to send 1 byte of binary data
    pause(serialWait);
    %fclose(s2);                                                             % Close serial port    
    pause(delays_img_show_sequence(5));
end
close (fig);
fclose(s2);                                                                 % Close serial port   
delete(s2);                                                                 % Delete Serial port
clear io64;                                                                 % Cerramos el acceso al driver del puerto paralelo


%--------------------------------------------------------------------------
% Rutina que se encarga de gestionar las interrupciones 
%--------------------------------------------------------------------------
function call_send_mouse_button(h,~,~,ioObj,address)
    seltype = get(h,'SelectionType');
        if strcmpi(seltype,'normal')
            % fprintf('left mouse button pressed!\n');
            %----------------------------------------------------------------------
            % Escribimos la marca de mano sobre el puerto paralelo
            %----------------------------------------------------------------------
            data_out = 64;                                                  % Enviamos la marca del boton izquierdo del raton "64"
            io64(ioObj,address,data_out);                                   % send the mark
            pause(0.01);                                                    % dejamos fija la marca 10ms
            data_out = 0;
            io64(ioObj,address,data_out);                                   % stop sending a signal
        elseif strcmpi(seltype,'extend:')
            % fprintf('right mouse button pressed!\n');
            data_out = 192;                                                 % Enviamos la marca del boton derecho del raton "128"
            io64(ioObj,address,data_out);                                   % send the mark
            pause(0.01);                                                     % dejamos fija la marca 10ms
            data_out = 0;
            io64(io6Obj,address,data_out);                                  % stop sending a signal
        elseif strcmpi(seltype,'alt')
            % fprintf('right mouse button pressed!\n');
            data_out = 128;                                                 % Enviamos la marca del boton derecho e izquierdo del raton "192"
            io64(ioObj,address,data_out);                                   % send the mark
            pause(0.01);                                                     % dejamos fija la marca 10ms
            data_out = 0;
            io64(ioObj,address,data_out);                                   % stop sending a signal  
        end
end



