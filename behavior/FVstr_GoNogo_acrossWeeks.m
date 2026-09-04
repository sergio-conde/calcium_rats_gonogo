%script to plot go and nogo behavior across weeks for both cohorts
clear; clc;
saveDir = '\\vs03\VS03-NandB-3\Felice\Dreadd_Rat_PFC_GNG\Data_Analysis\GNG';   
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

Config = struct();

Config.Cohort4.Folder = '\\vs03\VS03-NandB-3\Aishu\raw_data\_aishu_data_to_sort\CalciumImaging\Rats\NIN191204\cortex\MedPC_cohort4';
Config.Cohort5.Folder = '\\vs03\VS03-NandB-3\Aishu\raw_data\_aishu_data_to_sort\CalciumImaging\Rats\NIN191204\cortex\MedPC_cohort5';

% 
Config.Cohort4.Animals(1).ID    = 'MAR';

Config.Cohort4.Animals(2).ID    = 'MAY';

Config.Cohort4.Animals(3).ID    = 'AUG';

Config.Cohort4.Animals(4).ID    = 'JUL';

Config.Cohort4.Animals(5).ID    = 'SEP';

Config.Cohort4.Animals(6).ID    = 'NOV';

%
Config.Cohort5.Animals(1).ID    = 'Pip';

Config.Cohort5.Animals(2).ID    = 'Tat';

Config.Cohort5.Animals(3).ID    = 'Bil';

Config.Cohort5.Animals(4).ID    = 'Raf';

% %
% Config.Cohort4.CutoffDate = '20210506';
% Config.Cohort5.CutoffDate = '20211228';

% Cohort 4
Config.Cohort4.Animals(1).ID         = 'MAR';
Config.Cohort4.Animals(1).CutoffDate = '20210414';
Config.Cohort4.Animals(1).Date_Omit1 = [];
Config.Cohort4.Animals(1).Date_Omit2 = [];

Config.Cohort4.Animals(2).ID         = 'MAY';
Config.Cohort4.Animals(2).CutoffDate = '20210421';
Config.Cohort4.Animals(2).Date_Omit1 = '20210507';
Config.Cohort4.Animals(2).Date_Omit2 = '20210527';

Config.Cohort4.Animals(3).ID         = 'AUG';
Config.Cohort4.Animals(3).CutoffDate = '20210414';
Config.Cohort4.Animals(3).Date_Omit1 = '20210507';
Config.Cohort4.Animals(3).Date_Omit2 = '20210520';

Config.Cohort4.Animals(4).ID         = 'JUL';
Config.Cohort4.Animals(4).CutoffDate = '20210510';
Config.Cohort4.Animals(4).Date_Omit1 = '20210519';
Config.Cohort4.Animals(4).Date_Omit2 = '20210527';

Config.Cohort4.Animals(5).ID         = 'SEP';
Config.Cohort4.Animals(5).CutoffDate = '20210406';
Config.Cohort4.Animals(5).Date_Omit1 = '20210507';
Config.Cohort4.Animals(5).Date_Omit2 = '20210520';

Config.Cohort4.Animals(6).ID         = 'NOV';
Config.Cohort4.Animals(6).CutoffDate = '20210414';
Config.Cohort4.Animals(6).Date_Omit1 = '20210507';
Config.Cohort4.Animals(6).Date_Omit2 = '20210520';

% Cohort 5
Config.Cohort5.Animals(1).ID         = 'Pip';
Config.Cohort5.Animals(1).CutoffDate = '20211216';
Config.Cohort5.Animals(1).Date_Omit1 = '20211229';
Config.Cohort5.Animals(1).Date_Omit2 = '20220111';

Config.Cohort5.Animals(2).ID         = 'Tat';
Config.Cohort5.Animals(2).CutoffDate = '20211216';
Config.Cohort5.Animals(2).Date_Omit1 = '20211229';
Config.Cohort5.Animals(2).Date_Omit2 = '20220111';

Config.Cohort5.Animals(3).ID         = 'Bil';
Config.Cohort5.Animals(3).CutoffDate = '20211128';  % 
Config.Cohort5.Animals(3).Date_Omit1 = '20211230';
Config.Cohort5.Animals(3).Date_Omit2 = '20220111';

Config.Cohort5.Animals(4).ID         = 'Raf';
Config.Cohort5.Animals(4).CutoffDate = '20211208';
Config.Cohort5.Animals(4).Date_Omit1 = '20211229';
Config.Cohort5.Animals(4).Date_Omit2 = '20220111';
%%%
%6-2026 save config mat
% save(fullfile(saveDir, 'Performance_Config_wGo_Nogo_dates.mat'), 'Config'); %6-2026 with dates


