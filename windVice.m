%% wind test
clear
addpath('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/matlab/ReadMSEEDFast.m');

% X = ReadMSEEDFast('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/windyFun/TA.A21K.EP.LWS.2019.001.00.00.00.000-2019.032.00.00.00.000.miniseed')
X = ReadMSEEDFast('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/windyFun/A21K.TA.WindSpeed.LWS.mseed');

%%
load('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/iceData/fast_ice_v_power.mat');
info.a = {'A21K','C36M','Q23K'};
%% bin frequencies into average
% uncomment the bin data range desired
%   rangel= 1/20; rangem= 1/13; %primary
%   rangel= 1/10; rangem= 1/5; %secondary
%   rangel= 1/5; rangem= 1/2.5; %short
% rangel= 1/2; rangem= 1/1; %short short
rangel = 5; rangem =15; % dybing freq


k = find((freqTemp > rangel) & (freqTemp < rangem)); %indices of all frequencies in any microseism range

for i = 1:length(info.a)
    binnedData(:,i) = rms(dataTemp(:,k,i),2);
end

binnedData(361,3) = NaN; % faulty data point

% for i = 1:length(info.a) % normalizes data
%     norm_bin_data(:,i) = (binnedData(:,i)-min(binnedData(:,i)))/ (max(binnedData(:,i))-min(binnedData(:,i)));
% end

%% wind v power
figure(4); clf; hold on
title('A21K -- 5-15Hz');
for i=1:length(X)
    z(i) = rms((X(i).data)/10);
    time(i) = datenum(X(i).dateTimeString);
end
xlim([time(1) time(end)]);

yyaxis right;
bar(time,z,50);
xlabel('Time');
ylabel('Wind (m/s)');

yyaxis left;
scatter(dates,binnedData(:,1),'LineWidth',2); 
ylabel('Power (dB)');

datetick;
legend('Power','Wind');

%% wind v power scatter before/ after turbine
