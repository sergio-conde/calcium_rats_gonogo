% Head entry post pellet drop latency in go and no-go trials in Regular
% sesssion
%By fv 27-3-2026
%last edited 31-3-2026
%%%%%%%%%%%%%%%%
clear; clc
gng = gonogo_mainconfig;
load(fullfile(gng.file.support,'regular_trials.mat'))

trial_files.regular   = regular_trials;
type_label            = {'regular'};

%% behavior
isession   = 1;
sel_files  = pick_files(regular_trials,'session_id',isession);
results = struct( ...
    'area_id', [], ...
    'rlabel', [], ...
    'HEmag_lat_nogo', [], ...
    'HEmag_lat_go', [] ...
);

for irat = 1:length(sel_files)
    data = load(fullfile(sel_files(irat).folder,sel_files(irat).name));
    name = fieldnames(data);
    data = data.(name{1});
    data = pick_files(data,'reward',1);

        % Reward pickup latency- Find the  first headentry after reward
        for i = 1: length (data)
            idx_reward = find(data(i).E == 3, 1, 'first');  % reward event code
            if ~isempty(idx_reward)
                idx_he_rel = find(data(i).E(idx_reward+1:end) == 13, 1, 'first'); % headentry code
                if ~isempty(idx_he_rel)
                    idx_he = idx_reward + idx_he_rel;
                    time_reward = data(i).D(idx_reward);
                    time_he = data(i).D(idx_he);
                    data(i).latency_rewardpickup = (time_he - time_reward) / 100; % seconds
                else
                    data(i).latency_rewardpickup = NaN; % no headentry after reward
                end
            else
                data(i).latency_rewardpickup = NaN; % no reward event found
            end
        end % Build extra field

    nogo_data     = data([data.nogo] == 1 & [data.reward] == 1);
    HEmag_lat_nogo(irat) = median([nogo_data.latency_rewardpickup], 'omitnan');
    go_data = data([data.nogo] == 0 & [data.reward] == 1);
               HEmag_lat_go(irat) = median([go_data.latency_rewardpickup],  'omitnan')

               results(irat).area_id = sel_files(irat).area_id;
results(irat).rlabel   =  sel_files(irat).rat_label;
results(irat).HEmag_lat_nogo = HEmag_lat_nogo(irat);
results(irat).HEmag_lat_go   = HEmag_lat_go(irat);

end

% save(fullfile(gng.file.publications,'/paper/figure_1/data/','Magazine_headentry_lat.mat'),'results') 
% save(fullfile(gng.file.support,'Magazine_headentry_lat.mat'),'results')
%%
%%%%%%%%%%%%%%%%%%%%%%%%%
%%plot
%%%%%%%%%%%%%%%%%%%%%%%%%

lat_all = [results.HEmag_lat_nogo; results.HEmag_lat_go];
group   = [repmat({'No-go'}, length(HEmag_lat_nogo), 1); ...
           repmat({'Go'},    length(HEmag_lat_go),   1)];

figure; hold on;
boxplot(lat_all, group, 'Symbol', '');
ylim([0 3])
ylabel('Latency reward pick-up (s)')

colors = cell2mat(gng.graph.colors.task);

h = flipud(findobj(gca,'Tag','Box'));

for j = 1:length(h)
    patch(get(h(j),'XData'), get(h(j),'YData'), colors(j,:), ...
        'FaceAlpha', 0.5, 'EdgeColor', colors(j,:));
end

x1 = ones(size(HEmag_lat_nogo));
x2 = 2 * ones(size(HEmag_lat_go));

scatter(ones(size(HEmag_lat_nogo)), HEmag_lat_nogo, 25, colors(1,:), ...
    'filled', 'jitter','on','jitterAmount',0.1)

scatter(2*ones(size(HEmag_lat_go)), HEmag_lat_go, 25, colors(2,:), ...
    'filled', 'jitter','on','jitterAmount',0.1)
set(gcf,'Renderer','painters','Color','w')
box off; xlim([0.5 2.5])

% saveas(gcf,fullfile(gng.file.publications,'/paper/figure_1/','reward_pickup.eps'),'epsc')
