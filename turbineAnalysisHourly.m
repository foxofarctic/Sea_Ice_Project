% wind test
clear;
addpath('/media/lucas/Elements/IRIS_Sea_Ice/matlab/ReadMSEEDFast.m');

X = ReadMSEEDFast('/media/lucas/Elements/IRIS_Sea_Ice/matlab/windyFun/A19K.TA.mseed');
% X = ReadMSEEDFast('data/A19K.TA.mseed');
%%
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/windyFun/A19K_PSD_full_data.mat');
% timeStr1 is a list of corresponding times for each entry
% data is power for each hour

%% frequencies we want
% rangel= 1/20; rangem= 1/13; micName = 'Primary'; %primary
% rangel= 1/10; rangem= 1/5; micName = 'Secondary';  %secondary
% rangel= 1/5; rangem= 1/2.5; micName = 'Short'; %short
% rangel= 1/2; rangem= 1/1; micName = 'Short Short';%short short
rangel = 5; rangem =15; micName = '5-15Hz';% dybing freq
% rangel= 1/40; rangem= 1/20; micName = 'Longer Periods (20-40s)'; %primary

k = find((xfreq > rangel) & (xfreq < rangem)); %indices of all frequencies in any microseism range

% for i = 1:length(info.a)
binnedData = mean(data(k,:),1);
% end

%% gets all days wind data is available -- puts it in windDays

timePSD = datetime(timeStr1);
for i=1:length(X)
    windDays(i) = datetime(X(i).dateTimeString,'InputFormat','yyyy/MM/dd HH:mm:ss.SSSSSS'); 
end
%% find avg wind spd hourly
% takes a longggggggg time to run
tic
for i=1:20 %length(timePSD)
    ind = find(windDays > timePSD(i),1)-1;
    if ind
               
        % this part makes it slow
        if ind < length(X) % for when hour bleeds to next day -- adds 1 hour of next day
            windSec = [datetime(datestr(X(ind).matlabTimeVector))' datetime(datestr(X(ind+1).matlabTimeVector(1:3600)))'];
            windData = [X(ind).data' X(ind+1).data(1:3600)'];
        else
            % only if last X entry
            windSec = datetime(datestr(X(ind).matlabTimeVector));
            windData = X(ind).data;
        end
        
        % finds indices of beginning and end of PSD
        [d indl] = min(abs(windSec - timePSD(i)));
        [d indh] = min(abs(windSec - (timePSD(i)+hours(1))));        

        
        % checks there was at least 40 minutes of data for the hour
        if indh - indl > 2400 & indh-indl < 3610 
            windHourly(i) = mean(windData(indl:indh))/10;
        else
            windHourly(i) = NaN;
        end
    else
        windHourly(i) = NaN;
    end
    i
end
toc
%% Plot data
load('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/windyFun/A19K_Hourly_2019_07_16.mat');

% find when turbine was installed
[~,split] = min(abs(datenum(timePSD) - datenum('2018/08/17')));

figure(4); clf; hold on
title(sprintf('A19K Power vs Wind Hourly PSD--%s', micName));
scatter(windHourly(1:(split-1)),binnedData(1:(split-1)),'LineWidth',2); 
xlabel('Hourly Mean Wind Speed  (m/s)')
ylabel('Hourly PSD (dB)');
scatter(windHourly(split:end),binnedData(split:end),'r','LineWidth',2); 
% legend('Power','Wind');
legend('Before Turbine Install','After Turbine Install');
% ylim([-160 -100])