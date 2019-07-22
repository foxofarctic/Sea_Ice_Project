%% wind test
clear;
addpath('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/ReadMSEEDFast.m');
% load('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/windyFun/C23KwindLWS.mat');
X = ReadMSEEDFast('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/windyFun/A19K.TA.mseed');
% X = ReadMSEEDFast('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/windyFun/C23K/C23K.TA.mseed');

%%
addpath('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/');

start = '2017-09-27';
en = '2019-07-10';
[dates,freqTemp,dataTemp(:,:)] = get_spec_data('A19K',start,en);
%% wind v power
i1 = 1;
i = 1;
x=1;
while i <= length(dates)
%     datenum(X(1).dateTimeString):datenum(X(length(X)).dateTimeString)
    C = strsplit(X(i1).dateTimeString);
    if dates(i) == datenum(C(1))
        z(i) = rms((X(i1).data)/10);    
        i1 =i1+1;
    else
        if datenum(C(1)) == dates(i-1)
            z(i-1) = rms([X(i1-1).data' X(i1).data']/10);
            i = i-1;
            i1 = i+1;
        else
            z(i) = NaN; 
        end
    end
    i = i+1;
    x = x+1;
end
%%
% rangel= 1/20; rangem= 1/13; micName = 'Primary'; %primary
% rangel= 1/10; rangem= 1/5; micName = 'Secondary';  %secondary
% rangel= 1/5; rangem= 1/2.5; micName = 'Short'; %short
% rangel= 1/2; rangem= 1/1; micName = 'Short Short';%short short
rangel = 5; rangem =15; micName = '5-15Hz';% dybing freq
% rangel= 1/40; rangem= 1/20; micName = 'Longer Periods (20-40s)'; %primary

k = find((freqTemp > rangel) & (freqTemp < rangem)); %indices of all frequencies in any microseism range

% for i = 1:length(info.a)
    binnedData = mean(dataTemp(:,k),2);
% end
%% find when turbine was installed
split = find(datenum('8/17/18') == dates)

%% Plot data
z(940) = NaN;
figure(4); clf; hold on
title(sprintf('C23K Power vs Wind--%s', micName));
scatter(z(1:(split-1)),binnedData(1:(split-1)),'LineWidth',2); 
xlabel('Daily rms Wind Speed  (m/s)')
ylabel('Daily Power (dB)');
scatter(z(split:end),binnedData(split:end),'r','LineWidth',2); 
% legend('Power','Wind');
legend('Before Turbine Install','After Turbine Install');
