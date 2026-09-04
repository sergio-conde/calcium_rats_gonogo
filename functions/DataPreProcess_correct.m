function [dpca_data,firingRates,firingRatesAverage,trialNum,ind_ee] = DataPreProcess_correct(trials,shuf,dpca,lim,baseline_flag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code z-scores, baseline-subtractes and stretches or shrinks the go trials to match the length of the
% nogo trial.
% Input -
% 1) trials - the structure that is of size Ntrials and has fields that
% correspond to different behavioral paramenters.
% 2) shuf - if we want the trial label shuffled. 1 = yes and 0 = no
% Output -
% 1) dpca_data - representation of trials with z-scored, baseline-substracted and streched /shrunk data
% 2) firingRates - Output that dpca needs. 5-d matrix : Ncells x Ncond x
% Noutcome x Nbins x Ntrials. If there are unequal number of trials in
% different conditions, the size of this matrix is the max no of trials
% found in any of the condition. If a condition has lesser number of
% trials, it is padded with NaNs.
% 3) firingRatesAverage - trial averaged firingRates. Therefor 4d matrix.
% 4) trialNum - 3d matrix showing the number of trials for each neuron and
% each condition. Size - Ncells x Ncond x Noutcome.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Removing error trials where the animal did not hold his nose in the poke hole during error trials
ind_ee = [];
for i = 1:length(trials)
    if ~trials(i).nogo
        if (trials(i).nosepokecueoffframe - trials(i).nosepokeentryframe) < 6
            
            ind_ee = [ind_ee i];
        end
    else
        if (trials(i).nosepokecueoffframe - trials(i).nosepokeentryframe) < 6
            ind_ee = [ind_ee i];
        end
        
    end
    if isempty(trials(i).nosepokeentryframe)
        ind_ee = [ind_ee i];
    end
    if trials(i).nosepokeentryframe + lim(2) > size(trials(i).Craw,2)
        ind_ee = [ind_ee i];
    end
end
trials(ind_ee) = [];
%% Z-scores
if dpca
    C_raw_m=[];
    C_m=[];
    % concatenates all baselines, i.e., lim(1) frames before the npentry  
    for i = find([trials(:).reward] == 1) %1:length(trials)
        npentry = trials(i).nosepokeentryframe;
        C_raw_m = [C_raw_m trials(i).Craw(:,npentry-lim(1):npentry)];

