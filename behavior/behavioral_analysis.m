clear; clc
gng = gonogo_mainconfig;
load(fullfile(gng.file.support,'omission_trials.mat'))
load(fullfile(gng.file.support,'regular_trials.mat'))
% load(fullfile(gng.file.support,'switch_trials.mat'))
% load(fullfile(gng.file.support,'Magazine_headentry_lat.mat'))
% 
% trial_files.omission  = omission_trials;
% trial_files.regular   = regular_trials;
% type_label            = {'regular','omission'};
%% BEHAVIOR EXTRACTION

% Go/No-go rule
cfg = [];
cfg.fileList = regular_trials;
cfg.rule = 'gng';
behavior.gng = extractBehavior(cfg);

% DRO acquisition
cfg = [];
cfg.fileList = getEntry(omission_trials,'session_id',1);
cfg.rule = 'DRO-acquisition';
behavior.droAcquisition = extractBehavior(cfg);

% DRO acquired
cfg = [];
cfg.fileList = getEntry(omission_trials,'session_id',2);
cfg.rule = 'DRO-acquired';
behavior.droAcquisition = extractBehavior(cfg);


%% Basic behavior
isession   = 1;
sel_files  = getEntry(regular_trials,'session_id',isession);

n_press    = nan(length(sel_files),1); 
press_lat  = nan(length(sel_files),1);
np_hold    = nan(length(sel_files),1);
rew_hold   = nan(length(sel_files),1);
go_mov     = nan(length(sel_files),1);
rew_frame.nogo = nan(length(sel_files),1);
rew_frame.go   = nan(length(sel_files),1);

for irat = 1:length(sel_files)
    data = load(fullfile(sel_files(irat).folder,sel_files(irat).name));
    name = fieldnames(data);
    data = data.(name{1});
    data = getEntry(data,'reward',1);

    % Number of lever presses during correct go trials
    all_npress    = cellfun(@length,{data.lpressframe});
    n_press(irat) = median(all_npress(~[data.nogo]));

    % Latency to the first lever press
    % press_lat(irat) = median([data(~[data.nogo]).first_press_latency]);

    % Nose-poke exit latency during nogo correct trials
    % np_ref  = pick_files(gng.med.np_hold,'rat_label',sel_files(irat).rat_label);
    % np_exit = ([data([data.nogo] == 1).nosepokeexitframe] - [data([data.nogo] == 1).nosepokeentryframe]) / gng.analysis.fr_rate;
    % np_hold(irat) = median(np_exit) - np_ref.o1 - 0.5;

    % mean differential trial duration
    ref_frame = ([data.rewardframe] - [data.nosepokeentryframe]);
   
    diff_dur.go(irat)    = mean(ref_frame([data.nogo] == 0))./gng.analysis.fr_rate;
    diff_dur.nogo(irat)  = mean(ref_frame([data.nogo] == 1))./gng.analysis.fr_rate;

    nogo_data     = data([data.nogo] == 1 & [data.reward] == 1);
    empty_trials  = cellfun(@isempty,{nogo_data.nosepokeexitframe});
    nogo_data(empty_trials) = [];
    rew_frame.nogo(irat) = median([nogo_data.rewardframe] - [nogo_data.nosepokeentryframe]);

    % rew_hold(irat) = median(([nogo_data.nosepokeexitframe] - [nogo_data.rewardframe]))/gng.analysis.fr_rate;
    rew_hold(irat) = median(([nogo_data.nosepokeexitframe] - [nogo_data.rewardframe]))/gng.analysis.fr_rate;


    go_data = data([data.nogo] == 0 & [data.reward] == 1);
    rew_frame.go(irat) = median([go_data.rewardframe] - [go_data.nosepokeentryframe]);

    press_lat(irat) = median([go_data.first_press_latency]);
    
    go_mov(irat) = median(([go_data.nosepokeexitframe] - [go_data.nosepokeentryframe]))/gng.analysis.fr_rate; 

    % diff_dur(irat,1) = go_dur;
    % diff_dur(irat,2) = nogo_dur;
    % diff_dur(irat,3) = go_dur - nogo_dur;
