
fclose('all');
close
clear
% read the LNM & HNM
[lnmt lnmv] = textread('LNM.dat','%f %f');
[hnmt hnmv] = textread('HNM.dat','%f %f');

%filestring = 'A19K-BHZ-2018-12-21.txt';
net = char('TA');
loc = char('A21K');
%tmp = importdata([filestring]);

%Trying to get curl work
numPSDs = 94;
startDate = '2017-12-22T00:00:00';
endDate = '2017-12-24T00:00:00';
station = 'A21K';
numFreq = 96;

%took out the final frequency section as well as the location "--" as the
%txt file does not have it.

t = sprintf('curl -g https://service.iris.edu/mustang/noise-psd/1/query?target=TA.%s..BHZ.M\134\46starttime=%s\134\46endtime=%s\134\46format=text > temp.txt', station, startDate, endDate)
system(t)

%...TA.A21K..BHZ.M&starttime=2017-12-23T00:00:00&endtime=2017-12-23T23:59:59&format=text

fileID = fopen('temp.txt');
templine = fgetl(fileID);
templine;
while(any(strncmp(templine, {'#','s','e'},1)))
        templine = fgetl(fileID);
        templine;
end


for(j = 1:numPSDs)
templine = fgetl(fileID);
while(any(strncmp(templine, {'#','s','e'},1)))
        templine = fgetl(fileID);
end
i = 1;
%templine = fgetl(fileID);
while(~any(strncmp(templine, {'#','s','e'},1)) && ~feof(fileID))
        C = strsplit(templine,', ');
        freq{j,i} = str2num(C{2});
        xfreq{i} = str2num(C{1});
        templine = fgetl(fileID);
        i=i+1;
end
end
C = strsplit(templine,', ');
freq{numPSDs,numFreq} = str2num(C{2});
xfreq{numFreq} = str2num(C{1});

%%
fclose(fileID);
colormap(cool())

    % Prepare the new file.
    vidObj = VideoWriter('A19K-BHZ-2018-12-21.avi');
    vidObj.FrameRate = 2;
 open(vidObj);
    
figure(1);
hold on;
c = colorbar;
cmap = colormap(cool(numPSDs));
c.Ticks=[0 0.25 0.5 0.75 1];
c.TickLabels={'00:00','06:00','12:00', '18:00', '24:00'};
c.Label.String = 'Time (UTC)';
      line(lnmt,lnmv,'color',[.5 .5 .5],'LineWidth',2);
      text(.105,-89,'HNM','color',[.5 .5 .5],'LineWidth',5,'FontSize',14)
      line(hnmt,hnmv,'color',[.5 .5 .5],'LineWidth',2);
      text(.105,-171,'LNM','color',[.5 .5 .5],'LineWidth',5,'FontSize',14)
      
      xmin       = 0.1; % x-axis minimum
xmax       = 200; % x-axis maximum
ymin       = -200; % y-axis minimum 
ymax       = -50; % y-axis maximum
ytick      = 10; % y-axis tick spacing
      box on;
      ylim([ymin ymax]);
      xlim([xmin xmax]);
      set(gca,'TickDir','out');
      set(gca,'XScale','log'); n=get(gca,'XTick');
%     set(gca,'XTickLabel',sprintf('%.1f |',n'),'Fontsize',14);
      %set(gca,'XTickLabel',sprintf('%.1f\n',n))
      set(gca,'YTick',[ymin:ytick:ymax],'Fontsize',14);
ylabel('Power (dB)');
xlabel('Period (s)');
title(sprintf('Power Spectral Density for TA.%s.BHZ %s -- %s',station,startDate,endDate ));
axis square
grid
%hold on;
%freq{numPSDs,(length([freq{j,:}])+1)} = NaN;
for(j = 1:numPSDs)
semilogx(1./[xfreq{:}],([freq{j,:}]),'Color',cmap(j,:),'LineWidth',1.5);
hold on
currFrame = getframe(gcf);
writeVideo(vidObj,currFrame);
end

close(vidObj);

%fclose(fileID);

%% make plot of power for one frequency over time period
figure(2);clf;
plot(1:numPSDs,[freq{:,1}]);
title(sprintf('Frequency Plot for Frequency %d',xfreq{1}));
xlabel('Time');
ylabel('Power(dB)');

%% make sea ice concentration maps
clear;
addpath('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/matlab/arctic_sea_ice');

%start day, month, year
%pixel = [165 157];
dd = 22;
mm = 12;
yy = 2017;
loops = 8;
Y(loops) = struct('cdata',[],'colormap',[]); %Frames Struct

figure(3); clf;
subplot(1,2,1);
[ci,lat,lon,x,y,h] = arcticseaice(datenum(yy,mm,dd));
cb = colorbar;
ylabel(cb,'sea ice concentration %');


subplot(1,2,2);
[ci,lat,lon,x,y,h] = arcticseaice(datenum(yy,mm,dd+2));
cb = colorbar;
ylabel(cb,'sea ice concentration %');

%% wind test data from 2017-12-21 -- 2017-12-25

addpath('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/matlab/ReadMSEEDFast.m');

X = ReadMSEEDFast('/home/lucas/Documents/summer19/IRIS/IRIS_Sea_Ice/matlab/windyFun/A21K.TA.mseed')
figure(4); clf;
subplot(3,1,3); hold on
for i=2:3
    plot(X(i).matlabTimeVector,(X(i).data)/10,'b');
    datetick;
end
ylabel('Wind Speed (m/s)')
xlabel('Time')

subplot(3,1,[1 2]);hold on
c = colorbar;
cmap = colormap(cool(numPSDs));
c.Ticks=[0 0.25 0.5 0.75 1];
c.TickLabels={'00:00','06:00','12:00', '18:00', '24:00'};
c.Label.String = 'Time (UTC)';
line(lnmt,lnmv,'color',[.5 .5 .5],'LineWidth',2);
text(.105,-89,'HNM','color',[.5 .5 .5],'LineWidth',5,'FontSize',14)
line(hnmt,hnmv,'color',[.5 .5 .5],'LineWidth',2);
text(.105,-171,'LNM','color',[.5 .5 .5],'LineWidth',5,'FontSize',14)

xmin       = 0.1; % x-axis minimum
xmax       = 200; % x-axis maximum
ymin       = -200; % y-axis minimum
ymax       = -50; % y-axis maximum
ytick      = 10; % y-axis tick spacing
box on;
ylim([ymin ymax]);
xlim([xmin xmax]);
set(gca,'TickDir','out');
set(gca,'XScale','log'); n=get(gca,'XTick');
%     set(gca,'XTickLabel',sprintf('%.1f |',n'),'Fontsize',14);
%set(gca,'XTickLabel',sprintf('%.1f\n',n))
set(gca,'YTick',[ymin:ytick:ymax],'Fontsize',14);
ylabel('Power (dB)');
xlabel('Period (s)');
title(sprintf('Power Spectral Density for TA.%s.BHZ %s -- %s',station,startDate,endDate ));
axis square
grid
%hold on;
%freq{numPSDs,(length([freq{j,:}])+1)} = NaN;
for(j = 1:numPSDs)
    semilogx(1./[xfreq{:}],([freq{j,:}]),'Color',cmap(j,:),'LineWidth',1.5);
    hold on
end

