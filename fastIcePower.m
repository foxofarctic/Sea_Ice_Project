% Ice v power, but with only relevant data for A21K, C36M, and Q23K
% light weight variables so my computer stops freezing
clear;

% load needed vars
load('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/iceData/fast_ice_v_power.mat');
info.a = {'A21K','C36M','Q23K'};

%% bin frequencies into average
% uncomment the bin data range desired
% rangel= 1/20; rangem= 1/13; micName = 'primary';
% rangel= 1/10; rangem= 1/5; micName = 'secondary';
rangel= 1/5; rangem= 1/2.5; micName = 'short';
% rangel= 1/2; rangem= 1/1; micName = 'short short';


k = find((freqTemp > rangel) & (freqTemp < rangem)); %indices of all frequencies in any microseism range

for i = 1:length(info.a)
    binnedData(:,i) = mean(dataTemp(:,k,i),2);
end

binnedData(361,3) = NaN; % faulty data point

for i = 1:length(info.a) % normalizes data
    norm_bin_data(:,i) = (binnedData(:,i)-min(binnedData(:,i)))/ (max(binnedData(:,i))-min(binnedData(:,i)));
end

%% make plots with normalized and binned frequencies
figure(2); clf; hold on 
sgtitle('Ice Concentration and Frequency Plots, Binned Avg for Short Short Microseism')
for i = 1:length(info.a)
    subplot(3,1,i); hold on
    yyaxis right % plot sea ice
    plot(dates',movmean(squeeze(ci(2:length(ci),i)),15),'LineWidth',2)
    ylabel('Sea Ice Conc. %');
    %ylim([0 100]);
    
    % plot frequency
    yyaxis left
    plot(dates',movmean(norm_bin_data(:,i),15,'omitnan'),'LineWidth',2); % normalized
%     plot(dates',(dataTemp(:,freqInd,i)),'LineWidth',2); %absolute option
    title(sprintf('%s -- Frequency Range: %.3f - %.3f',char(info.a(i)),rangel, rangem));
    xlabel('Time');
    ylabel('Normalized Power');
    datetick;
end
legend('Frequency','Sea Ice Concentration','Location','southoutside')
%% do parametrization
xydat = [binnedData(1:length(binnedData),3) ci(2:length(ci),1) binnedData(1:length(binnedData),1) dates'];
xydat1 = (xydat(isfinite(xydat(:, 1)), :));
xydat1 = (xydat1(isfinite(xydat1(:, 3)), :));
xdata = xydat1(:,1:2);
ydata = xydat1(:,3);
datesLeft = xydat1(:,4);
fun = @(ps,xdata)ps(1)+(ps(2)*xdata(:,1))+(ps(3)*xdata(:,2));
x0 = [-24.516 0.8314 -23.438];
ps = lsqcurvefit(fun,x0,xdata,ydata);

%% plot Tsai curve
% times = 1:length(xdata);
figure(1);clf; hold on;
plot(datesLeft,movmean(ydata,14),'r-','LineWidth',2);
% plot(datesLeft, ydata,'r-','LineWidth',2);
plot(datesLeft,movmean(fun(ps,xdata),14),'b-','LineWidth', 2);
% plot(datesLeft, fun(ps,xdata),'b-','LineWidth', 2);
datetick;
xlabel('Date');
ylabel('Power(dB)'); 
yl = ylim;
xl = xlim;
cor = corrcoef(ydata,fun(ps,xdata));
text(xl(2)-250,yl(2),sprintf('corrcoeff: %.6f',cor(1,2)));
legend('C36M Observed','Tsai Equation')
title(sprintf('C36M Data and Fitted Tsai Equation -- %s',micName))
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


figure(4); clf; hold on
dates1 = dates';
for i =1:3
    
    temp = movmean(binnedData(:,i),30, 'omitnan');
    st = find(~isnan(temp));
    
    [fa,fb,ffit] = Fseries(dates1(st),temp(st),6);  
    
    subplot(3,1,i); hold on
    plot(dates1,temp,'LineWidth',2); % monthly moving mean!
    plot(dates1(st),ffit,'LineWidth',2);
    title(sprintf('%s Short Microseism Plot',char(info.a(i))));
    datetick;
    ylabel('Power (dB');
    corr = corrcoef(ffit,temp(st));
    corr1(i) = corr(1,2);
end
sgtitle('6 Term Fourier Transform Charts');
legend('Moving Observed Monthly Mean', 'Fourier Fit','location','southoutside');