%% ============================
% Loop to get all performances and latencies of all animals in both cohorts
% 

CohortNames = fieldnames(Config);
Results = struct();

for c = 1:length(CohortNames)

    cohortName = CohortNames{c};
    cohortPath = Config.(cohortName).Folder;
    animalList = Config.(cohortName).Animals;

    fprintf('\n=============================\n');
    fprintf(' Processing %s\n', cohortName);
    fprintf('=============================\n');

    %% Find all session folders automatically 
    sessionFolders = dir(cohortPath);
    sessionFolders = sessionFolders([sessionFolders.isdir]);

  
    sessionFolders = sessionFolders(~ismember({sessionFolders.name},{'.','..'}));

    fprintf('Found %d session folders\n', length(sessionFolders));

    %% Loop over animals 
    for a = 1:length(animalList)

        ratID = animalList(a).ID;
perfB9B1_all = [];
perfB15_all  = [];
b12_all      = [];
perfb24Nogo_all = [];
perfb27Go_all = [];
        sessionDates = {};

        fprintf('\nAnimal: %s\n', ratID);

        %Loop over all session folders
        for s = 1:length(sessionFolders)

            folderName = sessionFolders(s).name;
            sessionPath = fullfile(cohortPath, folderName);

            % Extract true date (first 8 digits)
            dateToken = regexp(folderName, '^\d{8}', 'match');

            if isempty(dateToken)
                continue; % skip weird folders
            end

           % sessionDate = dateToken{1};
           sessionDate = folderName;  
sessionDates{end+1} = folderName;  

               medpcFile = dir(fullfile(sessionPath, ['*' ratID '*']));

            if isempty(medpcFile)
                continue; % animal missing that day → skip
            end

            filePath = fullfile(sessionPath, medpcFile(1).name);

            %Read MedPC 
            medpc_data = read_medpc(filePath);

if length(medpc_data.B) >= 10 && medpc_data.B(1) > 0
    perf_B9B1 = medpc_data.B(10) / medpc_data.B(2);
else
    perf_B9B1 = NaN;
end


if length(medpc_data.B) >= 16
    perf_B15 = medpc_data.B(16);
else
    perf_B15 = NaN;
end

  

if length(medpc_data.B) >= 13
    b12value = medpc_data.B(13);
else
    b12value = NaN;
end
%nogo
if length(medpc_data.B) >= 25
    b24value = medpc_data.B(25);
else
    b24value = NaN;
end
if length(medpc_data.B) >= 28
    b27value = medpc_data.B(28);
else
    b27value = NaN;
end


%storing it
perfB9B1_all(end+1) = perf_B9B1;
perfB15_all(end+1)  = perf_B15;
b12_all(end+1)      = b12value;
perfb24Nogo_all(end+1) = b24value;
perfb27Go_all(end+1)= b27value;

        end

     Results.(cohortName).(ratID).Perf_B9B1 = perfB9B1_all;
Results.(cohortName).(ratID).Perf_B15  = perfB15_all;
Results.(cohortName).(ratID).B12       = b12_all;
Results.(cohortName).(ratID).Nogo  = perfb24Nogo_all;
Results.(cohortName).(ratID).Go  = perfb27Go_all;
Results.(cohortName).(ratID).Dates     = sessionDates;  % now a full cell array

%         Results.(cohortName).(ratID).Dates      = sessionDate;


    end %animals
end % cohorts

%% ============================
%SAVE RESULTS STRUCT
%% Save 
 save(fullfile(saveDir, 'Performance_Results_wGo_Nogo_dates.mat'), 'Results'); %6-2026 with dates
%load ('\\vs03\VS03-NandB-3\Felice\Dreadd_Rat_PFC_GNG\Data_Analysis\GNG\Performance_Results_wGo_Nogo.mat')
%%
CohortNames = fieldnames(Results);

% Collect all rats into one list
allRats = {};

for c = 1:length(CohortNames)
    cohortName = CohortNames{c};
    ratNames = fieldnames(Results.(cohortName));

    for r = 1:length(ratNames)
        allRats{end+1}.Cohort = cohortName;
        allRats{end}.RatID   = ratNames{r};
    end
end

nRats = length(allRats);

%%Find maximum number of sessions across all rats
maxSessions = 0;

for i = 1:nRats
    cohort = allRats{i}.Cohort;
    ratID  = allRats{i}.RatID;

    nSess = length(Results.(cohort).(ratID).Perf_B9B1);

    if nSess > maxSessions
        maxSessions = nSess;
    end
end
%% =====================================================
% Combined Go/NoGo plot — both cohorts together

