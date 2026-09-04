
%% Creates the trajectories from the regular files 
clear; clc
gng = gonogo_mainconfig;
load(fullfile(gng.file.support,'regular_trials.mat'))

ref_frames = [29 60];

for ifile = 1%:length(regular_trials)
    fprintf('Processing %s ...\n',regular_trials(ifile).rat_label)
    load(fullfile(regular_trials(ifile).folder,regular_trials(ifile).name));

    entry         = [];
    entry.reward  = 1;
    trials        = get_entry(trials,entry);

    %Builds the data in the required format. All these input/output variables are described in the readme files within data folders.
    [dpca_data,firingRates,firingRatesAverage,trialNum,ind_ee] = DataPreProcess_correct(trials,0,1,ref_frames,true);

    % takes only correct trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    firingRates         = squeeze(firingRates(:,:,1,:,:));
    firingRatesAverage  = squeeze(firingRatesAverage(:,:,1,:));
    trialNum            = squeeze(trialNum(:,:,1));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('\tComputing dpca ... ')
    % Computes the dimensionality reduced components only with correct trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [W,V,~,~,whichMarg,explVar] = dpca_gonogo_corr(firingRates,firingRatesAverage,trialNum);
    % Builds the task relevant and time-related trajectories. Also,reconstructs the all neuron's C values from the task related
    % and time related components (This is not used in any of the analysis).
    [firingRates_taskonly,Trajs_taskonly,...
        firingRates_timeonly,Trajs_timeonly,~] = ReconstructTrajs_correct(firingRates,V,W,trialNum,whichMarg,explVar);
    fprintf('done\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    file_name = sprintf('traj_regular_%s.mat',regular_trials(ifile).rat_label);
    % save(fullfile(regular_trials(ifile).folder,file_name),"Trajs_taskonly","Trajs_timeonly",...
    % "explVar",'trialNum','firingRates_taskonly','W','V','whichMarg',ind_ee)
    fprintf('%s done\n\n',regular_trials(ifile).rat_label)
end

%% Creates the trajectories from the omission files 

clear; clc
gng = gonogo_mainconfig;
load(fullfile(gng.file.support,'omission_trials.mat'))

ref_frames = [29 63];

for ifile = 1%:length(omission_trials)
    fprintf('Processing %s ...\n',omission_trials(ifile).rat_label)
    load(fullfile(omission_trials(ifile).folder,omission_trials(ifile).name));

    % This is only to make Pipa run. The trial file was saved as FV_trials.
    if strcmp(omission_trials(ifile).rat_label,'Pipa') 
        trials = FV_trials;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % This is only to remove the cell 30 from Nov that was at zeros.
    % Check why this happened 
    if ifile == 6
        for itrial = 1:length(trials)
            trials(itrial).Craw(30,:) = [];
            trials(itrial).C(30,:)    = [];
            trials(itrial).S(30,:)    = [];
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nframes               = cellfun(@(x) size(x,2),{trials.Craw});
    trials(nframes < 93)  = [];

    seq.nogo = logical([trials.nogo]);
    seq.rew  = logical([trials.reward]);
   
    entry         = [];
    entry.reward  = 1;
    trials        = get_entry(trials,entry);

    %Builds the data in the required format. All these input/output variables are described in the readme files within data folders.
    [dpca_data,firingRates,firingRatesAverage,trialNum,ind_ee] = DataPreProcess_correct(trials,0,1,ref_frames,true);

    % takes only correct trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    firingRates         = squeeze(firingRates(:,:,1,:,:));
    firingRatesAverage  = squeeze(firingRatesAverage(:,:,1,:));
    trialNum            = squeeze(trialNum(:,:,1));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('\tComputing dpca ... ')
    % Computes the dimensionality reduced components only with correct trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [W,V,~,~,whichMarg,explVar] = dpca_gonogo_corr(firingRates,firingRatesAverage,trialNum);
    % Builds the task relevant and time-related trajectories. Also,reconstructs the all neuron's C values from the task related
    % and time related components (This is not used in any of the analysis).
    [firingRates_taskonly,Trajs_taskonly,...
        firingRates_timeonly,Trajs_timeonly,~] = ReconstructTrajs_correct(firingRates,V,W,trialNum,whichMarg,explVar);
    fprintf('done\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nogo_seq  = logical([trials.nogo]);
    file_name = sprintf('traj_omission_%i_%s.mat',...
        omission_trials(ifile).session_id,omission_trials(ifile).rat_label);
    % save(fullfile(omission_trials(ifile).folder,file_name),"Trajs_taskonly","Trajs_timeonly",...
    % 'firingRates_taskonly',"explVar",'trialNum','whichMarg','nogo_seq')
    fprintf('%s done\n\n',omission_trials(ifile).rat_label)
end

%% Creates the trajectories from the error trials in omission session

clear; clc
gng = gonogo_mainconfig;
load(fullfile(gng.file.support,'omission_trials.mat'))

ref_frames = [29 63];

for ifile = 1%:length(omission_trials)
    fprintf('Processing %s ...\n',omission_trials(ifile).rat_label)
    load(fullfile(omission_trials(ifile).folder,omission_trials(ifile).name));

    % This is only to make Pipa run. The trial file was saved as FV_trials.
    if strcmp(omission_trials(ifile).rat_label,'Pipa') 
        trials = FV_trials;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % This is only to remove the cell 30 from Nov that was at zeros.
    % Check why this happened 
    if ifile == 6
        for itrial = 1:length(trials)
            trials(itrial).Craw(30,:) = [];
            trials(itrial).C(30,:)    = [];
            trials(itrial).S(30,:)    = [];
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nframes               = cellfun(@(x) size(x,2),{trials.Craw});
    trials(nframes < 93)  = [];

    seq.nogo = logical([trials.nogo]);
    seq.rew  = logical([trials.reward]);

    entry         = [];
    entry.reward  = 0;
    trials        = get_entry(trials,entry);

    %Builds the data in the required format. All these input/output variables are described in the readme files within data folders.
    [dpca_data,firingRates,firingRatesAverage,trialNum,ind_ee] = DataPreProcess_correct(trials,0,1,ref_frames,true);

    % takes only error trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    firingRates         = squeeze(firingRates(:,:,2,:,:));
    firingRatesAverage  = squeeze(firingRatesAverage(:,:,2,:));
    trialNum            = squeeze(trialNum(:,:,2));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if all(trialNum(1,:) > 1)
        fprintf('\tComputing dpca ... ')
        % Computes the dimensionality reduced components only with correct trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [W,V,~,~,whichMarg,explVar] = dpca_gonogo_corr(firingRates,firingRatesAverage,trialNum);
        % Builds the task relevant and time-related trajectories. Also,reconstructs the all neuron's C values from the task related
        % and time related components (This is not used in any of the analysis).
        [firingRates_taskonly,Trajs_taskonly,...
            firingRates_timeonly,Trajs_timeonly,~] = ReconstructTrajs_correct(firingRates,V,W,trialNum,whichMarg,explVar);
        fprintf('done\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        file_name = sprintf('traj_err_omission_%i_%s.mat',...
            omission_trials(ifile).session_id,omission_trials(ifile).rat_label);
        % save(fullfile(omission_trials(ifile).folder,file_name),"Trajs_taskonly","Trajs_timeonly",...
        % 'firingRates_taskonly',"explVar",'trialNum','whichMarg','nogo_seq')
        fprintf('%s done\n\n',omission_trials(ifile).rat_label)
    end
end