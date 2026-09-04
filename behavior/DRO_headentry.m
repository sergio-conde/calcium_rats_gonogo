clear; clc
gng           = gonogo_mainconfig;
session_type  = {'regular','omission','err'};

beh_cfg = [];

% Go/Nogo % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \ E = Event identity time stamps
beh_cfg.itiStart   = 1;    % \ 1 - iti start
beh_cfg.trialStart = 2;    % \ 2 - trial Start
beh_cfg.reward     = 3;    % \ 3 - Reward
beh_cfg.trialHead  = 12;   % \ 12 - Head-entry during trial
beh_cfg.itiHead    = 13;   % \ 13 - Head-entry during iti
beh_cfg.cue1kOn    = 50;   % \ 50 - cue 1 KHz ON
beh_cfg.cue1kOff   = 51;   % \ 51 - cue 1 KHz OFF
beh_cfg.cue3kOn    = 52;   % \ 52 - cue 3 KHz ON
beh_cfg.cue3kOff   = 53;   % \ 53 - cue 3 KHz OFF
beh_cfg.sessionEnd = 100;  % \ 100 - End of session
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select between regular, omission (or error)
itype = 2; 

% load the file list
trial_name = sprintf('%s_trials.mat',session_type{itype}); 
trial_list = importdata(fullfile(gng.file.support,trial_name));
% %
isession = 1;
if isession == 1
    trial_list([7:10 17 18]) = [];
else
    trial_list(9:10) = [];
end
sess_files = pick_files(trial_list,'session_id',isession);

%%

wfig(isession); clf
time_bins = -200:400;
center_bins = linspace(-2,4,length(time_bins)) + 0.5;
for ifile = 1:length(sess_files)
    trials = importdata(fullfile(sess_files(ifile).folder,sess_files(ifile).name));
    rew_trials = pick_files(trials,'reward',1,'nogo',0);
  
    time_hist = nan(length(rew_trials),length(time_bins) - 1);

    for itrial = 1:length(rew_trials)
        tone_flag = [rew_trials(itrial).E] == 52;
        tone_time = [rew_trials(itrial).D(tone_flag)];
        tone_time = tone_time - rew_trials(itrial).E(1);

        np_flags = [rew_trials(itrial).E] == 20;
        np_times = [rew_trials(itrial).D(np_flags)];
        np_times = np_times - rew_trials(itrial).E(1) - tone_time;
        time_hist(itrial,:) = histcounts(np_times,time_bins) > 0;
    end

    subplot(3,3,ifile)
    imagesc(center_bins,[],time_hist)
    hold on
    plot([0 0],[0 itrial],'r','LineWidth',2)
    plot([0.5 0.5],[0 itrial],'r','LineWidth',2)
    hold off;
    ylabel 'trial #'; xlabel('time (s)')
    animal_name = sess_files(ifile).rat_label;
    area = sess_files(ifile).area_label;
    title(sprintf('%s - %s',animal_name,area))
end

