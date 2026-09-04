function [class,posterior,perf,test_gr] =  DecodeTrajs_correct(trajs,trialNum,iter,shuf,balance_flag)

% [class,posterior,perf,test_gr] =  DecodeTrajs_correct(Trajs,trialNum,iter,shuf)
%
% This is based on Aisu's DecodeTrajs function, but only for correct trials. It also balance the decoder's training 
% input by feed it wit the same amount the go and no go trials. 
%
%   Inputs:
%     trajs: 4D array organized as Aishu's but only for correct trials ([dpca_comp x n_frames x nogo/go x trial])
%     tialNum: number of go and nogo trials as
%     iter: 
%     shuf: shuffle (or not) go nogo trials before testing the decodifier
%     balance_flag: take (or not) same number of go and nogo trials to train the decoder 
%
%   Outputs:
%
% Sergio Conde, Mar 2023. NIN. Willuhn's Lab. 

% % debbuging %%%%%%%%
% shuf = 0;
% balance_flag = true;
% trajs = corr_trajs;
% %%%%%%%%%%%%%%%%%%%%

% read number of go and nogo trials %%%%%%%%%%%%
n_go = trialNum(1,2,1); 
n_nogo = trialNum(1,1,1);
n_train = floor(min([n_go n_nogo])/2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% concatenate go and nogo trials %%%%%%%%%%%%%%%%
all_nogo_trajs = squeeze(trajs(:,:,1,1:n_nogo));
all_go_trajs = squeeze(trajs(:,:,2,1:n_go));
all_trajs  = cat(3,all_nogo_trajs,all_go_trajs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% shuffle (or not) go nogo trials %%%%%%%%%%%%%
if shuf == 0
    gr = [ones(1,n_nogo) 2*ones(1,n_go)];
else
    gr = [ones(1,n_nogo) 2*ones(1,n_go)];
    gr = gr(randsample(length(gr),length(gr)));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if balance_flag
    all_trajs = cat(3,all_trajs(:,:,1:2*n_train),...
        all_trajs(:,:,n_nogo+1:n_nogo + 2*n_train));
     n_nogo = 2 * n_train; n_go = 2 * n_train;
     gr = [ones(1,2*n_train) 2*ones(1,2*n_train)];
     if shuf == 1
         gr = gr(randsample(length(gr),length(gr)));
     end     
end

for i_train = 1:iter
    tr_nogo_samp = randsample(1:n_nogo,n_train);
    tr_go_samp = randsample(n_nogo + 1 : n_nogo + n_go,n_train);

    train_set(i_train,:) = [tr_nogo_samp tr_go_samp];
    test_set(i_train,:) = setdiff(1:size(all_trajs,3),train_set(i_train,:));

    for i_time = 1:size(all_trajs,2)
        
        [class(i_train,i_time,:),~,posterior(i_train,i_time,:,:),~,~] = classify(squeeze(all_trajs(:,i_time,test_set(i_train,:)))',...
            squeeze(all_trajs(:,i_time,train_set(i_train,:)))',gr(train_set(i_train,:)));

        perf(i_train,i_time) = length(find(squeeze(class(i_train,i_time,:))' - gr(test_set(i_train,:))==0))/length(test_set(i_train,:));
    end
    test_gr(i_train,:) = gr(test_set(i_train,:));
end
