% create animation of both sea ice image and pixel

clear;
addpath('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/matlab/arctic_sea_ice');
%create file for video 
v = VideoWriter('sea_ice.avi');
v.FrameRate = .5;
open(v);

%animation of map
%start day, month, year
% pixel = [165 157];

%middleton Island
pixel = [191 24];
dd = 28; 
mm = 1;
yy = 2016;
loops = 12;
Y(loops) = struct('cdata',[],'colormap',[]); %Frames Struct

figure(1); clf;
for i = 1:loops
    subplot(1,3,[2 3]); hold on;
    [ci,lat,lon,x,y,h] = arcticseaice(datenum(yy,mm,dd));
    plot(x(pixel(1),pixel(2)),y(pixel(1),pixel(2)),'r*');
    cb = colorbar;
    ylabel(cb,'sea ice concentration %');
    hold off;
    
    subplot(1,3,1);
    time(i) = i;
    conc(i) = ci(pixel(1),pixel(2));
    plot(time,conc,'r*-','LineWidth',1);
    axis([0 12 0 100]);
    legend(['Pixel at (74.0503' char(10) ',132.9399)'],'Location','northoutside')
    xlabel('Time (months from Jan 1, 1997)');
    ylabel('sea ice concentration %');
    
    % capture frame
    Y(i) = getframe(gcf);
    writeVideo(v,Y(i));
    mm = mm+1;
end
close(v);

fig = figure;
movie(fig,Y,2,2)

