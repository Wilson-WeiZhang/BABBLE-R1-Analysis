%% Compare IA Alpha values: cond=1 only vs cond=1:3
clc; clear all;

basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';

fprintf('==========================================================\n');
fprintf('Comparing IA Alpha values: cond=1 only vs cond=1:3\n');
fprintf('==========================================================\n\n');

%% Load cond=1:3 data
fprintf('Loading cond=1:3 data (dataGPDC.mat)...\n');
load([basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2/dataGPDC.mat'], 'data');
data_all = data;
fprintf('  Data loaded: %d samples\n\n', size(data_all, 1));

%% Load cond=1 only data
fprintf('Loading cond=1 only data...\n');
load([basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/data_GPDC_cond1_only.mat'], 'data');
data_cond1 = data;
fprintf('  Data loaded: %d samples\n\n', size(data_cond1, 1));

%% Extract IA alpha for both datasets
% IA alpha columns: 892-972 (within the GPDC features starting at column 10)
% Total features: 972 (243*4)
% IA is the 4th block: columns 729-972 (243 features)
% Alpha is 3rd band within IA: columns 163-243 within IA block
% So IA alpha is columns: 729 + 162 + 1 : 729 + 243 = 892:972
% But features start at column 10, so overall columns are 10+891:10+971 = 901:981

ia_alpha_cols = 892:972;  % Within GPDC features
ia_alpha_all = data_all(:, 9 + ia_alpha_cols);
ia_alpha_cond1 = data_cond1(:, 9 + ia_alpha_cols);

fprintf('==========================================================\n');
fprintf('IA Alpha Statistics\n');
fprintf('==========================================================\n');

fprintf('\nCond=1:3 (All conditions):\n');
fprintf('  Sample size: %d\n', size(data_all, 1));
fprintf('  IA Alpha mean: %.6f\n', nanmean(ia_alpha_all(:)));
fprintf('  IA Alpha std: %.6f\n', nanstd(ia_alpha_all(:)));
fprintf('  IA Alpha median: %.6f\n', nanmedian(ia_alpha_all(:)));

fprintf('\nCond=1 only:\n');
fprintf('  Sample size: %d\n', size(data_cond1, 1));
fprintf('  IA Alpha mean: %.6f\n', nanmean(ia_alpha_cond1(:)));
fprintf('  IA Alpha std: %.6f\n', nanstd(ia_alpha_cond1(:)));
fprintf('  IA Alpha median: %.6f\n', nanmedian(ia_alpha_cond1(:)));

fprintf('\nDifference:\n');
fprintf('  Mean difference: %.6f\n', nanmean(ia_alpha_cond1(:)) - nanmean(ia_alpha_all(:)));
fprintf('  Ratio (cond1/all): %.4f\n', nanmean(ia_alpha_cond1(:)) / nanmean(ia_alpha_all(:)));

%% Break down by condition in the all-conditions dataset
fprintf('\n==========================================================\n');
fprintf('Breakdown by Condition (from cond=1:3 dataset)\n');
fprintf('==========================================================\n');

cond_col = 6;  % Condition column
for c = 1:3
    cond_idx = data_all(:, cond_col) == c;
    ia_alpha_this_cond = data_all(cond_idx, 9 + ia_alpha_cols);

    fprintf('\nCondition %d:\n', c);
    fprintf('  Sample size: %d\n', sum(cond_idx));
    fprintf('  IA Alpha mean: %.6f\n', nanmean(ia_alpha_this_cond(:)));
    fprintf('  IA Alpha std: %.6f\n', nanstd(ia_alpha_this_cond(:)));
    fprintf('  IA Alpha median: %.6f\n', nanmedian(ia_alpha_this_cond(:)));
end

%% Compare with surrogate
fprintf('\n==========================================================\n');
fprintf('Check Surrogate Data\n');
fprintf('==========================================================\n');

% Check if surrogate data exists for both
surr_file_all = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2/data_read_surr_gpdc2.mat'];
surr_file_cond1 = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/data_GPDC_cond1_only.mat'];

if exist(surr_file_all, 'file')
    fprintf('\nLoading surrogate data for cond=1:3...\n');
    load(surr_file_all, 'data_surr');
    data_surr_all = data_surr;

    % CORRECT METHOD: Calculate mean for each surrogate, then average across surrogates
    n_surr = min(100, length(data_surr_all));
    surr_means = zeros(n_surr, 1);
    for s = 1:n_surr
        surr_ia_this = data_surr_all{s}(:, 9 + ia_alpha_cols);
        surr_means(s) = nanmean(surr_ia_this(:));
    end

    fprintf('  Surrogate IA Alpha mean (correct): %.6f\n', nanmean(surr_means));
    fprintf('  Real/Surrogate ratio: %.4f\n', nanmean(ia_alpha_all(:)) / nanmean(surr_means));

    if nanmean(ia_alpha_all(:)) < nanmean(surr_means)
        fprintf('  ✓ Real < Surrogate (as expected for IA)\n');
    else
        fprintf('  ✗ Real > Surrogate (unexpected for IA)\n');
    end
end

% Load cond=1 surrogate from the same file
fprintf('\nLoading surrogate data for cond=1 only...\n');
load(surr_file_cond1, 'data_surr');
data_surr_cond1 = data_surr;

% CORRECT METHOD: Calculate mean for each surrogate, then average across surrogates
n_surr = min(100, length(data_surr_cond1));
surr_means_cond1 = zeros(n_surr, 1);
for s = 1:n_surr
    surr_ia_this = data_surr_cond1{s}(:, 9 + ia_alpha_cols);
    surr_means_cond1(s) = nanmean(surr_ia_this(:));
end

fprintf('  Surrogate IA Alpha mean (correct): %.6f\n', nanmean(surr_means_cond1));
fprintf('  Real/Surrogate ratio: %.4f\n', nanmean(ia_alpha_cond1(:)) / nanmean(surr_means_cond1));

if nanmean(ia_alpha_cond1(:)) < nanmean(surr_means_cond1)
    fprintf('  ✓ Real < Surrogate (as expected for IA)\n');
else
    fprintf('  ✗ Real > Surrogate (unexpected for IA)\n');
end

fprintf('\n==========================================================\n');
fprintf('Summary\n');
fprintf('==========================================================\n');
fprintf('The IA (Infant-to-Adult) should be close to or below surrogate\n');
fprintf('because the adult audio is pre-recorded and cannot be influenced\n');
fprintf('by the infant.\n\n');

fprintf('If cond=1 shows IA > surrogate but cond=1:3 shows IA < surrogate,\n');
fprintf('this suggests that conditions 2 and/or 3 have lower IA values\n');
fprintf('that pull down the overall mean.\n');
fprintf('==========================================================\n\n');
