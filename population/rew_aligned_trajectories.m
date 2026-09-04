clear; clc
gng           = gonogo_mainconfig;
trial_labels  = {'nogo','go'};
session_type  = {'regular','omission','err'};

% select between regular, omission (or error)
itype = 2; isession = 2;

% load the file list
trial_name = sprintf('%s_trials.mat',session_type{itype}); 
trial_list = importdata(fullfile(gng.file.support,trial_name));

% remove selected animals (low performance)
if itype == 1 
    var_data = importdata(fullfile(gng.file.support,'expl_var_regular.mat'));
    expl_var = var_data.expl_var;
    sh_list = importdata(fullfile(gng.file.support,'shuf_regular.mat'));
elseif itype == 2
    exp_var_file = sprintf('expl_var_omission%i.mat',isession);
    var_data = importdata(fullfile(gng.file.support,exp_var_file));
    expl_var = pick_files(var_data.expl_var,'session_id',isession);
    sh_list = importdata(fullfile(gng.file.support,'shuf_omission.mat'));
    sh_list = pick_files(sh_list,'session_id',isession);
    if isession == 1
        trial_list([7:10 17 18]) = [];
        sh_list([4 5 9]) = [];
        expl_var([4 8]) = [];
    else
        trial_list(9:10) = [];
        sh_list(5) = [];
    end
end

% read features from the selected session
feats_name = sprintf('traj_%s_feats.mat',session_type{itype});
load(fullfile(gng.file.support,feats_name))

% select features files from the selected session
feats.task  = pick_files(feats.task,'session_id',isession);
feats.time  = pick_files(feats.time,'session_id',isession);
trial_list  = pick_files(trial_list,'session_id',isession);

nframes   = size(feats.task(1).nogo_traj,2);
time_axis = ((1:nframes)/gng.analysis.fr_rate) - 2;

%%

% this section must be configured to chose between first/second half of the
% omission 1 trials; or the whole regular / omission 2 trials

o1_half = 1; sw_trial = 17;

n_np_ref  = 60; % 30 frames before up to np entry to 30 frames after
n_rew_ref = 22; % 15 frames pre and up tp reward and 7 frames after

np_all.nogo   = nan(length(trial_list),n_np_ref);
rew_all.nogo  = nan(length(trial_list),n_rew_ref - 1);
np_all.go     = nan(length(trial_list),n_np_ref);
rew_all.go    = nan(length(trial_list),n_rew_ref - 1);
len_gng       = nan(length(trial_list),2);

task_val    = [1 0]; % 1- nogo; 0 - go

