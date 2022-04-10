%T1file = '/home/eckhard/Documents/MATLAB/toolboxes/NeMo-master/mymfiles/spm8/templates/T1.nii';
%[pathstr,name,ext] = fileparts(T1file);


if(~exist('CHUNKS','var')); CHUNKS=1; end
if(~exist('MAGICNUMBER','var')); MAGICNUMBER=0; end

if(~exist('SORT_MODE','var'));
       	idx = 1:n;
else
	[~, idx] = sort(vol, SORT_MODE);
end

idx = idx(mod(1:n,CHUNKS)==MAGICNUMBER);

timings = nan(n,1);
args = cell(numel(idx),1);

%delete(gcp('nocreate'))
%c = parcluster('local')
%c.NumWorkers = 32;

%j = createJob(c);

func = @(vol,DamageFileName,Coreg2MNI,CalcSpace,atlassize,StrSave,NumWorkers,dispMask,coregOnly,main_dir)(ChaCoCalc(DamageFileName,Coreg2MNI,CalcSpace,atlassize,StrSave,NumWorkers,dispMask,coregOnly,main_dir));

for i = 1:numel(idx)
    subject = subjects{idx(i)};
    sprintf('Processing file %s (%d/%d)\n',subject,i,n)
    DamageFileName = [lesiondir filesep subject '.nii'];
    %[filepath,name,ext] = fileparts(DamageFileName);
    %TempDamageFileName = ['/work/fawx493/tmp' filesep visit num2str(atlassize) name  ext];
    %copyfile(DamageFileName, TempDamageFileName, 'f')
    StrSave = [outdir filesep subject];
    %copyfile(T1file, StrSave)
    
    %Coreg2MNI = struct('StructImageType','t1','ImageFileName',[StrSave filesep name ext]);
    Coreg2MNI = struct('StructImageType',{},'ImageFileName',{});
    CalcSpace = 'MNI';
    NumWorkers = 7;
    dispMask = true;
    coregOnly = false;
    
    if ~exist(StrSave,'dir'); mkdir(StrSave); end
    args{i} = {vol(idx(i)), DamageFileName,Coreg2MNI,CalcSpace,atlassize,StrSave,NumWorkers,dispMask,coregOnly,main_dir};
    func(args{i}{:})
    %TSTART = tic;
    %computechacosubject(DamageFileName,Coreg2MNI,CalcSpace,atlassize,StrSave,NumWorkers,dispMask,coregOnly,main_dir)
    %timings(j) = toc(TSTART);
%delete(TempDamageFileName);
end
