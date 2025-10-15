%% ========================================================================
%  fs_R1_GPDC_cond1_read.m
%  ========================================================================
%
%  PURPOSE:
%  Read and organize GPDC data (real and surrogate) for condition 1 only
%
%  CORRESPONDS TO:
%  - Step 4 of integrated analysis
%  - Loads behavioral data and GPDC results
%  - Organizes into final data table for statistical analysis
%
%  INPUT:
%  - Behavioral data from behaviour2.5sd.xlsx
%  - Real GPDC from GPDC3_cond1_only/ folder
%  - Surrogate GPDC from surrGPDC_cond1_SET/ folders
%
%  OUTPUT:
%  - data: Matrix with behavioral variables + GPDC features (cond=1 only)
%  - data_surr: Cell array of surrogate data matrices
%  - titles: Column names for the data matrix
%  - Saved to: data_GPDC_cond1_only.mat
%
%  ========================================================================

clc
clear all

fprintf('==========================================================\n');
fprintf('STEP 4: Reading and organizing data for cond=1 only\n');
fprintf('==========================================================\n\n');

%% Configuration
basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';
type = 'GPDC';

%% Load behavioral data
fprintf('Loading behavioral data...\n');
[a, b] = xlsread([basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/table/behaviour2.5sd.xlsx']);

% Remove samples with NaN in learning column
a(find(sum(isnan(a(:, 7)), 2) > 0), :) = [];

% Extract behavioral variables
AGE = a(:, 3);
SEX = a(:, 4);
SEX = categorical(SEX);
COUNTRY = a(:, 1);
COUNTRY = categorical(COUNTRY);
blocks = a(:, 5);
blocks = categorical(blocks);
CONDGROUP = a(:, 6);
CONDGROUP = categorical(CONDGROUP);
learning = a(:, 7);
atten = a(:, 9);
ID = a(:, 2);
ID = categorical(ID);

fprintf('Behavioral data loaded: %d samples\n\n', size(a, 1));

%% Read real GPDC data (COND=1 ONLY)
fprintf('Reading real GPDC data for cond=1...\n');

data_real = [];
count = 0;

for i = 1:size(a, 1)
    if ~isnan(a(i, 7))
        num = a(i, 2);

        % Skip excluded participants
        if ismember(num, [1113, 1136, 1112, 1116, 2112, 2118, 2119]) == 0
            num_str = num2str(a(i, 2));
            num_str = num_str(2:4);

            % Load GPDC data
            if a(i, 1) == 1
                gpdc_file = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/', type, '3_cond1_only/UK_', num_str, '_GPDC.mat'];
            else
                gpdc_file = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/', type, '3_cond1_only/SG_', num_str, '_GPDC.mat'];
            end

            if exist(gpdc_file, 'file')
                load(gpdc_file, 'II', 'AI', 'AA', 'IA');

                try
                    block = a(i, 5);
                    cond = a(i, 6);

                    % ONLY PROCESS IF cond==1
                    if cond == 1 && ~isempty(II) && size(II, 1) >= block && size(II, 2) >= cond
                        % Extract GPDC matrices for 3 frequency bands
                        ii1 = []; ii2 = []; ii3 = [];
                        aa1 = []; aa2 = []; aa3 = [];
                        ai1 = []; ai2 = []; ai3 = [];
                        ia1 = []; ia2 = []; ia3 = [];

                        if ~isempty(II{block, cond, 1}), ii1 = II{block, cond, 1}(:)'; end
                        if ~isempty(II{block, cond, 2}), ii2 = II{block, cond, 2}(:)'; end
                        if ~isempty(II{block, cond, 3}), ii3 = II{block, cond, 3}(:)'; end

                        if ~isempty(AA{block, cond, 1}), aa1 = AA{block, cond, 1}(:)'; end
                        if ~isempty(AA{block, cond, 2}), aa2 = AA{block, cond, 2}(:)'; end
                        if ~isempty(AA{block, cond, 3}), aa3 = AA{block, cond, 3}(:)'; end

                        if ~isempty(AI{block, cond, 1}), ai1 = AI{block, cond, 1}(:)'; end
                        if ~isempty(AI{block, cond, 2}), ai2 = AI{block, cond, 2}(:)'; end
                        if ~isempty(AI{block, cond, 3}), ai3 = AI{block, cond, 3}(:)'; end

                        if ~isempty(IA{block, cond, 1}), ia1 = IA{block, cond, 1}(:)'; end
                        if ~isempty(IA{block, cond, 2}), ia2 = IA{block, cond, 2}(:)'; end
                        if ~isempty(IA{block, cond, 3}), ia3 = IA{block, cond, 3}(:)'; end

                        % Check alpha band (band 3) like original code
                        if ~isempty(ii3)
                            data_real = [data_real; [a(i, 1:9), ii1, ii2, ii3, aa1, aa2, aa3, ai1, ai2, ai3, ia1, ia2, ia3]];
                            count = count + 1;
                        end
                    end
                catch ME
                    fprintf('  Warning: Error processing participant %d: %s\n', num, ME.message);
                end
            else
                fprintf('  Warning: File not found for participant %d\n', num);
            end
        end
    end
end

fprintf('Real GPDC data loaded: %d samples (cond=1 only)\n\n', count);

%% Read surrogate GPDC data (COND=1 ONLY)
fprintf('Reading surrogate GPDC data for cond=1...\n');

% Check how many surrogates are available
surrPathPrefix = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDCSET5/'];

% Find available surrogate folders (may not be sequential)
valid_surr_indices = [];
for surrIdx = 1:1000
    surrPath = [surrPathPrefix, num2str(surrIdx)];
    if exist(surrPath, 'dir')
        files = dir(fullfile(surrPath, '*.mat'));
        if length(files) >= 42
            valid_surr_indices = [valid_surr_indices, surrIdx];
        end
    end
end

fprintf('Found %d complete surrogate datasets (indices may be non-sequential)\n', length(valid_surr_indices));

% Load surrogate data
data_surr = cell(length(valid_surr_indices), 1);
valid_surr_count = 0;

for idx = 1:length(valid_surr_indices)
    surrIdx = valid_surr_indices(idx);
    if mod(idx, 100) == 0
        fprintf('  Loading surrogate %d/%d (index %d)...\n', idx, length(valid_surr_indices), surrIdx);
    end

    surrPath = [surrPathPrefix, num2str(surrIdx)];
    temp_surr = zeros(size(data_real));
    count_surr = 0;

    for i = 1:size(a, 1)
        if ~isnan(a(i, 7))
            num = a(i, 2);

            if ismember(num, [1112, 1116, 2112, 2118, 2119]) == 0
                num_str = num2str(a(i, 2));
                num_str = num_str(2:4);

                if a(i, 1) == 1
                    gpdc_file = fullfile(surrPath, sprintf('UK_%s_PDC.mat', num_str));
                else
                    gpdc_file = fullfile(surrPath, sprintf('SG_%s_PDC.mat', num_str));
                end

                if exist(gpdc_file, 'file')
                    load(gpdc_file, 'II', 'AI', 'AA', 'IA');

                    try
                        block = a(i, 5);
                        cond = a(i, 6);

                        % ONLY PROCESS IF cond==1
                        if cond == 1 && ~isempty(II) && size(II, 1) >= block && size(II, 2) >= cond
                            ii1 = []; ii2 = []; ii3 = [];
                            aa1 = []; aa2 = []; aa3 = [];
                            ai1 = []; ai2 = []; ai3 = [];
                            ia1 = []; ia2 = []; ia3 = [];

                            if ~isempty(II{block, cond, 1}), ii1 = II{block, cond, 1}(:)'; end
                            if ~isempty(II{block, cond, 2}), ii2 = II{block, cond, 2}(:)'; end
                            if ~isempty(II{block, cond, 3}), ii3 = II{block, cond, 3}(:)'; end

                            if ~isempty(AA{block, cond, 1}), aa1 = AA{block, cond, 1}(:)'; end
                            if ~isempty(AA{block, cond, 2}), aa2 = AA{block, cond, 2}(:)'; end
                            if ~isempty(AA{block, cond, 3}), aa3 = AA{block, cond, 3}(:)'; end

                            if ~isempty(AI{block, cond, 1}), ai1 = AI{block, cond, 1}(:)'; end
                            if ~isempty(AI{block, cond, 2}), ai2 = AI{block, cond, 2}(:)'; end
                            if ~isempty(AI{block, cond, 3}), ai3 = AI{block, cond, 3}(:)'; end

                            if ~isempty(IA{block, cond, 1}), ia1 = IA{block, cond, 1}(:)'; end
                            if ~isempty(IA{block, cond, 2}), ia2 = IA{block, cond, 2}(:)'; end
                            if ~isempty(IA{block, cond, 3}), ia3 = IA{block, cond, 3}(:)'; end

                            % Check alpha band (band 3) like original code
                            if ~isempty(ii3)
                                count_surr = count_surr + 1;
                                temp_surr(count_surr, :) = [a(i, 1:9), ii1, ii2, ii3, aa1, aa2, aa3, ai1, ai2, ai3, ia1, ia2, ia3];
                            end
                        end
                    end
                end
            end
        end
    end

    if count_surr > 0
        valid_surr_count = valid_surr_count + 1;
        data_surr{valid_surr_count} = temp_surr(1:count_surr, :);
    end
    idx
end

% Remove empty cells
data_surr = data_surr(1:valid_surr_count);

fprintf('Surrogate GPDC data loaded: %d valid surrogate datasets\n\n', valid_surr_count);

%% Generate column titles
nodes = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
frequencyBands = {'Delta', 'Theta', 'Alpha'};
connectionTypes = {'II', 'AA', 'AI', 'IA'};

connectionTitles = {};
for conn = 1:length(connectionTypes)
    for freq = 1:length(frequencyBands)
        for dest = 1:length(nodes)
            for src = 1:length(nodes)
                connectionTitles{end+1} = sprintf('%s_%s_%s_to_%s', connectionTypes{conn}, frequencyBands{freq}, nodes{dest}, nodes{src});
            end
        end
    end
end

titles = ['Country', 'ID', 'Age', 'Sex', 'Block', 'Cond', 'Learning', 'LEARN', 'Atten', connectionTitles];

%% Rename for consistency with original code
data = data_real;

%% Save final data
fprintf('Saving final data...\n');
cd([basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/']);
save(['data_', type, '_cond1_only.mat'], 'data', 'data_surr', 'titles', '-v7.3');

fprintf('==========================================================\n');
fprintf('Data organization completed!\n');
fprintf('Output saved to: data_%s_cond1_only.mat\n', type);
fprintf('  Real data: %d samples (cond=1 only)\n', size(data, 1));
fprintf('  Surrogate data: %d datasets\n', length(data_surr));
fprintf('==========================================================\n\n');
