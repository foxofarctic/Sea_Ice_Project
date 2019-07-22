addpath('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/matlab/arctic_sea_ice');

pixelData.stations = ['A21K' 'C36M' 'Q23K'];
pixelData.y = [78 65 24];
pixelData.x = [204 252 190];

figure(1); clf; hold on
[ci,lat,lon,x,y,h] = arcticseaice(datenum(2016,02,15));
cb = colorbar; 
ylabel(cb,'sea ice concentration %');
xlabel('Time');

plot(x(pixelData.x(1),pixelData.y(1)),y(pixelData.x(1),pixelData.y(1)),'ro','MarkerSize',12,'MarkerFaceColor','r');
plot(x(pixelData.x(2),pixelData.y(2)),y(pixelData.x(2),pixelData.y(2)),'ro','MarkerSize',12,'MarkerFaceColor','r');
plot(x(pixelData.x(3),pixelData.y(3)),y(pixelData.x(3),pixelData.y(3)),'ro','MarkerSize',12,'MarkerFaceColor','r');
text(x(pixelData.x(1),pixelData.y(1)),y(pixelData.x(1),pixelData.y(1)),pixelData.stations(1:4),'FontSize', 12);
text(x(pixelData.x(2),pixelData.y(2)),y(pixelData.x(2),pixelData.y(2)),pixelData.stations(5:8),'FontSize', 12);
text(x(pixelData.x(3),pixelData.y(3)),y(pixelData.x(3),pixelData.y(3)),pixelData.stations(9:12),'FontSize', 12);