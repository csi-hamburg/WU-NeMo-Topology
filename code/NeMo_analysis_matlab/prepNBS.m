V0 = load([basedir filesep 'derivatives' filesep 'NeMo_output' filesep ['GGP_V0_' num2str(atlassize) '.mat']]);
V3 = load([basedir filesep 'derivatives' filesep 'NeMo_output' filesep ['GGP_V3_' num2str(atlassize) '.mat']]);


log1x3 = cellfun(@(p)(contains(subjects(1:n),p)),{'1-14-006','2-01-070', '5-04-010'}, 'uni', false);
idxtemp = ~(log1x3{1} | log1x3{2} | log1x3{3});


CIJstack = permute(V3.CIJ.mean - V0.CIJ.mean, [2,3,1]);



vol = csvread([basedir filesep 'derivatives' filesep 'volV0V3PACS.dat']);
vol0 = vol(1:n,1);
dvol = vol(1:n,2) - vol(1:n,1);

fid=fopen([basedir filesep 'clinical' filesep 'v3names.csv']);
data=textscan(fid,'%s%s%s%f%f%s%d','Delimiter',',','Headerlines',1);
fclose(fid);
idx=cellfun(@(s)(find(1-cellfun(@isempty,strfind(data{1},s)))),subjectsID);

tx = double(contains(data{2}(idx(1:n)), 'rtPA'));

switch suffix
        case ''
            design = [ones(n,1), tx];
        case 'dvol'
            design = [ones(n,1), tx, dvol];
        case 'vol0'
            design = [ones(n,1), tx, vol0];
        case 'vol0_dvol'
            design = [ones(n,1), tx, vol0, dvol];
end
    


CIJstack = CIJstack(:, :, idxtemp);
design = design(idxtemp, :);

save('CIJstack.mat', 'CIJstack')
save('design.mat', 'design')

%%

coords = dlmread('coords.txt');
coords = (rotx(-13)*1.05*(coords(idxLH, 2:4) + [6 -45 -3])')'; % LR, AP, IS

save('coords.mat', 'coords');

labelsLH = labels(idxLH);
save('labelsLH.mat', 'labelsLH');
fid = fopen('labelsLH.txt', 'w');
fprintf(fid, '%s\n', labelsLH{:});
fclose(fid);



%%
tt = 1:.1:2.5;
%tt = [1.0, 1.5, 2.1];

reps=length(tt);
p=nan(reps,1);
nedges=nan(reps,1);


if ~exist('plotflag','var'); plotflag = false; end

%suffix = 'vol0_dvol'

plotflag=false

SDNarr = cell(reps,1);

for i=1:reps
    
    clearvars -global nbs UI
    
    UI = struct();
    UI.method.ui = 'Run NBS';
    UI.test.ui = 't-test';
    UI.size.ui = 'Extent';
    UI.thresh.ui = num2str(tt(i));
    UI.perms.ui = '1e2';
    UI.alpha.ui = '1';
    
    UI.matrices.ui = 'CIJstack.mat';
    UI.design.ui = 'design.mat';
    
    switch suffix
        case ''
            UI.contrast.ui = '[0,1]';
        case 'dvol'
            UI.contrast.ui = '[0,1,0]';
        case 'vol0'
            UI.contrast.ui = '[0,1,0]';
        case 'vol0_dvol'
            UI.contrast.ui = '[0,1,0,0]';
    end
    UI.exchange.ui = '';
    UI.node_coor.ui = '';
    UI.node_label.ui = 'labelsLH.mat';
        
    global nbs
    
    NBSrun(UI,[])
    
    
    if ~isempty(nbs.NBS.pval)
        [p(i),idxmin] = min(nbs.NBS.pval);
        nedges(i) = full(sum(nbs.NBS.con_mat{idxmin}(:)));
       
        SDNmask = full(nbs.NBS.con_mat{idxmin});
        SDNmask = SDNmask + SDNmask';
        
        idxx = sum(SDNmask)==1;
        SDNmask(idxx,:) = 0;
        SDNmask(:,idxx) = 0;
        
        SDNarr{i} = SDNmask; 
        if ~plotflag
            continue;
        end
        
        %nodes
        sizes = degrees_und(SDNmask);
        file_node = ['SDNmask' filesep 'SDNmask-' num2str(tt(i)) '.node'];
        fid = fopen(file_node,'w');
        for j = 1:size(SDNmask,1) 
            fprintf(fid,'%f\t%f\t%f\t%f\t%f\t%s\n',coords(j,1), coords(j,2), coords(j,3), double(lobes(idxLH(j))), sizes(j), labelsLH{j});
        end
        fclose(fid);
        
        %edges
        file_edge = ['SDNmask' filesep 'SDNmask-' num2str(tt(i)) '.edge'];
        dlmwrite(file_edge,SDNmask,' ');
        
                
                
                for ext = {'ax', 'cor', 'sag'}
                    filename_opt = sprintf('BNVoptions_%s.mat', ext{1});
                    filename_save = sprintf('NBSplot-%f_%s_%s.png',tt(i), ext{1}, suffix);

                    if ~exist(fileparts(filename_save),'dir'); mkdir(fileparts(filename_save)); end

                    BrainNet_MapCfg('/home/eckhard/Documents/MATLAB/toolboxes/BrainNet/Data/SurfTemplate/BrainMesh_ICBM152.nv',file_node,file_edge,filename_save,filename_opt);
                    pause(5)
                    close all
                    pause(5)
                end
        %return;
    end
end

if length(tt)==1
    return;
end

%% export t, p, n
if str2num(UI.perms.ui) >= 1e3
    dlmwrite([basedir filesep 'derivatives' filesep 'matlab_processing' filesep 'p_t_n_', suffix, '.dat'], [tt', p, cellfun(@(m)(sum(m(:)/2)), SDNarr)])
    disp('file exported')
end