end
diff_dur.gonogo = diff_dur.go - diff_dur.nogo;
diff_dur.area_id = [sel_files.area_id];
% save(fullfile(gng.file.publications,'/paper/figure_1/data/','gonogo_diff_dur.mat'),'diff_dur') 
% save(fullfile(gng.file.publications,'/paper/figure_2/data/','rew_frame.mat'),'rew_frame') 

%%
clc
npoints = 25;
cum_lp = nan(10,npoints);
ngo = nan(10,1);
lp_hz = nan(10,1);
for irat = 1:10
    fprintf('Processing rat %i ... ',irat)
    data = load(fullfile(sel_files(irat).folder,sel_files(irat).name));
    name = fieldnames(data);
    data = data.(name{1});
    go_data = getEntry(data,'reward',1,'nogo',0);
    nogo_data = getEntry(data,'reward',1,'nogo',1);

    ngo(irat) = length(go_data);

    %lever press frequency 

    go_dur = cellfun(@(x, b) (max(x) - b)/15, {go_data.lpressframe}, {go_data.nosepokeentryframe}, ...
        'UniformOutput', false);
    trial_hz = cellfun(@(x, b) length(x)/(b - 0.5), {go_data.lpressframe}, go_dur);
    lp_hz(irat) = mean(trial_hz);


    % lever presses time distribution along each trial
    ref_lp = cellfun(@(x,b) (x - b)/max(x - b), {go_data.lpressframe} , {go_data.nosepokeexitframe}, ...
        'UniformOutput', false);
    ref_lp = cat(2,ref_lp{:});
    cum_lp(irat,:) = histcounts(ref_lp,npoints)/ngo(irat);

    % np_reaction
    np_reaction.go{irat} = [go_data.nosepokeentryframe] - [go_data.nosepokecueonframe];
    np_reaction.nogo{irat} = [nogo_data.nosepokeentryframe] - [nogo_data.nosepokecueonframe];
    
    fprintf('done\n')
end
%%
react.go = cellfun(@mean,np_reaction.go)/15;
react.nogo = cellfun(@mean,np_reaction.nogo)/15;
react.lp = sum(cum_lp,2);

beh_table = struct2table(trial_files.regular);

beh_table.go_react = react.go';
beh_table.nogo_react = react.nogo';
beh_table.lp = react.lp;
beh_table.hdent_go = [results.HEmag_lat_go]';
beh_table.hdent_nogo = [results.HEmag_lat_nogo]';
% save(fullfile(gng.file.publications,'/paper/figure_1/data/','beh_table.mat'),'beh_table') 
%%
go_table = beh_table(:,{'area_label','area_id','go_react','hdent_go'});
go_table.Properties.VariableNames{3} = 'reaction';
go_table.Properties.VariableNames{4} = 'reward_pick';
go_table.task_label(:) = 0;  

nogo_table = beh_table(:,{'area_label','area_id','nogo_react','hdent_nogo'});
nogo_table.Properties.VariableNames{3} = 'reaction';
nogo_table.Properties.VariableNames{4} = 'reward_pick';
nogo_table.task_label(:) = 1;  

beh_table =  cat(1,go_table,nogo_table);
% writetable(beh_table,fullfile(gng.file.publications,'/paper/figure_1/data/','beh_table.csv')) 

%%
wfig(100); clf
set(gcf,"Position",[-1552 650  1141  199],'Renderer','painters')
mean_lp = sum(cum_lp,2);

