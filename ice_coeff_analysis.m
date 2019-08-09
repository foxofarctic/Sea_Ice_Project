% % Tsai eq -- Ice Coefficient analysis 
clear;close all;
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/TsaiCoeffsFixed.mat');

figure(2);clf;hold on
x = [TsaiCoeffs.DistancefromCoastkm]';
y = [TsaiCoeffs.IceCoefficientshortshort]';
plot(x,y,'o');
title('Ice Coefficient Effect vs Distance from Coast -- 52 Stations');
xlabel('Distance from Coast (km)');
ylabel('Tsai Ice Coefficients');

%linear regression
format long;
b1 = x\y;
X = [ones(length(x),1) x];
b = X\y;
yCalc2 = X*b;
plot(x,yCalc2); % regression line
cor = corrcoef(y,yCalc2);
xl = xlim;
yl =ylim;
zline = refline(0,0) % zeroline
zline.Color = 'k'
text(xl(2)-102, yl(2)-.02,sprintf('corrcoeff: %.6f',cor(1,2)))
text(xl(2)-125, yl(2)-.01,sprintf('y = %.3f + %.6fx',b(1),b(2)))
legend('station','linear regression','Location','northwest');
figure(1); clf;
geoscatter([TsaiCoeffs.Latitude],[TsaiCoeffs.Longitude],'filled','SizeData',100)
geobasemap('landcover')
legend('Stations Used for Distance Analysis')
%% graphs of different transects -- west east
clear; 
% load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/TsaiCoeffs.mat');
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/TsaiCoeffs.mat');
% TsaiCoeffs = table2struct(TsaiCoefficients16px);
transectGroup = {["18","19","20","21","22"], ["23","24","24","25","26","27"]};
names = ["Western","Eastern"];

cont = contains([TsaiCoeffs.Station], transectGroup{1});
tind = {find(cont == 1) find(cont == 0)};
figure(2);clf; hold on

for i = 1:length(tind)
    x = [TsaiCoeffs(tind{i}).DistancefromCoastkm]';
    y = [TsaiCoeffs(tind{i}).IceCoefficientshortshort]';
    subplot(2,1,i); hold on
    plot(x,y,'o');
    
    
    format long;
    b1 = x\y;
    X = [ones(length(x),1) x];
    b = X\y;
    yCalc2 = X*b;
    plot(x,yCalc2); % regression line
    cor = corrcoef(y,yCalc2);
    
    zline = refline(0,0) % zeroline
    zline.Color = 'k'
    ylim([-.3 0.1]);
    yl = ylim;
    xl = xlim;
    text(xl(2)-102, yl(1)+.05,sprintf('corrcoeff: %.6f',cor(1,2)))
    text(xl(2)-115, yl(1)+.04,sprintf('y = %.3f + %.6fx',b(1),b(2)))
    title(sprintf('Stations on %s Alaska Transects',names(i)))
    ylabel('Tsai Ice Coefficient');
end
xlabel('Distance from Coast (km)');
legend('station','linear regression','Location','northwest');


figure;
region = categorical(cont);
gb = geobubble([TsaiCoeffs.Latitude],[TsaiCoeffs.Longitude],[],region,'BubbleWidthRange',20,'Basemap','bluegreen','LegendVisible','off');
% legend('West', 'East')
% gb.Title = 'Alaskan Map of East/West Stations';


% Make alaska Map
figure(1); clf;
geoscatter([TsaiCoeffs(tind{1}).Latitude],[TsaiCoeffs(tind{1}).Longitude],'filled','SizeData',100)
hold on;
geoscatter([TsaiCoeffs(tind{2}).Latitude],[TsaiCoeffs(tind{2}).Longitude],'filled','SizeData',100)
hold off;
geobasemap('landcover')
legend('Western Stations','Eastern Stations')