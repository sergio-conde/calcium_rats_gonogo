function behavior = extractBehavior(cfg)
if ~isfield(cfg,'frameRate')
    cfg.frameRate = 15;
end
Nfiles = length(cfg.fileList); % Number of files
% Initialize behavioral variables:
variableLabels = {
    'nPress',... % number of lever presses
    'pressLatency',... % Latency to press during go trials
    'goNosePokeHold',... % Nose-poke hole after cue during go trials
    'nogoNosePokeHold',... % Nose-poke hole after cue during no-go trials
    'goRewardLatency',... % Latency to collect reward during go trials
    'nogoRewardLatency',... % Latency to collect reward during no-go trials
    'goExitLatency',... % latency to leave the nose-poke hole during go trials
    'nogoExitLatency',... % latency to leave the nose-poke hole during no-go trials
    'goDuration',... % go trials duration
    'nogoDuration'}; % no-go trials duration
nPress = nan(Nfiles,1);
pressLatency = nan(Nfiles,1);
goNosePokeHold = nan(Nfiles,1);
nogoNosePokeHold = nan(Nfiles,1);
goRewardLatency = nan(Nfiles,1);
nogoRewardLatency = nan(Nfiles,1);
goExitLatency = nan(Nfiles,1);
nogoExitLatency = nan(Nfiles,1);
goDuration = nan(Nfiles,1);
nogoDuration = nan(Nfiles,1);
% For all files in the list:
fprintf('\n>-- PROCESSING BEHAVIOR --<\n')
for iFile = 1:Nfiles
    fprintf('\nFolder: %s\nFile: %s\n',...
        cfg.fileList(iFile).folder, ...
        cfg.fileList(iFile).name)
    % read behavioral data
    data = load(fullfile(cfg.fileList(iFile).folder,cfg.fileList(iFile).name));
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
    if strcmp(cfg.rule,'gng')
        % Mean latency to the first lever press
        firstPressFrame = cellfun(@(x) x(1),{goData.lpressframe});
        pressLatency(iFile) = mean(firstPressFrame - goExit)/cfg.frameRate;
        % Mean latency to collect reward during go trials
        lastPressFrame = cellfun(@(x) x(end),{goData.lpressframe});
        goRewardLatency(iFile) = mean(goReward - lastPressFrame)/cfg.frameRate;
    else
        % Mean latency to the first lever press
        pressLatency(iFile) = nan;
        % Mean latency to collect reward during go trials
        goRewardLatency(iFile) = nan;
    end
    % Mean nose-poke hold
    goNosePokeHold(iFile) = mean(goExit - goEntry)/cfg.frameRate;
    nogoNosePokeHold(iFile) = mean(nogoExit - nogoEntry)/cfg.frameRate;
    % Mean latency to leave the nose-poke hole
    goExitLatency(iFile) = goNosePokeHold(iFile);
    nogoExitLatency(iFile) = nogoNosePokeHold(iFile);
    % Mean latency to collect reward during no-go trials
    nogoRewardLatency(iFile) = mean(nogoReward - nogoExit + 1)/cfg.frameRate;
    % Mean differential trial duration
    goDuration(iFile) = mean(goReward - goEntry + 1)/cfg.frameRate;
    nogoDuration(iFile) = mean(nogoReward - nogoEntry + 1)/cfg.frameRate;
    fprintf('Done\n')
end
behavior.cfg = rmfield(cfg,"fileList");
behavior.data = cfg.fileList;
if isstruct(behavior.data)
    behavior.data = struct2table(cfg.fileList);
end
behavior.data = addvars(behavior.data,...
    nPress,...
    pressLatency,...
    goNosePokeHold,...
    nogoNosePokeHold,...
    goRewardLatency,...
    nogoRewardLatency,...
    goExitLatency,...
    nogoExitLatency,...
    goDuration,...
    nogoDuration,...
    NewVariableNames = variableLabels);