for irat = 1:length(trial_list)

    rat_name  = trial_list(irat).rat_label;
    if itype == 1
        file_name = sprintf('traj_regular_%s.mat',rat_name);
    else
        file_name = sprintf('traj_omission_%i_%s.mat',isession,rat_name);
    end

    load(fullfile(trial_list(irat).folder,file_name),'trialNum')
    trials = importdata(fullfile(trial_list(irat).folder,trial_list(irat).name));

    rat_cfg = []; 
    rat_cfg.rat_label = rat_name;
    rat_sh = get_entry(sh_list,rat_cfg);
    [~, var_idx] = get_entry(expl_var,rat_cfg);

    sh_var = load(fullfile(rat_sh.folder,rat_sh.name),'task_var','time_var','tot_var');

    expl_var(var_idx).task_sh = mean(sh_var.task_var);
    expl_var(var_idx).time_sh = mean(sh_var.time_var);
    expl_var(var_idx).total_sh = mean(sh_var.tot_var);

    % get only correct trials
    entry         = [];
    entry.reward  = 1;
    trials        = get_entry(trials,entry);

    if sum(trialNum(1,:)) == length(trials)

        np_gng  = [];
        rew_gng = [];
        
        for itask = 1:2
            % select the features from the current task and rat
            rat_feats   = pick_files(feats.task,'rat_label',rat_name);
            feat_trajs  = rat_feats.([lower(gng.analysis.trial_label{itask}) '_trials']);
            task_trajs  = cat(3,feat_trajs.traj);
            if itype == 2 & isession == 1
                if size(task_trajs,3) > sw_trial
                    sw_ref = sw_trial;
                else
                    sw_ref = size(task_trajs,3);
                end

                if o1_half == 1
                    tr1 = 1; tr2 = sw_ref;
                else
                    tr1 = sw_ref + 1; tr2 = size(task_trajs,3);
                end
            else
                tr1 = 1; tr2 = size(task_trajs,3);
            end
            task_mean = mean(task_trajs(:,:,tr1:tr2),3,"omitmissing");
            task_dist = diag(dist(task_mean),1);
            np_all.(lower(gng.analysis.trial_label{itask}))(irat,:) = task_dist(2:61);

            rew_trajs   = nan(3,n_rew_ref,trialNum(1,itask));
            task_trials = trials([trials.nogo] == task_val(itask));
            rew_frame   = [task_trials.rewardframe] - [task_trials.nosepokeentryframe] + 2 * gng.analysis.fr_rate;
            np_rew_traj = nan(3,max(rew_frame),trialNum(1,itask));

            for itrial = tr1:tr2
                if rew_frame(itrial) + 6 <= size(task_trajs,2)
                    rew_trajs(:,:,itrial) = task_trajs(:,rew_frame(itrial) - 15:rew_frame(itrial) + 6,itrial);

                    np_rew_points = 30:rew_frame(itrial);
                    np_rew_traj(:,1:length(np_rew_points),itrial) = task_trajs(:,np_rew_points,itrial);
                    
                end
            end
            rew_mean = mean(rew_trajs,3,"omitmissing");
            rew_dist = diag(dist(rew_mean),1);
            rew_all.(lower(gng.analysis.trial_label{itask}))(irat,:) = rew_dist;

            np_gng  = cat(2,np_gng,task_mean(:,2:61));
            rew_gng = cat(2,rew_gng,rew_mean);

            np_rew_mean = mean(np_rew_traj,3,"omitmissing");
            np_rew_dist = diag(dist(np_rew_mean),1);
            len_gng(irat,itask) = mean(np_rew_dist,"omitmissing");
        end

        np_all.gng(irat,:)  = diag(dist(np_gng),n_np_ref);
        rew_all.gng(irat,:) = diag(dist(rew_gng),n_rew_ref);
    else
        disp('check missmatch')
    end
end

fr_dist.np  = np_all;
fr_dist.rew = rew_all;
fr_dist.t_axis = time_axis;

%%
% save(fullfile(gng.file.publications,'/paper/figure_2/data/','fr_dist.mat'),'fr_dist') 
% save(fullfile(gng.file.publications,'/paper/figure_2/data/','len_gng.mat'),'len_gng') 
% save(fullfile(gng.file.publications,'/paper/figure_2/data/','file_list.mat'),'trial_list')

% save(fullfile(gng.file.publications,'/paper/figure_4/data/','fr_dist_o1h1.mat'),'fr_dist') 
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','file_list_o1h1.mat'),'trial_list')

% save(fullfile(gng.file.publications,'/paper/figure_4/data/','fr_dist_o1h2.mat'),'fr_dist') 
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','file_list_o1h2.mat'),'trial_list')

% save(fullfile(gng.file.publications,'/paper/figure_4/data/','fr_dist_o2.mat'),'fr_dist') 
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','file_list_o2.mat'),'trial_list')

%% explained variance

gray_level = 0.75;

ref_labels = {'task','time','total'};
ref_titles = {'task-related','task-unrelated','total'};
wfig(111); clf
set(gcf,'Color','w','Renderer','painters')