totalAnimals = sum(cellfun(@(c) length(Config.(c).Animals), CohortNames));

%% =====================================================
%  max session length across all animals
%% =====================================================
maxSess = 0;
for c = 1:length(CohortNames)
    cohortName = CohortNames{c};
    animalList = Config.(cohortName).Animals;
    for a = 1:length(animalList)
        ratID   = animalList(a).ID;
        maxSess = max(maxSess, length(Results.(cohortName).(ratID).Go));
    end
end
%% =====================================================
% Preallocate matrices (animals x sessions)
allGo   = NaN(totalAnimals, maxSess);
allNogo = NaN(totalAnimals, maxSess);

%% =====================================================
%  lookup table (row → cohort + animal)
%           so we can trace any matrix row back to an animal
rowInfo = struct();
row = 0;
for c = 1:length(CohortNames)
    cohortName = CohortNames{c};
    animalList = Config.(cohortName).Animals;
    for a = 1:length(animalList)
        row = row + 1;
        rowInfo(row).Cohort = cohortName;
        rowInfo(row).Animal = animalList(a).ID;
    end
end
%% =====================================================
%  Fill matrices, trimmed per animal cutoff
row = 0;
for c = 1:length(CohortNames)
    cohortName = CohortNames{c};
    animalList = Config.(cohortName).Animals;

    for a = 1:length(animalList)
        row        = row + 1;
        ratID      = animalList(a).ID;
        cutoffDate = animalList(a).CutoffDate;

        go    = Results.(cohortName).(ratID).Go;
        nogo  = Results.(cohortName).(ratID).Nogo;
        dates = Results.(cohortName).(ratID).Dates;

        % Find last session index on or before this animal's cutoff
%         if isempty(cutoffDate)
%             animalCutoff = length(go);  % no cutoff — use all sessions
%         else
            animalCutoff = find(cellfun(@(d) str2double(d(1:8)) <= str2double(cutoffDate), dates), 1, 'last');
            if isempty(animalCutoff)
                animalCutoff = 0;
            end
%         end

        % Fill only up to cutoff, rest stays NaN
        trimLen              = min(animalCutoff, length(go));
        allGo(row, 1:trimLen)   = go(1:trimLen);

        trimLen              = min(animalCutoff, length(nogo));
        allNogo(row, 1:trimLen) = nogo(1:trimLen);
    end
end

%% =====================================================
%  Clean: replace zeros with NaN

allGo(allGo == 0)     = NaN;
allNogo(allNogo == 0) = NaN;
%% =====================================================
%  Inspect: valid sessions per animal
%% =====================================================
fprintf('\nValid sessions per animal:\n');
fprintf('%-5s %-12s %-10s %-15s\n', 'Row', 'Cohort', 'Animal', 'Valid Sessions');
fprintf('%s\n', repmat('-', 1, 45));
for r = 1:size(allGo, 1)
    nValid = sum(~isnan(allGo(r,:)));
    fprintf('%-5d %-12s %-10s %d\n', r, rowInfo(r).Cohort, rowInfo(r).Animal, nValid);
end

%% =====================================================
%   Inspect: outliers in allGo

threshold_low  = 0.2;  % below 20%
threshold_high = 1.0;  % above 100% — impossible

[rowIdx, colIdx] = find(allGo < threshold_low | allGo > threshold_high);

fprintf('\nOutliers in allGo:\n');
fprintf('%-5s %-12s %-10s %-15s %-10s\n', 'Row', 'Cohort', 'Animal', 'Date', 'Value');
fprintf('%s\n', repmat('-', 1, 55));
for i = 1:length(rowIdx)
    r          = rowIdx(i);
    col        = colIdx(i);
    cohortName = rowInfo(r).Cohort;
    ratID      = rowInfo(r).Animal;
    dates      = Results.(cohortName).(ratID).Dates;
    if col <= length(dates)
        dateStr = dates{col};
    else
        dateStr = 'beyond dates';
    end
    fprintf('%-5d %-12s %-10s %-15s %-10.3f\n', r, cohortName, ratID, dateStr, allGo(r, col));
end

%% =====================================================
%  Compute mean + SEM across animals per session

MeanGo_combined   = mean(allGo,   1, 'omitnan') * 100;
SEMGo_combined    = std(allGo,    0, 1, 'omitnan') ./ sqrt(sum(~isnan(allGo),   1)) * 100;
MeanNogo_combined = mean(allNogo, 1, 'omitnan') * 100;
SEMNogo_combined  = std(allNogo,  0, 1, 'omitnan') ./ sqrt(sum(~isnan(allNogo), 1)) * 100;

