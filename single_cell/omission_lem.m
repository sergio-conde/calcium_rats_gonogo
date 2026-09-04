%%
% This code lists the trial.mat files and loop them to compute the LEM
% using Aishu's codes. The script will create in each folder a
% lem_results_omission.mat file containing the results for both model and
% surrogate. 

clear; clc
main_cfg = gonogo_mainconfig; % read main configuration

% %
% %%% load the default main omission trials configuration                                       
cfg = [];
cfg.file.main_path      = main_cfg.file.process;
cfg.file.level_name     = {'area','rat'};               % labels of each organization level
cfg.file.folder_coding  = {'*L','*'};                   % string coding for each level (folders)
cfg.file.file_str       = 'trials_o*.mat';              % indicate file name coding  (to take omission trials.mat files)
om_trials               = proj_organigram(cfg.file);    % create file list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

om_trials(9:10) = []; % removng Sep because of its low perfomance

for ifile = 1:length(om_trials)
    under_flag = strfind(om_trials(ifile).name,'.');
    om_trials(ifile).session_id = str2double(om_trials(ifile).name(under_flag - 1));
end 

% % taking only the second omission just to test the model
% entry             = [];
% entry.session_id  = 1;
% om_trials         = get_entry(om_trials,entry);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off','all')
%%
%  load('\\vs03\VS03-NandB-3\Aishu\GoNogo_MS\PreProcessed_Data\PL\Cohort_4\Aug\Go_3s\FV_trials.mat')

%%
err_files     = []; % this will store the file ids of those trial.mat files that had probelms processing so you can check them separately later
n_iter        = 300; % 500;  % number of surrogates
data_interval = [29 63]; % This cuts up to 63 to adapt the data to omission trials. Originally (regular trials) was up to 60, so 90 frames in total)

for ifile = 2%1:length(om_trials)
    fprintf('Processing file %i ...',ifile)
    clear K_*shuf
    load(om_trials(ifile).file_path) % load calcium traces at each trial

    % This is dealing exclusively with Pipa's peculiarities
    if strcmp(om_trials(ifile).rat,'Pipa')
        trials = FV_trials; % The file was created with that name
        npress = cellfun(@length,{trials.lpressframe});
        trials(npress > 0) = []; % trials with any number of lever presses are removed
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    nframes = cellfun(@(x) size(x,2),{trials.Craw});
    trials(nframes < 93) = []; 
    
    try
        % DataPreProcessTest only cuts and center the traces
        [dpca_data,firingRates,firingRatesAverage,trialNum,ind_ee] = DataPreProcessTest(trials,0,1,data_interval); 
        trials(ind_ee) = [];

        [K,task_Event]  = Regression2test(firingRates,trials,trialNum,[],0);
        [K_npentry,~]   = Regression2test(firingRates,trials,trialNum,1,0);
        [K_go,~]        = Regression2test(firingRates,trials,trialNum,2,0);
        [K_nogo,~]      = Regression2test(firingRates,trials,trialNum,3,0);
        [K_rew,~]       = Regression2test(firingRates,trials,trialNum,4,0);
        [K_lp,~]        = Regression2test(firingRates,trials,trialNum,5,0);

        for i = 1:n_iter
            fprintf('shuffle %i\n',i)
            [K_shuf(:,:,:,i),~]         = Regression2test(firingRates,trials,trialNum,[],1);
            [K_npentry_shuf(:,:,:,i),~] = Regression2test(firingRates,trials,trialNum,1,1);
            [K_go_shuf(:,:,:,i),~]      = Regression2test(firingRates,trials,trialNum,2,1);
            [K_nogo_shuf(:,:,:,i),~]    = Regression2test(firingRates,trials,trialNum,3,1);
            [K_rew_shuf(:,:,:,i),~]     = Regression2test(firingRates,trials,trialNum,4,1);
            [K_lp_shuf(:,:,:,i),~]      = Regression2test(firingRates,trials,trialNum,5,1);
        end

        [F_npentry,F_npentry_shuf,p_npentry_true,p_npentry_shuf]    = ValidateRegression2test(K,K_npentry,K_shuf,K_npentry_shuf,firingRates,trialNum,1,trials);
        [F_go,F_go_shuf,p_go_true,p_go_shuf]                        = ValidateRegression2test(K,K_go,K_shuf,K_go_shuf,firingRates,trialNum,2,trials);
        [F_nogo,F_nogo_shuf,p_nogo_true,p_nogo_shuf]                = ValidateRegression2test(K,K_nogo,K_shuf,K_nogo_shuf,firingRates,trialNum,3,trials);
        [F_rew,F_rew_shuf,p_rew_true,p_rew_shuf]                    = ValidateRegression2test(K,K_rew,K_shuf,K_rew_shuf,firingRates,trialNum,4,trials);
        [F_lp,F_lp_shuf,p_lp_true,p_lp_shuf]                        = ValidateRegression2test(K,K_lp,K_shuf,K_lp_shuf,firingRates,trialNum,5,trials);

        n_cells_npentry =  FindCells(F_npentry,F_npentry_shuf,K,1,'no');
        n_cells_go      =  FindCells(F_go,F_go_shuf,K,1,'no');
        n_cells_nogo    =  FindCells(F_nogo,F_nogo_shuf,K,1,'no');
        n_cells_lp      =  FindCells(F_lp,F_lp_shuf,K,1,'no');
        n_cells_rew     =  FindCells(F_rew,F_rew_shuf,K,1,'no');

%         disp('Please choose a folder to save the results from the analysis.');
        % Saves the necessary lem_results for intermediate results fro each
        % animal.
        area_name   = om_trials(ifile).area;
        animal_name = om_trials(ifile).rat;

        % file_name = sprintf('lem_o%i_%s.mat',om_trials(ifile).session_id,om_trials(ifile).rat);
        % save_path = fullfile(om_trials(ifile).folder,file_name);
        % save(save_path,'firingRates','firingRatesAverage','task_Event',...
        %     'K','K_npentry','K_go','K_nogo','K_rew','K_lp',...
        %     'K_shuf','K_npentry_shuf','K_go_shuf','K_nogo_shuf','K_rew_shuf','K_lp_shuf',...
        %     'F_npentry','F_go','F_nogo','F_rew','F_lp',...
        %     'F_go_shuf','F_npentry_shuf','F_nogo_shuf','F_rew_shuf','F_lp_shuf',...
        %     'n_cells_npentry','n_cells_go','n_cells_nogo','n_cells_rew','n_cells_lp');

        fprintf('done\n')
    catch errlog
        fprintf('error\n')
        err_files = cat(1,err_files,ifile);
    end
end

