clear;
% function [y,z] = get_psd(station,startTime,endTime)
% read the LNM & HNM
% [lnmt lnmv] = textread('LNM.dat','%f %f');
% [hnmt hnmv] = textread('HNM.dat','%f %f');

net = char('TA');

%Trying to get curl work
% numPSDs = 47*643;
% startDate = startTime;
% startDate = '2017-09-26T00:00:00';
startDate = '2018-08-17T00:00:00';
% endDate = endTime;
% endDate = '2018-08-17T00:00:00';
endDate = '2019-07-09T00:00:00';
% station = station;
station = 'A19K';
numFreq = 96;

%took out the final frequency section as well as the location "--" as the
%txt file does not have it.

t = sprintf('curl -g https://service.iris.edu/mustang/noise-psd/1/query?target=TA.%s..BHZ.M\134\46starttime=%s\134\46endtime=%s\134\46format=text > temp.txt', station, startDate, endDate);
system(t)

%...TA.A21K..BHZ.M&starttime=2017-12-23T00:00:00&endtime=2017-12-23T23:59:59&format=text
%%

fileID = fopen('temp.txt');
templine = fgetl(fileID);
templine;
while(any(strncmp(templine, {'#','s','e'},1)))
    templine = fgetl(fileID);
    templine;
end

j = 1;
while (ischar(templine))
    templine = fgetl(fileID);
    while(any(strncmp(templine, {'#','e'},1)))
        templine = fgetl(fileID);
    end
    
    while(strncmp(templine, 's',1))
        Z = strsplit(templine,' ');
        timeStr(j,:) = Z{2};
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
    j= j+1;
end
y = xfreq;
z = freq;
% end
%% fix data
freq1 = freq(2:length(freq()),:);

x = freq1(1:2:end,:);
y = freq1(1:2:end,:);
data = [x' y'];

% f = [data{:}];
% reshape(f, size(data));
[w h] = size(data);
for i = 1:w
    for x =1:h
        if(isempty(data{i, x}))
            data{i, x} = NaN;
        end
    end
end
data = cell2mat(data);

% fix timeStr to timeStr1
x1 = timeStr(1:2:end,:);
y1 = timeStr(1:2:end,:);
timeStr = [x1' y1'];
xfreq = cell2mat(xfreq);

for i = 1:length(timeStr)
    timeStr1(i,:) = replace(timeStr(:,i)','T',' ');
end

% C = strsplit(templine,', ');
% freq{numPSDs,numFreq} = str2num(C{2});
% xfreq{numFreq} = str2num(C{1});