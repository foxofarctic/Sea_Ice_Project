%Request and plot a spectrogram from IRIS MUSTANG metrics

close all
clear

startDate = '2015-12-17';
endDate = '2016-4-31';
station = 'A21K';
numFreq = 96;

t = sprintf('curl -g http://service.iris.edu/mustang/noise-mode-timeseries/1/query?target=TA.%s.--.BHZ.M\134\46starttime=%s\134\46endtime=%s\134\46format=text\134\46frequencies=[0.005,20] > temp.txt', station, startDate, endDate)
system(t)
%%
numDays = datenum(endDate)-datenum(startDate);
dataTemp = zeros(numDays,numFreq);
freqTemp= zeros(1,numFreq);
day = {0 0 0 0 0 0};

fid = fopen('temp.txt');
dayCount = 1;
tline = fgetl(fid);
while ischar(tline)
    if(strncmpi(tline,'day:',4))
        L=strsplit(tline,' ');
        dayIndex=(datenum(L{2},'yyyy-mm-dd')-datenum(startDate))+1;
        day{dayIndex} = datenum(L{2},'yyyy-mm-dd');
        %disp(tline)
        tline = fgetl(fid);
        L=strsplit(tline,' ');
        freq=str2num(L{2});
        tline = fgetl(fid);
        
        for(j=1:1:freq)
            tline = fgetl(fid);
            L=strsplit(tline,',');
            frequency{j} = str2num(L{1});
            power{j} = str2num(L{2});
            dataTemp(dayIndex,j) = power{j};
            freqTemp(1,j) = frequency{j};
        end
        
        dayCount = dayCount + 1;
    end
    tline = fgetl(fid);
end

fclose(fid);

figure(1),clf;
hold on
%surf([day{:}]',freqTemp(:),dataTemp', 'edgecolor', 'none')
dataTemp(dataTemp == 0) = NaN;
surf([datenum(startDate):datenum(endDate)-1]',freqTemp(:),dataTemp', 'edgecolor', 'none')

view(2);
set(gca, 'YScale', 'log');
ylabel('Frequency (Hz)');
xlabel('Date');
datetick;
colorbar;
colormap('jet');
caxis([-180 -80]);
axis([datenum(startDate) datenum(endDate)+1 freqTemp(1) freqTemp(96)]);
%%
figure(2); clf;
plot([datenum(startDate):datenum(endDate)-1]',dataTemp(:,1));
title(sprintf('Frequency Plot for Frequency %d',freqTemp(1)));
xlabel('Time');
ylabel('Power(dB)');
datetick;

