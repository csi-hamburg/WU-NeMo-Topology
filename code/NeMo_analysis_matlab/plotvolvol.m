vol3Mevis=data{5};
fid2=fopen('../../derivatives/volumesV3.dat');
data2=textscan(fid,'%s%f', 'Delimiter', ' ');
vol3MNI=data2{2};
fclose(fid2)

%% only for v0

data2{1}=cellfun(@(s)([s(1:9) 'v03']),data2{1},'uni', false)
idx2=cellfun(@(s)(find(1-cellfun(@isempty,strfind(data2{1},s)))),data{1},'uni', false);
idx2 = cell2mat(idx2(find(cellfun(@(i)(~isempty(i)),idx2))));
idx3=cellfun(@(s)(find(1-cellfun(@isempty,strfind(data{1},s)))),data2{1}(idx2));
vol3Mevis = vol3Mevis(idx3);

%% only for v3
idx2=cellfun(@(s)(find(1-cellfun(@isempty,strfind(data2{1},s)))),data{1});

%%
scatter(log(vol3Mevis), log(vol3MNI(idx2)))
ylabel('fslstats -V der Masken')
xlabel('Aus Execel Datei')

