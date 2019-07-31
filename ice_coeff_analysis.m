% % Tsai eq -- Ice Coefficient analysis 
clear;close all;
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/TsaiCoeffs.mat');
figure(1);clf;hold on
plot([TsaiCoeffs.DistancefromCoastkm],[TsaiCoeffs.IceCoefficientshortshort],'o', 'MarkerFaceColor','b');
plot([TsaiCoeffs.DistancefromCoastkm],zeros(length([TsaiCoeffs.DistancefromCoastkm])),'k');
title('Ice Coefficient Effect vs Distance from Coast -- 52 Stations');
xlabel('Distance from Coast');
ylabel('Tsai Ice Coefficients');

%%

ax = worldmap('USA');
can = load('korea');
Z= can.map;
% states = shaperead('usastatelo', 'UseGeoCoords', true);
% faceColors = makesymbolspec('Polygon',{'INDEX', [1 numel(states)], 'FaceColor',polcmap(numel(states))}); % NOTE - colors are random
% geoshow(ax, states, 'DisplayType', 'polygon','SymbolSpec', faceColors)
R = georasterref('RasterSize',size(Z),'Latlim',[60 75], 'Lonlim', [145 170]);
figure; 
worldmap(Z,R)
geoshow(Z,R,'DisplayType','surface','ZData',zeros(size(Z)),'CData',Z)
demcmap(Z)
% geoshow(ax, coastlat, coastlon,'DisplayType', 'polygon', 'FaceColor', [.45 .60 .30])

