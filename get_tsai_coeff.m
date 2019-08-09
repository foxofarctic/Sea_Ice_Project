%%
clear
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/TsaiCoeffsFixed.mat');
start ='2014-08-16';
en = '2019-06-01';
tic
for i = 1:length(TsaiCoeffs)
    [coeffs(:,i)] = get_tsai_coeffs(char(TsaiCoeffs(i).Station),'UNV',start,en); 
end
toc
%%

figure(1);clf
plot(coeffs(3,:),[TsaiCoeffs.IceCoefficientshortshort],'ko','MarkerFaceColor', 'k')
xlabel('Ice Coefficient using UNV');
ylabel('Ice Coefficient using Q23K');
title('Comparison of fits using Q23K and UNV');

%% finds tsai coefficients for given station and control station and start/endtime
function [coeffs] = get_tsai_coeffs(station1,control,startTime,endTime)
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/ice_data_aug21_13_jun1_19.mat');
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/latLonCoastDist.mat');
addpath('/media/lucas/Elements/IRIS_Sea_Ice/matlab');
info.a = {station1,control};
stationList = [latLonCoastDist.StationName];%get station list

indS1 = find(stationList == station1); % find index of station
indC = find(stationList == control);

% find lat and lon of stations
dlat(:) = [latLonCoastDist(indS1).Latitude,latLonCoastDist(indC).Latitude];
dlon(:) = [latLonCoastDist(indS1).Longitude,latLonCoastDist(indC).Longitude];

% get data from stations
for i = 1:length(info.a)
    [dates,freqTemp,dataTemp(:,:,i)] = get_spec_data(char(info.a(i)),startTime,endTime);
end

% turn all 0 data to NaN
dataTemp(dataTemp(:,:,:) == 0) = NaN;

% find correct starting location for ice data
iceInd = length(datenum('2013-08-21'):datenum(startTime))+1;

dates1 = [datenum(startTime):(datenum(endTime)-1)];

% extract data from iceDat struct
lat = iceDat(1).lat;
lon = iceDat(1).lon;

% finds the closest numpx pixels to station
numpx = 16; % 16 for now
i = 1;
while i <= length(dlat)
    x = 1;
    while x <= numpx
        [~, ind] = min(abs(lat(:)-dlat(i))+abs(lon(:)-dlon(i)));
        [r(i), c(i)] = ind2sub(size(lat),ind);
        
        % take all ice data from struct and squeeze the info needed to array
        ci1(:,x,i) = squeeze(cat(3, iceDat(1).ci(r(i),c(i),:), iceDat(2).ci(r(i),c(i),:), iceDat(3).ci(r(i),c(i),:)));
        
        %checks if all nans
        if (all(isnan(ci1(:,x,i))))
            lat(r(i),c(i)) = NaN; lon(r(i),c(i)) = NaN;
        else
            lat(r(i),c(i)) = NaN; lon(r(i),c(i)) = NaN;
            pixelx(x,i)= r(i);
            pixely(x,i)= c(i);
            x = x + 1;
        end
    end
    ci(:,i) = mean(ci1(iceInd:end,:,i),2);
    i = i+1;
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

% robust fit
xdat = [binnedData(:,2) ci(:,1)];
coeffs = robustfit(xdat,binnedData(:,1));

% fun = @(ps,xdata)ps(1)+(ps(2)*xdata(:,1))+(ps(3)*xdata(:,2));
end
