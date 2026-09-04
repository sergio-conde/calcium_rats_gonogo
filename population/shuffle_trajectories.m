%% THIS SHUFFLES THE GO AND NOGO LABELS IN ORDER TO EXTARACT THE SHUFFLED EXPLAINED VARIANCE
% %% Creates the trajectories from the regular files 
clear; clc
gng = gonogo_mainconfig;
load(fullfile(gng.file.support,'regular_trials.mat'))

ref_frames = [29 60];

for ifile = 1:length(regular_trials)
    fprintf('Processing %s ...\n',regular_trials(ifile).rat_label)
    load(fullfile(regular_trials(ifile).folder,regular_trials(ifile).name));

    entry         = [];
    entry.reward  = 1;
    trials        = get_entry(trials,entry);

    sh_trials = trials;
    n_go = sum(~[trials.nogo]);

    tr_sh.nogo = [];
    tr_sh.go = [];
    task_var = nan(1,300);
    time_var = nan(1,300);
    tot_var = nan(1,300);

    for ishuff = 1:300

        sh_nogo = ones(1,length(trials));
        sh_nogo(randperm(length(trials),n_go)) = 0;
        sh_labels = num2cell(sh_nogo);
        [sh_trials(:).nogo] = sh_labels{:};

        %Builds the data in the required format. All these input/output variables are described in the readme files within data folders.
        [dpca_data,firingRates,firingRatesAverage,trialNum,ind_ee] = DataPreProcess_correct(sh_trials,0,1,ref_frames,true);

        % takes only correct trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        firingRates         = squeeze(firingRates(:,:,1,:,:));
        firingRatesAverage  = squeeze(firingRatesAverage(:,:,1,:));
        trialNum            = squeeze(trialNum(:,:,1));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        fprintf('\tComputing dpca shuffle %i ... ',ishuff)
        % Computes the dimensionality reduced components only with correct trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [W,V,~,~,whichMarg,explVar] = dpca_gonogo_corr(firingRates,firingRatesAverage,trialNum);
        % Builds the task relevant and time-related trajectories. Also,reconstructs the all neuron's C values from the task related
        % and time related components (This is not used in any of the analysis).
        [firingRates_taskonly,Trajs_taskonly,...
            firingRates_timeonly,Trajs_timeonly,~] = ReconstructTrajs_correct(firingRates,V,W,trialNum,whichMarg,explVar);
        fprintf('done\n')

        task3 = find(whichMarg == 1,3);
        time3 = find(whichMarg == 2,3);
        task_var(ishuff) = sum(explVar.componentVar(task3));
        time_var(ishuff) = sum(explVar.componentVar(time3));
        tot_var(ishuff) = explVar.cumulativeDPCA(end);

        loc_nogo = squeeze(mean(Trajs_taskonly(1:3,:,1,1:trialNum(1,1)),4));
        tr_sh.nogo = cat(3,tr_sh.nogo,loc_nogo);

        loc_go = squeeze(mean(Trajs_taskonly(1:3,:,2,1:trialNum(1,2)),4));
        tr_sh.go = cat(3,tr_sh.go,loc_go);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    file_name = sprintf('sh_traj_regular_%s.mat',regular_trials(ifile).rat_label);
    % save(fullfile(regular_trials(ifile).folder,file_name),'tr_sh','task_var','time_var','tot_var')
    fprintf('%s done\n\n',regular_trials(ifile).rat_label)
end

%% Creates the trajectories from the omission files 

clear; clc
gng = gonogo_mainconfig;
load(fullfile(gng.file.support,'omission_trials.mat'))

ref_frames = [29 63];

