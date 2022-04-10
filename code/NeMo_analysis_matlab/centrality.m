refNW = median(cell2mat(permute(cellfun(@(s)(s.MapTFC(idxLH,idxLH)),temp.OrigMat(2:end),'UniformOutput',false),[2,3,1])),3);

EBC = edge_betweenness_wei(1./refNW);

SDNmask = EBC;
idxx = sum(SDNmask)==1;
SDNmask(idxx,:) = 0;
SDNmask(:,idxx) = 0;
%nodes
sizes = degrees_und(SDNmask);
file_node = ['SDNmask' filesep 'backbone.node'];
fid = fopen(file_node,'w');
for j = 1:size(SDNmask,1)
    fprintf(fid,'%f\t%f\t%f\t%f\t%f\t%s\n',coords(j,1), coords(j,2), coords(j,3), double(lobes(idxLH(j))), sizes(j), labelsLH{j});
end
fclose(fid);

%edges
file_edge = ['SDNmask' filesep 'backbone.edge'];
dlmwrite(file_edge,SDNmask,' ');

filename_opt = 'BNVoptions.mat';
filename_save = [basedir filesep 'derivatives' filesep 'matlab_processing' filesep 'backbone.png'];

if ~exist(fileparts(filename_save),'dir'); mkdir(fileparts(filename_save)); end

BrainNet_MapCfg('/home/eckhard/Documents/MATLAB/toolboxes/BrainNet/Data/SurfTemplate/BrainMesh_ICBM152Left.nv',file_node,file_edge,filename_save,filename_opt);
pause(5)
%close all


%% export EDC by SDN
idxEBC = find(EBC>0);
idxEBC0 = find(EBC==0);

dlmwrite([basedir filesep 'derivatives' filesep 'matlab_processing' filesep  'EBCcont.dat'],[nbs.NBS.test_stat(idxEBC), EBC(idxEBC)])

x=nbs.NBS.test_stat(idxEBC); x=x(x~=0); %% t-stat in backbone
y=nbs.NBS.test_stat(idxEBC0); y=y(y~=0); %% t-stat off the backbone

%% information centrality

refeff = efficiency_wei(refNW);

SDNarrplot = SDNarr(tt<=2.1);

kk = 1e4; 
figure; format compact

for i = 1:numel(SDNarrplot)
    
    SDNmask = SDNarrplot{i};
    nw = refNW;
    nw(logical(SDNmask)) = 0;
    eff = 1 - efficiency_wei(nw) / refeff;
    nono = sum(sum(SDNmask)>0);
    noed = sum(SDNmask(:))/2;
    
    effarr = nan(kk,1);
    k = 1;
    while k<=kk
        m = zeros(nono);
        edgeidx = randperm(nono*(nono-1)/2, noed);
        triuidx = find(triu(ones(nono),1));
        m(triuidx(edgeidx)) = 1;
        m = m + m';
        
        nm = zeros(43,43);
        nodeidx = randperm(43, nono);
        nm(nodeidx, nodeidx) = m;
        
        [bins, binsizes]=conncomp(graph(nm, 'omitselfloops'));
        if numel(find(binsizes>1)) > 1
            disp('simulated lesion network not connected')
            continue
        end
        if max(binsizes) ~= nono
            disp('sizes dont match')
            continue
        end
        
        nw = refNW;
        nw(logical(nm)) = 0;
        effarr(k) = 1 - efficiency_wei(nw) / refeff;
        k = k+1;
    end
    
    subplot(numel(SDNarrplot),1,numel(SDNarrplot)-i+1);
    h = histogram(effarr, 'BinMethod', 'fd', 'Normalization', 'probability', 'FaceColor', 'black');
    hold on
    plot([eff eff], [0, 1.1*max(h.Values)], '-r', 'LineWidth', .5)
    plot([quantile(effarr, .95) quantile(effarr, .95)], [0, 1.1*max(h.Values)], '-', 'Color', [.5, .5, .5], 'LineWidth', .5)
    plot([quantile(effarr, .5) quantile(effarr, .5)], [0, 1.1*max(h.Values)], '-', 'Color', [.8, .8, .8], 'LineWidth', .5)
    text(.3, .55*max(h.Values), sprintf('%d nodes\n%d edges', nono, noed), 'FontSize', 4)
    ylabel(sprintf('t=%1.1f\n',tt(i)), 'FontSize',4)
    a = gca;
    if i~=1
        set(a, 'XTick',[])
    end
    set(a, 'box','off','color','none')
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(a)
    % link axes in case of zooming
    linkaxes([a b])
    if i~=1
        set(a, 'XTick',[])
    else
       xlabel('Information centrality', 'FontSize', 4)
       set(a, 'Xtick', 0:0.1:0.3, 'XTickLabel', get(a, 'XTickLabel'), 'FontSize', 4)
    end
    set(a, 'YTick',[])
    xlim([0, .4])
    ylim([0, 1.1*max(h.Values)])
end
set(gcf, 'PaperUnits', 'centimeters');
x_width=5 ;y_width=10;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
print([basedir filesep 'derivatives' filesep 'matlab_processing' filesep  'EBCbyref.png'], '-dpng', '-r600')