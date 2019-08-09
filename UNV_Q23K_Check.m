load('/media/lucas/Elements/IRIS_Sea_Ice/matlab/iceData/TsaiCoeffs_Q23K_UNV.mat')
scatter([TsaiCoeffs.IceCoefficientshortshort],[TsaiCoeffs.IceCoefficientshortshort1],'filled');
ylabel('Ice Coefficient using UNV');
xlabel('Ice Coefficient using Q23K');
title('Comparison of fits using Q23K and UNV');
plot('')