
function cfg = gonogo_mainconfig

% cfg = gonogo_mainconfig creates the main configuration structure of the
% calcum imaging, Go/No-go project. 
%
% Inputs (none)
%
% Outputs
%   cfg [struct] containing the following fields:
%
%     - file: with all the main project folders. It contains:
%         .root: main project folder
%         .analysis: Data_analysis folder
%         .process: pre-processed data
%         .support: support files as file lists, etc.
%         .collection: Data_collection folder
%         .dread: dread data folder
%         .miniscope: calcium data folder
%         .methods: Methods_and_materials folder
%         .raw: Raw calcium data folder
%
%     - med: with the behavioral configuration. It contains:
%         .np_hold: nose-poke hold requirement to have a correct NoGo trial in seconds [struct]
%           .rat_label: rat name [string]
%           .01: seconds to hold during omission 1 sessions [double]
%           .02: seconds to hold during omission 2 sessions [double]

% Sergio Conde-Ocazionez, 2023. NIN, Willuhn's Lab.

%%
% files configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.file.root           = '\\vs03\VS03-NandB-3\Sergio\miniscope_rat_gonogo';  % project's root folder

cfg.file.analysis       = fullfile(cfg.file.root,'Data_analysis');
cfg.file.collection     = fullfile(cfg.file.root,'Data_collection');
cfg.file.methods        = fullfile(cfg.file.root,'Methods_and_materials');

cfg.file.process        = fullfile(cfg.file.analysis,'processed');            % data's preprocessed folder
cfg.file.support        = fullfile(cfg.file.analysis,'support');              % data's support files folder

cfg.file.dreadd         = fullfile(cfg.file.collection,'DREADD');             % DREADD experiments
cfg.file.miniscope      = fullfile(cfg.file.collection,'Miniscope');          % Calcium experiments

cfg.file.raw            = fullfile(cfg.file.miniscope,'Calcium');             % data's raw matlab files folder
cfg.file.publications   = fullfile(cfg.file.root,'Publications');             % data's raw matlab files folder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Behavioral MedPC config
cfg.med.np_hold(1).rat_label = 'Bilu';
cfg.med.np_hold(1).gng        = 3;
cfg.med.np_hold(1).o1         = 3;
cfg.med.np_hold(1).o2         = 3;

cfg.med.np_hold(2).rat_label = 'July';
cfg.med.np_hold(2).gng        = 2.75;
cfg.med.np_hold(2).o1         = 2.75;
cfg.med.np_hold(2).o2         = 2.75;

cfg.med.np_hold(3).rat_label = 'Nov';
cfg.med.np_hold(3).gng        = 3;
cfg.med.np_hold(3).o1         = 3;
cfg.med.np_hold(3).o2         = 3;

cfg.med.np_hold(4).rat_label = 'Rafa';
cfg.med.np_hold(4).gng        = 3;
cfg.med.np_hold(4).o1         = 3;
cfg.med.np_hold(4).o2         = 3;

cfg.med.np_hold(5).rat_label = 'Sep';
cfg.med.np_hold(5).gng        = 3;
cfg.med.np_hold(5).o1         = 3;
cfg.med.np_hold(5).o2         = 3;

cfg.med.np_hold(6).rat_label = 'Aug';
cfg.med.np_hold(6).gng        = 3;
cfg.med.np_hold(6).o1         = 3;
cfg.med.np_hold(6).o2         = 3;

cfg.med.np_hold(7).rat_label = 'May';
cfg.med.np_hold(7).gng        = 2.25;
cfg.med.np_hold(7).o1         = 2.25;
cfg.med.np_hold(7).o2         = 2.25;

cfg.med.np_hold(8).rat_label = 'Pipa';
cfg.med.np_hold(8).gng        = 2.5;
cfg.med.np_hold(8).o1         = 2.5;
cfg.med.np_hold(8).o2         = 2.5;

cfg.med.np_hold(9).rat_label = 'Tati';
cfg.med.np_hold(9).gng        = 3;
cfg.med.np_hold(9).o1         = 3;
cfg.med.np_hold(9).o2         = 3;

% Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.analysis.trial_label  = {'nogo','go'};
cfg.analysis.rule         = {'regular','omission'};
cfg.analysis.cmp_type     = {'task','notask','all'};

cfg.analysis.trial_id   = [1 0]; % this is intended to match the nogo field in the trials struct where Go = 0 and NoGo = 1;
cfg.analysis.area_label = {'IL','PL'};
cfg.analysis.beh_label  = {'nose-poke','tone-go','tone-nogo','reward','lever-press'};
cfg.analysis.beh_refs   = {'npentry','go','nogo','rew','lp'};
cfg.analysis.fr_rate    = 15;

% Graphics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.graph.colors.area   = {[76 0 153]./255,[255 153 51]./255};
cfg.graph.colors.task   = {[208 2 2]./255;[42 179 75]./255};  % task colors
cfg.graph.trial_label   = {'No-go','Go'};

% Assembly detection configuration %%%%%%%%%%%%%%%%%%%%
cfg.assembly.threshold.method =  'MarcenkoPastur';
% cfg.assembly.threshold.method =  'circularshift';
cfg.assembly.threshold.permutations_percentile = 95;
cfg.assembly.threshold.number_of_permutations = 250;
cfg.assembly.Patterns.method = 'ICA';
cfg.assembly.Patterns.number_of_iterations = 500;
cfg.assembly.act_thr = 500;
%------------------------------------------------%