subplot (1,6,2)
hold on
% histogram(cat(2,np_reaction.go{:})./15,0:0.25:5,...
%     "FaceColor",gng.graph.colors.task{2})
% hold on
% histogram(cat(2,np_reaction.nogo{:})./15,0:0.25:5,...
%     "FaceColor",gng.graph.colors.task{1})
% hold off;
% box off
% xlabel 'Nose-poke reaction time (s)'
% ylabel 'Number of trials'
% legend({'Go','No-go'},'Box','off')
for itask = 1:2
    task_field = lower(gng.analysis.trial_label{itask});
    task_react = react.(task_field);
    % boxchart(itask * ones(1,length(task_react)),react.(task_field),...
    %     'BoxFaceColor',gng.graph.colors.task{itask},...
    %     'MarkerStyle','.',...
    %     'MarkerColor',gng.graph.colors.task{itask});

    mean_react = mean(react.(task_field));
    err_react = std(react.(task_field))/sqrt(10);

    bar(itask,mean_react,...
        'FaceColor',gng.graph.colors.task{itask},...
        'FaceAlpha',0.45)
    errorbar(itask,mean_react,err_react,'.k')


    plot(itask,react.(task_field)','o',...
        'Color',gng.graph.colors.task{itask},...
        'MarkerFaceColor',gng.graph.colors.task{itask},...
        'MarkerSize',3);
end
ylim([0 1.5])

subplot (1,6,3)
% boxplot(mean_lp,'Colors',gng.graph.colors.task{2})
lp_mean = mean(mean_lp);
lp_err = std(mean_lp)./sqrt(10);
bar(lp_mean,...
        'FaceColor',gng.graph.colors.task{2},...
        'FaceAlpha',0.45)
hold on
errorbar(lp_mean,lp_err,'.k')
plot(1,mean_lp,'o',...
    'MarkerSize',4,...
    'MarkerFaceColor',gng.graph.colors.task{2},...
    'MarkerEdgeColor',gng.graph.colors.task{2})
hold off; box off; axis tight
ylim([0 7]); 
xlim([0.2 1.8])
ylabel 'Lever presses / trial'

data_cfg = [];
data_cfg.ydata = cum_lp(:,1:end - 1);
full_x = linspace(0,1,size(data_cfg.ydata,2) + 1);
data_cfg.xdata = full_x(1:end - 1);
data_cfg.color_val = gng.graph.colors.task{2};
subplot(1,6,4:5)
avg_err_shade(data_cfg);
box off; 
xlabel 'Relative lever press time (s)' 
ylabel 'Lever presses (%)'
% saveas(gcf,fullfile(gng.file.publications,'/paper/figure_1/','gen_beh.eps'),'epsc')

react.cum_lp = cum_lp;
% save(fullfile(gng.file.publications,'/paper/figure_1/data/','react.mat'),'react')



%%
wfig(1); clf
subplot 131
boxplot(go_mov,'Orientation','horizontal')
hold on
plot(go_mov,1,'ok')
hold off; box off
xlabel 'go mov latency (s)'
set(gca,'YTick','')
subplot 132
boxplot(press_lat,'Orientation','horizontal')
hold on
plot(press_lat,1,'ok')
hold off; box off
xlabel '1st press latency (s)'
set(gca,'YTick','')
subplot 133
boxplot(rew_hold,'Orientation','horizontal')
hold on
plot(rew_hold,1,'ok')
hold off; box off
xlabel 'exit latency (s)'
set(gca,'YTick','')

%%
wfig(100)
subplot 131
boxplot(n_press); 
box off; ylabel '# lever presses'; set(gca,'XTick','')
subplot 132
boxplot(press_lat)
box off; ylabel '1st press latency (s)'; set(gca,'XTick','')
subplot 133
boxplot(np_hold)
box off; ylabel 'nose poke hold'; set(gca,'XTick','')

%%
% % cumulative correct trials

% the faster they get to the max number of correct, the better they are
% in the case of omission 1: it says something about learning, contingency
% updating

