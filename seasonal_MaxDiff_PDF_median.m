%% make plot of PSD medians
clear;
addpath('/media/lucas/Elements/IRIS_Sea_Ice/matlab/')
info.a = {'D27M','E27K','G27K','H27K'};
% info.a = {'C26K','F26K','G26K'};
% info.a = {'D25K','E25K','F25K','G25K'};
% info.a = {'C24K','D24K','E24K','F24K','G24K','H24K'};
% info.a = {'B18K','C18K'};
% info.a = {'A19K','C19K','D19K'};
% info.a = {'C23K','D23K','E23K','G23K','H23K'};
figure(2);clf;hold on
for i = 1:length(info.a)
    [x,meds] = get_pdf_median(char(info.a(i)),'2017-06-01','2017-11-01');
    [x,meds1] = get_pdf_median(char(info.a(i)),'2018-01-01','2018-04-01');
    diffs(i,:) = meds - meds1;
    [M,I] = max(diffs(i,:));
    maxDiffFreq(i) = x(I);
    plot(x,diffs(i,:),'LineWidth',2);
end
% xmin = .1;xmax = 200;
% ymin = -200; ymax = -50; ytick =10;
axis tight; box on;
set(gca,'TickDir','out');
set(gca,'XScale','log'); n=get(gca,'XTick');
% set(gca,'YTick',[ymin:ytick:ymax],'Fontsize',14);
xlabel('Period (s)','FontSize',18);
ylabel('Power [dB]','FontSize',18);
title('Seasonal Difference Median pdfs of Multiple Station');
% ylim([ymin ymax]);
% xlim([xmin xmax]);
legend(info.a);
