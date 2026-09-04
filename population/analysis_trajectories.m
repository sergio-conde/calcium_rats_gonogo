clear; clc
gng = gonogo_mainconfig;
comp = 'task';

% load(fullfile(gng.file.support,'traj_regular.mat'));
% load(fullfile(gng.file.support,'traj_regular_feats.mat'));
% traj_files = traj_regular;
% feats      = feats.(comp);
% load(fullfile(gng.file.support,"regular_perf.mat"))
% perf = regular_perf;
% nframes = 90;

load(fullfile(gng.file.support,'traj_omission.mat'));
load(fullfile(gng.file.support,'traj_omission_feats.mat'));
load(fullfile(gng.file.support,"omission_perf.mat"))
perf    = omission_perf;
nframes = 93;

isession      = 1;
traj_omission = pick_files(traj_omission,'session_id',isession);
feats         = pick_files(feats.(comp),'session_id',isession);
perf          = pick_files(perf,'session_id',isession);
perf(5) = []; % removing September due to very low nogo performande (5%)

traj_files    = traj_omission;

% load(fullfile(gng.file.support,'traj_err.mat'));
% load(fullfile(gng.file.support,'traj_err_feats.mat'));
% load(fullfile(gng.file.support,"omission_perf.mat"))
% perf    = omission_perf;
% % perf(5) = []; % removing September due to very low nogo performande (5%)
% nframes = 93;
% 
% isession      = 1;
% traj_err      = pick_files(traj_err,'session_id',isession);
% feats         = pick_files(feats.(comp),'session_id',isession);
% perf          = pick_files(perf,'session_id',isession);
% traj_files    = traj_err;

% traj_files(4) = [];
% feats(4)      = [];
% 
% %

