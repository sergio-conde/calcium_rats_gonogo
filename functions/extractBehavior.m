% function behavior = extractBehavior(fileList)


if isstruct(fileList)
    fileList = struct2table(fileList);
end

Nfiles = length(fileList); % Number of files

% Initialize behavioral variables: 

nPress = nan(Nfiles,1); % number of lever presses
pressLatency = nan(Nfiles,1); % Latency to press during go trials
nosePokeExit = nan(Nfiles,1); % Latency to leave nose-poke hole during no-go trials
goNosePokeHold = nan(Nfiles,1); % Nose-poke hole after cue during go trials
nogoNosePokeHold = nan(Nfiles,1); % Nose-poke hole after cue during no-go trials
goRewardLatency = nan(Nfiles,1); % Latency to collect reward during go trials
nogoRewardLatency = nan(Nfiles,1); % Latency to collect reward during no-go trials
goLatency = nan(Nfiles,1); % latency to leave the nose-poke hole
goDuration = nan(Nfiles,1); % go trials duration 
nogoDuration = nan(Nfiles,1); % no-go trials duration


% For all files in the list:

fprintf('\n>-- PROCESSING BEHAVIOR --<')
for iFile = 1:Nfiles

    % fprintf(repmat('\b',1,length(tagStr)))
    % tagStr = sprintf(' %i ',ifile);
    % fprintf('%s',tagStr)    

    % read behavioral data
    data = load(fullfile(fileList(iFile).folder,fileList(iFile).name));
    localName = fieldnames(data);
    data = data.(localName{1});
    data = getEntry(data,'reward',1); % select only correct trials

    % extract trial type 
    goFlags = [data.nogo] == 0;
    nogoFlags = [data.nogo] == 1;

    % extract go and no-go correct trials data
    goData = data(goFlags & [data.reward] == 1);
    goExit = [goData.nosepokeexitframe];
    goEntry = [goData.nosepokeentryframe];
    goReward = [goData.rewardframe];
    
    nogoData = data(nogoFlags & [data.reward] == 1);
    emptyNogo = cellfun(@isempty,{nogoData.nosepokeexitframe});
    nogoData(emptyNogo) = []; % Remove correct No-go without leaving the nose-poke hole
    nogoExit = [nogoData.nosepokeexitframe];
    nogoEntry = [nogoData.nosepokeentryframe];
    nogoReward = [nogoData.rewardframe];

    % Mean lever presses during correct go trials
    nPress(iFile) = mean(cellfun(@length,{goData.lpressframe}));
    nosePokeExit(iFile) = mean((nogoExit - nogoEntry))/cfg.frameRate;

    % Mean latency to the first lever press
    pressLatency(iFile) = mean([goData.first_press_latency]);

    % Mean nose-poke hold
    goNosePokeHold(iFile) = mean(goExit - goEntry)/cfg.frameRate; 
    goNosePokeHold(iFile) = mean(goExit - nogoEntry)/cfg.frameRate;

    % Mean latency to collect reward
    lastPressFrame = cellfun(@(x) x(end),{goData.lpressframe});
    goRewardLatency(iFile) = mean(goReward - lastPressFrame)/cfg.frameRate;
    nogoRewardLatency(iFile) = mean(nogoReward - nogoExit)/cfg.frameRate;

    % Mean differential trial duration
    goDuration(iFile) = mean(goReward - goEntry)/cfg.frameRate;
    nogoDuration(iFile) = mean(nogoReward - nogoEntry)/cfg.frameRate;
end

