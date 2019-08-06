clear;
addpath('/media/lucas/Elements/IRIS_Sea_Ice/matlab/BlockMean_05Nov2010')
% ncfile = '/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/RN-4070_1564768398586/GEBCO_2019_-170.0_90.0_-135.0_65.0.nc'; % nc file name
ncfile = '/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/bath_data/GEBCO_2019_-180.0_90.0_-135.0_50.0.nc'; % nc file name
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/TsaiCoeffsFixed.mat');

% To get information about the nc file
%  finfo = ncinfo(ncfile)
% to display nc file
%  ncdisp(ncfile)
% to read a vriable 'var' exisiting in nc file
lat = ncread(ncfile,'lat');
lon = ncread(ncfile,'lon');
elev = double(ncread(ncfile,'elevation'));

%% averages data into into smaller matrices /10
elev(find(elev>0)) = NaN;
Z1 = BlockMean(elev,10);
Z1 = abs(Z1);
elev = abs(elev);
T = (2*pi*elev)/(.85*2800);

X = BlockMean(lon,10,1);
Y = BlockMean(lat,10,1);
Z = BlockMean(T,10);
Z(find(Z==0)) = NaN;


%% Create Bathymetry Map
figure(1);clf;

plot3([TsaiCoeffs.Longitude],[TsaiCoeffs.Latitude],ones(length(TsaiCoeffs))*4000,'ko','MarkerFaceColor','k');
view(2);
hold on
surf(X,Y,Z1','edgecolor','none');
view(2);
legend('Stations');
legend('Stations','Location','SouthWest')
xlabel('Longitude');
ylabel('Latitude');
colormap(flipud(parula))
c = colorbar;
c.Label.String = 'Bathymetry (m)';
%%
figure(2);clf;
subplot(1,2,1);
plot3([TsaiCoeffs.Longitude],[TsaiCoeffs.Latitude],ones(length(TsaiCoeffs))*4000,'ko','MarkerFaceColor','k');
xl = xlim;

hold on
surf(X,Y,Z','edgecolor','none');
view(2);

caxis([0 11]);
legend('Stations','Location','SouthWest')
xlabel('Longitude');
ylabel('Latitude');
colormap(flipud(parula))
c = colorbar;
c.Label.String = 'Optimal Peak Excitation Period (s)';
title('Expected Optimal Expectation based on Tanimoto Equation (2013)');

subplot(1,2,2);
scatter([TsaiCoeffs.Longitude],[TsaiCoeffs.max_difference_period_s],'filled')
ylim([0 3]);
xlabel('Longitude');
ylabel('Actual Excitation Period (s)');
title('Excitation Period vs Longitude');