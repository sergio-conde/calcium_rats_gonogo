%% this script takes the LME results from regular and omission trials

clear; clc
gng = gonogo_mainconfig;
load(fullfile(gng.file.process,'lem_results.mat'))
tr_label  = fieldnames(lem);
beh_refs = gng.analysis.beh_refs;

%% read LME results and compare to the shuffled data to identify responsive cells

% lem.regular   = importdata(fullfile(gng.file.support,'lem_regular.mat'));
% lem.omission  = importdata(fullfile(gng.file.support,'lem_omission.mat'));
% tr_label  = fieldnames(lem);
% 
% for itr = 1:2
%     for ifile = 1:length(lem.(tr_label{itr}))
%         for ivar = 1:length(gng.analysis.beh_refs)
%             loc_var = gng.analysis.beh_refs{ivar};
%             fprintf('Variable: %s ... ',loc_var)
% 
%             file_path   = fullfile(lem.(tr_label{itr})(ifile).folder,lem.(tr_label{itr})(ifile).name);
%             lem_data    = load(file_path,'K',['F_' loc_var],['F_' loc_var '_shuf']);
%             F_var       = lem_data.(['F_' loc_var]);
%             F_var_shuf  = lem_data.(['F_' loc_var '_shuf']);
% 
%             lem.(tr_label{itr})(ifile).ncells               = size(lem_data.K,1);
%             lem.(tr_label{itr})(ifile).([loc_var '_cells']) = FindCells(F_var,F_var_shuf,lem_data.K,1,'no');
%             fprintf(' done\n')
%         end
%     end
% end
% % save(fullfile(gng.file.process,'lem_results.mat'),"lem")

%% read the lem results and plot the number of responsive cells in regular and omission trials

titles = {'Regular','Omission 1','Omission 2'};
anova_data = cell(1,3);
wfig(1); clf
set(gcf,'Renderer','painters')
isp = 1;
resp_cells.beh_labels = gng.analysis.beh_label([1:3 5 4]);

for itr = 2%1:2
    il_flags = cellfun(@(x) strcmp(x,'IL'),{lem.(tr_label{itr}).area_label});

    for isession = 1:2
        session_flags = [lem.(tr_label{itr})(:).session_id] == isession;
        
        
        if any(session_flags)
            tab_labels = {};
            area_labels = {};

            il_data   = il_flags & session_flags;
            pl_data   = ~il_flags & session_flags;
            all_data  = il_data | pl_data;

            var_means   = [];
            var_std     = [];

            resp_cells.session  = titles{isp};
            resp_cells.il_flags = il_data;
            resp_cells.labels   = gng.analysis.beh_refs;

            for ivar = [1 2 3 5 4] %1:length(gng.analysis.beh_refs)
                loc_var = gng.analysis.beh_refs{ivar};

                cell_num    = 100 * cellfun(@numel,{lem.(tr_label{itr}).([loc_var '_cells'])})./[lem.(tr_label{itr})(:).ncells];
                var_means   = cat(1,var_means,mean(cell_num(il_data)));
                var_means   = cat(1,var_means,mean(cell_num(pl_data)));

                var_std     = cat(1,var_std,std(cell_num(il_data))./sqrt(sum(il_data)));
                var_std     = cat(1,var_std,std(cell_num(pl_data))./sqrt(sum(pl_data)));

                var_means   = cat(1,var_means,nan);
                var_std     = cat(1,var_std,nan);

                rat_id          = [lem.(tr_label{itr}).rat_id]';
                rat_id(pl_data) = rat_id(pl_data) + 5;
                long_data       = [cell_num' rat_id [lem.(tr_label{itr}).area_id]' ivar * ones(length(cell_num),1)];

                anova_data{isp} = cat(1,anova_data{isp},long_data(all_data,:));
                tab_labels = cat(1,tab_labels,repmat(resp_cells.labels(ivar),sum(all_data),1));
                loc_areas = {lem.(tr_label{itr}).area_label}';
                area_labels = cat(1,area_labels,loc_areas(session_flags));
            end

            resp_cells.var_means  = var_means;
            resp_cells.var_std    = var_std;

            loc_table = array2table(anova_data{isp},'VariableNames',{'perc','animal_id','area_id','beh_var'});
            loc_table.beh_labels = tab_labels;
            loc_table.area_label = area_labels;

            anova_data{isp} = loc_table;

            table_name = sprintf('resp_cells_%s_%i.csv',tr_label{itr},isession);

            % writetable(loc_table,fullfile(gng.file.publications,'/paper/figure_1/data/',table_name))

            subplot(1,3,isp)
            bar(1:3:13,var_means(1:3:13),'BarWidth',0.25,'FaceColor',gng.graph.colors.area{1},'FaceAlpha',0.6)
            hold on
            bar(2:3:14,var_means(2:3:14),'BarWidth',0.25,'FaceColor',gng.graph.colors.area{2},'FaceAlpha',0.6)
            errorbar(1:3:13,var_means(1:3:13),var_std(1:3:13),'.k')
            errorbar(2:3:14,var_means(2:3:14),var_std(2:3:14),'.k')
            plot([0 15],[10 10],'--','color',0.65 * ones(1,3));
            plot([0 15],[50 50],'--','color',0.65 * ones(1,3));
            hold off; box off; xlim([0 15])
            set(gca,'xtick',[1.5 4. 7.5 10.5 13.5],'XTickLabel',gng.analysis.beh_label([1:3 5 4]))
            ylabel '% responsive cells'
            title(titles{isp + 1})
            legend({'IL','PL'},'Location','northwest')
            ylim([0 100])
            isp = isp + 1;
        end
    end
