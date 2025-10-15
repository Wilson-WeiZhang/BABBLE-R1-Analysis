%% Debug Surrogate IA Values
clc; clear all;

basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';

fprintf('==========================================================\n');
fprintf('Debugging Surrogate IA Alpha Values\n');
fprintf('==========================================================\n\n');

%% Check one surrogate file directly
fprintf('Loading first surrogate file directly...\n');
surr_path = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDC_cond1_SET/GPDC1/'];

% Try UK_101
test_file = [surr_path, 'UK_101_GPDC.mat'];
if exist(test_file, 'file')
    fprintf('  Loading %s\n', test_file);
    load(test_file, 'II', 'AA', 'AI', 'IA');

    fprintf('\n  Structure of loaded data:\n');
    fprintf('  II size: [%d, %d, %d]\n', size(II,1), size(II,2), size(II,3));
    fprintf('  AA size: [%d, %d, %d]\n', size(AA,1), size(AA,2), size(AA,3));
    fprintf('  AI size: [%d, %d, %d]\n', size(AI,1), size(AI,2), size(AI,3));
    fprintf('  IA size: [%d, %d, %d]\n', size(IA,1), size(IA,2), size(IA,3));

    % Check block=1, cond=1, band=3 (alpha)
    if size(II,1) >= 1 && size(II,2) >= 1 && size(II,3) >= 3
        fprintf('\n  Block 1, Cond 1, Band 3 (Alpha):\n');

        if ~isempty(II{1,1,3})
            fprintf('    II alpha: size=%dx%d, mean=%.6f\n', size(II{1,1,3},1), size(II{1,1,3},2), nanmean(II{1,1,3}(:)));
        end

        if ~isempty(AA{1,1,3})
            fprintf('    AA alpha: size=%dx%d, mean=%.6f\n', size(AA{1,1,3},1), size(AA{1,1,3},2), nanmean(AA{1,1,3}(:)));
        end

        if ~isempty(AI{1,1,3})
            fprintf('    AI alpha: size=%dx%d, mean=%.6f\n', size(AI{1,1,3},1), size(AI{1,1,3},2), nanmean(AI{1,1,3}(:)));
        end

        if ~isempty(IA{1,1,3})
            fprintf('    IA alpha: size=%dx%d, mean=%.6f\n', size(IA{1,1,3},1), size(IA{1,1,3},2), nanmean(IA{1,1,3}(:)));
            fprintf('    IA alpha range: [%.6f, %.6f]\n', min(IA{1,1,3}(:)), max(IA{1,1,3}(:)));
        end
    end
else
    fprintf('  File not found: %s\n', test_file);
end

%% Compare with real data
fprintf('\n==========================================================\n');
fprintf('Comparing with Real Data\n');
fprintf('==========================================================\n');

real_path = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/GPDC3_cond1_only/'];
test_file_real = [real_path, 'UK_101_GPDC.mat'];

if exist(test_file_real, 'file')
    fprintf('  Loading %s\n', test_file_real);
    load(test_file_real, 'II', 'AA', 'AI', 'IA');

    % Check block=1, cond=1, band=3 (alpha)
    if size(II,1) >= 1 && size(II,2) >= 1 && size(II,3) >= 3
        fprintf('\n  Block 1, Cond 1, Band 3 (Alpha):\n');

        if ~isempty(II{1,1,3})
            fprintf('    II alpha: size=%dx%d, mean=%.6f\n', size(II{1,1,3},1), size(II{1,1,3},2), nanmean(II{1,1,3}(:)));
        end

        if ~isempty(AA{1,1,3})
            fprintf('    AA alpha: size=%dx%d, mean=%.6f\n', size(AA{1,1,3},1), size(AA{1,1,3},2), nanmean(AA{1,1,3}(:)));
        end

        if ~isempty(AI{1,1,3})
            fprintf('    AI alpha: size=%dx%d, mean=%.6f\n', size(AI{1,1,3},1), size(AI{1,1,3},2), nanmean(AI{1,1,3}(:)));
        end

        if ~isempty(IA{1,1,3})
            fprintf('    IA alpha: size=%dx%d, mean=%.6f\n', size(IA{1,1,3},1), size(IA{1,1,3},2), nanmean(IA{1,1,3}(:)));
            fprintf('    IA alpha range: [%.6f, %.6f]\n', min(IA{1,1,3}(:)), max(IA{1,1,3}(:)));
        end
    end
else
    fprintf('  File not found: %s\n', test_file_real);
end

%% Check the loaded data from fs_R1_GPDC_cond1_read.m
fprintf('\n==========================================================\n');
fprintf('Checking Loaded Data from fs_R1_GPDC_cond1_read.m\n');
fprintf('==========================================================\n');

data_file = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/data_GPDC_cond1_only.mat'];
if exist(data_file, 'file')
    load(data_file, 'data', 'data_surr');

    fprintf('\n  Real data:\n');
    fprintf('    Samples: %d\n', size(data, 1));
    fprintf('    Features: %d\n', size(data, 2));

    % Extract IA alpha from real data
    ia_alpha_cols = 892:972;  % IA alpha within GPDC features
    real_ia_alpha = data(:, 9 + ia_alpha_cols);
    fprintf('    IA alpha mean: %.6f\n', nanmean(real_ia_alpha(:)));
    fprintf('    IA alpha range: [%.6f, %.6f]\n', min(real_ia_alpha(:)), max(real_ia_alpha(:)));

    fprintf('\n  Surrogate data:\n');
    fprintf('    Number of surrogates: %d\n', length(data_surr));

    if ~isempty(data_surr)
        fprintf('    Surrogate 1 samples: %d\n', size(data_surr{1}, 1));
        fprintf('    Surrogate 1 features: %d\n', size(data_surr{1}, 2));

        % Extract IA alpha from surrogate
        surr1_ia_alpha = data_surr{1}(:, 9 + ia_alpha_cols);
        fprintf('    Surrogate 1 IA alpha mean: %.6f\n', nanmean(surr1_ia_alpha(:)));
        fprintf('    Surrogate 1 IA alpha range: [%.6f, %.6f]\n', min(surr1_ia_alpha(:)), max(surr1_ia_alpha(:)));

        % Check if there are many zeros
        zero_count = sum(surr1_ia_alpha(:) == 0);
        total_count = numel(surr1_ia_alpha);
        fprintf('    Zeros in surrogate 1 IA alpha: %d / %d (%.2f%%)\n', zero_count, total_count, 100*zero_count/total_count);
    end
end

fprintf('\n==========================================================\n\n');
