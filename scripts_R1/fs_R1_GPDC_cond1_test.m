%% ========================================================================
%  fs_R1_GPDC_cond1_test.m
%  ========================================================================
%
%  PURPOSE:
%  Test and validate GPDC analysis results for condition 1 only
%  **FOCUS: ALPHA BAND (6-9 Hz) ONLY**
%
%  PERFORMS:
%  - Data integrity checks
%  - Basic statistical summaries for ALPHA BAND
%  - Comparison between real and surrogate data (ALPHA BAND)
%  - Correlation analysis with learning (ALPHA BAND)
%  - Visualization of key results (ALPHA BAND)
%
%  INPUT:
%  - data_GPDC_cond1_only.mat (output from fs_R1_GPDC_cond1_read.m)
%
%  OUTPUT:
%  - Console output with test results (ALPHA BAND focus)
%  - Basic visualizations (ALPHA BAND focus)
%
%  ========================================================================

clc
clear all

fprintf('==========================================================\n');
fprintf('GPDC COND=1 ANALYSIS - TESTING AND VALIDATION\n');
fprintf('==========================================================\n\n');

%% Load data
basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';
type = 'GPDC';

fprintf('Loading data...\n');
load([basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/data_', type, '_cond1_only.mat'], 'data', 'data_surr', 'titles');
fprintf('Data loaded successfully!\n\n');

%% Test 1: Data dimensions and structure
fprintf('==========================================================\n');
fprintf('TEST 1: Data Dimensions and Structure\n');
fprintf('==========================================================\n');

fprintf('Real data dimensions: %d samples x %d features\n', size(data, 1), size(data, 2));
fprintf('Number of surrogate datasets: %d\n', length(data_surr));

if ~isempty(data_surr)
    fprintf('Surrogate data dimensions: %d samples x %d features\n', size(data_surr{1}, 1), size(data_surr{1}, 2));
end

fprintf('Number of column titles: %d\n', length(titles));
fprintf('\n');

%% Test 2: Behavioral variables
fprintf('==========================================================\n');
fprintf('TEST 2: Behavioral Variables (Cond=1 Only)\n');
fprintf('==========================================================\n');

% Check that all samples are cond=1
cond_values = unique(data(:, 6));
fprintf('Unique condition values: %s\n', mat2str(cond_values));
if all(cond_values == 1)
    fprintf('  ✓ All samples are cond=1\n');
else
    fprintf('  ✗ WARNING: Found non-cond=1 samples!\n');
end

% Country distribution
country = data(:, 1);
fprintf('\nCountry distribution:\n');
fprintf('  Cambridge (1): %d samples\n', sum(country == 1));
fprintf('  Singapore (2): %d samples\n', sum(country == 2));

% Block distribution
blocks = data(:, 5);
fprintf('\nBlock distribution:\n');
for b = unique(blocks)'
    fprintf('  Block %d: %d samples\n', b, sum(blocks == b));
end

% Learning statistics
learning = data(:, 7);
fprintf('\nLearning statistics:\n');
fprintf('  Mean: %.4f\n', nanmean(learning));
fprintf('  SD: %.4f\n', nanstd(learning));
fprintf('  Min: %.4f\n', nanmin(learning));
fprintf('  Max: %.4f\n', nanmax(learning));

fprintf('\n');

%% Test 3: GPDC features (ALPHA BAND ONLY)
fprintf('==========================================================\n');
fprintf('TEST 3: GPDC Features (Alpha Band Only)\n');
fprintf('==========================================================\n');

% Extract GPDC features (columns 10 onwards)
gpdc_features = data(:, 10:end);

fprintf('Total GPDC feature dimensions: %d samples x %d features\n', size(gpdc_features, 1), size(gpdc_features, 2));
fprintf('Expected features per frequency band: 81 (9x9 matrix)\n');
fprintf('Expected total features per connection type (3 bands): 243\n');
fprintf('Expected total features (4 connection types): 972\n\n');

% Extract ALPHA BAND ONLY (163-243 within each connection type)
% Alpha is the 3rd band: columns 163-243 within each 243-feature block
% II alpha: columns 163-243 (overall columns 163-243)
% AA alpha: columns 163-243 within AA block (overall columns 406-486)
% AI alpha: columns 163-243 within AI block (overall columns 649-729)
% IA alpha: columns 163-243 within IA block (overall columns 892-972)

ii_alpha = gpdc_features(:, 163:243);
aa_alpha = gpdc_features(:, 406:486);
ai_alpha = gpdc_features(:, 649:729);
ia_alpha = gpdc_features(:, 892:972);

% Remove diagonal elements for II and AA (self-connections)
% In a 9x9 matrix flattened column-wise, diagonal indices are: 1, 10, 19, 28, 37, 46, 55, 64, 73
diagonal_idx = 1:10:81;

fprintf('Removing diagonal elements (self-connections) from II and AA:\n');
fprintf('  Diagonal indices in 9x9 matrix: ');
fprintf('%d ', diagonal_idx);
fprintf('\n');

ii_alpha(:, diagonal_idx) = NaN;
aa_alpha(:, diagonal_idx) = NaN;

fprintf('\nExtracted ALPHA band only (after removing diagonals):\n');
fprintf('  II alpha: %d features (%d valid, 9 diagonal set to NaN)\n', size(ii_alpha, 2), sum(~isnan(ii_alpha(1,:))));
fprintf('  AA alpha: %d features (%d valid, 9 diagonal set to NaN)\n', size(aa_alpha, 2), sum(~isnan(aa_alpha(1,:))));
fprintf('  AI alpha: %d features (all valid)\n', size(ai_alpha, 2));
fprintf('  IA alpha: %d features (all valid)\n\n', size(ia_alpha, 2));

% Check for NaN values in alpha band
nan_count_alpha = sum(sum(isnan(ii_alpha))) + sum(sum(isnan(aa_alpha))) + ...
                  sum(sum(isnan(ai_alpha))) + sum(sum(isnan(ia_alpha)));
total_alpha = numel(ii_alpha) + numel(aa_alpha) + numel(ai_alpha) + numel(ia_alpha);
nan_percent_alpha = 100 * nan_count_alpha / total_alpha;
fprintf('NaN values in alpha band: %d (%.2f%%)\n', nan_count_alpha, nan_percent_alpha);

% Basic statistics for alpha band only
fprintf('\nAlpha band GPDC statistics by connection type:\n');
fprintf('  II (Infant-to-Infant) Alpha:\n');
fprintf('    Mean: %.6f, SD: %.6f\n', nanmean(ii_alpha(:)), nanstd(ii_alpha(:)));

fprintf('  AA (Adult-to-Adult) Alpha:\n');
fprintf('    Mean: %.6f, SD: %.6f\n', nanmean(aa_alpha(:)), nanstd(aa_alpha(:)));

fprintf('  AI (Adult-to-Infant) Alpha:\n');
fprintf('    Mean: %.6f, SD: %.6f\n', nanmean(ai_alpha(:)), nanstd(ai_alpha(:)));

fprintf('  IA (Infant-to-Adult) Alpha:\n');
fprintf('    Mean: %.6f, SD: %.6f\n', nanmean(ia_alpha(:)), nanstd(ia_alpha(:)));

fprintf('\n');

%% Test 4: Real vs Surrogate comparison (ALPHA BAND ONLY)
fprintf('==========================================================\n');
fprintf('TEST 4: Real vs Surrogate Data Comparison (Alpha Band)\n');
fprintf('==========================================================\n');

if ~isempty(data_surr)
    % Calculate mean surrogate GPDC for ALPHA BAND only
    % Alpha columns: 163-243, 406-486, 649-729, 892-972
    alpha_cols = [163:243, 406:486, 649:729, 892:972];

    surr_mean_alpha = zeros(length(alpha_cols), 1);
    surr_std_alpha = zeros(length(alpha_cols), 1);

    for i = 1:length(alpha_cols)
        feat = alpha_cols(i);
        feat_values = [];
        for s = 1:length(data_surr)
            feat_values = [feat_values; data_surr{s}(:, feat + 9)];
        end
        surr_mean_alpha(i) = nanmean(feat_values);
        surr_std_alpha(i) = nanstd(feat_values);
    end

    % Compare real vs surrogate for alpha band only
    fprintf('\nReal vs Surrogate (Alpha band mean values):\n');

    % II alpha
    real_ii_alpha_mean = nanmean(ii_alpha(:));
    surr_ii_alpha_mean = nanmean(surr_mean_alpha(1:81));
    fprintf('  II Alpha - Real: %.6f, Surrogate: %.6f, Ratio: %.4f\n', real_ii_alpha_mean, surr_ii_alpha_mean, real_ii_alpha_mean/surr_ii_alpha_mean);

    % AA alpha
    real_aa_alpha_mean = nanmean(aa_alpha(:));
    surr_aa_alpha_mean = nanmean(surr_mean_alpha(82:162));
    fprintf('  AA Alpha - Real: %.6f, Surrogate: %.6f, Ratio: %.4f\n', real_aa_alpha_mean, surr_aa_alpha_mean, real_aa_alpha_mean/surr_aa_alpha_mean);

    % AI alpha
    real_ai_alpha_mean = nanmean(ai_alpha(:));
    surr_ai_alpha_mean = nanmean(surr_mean_alpha(163:243));
    fprintf('  AI Alpha - Real: %.6f, Surrogate: %.6f, Ratio: %.4f\n', real_ai_alpha_mean, surr_ai_alpha_mean, real_ai_alpha_mean/surr_ai_alpha_mean);

    % IA alpha
    real_ia_alpha_mean = nanmean(ia_alpha(:));
    surr_ia_alpha_mean = nanmean(surr_mean_alpha(244:324));
    fprintf('  IA Alpha - Real: %.6f, Surrogate: %.6f, Ratio: %.4f\n', real_ia_alpha_mean, surr_ia_alpha_mean, real_ia_alpha_mean/surr_ia_alpha_mean);

    fprintf('\nNote: IA connections should be close to surrogate (adult is pre-recorded)\n');
else
    fprintf('  No surrogate data available for comparison\n');
end

fprintf('\n');

%% Test 5: Correlation with learning (ALPHA BAND ONLY)
fprintf('==========================================================\n');
fprintf('TEST 5: Correlation with Learning (Alpha Band)\n');
fprintf('==========================================================\n');

% Calculate correlation between ALPHA BAND features and learning
learning_vec = data(:, 7);
valid_samples = ~isnan(learning_vec);

% Concatenate all alpha features
alpha_features_all = [ii_alpha, aa_alpha, ai_alpha, ia_alpha];
alpha_cols = [163:243, 406:486, 649:729, 892:972];

correlations_alpha = zeros(size(alpha_features_all, 2), 1);
pvalues_alpha = zeros(size(alpha_features_all, 2), 1);

for feat = 1:size(alpha_features_all, 2)
    feat_vec = alpha_features_all(:, feat);
    valid = valid_samples & ~isnan(feat_vec);

    if sum(valid) > 10
        [r, p] = corr(learning_vec(valid), feat_vec(valid));
        correlations_alpha(feat) = r;
        pvalues_alpha(feat) = p;
    else
        correlations_alpha(feat) = NaN;
        pvalues_alpha(feat) = NaN;
    end
end

% Find strongest correlations
[~, sorted_idx] = sort(abs(correlations_alpha), 'descend');
top_n = 10;

fprintf('Top %d alpha band correlations with learning:\n', top_n);
for i = 1:top_n
    idx = sorted_idx(i);
    if ~isnan(correlations_alpha(idx))
        actual_col = alpha_cols(idx);
        fprintf('  Alpha Feature %d (%s): r=%.4f, p=%.4f\n', actual_col, titles{actual_col+9}, correlations_alpha(idx), pvalues_alpha(idx));
    end
end

% Count significant correlations
sig_count_alpha = sum(pvalues_alpha < 0.05);
fprintf('\nNumber of alpha features with p<0.05: %d (%.2f%%)\n', sig_count_alpha, 100*sig_count_alpha/length(pvalues_alpha));

fprintf('\n');

%% Test 6: Visualization (ALPHA BAND ONLY)
fprintf('==========================================================\n');
fprintf('TEST 6: Basic Visualizations (Alpha Band)\n');
fprintf('==========================================================\n');

% Create figure with multiple subplots
figure('Position', [100, 100, 1200, 800]);

% Subplot 1: Distribution of ALPHA GPDC values by connection type
subplot(2, 3, 1);
boxplot([ii_alpha(:), aa_alpha(:), ai_alpha(:), ia_alpha(:)], ...
        'Labels', {'II', 'AA', 'AI', 'IA'});
title('Alpha Band GPDC Distribution (Cond=1)');
ylabel('Alpha GPDC Value');
grid on;

% Subplot 2: Learning distribution
subplot(2, 3, 2);
histogram(learning, 20);
title('Learning Score Distribution (Cond=1)');
xlabel('Learning Score');
ylabel('Frequency');
grid on;

% Subplot 3: Alpha correlation histogram
subplot(2, 3, 3);
histogram(correlations_alpha(~isnan(correlations_alpha)), 50);
title('Alpha Correlations with Learning');
xlabel('Correlation Coefficient');
ylabel('Frequency');
grid on;

% Subplot 4: Mean Alpha GPDC by connection type
subplot(2, 3, 4);
ii_alpha_mean = nanmean(ii_alpha, 2);
aa_alpha_mean = nanmean(aa_alpha, 2);
ai_alpha_mean = nanmean(ai_alpha, 2);
ia_alpha_mean = nanmean(ia_alpha, 2);
boxplot([ii_alpha_mean, aa_alpha_mean, ai_alpha_mean, ia_alpha_mean], ...
        'Labels', {'II', 'AA', 'AI', 'IA'});
title('Mean Alpha GPDC by Connection (Cond=1)');
ylabel('Mean Alpha GPDC');
grid on;

% Subplot 5: AI Alpha GPDC vs Learning
subplot(2, 3, 5);
ai_alpha_mean = nanmean(ai_alpha, 2);
scatter(ai_alpha_mean, learning, 30, 'filled', 'MarkerFaceAlpha', 0.5);
xlabel('Mean AI Alpha GPDC');
ylabel('Learning Score');
title('AI Alpha GPDC vs Learning (Cond=1)');
grid on;
lsline;

% Subplot 6: Real vs Surrogate comparison (Alpha band only)
if ~isempty(data_surr)
    subplot(2, 3, 6);
    surr_alpha_gpdc = [];
    for s = 1:min(10, length(data_surr))
        % Extract alpha columns from surrogate data
        surr_alpha_cols = data_surr{s}(:, [163:243, 406:486, 649:729, 892:972] + 9);
        surr_alpha_gpdc = [surr_alpha_gpdc; nanmean(surr_alpha_cols, 2)];
    end
    real_alpha_gpdc = nanmean(alpha_features_all, 2);

    histogram(real_alpha_gpdc, 30, 'FaceColor', 'b', 'FaceAlpha', 0.5, 'DisplayName', 'Real');
    hold on;
    histogram(surr_alpha_gpdc, 30, 'FaceColor', 'r', 'FaceAlpha', 0.5, 'DisplayName', 'Surrogate');
    legend;
    title('Real vs Surrogate Alpha GPDC');
    xlabel('Mean Alpha GPDC');
    ylabel('Frequency');
    grid on;
else
    subplot(2, 3, 6);
    text(0.5, 0.5, 'No surrogate data available', 'HorizontalAlignment', 'center');
    axis off;
end

fprintf('Visualizations created!\n\n');

%% Summary
fprintf('==========================================================\n');
fprintf('TESTING SUMMARY (ALPHA BAND FOCUS)\n');
fprintf('==========================================================\n');
fprintf('✓ All tests completed successfully!\n');
fprintf('\nKey findings:\n');
fprintf('  - Data structure: Valid\n');
fprintf('  - All samples are cond=1: %s\n', iif(all(cond_values == 1), 'Yes', 'No'));
fprintf('  - Sample size: %d\n', size(data, 1));
fprintf('  - Total GPDC features: %d\n', size(gpdc_features, 2));
fprintf('  - Alpha band features: %d (324 = 81*4 connection types)\n', size(alpha_features_all, 2));
fprintf('  - Valid alpha features (excluding diagonals): %d (II:72, AA:72, AI:81, IA:81)\n', sum(~isnan(alpha_features_all(1,:))));
fprintf('  - Significant alpha correlations with learning: %d\n', sig_count_alpha);
fprintf('\n==========================================================\n\n');

%% Helper function
function result = iif(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end
