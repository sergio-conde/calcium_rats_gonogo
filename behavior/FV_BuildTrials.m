function trials = FV_BuildTrials(result,filename,medpcfilename,fps)
%For Omission sessions
% filename - path to the folder where all the avi files are stored.
% result - result.mat from cnmf-e
% medpcfilename - medpcfilename for the session recorded
% fps  - frames per second used in the recording
%By FV 22-7-2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% count the number of frames in each of the avi files you concatenated
frameno = FV_CountFrames(filename); 
frameno = cumsum(frameno); %cummulative sum of the framenumbers

[~,D,E] =  ProcessMedPC(medpcfilename); %gets the Events vector 'E' and the time of events vector 'D'

%Downloadaed the whole Oasis package - dot index error 
C = nan(size(result.C_raw));
S = nan(size(result.C_raw));
for itrace = 1:size(result.C_raw,1)
    [C(itrace,:),S(itrace,:),~] = deconvolveCa(result.C_raw(itrace,:),'ar2','optimize_pars',1,'optimize_smin',1,'optimize_b',1);
end


for i = 1:length(frameno) % Separating 1 long C_raw into separate trials
    if i==1
        trials(i).Craw = result.C_raw(:,1:frameno(i));
        trials(i).C = C(:,1:frameno(i));
        trials(i).S = S(:,1:frameno(i));
    else
        trials(i).Craw = result.C_raw(:,frameno(i-1):frameno(i));
        trials(i).C = C(:,frameno(i-1):frameno(i));
        trials(i).S = S(:,frameno(i-1):frameno(i));
    end
end

ind_miniscope = find(E==40);
ind_miniscopeoff = find(E==41);
% Separate the events per trial
for i = 1:length(trials)
    trials(i).E = E(ind_miniscope(i)-1:ind_miniscopeoff(i));
end
%Get the timing of each event.
for i = 1:length(trials)
    trials(i).D = D(ind_miniscope(i)-1:ind_miniscopeoff(i));
end

%correct trial yes or no - based on rew deliverd
for i = 1:length(trials)
   if ~isempty(find(trials(i).E==3))
       trials(i).reward = 1;
   else
       trials(i).reward = 0;
       
    end
end

% what was rewardframe

for i = 1:length(trials)
    if ~isempty(find(trials(i).E==3))
        tmp = find(trials(i).E==3);
        tim_rew = (trials(i).D(tmp) - trials(i).D(2))/100 ;
        trials(i).rewardframe = round(tim_rew*fps);
%     else % otherwise Houselight on -for learning?
%         tmp = find(trials(i).E==14);
%         tim_HL = (trials(i).D(tmp) - trials(i).D(2))/100 ;
%         trials(i).HLon = round(tim_HL*fps);

    end
end
%error in medpc script - look into what happens in a trial this long - pretty sure it's 'the' error we saw in 116- So delete trials where rewardframe is after
%nosepokecueoffframe
% What happens is that trial initiation NP is made late, but within 15 sec
% so still ok, but then a ctrl mechanism that turn off miniscope at 10 sec
% - ERROR was in loading the wrong mini data

%Nosepoke CUE ON

for i = 1:length(trials)
    if ~isempty(find(trials(i).E==16))
        tmp = find(trials(i).E==16);
        tim_cueon = (trials(i).D(tmp) - trials(i).D(2))/100 ;
        trials(i).nosepokecueonframe = round(tim_cueon*fps);
    end
end

%Nogo or not

for i = 1:length(trials)
    if ~isempty(find(trials(i).E==52))  %go tone on
        trials(i).nogo = 0;
    else
        trials(i).nogo = 1;
    end
end


%nosepokeentryframe

for i = 1:length(trials)
    if ~isempty(find(trials(i).E==40))
        tmp = find(trials(i).E==16);
        ind = find(trials(i).E(tmp:end)==20,1,'first')+tmp - 1;  %first Nosepoke afer cue light on
        tim_nosepoke = (trials(i).D(ind) - trials(i).D(2))/100 ;
        trials(i).nosepokeentryframe = round(tim_nosepoke*fps);
    end
end

% %Nosepoke exit ???!!



%nosepokeexit
for i = 1:length(trials)
    exclEvents = [43, 42, 50, 52, 51, 53, 17, 6, 25]; % Events to exclude from consideration

 if ~isempty(find(trials(i).E==43)) %well initiated go trial
     ind_initiated = find(trials(i).E==43);
 afterfirstNosepoke = trials(i).E(ind_initiated+1:end);
        leaveNosepokeIndex =  find(~ismember(afterfirstNosepoke, [20, exclEvents]), 1, 'first')+ ind_initiated-1;
        leaveNosepoketime = (trials(i).D(leaveNosepokeIndex)- trials(i).D(2))/100 ;
        trials(i).nosepokeexitframe = round(leaveNosepoketime*fps);

 else ~isempty(find(trials(i).E==42)) %well initiated nogo trial
ind_initiated = find(trials(i).E==42);
 afterfirstNosepoke = trials(i).E(ind_initiated+1:end);
         leaveNosepokeIndex =  find(~ismember(afterfirstNosepoke, [20, exclEvents]), 1, 'first')+ ind_initiated-1
        leaveNosepoketime = (trials(i).D(leaveNosepokeIndex)- trials(i).D(2))/100 ;
        trials(i).nosepokeexitframe = round(leaveNosepoketime*fps);

 end