for iref = 1:3
    subplot(1,3,iref)
    for iarea = 2:-1:1
        area_flg  = [expl_var(:).area_id] == iarea;

        mean_var  = mean([expl_var(area_flg).(ref_labels{iref})]);
        err_var   = std([expl_var(area_flg).(ref_labels{iref})]) / sqrt(sum(area_flg));

        mean_sh  = mean([expl_var(area_flg).([ref_labels{iref} '_sh'])]);
        err_sh   = std([expl_var(area_flg).([ref_labels{iref} '_sh'])]) / sqrt(sum(area_flg));

        bar(iarea,mean_var,'FaceColor',gng.graph.colors.area{iarea},'FaceAlpha',0.55);
        hold on
        plot(iarea * ones(sum(area_flg),1),[expl_var(area_flg).(ref_labels{iref})],'o',...
            'color',gng.graph.colors.area{iarea},...
            'MarkerFaceColor',gng.graph.colors.area{iarea},...
            'MarkerSize',4)
        errorbar(iarea,mean_var,err_var,'.k')
        bar(iarea + 2,mean_sh,'FaceColor',gray_level * ones(1,3),'FaceAlpha',0.55);
        plot(iarea + 2 * ones(sum(area_flg),1),[expl_var(area_flg).([ref_labels{iref} '_sh'])],'o',...
            'color',gray_level * ones(1,3),...
            'MarkerFaceColor',gray_level * ones(1,3),...
            'MarkerSize',4)
        errorbar(iarea + 2,mean_sh,err_sh,'.k')
        ylim([0 100])
    end
    ylabel 'Explained variance'
    set(gca,'xtick',1:4,...
        'XTickLabel',[gng.analysis.area_label,'IL_{shuf}','PL_{shuf}'])
    box off;
    if iref == 1
        ylim([0 70])
    end
    title(ref_titles{iref})
end
% save(fullfile(gng.file.publications,'/paper/figure_2/data/','expl_var_regular.mat'),'expl_var')
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','expl_var_o1.mat'),'expl_var')
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','expl_var_o2.mat'),'expl_var')

%%
var_table = struct2table(expl_var);
reg_var = var_table(:,{'area_label', 'area_id', 'task', 'time', 'total'});
sh_var = var_table(:,{'area_label', 'area_id',...
    'task_sh', 'time_sh', 'total_sh'});
sh_var{:,1} = cellfun(@(x) strcat(x,'_sh'), sh_var{:,1},...
    'UniformOutput', false);

sh_var(:,2) = sh_var(:,2) + 2;
sh_var.Properties.VariableNames{3} = 'task';
sh_var.Properties.VariableNames{4} = 'time';
sh_var.Properties.VariableNames{5} = 'total';

exp_var_table = cat(1,reg_var,sh_var);
% writetable(exp_var_table,fullfile(gng.file.publications,'/paper/figure_2/data/exp_var_table.csv'))
% writetable(exp_var_table,fullfile(gng.file.publications,'/paper/figure_4/data/exp_var_table_o1.csv'))
% writetable(exp_var_table,fullfile(gng.file.publications,'/paper/figure_4/data/exp_var_table_o2.csv'))

%% Frame-by-frame distance with the gap to aloow the alignment of reward frames from animals with different time requirements

max_y = 0.35;
wfig(104); clf
set(gcf,'Color','w','Renderer','painters')

