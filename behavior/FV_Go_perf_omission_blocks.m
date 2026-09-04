%%%Script to evaluate the Go performance during Omission GNG manuscript
%Using Sergio's structuring
%FV 23-1-2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

% %%% load the default main omission trials configuration
cfg = gonogo_mainconfig('bla');                                             % read main configuration
cfg.file.file_str = 'trials_o*.mat';                                        % indicate file name coding
om_trials = proj_organigram(cfg.file);                                      % create file list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%om_trials([9 10]) = [];                                                     % removng Sep because of its low perfomance


for ifile = 1 : length(om_trials)
    fprintf('Processing file %i ...',ifile)

    load(om_trials(ifile).file_path)

    totalNoGoTrials = sum([trials(1:end).nogo]);
    totalTrials = size (trials,2);
    totalGoTrials = totalTrials - totalNoGoTrials;
    blockSize = 10; % Number of trials in each block

    for i = 1:length(trials)
        trials(i).originalIdx = i;
    end

    trialsGo = trials([trials.nogo] == 0); % Remove nogo trials

    % Initialize
    percentageCorrectGo = zeros(1, floor(totalGoTrials/blockSize));
    trialNumbers = 1:blockSize:totalGoTrials;
    trialNumberAbove50 = 0;

    % Calculate percentage of correct go responses for each block
    for i = 1:length(percentageCorrectGo)
        startIdx = (i - 1) * blockSize + 1;
        endIdx = min(i * blockSize, totalGoTrials);

        nogoTrialsblock = sum([trialsGo(startIdx:endIdx).nogo])
        totalGoTrialsblock = blockSize - nogoTrialsblock

       
        correctGoCount = sum([trialsGo(startIdx:endIdx).nogo] == 0 & [trialsGo(startIdx:endIdx).reward] == 1);

        if totalGoTrialsblock > 0
            percentageCorrectGo(i) = (correctGoCount / totalGoTrialsblock) * 100;

            if percentageCorrectGo(i) > 50 && trialNumberAbove50 == 0  %first one above 50
                trialNumberAbove50 = trialsGo(startIdx).originalIdx;
            end
        else
            percentageCorrectGo(i) = 0; % Set to 0 if there are no go trials in the block
        end
    end

    if trialNumberAbove50 > 0
        fprintf('The trial number where go performance is >50%% is: %d\n', trialNumberAbove50);
    else
        fprintf('No block found where go performance is >50%%.\n');
    end

        area_name   = om_trials(ifile).area;
        animal_name = om_trials(ifile).rat;
        file_name   = ['Goperform_goblocks' om_trials(ifile).name(end-6:end-4) '.mat'];
        save_path   = [cfg.file.analysis 'processed_data\' area_name '\' animal_name '\' file_name];
        save_plot_path =  [cfg.file.analysis 'processed_data\' area_name '\' animal_name]; 
        
        save(save_path,'percentageCorrectGo','trialNumberAbove50')

        figure;
        plot( percentageCorrectGo, 'o-');
        xlabel('Trial Number Block (blocks of 10)');
        ylabel('Percentage Correct (Go Trials)');
        title('Learning Curve for Go Trials');
        ylim([0 100]);
        text(max((trialNumbers-2)/10), 100, sprintf('Trial: %d', trialNumberAbove50), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');


    plot_file_name = ['Goperform_goblocks' om_trials(ifile).name(end-6:end-4) '_plot.png'];
    saveas(gcf, fullfile(save_plot_path, plot_file_name)); % Save the plot

 
end %ifile (per session/animal)
    %%