for ifile = 14:length(omission_trials)
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

    sh_trials = trials;
    n_go = sum(~[trials.nogo]);

    tr_sh.nogo = [];
    tr_sh.go = [];
    task_var = nan(1,300);
    time_var = nan(1,300);
    tot_var = nan(1,300);

    for ishuff = 1:300

        sh_nogo = ones(1,length(trials));
        sh_nogo(randperm(length(trials),n_go)) = 0;
        sh_labels = num2cell(sh_nogo);
        [sh_trials(:).nogo] = sh_labels{:};

        %Builds the data in the required format. All these input/output variables are described in the readme files within data folders.
        [dpca_data,firingRates,firingRatesAverage,trialNum,ind_ee] = DataPreProcess_correct(sh_trials,0,1,ref_frames,true);

        % takes only correct trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        firingRates         = squeeze(firingRates(:,:,1,:,:));
        firingRatesAverage  = squeeze(firingRatesAverage(:,:,1,:));
        trialNum            = squeeze(trialNum(:,:,1));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        fprintf('\tComputing dpca shuffle %i ... ',ishuff)
        % Computes the dimensionality reduced components only with correct trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [W,V,~,~,whichMarg,explVar] = dpca_gonogo_corr(firingRates,firingRatesAverage,trialNum);
        % Builds the task relevant and time-related trajectories. Also,reconstructs the all neuron's C values from the task related
        % and time related components (This is not used in any of the analysis).
        [firingRates_taskonly,Trajs_taskonly,...
            firingRates_timeonly,Trajs_timeonly,~] = ReconstructTrajs_correct(firingRates,V,W,trialNum,whichMarg,explVar);
        fprintf('done\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        task3 = find(whichMarg == 1,3);
        time3 = find(whichMarg == 2,3);
        task_var(ishuff) = sum(explVar.componentVar(task3));
        time_var(ishuff) = sum(explVar.componentVar(time3));
        tot_var(ishuff) = explVar.cumulativeDPCA(end);

        if length(task3) == 3
            loc_nogo = squeeze(mean(Trajs_taskonly(1:3,:,1,1:trialNum(1,1)),4));
            tr_sh.nogo = cat(3,tr_sh.nogo,loc_nogo);

            loc_go = squeeze(mean(Trajs_taskonly(1:3,:,2,1:trialNum(1,2)),4));
            tr_sh.go = cat(3,tr_sh.go,loc_go);
        end

    end

    file_name = sprintf('sh_traj_omission%i_%s.mat',...
        omission_trials(ifile).session_id,...
        omission_trials(ifile).rat_label);
    save(fullfile(omission_trials(ifile).folder,file_name),'tr_sh','task_var','time_var','tot_var')
    fprintf('%s done\n\n',omission_trials(ifile).rat_label)
end

%% These approach takes the actual trajectories and shift them in time. 
clear; clc
gng = gonogo_mainconfig;
load(fullfile(gng.file.support,'traj_regular.mat'));
traj_files = traj_regular;

nsh     = 100;
max_sh  = 45;

%%
%trialNum NoGo x Go 
for itraj = 8%:nfiles
    load(fullfile(traj_files(itraj).folder,traj_files(itraj).name),'Trajs_taskonly','W','V','whichMarg','firingRates_taskonly','trialNum');
    go_data   = squeeze(firingRates_taskonly(:,2,:,1:trialNum(1,2)));
    nogo_data = squeeze(firingRates_taskonly(:,1,:,1:trialNum(1,1)));
    sh_go     = shift_traj(go_data,nsh,max_sh,W,whichMarg);
    sh_nogo   = shift_traj(nogo_data,nsh,max_sh,W,whichMarg);
end

%%
wfig(11); clf
plot3(sh_go.shift(:,1),sh_go.shift(:,2),sh_go.shift(:,3),'-*b')
hold on
% plot3(sh_go.perm(:,1),sh_go.perm(:,2),sh_go.perm(:,3),'-ob')
plot3(sh_nogo.shift(:,1),sh_nogo.shift(:,2),sh_nogo.shift(:,3),'-*r')
% plot3(sh_nogo.perm(:,1),sh_nogo.perm(:,2),sh_nogo.perm(:,3),'-or')
plot3(sh_go.traj(:,1),sh_go.traj(:,2),sh_go.traj(:,3),'b')
plot3(sh_nogo.traj(:,1),sh_nogo.traj(:,2),sh_nogo.traj(:,3),'r')
hold off
grid on
%%


for itraj = 8%:nfiles
    load(fullfile(traj_files(itraj).folder,traj_files(itraj).name),'Trajs_taskonly','W','V','whichMarg','firingRates_taskonly','trialNum');
    nmix = round(trialNum(1,:)/2);
    task_related = whichMarg == 1; % 1 - Task; 2 - Time
    for ish = 1:2%100
        go_traj = [];
        nogo_traj = [];

        go_data   = squeeze(firingRates_taskonly(:,2,:,1:trialNum(1,2)));
        nogo_data = squeeze(firingRates_taskonly(:,1,:,1:trialNum(1,1)));

        
        for itrial = 1:size(go_data,3)
            tr_data   = squeeze(go_data(:,:,itrial));
            go_traj = cat(3,go_traj,tr_data*W(:,task_related));
        end
        for itrial = 1:size(nogo_data,3)
            tr_data   = squeeze(nogo_data(:,:,itrial));
            nogo_traj = cat(3,nogo_traj,tr_data*W(:,task_related));
        end
        all_go_traj(:,:,ish)   = mean(go_traj,3);
        all_nogo_traj(:,:,ish) = mean(nogo_traj,3);
    end
end

plot_go = mean(all_go_traj,3);
plot_nogo = mean(all_nogo_traj,3);

wfig(111); clf
plot3(plot_go(:,1),plot_go(:,2),plot_go(:,3),'b')
hold on
plot3(plot_nogo(:,1),plot_nogo(:,2),plot_nogo(:,3),'r')
hold off
grid on