sessions = (1:size(allGo, 2))';

%% =====================================================
%  Go / NoGo across sessions plot

green = [0.3608 0.7725 0.3020];
red   = [0.8157 0.0078 0.0078];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HOW MANY SESSIONS TO INCLUDE
% Find max session with most animals still included
fprintf('\nSession coverage:\n');
fprintf('%-12s %-20s\n', 'Session', 'N animals with data');
fprintf('%s\n', repmat('-', 1, 35));

nAnimalsPerSession = sum(~isnan(allGo), 1);  % how many animals have data at each session

% Print where coverage drops
prev = nAnimalsPerSession(1);
for s = 1:length(nAnimalsPerSession)
    if nAnimalsPerSession(s) ~= prev || s == 1
        fprintf('Session %3d: %d animals\n', s, nAnimalsPerSession(s));
        prev = nAnimalsPerSession(s);
    end
end
%%
%Gives Session  78: 8 animals
lastGoodSession = 129 ;

% Trim to lastGoodSession
validGo   = ~isnan(MeanGo_combined(1:lastGoodSession))   & ~isnan(SEMGo_combined(1:lastGoodSession));
validNogo = ~isnan(MeanNogo_combined(1:lastGoodSession)) & ~isnan(SEMNogo_combined(1:lastGoodSession));

sessGo   = sessions(validGo);
sessNogo = sessions(validNogo);

figure;
hold on;

% Shaded SEM — NoGo
fill([sessNogo; flipud(sessNogo)], ...
     [MeanNogo_combined(validNogo)' + SEMNogo_combined(validNogo)'; ...
      flipud(MeanNogo_combined(validNogo)' - SEMNogo_combined(validNogo)')], ...
     red, 'FaceAlpha', 0.3, 'EdgeColor', 'none');

% Shaded SEM — Go
fill([sessGo; flipud(sessGo)], ...
     [MeanGo_combined(validGo)' + SEMGo_combined(validGo)'; ...
      flipud(MeanGo_combined(validGo)' - SEMGo_combined(validGo)')], ...
     green, 'FaceAlpha', 0.3, 'EdgeColor', 'none');

% Mean lines
plot(sessGo,   MeanGo_combined(validGo),    '-', 'Color', green, 'LineWidth', 1);
plot(sessNogo, MeanNogo_combined(validNogo), '-', 'Color', red,   'LineWidth', 1);

% Top and bottom SEM border lines — Go
plot(sessGo, MeanGo_combined(validGo)   + SEMGo_combined(validGo),   '-', 'Color', green, 'LineWidth', 0.3);
plot(sessGo, MeanGo_combined(validGo)   - SEMGo_combined(validGo),   '-', 'Color', green, 'LineWidth', 0.3);

% Top and bottom SEM border lines — NoGo
plot(sessNogo, MeanNogo_combined(validNogo) + SEMNogo_combined(validNogo), '-', 'Color', red, 'LineWidth', 0.5);
plot(sessNogo, MeanNogo_combined(validNogo) - SEMNogo_combined(validNogo), '-', 'Color', red, 'LineWidth', 0.5);


ylim([0 100]);
xlim([1 lastGoodSession]);
xlabel('Session Number', 'FontSize', 12);
ylabel('Performance (%)', 'FontSize', 12);
%legend({'NoGo', 'Go'}, 'Location', 'best', 'FontSize', 11);
title(sprintf('Go / NoGo Performance — All Animals, Both Cohorts (%d sessions)', lastGoodSession), 'FontSize', 13);
set(gca, 'FontSize', 11, 'Box', 'off');
hold off;

%%
figName = 'MeanSEM_Performance_GoNogo_maxDates2';

saveas(gcf, fullfile(saveDir, [figName, '.fig']));   
saveas(gcf, fullfile(saveDir, [figName, '.png']));   
saveas(gcf, fullfile(saveDir, [figName, '.eps']));   
saveas(gcf, fullfile(saveDir, [figName, '.pdf'])); 
%%
%==============================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
maxOmitSess = 0;
for c = 1:length(CohortNames)
    cohortName = CohortNames{c};
    animalList = Config.(cohortName).Animals;
    for a = 1:length(animalList)
        ratID  = animalList(a).ID;
        omit1  = animalList(a).Date_Omit1;
        omit2  = animalList(a).Date_Omit2;
        dates  = Results.(cohortName).(ratID).Dates;

        if isempty(omit1) || isempty(omit2)
            continue;
        end

        idx1 = find(cellfun(@(d) str2double(d(1:8)) >= str2double(omit1), dates), 1, 'first');
        idx2 = find(cellfun(@(d) str2double(d(1:8)) <= str2double(omit2), dates), 1, 'last');

        if ~isempty(idx1) && ~isempty(idx2) && idx2 >= idx1
            maxOmitSess = max(maxOmitSess, idx2 - idx1 + 1);
        end
    end
