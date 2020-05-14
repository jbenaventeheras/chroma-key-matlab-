        %Equipos trabajo final g-12 chroma-key-video
        
    
clc; clear all; close all;       
% leer video
% leer video, formatos help -->videoreader
a=VideoReader('plane.mp4');
%resolucion del video
rows = 1080;
cols = 1920;
%Miramos el numero de frames/s del video original y con su duraci?n
%calculamos los frames que tiene para que el procesado tenga la misma
%duracion que el el original
Frames = 300;

fondo = imread('Gran_Via.jpg');
fondo = double(imresize(fondo,[rows cols]));

% Guardamos salida en un yuv
FileNameVideoOut='OUT_1920x1080_P444_8b_RGB.rgb';
FidOut = fopen(FileNameVideoOut,'w');
if FidOut <0
    fprintf('***** Error al abrir el fichero %s *****\n', FileOUT);
    fclose(FidOut);
    return;
end

%para cada frame del video (imagen PP), insertar fondo (gran via)
for img = 1:min(Frames,a.NumberOfFrames)
    
    fprintf ('- Procesando Frame: %d\n', img);
    %nombrar cada frame leido
    filename=strcat('frame',num2str(img),'.jpg');
    b = read(a, img);
    
%guardar cada frame leido
%imwrite(b,filename);


%imshow(fondo);
primerplano=double(b);
%ajustar el primer plano al fondo


% extraemos las matrices de color y luminancia
% 
fgR = primerplano(:,:,1);
fgG = primerplano(:,:,2);
fgB = primerplano(:,:,3);
fgY = 0.2126*fgR+0.71526*fgG+0.0772*fgB;

% extramemos la luminacia del verde
% fgG_Y=mat2gray(fgG-fgY);
% min(fgG_Y(:))
% max(fgG_Y(:))
fgG_Y=fgG-fgY;
%figure, imshow(fgG_Y), title('G-Y');


% Puedes obtener el valor mas frecuente con la moda;
Th = mode(fgG_Y(:));
K=40;
Rango=[Th-K Th+K];


% establecido en 1 en su mascara todos aquellos valores donde
% fg (G-Y) es inferior al umbral entre los rangos
% establecido en 1 en su mascara todos aquellos valores donde
% fg (G-Y) es inferior al umbral, esto crea una matriz logica con la dimesion
%de la resolucion en donde pondra 1 para imagen primer plano y un 0 para
%el fondo de chroma

mascara = (fgG_Y >=Rango(1) & fgG_Y <=Rango(2));
%para ficheros largos (muchos frames comentar este imshow)
%figure, imshow(double(mascara)), title('Mascara');

% finalmente, guardamos para cada componente 
%el primer plano donde mascara = 1 y fondo para mascara = 0 (1-mascara = 1)
final(:,:,1)=primerplano(:,:,1).*(1-mascara) + fondo(:,:,1).*mascara;
final(:,:,2)=primerplano(:,:,2).*(1-mascara) + fondo(:,:,2).*mascara;
final(:,:,3)=primerplano(:,:,3).*(1-mascara) + fondo(:,:,3).*mascara;

%para ficheros largos (muchos frames comentar este imshow)
%figure, imshow(uint8(final), [0 255]), title('Final');

% Escribo el frame en el video para cada componente y profunidad (8).
Write_YCbCr_444(FidOut, final(:,:,1), final(:,:,2), final(:,:,3),8);


%nombramos igual para que nos sobrrescriba con frame ya montado
filename_final=strcat('frame',num2str(img),'.jpg');
 
    
%guardar cada frame leido
%imwrite(uint8(final),filename_final);

;
end

