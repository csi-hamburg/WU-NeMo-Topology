 

NeMoanalysisdir = fileparts(which('computechaco.m')); 
basedir = [NeMoanalysisdir filesep '..' filesep '..'];
outdir = [basedir filesep 'derivatives' filesep 'NeMo_output'];

V0 = load([basedir filesep 'derivatives' filesep 'NeMo_output' filesep ['GGP_V0_' num2str(atlassize) '.mat']]);
V3 = load([basedir filesep 'derivatives' filesep 'NeMo_output' filesep ['GGP_V3_' num2str(atlassize) '.mat']]);



V0.NeMo=reshape(V0.GGP.mean,[],1);
V3.NeMo=reshape(V3.GGP.mean,[],1);


fid = fopen([basedir filesep 'derivatives' filesep 'subjectsV0V3PACS.dat'], 'r');
data = textscan(fid, '%s');
fclose(fid);
subjectsID = data{1};
clear data

fid=fopen([basedir filesep 'clinical' filesep 'v3names.csv']);
data=textscan(fid,'%s%s%s%f%f%s%d','Delimiter',',','Headerlines',1);
fclose(fid);
idx=cellfun(@(s)(find(1-cellfun(@isempty,strfind(data{1},s)))),subjectsID);

numel(idx)


mm = cellfun(@(l)(repmat({l},[n,1])),V0.GGP.measures,'uni',false);

c=[V0.NeMo, V3.NeMo, {reshape([mm{:}],[],1)}, cellfun(@(c)(repmat(c(idx(1:n)),[numel(measures),1])),data,'uni',false)];

rownames={'GGP_V0','GGP_V3','lab','ID','treatment','lesion_side','lesionvolume_V0','lesionvolume_V3','lesion_location','lesion_supratentorial'};

cNUM = c([1 2 7 8 10]);
cNUM = cellfun(@double,cNUM,'uni',false);
tabNUM = array2table([cNUM{:}],'VariableNames',rownames([1 2 7 8 10]));
cTXT = c([3 4 5 6 9]);
tabTXT = cell2table([cTXT{:}],'VariableNames',rownames([3 4 5 6 9]));

tab=[tabTXT, tabNUM];

writetable(tab,[basedir filesep 'derivatives' filesep 'NeMo_output' filesep 'GGP' num2str(atlassize) '.csv'])