end

% Preallocate matrices (animals x sessions)
allOmission_omit = NaN(totalAnimals, maxOmitSess);
allNogo_omit     = NaN(totalAnimals, maxOmitSess);
allDates_omit    = cell(totalAnimals, maxOmitSess);  % date strings for traceability

% Build lookup table for omission period
omitInfo = struct();
row = 0;

for c = 1:length(CohortNames)
    cohortName = CohortNames{c};
    animalList = Config.(cohortName).Animals;

    for a = 1:length(animalList)
           row    = row + 1;  % always increment
        ratID  = animalList(a).ID;
        omit1  = animalList(a).Date_Omit1;
        omit2  = animalList(a).Date_Omit2;
        dates  = Results.(cohortName).(ratID).Dates;
        go     = Results.(cohortName).(ratID).Go;
        nogo   = Results.(cohortName).(ratID).Nogo;

    
        omitInfo(row).Cohort = cohortName;
        omitInfo(row).Animal = ratID;

        if isempty(omit1) || isempty(omit2)
            fprintf('Skipping %s %s — missing omission dates\n', cohortName, ratID);
            continue;
        end

        % Find session indices between omit1 and omit2 (inclusive)
        idx1 = find(cellfun(@(d) str2double(d(1:8)) >= str2double(omit1), dates), 1, 'first');
        idx2 = find(cellfun(@(d) str2double(d(1:8)) <= str2double(omit2), dates), 1, 'last');

        if isempty(idx1) || isempty(idx2) || idx2 < idx1
            fprintf('Skipping %s %s — omission dates not found in sessions\n', cohortName, ratID);
            continue;
        end

        nSess   = idx2 - idx1 + 1;
        omitIdx = idx1:idx2;

        % Fill matrices
        allOmission_omit(row, 1:nSess) = 1 - go(omitIdx);    % omission = 1 - Go
        allNogo_omit(row,     1:nSess) = nogo(omitIdx);
        allDates_omit(row,    1:nSess) = dates(omitIdx);

        fprintf('%s %s | Omit1: %s (idx %d) → Omit2: %s (idx %d) | %d sessions\n', ...
            cohortName, ratID, omit1, idx1, omit2, idx2, nSess);
    end
end

% Replace zeros with NaN
allOmission_omit(allOmission_omit == 0) = NaN;
allNogo_omit(allNogo_omit == 0)         = NaN;



%% =====================================================
%  Plot individual animal performances
%% =====================================================
green = [0.3608 0.7725 0.3020];
red   = [0.8157 0.0078 0.0078];

%%
figure;
hold on;

for  r = 1:totalAnimals
    if strcmp(omitInfo(r).Animal, 'SEP')
        continue;
    end
   
    omData   = allOmission_omit(r, :);
    nogoData = allNogo_omit(r, :);
    
    validOm   = find(~isnan(omData));
    validNogo = find(~isnan(nogoData));
    
    if isempty(validOm) && isempty(validNogo)
        continue;
    end
    
    if ~isempty(validOm)
        plot(validOm, omData(validOm) * 100, '-', ...
            'Color', green, 'LineWidth', 1.5, ...
            'HandleVisibility', 'off');
    end
    
    if ~isempty(validNogo)
        plot(validNogo, nogoData(validNogo) * 100, '-', ...
            'Color', red, 'LineWidth', 1.5, ...
            'HandleVisibility', 'off');
    end
end

% Dummy plots for legend only
plot(nan, nan, '-', 'Color', green, 'LineWidth', 1, 'DisplayName', 'DRO');
plot(nan, nan, '-', 'Color', red,   'LineWidth', 1, 'DisplayName', 'NoGo');

ylim([0 100]);
xlabel('Session Number', 'FontSize', 12);
ylabel('Performance (%)', 'FontSize', 12);
%legend('Location', 'best', 'FontSize', 11);
title('DRO & NoGo Performance — Individual Animals', 'FontSize', 13);
set(gca, 'FontSize', 11, 'Box', 'off');
hold off;


%%
figName = 'Individuals_Performance_DRO_Dates';

saveas(gcf, fullfile(saveDir, [figName, '.fig']));   
saveas(gcf, fullfile(saveDir, [figName, '.png']));   
saveas(gcf, fullfile(saveDir, [figName, '.eps']));   
saveas(gcf, fullfile(saveDir, [figName, '.pdf'])); 
