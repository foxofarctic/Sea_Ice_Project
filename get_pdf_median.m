% Name: pdfPsdPlot.m - a script to read through the PSD files and creates a PDF
%
% Description:
%
%    Script reads through the PSD files in a directory and creates a PDF.
%    The codes sets up a matrix, the rows are dB values, in 1 dB increments,
%    the columns are the frequency values, assuning the frequencies for all files fo
%    a given network, station, location and channel to be the same. Each matrix
%    element is simply a tally of how many spectra touch that frequency, dB point.
%
% Input:
%
%    Script expects PSDs to be in the standard DMC PSD format. For more informatio
%    see http://www.iris.edu/dms/products/pdfpsd
%
%    DMC PDFPSD standard directory structure
%
%    PDFPSD/network.station.location/channel/Yyyyy/Djjj.bin
%
%    where
%
%    net  - is the network code
%    sta  - is the station code
%    loc - is the location ID
%    chan  - is the channel code
%    yyyy     - is the year of the data file
%    jjj      - is the Julian day of the data file
%
% History:
%    2019 Lucas Estrada: Updated for greater accessibility
%    2011-05-26 IRIS DMC Product Team (MB): revised for public distribution
%    2011 Bob Woodward (IRIS): Original version
%
%
%
% ==========================================
% configuration parameters. Change as needed
% ==========================================
%
%
% set the color map
%
function [x,meds] = get_pdf_median(station,startTime,endTime)
cmap       = load('pdfpsd.cp'); % load the optional color map
%cmap       = colormap(flipud(hot)); % set the colormap to standard hot (comment out this line to use colormap above)

% define the following processing parameters based on the above input informtion
% to control the PDF generation

cumulative = 0; % 0- report results as percent; 1- report results as cumulative PSD
doplot     = 1; % create plot(s)
dostat     = 1; % plot mode and median, AF edit
xmin       = 0.1; % x-axis minimum
xmax       = 200; % x-axis maximum
ymin       = -200; % y-axis minimum
ymax       = -50; % y-axis maximum
ytick      = 10; % y-axis tick spacing
skiphigh   = 0; % skip the 5 highest frequencies - they always seem to be high in the PSDs. Do this for IU.COLA.00

% read the LNM & HNM
[lnmt lnmv] = textread('LNM.dat','%f %f');
[hnmt hnmv] = textread('HNM.dat','%f %f');

%h1 = figure;

% define data you want
startDate = startTime;
endDate = endTime;
net = 'TA';
sta = station;
loc = '--';
chan = 'BHZ';

% makes textfile temp.txt
t = sprintf('curl -g http://service.iris.edu/mustang/noise-pdf/1/query?target=%s.%s.%s.%s.M\134\46starttime=%s\134\46endtime=%s\134\46format=text > temp.txt',net,sta,loc,chan, startDate, endDate);
system(t);

numval = 0;
filestring = 'temp.txt';
titlestring = [net '.' sta '.' loc '.' chan];


tmp1 = importdata(filestring,',',5);
tmp = tmp1.data ;

% extract and count unique frequency values
frequencylist = unique(tmp(:,1)); fc = length(frequencylist);
stn_mode = nan(1,fc); stn_medi = stn_mode;

% psd is set up as a matrix, the rows are dB values, in 1 dB increments,
% the columns are the frequency values. Each matrix element is simply a tally of
% how many spectra touch that frequency, dB point.

psd = zeros(201,fc);
% loop through frequencies
for icol=skiphigh+1:fc
    freq = frequencylist(icol);
    % go through frequency list and select the ones match
    for ifreq=1:length(tmp)
        if(tmp(ifreq,1) == freq)
            irow = round (-1*tmp(ifreq,2)) + 1; % round the dB values at this freq
            if irow < 1 || irow > 201 continue; end; 
            % add psd hits to the appropriate matrix element
            psd(irow,icol) = psd(irow,icol) + tmp(ifreq,3);
            numval = numval + tmp(ifreq,3);
        end; % frequency list
    end;% matrix population
    % extract mode
    [~,b]=max(psd(:,icol)); if (length(b)>1) disp(b); end
    if (b>0); stn_mode(1,icol) = b; end
    
    % extract median
    [a,~,~]=find(psd(:,icol) ~= 0); b=nonzeros(psd(:,icol));
    vals = [];
    for i=1:length(a);
        for j=1:b(i)
            vals=[vals a(i)];
        end
    end
    stn_medi(1,icol) = median(vals);
end;
stn_mode = -stn_mode; stn_medi = -stn_medi;
x = 1./frequencylist;
meds = [stn_medi];

end