end
%% Changing the table format

wide_table = array2table(cell(0,7),'VariableNames',[...
    'animal_id','area_label',beh_refs]);

rat_ids = unique(loc_table.animal_id);
for irat = 1:length(rat_ids)
    wide_table.animal_id{irat} = rat_ids(irat);
    for ievent = 1:5
        loop_flags = loc_table.animal_id == rat_ids(irat) & ...
            strcmp(loc_table.beh_labels,beh_refs{ievent});
        loop_data = loc_table(loop_flags,:);
        wide_table.(beh_refs{ievent}){irat} = loop_data.perc;
    end
    wide_table.area_label(irat) = loop_data.area_label;
end
table_name = sprintf('resp_cells_%s_%i_wide.csv',tr_label{itr},isession);
% writetable(wide_table,fullfile(gng.file.publications,'/paper/figure_1/data/',table_name))

%% cells responding exclusively to a specific event

itr = 1;
resp_cells.exc.data = nan(1,5);
isp = 1;
for ibeh_ref = [1:3 5 4]
    rem_beh = setdiff(1:5,ibeh_ref);
    for irat  = 1:10
        ref_cells = lem.(tr_label{itr})(irat).([beh_refs{ibeh_ref} '_cells']);
        cplx_cells = [];
        for ibeh = rem_beh
            cplx_cells = cat(2,cplx_cells,lem.(tr_label{itr})(irat).([beh_refs{ibeh} '_cells']));
        end
        resp_cells.exc.data(irat,ibeh_ref) = 100 * sum(~ismember(ref_cells,cplx_cells))/lem.(tr_label{itr})(irat).ncells;
    end
    isp = isp + 1;
end

isp = 1;
resp_cells.exc.mean_val = nan(1,10);
resp_cells.exc.err_val = nan(1,10);
for ibeh = [1 2 3 5 4]
    for iarea = 1:2
        area_flags  = [lem.(tr_label{itr}).area_id] == iarea;
        area_data   = resp_cells.exc.data(area_flags,ibeh);

        resp_cells.exc.mean_val(isp) = mean(area_data);
        resp_cells.exc.err_val(isp) = std(area_data)./sqrt(sum(area_flags));
        isp = isp + 1;
    end
end

% save(fullfile(gng.file.publications,'/paper/figure_1/data/','resp_cells.mat'),'resp_cells') 
%% comparing regular vs omission

bar_cfg             = [];
bar_cfg.position    = [1 2];
bar_cfg.max_jitter  = 0.1;
bar_cfg.paired      = true;
bar_cfg.transparency= 0.5;
bar_cfg.error       = true;

omission = 2;
isp      = 1;

wfig(2); clf
for iarea = 1:2
    om_results  = pick_files(lem.omission,'session_id',omission,'area_id',iarea);
    reg_results = pick_files(lem.regular,'area_id',iarea);

    bar_cfg.bar_color = gng.graph.colors.area{iarea};
    bar_cfg.dot_color = gng.graph.colors.area{iarea};

    for ibeh = 1:4
        resp_cells  = nan(length(om_results),2);
        beh_ref     = gng.analysis.beh_refs{ibeh};
        for irat = 1:length(om_results)
            reg_data            = pick_files(reg_results,'rat_label',om_results(irat).rat_label);
            resp_cells(irat,1)  = 100 * length(reg_data.([beh_ref '_cells'])) / reg_data.ncells;
            resp_cells(irat,2)  = 100 * length(om_results(irat).([beh_ref '_cells'])) / om_results(irat).ncells;
        end
        subplot (2,4,isp)
        bar_disp_dots(resp_cells,bar_cfg);
        title([gng.analysis.area_label{iarea} ' - '  gng.analysis.beh_label{ibeh}])
        xticklabels({'','Regular','Omission'});
        ylabel '% resp. cells'; xlabel 'Session'
        isp = isp + 1;
    end
end


%%


wfig(222); clf; 
set(gcf,"Position",[1326 422 387 452],"Renderer","painters")
bar(1:3:13,mean_val(1:2:10),'BarWidth',0.3,'FaceColor',gng.graph.colors.area{1},'FaceAlpha',0.6)
hold on
bar(2:3:14,mean_val(2:2:10),'BarWidth',0.3,'FaceColor',gng.graph.colors.area{2},'FaceAlpha',0.6)
errorbar(1:3:13,mean_val(1:2:10),err_val(1:2:10),'.k')
errorbar(2:3:14,mean_val(2:2:10),err_val(2:2:10),'.k')
plot([0 15],[10 10],'--','color',0.65 * ones(1,3));
plot([0 15],[50 50],'--','color',0.65 * ones(1,3));
hold off; box off; xlim([0 15])
set(gca,'xtick',[1.5 4. 7.5 10.5 13.5],...
    'XTickLabel',gng.analysis.beh_label([1:3 5 4]),...
    'YTick',20:20:100,'FontSize',11)
ylabel('% Responsive Cells','FontSize',14)
legend({'IL','PL'},'Location','northwest','Box','off')
ylim([0 100])