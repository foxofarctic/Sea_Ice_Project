%% get ice data and spec data
clear;
load('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/iceData/ice_data_aug21_13_jun1_19.mat');
%%
addpath('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/matlab');
info.a = {'A21K','C36M','Q23K'};
start ='2013-08-21';
% start ='2013-08-22';
en = '2019-06-01';
for i = 1:length(info.a)
    [dates,freqTemp,dataTemp(:,:,i)] = get_spec_data(char(info.a(i)),start,en);
end
% turn all 0 data to NaN
dataTemp(dataTemp(:,:,:) == 0) = NaN;
%%
dates1 = [datenum(start):datenum(en)-1];

%% extract data from iceDat struct
lat = iceDat(1).lat;
lon = iceDat(1).lon;

%% set frequency and pixel specifications also normalizes data
% fr = 1/2.5;
% fr = 1/25;
%fr = 1/8; 
dlat(:) = [71.322098,69.347504,59.4296]; %desired lat
dlon(:) = [-156.617493,-124.070297,-146.339905];

% finds the pixel closest to station
i = 1;
while i <= length(dlat)
    [~, ind] = min(abs(lat(:)-dlat(i))+abs(lon(:)-dlon(i)));
    [r(i), c(i)] = ind2sub(size(lat),ind);
    
    % take all ice data from struct and squeeze the info needed to array
    ci(:,i) = squeeze(cat(3, iceDat(1).ci(r(i),c(i),:), iceDat(2).ci(r(i),c(i),:), iceDat(3).ci(r(i),c(i),:))); 

    %checks if all nans
    if (all(isnan(ci(:,i))))
        lat(r(i),c(i)) = NaN; lon(r(i),c(i)) = NaN;
    else
        i = i + 1;
    end
end
%%
% finds index of desired frequency 
% [~,freqInd] = min(abs(freqTemp-fr));
% for i = 1:length(info.a) % normalizes data
%     norm_data(i,:) = (dataTemp(:,freqInd,i)-min(dataTemp(:,freqInd,i)))/ (max(dataTemp(:,freqInd,i))-min(dataTemp(:,freqInd,i)));
% end
%% bin frequencies into average
% rangel= 1/20; rangem= 1/13; micName = 'Primary'; %primary
% rangel= 1/10; rangem= 1/5; micName = 'Secondary'; %secondary
% rangel= 1/5; rangem= 1/2.5; micName = 'Short'; %short
rangel= 1/2; rangem= 1/1; micName = 'Short Short';%short short


k = find((freqTemp > rangel) & (freqTemp < rangem)); %indices of all frequencies in any microseism range

for i = 1:length(info.a)
    binnedData(:,i) = mean(dataTemp(:,k,i),2);
end

 %---------------------------------------------------------% eliminate bad data points
 
% binnedData(find(dates1 == datenum('2018-01-25')):find(dates1 == datenum('2018-03-05')),1:2)= NaN;
% binnedData(find(dates1 == datenum('2019-01-15')):find(dates1 == datenum('2019-02-15')),3)= NaN;
% binnedData(find(dates1 == datenum('2019-02-01')):find(dates1 == datenum('2019-03-01')),1)= NaN;

% % binnedData(590:640,2) = NaN; % faulty data point
binnedData(361,3) = NaN; % faulty data point
binnedData(819:865,2) = NaN; % faulty data point
% binnedData(998,3) = NaN; % faulty data point
% binnedData(1415,3) = NaN; % faulty data point
% binnedData(431,3) = NaN; % faulty data point
% 
% binnedData(930:957,1) = NaN; % faulty data point
% binnedData(9,2) = NaN; % faulty data point
% binnedData(789,2) = NaN; % faulty data point
% binnedData(621:624,3) = NaN; % faulty data point
% binnedData(603,1) = NaN; % faulty data point
% binnedData(625:628,3) = NaN; % faulty data point


% [~,freqInd] = min(abs(freqTemp-fr));
for i = 1:length(info.a) % normalizes data
    norm_bin_data(:,i) = (binnedData(:,i)-min(binnedData(:,i)))/ (max(binnedData(:,i))-min(binnedData(:,i)));
end
%% bin frequencies into average -- normalize first
% % rangel= 1/20; rangem= 1/13; %primary
% % rangel= 1/10; rangem= 1/5; %secondary
% rangel= 1/5; rangem= 1/2.5; %short
% 
% k = find((freqTemp > rangel) & (freqTemp < rangem)); %indices of all frequencies in any microseism range
% 
% for i = 1:length(info.a) % normalizes data
%     norm_bin_data(:,i) = (dataTemp(:,k,i)-min(dataTemp(:,k,i)))/ (max(dataTemp(:,k,i))-min(dataTemp(:,k,i)));
% end
% % 
% % for i = 1:length(info.a)
% %     norm_bin_data(:,i) = mean(norm_data(:,i),2);
% % end
% norm_bin_data(361,3) = NaN; % faulty data point
% %binnedData(binnedData(:,:) == 0) = NaN; %% set all 0valueed frequencies to NaN
% 
% [~,freqInd] = min(abs(freqTemp-fr));

