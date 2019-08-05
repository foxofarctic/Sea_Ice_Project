clear;
addpath('/media/lucas/Elements/IRIS_Sea_Ice/matlab/BlockMean_05Nov2010')
% ncfile = '/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/RN-4070_1564768398586/GEBCO_2019_-170.0_90.0_-135.0_65.0.nc'; % nc file name
ncfile = '/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/bath_data/GEBCO_2019_-180.0_90.0_-135.0_50.0.nc'; % nc file name
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/TsaiCoeffsFixed.mat');

% To get information about the nc file
%  finfo = ncinfo(ncfile)
% to display nc file
 ncdisp(ncfile)
% to read a vriable 'var' exisiting in nc file
lat = ncread(ncfile,'lat');
lon = ncread(ncfile,'lon');
elev = double(ncread(ncfile,'elevation'));

%% averages data into into smaller matrices /10
elev(find(elev>0)) = NaN;
elev = abs(elev);
T = (2*pi*elev)/(.85*2800);

X = BlockMean(lon,10,1);
Y = BlockMean(lat,10,1);
% Z = BlockMean(elev,10);
Z = BlockMean(T,10);
Z(find(Z==0)) = NaN;



%%
figure(1);clf;
% plot3([TsaiCoeffs.Longitude],[TsaiCoeffs.Latitude],ones(length(TsaiCoeffs))*4000,'ko','MarkerFaceColor','k');

% hold on
% ax1 = axes;
surf(X,Y,Z','edgecolor','none');
view(2);
% ax2 = axes;
hold on
scatter3([TsaiCoeffs.Longitude],[TsaiCoeffs.Latitude],[TsaiCoeffs.max_difference_period_s],[],[TsaiCoeffs.max_difference_period_s],'filled');
% set(ax2,'XLim',ax1.XLim);
% set(ax2,'YLim',ax2);
% ax2.ylim(ylim)
% linkaxes([ax1,ax2])
%%Hide the top axes
% ax2.Visible = 'off';
% ax2.XTick = [];
% ax2.YTick = [];
% %%Give each one its own colormap
% colormap(ax1,'winter');
% colormap(ax2,'autumn')
caxis([0 11]);
legend('Stations')
xlabel('Longitude');
ylabel('Latitude');
c = colorbar;
% set([ax1,ax2],'Position',[.17 .11 .685 .815]);
% cb1 = colorbar(ax1,'Position',[.05 .11 .0675 .815]);
% cb2 = colorbar(ax2,'Position',[.88 .11 .0675 .815]);
c.Label.String = 'Optimal Peak Excitation Period (s)';
% cb2.Label.String = 'Actual Peak Excitation Period (s)';