end


% %   in case of Go trial last NP between tone on and LP - doesnt work if no
% %   np between those - so if isempty(ans) last NP before LP (19)
% %   ------DOESNT work to look at LP since they'll refrain from LP when
% %   omission is learned
% %         in case of correct NoGo trial last NP between tone on and reward
% %          In case of incorrect NoGo trial last NP between tone on and off
% %             
% 
% for i = 1:length(trials)
%     %GO
%     if isempty(find(trials(i).E==46)) %if it's go
%         tmp_strt = find(trials(i).E==52); %go tone on
%         tmp_end = find(trials(i).E==19); %LP
%         ind = find(trials(i).E(tmp_strt:tmp_end(1))==20,1,'last')+tmp - 1;  %
%         if isempty (ind)
%              ind = find(trials(i).E(1:tmp_end(1))==20,1,'last')+tmp - 1;  %
%         end
%         tim_nosepoke = (trials(i).D(ind) - trials(i).D(2))/100 ;
%         trials(i).nosepokeexitframe = round(tim_nosepoke*fps);
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%No of LP's between tone on and off

 for i = 1:length(trials)

   if ~isempty(find(trials(i).E==47)) %if it's go
 tmp_strt = find(trials(i).E==52);
 tmp_end = find(trials(i).E == 53);

%  a = trials(i).E(tmp_strt:tmp_end)
%  b = [19,7,9];
%  c = ismember(a, b);
%  indexes = find(c);
%         ind_LP = (indexes)+tmp_strt - 1;  %all LP's

%7 and 9 are extra event for same press (check in code)
ind_LP = find(trials(i).E(tmp_strt:tmp_end) == 19)+tmp_strt - 1;

        trials(i).n_lvr = size(ind_LP,2); %how many

        tim_LP = (trials(i).D(ind_LP) - trials(i).D(2))/100 ;
        trials(i).lpressframe = round(tim_LP*fps);
    end
 end

%Nosepoke CUE OFF


for i = 1:length(trials)
    if ~isempty(find(trials(i).E==17))
        tmp = find(trials(i).E==17,1,'first');
        tim_cueoff = (trials(i).D(tmp) - trials(i).D(2))/100 ;
        trials(i).nosepokecueoffframe = round(tim_cueoff*fps);
    end
end
 

%first press latency from go tone on

for i = 1:length(trials)

    if ~isempty(find(trials(i).E==47)) %if it's go
        tmp_strt = find(trials(i).E==52);
        time_toneOn = trials(i).D(tmp_strt);
        tmp_end = find(trials(i).E == 53);
        ind_LP = find(trials(i).E(tmp_strt:tmp_end) == 19,1, 'first')+tmp_strt - 1;

       tim_LP = trials(i).D(ind_LP) ;
        trials(i).first_press_latency = (tim_LP - time_toneOn)/100; %latency in sec
    end
end

% %%Correct Go omission done as NOGO
for i = 1:length(trials)
if  trials(i).nogo == 0 && trials(i).reward == 1 %  
    if (abs(trials(i).nosepokeexitframe - trials(i).rewardframe)) <3   %3 frames is arbitrary
        trials(i).DoneasNoGo = 1;
    else
    trials(i).DoneasNoGo = 0;
    end
end
end

%explore go trials

for i = 1:length(trials)

    if ~isempty(find(trials(i).E==47)) %if it's go
        tmp_strt = find(trials(i).E==52);
        time_toneOn = trials(i).D(tmp_strt);
        tmp_end = find(trials(i).E == 53);
        ind_firstend = find(trials(i).E(tmp_strt:tmp_end) == 25,1, 'first')+tmp_strt - 1;
 tim_firstend = (trials(i).D(ind_firstend) - trials(i).D(2))/100 ;
        trials(i).firstendframe = round(tim_firstend*fps);

tim_end = trials(i).D(ind_firstend) ;
        trials(i).first_end_latency = (tim_end - time_toneOn)/100; %latency in sec

    end
end

%What about later nosepokes?

for i = 1:length(trials)
   
exclEvents = [43, 42, 50, 52, 51, 53, 17, 6, 25]; % Events to exclude from consideration
 if ~isempty(find(trials(i).E==43)) %well initiated go trial
     ind_initiated = find(trials(i).E==43);
      tmp_end = find(trials(i).E == 53);
 afterfirstNosepoke = trials(i).E(ind_initiated+1:tmp_end); %between start go trial and tone off
        leaveNosepokeIndex =  find(~ismember(afterfirstNosepoke, [20, exclEvents]), 1, 'first')+ ind_initiated-1;

     afterlastNosepoke = trials(i).E(leaveNosepokeIndex+1:end); %after the last nosepoke from the first long hold, if thea animal leaves then does it come back?
  Event_indices =  (find(afterlastNosepoke == 20))+leaveNosepokeIndex - 1; %all the nosepoes after
    

        laterNosepoketime = (trials(i).D(Event_indices)- trials(i).D(2))/100 ;  
        laternosepokeframes = round(laterNosepoketime*fps);
        trials(i).laternosepokeframes = unique(laternosepokeframes);


 end
end





 end