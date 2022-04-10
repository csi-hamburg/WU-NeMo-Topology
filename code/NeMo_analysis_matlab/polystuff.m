CIJ0=squeeze(mean(V0.CIJ.mean,1))
x=1-CIJ0(triu(true(43),1));
y=nbs.NBS.test_stat(triu(true(43),1));

y = y(x>0);
x = x(x>0);

[xs,xi] = sort(x);
ys = y(xi);

dlmwrite([basedir filesep 'derivatives' filesep 'matlab_processing' filesep 'polyfit.dat'],[x,y])
