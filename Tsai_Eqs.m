%% get ice data and spec data
clear;
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/ice_data_aug21_13_jun1_19.mat');
%%
addpath('/media/lucas/Elements/IRIS_Sea_Ice/matlab');
info.a = {'A36M','Q23K'};


% dlat(:) = [71.322098,59.4296]; %desire lat - A21K,Q23K
% dlon(:) = [-156.617493,-146.339905]; %A21K,Q23K
% dlat(:) = [69.347504,59.4296]; %desire lat - C36M,Q23K
% dlon(:) = [-124.070297,-146.339905]; %C36M,Q23K
dlat(:) = [71.987099,59.4296]; %desire lat - A36M,Q23K
dlon(:) = [-125.2472,-146.339905]; %A36M,Q23K

start ='2013-08-21';
% start ='2013-08-22';
en = '2019-06-01';
for i = 1:length(info.a)
    [dates,freqTemp,dataTemp(:,:,i)] = get_spec_data(char(info.a(i)),start,en);
end
% turn all 0 data to NaN
dataTemp(dataTemp(:,:,:) == 0) = NaN;
%% set frequency and pixel specifications
dates1 = [datenum(start):datenum(en)-1];

% extract data from iceDat struct
lat = iceDat(1).lat;
lon = iceDat(1).lon;

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

% binnedData(484,1) = NaN;

% binnedData(find(dates1 == datenum('2018-01-25')):find(dates1 == datenum('2018-03-05')),1:2)= NaN;
% binnedData(find(dates1 == datenum('2019-01-15')):find(dates1 == datenum('2019-02-15')),3)= NaN;
% binnedData(find(dates1 == datenum('2019-02-01')):find(dates1 == datenum('2019-03-01')),1)= NaN;

% [~,freqInd] = min(abs(freqTemp-fr));
% for i = 1:length(info.a) % normalizes data
%     norm_bin_data(:,i) = (binnedData(:,i)-min(binnedData(:,i)))/ (max(binnedData(:,i))-min(binnedData(:,i)));
% end

%% do parametrization
xydat = [binnedData(1:length(binnedData),2) ci(2:length(ci),1) binnedData(1:length(binnedData),1) dates'];
xydat1 = (xydat(isfinite(xydat(:, 1)), :));
xydat1 = (xydat1(isfinite(xydat1(:, 3)), :));
xdata = xydat1(:,1:2);
ydata = xydat1(:,3);
datesLeft = xydat1(:,4);
fun = @(ps,xdata)ps(1)+(ps(2)*xdata(:,1))+(ps(3)*xdata(:,2));
x0 = [-24.516 0.8314 -23.438];
ps = lsqcurvefit(fun,x0,xdata,ydata);

%% plot Tsai curve
figure(1);clf; hold on

subplot(2,1,1);hold on
plot(datesLeft, ydata,'r-','LineWidth',2);
plot(datesLeft, fun(ps,xdata),'b-','LineWidth', 2);

ylabel('Power(dB)'); 
cor = corrcoef(ydata,fun(ps,xdata));
yl = ylim;
xl = xlim;
text(xl(2)-250,yl(2),sprintf('corrcoeff: %.6f',cor(1,2)));
legend(sprintf('%s Observed',char(info.a(1))),'Tsai Equation')
title(sprintf('%s Data and Fitted Tsai Equation -- %s',char(info.a(1)),micName))
datetick;

subplot(2,1,2); hold on
plot(datesLeft,movmean(ydata,14),'r-','LineWidth',2);
plot(datesLeft,movmean(fun(ps,xdata),14),'b-','LineWidth', 2);


cor = corrcoef(movmean(ydata,14),movmean(fun(ps,xdata),14));
yl = ylim;
xl = xlim;
text(xl(2)-250,yl(2),sprintf('corrcoeff: %.6f',cor(1,2)));
title('14 Day Smoothed Version');
datetick;
xlabel('Date');
ylabel('Power(dB)'); 

%%
figure(3);clf; hold on
% subplot(2,1,2);hold on
plot(datesLeft,movmean(ydata,14),'r-','LineWidth',2);
plot(datesLeft,movmean(fun(ps,xdata),14),'b-','LineWidth', 2);


cor = corrcoef(movmean(ydata,14),movmean(fun(ps,xdata),14));
yl = ylim;
xl = xlim;
text(xl(2)-250,yl(2),sprintf('corrcoeff: %.6f',cor(1,2)));
title(sprintf('%s - 14 Day Smoothed Version -- %s', char(info.a(1)),micName ));
datetick;
xlabel('Date');
ylabel('Power(dB)'); 
legend(sprintf('%s Observed',char(info.a(1))),'Tsai Equation')