task_cmap{1} = [linspace(231,208,90)' linspace(235,2,90)' linspace(113,2,90)']/255;
task_cmap{2} = [linspace(231,42,90)' linspace(235,179,90)' linspace(113,75,90)']/255;

%%
nrats = length(traj_files);
traj_var = strcat('Trajs_',comp,'only');

wfig(1); clf  
set(gcf,"Renderer","painters",'Position',[ -1607 442 1444 529]) % Initialize figure

mean_dist     = zeros(nrats,nframes);
norm_maxdist  = zeros(nrats,nframes);
norm_basedist = zeros(nrats,nframes);
firstd_go     = zeros(nrats,nframes - 1);
firstd_nogo   = zeros(nrats,nframes - 1);
expl_var      = traj_files;
dist_auc      = zeros(nrats,1);

nsp = 1;
all_trajs.IL.nogo = [];
all_trajs.IL.go = [];
all_trajs.PL.nogo = [];
all_trajs.PL.go = [];

for irat = 1:nrats
    
    subplot (2,5,nsp)
    nsp = nsp + 1;

    % if itraj == 4; nsp = nsp + 1; end  % omission plots

    traj_data = load(fullfile(traj_files(irat).folder,traj_files(irat).name),traj_var,'explVar','whichMarg','trialNum');
    % expl_var(itraj).rat_label = traj_files(itra)
    % expl_var(irat).total = traj_data.explVar.cumulativeDPCA(3);
    
    task_components      = find(traj_data.whichMarg == 1);
    time_components      = find(traj_data.whichMarg == 2);
    expl_var(irat).task  = sum(traj_data.explVar.componentVar(task_components(1:3)));
    expl_var(irat).time  = sum(traj_data.explVar.componentVar(time_components(1:3)));
    % expl_var(irat).total = traj_data.explVar.cumulativeDPCA(3);
    expl_var(irat).total = expl_var(irat).task + expl_var(irat).time;
    
    expl_var(irat).task_cum  = cumsum(traj_data.explVar.componentVar(task_components));
    expl_var(irat).time_cum  = cumsum(traj_data.explVar.componentVar(time_components));
    expl_var(irat).total_cum  = traj_data.explVar.cumulativeDPCA;


    % mean_traj = mean(traj_data.(traj_var),4); % trials is the 4th dimension
    traj_dims = size(traj_data.(traj_var));
    mean_traj = nan(traj_dims(1),traj_dims(2),traj_dims(3));

    area_label = traj_files(irat).area_label;
    for itask = 1:2   

        z_traj  = squeeze(mean(traj_data.(traj_var)(:,:,itask,1:traj_data.trialNum(1,itask)),4));
        mean_traj(:,:,itask) = z_traj;
        z_traj = squeeze(mean_traj(:,:,itask));

        % task_type = lower(gng.analysis.trial_label{itask});
        % all_trajs.(area_label).(task_type) = cat(3,all_trajs.(area_label).(task_type),z_traj(1:3,:));
        % 
        % X = z_traj(1,:).';
        % Y = z_traj(2,:).';
        % Z = z_traj(3,:).';
        % cd = permute(cat(3,task_cmap{itask},task_cmap{itask}),[1 3 2]);
        % surf([X X], [Y Y], [Z Z], cd, ...
        %     'EdgeColor','interp', 'FaceColor','none', 'LineWidth',2);
        % hold on

        plot3(z_traj(1,:),z_traj(2,:),z_traj(3,:),...
            'color',gng.graph.colors.task{itask},'LineWidth',1);
        hold on
        plot3(z_traj(1,30),z_traj(2,30),z_traj(3,30),...
            'marker','v','markersize',7,...
            'MarkerFaceColor',gng.graph.colors.task{itask},...
            'color',gng.graph.colors.task{itask});
        plot3(z_traj(1,37),z_traj(2,37),z_traj(3,37),...
            'marker','square','markersize',7,...
            'MarkerFaceColor',gng.graph.colors.task{itask},...
            'color',gng.graph.colors.task{itask});
        plot3(z_traj(1,83),z_traj(2,83),z_traj(3,83),...
            'marker','o','markersize',7,...
            'MarkerFaceColor',gng.graph.colors.task{itask},...
            'color',gng.graph.colors.task{itask});
    end
    box off; xlabel 'PC1'; ylabel 'PC2'; zlabel 'PC3'; grid on
    % title(sprintf('area; %s, rat: %s',...
    %     traj_files(itraj).area_label,traj_files(itraj).rat_label))
    % xlim([0 3]); ylim([0 3]); zlim([0 3]);

    nogo_traj             = squeeze(mean_traj(1:3,:,1));
    go_traj               = squeeze(mean_traj(1:3,:,2));
    gonogo_dist           = dist([nogo_traj go_traj]);
    mean_dist(irat,:)    = diag(gonogo_dist,nframes);
    dist_auc(irat)       = sum(mean_dist(irat,30:end));
    norm_maxdist(irat,:) = mean_dist(irat,:)./max(mean_dist(irat,:));
    firstd_go(irat,:)    = diag(dist(go_traj),1);
    % firstd_go(itraj,:)    = firstd_go(itraj,:) - median(firstd_go(itraj,3:30));

    firstd_nogo(irat,:)  = diag(dist(nogo_traj),1);
    % firstd_nogo(itraj,:)  = firstd_nogo(itraj,:) - median(firstd_nogo(itraj,3:30));

end
time_axis = ((1:nframes)/gng.analysis.fr_rate) - 2;
dist_auc  = dist_auc/(nframes - 29);
%%
% save(fullfile(gng.file.publications,'/paper/figure_2/data/','all_trajs.mat'),'all_trajs') 

%% cumulative explained variance

var_fields = {'task_cum','time_cum','total_cum'};
field_color = [0 0 0; 0.65 * ones(1,3); 0.8 * ones(1,3)];
wfig(888); clf
for ifield = 1:2%length(var_fields)
    f_name = var_fields{ifield};
    exp_gain.(f_name) = nan(nrats,10);
    for irat = 1:nrats
        ncomp = length(expl_var(irat).(f_name));
        exp_gain.(f_name)(irat,1:ncomp) = diff([0 expl_var(irat).(f_name)] - expl_var(irat).(f_name)(1));
        % exp_gain(irat,1:ncomp) = expl_var(irat).(f_name);
    end

    avg_err_shade(exp_gain.(f_name)(:,1:4));
    hold on
end
hold off; box off; axis tight
ylabel 'Explained variance gain'
xlabel 'dPCA components'
set(gca,'XTick',1:4)
xlim([0.5 4.5])
legend({'','task-related','','task-unrelated'},"Box","off")

% save(fullfile(gng.file.publications,'/paper/figure_2/data/','expl_var_regular.mat'),'expl_var','exp_gain') 
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','expl_var_omission1.mat'),'expl_var','exp_gain') 
% save(fullfile(gng.file.publications,'/paper/figure_4/data/','expl_var_omission2.mat'),'expl_var','exp_gain') 

%% explained variance

% bar_cfg             = [];
% bar_cfg.position    = [1 2];
% bar_cfg.max_jitter  = 0.1;
% bar_cfg.paired      = true;
% bar_cfg.transparency= 0.5;
% bar_cfg.error       = true;

% il_flags = [traj_files(:).area_id] == 1;
% pl_flags = ~il_flags;
% 
% var_data = [expl_var(il_flags) expl_var(pl_flags)];

ref_labels = {'task','time','total'};
ref_titles = {'task-related','task-unrelated','total'};

wfig(111); clf
set(gcf,'Color','w','Renderer','painters')

for iref = 1:3
    subplot(1,3,iref)
    for iarea = 1:2
        area_flg  = [traj_files(:).area_id] == iarea;
        mean_var  = mean([expl_var(area_flg).(ref_labels{iref})]);
        err_var   = std([expl_var(area_flg).(ref_labels{iref})]) / sqrt(sum(area_flg));

        bar(iarea,mean_var,'FaceColor',gng.graph.colors.area{iarea},'FaceAlpha',0.55);
        hold on
        plot(iarea * ones(sum(area_flg),1),[expl_var(area_flg).(ref_labels{iref})],'o',...
            'color',gng.graph.colors.area{iarea},...
            'MarkerFaceColor',gng.graph.colors.area{iarea},...
            'MarkerSize',4)
        errorbar(iarea,mean_var,err_var,'.k')
    end
    ylabel 'Explained variance'
    set(gca,'xtick',1:2,'XTickLabel',gng.analysis.area_label)
    box off; ylim([0 100])
    title(ref_titles{iref})
end
%% Are the task-related variance and performance related?
% here we have the correlations without separating areas

il_flags = [traj_files(:).area_id] == 1;
pl_flags = ~il_flags;

var_data = [expl_var(il_flags); expl_var(pl_flags)];

% gen_perf = nan(length(perf),1);
% for irat = 1:length(perf)
%     gen_perf(irat) = 100 * (perf(irat).corr_nogo + perf(irat).corr_go)/perf(irat).ntrials;
% end

% gen_perf = nan(length(perf),1);
% for irat = 1:length(perf)
%     gen_perf(irat) = 100 * perf(irat).corr_go /perf(irat).n_go;
% end

gen_perf = nan(length(perf),1);
for irat = 1:length(perf)
    gen_perf(irat) = 100 * perf(irat).corr_nogo /perf(irat).n_nogo;
end

wfig(3); clf
for iref = 1:3
    subplot(1,3,iref)

    var_data  = [ones(length(var_data),1) [expl_var(:).(ref_labels{iref})]']; 
    beta      = var_data\gen_perf;
    x_line    = min(var_data(:,2)):max(var_data(:,2)); 
    line_data = [ones(length(x_line),1) x_line']*beta;
    perf_fit  = var_data*beta;
    R2        = 1 - sum((gen_perf - perf_fit).^2)/sum((gen_perf - mean(gen_perf)).^2);

    [corr_r,corr_p] = corrcoef(gen_perf,var_data(:,2));

    plot([expl_var([traj_files(:).area_id] == 1).(ref_labels{iref})],gen_perf([traj_files(:).area_id] == 1),'o',...
        'color',gng.graph.colors.area{1},'MarkerFaceColor',gng.graph.colors.area{1})
    hold on
    plot([expl_var([traj_files(:).area_id] == 2).(ref_labels{iref})],gen_perf([traj_files(:).area_id] == 2),'o',...
        'color',gng.graph.colors.area{2},'MarkerFaceColor',gng.graph.colors.area{2})
    plot(x_line,line_data,'--','Color',0.65 * ones(1,3))
    hold off; box off; ylabel 'Performance [%]'; xlabel 'Explained variance'
    ylim([0 100]); 
    title(sprintf('%s: R^2:%1.3f, \nr-corr = %1.2f, p = %1.3f',...
        ref_labels{iref},R2,corr_r(1,2),corr_p(1,2)))
end
%% Are the task-related variance and performance related?
% here we have the correlations separating areas

% gen_perf = nan(length(perf),1);
% for irat = 1:length(perf)
%     gen_perf(irat) = 100 * (perf(irat).corr_nogo + perf(irat).corr_go)/perf(irat).ntrials;
% end

gen_perf = nan(length(perf),1);
for irat = 1:length(perf)
    gen_perf(irat) = 100 * perf(irat).corr_nogo /perf(irat).n_nogo;
end

% gen_perf = nan(length(perf),1);
% for irat = 1:length(perf)
%     gen_perf(irat) = 100 * perf(irat).corr_go /perf(irat).n_go;
% end

wfig(30); clf
R2 = nan(1,2); rs = nan(1,2); ps = nan(1,2);

for iref = 1:3
    subplot(1,3,iref)
    hold on
    for iarea = 1:2

        area_flags  = [traj_files(:).area_id] == iarea;
        area_perf   = gen_perf(area_flags);

        % regression %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        area_data = [ones(sum(area_flags),1) [expl_var(area_flags).(ref_labels{iref})]'];
        beta      = area_data\area_perf;
        x_line    = min(area_data(:,2)):max(area_data(:,2));
        line_data = [ones(length(x_line),1) x_line']*beta;
        perf_fit  = area_data*beta;
        R2(iref,iarea)  = 1 - sum((area_perf - perf_fit).^2)/sum((area_perf - mean(area_perf)).^2);
        [corr_r,corr_p] = corrcoef(area_perf,area_data(:,2));
        rs(iref,iarea)  = corr_r(1,2);
        ps(iref,iarea)  = corr_p(1,2);
        % regression %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        plot([expl_var(area_flags).(ref_labels{iref})],gen_perf(area_flags),'o',...
            'color',gng.graph.colors.area{iarea},'MarkerFaceColor',gng.graph.colors.area{iarea})
        plot(x_line,line_data,'--','Color',gng.graph.colors.area{iarea})
    end
    title_str = sprintf('R^2_{IL} = %1.3f; p_{IL} = %1.3f\nR^2_{PL} = %1.3f; p_{PL} = %1.3f',...
        R2(iref,1),ps(iref,1),R2(iref,2),ps(iref,2));
    title(title_str)
    hold off; box off; 
    % ylabel 'Performance [%]';
    % ylabel 'No-go Performance [%]';
    ylabel 'Go Performance [%]';
    xlabel 'Explained variance'
    ylim([0 100]); 
end

% title(sprintf('%s: R^2:%1.3f, \nr-corr = %1.2f, p = %1.3f',...
%         ref_labels{iref},R2,cprr_r(1,2),corr_p(1,2)))

%% The mean go-nogo distance along the trial

figure(2); clf                                                              % Initialize figure
set(gcf,'Color','w','Renderer','painters')
subplot 121; hold on
for iarea = 1:2
    plot(time_axis,mean_dist([traj_files(:).area_id] == iarea,:)','color',gng.graph.colors.area{iarea})
end
box off; xlabel 'Time [s]'; ylabel 'Go-Nogo Distance [a.u.]'
legend({'','IL','','','','','PL'},'Location','northwest','Box','off')

subplot 122; hold on
for iarea = 1:2
    shadow_plot(time_axis,norm_maxdist([traj_files(:).area_id] == iarea,:),true,gng.graph.colors.area{iarea},0.3);
end
plot([0 0],[0 1],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[0 1],'--','color',0.65*ones(1,3))
plot([3.5 3.5],[0 1],'--','color',0.65*ones(1,3))
box off; xlabel 'Time [s]'; ylabel 'Norm. Go - Nogo distance [a.u.]'
legend({'','IL','','PL'},'Location','northwest','Box','off')

%% The mean go-nogo distance along the trial

figure(22); clf                                                              % Initialize figure
set(gcf,'Color','w','Renderer','painters')
subplot 131
hold on
for iarea = 1:2
    plot(time_axis,mean_dist([traj_files(:).area_id] == iarea,:)','color',gng.graph.colors.area{iarea})
end
plot([0 0],[0 6],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[0 6],'--','color',0.65*ones(1,3))
plot([3.5 3.5],[0 6],'--','color',0.65*ones(1,3))

box off; xlabel 'Time [s]'; ylabel 'Go-Nogo Distance [a.u.]'
legend({'','IL','','','','','PL'},'Location','northwest','Box','off')

subplot 132
for iarea = 1:2
    shadow_plot(time_axis,mean_dist([traj_files(:).area_id] == iarea,:),true,gng.graph.colors.area{iarea},0.3);
end
plot([0 0],[0 6],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[0 6],'--','color',0.65*ones(1,3))
plot([3.5 3.5],[0 6],'--','color',0.65*ones(1,3))
box off; xlabel 'Time [s]'; ylabel 'Go - Nogo distance [a.u.]'
legend({'','IL','','PL'},'Location','northwest','Box','off')
% ylim([0 6])

subplot 133
for iarea = 1:2
    area_flg  = [traj_files(:).area_id] == iarea;
    mean_var  = mean(dist_auc(area_flg));
    err_var   = std(dist_auc(area_flg)) / sqrt(sum(area_flg));

    bar(iarea,mean_var,'FaceColor',gng.graph.colors.area{iarea},'FaceAlpha',0.55);
    hold on
    plot(iarea * ones(sum(area_flg),1),dist_auc(area_flg),'o',...
        'color',gng.graph.colors.area{iarea},'MarkerFaceColor',gng.graph.colors.area{iarea})
    errorbar(iarea,mean_var,err_var,'.k')
end
ylabel 'Norm. area [a.u. per frame]'
set(gca,'xtick',1:2,'XTickLabel',gng.analysis.area_label)
box off
% ylim([0 5])


%% The greater the area under the curve is, the more different the go and no-go activities were. 

% Does this have any relation with the performance?
% gen_perf = nan(length(perf),1);
% for irat = 1:length(perf)
%     gen_perf(irat) = 100 * (perf(irat).corr_nogo + perf(irat).corr_go)/perf(irat).ntrials;
% end
gen_perf = nan(length(perf),1);
for irat = 1:length(perf)
    gen_perf(irat) = 100 * perf(irat).corr_go /perf(irat).n_go;
end
wfig(3); clf
area_und = sum(mean_dist,2);
hold on
for iarea = 1:2
    plot(area_und([traj_files(:).area_id] == iarea),gen_perf([traj_files(:).area_id] == iarea),'o',...
        'color',gng.graph.colors.area{iarea},'MarkerFaceColor',gng.graph.colors.area{iarea})
end

% plot(area_und(area_flags{2}),gen_perf(area_flags{2}),'o',...
%     'color',gng.graph.colors.area{2},'MarkerFaceColor',gng.graph.colors.area{2})
hold off; box off; ylabel 'Performance [%]'; xlabel 'A.U.C'
ylim([0 100])

%% Plotting the mean lenght

t_data{1} = [feats.nogo_mlen]'/(nframes - 29);
t_data{2} = [feats.go_mlen]'/(nframes - 29);

figure(33); clf                                                              % Initialize figure
set(gcf,'Color','w','Renderer','painters')
for iarea = 1:2
    subplot (1,2,iarea)% plot variance explained by each component individualy 
    area_flags2 = [feats.area_id] == iarea;
    
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
    % ylim([0 0.25])
end

%% Frame-by-frame distance

max_y = 0.35;
figure(4); clf                                                              % Initialize figure
set(gcf,'Color','w','Renderer','painters')
subplot 121
shadow_plot(time_axis(3:end),firstd_nogo(([traj_files(:).area_id] == 1),2:end),true,gng.graph.colors.task{1},0.3);
shadow_plot(time_axis(3:end),firstd_go(([traj_files(:).area_id] == 1),2:end),true,gng.graph.colors.task{2},0.3);
plot([0 0],[-0.05 max_y],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[-0.05 max_y],'--','color',0.65*ones(1,3))
plot([3.5 3.5],[-0.05 max_y],'--','color',0.65*ones(1,3))
box off; xlabel 'Time [s]'; ylabel 'Frame-by-frame norm. distance [a.u.]'
legend({'','NoGo','','Go'},'Location','northwest','Box','off')
% ylim([-0.07 max_y])
title('IL')

subplot 122
shadow_plot(time_axis(3:end),firstd_nogo(([traj_files(:).area_id] == 2),2:end),true,gng.graph.colors.task{1},0.3);
shadow_plot(time_axis(3:end),firstd_go(([traj_files(:).area_id] == 2),2:end),true,gng.graph.colors.task{2},0.3);
plot([0 0],[-0.05 max_y],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[-0.05 max_y],'--','color',0.65*ones(1,3))
plot([3.5 3.5],[-0.05 max_y],'--','color',0.65*ones(1,3))
box off; xlabel 'Time [s]'; ylabel 'Frame-by-frame norm. distance [a.u.]'
legend({'','NoGo','','Go'},'Location','northwest','Box','off')
% ylim([-0.07 max_y]); xlim([-2 4])
title('PL')

%%
time_axis = ((1:nframes)/gng.analysis.fr_rate) - 2;


[~, max_loc] = max(norm_maxdist,[],2);
max_time = time_axis(max_loc);
figure(311); clf                                                              % Initialize figure
set(gcf,'Color','w','Renderer','painters')

subplot 121
plot([0.5 2.5],[3.5 3.5],'--','color',0.65 * ones(1,3))                     % Plot line indicating reward delivery
hold on
boxplot(max_time,[1 1 1 1 1 2 2 2 2 2],...
    'colors',[gng.graph.colors.area{1};gng.graph.colors.area{2}])
box off; hold off
xticklabels(gng.analysis.areas)
ylabel 'Time @ max distance (s)'; ylim([0 4])
set(gca,'TickDir','out')

subplot 122
plot([0.5 2.5],[3.5 3.5],'--','color',0.65 * ones(1,3))                     % Plot line indicating reward delivery
hold on
for iarea = 1:2
    area_data = max_time(area_flags{iarea});                                % Compute cummulative variance
    bar(iarea,mean(area_data),...                                           % plot bar with colorcoded by area
        'FaceColor',gng.graph.colors.area{iarea},...
        'EdgeColor','w',...
        'FaceAlpha',0.5)
    npoints = length(area_data);
    plot(iarea * ones(npoints,1),area_data,...                              % plot inidividual data points
        'o',...
        'Color',gng.graph.colors.area{iarea},...
        'MarkerFaceColor',gng.graph.colors.area{iarea},...
        'MarkerSize',5)
    errorbar(iarea,mean(area_data),std(area_data)./sqrt(npoints),'.k')      % plot errorbars
end
set(gca,'xtick',[1 2],'xticklabels',gng.analysis.areas);                    % axis properties 
ylabel 'Time @ max distance (s)'; ylim([0 4])
box off; set(gca,'TickDir','out')



%%
% z_norm_dist = zscore(norm_dist,[],2);
% figure(5); clf                                                              % Initialize figure
% set(gcf,'Color','w','Renderer','painters')
% shadow_plot(time_axis,norm_maxdist(area_flags{1},:),true,gng.graph.colors.area{1},0.3);
% shadow_plot(time_axis,norm_maxdist(area_flags{2},:),true,gng.graph.colors.area{2},0.3);
% plot([0 0],[0 1],'--','color',0.65*ones(1,3))
% plot([0.5 0.5],[0 1],'--','color',0.65*ones(1,3))
% plot([3.5 3.5],[0 1],'--','color',0.65*ones(1,3))
% box off; xlabel 'Time [s]'; ylabel 'Go - Nogo distance [a.u.]'
% legend({'','IL','','PL'},'Location','northwest','Box','off')
%%
figure(6); clf 
% Initialize figure
set(gcf,'Color','w','Renderer','painters')

max_y = 5;
subplot 121
shadow_plot(time_axis,nogo_basedist(area_flags{1},:),true,gng.graph.colors.task{1},0.3);
shadow_plot(time_axis,go_basedist(area_flags{1},:),true,gng.graph.colors.task{2},0.3);
plot([0 0],[0 max_y],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[0 max_y],'--','color',0.65*ones(1,3))
plot([3.5 3.5],[0 max_y],'--','color',0.65*ones(1,3))
box off; xlabel 'Time [s]'; ylabel 'Norm. Distance [a.u.]'
legend({'','NoGo','','Go'},'Location','northwest','Box','off')
title('IL')
axis tight

subplot 122
shadow_plot(time_axis,nogo_basedist(area_flags{2},:),true,gng.graph.colors.task{1},0.3);
shadow_plot(time_axis,go_basedist(area_flags{2},:),true,gng.graph.colors.task{2},0.3);
plot([0 0],[0 max_y],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[0 max_y],'--','color',0.65*ones(1,3))
plot([3.5 3.5],[0 max_y],'--','color',0.65*ones(1,3))
box off; xlabel 'Time [s]'; ylabel 'Norm. Distance [a.u.]'
legend({'','NoGo','','Go'},'Location','northwest','Box','off')
title('PL')
axis tight

%%
figure(66); clf                                                              % Initialize figure
set(gcf,'Color','w','Renderer','painters')
max_y = 5;

subplot 121
shadow_plot(time_axis,nogo_basedist(area_flags{1},:),true,gng.graph.colors.area{1},0.3);
shadow_plot(time_axis,nogo_basedist(area_flags{2},:),true,gng.graph.colors.area{2},0.3);
plot([0 0],[0 max_y],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[0 max_y],'--','color',0.65*ones(1,3))
plot([3.5 3.5],[0 max_y],'--','color',0.65*ones(1,3))
box off; xlabel 'Time [s]'; ylabel 'Norm. Distance [a.u.]'
legend({'','IL','','PL'},'Location','northwest','Box','off')
title('NoGo')
axis tight

subplot 122
shadow_plot(time_axis,go_basedist(area_flags{1},:),true,gng.graph.colors.area{1},0.3);
shadow_plot(time_axis,go_basedist(area_flags{2},:),true,gng.graph.colors.area{2},0.3);
plot([0 0],[0 max_y],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[0 max_y],'--','color',0.65*ones(1,3))
plot([3.5 3.5],[0 max_y],'--','color',0.65*ones(1,3))
box off; xlabel 'Time [s]'; ylabel 'Norm. Distance [a.u.]'
legend({'','IL','','PL'},'Location','northwest','Box','off')
title('Go')
axis tight

%%
%%
% % z_norm_dist = zscore(norm_dist,[],2);
% max_y = 0.25;
% figure(7); clf                                                              % Initialize figure
% set(gcf,'Color','w','Renderer','painters')
% subplot 121
% shadow_plot(time_axis(3:end),firstd_nogo(area_flags{1},2:end),true,gng.graph.colors.task{1},0.3);
% shadow_plot(time_axis(3:end),firstd_go(area_flags{1},2:end),true,gng.graph.colors.task{2},0.3);
% plot([0 0],[0 max_y],'--','color',0.65*ones(1,3))
% plot([0.5 0.5],[0 max_y],'--','color',0.65*ones(1,3))
% plot([3.5 3.5],[0 max_y],'--','color',0.65*ones(1,3))
% box off; xlabel 'Time [s]'; ylabel 'Frame-by-frame distance [a.u.]'
% legend({'','NoGo','','Go'},'Location','northwest','Box','off')
% ylim([-0.05 max_y])
% title('IL')
% 
% subplot 122
% shadow_plot(time_axis(3:end),firstd_nogo(area_flags{2},2:end),true,gng.graph.colors.task{1},0.3);
% shadow_plot(time_axis(3:end),firstd_go(area_flags{2},2:end),true,gng.graph.colors.task{2},0.3);
% plot([0 0],[0 max_y],'--','color',0.65*ones(1,3))
% plot([0.5 0.5],[0 max_y],'--','color',0.65*ones(1,3))
% plot([3.5 3.5],[0 max_y],'--','color',0.65*ones(1,3))
% box off; xlabel 'Time [s]'; ylabel 'Frame-by-frame distance [a.u.]'
% legend({'','NoGo','','Go'},'Location','northwest','Box','off')
% ylim([-0.05 max_y])
% title('PL')
% %% Splitting by task (to compare brain regions)
% max_y = 0.25;
% 
% 
% figure(8); clf                                                              % Initialize figure
% set(gcf,'Color','w','Renderer','painters')
% subplot 121
% shadow_plot(time_axis(3:end),firstd_nogo(area_flags{1},2:end),true,gng.graph.colors.area{1},0.3);
% shadow_plot(time_axis(3:end),firstd_nogo(area_flags{2},2:end),true,gng.graph.colors.area{2},0.3);
% plot([0 0],[0 max_y],'--','color',0.65*ones(1,3))
% plot([0.5 0.5],[0 max_y],'--','color',0.65*ones(1,3))
% plot([3.5 3.5],[0 max_y],'--','color',0.65*ones(1,3))
% box off; xlabel 'Time [s]'; ylabel 'Frame - Frame length, [a.u.]'
% legend({'','IL','','PL'},'Location','northwest','Box','off')
% % ylim([0 max_y])
% title('NoGo')
% 
% subplot 122
% shadow_plot(time_axis(3:end),firstd_go(area_flags{1},2:end),true,gng.graph.colors.area{1},0.3);
% shadow_plot(time_axis(3:end),firstd_go(area_flags{2},2:end),true,gng.graph.colors.area{2},0.3);
% plot([0 0],[0 max_y],'--','color',0.65*ones(1,3))
% plot([0.5 0.5],[0 max_y],'--','color',0.65*ones(1,3))
% plot([3.5 3.5],[0 max_y],'--','color',0.65*ones(1,3))
% box off; xlabel 'Time [s]'; ylabel 'Frame - Frame length, [a.u.]'
% legend({'','IL','','PL'},'Location','northwest','Box','off')
% % ylim([-0.05 max_y])
% title('Go')

%% Checking consistency of the brain regions comparison across animals 

il_rats = [1 2 3 4 5];
pl_rats = [6 7 8 9 10];

max_y = 0.5;
figure(88); clf                                                              % Initialize figure
set(gcf,'Color','w','Renderer','painters')
subplot 121
plot(time_axis(2:end),firstd_nogo(il_rats,:)','color',gng.graph.colors.area{1});
hold on
plot(time_axis(2:end),firstd_nogo(pl_rats,:)','color',gng.graph.colors.area{2});
plot([0 0],[0 max_y],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[0 max_y],'--','color',0.65*ones(1,3))
plot([3.5 3.5],[0 max_y],'--','color',0.65*ones(1,3))
box off; xlabel 'Time [s]'; ylabel 'Frame - Frame length, [a.u.]'
legend({gng.analysis.areas{1},...
    '','','','','',gng.analysis.areas{2}},'Location','northwest','Box','off')
hold off
% ylim([0 max_y])
title('NoGo')

subplot 122
plot(time_axis(2:end),firstd_go(il_rats,:)','color',gng.graph.colors.area{1});
hold on
plot(time_axis(2:end),firstd_go(pl_rats,:)','color',gng.graph.colors.area{2});
plot([0 0],[0 max_y],'--','color',0.65*ones(1,3))
plot([0.5 0.5],[0 max_y],'--','color',0.65*ones(1,3))
plot([3.5 3.5],[0 max_y],'--','color',0.65*ones(1,3))
box off; xlabel 'Time [s]'; ylabel 'Frame - Frame length, [a.u.]'
legend({gng.analysis.areas{1},...
    '','','','','',gng.analysis.areas{2}},'Location','northwest','Box','off')
hold off
ylim([-0.05 max_y])
title('Go')


%%
gng.graphics.bar_color = 'w';
gng.graphics.max_jitter = 0.1;
gng.graphics.dot_color = 0.65 * ones(1,3);
gng.graphics.paired = false;
gng.graphics.error = true;
gng.graphics.paired = true;
first_bar_pos = [1 3];

wfig(77); clf
for iarea = 1:2
    area_flags = [feats(:).area_id] == iarea;
    len_data = [[feats(area_flags).go_mlen]' [feats(area_flags).nogo_mlen]'];
    gng.graphics.position = [first_bar_pos(iarea) first_bar_pos(iarea) + 1];
    bar_disp_dots(len_data,gng.graphics)
end
ylabel 'Traj. Length'; xlim([0.5 4.5])
set(gca,'XTick',[1 2 3 4],'XTickLabel',{'Go_I_L','NoGo_I_L','Go_P_L','NoGo_P_L'})
hold off