start_t = 2.5;
rew_time_ax = linspace(start_t,start_t + 1.4,21);
rew_time = rew_time_ax(15);
isp = 1;
for iarea = 2:-1:1
    area_flags = [trial_list.area_id] == iarea;

    sh_cfg = [];
    sh_cfg.xdata = time_axis(1:60);
    subplot(2,1,isp); isp = isp + 1;
    sh_cfg.ydata = np_all.nogo(area_flags,:);
    sh_cfg.color_val = gng.graph.colors.task{1};
    avg_err_shade(sh_cfg);   
    % shadow_plot(time_axis(1:60),np_all.nogo(area_flags,:),true,gng.graph.colors.task{1},0.4);
    hold on
    sh_cfg.ydata = np_all.go(area_flags,:);
    sh_cfg.color_val = gng.graph.colors.task{2};
    avg_err_shade(sh_cfg);
    % shadow_plot(time_axis(1:60),np_all.go(area_flags,:),true,gng.graph.colors.task{2},0.4);

    sh_cfg = [];
    sh_cfg.xdata = rew_time_ax;
    sh_cfg.ydata = rew_all.nogo(area_flags,:);
    sh_cfg.color_val = gng.graph.colors.task{1};
    avg_err_shade(sh_cfg);

    sh_cfg.ydata = rew_all.go(area_flags,:);
    sh_cfg.color_val = gng.graph.colors.task{2};  
    avg_err_shade(sh_cfg);

    % shadow_plot(rew_time_ax,rew_all.nogo(area_flags,:),true,gng.graph.colors.task{1},0.4);
    % shadow_plot(rew_time_ax,rew_all.go(area_flags,:),true,gng.graph.colors.task{2},0.4);
    plot([0 0],[-0.05 max_y],'--','color',0.65*ones(1,3))
    plot([0.5 0.5],[-0.05 max_y],'--','color',0.65*ones(1,3))
    plot([rew_time rew_time],[-0.05 max_y],'--','color',0.65*ones(1,3))
    hold off;  ylim([0 max_y]); 
   
    box off; xlabel 'Time [s]'; ylabel 'Frame-by-frame norm. distance [a.u.]'
    legend({'','NoGo','','Go'},'Location','northwest','Box','off')
    title(gng.analysis.area_label{iarea})
end

%% Go - Nogo distance
max_y = 6;
wfig(101); clf
set(gcf,'Color','w','Renderer','painters')

start_t = 2.5;
rew_time_ax = linspace(start_t,start_t + 1.5,22);
rew_time = rew_time_ax(15);
for iarea = 1:2
    area_flags = [trial_list.area_id] == iarea;

    sh_cfg = [];
    sh_cfg.xdata = time_axis(1:60);
    sh_cfg.ydata = np_all.gng(area_flags,:);
    sh_cfg.color_val = gng.graph.colors.area{iarea};
    avg_err_shade(sh_cfg);

    hold on
    sh_cfg = [];
    sh_cfg.xdata = rew_time_ax;
    sh_cfg.ydata = rew_all.gng(area_flags,:);
    sh_cfg.color_val = gng.graph.colors.area{iarea};
    avg_err_shade(sh_cfg);

    ylim([0 max_y]);
    box off; xlabel 'Time [s]'; ylabel 'Go - Nogo distance [a.u.]'
    legend({'','IL','','','','PL'},'Location','northwest','Box','off')
    % title(gng.analysis.area_label{iarea})
end
legend AutoUpdate off
plot([0 0],[-0.05 max_y],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[-0.05 max_y],'--','color',0.65*ones(1,3))
plot([rew_time rew_time],[-0.05 max_y],'--','color',0.65*ones(1,3))

hold off

% %%
% task_mean = mean(task_trajs(:,:,1:size(task_trajs,3)), 3, "omitmissing");
% max_tr = size(task_trajs, 3);
np_time_ax = time_axis(1:60);

% save(fullfile(gng.file.publications,'/paper/figure_2/data/','go_nogo_dist.mat'),'np_all','rew_all','np_time_ax','rew_time_ax')
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','go_nogo_dist_o2.mat'),'np_all','rew_all','np_time_ax','rew_time_ax')

%% Plotting the mean lenght

t_data{1} = len_gng(:,1);
t_data{2} = len_gng(:,2);

