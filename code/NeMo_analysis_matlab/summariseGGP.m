measures = {@efficiency_wei, @(m)(mean(clustering_coef_wu(weight_conversion(m, 'normalize'))))};
measlabs = {'efficiency', 'clustering'};



fid=fopen([start_dir filesep '..' filesep 'resource' filesep 'atlas'  num2str(atlassize) '.cod']);
data=textscan(fid,'%s');
fclose(fid);
labels = data{1};

idxLH = find(contains(labels,'_L'));
idxRH = find(contains(labels,'_R'));

fid = fopen([basedir filesep 'derivatives' filesep 'subjectsV0V3PACS.dat'], 'r');
data = textscan(fid, '%s');
fclose(fid);
subjectsID = data{1};
clear data
fid=fopen([basedir filesep 'clinical' filesep 'v3names.csv']);
data=textscan(fid,'%s%s%s%f%f%s%d','Delimiter',',','Headerlines',1);
fclose(fid);
idx=cellfun(@(s)(find(1-cellfun(@isempty,strfind(data{1},s)))),subjectsID);

side = data{3}(idx);

%n = 5;

GGP = struct();
GGP.raw = nan(n,nTract,numel(measures));
GGP.orig = nan(n,nTract,numel(measures));

CIJ = struct();
CIJ.raw = nan(n,atlassize/2, atlassize/2, nTract);
CIJ.orig = nan(n,atlassize/2, atlassize/2, nTract);

for i = 1:n
    subject = subjects{i};
    sprintf('Processing file %s (%d/%d)\n',subject,i,n)    
    StrSave = [outdir filesep subject];
    data=load([StrSave filesep 'ChaCo' num2str(atlassize) '_MNI.mat']);
    
    temp=struct2table(data.ChaCoResults);
    
    if strcmp(side{i}, 'left')
        I = idxRH;
    elseif strcmp(side{i}, 'right')
        I = idxLH;
    else
        error('error')
    end
    
    GGP.raw(i,:,:) = cell2mat(cellfun(@(measure)(cellfun(@(m)(measure(m(I,I))), cellfun(@(a,b)(2*b.MapTFC - a), temp.ConMat(2:end), temp.OrigMat(2:end), 'UniformOutput', false))), measures, 'unif', false)); % raw GGP

    t = cellfun(@(measure)(cell2mat(cellfun(@(s)(measure(s.MapTFC(I,I))), temp.OrigMat(2:end), 'UniformOutput', false))), measures, 'unif', false);
    GGP.orig(i,:,:) = [t{:}];
    
    CIJ.raw(i,:,:,:) = cell2mat(permute(cellfun(@(m)(m(I,I)), temp.ConMat(2:end), 'UniformOutput', false), [3,2,1])); % raw CIJ
    CIJ.orig(i,:,:,:) = cell2mat(permute(cellfun(@(s)(s.MapTFC(I,I)), temp.OrigMat(2:end), 'UniformOutput', false), [3,2,1]));
        
end



%%
GGP.norm = GGP.raw ./ GGP.orig;

GGP.mean = squeeze(nanmean(GGP.norm, 2)); % mean relative GGP
GGP.median = squeeze(nanmedian(GGP.norm, 2)); % median relative GGP
GGP.sd = squeeze(nanstd(GGP.norm, 2)); % sd relative GGP

GGP.measures = measlabs;

CIJ.chaco = (2*CIJ.orig - CIJ.raw) ./ CIJ.orig;
CIJ.mean = mean(CIJ.chaco, 4);
CIJ.mean(isnan(CIJ.mean)) = 1;
CIJ.median = median(CIJ.chaco, 4);
CIJ.median(isnan(CIJ.median)) = 1;
%%
save(ChaCoResultsFilename,'subjects','GGP', 'CIJ');
