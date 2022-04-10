anatsort = [];
gaps = [];

for i=1:6
    f = find(lobes(idxLH)==i);
    anatsort = [anatsort; f];
    gaps = [gaps, length(f)];
end
gaps = [0,cumsum(gaps)]

fid = fopen('labelsLHshort.txt');
labelsshort = textscan(fid, '%s');
fclose(fid);
labelsshort = labelsshort{1}

M=zeros(43);
M(logical(triu(ones(43),1)))=nbs.STATS.test_stat(1,:);
M = nbs.NBS.test_stat;
M(M==0)=nan;
Manat = M(anatsort, anatsort);

mean(nbs.NBS.test_stat(nbs.NBS.test_stat(:)~=0))
std(nbs.NBS.test_stat(nbs.NBS.test_stat(:)~=0))

imagesc(Manat, 'AlphaData', ~isnan(Manat))
daspect([1 1 1])
hold on
for j = 1:numel(gaps)
    g = gaps(j);
    plot([g,g]+.5,[.5,43.5],'-k')
    plot([.5,43.5],[g,g]+.5,'-k')
    if j>1; ming = gaps(j-1); else ming = gaps(j); end
    if j<numel(gaps); maxg = gaps(j+1); else maxg = 43; end
    plot([ming, maxg]+.5, [g,g]+.5,'-k', 'LineWidth', 3)
    plot([g,g]+.5,[ming, maxg]+.5,'-k', 'LineWidth', 3)
    
end

colorbar
colormap('turbo')
caxis([-3,3])
set(gca,'Xtick',(1:43), 'XTickLabels', labelsshort(anatsort), 'XAxisLocation', 'top', 'FontSize',8, 'TickLength', [0,0])
set(gca,'Ytick',(1:43), 'YTickLabels', labelsshort(anatsort))

set(gcf, 'PaperUnits', 'centimeters');
x_width=18.5 ;y_width=18.5;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
print([basedir filesep 'derivatives' filesep 'matlab_processing' filesep  'NBStstat.png'], '-dpng', '-r600')

%%
tplot = [1.0, 1.5, 2.1];
figure; format compact

suffixes = {'vol0_dvol'};

load('BNVoptions.mat', 'EC')
cols = EC.nod.CMm;
colorsHex = {'#0077bb','#ee7733','#009988','#33bbee','#ee3377','#cc3311'};
cols = cell2mat(cellfun(@(x)sscanf(x(2:end),'%2x%2x%2x',[1 3])'/255, colorsHex, 'UniformOutput', false))';
         
for suffixidx = 1:numel(suffixes)
 load(['SDNdata_', suffixes{suffixidx}, '.mat'])
    
for k = 1:numel(tplot)
    t = tplot(k);
    i = find(abs(tt-t)<1e-10);
    M = SDNarr{i}.*nbs.NBS.test_stat;
    
    M(M==0)=nan;
    Manat = M(anatsort, anatsort);
    subplot(numel(tplot), numel(suffixes), (suffixidx-1)*numel(tplot)+k)
    imagesc(Manat, 'AlphaData', ~isnan(Manat))
    daspect([1 1 1])
    hold on
    for j = 1:numel(gaps)
        g = gaps(j);
        plot([g,g]+.5,[.5,43.5],'-k', 'LineWidth', .5)
        plot([.5,43.5],[g,g]+.5,'-k', 'LineWidth', .5)
        if j>1; ming = gaps(j-1); else ming = gaps(j); end
        if j<numel(gaps); maxg = gaps(j+1); else maxg = 43; end
        plot([ming, maxg]+.5, [g,g]+.5,'-k', 'LineWidth', 1)
        plot([g,g]+.5,[ming, maxg]+.5,'-k', 'LineWidth', 1)
        
    end
    lobelabs = {'Frontal','Parietal','Temporal','Occipital','Limbic','Subcortical'};
    lobelabs = {'F','P','T','O','Li','Sc'};
    lobelabs = arrayfun(@(i)(sprintf('\\color[rgb]{%f,%f,%f}%s',cols(i,:), lobelabs{i})), 1:6, 'UniformOutput', false)

        
    %colorbar
    colormap('turbo')
    caxis([-3,3])
    if k==1; temp=diff(gaps)/2 + gaps(1:end-1); else temp=[]; end
    set(gca,'Xtick',temp, 'XTickLabels', lobelabs, 'XAxisLocation', 'top', 'FontSize',8, 'TickLength', [0,0])
    if k>0
        temp=diff(gaps)/2 + gaps(1:end-1); 
    else
        temp=[]; 
    end
    xtickangle(0)
    
    if suffixidx==numel(suffixes)
            t = title(sprintf('t=%1.2f', t), 'Units', 'normalized', 'Position', [0.5, -0.2, 0]); % Set Title with correct Position
    end
    set(gca,'Ytick',temp, 'YTickLabels', lobelabs, 'FontSize', 6)
    if k==3
        %label_y = ylabel(sprintf('Suffix=%s', suffixes{suffixidx}),'fontweight','bold');
        %label_y.Position(1) = 50;
        
    end
end
end
set(gcf, 'PaperUnits', 'centimeters');
x_width=5 ;y_width=10;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
print([basedir filesep 'derivatives' filesep 'matlab_processing' filesep 'NBStstatsmall_vert.png'], '-dpng', '-r600')