wfig(1); clf
nsp = 1;
cum_correct = cell(1,6);
for itype = 1:2 % for regular and omission trials
    curr_trials = trial_files.(type_label{itype});
    for isession = 1:2 % for sessions 1 and 2

        sess_trials = pick_files(curr_trials,'session_id',isession);
        if itype == 2
            sess_trials(5) = [];
        end
        if ~isempty(sess_trials)
            for inogo = 0:1
                if inogo == 1; trial_label = 'NoGo'; else; trial_label = 'Go'; end
                cum_correct{nsp} = nan(length(sess_trials),150);
                ntrials     = nan(length(sess_trials),1);
                for ifile = 1:length(sess_trials)
                    load(fullfile(sess_trials(ifile).folder,sess_trials(ifile).name));
                    type_trials = trials([trials.nogo] == inogo);
                    cum_correct{nsp}(ifile,1:length(type_trials)) = cumsum([type_trials.reward]);
                    % nerror = sum(~[type_trials.reward]);
                    % cum_correct(ifile,1:length(type_trials)) = cumsum(~[type_trials.reward])./nerror;
                    ntrials(ifile) = length(type_trials);
                end
                subplot(3,2,nsp); nsp = nsp + 1;
                plot([0 max(ntrials)],[0 max(ntrials)],'--','Color',0.7 * ones (1,3))
                % plot([0 max(ntrials)],[0 1],'--','Color',0.7 * ones (1,3))
                hold on
                plot(cum_correct{nsp - 1}');
                hold off; box off
                legend({'',sess_trials.rat_label},'Location','northeastoutside',...
                    'Box','off')
                xlabel(sprintf('%s trial number',trial_label));
                ylabel(sprintf('cumulative correct %s trials',trial_label));
                title(sprintf('%s %i; %s',type_label{itype},isession,trial_label))
                axis tight
                % axis equal
            end
        end
    end
end
%% cumulative, group result

% elements 3 and 4 correspond to omission 1 (go and nogo respectively). 5
% and 6 to omission 2
refs = [3 4;5 6];
c_ref = [2 1];
wfig(99); clf
set(gcf,"Position",[968 550 458 243])
for iref = 1:2
    subplot(1,2,iref)

    for icum = 1:2
        sh = [];
        sh.ydata = cum_correct{refs(iref,icum)};
        sh.color_val = gng.graph.colors.task{c_ref(icum)};

        valid_rats = sum(~isnan(cum_correct{refs(iref,icum)}),1);
        del_points = valid_rats < 2;
        sh.ydata(:,del_points) = [];
        
        avg_err_shade(sh);
        hold on
    end
    plot([0 100],[0 100],'--k')
    xlim([0 50]); ylim([0 50])
    hold off; box off; axis square
    xlabel 'trial number'
    ylabel 'Cumulative correct trials'
    legend({'','Go','','No-go',''},'Box','off','Location','northwest')
    title(sprintf('Omission sesson %i',iref)) 
end
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','cum_correct.mat'),'cum_correct')

%% SLIDING MEAN performance OVER A SHORT WINDOW

win_size  = 5;
isession  = 1;
sw = struct([]);

iline = 1;
for itrial_type = 1:2
    inogo       = gng.analysis.trial_id(itrial_type);
    trial_label = gng.analysis.trial_type{itrial_type};
    wfig(2 + itrial_type); clf
    for irat = 1:length(regular_trials)
        om_file = pick_files(omission_trials,'session_id',isession,'rat_label',regular_trials(irat).rat_label);
        if ~isempty(om_file)
            om_fields = fieldnames(om_file);
            for ifield = 1:5
                sw(iline).(om_fields{ifield}) = om_file.(om_fields{ifield});
            end
            sw(iline).trial_type = trial_label;
            sw(iline).trial_id   = itrial_type;

            reg = load(fullfile(regular_trials(irat).folder,regular_trials(irat).name));
            om  = load(fullfile(om_file.folder,om_file.name));
            om_name = fieldnames(om);

            reg_perf = movmean([reg.trials([reg.trials.nogo] == inogo).reward],win_size);
            reg_mean = mean(reg_perf);
            reg_sem  = std(reg_perf)/sqrt(length(reg_perf));
            reg_ci   = reg_mean + reg_sem * tinv([0.025 0.975],length(reg_perf) - 1);

            [~,~,~,trialNum,ind_ee] = DataPreProcess_correct(om.(om_name{1}),0,1,[29 63],true);
            % no_show = cellfun(@isempty,{om.(om_name{1}).nosepokeentryframe});
            om.(om_name{1})(ind_ee) = [];

            om_perf = movmean([om.(om_name{1})([om.(om_name{1}).nogo] == inogo).reward],win_size);
            rat_switch = find(om_perf >= reg_ci(1),1);
            if isempty(rat_switch)
                rat_switch = length(om_perf);
            end
            sw(iline).switch = rat_switch;
            sw(iline).trial_num = find([om.(om_name{1}).nogo] == inogo);
            sw(iline).correct   = find([om.(om_name{1}).nogo] == inogo & [om.(om_name{1}).reward]);
            sw(iline).errors    = find([om.(om_name{1}).nogo] == inogo & ~[om.(om_name{1}).reward]);


            subplot (2,5,irat)
            plot([1 length(om_perf)],[reg_mean reg_mean],'Color',0.6 * ones(1,3))
            hold on
            plot([1 length(om_perf)],[reg_ci(1) reg_ci(1)],'--','Color',0.6 * ones(1,3))
            plot([1 length(om_perf)],[reg_ci(2) reg_ci(2)],'--','Color',0.6 * ones(1,3))
            plot(om_perf,'-o','Color',gng.graph.colors.area{om_file.area_id},...
                'MarkerFaceColor',gng.graph.colors.area{om_file.area_id},'Markersize',4)
            plot(sw(iline).switch,om_perf(sw(iline).switch),'or','MarkerFaceColor','r')
            plot([sw(iline).switch sw(iline).switch],[0 1],'--r')
            hold off; box off;
            ylabel(sprintf('%s performance omission %i',gng.analysis.trial_type{itrial_type},isession));
            xlabel(sprintf('%s trial number',gng.analysis.trial_type{itrial_type}))
            title(sprintf('%s (%s)',om_file.rat_label,om_file.area_label));
            ylim([0 1])

            iline = iline + 1;
        end
        
    end
end
% save(fullfile(gng.file.support,'switch_trials.mat'),'sw')
%% "summary" directly plotting regular vs omission switch trials

wfig(5); clf
for irat = 1:length(regular_trials)
plot(sw{1}(irat),sw{2}(irat),'.','MarkerSize',15)
hold on
end
box off; xlabel 'switch Go trial '; ylabel 'switch No-Go trial'
legend(regular_trials.rat_label,'Location','northeastoutside','Box','off')

%% was the # of presses befpre they updated the rule similar to the one observed during the regular trials and then went to minimum?

isession  = 1;
inogo     = 0;

wfig(66); clf

for irat = 1:10
    om_file = pick_files(omission_trials,'session_id',isession,'rat_label',regular_trials(irat).rat_label);
    
    if ~isempty(om_file)
        sw_info = pick_files(sw,'rat_label',om_file.rat_label,'trial_id',2);

        reg = load(fullfile(regular_trials(irat).folder,regular_trials(irat).name));
        om  = load(fullfile(om_file.folder,om_file.name));
        om_name = fieldnames(om);

        % sw_trial      = sw_info(irat);
        % om_flags      = find([om.(om_name{1}).nogo] == inogo);
        om_trial_ref  = 20;%sw_info.trial_num(sw_info.switch);

        try
            % reg_lp = [reg.trials([reg.trials.nogo] == inogo & [reg.trials.reward]).first_press_latency];
            reg_lp = [reg.trials([reg.trials.nogo] == inogo & [reg.trials.reward]).n_lever];
            % reg_lp = [reg.trials([reg.trials.nogo] == inogo).n_lever];
        catch
            reg_lp = [reg.trials([reg.trials.nogo] == inogo & [reg.trials.reward]).n_lvr];
            % reg_lp = [reg.trials([reg.trials.nogo] == inogo).n_lvr];
        end
       
        % om_pre_lp   = [om.(om_name{1})(sw_info.trial_num(sw_info.trial_num <= om_trial_ref)).first_press_latency];
        % om_post_lp  = [om.(om_name{1})(sw_info.trial_num(sw_info.trial_num > om_trial_ref)).first_press_latency];

        om_pre_lp   = [om.(om_name{1})(sw_info.trial_num(sw_info.trial_num <= om_trial_ref)).n_lvr];
        om_post_lp  = [om.(om_name{1})(sw_info.trial_num(sw_info.trial_num > om_trial_ref)).n_lvr];

        % mean_reg  = mean(reg_lp);
        % err_reg   = std(reg_lp)./sqrt(length(reg_lp));
        % mean_pre  = mean(om_pre_lp);
        % err_pre   = std(om_pre_lp)./sqrt(length(om_pre_lp));
        % mean_post = mean(om_post_lp);
        % err_post  = std(om_post_lp)./sqrt(length(om_post_lp));

        gr_reg  = ones(1,length(reg_lp));
        gr_pre  = 2 * ones(1,length(om_pre_lp));
        gr_post = 3 * ones(1,length(om_post_lp));

        subplot(2,5,irat)
        % bar([mean_reg mean_pre mean_post],'FaceColor',0.9 * ones(1,3))
        % hold on
        % errorbar([mean_reg mean_pre mean_post],[err_reg err_pre err_post],'.k')
        % hold off
        boxplot([reg_lp om_pre_lp om_post_lp],[gr_reg gr_pre gr_post],'Colors','k')
        % set(findobj(gca,'Type','Line'),'LineStyle','-')
        set(findobj(gca,'Tag','Median'),'linewidth',2)

        % ylabel 'first lever press latency (s)'; xticklabels ''
        ylabel '# lever presses/trial'; xticklabels ''
        set(gca,'xtick',1:3,'xticklabels',{'Regular','Pre-sw','Post-sw'})
        title(sprintf('%s (%s), sw:%i',om_file.rat_label,om_file.area_label,sw_info.switch));
        box off
    end
end
%% was the nose-poke exit latency during Nogo omission 1 trials similar to the one observed during the regular trials?
isession  = 1;
inogo     = 1;

wfig(7); clf
for irat = 1:10
    om_file = pick_files(omission_trials,'session_id',isession,'rat_label',regular_trials(irat).rat_label);
    if ~isempty(om_file)

        reg = load(fullfile(regular_trials(irat).folder,regular_trials(irat).name));
        om  = load(fullfile(om_file.folder,om_file.name));
        om_name = fieldnames(om);

        np_hold = pick_files(gng.med.np_hold,'rat_label',regular_trials(irat).rat_label);

        sw_info       = pick_files(sw,'rat_label',om_file.rat_label,'trial_id',1);
        om_trial_ref  = sw_info.trial_num(sw_info.switch);
        corr_flags    = find([om.(om_name{1}).reward] & [om.(om_name{1}).nogo] == inogo);
           
        reg_npex = [reg.trials([reg.trials.nogo] == inogo & [reg.trials.reward]).nosepokeexitframe];
        om_pre_npex   = [om.(om_name{1})(corr_flags(corr_flags <= om_trial_ref)).nosepokeexitframe];
        om_post_npex  = [om.(om_name{1})(corr_flags(corr_flags > om_trial_ref)).nosepokeexitframe];

        reg_npen = [reg.trials([reg.trials.nogo] == inogo & [reg.trials.reward]).nosepokeentryframe];
        om_pre_npen   = [om.(om_name{1})(corr_flags(corr_flags <= om_trial_ref)).nosepokeentryframe];
        om_post_npen  = [om.(om_name{1})(corr_flags(corr_flags > om_trial_ref)).nosepokeentryframe];

        % reg_npex = [reg.trials([reg.trials.nogo] == inogo & [reg.trials.reward]).nosepokeexitframe];
        % om_pre_npex   = [om.(om_name{1})(sw_info.trial_num(sw_info.trial_num <= om_trial_ref)).nosepokeexitframe];
        % om_post_npex  = [om.(om_name{1})(sw_info.trial_num(sw_info.trial_num <= om_trial_ref)).nosepokeexitframe];
        % 
        % reg_npen = [reg.trials([reg.trials.nogo] == inogo & [reg.trials.reward]).nosepokeentryframe];
        % om_pre_npen   = [om.(om_name{1})(sw_info.trial_num(sw_info.trial_num <= om_trial_ref)).nosepokeentryframe];
        % om_post_npen  = [om.(om_name{1})(sw_info.trial_num(sw_info.trial_num <= om_trial_ref)).nosepokeentryframe];

        reg_hold  = ((reg_npex - reg_npen) / gng.analysis.fr_rate) - np_hold.o1;
        pre_hold  = ((om_pre_npex - om_pre_npen) / gng.analysis.fr_rate) - np_hold.o1;
        post_hold = ((om_post_npex - om_post_npen) / gng.analysis.fr_rate) - np_hold.o1;

        gr_reg  = ones(1,length(reg_hold));
        gr_pre  = 2 * ones(1,length(pre_hold));
        gr_post = 3 * ones(1,length(post_hold));

        % mean_reg  = mean(reg_hold);
        % err_reg   = std(reg_hold)./sqrt(length(reg_npex));
        % mean_pre  = mean(pre_hold);
        % err_pre   = std(pre_hold)./sqrt(length(om_pre_npex));
        % mean_post = mean(post_hold);
        % err_post  = std(post_hold)./sqrt(length(om_post_npex));

        subplot(2,5,irat)
        % bar([mean_reg mean_pre mean_post],'FaceColor',0.9 * ones(1,3))
        % hold on
        % errorbar([mean_reg mean_pre mean_post],[err_reg err_pre err_post],'.k')
        % hold off

        boxplot([reg_hold pre_hold post_hold],[gr_reg gr_pre gr_post],'Colors','k')
        % set(findobj(gca,'Type','Line'),'LineStyle','-')
        set(findobj(gca,'Tag','Median'),'linewidth',2)

        ylabel 'mean nose-poke exit latency [s]'; xticklabels ''
        set(gca,'xtick',1:3,'xticklabels',{'Regular','Pre-sw','Post-sw'})
        title(sprintf('%s (%s), sw:%i',om_file.rat_label,om_file.area_label,sw_info.switch));
        box off
        % if irat ~=5
        %     rat_lim = ylim;
        %     ylim([0 rat_lim(2)])
        % end
    end
end

%%
% how fast do they respond to the nose-poke cue?
% ONGOING
% all_data = cell(2);
% for ifile = 1:length(sess_trials)
%     load(fullfile(sess_trials(ifile).folder,sess_trials(ifile).name));
%     not_init          = cellfun(@isempty,{trials.nosepokeentryframe});
%     trials(not_init)  = [];
%     var_data          = [trials.nosepokeentryframe] - [trials.nosepokecueonframe];
%     for inogo = 0:1
%         for irew = 0:1
%             sel_trials = [trials.nogo] == inogo & [trials.reward] == irew;
%             all_data{inogo + 1,irew + 1} = cat(1,all_data{inogo + 1,irew + 1},median(var_data(sel_trials)));
%         end
%     end
% end
%% 

