%% get ice data and spec data
clear;
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/ice_data_aug21_13_jun1_19.mat');

%% extract data from iceDat struct
lat = iceDat(1).lat;
lon = iceDat(1).lon;
dates = datenum('2013-08-21'):datenum('2019-06-01');
info.a = {'A21K','Q23K'};
numpx =1;

%% set frequency and pixel specifications also normalizes data

dlat(:) = [71.322098,59.4296]; %desire lat - A21K,Q23K
dlon(:) = [-156.617493,-146.339905]; %A21K,Q23K

% finds the pixel closest to station
i = 1;
while i <= length(dlat)
    x = 1;
    while x <= numpx
        [~, ind] = min(abs(lat(:)-dlat(i))+abs(lon(:)-dlon(i)));
        [r(i), c(i)] = ind2sub(size(lat),ind);
        
        % take all ice data from struct and squeeze the info needed to array
        ci(:,x,i) = squeeze(cat(3, iceDat(1).ci(r(i),c(i),:), iceDat(2).ci(r(i),c(i),:), iceDat(3).ci(r(i),c(i),:)));
        
        %checks if all nans
        if (all(isnan(ci(:,x,i))))
            lat(r(i),c(i)) = NaN; lon(r(i),c(i)) = NaN;
        else
            lat(r(i),c(i)) = NaN; lon(r(i),c(i)) = NaN;
            pixelx(x,i)= r(i);
            pixely(x,i)= c(i);
            x = x + 1;
        end
    end
    i = i+1;
end
%%
figure(1);clf;hold on

subplot(2,1,1);hold on
for x=1:numpx
    plot(dates,ci(:,x,1),'LineWidth', 2);
%     title(char(info.a(1)));

end
plot(dates,mean(ci(:,:,1),2),'k-','LineWidth', 2);
title(sprintf('%s -- Average sea ice for closest %d pixels',char(info.a(1)),numpx))
ylabel('Ice Concentration (%)');
datetick;
% xlim([datenum('2014-05-28') datenum('2015-10-18')])

subplot(2,1,2);hold on
for x=1:numpx
    plot(dates,mean(ci(:,:,1),2)-ci(:,x,1),'LineWidth', 2);
%     title(char(info.a(1)));
    datetick;
end
title('A21K Difference from Mean')
xlabel('Date');
ylabel('Difference from Mean (conc %)')

%%
addpath('/media/lucas/07A5541E0CB71F94/IRIS/IRIS_Sea_Ice/matlab/arctic_sea_ice');
figure(2);clf; hold on
[ci,lat,lon,x,y,h] = arcticseaice;

for i = 1:numpx
    scatter(x(pixelx(i,1),pixely(i,1)),y(pixelx(i,1),pixely(i,1)),100,'filled')
end
