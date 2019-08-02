clear;
addpath('/media/lucas/Elements/IRIS_Sea_Ice/matlab/BlockMean_05Nov2010')
ncfile = '/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/RN-4070_1564768398586/GEBCO_2019_-170.0_90.0_-135.0_65.0.nc'; % nc file name
load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/TsaiCoeffsFixed.mat');

% To get information about the nc file
%  finfo = ncinfo(ncfile)
% to display nc file
% ncdisp(ncfile)
% to read a vriable 'var' exisiting in nc file
lat = ncread(ncfile,'lat');
lon = ncread(ncfile,'lon');
elev = double(ncread(ncfile,'elevation'));

%%
elev(find(elev>0)) = NaN;
T = (2*pi*elev)/(.85*2800);

X = BlockMean(lon,10,1);
Y = BlockMean(lat,10,1);
% Z = BlockMean(elev,10);
Z = BlockMean(T,10);
Z(find(Z==0)) = NaN;



%%
figure(1);clf;
plot3([TsaiCoeffs.Longitude],[TsaiCoeffs.Latitude],ones(length(TsaiCoeffs))*4000,'ko','MarkerFaceColor','k');
hold on
surf(X,Y,Z','edgecolor','none');
view(2);
c = colorbar();
caxis([-Inf 0]);
legend('Stations')
xlabel('Longitude');
ylabel('Latitude');
c.label.String('Optimal Peak Excitation');