%         trials(i).C = detrend(trials(i).C')';
        C_m = [C_m trials(i).C(:,npentry-lim(1):npentry)];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for j = 1:length(trials)
        frameno(j) = size(trials(j).Craw,2); % takes the number of frames 
    end

    C_raw = [trials.Craw];
    C = [trials.C];
    frameno = cumsum(frameno); % cumulative number of frames   

    % normalization by the overall zscore of C and Craw values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:size(C_raw,1)
        m = mean(C_raw(i,:));
        st = std(C_raw(i,:));
        m_c = mean(C(i,:));
        st_c = std(C(i,:));
        z_C_raw(i,:) = (C_raw(i,:) - repmat(m,1,length(C_raw(i,:))))./repmat(st,1,length(C_raw(i,:)));
        z_C(i,:) = (C(i,:) - repmat(m_c,1,length(C(i,:))))./repmat(st_c,1,length(C(i,:)));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    for i  = 1:length(trials)
        if i == 1
            trials(i).Craw = z_C_raw(:,1:frameno(i));
            trials(i).C = z_C(:,1:frameno(i));
        else
            trials(i).Craw = z_C_raw(:,frameno(i-1)+1:frameno(i));
            trials(i).C = z_C(:,frameno(i-1)+1:frameno(i));
        end
    end

% trials(1).C = detrend(z_C(:,1:frameno(1)));
% for itrial = 2:length(trials)
%     trials(i).C = detrend(z_C(:,frameno(i-1)+1:frameno(i)));
% end
    
    %% Baseline subtracted
    % reward = [trials.reward;];
    % ind_reward = find(reward);
    % ind_reward_ss = ind_reward(randsample(length(ind_reward),50));
    % for i = 1:length(ind_reward_ss)

    if baseline_flag
        for i = 1:length(trials)
            
                npentry = trials(i).nosepokeentryframe;
                %      me = mean(trials(i).Craw(:,npentry - 14:npentry-7),2);
                %      me_c = mean(trials(i).C(:,npentry - 14:npentry-7),2);
                me =  mean(trials(i).Craw(:,npentry-lim(1):npentry),2);
                me_c =  mean(trials(i).C(:,npentry-lim(1):npentry),2);


                trials(i).Craw = trials(i).Craw - repmat(me,1,size(trials(i).Craw,2));
                trials(i).C = trials(i).C - repmat(me_c,1,size(trials(i).C,2));
           
        end
    end
 end
%%
for i = 1:length(trials)
    tmp = trials(i).C;
    nogo = trials(i).nogo;
    rew = trials(i).reward;
    if ~nogo && rew
        %         tim_interest = trials(i).leverpressframe - trials(i).nosepokeentryframe;
        %extrplt_tim = linspace(1,tim_interest,45);
        
        for j = 1:size(trials(i).Craw,1)
            tmp2 = tmp(j,:);
            %             tmp_tt = timeseries(tmp2(trials(i).nosepokeentryframe:trials(i).leverpressframe));
            %             tmp_tt2 = resample(tmp_tt,extrplt_tim);
            %             dpca_data(i).C_raw(j,:) = [tmp2(trials(i).nosepokeentryframe-14:trials(i).nosepokeentryframe) squeeze(tmp_tt2.data)' tmp2(trials(i).leverpressframe+1:trials(i).leverpressframe+20)];
            dpca_data(i).C_raw(j,:) = tmp2(trials(i).nosepokeentryframe-lim(1):trials(i).nosepokeentryframe+lim(2));
        end
    elseif nogo && ~rew
        %         tim_interest = trials(i).nosepokecueoffframe - trials(i).nosepokeentryframe;
        %         extrplt_tim = linspace(1,tim_interest,45);
        for j = 1:size(trials(i).Craw,1)
            tmp2 = tmp(j,:);
            %             tmp_tt = timeseries(tmp2(trials(i).nosepokeentryframe:trials(i).nosepokecueoffframe));
            %             tmp_tt2 = resample(tmp_tt,extrplt_tim);
            %             dpca_data(i).C_raw(j,:) = [tmp2(trials(i).nosepokeentryframe-14:trials(i).nosepokeentryframe) squeeze(tmp_tt2.data)' tmp2(trials(i).nosepokecueoffframe+1:trials(i).nosepokecueoffframe+20)];
            dpca_data(i).C_raw(j,:) = tmp2(trials(i).nosepokeentryframe-lim(1):trials(i).nosepokeentryframe+lim(2));
        end
    else
        
        for j = 1:size(trials(i).Craw,1)
            tmp2 = tmp(j,:);
            dpca_data(i).C_raw(j,:) = tmp2(trials(i).nosepokeentryframe-lim(1):trials(i).nosepokeentryframe+lim(2));
            
        end
    end
end

for i = 1:length(dpca_data)
    dpca_data(i).reward = trials(i).reward;
    dpca_data(i).nogo = trials(i).nogo;
end

ind_nogo = [dpca_data.nogo;];
nogo_trials = find(ind_nogo);
go_trials = setdiff(1:length(dpca_data),nogo_trials);
max_trials_condition = max([length(nogo_trials),length(go_trials)]);
n_neurons = size(trials(1).Craw,1);
firingRates = nan(n_neurons,2,2,size(dpca_data(1).C_raw,2),max_trials_condition);

if shuf
    dpca_data2 = dpca_data;
    new_order = randperm(length(dpca_data));
    for f = 1:length(dpca_data)
        dpca_data(f).C_raw = dpca_data2(new_order(f)).C_raw;
    end
end

count = ones(1,4);
for i = 1:length(dpca_data)
    if dpca_data(i).reward && dpca_data(i).nogo
        firingRates(:,1,1,:,count(1)) = dpca_data(i).C_raw;
        count(1) = count(1)+1;
    elseif dpca_data(i).reward && ~dpca_data(i).nogo
        firingRates(:,2,1,:,count(2)) = dpca_data(i).C_raw;
        count(2) = count(2)+1;
    elseif ~dpca_data(i).reward && dpca_data(i).nogo
        firingRates(:,1,2,:,count(3)) = dpca_data(i).C_raw;
        count(3) = count(3)+1;
    else
        firingRates(:,2,2,:,count(4)) = dpca_data(i).C_raw;
        count(4) = count(4) + 1;
    end
end

trialNum(1:n_neurons,1,1) = count(1)-1;
trialNum(1:n_neurons,1,2) = count(3)-1;
trialNum(1:n_neurons,2,2) = count(4)-1;
trialNum(1:n_neurons,2,1) = count(2)-1;
firingRatesAverage = nanmean(firingRates,5);