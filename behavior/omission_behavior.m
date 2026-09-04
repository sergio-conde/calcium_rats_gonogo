clear; clc

%%% load the default main omission trials configuration
cfg = gonogo_mainconfig('omission');                                        % read main configuration
cfg.file.level_name = {'cohort','rat','omission'};                          % adjust level_name configuration to read trials.mat files
cfg.file.folder_coding = {'*ohort_*','*','*_o*'};                           % adjust foler_coding
cfg.file.file_str = 'trials.mat';                                           % indicate file name coding
om_trials = proj_organigram(cfg.file);                                      % create file list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Descriptive statistics 

om_desc = struct([]);                                                         % initialize variable
for ifile = 1:length(om_trials)
    load(om_trials(ifile).file_path)                                          % load trials.mat file

    om_desc(ifile).cohort       = str2double(om_trials(ifile).cohort(8));     % include cohort
    om_desc(ifile).area         = om_trials(ifile).cohort(end-1:end);         % include area
    om_desc(ifile).rat          = om_trials(ifile).rat;                       % include rat
    om_desc(ifile).omission     = om_trials(ifile).omission;                  % include omission session
    om_desc(ifile).omission_id  = str2double(om_trials(ifile).omission(end)); % inlcude omission session
    om_desc(ifile).ncells       = size(trials(1).C,1);                        % include number of cells
    om_desc(ifile).ntrials      = length(trials);                             % include number of trials

    nogo_flags                  = [trials(:).nogo];                           % compute nogo trials flags
    om_desc(ifile).nogo_ntrials = sum(nogo_flags);                            % include number of nogo trials
    om_desc(ifile).go_ntrials   = sum(~nogo_flags);                           % include number of go trials

    reward_trials         = [trials(:).reward];                               % compute reward flags
    om_desc(ifile).ncorr  = sum(reward_trials);                               % include total number of correct trials
    om_desc(ifile).nerr   = sum(~reward_trials);                              % include total number of errors

    om_desc(ifile).ncorr_go   = sum(reward_trials & ~nogo_flags);             % include correct go trials
    om_desc(ifile).nerr_go    = sum(~reward_trials & ~nogo_flags);            % include error go trials
    om_desc(ifile).ncorr_nogo = sum(reward_trials & nogo_flags);              % include correct nogo trials
    om_desc(ifile).nerr_nogo  = sum(~reward_trials & nogo_flags);             % include error nogo trials
    om_desc(ifile).perf_go    = 100 * sum(reward_trials & ~nogo_flags)...     % iclude go performance
        /sum(~nogo_flags);
    om_desc(ifile).perf_nogo  = 100 * sum(reward_trials & nogo_flags)...      % include nogo performance
    /sum(nogo_flags);
    om_desc(ifile).trial_file = om_trials(ifile).file_path;                   % include original trial.mat path

end
% save([cfg.file.main_path '\omission_behavior.mat'],'om_desc')
%%
load([cfg.file.main_path '\omission_behavior.mat'])
%%
om_desc([5 6]) = [];                                                        % removng Sep because of its low perfomance

%% group and session results

wfig(1); clf
area_marker = 'o*';
lag = [-1 1] * 0.1;
sel_vars = {'ncells','ntrials'};
for ivar = 1:2
    var_name = sel_vars{ivar};
    subplot(1,2,ivar)
    for iom = 1:2
        om_flags = [om_desc(:).omission_id] == iom;
        mean_val = mean([om_desc(om_flags).(var_name)]);
        ste_val = std([om_desc(om_flags).(var_name)])/sqrt(sum(om_flags));
        bar(iom,mean_val,'FaceColor',0.87 * ones(1,3))
        hold on
        errorbar(iom,mean_val,ste_val,'.k')
        for iarea = 1:2
            area_ref = repmat(cfg.analysis.areas(iarea),1,length(om_desc));
            area_flags = cellfun(@strcmp,area_ref,{om_desc(:).area});
            area_vals = [om_desc(om_flags & area_flags).(var_name)];
            plot(iom * ones(1,length(area_vals)) + lag(iarea),area_vals,...
                area_marker(iarea),"Color",'k');
        end
    end
    box off
    set(gca,'xtick',[1 2],'XTickLabel',{'omission 1','omission 2'})
    xlim([0.5 2.5])
    ylabel(var_name)
end
%%
wfig(2); clf
area_marker = 'o*';
lag = [-1 1] * 0.1;
sel_vars = {'nogo_ntrials','go_ntrials','perf_nogo','perf_go'};
var_label = {'nogo trials','go trials','nogo performance','go performance'};
isp = 1;
for ivars = 1:length(sel_vars)
    subplot(2,2,isp)
    var_name = sel_vars{ivars};
    for iom = 1:2
        om_flags = [om_desc(:).omission_id] == iom;
        mean_val = mean([om_desc(om_flags).(var_name)]);
        ste_val = std([om_desc(om_flags).(var_name)])/sqrt(sum(om_flags));
        bar(iom,mean_val,'FaceColor',0.87 * ones(1,3))
        hold on
        errorbar(iom,mean_val,ste_val,'.k')
        for iarea = 1:2
            area_ref = repmat(cfg.analysis.areas(iarea),1,length(om_desc));
            area_flags = cellfun(@strcmp,area_ref,{om_desc(:).area});
            area_vals = [om_desc(om_flags & area_flags).(var_name)];
            plot(iom * ones(1,length(area_vals)) + lag(iarea),area_vals,...
                area_marker(iarea),"Color",'k');
        end
    end
    box off
    set(gca,'xtick',[1 2],'XTickLabel',{'omission 1','omission 2'})
    xlim([0.5 2.5])
    ylabel(var_label{ivars})
    isp = isp + 1;
end




