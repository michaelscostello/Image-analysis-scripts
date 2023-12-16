%% KTR Nuclear Intensity from TrackMate spot.csv
% Reads .csv TrackMate outputs in folder ("spots data" for 10_26)
fileDir = uigetdir('/Users/michaelcostello/Dropbox/aaUCSB/aaaLab/aaaFHAB/aFhaB/aaaData/01Spring_Data/Ex\ vivo\ tracheal\ binding/output/MATLAB\ out','Open Folder with csvs');
addpath(fileDir);
fileNames = dir(fileDir);
fileNames = {fileNames.name};
fileStr = string(fileNames); fileStr = fileStr(3:end);
fileNames = fileNames(cellfun(...
    @(f)~isempty(strfind(f,'.csv')),fileNames));
%%

dat=cell(numel(fileNames)./2,2);

for i  = 1:1:8 % Change last position in array to numel(fileNames)./2 -- for 32 files -- use 16

    imut=(i*2)-1;
    iwt=(i*2);
    i_mut = readtable(fileNames{imut});
    i_wt = readtable(fileNames{iwt});
    dat{(i*2)./2,1} = numel(i_mut.Label);
    dat{(i*2)./2,2} = numel(i_wt.Label);

end
