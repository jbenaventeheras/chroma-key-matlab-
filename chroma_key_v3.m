        %Equipos trabajo final g-12 chroma-key-video
        
    
 clc; clear all; close all;       
% leer video
a=VideoReader('plane.mp4');
rows = 1080;
cols = 1920;

%para cada frame del video (imagen PP), insertar fondo (gran via)
for img = 1:a.NumberOfFrames;
    
    %nombrar cada frame leido
    filename=strcat('frame',num2str(img),'.jpg');
    b = read(a, img);
    
    %guardar cada frame leido
    imwrite(b,filename);

fondo=double(imread('bollo.jpg'));
%imshow(fondo);
primerplano=double(imread(filename));
%ajustar el primer plano al fondo
fondo = imresize(fondo,[rows cols]);
%imshow(primerplano);

% extraemos las matrices de color y luminancia
% 
fgR = primerplano(:,:,1);
fgG = primerplano(:,:,2);
fgB = primerplano(:,:,3);
fgY = 0.2126*fgR+0.71526*fgG+0.0772*fgB;

% extramemos la luminacia del verde
fgG_Y=mat2gray(fgG-fgY);

% calculamos el histograma
matriz = fgG_Y(:);
histo=hist(fgG_Y(:),rows);
plot([0:rows-1],histo);

% Definir y normalizar un umbral razonable para evitar derrames.
% demasiado alto recortar la imagen
% demasiado bajo permite que algo de verde atraviese el bordes
%quizas poner umbral como rango (consejo damian)
umbral = 350/rows;


% establecido en 1 en su mascara todos aquellos valores donde
% fg (G-Y) es inferior al umbral
mascara = fgG_Y < umbral;

% finalmente, guardamos para cada componente 
%el primer plano donde mascara = 1 y fondo para mascara = 0 (1-mascara = 1)
final(:,:,1)=primerplano(:,:,1).*mascara + fondo(:,:,1).*(1-mascara);
final(:,:,2)=primerplano(:,:,2).*mascara + fondo(:,:,2).*(1-mascara);
final(:,:,3)=primerplano(:,:,3).*mascara + fondo(:,:,3).*(1-mascara);

%nombramos igual para que nos sobrrescriba con frame ya montado
filename_final=strcat('frame',num2str(img),'.jpg');
 
    
 %guardar cada frame leido
imwrite(uint8(final),filename_final);



%figure(1), imshow(mat2gray(final));
%plot([0:798],histo);
end

%% Insertar frames ya montados en el video


video = VideoWriter('final_video','MPEG-4');
open(video);
for img = 1:a.NumberOfFrames;
    
I = imread(strcat('frame',num2str(img),'.jpg')); %leer imagen ya mezclada
%I = im2frame(I);  

writeVideo(video,I);  
       
end
close(video)