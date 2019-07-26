%% get ice data and spec data
clear;
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/ice_data_aug21_13_jun1_19.mat');
%%
tic
addpath('/media/lucas/Elements/IRIS_Sea_Ice/matlab');
info.a = {'H16K','Q23K'};

% dlat(:) = [59.652401,59.4296]; %desire lat - P19K,Q23K
% dlon(:) = [-153.231903,-146.339905]; %P19K,Q23K
% dlat(:) = [60.384899,59.4296]; %desire lat - M11K,Q23K
% dlon(:) = [-166.201096,-146.339905]; %M11K,Q23K
% dlat(:) = [63.886398,59.4296]; %desire lat - I17KK,Q23K
% dlon(:) = [-160.695007,-146.339905]; %I17K,Q23K
dlat(:) = [64.637901,59.4296]; %desire lat - H16K,Q23K
dlon(:) = [-162.238998,-146.339905]; %H16K,Q23K
% dlat(:) = [65.3936,59.4296]; %desire lat - G16K,Q23K
% dlon(:) = [-162.354706,-146.339905]; %G16K,Q23K
% dlat(:) = [65.474197,59.4296]; %desire lat - F14K,Q23K
% dlon(:) = [-166.328796,-146.339905]; %F14K,Q23K
% dlat(:) = [67.698799,59.4296]; %desire lat - D17K,Q23K
% dlon(:) = [-163.083099,-146.339905]; %D17K,Q23K
% dlat(:) = [68.274597,59.4296]; %desire lat - C16K,Q23K
% dlon(:) = [-165.343597,-146.339905]; %C16K,Q23K
% dlat(:) = [69.364098,59.4296]; %desire lat - B18K,Q23K
% dlon(:) = [-161.801605,-146.339905]; %B18K,Q23K
% dlat(:) = [71.003304,59.4296]; %desire lat - A22K,Q23K
% dlon(:) = [-154.974197,-146.339905]; %A22K,Q23K
% dlat(:) = [70.339996,59.4296]; %desire lat - B22K,Q23K
% dlon(:) = [-153.419601,-146.339905]; %B22K,Q23K
% dlat(:) = [69.835999,59.4296]; %desire lat - C23K,Q23K
% dlon(:) = [-150.612595,-146.339905]; %C23K,Q23K
% dlat(:) = [69.720001,59.4296]; %desire lat - C24K,Q23K
% dlon(:) = [-148.700897,-146.339905]; %C24K,Q23K
% dlat(:) = [69.917503,59.4296]; %desire lat - C26K,Q23K
% dlon(:) = [-144.912201,-146.339905]; %C26K,Q23K
% dlat(:) = [69.625999,59.4296]; %desire lat - C27K,Q23K
% dlon(:) = [-143.711395,-146.339905]; %C27K,Q23K
% dlat(:) = [69.242996,59.4296]; %desire lat - D27M,Q23K
% dlon(:) = [-140.964798,-146.339905]; %D27M,Q23K
% dlat(:) = [69.328598,59.4296]; %desire lat - D28M,Q23K
% dlon(:) = [-138.736694,-146.339905]; %D28M,Q23K
% dlat(:) = [68.388901,59.4296]; %desire lat - E29M,Q23K
% dlon(:) = [-137.896896,-146.339905]; %E29M,Q23K
% dlat(:) = [70.2043,59.4296]; %desire lat - A19K,Q23K
% dlon(:) = [-161.071304,-146.339905]; %A19K,Q23K
% dlat(:) = [71.322098,59.4296]; %desire lat - A21K,Q23K
% dlon(:) = [-156.617493,-146.339905]; %A21K,Q23K
% dlat(:) = [69.347504,59.4296]; %desire lat - C36M,Q23K
% dlon(:) = [-124.070297,-146.339905]; %C36M,Q23K
% dlat(:) = [71.987099,59.4296]; %desire lat - A36M,Q23K
% dlon(:) = [-125.2472,-146.339905]; %A36M,Q23K

start ='2013-08-21';
% start ='2013-08-22';
en = '2019-06-01';
for i = 1:length(info.a)
    [dates,freqTemp,dataTemp(:,:,i)] = get_spec_data(char(info.a(i)),start,en);
end
% turn all 0 data to NaN
dataTemp(dataTemp(:,:,:) == 0) = NaN;
toc
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

% ************** bin frequencies into average *************
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

% robust fit
xdat = [binnedData(:,2) ci(2:length(ci),1)];
b = robustfit(xdat,binnedData(:,1));
fun = @(ps,xdata)ps(1)+(ps(2)*xdata(:,1))+(ps(3)*xdata(:,2));

%% plot Tsai curve
figure(1);clf; hold on

subplot(2,1,1);hold on

% plot(datesLeft, fun(ps,xdata),'b-','LineWidth', 2);
plot(dates1, binnedData(:,1),'r-','LineWidth',2);
plot(dates1,fun(b,xdat),'LineWidth', 2);


ylabel('Power(dB)'); 
cor = corrcoef(binnedData(:,1),fun(b,xdat),'Rows','complete');
yl = ylim;
xl = xlim;
text(xl(2)-250,yl(2),sprintf('corrcoeff: %.6f',cor(1,2)));
legend(sprintf('%s Observed',char(info.a(1))),'Tsai Equation - Robust')
title(sprintf('%s Data and Fitted Tsai Equation -- %s',char(info.a(1)),micName))
datetick;

subplot(2,1,2); hold on
plot(dates1,movmean(binnedData(:,1),14),'r-','LineWidth',2);
plot(dates,movmean(fun(b,xdat),14),'b-','LineWidth', 2);

cor = corrcoef(movmean(binnedData(:,1),14),movmean(fun(b,xdat),14),'Rows','complete');
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
plot(datesLeft,movmean(fun(b,xdata),14),'LineWidth', 2);


cor = corrcoef(ydata,movmean(fun(b,xdata),14));
yl = ylim;
xl = xlim;
text(xl(2)-250,yl(2),sprintf('corrcoeff: %.6f',cor(1,2)));
title(sprintf('%s - 14 Day Smoothed Version -- %s', char(info.a(1)),micName ));
datetick;
xlabel('Date');
ylabel('Power(dB)'); 
legend(sprintf('%s Observed',char(info.a(1))),'Tsai Equation','Robust Fit')


