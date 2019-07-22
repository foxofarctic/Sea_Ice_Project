clear;
javaaddpath('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/irisFetch-matlab-2.0.10/IRIS-WS-2.0.18.jar')
addpath('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/irisFetch-matlab-2.0.10');

%tr = irisFetch.Traces('IU','ANMO','10','BHZ','2010-02-27 06:30:00','2010-05-27 10:30:00');
mytrace=irisFetch.Traces('TA','M22K','--','BHZ','2017-06-01 00:00:00','2017-06-03 00:00:00')
% process the data : for example, plot it
sampletimes=linspace(mytrace.startTime,mytrace.endTime,mytrace.sampleCount);
plot(sampletimes,mytrace.data);
datetick;
%%
clear;
% Here is a more exhaustive example:  plot and label all traces in time
mytrace=irisFetch.Traces('IU','ANMO','*','LHZ,BHZ,VHZ','2010-02-27 06:45:00','2010-02-27 07:35:00');
colors=brighten(lines(numel(mytrace)),-0.33); % define line colors
for n=1:numel(mytrace)
  tr = mytrace(n);
  data=double(tr.data) ./ tr.sensitivity;    % scale the data
  sampletimes = linspace(tr.startTime,tr.endTime,tr.sampleCount);
  plot(sampletimes, data, 'color', colors(n,:));
  hold on;
end
hold off;
datetick;
ylabel(tr.sensitivityUnits); % assumes all units are the same 
title(['UI-ANMO traces, starting ', datestr(mytrace(1).startTime)]); 
legend(strcat({mytrace.channel},'-',{mytrace.location}),'location','northwest');

%%
  minmag_glob = 6;
  tstart = '2000-01-01 00:00:00';
  glob_ev = irisFetch.Events('startTime',tstart,'minimumMagnitude',minmag_glob,'baseurl','http://service.iris.edu/fdsnws/event/1/');
  figure(2); clf;
  % Here we use the MATLAB Mapping Toolbox
  h = worldmap('world');
  geoshow(h,'landareas.shp','FaceColor',[.3 .3 .3])
  l = geoshow(h,[glob_ev.PreferredLatitude],[glob_ev.PreferredLongitude],'DisplayType','point');
  set(l,'Marker','.')
  mlabel('GLineWidth',.2,'FontSize',12,'MLabelLocation',90,'MLabelParallel','south');
  title(['Global M>' num2str(minmag_glob) ' events since ' datestr(tstart(1:10),1)],'FontSize',14)
  
%%  
  minlat = 52.1178; maxlat = 75.5676;
  maxlon = -119.5965; minlon = 177.4738;
  starttime = '2015-01-01 00:00:00';
  endtime = '2017-02-01 00:00:00';
  maxmag = 10.0; minmag = 5.0;
  ok_ev = irisFetch.Events('boxcoordinates',[minlat,maxlat,minlon,maxlon],...
      'maximumMagnitude',maxmag,'minimumMagnitude',minmag,...
      'startTime',starttime,'endTime',endtime,...
      'baseurl','http://service.iris.edu/fdsnws/event/1/');
  ok_sta = irisFetch.Stations('station','TA','*','*','BH?',...
      'boxcoordinates',[minlat,maxlat,minlon,maxlon]);
  figure(2)
  plot([ok_sta.Longitude],[ok_sta.Latitude],'b^','MarkerFaceColor','b')
  deg2in=6.0/diff(xlim);
 
  hold on
  
  plot([ok_ev.PreferredLongitude],[ok_ev.PreferredLatitude],'r.',...
      'MarkerSize',20)
  
  set(gca,'units','inches','pos',...
      [1.5 1 diff(xlim)*cosd(35)*deg2in diff(ylim)*deg2in],...
      'FontSize',12,'TickDir','out')
  l = legend('TA Station','Earthquake','Location','NorthEast');
  set(l,'FontSize',12)
  xlabel('Longitude')
  ylabel('Latitude')
  title(['M>' num2str(minmag) ' -- ' datestr(starttime(1:10),1) ' to ' ...
      datestr(endtime(1:10),1) ' -- ' ...
      num2str(numel(ok_ev)) ' total events'],'FontSize',14)
%%
clear;
for i = 1:29

    mytrace=irisFetch.Traces('TA','C26K','EP','LWS',strcat('2017-06-',sprintf('%02d',i),' 00:00:00'),strcat('2017-06-',sprintf('%02d',i+1),' 00:00:00'))
    % process the data : for example, plot it
    sampletimes=linspace(mytrace(1).startTime,mytrace(1).endTime,mytrace(1).sampleCount);
    avg(i) = mean(mytrace(1).data)/10
end
figure(1);
plot(avg); 
%%
clear;
mytrace=irisFetch.Traces('TA','M22K','--','BHZ','2018-11-29 00:00:00','2018-12-02 00:00:00')
% process the data : for example, plot it
sampletimes=linspace(mytrace(1).startTime,mytrace(1).endTime,mytrace(1).sampleCount);
plot(sampletimes,mytrace(1).data);
datetick;
%% wind test
clear
addpath('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/matlab/ReadMSEEDFast.m');

X = ReadMSEEDFast('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/matlab/windyFun/A21K.TA.mseed')
figure(4); clf; hold on
for i=1:4
   plot(X(i).matlabTimeVector,(X(i).data)/10,'b'); 
   datetick;
end
%% make plot of PSD medians
clear;
info.a = {'A19K','A21K','A22K','B22K','C36M','A36M','Q23K'};
figure(2);clf;hold on
for i = 1:length(info.a)
    [x,meds] = get_pdf_median(char(info.a(i)),'2017-06-01','2017-11-01');
    plot(x,meds,'LineWidth',2);
end
xmin = .1;xmax = 200;
ymin = -200; ymax = -50; ytick =10;
axis tight; box on;
set(gca,'TickDir','out');
set(gca,'XScale','log'); n=get(gca,'XTick');
set(gca,'YTick',[ymin:ytick:ymax],'Fontsize',14);
xlabel('Period (s)','FontSize',18);
ylabel('Power [dB]','FontSize',18);
title('Median pdfs of Multiple Stations');
ylim([ymin ymax]);
xlim([xmin xmax]);
legend(info.a);
