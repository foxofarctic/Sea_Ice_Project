%% get ice data and spec data
clear;
addpath('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/matlab');
% info.a = {'H21K','H22K','I23K','A21K'};
info.a = {'Q23K','P23K','Q20K','A21K'};
% start ='2013-08-21';
start ='2014-08-16';
en = '2019-06-01';

for i = 1:length(info.a)-1;
    [dates,freqTemp,dataTemp(:,:,i)] = get_spec_data(char(info.a(i)),start,en);
end
% turn all 0 data to NaN
dataTemp(dataTemp(:,:,:) == 0) = NaN;
%% get A21K data
[dates,freqTemp,coastData(:,:)] = get_spec_data(char(info.a(length(info.a))),start,en);
%% take rms of all stations
avgTemp = sqrt(mean(dataTemp .* dataTemp, 3,'omitnan'))*-1;
%% subtract avg from other station
coastData(coastData(:,:,:) == 0) = NaN;
subData = coastData-avgTemp;

%% plotting

figure(1);clf;hold on
subplot(3,1,1);hold on
surf(dates,freqTemp,coastData', 'edgecolor', 'none');

view(2);
set(gca, 'YScale', 'log');
ylabel('Frequency (Hz)');
xlabel('Date');
datetick;
colorbar;
colormap('jet');
caxis([-180 -80]);
axis([datenum(start) datenum(en)+1 freqTemp(1) freqTemp(96)]);
title('A21K -- normal')

subplot(3,1,2);hold on
surf(dates,freqTemp,avgTemp', 'edgecolor', 'none');

view(2);
set(gca, 'YScale', 'log');
ylabel('Frequency (Hz)');
xlabel('Date');
datetick;
colorbar;
colormap('jet');
caxis([-180 -80]);
axis([datenum(start) datenum(en)+1 freqTemp(1) freqTemp(96)]);
title('RMSed Interior Continental Stations -- Q23K, P23K, Q20K')

subplot(3,1,3);hold on

lineU = zeros(length(avgTemp),1)+1;
lineL = zeros(length(avgTemp),1)+(1/2);

a = plot(dates,lineU,'-k','LineWidth',2);
b = plot(dates,lineL,'-b','LineWidth',2);
surf(dates,freqTemp,subData', 'edgecolor', 'none');


view(2);
set(gca, 'YScale', 'log');
ylabel('Frequency (Hz)');
xlabel('Date');
datetick;
colorbar;
colormap('jet');
% caxis([-180 -80]);
axis([datenum(start) datenum(en)+1 freqTemp(1) freqTemp(96)]);
title('A21K- Subtracted Version from Interior');

legend([b a],'.5 Hz', '1 Hz');

