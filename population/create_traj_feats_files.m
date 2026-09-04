% This script uses the traj_feat to compute for each trajectory file:

%   expvar: explained variance of the three first dpca components
%   nogo_ / go_len: mean length of all nogo / go trials
%   nogo_ / go_dist: mean start to end distance of all nogo / go trials
%   nogo_ / go traj: mean trajectories
%   nogo_ / go mlen: length of the mean trajectory
%   nogo_ / go mdist: start to end distance of the mean trajectory

% Sergio Conde-Ocazionez, 2023. NIN. Willuhn Lab.

clear; clc
gng = gonogo_mainconfig; % project's main configuration

% general configuration
ndim = 3; % number of components to be considered
trial_type = {'regular','omission','err'};
traj_type  = {'task','time'};

for itype = 2%1:3
    trials_file = strcat('traj_',trial_type{itype},'.mat');
    f_list      = load(fullfile(gng.file.support,trials_file),trials_file(1:end-4));
    for itraj = 1:2
        feats.(traj_type{itraj}) = f_list.(trials_file(1:end-4));
        for ifile = 1:length(feats.(traj_type{itraj}))
            traj = [feats.(traj_type{itraj})(ifile).folder '\' feats.(traj_type{itraj})(ifile).name];
            load(traj,'Trajs_taskonly','Trajs_timeonly',"explVar",'trialNum','whichMarg')

            expl_var.total = explVar.cumulativeDPCA(end);
            expl_var.task  = sum(explVar.componentVar(whichMarg == 1));
            expl_var.time  = sum(explVar.componentVar(whichMarg == 2));

            loc_feat.task = traj_feat(Trajs_taskonly,ndim,trialNum(1,:));
            loc_feat.time = traj_feat(Trajs_timeonly,ndim,trialNum(1,:));

            feats.(traj_type{itraj})(ifile).totalvar  = expl_var.total;
            feats.(traj_type{itraj})(ifile).expvar    = expl_var.(traj_type{itraj});
            feats.(traj_type{itraj})(ifile).nogo_trials = loc_feat.(traj_type{itraj}).nogo_trials;
            feats.(traj_type{itraj})(ifile).go_trials   = loc_feat.(traj_type{itraj}).go_trials;

            feats.(traj_type{itraj})(ifile).nogo_len  = mean([loc_feat.(traj_type{itraj}).nogo_trials(:).length]);
            feats.(traj_type{itraj})(ifile).go_len    = mean([loc_feat.(traj_type{itraj}).go_trials(:).length]);
            feats.(traj_type{itraj})(ifile).nogo_dist = mean([loc_feat.(traj_type{itraj}).nogo_trials(:).st_end_dist]);
            feats.(traj_type{itraj})(ifile).go_dist   = mean([loc_feat.(traj_type{itraj}).go_trials(:).st_end_dist]);

            feats.(traj_type{itraj})(ifile).nogo_traj   = loc_feat.(traj_type{itraj}).mean(1).traj;
            feats.(traj_type{itraj})(ifile).go_traj     = loc_feat.(traj_type{itraj}).mean(2).traj;
            feats.(traj_type{itraj})(ifile).nogo_mlen   = mean([loc_feat.(traj_type{itraj}).mean(1).length]);
            feats.(traj_type{itraj})(ifile).go_mlen     = mean([loc_feat.(traj_type{itraj}).mean(2).length]);
            feats.(traj_type{itraj})(ifile).nogo_mdist  = mean([loc_feat.(traj_type{itraj}).mean(1).st_end_dist]);
            feats.(traj_type{itraj})(ifile).go_mdist    = mean([loc_feat.(traj_type{itraj}).mean(2).st_end_dist]);
        end
    end
    save_name = strcat('traj_',trial_type{itype},'_feats.mat');
    % save(fullfile(gng.file.support,save_name),"feats")
end
