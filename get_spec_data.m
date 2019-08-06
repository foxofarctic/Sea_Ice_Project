%Request and plot a spectrogram from IRIS MUSTANG metrics
function [x,y,z] = get_spec_data(station,startTime,endTime)
startDate = startTime;
endDate = endTime;
station = station;
numFreq = 96;
net = 'TA'

if strcmp(station,'UNV')
    net = 'AK'
end

t = sprintf('curl -g http://service.iris.edu/mustang/noise-mode-timeseries/1/query?target=%s.%s.--.BHZ.M\134\46starttime=%s\134\46endtime=%s\134\46format=text\134\46frequencies=[0.005,20] > temp.txt',net,station,startDate,endDate)
system(t)

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

x = [datenum(startDate):datenum(endDate)-1];
y = freqTemp(:);
z = dataTemp;
end