figure(33); clf                                                              % Initialize figure
set(gcf,'Color','w','Renderer','painters')
isp = 1;
for iarea = 2:-1:1
    subplot (2,1,isp)
    isp = isp + 1;
    area_flags2 = [trial_list.area_id] == iarea;
    
    for itask = 1:2
        
        task_data = t_data{itask}(area_flags2);                       % Pick variance values from dimension idim, area iarea
        bar(itask,mean(task_data),...                                       % plot bar with colorcoded by area
            'FaceColor',gng.graph.colors.task{itask},...
            'EdgeColor','w',...
            'FaceAlpha',0.5)
        hold on
        npoints = length(task_data);
        plot(itask * ones(npoints,1),task_data,...                          % plot inidividual data points
            'o',...
            'Color',gng.graph.colors.task{itask},...
            'MarkerFaceColor',gng.graph.colors.task{itask},...
            'MarkerSize',5)
        errorbar(itask,mean(task_data),std(task_data)./sqrt(npoints),'.k')  % plot errorbars
    end

    data_nogo = t_data{1}(area_flags2);
    data_go = t_data{2}(area_flags2);
    for iline = 1:length(data_go)
        plot([1 2],[data_nogo(iline) data_go(iline)],'Color',0.65 * ones(1,3))
    end

    set(gca,'xtick',[1 2],'xticklabels',{'Nogo','Go'});                % axis properties 
    ylabel 'Length [a.u. per frame]'; 
    box off; set(gca,'TickDir','out')
    title(gng.analysis.area_label{iarea})
    % ylim([0 14])
    ylim([0 0.3])
end
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','len_gng_o1_h1.mat'),'len_gng')
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','len_gng_o1_h2.mat'),'len_gng')
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','len_gng_o2.mat'),'len_gng')


%% Long data arragement to perform mixed anova

len_stats = trial_list;
nogo_len  = num2cell(len_gng(:,1));
go_len    = num2cell(len_gng(:,2));

[len_stats.nogo_len] = nogo_len{:};
[len_stats.go_len] = go_len{:};
len_stats = struct2table(len_stats);

% writetable(len_stats,fullfile(gng.file.publications,'/paper/figure_4/data/length_o1.csv'))

%% plot the length up to reward frame


figure(333); clf                                                              % Initialize figure
set(gcf,'Color','w','Renderer','painters')
isp = 1;
for iarea = 2:-1:1
    subplot (2,1,isp)
    isp = isp + 1;
    area_flags2 = [trial_list.area_id] == iarea;
    
    for itask = 1:2
        task_label = lower(gng.analysis.trial_label{itask});
        t_data = fr_dist.np.(task_label)(area_flags2,:);
        
        task_data = mean(t_data,2);                       % Pick variance values from dimension idim, area iarea
        bar(itask,mean(task_data),...                                       % plot bar with colorcoded by area
            'FaceColor',gng.graph.colors.task{itask},...
            'EdgeColor','w',...
            'FaceAlpha',0.5)
        hold on
        npoints = length(task_data);
        plot(itask * ones(npoints,1),task_data,...                          % plot inidividual data points
            'o',...
            'Color',gng.graph.colors.task{itask},...
            'MarkerFaceColor',gng.graph.colors.task{itask},...
            'MarkerSize',5)
        errorbar(itask,mean(task_data),std(task_data)./sqrt(npoints),'.k')  % plot errorbars
    end
    % 
    data_nogo = mean(fr_dist.np.nogo(area_flags2,:),2);
    data_go = mean(fr_dist.np.go(area_flags2,:),2);
    for iline = 1:length(data_go)
        plot([1 2],[data_nogo(iline) data_go(iline)],'Color',0.65 * ones(1,3))
    end

    set(gca,'xtick',[1 2],'xticklabels',{'Nogo','Go'});                % axis properties 
    ylabel 'Length [a.u. per frame]'; 
    box off; set(gca,'TickDir','out')
    title(gng.analysis.area_label{iarea})
    % ylim([0 14])
    ylim([0 0.16])
end