%% make plots with normalized and binned frequencies
figure(2); clf; hold on 
sgtitle(sprintf('Ice Concentration and Frequency Plots, Binned Avg for %s Microseism -- BHZ', micName))
indStartCi = length(ci)-length(dates1)+1;


for i = 1:length(info.a)
    temp1 = movmean(norm_bin_data(:,i),15);
    subplot(3,1,i); hold on
    yyaxis right % plot sea ice
    plot(dates',squeeze(ci(indStartCi:length(ci),i)),'LineWidth',2)
    ylabel('Sea Ice Conc. %');
    %ylim([0 100]);
    
    % plot frequency
    yyaxis left
    plot(dates',norm_bin_data(:,i),'LineWidth',2); % normalized
%     plot(dates',temp1,'LineWidth',2); % normalized
%     plot(dates',binnedData(:,i),'LineWidth',2); %absolute option
    title(sprintf('%s -- Frequency Range: %.3f - %.3f',char(info.a(i)),rangel, rangem));
    xlabel('Time');
    ylabel('Normalized Power');
    datetick;
end

legend('Frequency','Sea Ice Concentration','Location','southoutside')

%% make plots with normalized frequencies
% figure(1); clf; hold on 
% sgtitle('Ice Concentration and Frequency Plots ~25s period')
% for i = 1:length(info.a)
%     subplot(3,1,i); hold on
%     yyaxis right % plot sea ice
%     plot(dates',squeeze(ci(2:length(ci),i)),'LineWidth',2)
%     ylabel('Sea Ice Conc. %');
%     
%     % plot frequency
%     yyaxis left
%     plot(dates',norm_data(i,:),'LineWidth',2); % normalized
% %     plot(dates',(dataTemp(:,freqInd,i)),'LineWidth',2); %absolute option
%     title(sprintf('%s Frequency Plot for Frequency %d',char(info.a(i)),freqTemp(freqInd)));
%     xlabel('Time');
%     ylabel('Normalized Power');
%     datetick;
% end
% 
% legend('Frequency','Sea Ice Concentration','Location','southoutside')
%% fourier fit and plot
% rangel= 1/20; rangem= 1/13; %primary
% rangel= 1/10; rangem= 1/5; %secondary
% rangel= 1/5; rangem= 1/2.5; %short
rangel= 1/2; rangem= 1/1; %short short
addpath('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/FourierSeries');

k = find((freqTemp > rangel) & (freqTemp < rangem)); %indices of all frequencies in any microseism range

for i = 1:length(info.a)
    binnedData(:,i) = mean(dataTemp(:,k,i),2);
end
binnedData(361,3) = NaN; % faulty data point
%binnedData(binnedData(:,:) == 0) = NaN; %% set all 0valueed frequencies to NaN

[~,freqInd] = min(abs(freqTemp-fr));
% for i = 1:length(info.a) % normalizes data
%     norm_bin_data(:,i) = (binnedData(:,i)-min(binnedData(:,i)))/ (max(binnedData(:,i))-min(binnedData(:,i)));
% end
figure(4); clf; hold on
dates1 = dates';
for i =1:3
    
    temp = movmean(binnedData(:,i),30, 'omitnan');
    st = find(~isnan(temp));
    
    [fa,fb,ffit] = Fseries(dates1(st),temp(st),6);  
%     [fa,fb,ffit] = Fseries(dates1(st:length(dates1)),temp(st:length(temp)),10);  
    
    subplot(3,1,i); hold on
%     plot(dates1,binnedData(:,i),'LineWidth',2); 
%     plot(dates1,movmean(binnedData(:,i),30,'omitnan'),'LineWidth',2); % monthly mean!
    plot(dates1,temp,'LineWidth',2); % monthly mean!
    plot(dates1(st),ffit,'LineWidth',2);
    title(sprintf('%s Short Microseism Plot',char(info.a(i))));
    datetick;
    ylabel('Power (dB');
    corr = corrcoef(ffit,temp(st));
    corr1(i) = corr(1,2);
end
sgtitle('6 Term Fourier Transform Charts');
legend('Moving Observed Monthly Mean', 'Fourier Fit','location','southoutside');