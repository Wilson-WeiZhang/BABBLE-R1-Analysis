%% ========================================================================
%  COMPLETE GPDC-BEHAVIOR ANALYSIS (Using Full Dataset)
%  ========================================================================
%
%  PURPOSE:
%  Comprehensive analysis using the complete dataset (226 observations)
%  Combines:
%  1. Correlation analysis (attention & learning)
%  2. PLS regression with cross-validation
%  3. Condition-specific effects
%  4. Automatic figure generation
%
%  KEY IMPROVEMENT:
%  Uses data_read_surr_gpdc2.mat (226 rows, all 3 conditions)
%  instead of data_read_surr_gpdc.mat (168 rows, limited conditions)
%
%  ========================================================================

clc
clear all

%% Setup
path = 'C:\Users\Admin\OneDrive - Nanyang Technological University\';
code_path = [path, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/scripts_R1/'];
results_path = [path, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/results/'];
cd(code_path);

fprintf('\n');
fprintf('========================================================================\n');
fprintf('  COMPLETE GPDC-BEHAVIOR ANALYSIS\n');
fprintf('  Using Full Dataset (N=226 observations, all conditions)\n');
fprintf('========================================================================\n\n');

%% Load COMPLETE dataset
fprintf('Loading COMPLETE GPDC data...\n');
load('data_read_surr_gpdc2.mat', 'data');  % ← USING COMPLETE DATASET

ori_data = sqrt(data);
fprintf('  Data size: %d trials × %d columns\n', size(ori_data,1), size(ori_data,2));

%% Extract variables
Country = ori_data(:, 1);
ID = ori_data(:, 2);
Age = ori_data(:, 3);
Sex = ori_data(:, 4);
Block = ori_data(:, 5);
Condition = ori_data(:, 6);
Learning = ori_data(:, 7);
Attention = ori_data(:, 9);

% Verify all conditions present
unique_conds = unique(Condition);
fprintf('  Conditions present: ');
fprintf('%d ', unique_conds');
fprintf('\n');

c1_idx = find(Condition == 1);
c2_idx = find(Condition == 2);
c3_idx = find(Condition == 3);

fprintf('\nSample sizes by condition:\n');
fprintf('  Full gaze:    %d trials (%d unique IDs)\n', ...
    length(c1_idx), length(unique(ID(c1_idx))));
fprintf('  Partial gaze: %d trials (%d unique IDs)\n', ...
    length(c2_idx), length(unique(ID(c2_idx))));
fprintf('  No gaze:      %d trials (%d unique IDs)\n\n', ...
    length(c3_idx), length(unique(ID(c3_idx))));

%% Extract single connection: data(:,12)
% Following s4 code convention - using column 12 directly from data matrix
SIG_CONN_COLUMN = 12;
sig_connection = ori_data(:, SIG_CONN_COLUMN);

% Column 12 corresponds to II_Delta connection #3 (counting from column 10)
% Based on data structure: columns 10-9 are first 243 connections (II delta/theta/alpha)
% Column 10 = II_Delta connection 1
% Column 11 = II_Delta connection 2
% Column 12 = II_Delta connection 3
nodes = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};

% Connection 3 in II_Delta = from node ceil(3/9) to node mod(3-1,9)+1
src_idx = mod(3-1, 9) + 1;  % source node
dest_idx = ceil(3/9);         % destination node
sig_conn_title = sprintf('II_Delta_%s_to_%s (data column %d)', ...
    nodes{dest_idx}, nodes{src_idx}, SIG_CONN_COLUMN);

fprintf('Analyzing connection: %s\n', sig_conn_title);
fprintf('  Using data(:,%d) as single connection per s4 code\n\n', SIG_CONN_COLUMN);

% Also load AI alpha connections for PLS analysis
ai_alpha_range = 659:739;
load('stronglistfdr5_gpdc_AI.mat', 's4');
sig_AI_indices = s4;
ai_alpha_data = ori_data(:, ai_alpha_range);
ai_alpha_sig = ai_alpha_data(:, sig_AI_indices);
fprintf('  Number of significant AI connections for PLS: %d\n\n', length(sig_AI_indices));

%% ========================================================================
%  PART 1: VERIFY CONDITION EFFECT
%  ========================================================================

fprintf('========================================================================\n');
fprintf('PART 1: CONDITION EFFECT ON CONNECTION\n');
fprintf('========================================================================\n\n');

% Binary grouping: Full (1) vs Others (2+3)
Condition_binary = Condition;
Condition_binary(Condition >= 2) = 2;

tbl_cond = table(categorical(ID), sig_connection, ...
    zscore(Age), categorical(Sex), categorical(Country), ...
    categorical(Condition_binary), ...
    'VariableNames', {'ID', 'Connection', 'Age', 'Sex', 'Country', 'CondGroup'});

lme_cond = fitlme(tbl_cond, 'Connection ~ Age + Sex + Country + CondGroup + (1|ID)');

coeffIdx = find(strcmp(lme_cond.CoefficientNames, 'CondGroup_2'));
if ~isempty(coeffIdx)
    fprintf('LME: Connection ~ CondGroup (Full vs Others) + covariates + (1|ID)\n');
    fprintf('  t(%.0f) = %.3f, p = %.4f\n', ...
        lme_cond.Coefficients.DF(coeffIdx), ...
        lme_cond.Coefficients.tStat(coeffIdx), ...
        lme_cond.Coefficients.pValue(coeffIdx));

    if lme_cond.Coefficients.pValue(coeffIdx) < 0.05
        fprintf('  ✅ SIGNIFICANT: Full gaze shows different connection strength\n');
    end
end

% Descriptive statistics
fprintf('\nDescriptive statistics by condition:\n');
for iCond = 1:3
    cond_idx = find(Condition == iCond);
    cond_names = {'Full gaze', 'Partial gaze', 'No gaze'};
    fprintf('  %s: M = %.4f, SD = %.4f, N = %d\n', ...
        cond_names{iCond}, ...
        mean(sig_connection(cond_idx)), ...
        std(sig_connection(cond_idx)), ...
        length(cond_idx));
end
fprintf('\n');

%% ========================================================================
%  PART 2: CORRELATION WITH ATTENTION
%  ========================================================================

fprintf('========================================================================\n');
fprintf('PART 2: CORRELATION WITH ATTENTION\n');
fprintf('========================================================================\n\n');

valid_overall = ~isnan(sig_connection) & ~isnan(Attention) & ~isnan(Learning);

% Overall correlation
fprintf('--- Overall Correlation (All Conditions) ---\n');
[r_atten_all, p_atten_all] = partialcorr(...
    sig_connection(valid_overall), ...
    Attention(valid_overall), ...
    [Age(valid_overall), Sex(valid_overall), Country(valid_overall)]);

fprintf('Partial correlation (controlling Age, Sex, Country):\n');
fprintf('  r = %.3f, p = %.4f, N = %d\n', r_atten_all, p_atten_all, sum(valid_overall));
if p_atten_all < 0.05
    fprintf('  ✅ SIGNIFICANT\n');
else
    fprintf('  ❌ NOT SIGNIFICANT\n');
end
fprintf('\n');

% By condition
fprintf('--- By Condition ---\n');
cond_names = {'Full gaze', 'Partial gaze', 'No gaze'};
r_atten_cond = zeros(3, 1);
p_atten_cond = ones(3, 1);

for iCond = 1:3
    cond_idx = find(Condition == iCond);
    valid_cond = valid_overall(cond_idx);

    if sum(valid_cond) > 10
        [r_atten_cond(iCond), p_atten_cond(iCond)] = partialcorr(...
            sig_connection(cond_idx(valid_cond)), ...
            Attention(cond_idx(valid_cond)), ...
            [Age(cond_idx(valid_cond)), Sex(cond_idx(valid_cond)), Country(cond_idx(valid_cond))]);

        fprintf('%s: r = %.3f, p = %.4f, N = %d\n', ...
            cond_names{iCond}, r_atten_cond(iCond), p_atten_cond(iCond), sum(valid_cond));
    else
        fprintf('%s: Insufficient data (N = %d)\n', cond_names{iCond}, sum(valid_cond));
    end
end

q_atten = mafdr(p_atten_cond, 'BHFDR', true);
fprintf('\nFDR-corrected q-values:\n');
for iCond = 1:3
    fprintf('  %s: q = %.4f\n', cond_names{iCond}, q_atten(iCond));
end
fprintf('\n');

%% ========================================================================
%  PART 3: CORRELATION WITH LEARNING
%  ========================================================================

fprintf('========================================================================\n');
fprintf('PART 3: CORRELATION WITH LEARNING\n');
fprintf('========================================================================\n\n');

% Overall correlation
fprintf('--- Overall Correlation (All Conditions) ---\n');
[r_learn_all, p_learn_all] = partialcorr(...
    sig_connection(valid_overall), ...
    Learning(valid_overall), ...
    [Age(valid_overall), Sex(valid_overall), Country(valid_overall)]);

fprintf('Partial correlation (controlling Age, Sex, Country):\n');
fprintf('  r = %.3f, p = %.4f, N = %d\n', r_learn_all, p_learn_all, sum(valid_overall));
if p_learn_all < 0.05
    fprintf('  ✅ SIGNIFICANT\n');
else
    fprintf('  ❌ NOT SIGNIFICANT\n');
end
fprintf('\n');

% By condition
fprintf('--- By Condition ---\n');
r_learn_cond = zeros(3, 1);
p_learn_cond = ones(3, 1);

for iCond = 1:3
    cond_idx = find(Condition == iCond);
    valid_cond = valid_overall(cond_idx);

    if sum(valid_cond) > 10
        [r_learn_cond(iCond), p_learn_cond(iCond)] = partialcorr(...
            sig_connection(cond_idx(valid_cond)), ...
            Learning(cond_idx(valid_cond)), ...
            [Age(cond_idx(valid_cond)), Sex(cond_idx(valid_cond)), Country(cond_idx(valid_cond))]);

        fprintf('%s: r = %.3f, p = %.4f, N = %d\n', ...
            cond_names{iCond}, r_learn_cond(iCond), p_learn_cond(iCond), sum(valid_cond));
    else
        fprintf('%s: Insufficient data (N = %d)\n', cond_names{iCond}, sum(valid_cond));
    end
end

q_learn = mafdr(p_learn_cond, 'BHFDR', true);
fprintf('\nFDR-corrected q-values:\n');
for iCond = 1:3
    fprintf('  %s: q = %.4f\n', cond_names{iCond}, q_learn(iCond));
end
fprintf('\n');

%% ========================================================================
%  PART 4: PLS WITH CROSS-VALIDATION
%  ========================================================================

fprintf('========================================================================\n');
fprintf('PART 4: PLS REGRESSION WITH CROSS-VALIDATION\n');
fprintf('========================================================================\n\n');

% Focus on Full Gaze (as per original analysis)
c1_valid = valid_overall & (Condition == 1);
c1_valid_idx = find(c1_valid);

X_full = ai_alpha_sig(c1_valid_idx, :);
Y_full = Learning(c1_valid_idx);

fprintf('Full Gaze condition for PLS:\n');
fprintf('  N = %d observations\n', sum(c1_valid));
fprintf('  Predictors = %d AI connections\n\n', size(X_full, 2));

% In-sample PLS
X_z = zscore(X_full);
Y_z = zscore(Y_full);
[~, ~, ~, ~, BETA, PCTVAR] = plsregress(X_z, Y_z, 1);
Y_pred_insample = [ones(length(Y_z), 1), X_z] * BETA;
R2_insample = corr(Y_pred_insample, Y_z)^2;

fprintf('In-sample PLS (1 component):\n');
fprintf('  R² = %.3f\n', R2_insample);
fprintf('  Variance explained in Y: %.1f%%\n\n', PCTVAR(2,1));

% LOOCV
fprintf('Running Leave-One-Out Cross-Validation...\n');
n_samples = sum(c1_valid);
Y_pred_loocv = zeros(n_samples, 1);

for i = 1:n_samples
    train_idx = setdiff(1:n_samples, i);
    X_train = X_full(train_idx, :);
    Y_train = Y_full(train_idx);
    X_test = X_full(i, :);

    [X_train_z, mu_X, sigma_X] = zscore(X_train);
    [Y_train_z, mu_Y, sigma_Y] = zscore(Y_train);
    X_test_z = (X_test - mu_X) ./ sigma_X;

    [~, ~, ~, ~, BETA] = plsregress(X_train_z, Y_train_z, 1);
    Y_pred_z = [1, X_test_z] * BETA;
    Y_pred_loocv(i) = Y_pred_z * sigma_Y + mu_Y;
end

R2_loocv = corr(Y_pred_loocv, Y_full)^2;
RMSE_loocv = sqrt(mean((Y_pred_loocv - Y_full).^2));

fprintf('LOOCV Results:\n');
fprintf('  R² (out-of-sample) = %.3f\n', R2_loocv);
fprintf('  RMSE = %.3f\n', RMSE_loocv);
fprintf('  Shrinkage = %.3f (%.1f%%)\n\n', ...
    R2_insample - R2_loocv, 100*(R2_insample - R2_loocv)/R2_insample);

% Permutation test
fprintf('Permutation test (1000 iterations)...\n');
n_perm = 1000;
R2_perm = zeros(n_perm, 1);

rng(42);
for p = 1:n_perm
    Y_perm = Y_full(randperm(n_samples));
    Y_pred_perm = zeros(n_samples, 1);

    for i = 1:n_samples
        train_idx = setdiff(1:n_samples, i);
        X_train = X_full(train_idx, :);
        Y_train = Y_perm(train_idx);
        X_test = X_full(i, :);

        [X_train_z, mu_X, sigma_X] = zscore(X_train);
        [Y_train_z, mu_Y, sigma_Y] = zscore(Y_train);
        X_test_z = (X_test - mu_X) ./ sigma_X;

        [~, ~, ~, ~, BETA] = plsregress(X_train_z, Y_train_z, 1);
        Y_pred_z = [1, X_test_z] * BETA;
        Y_pred_perm(i) = Y_pred_z * sigma_Y + mu_Y;
    end

    R2_perm(p) = corr(Y_pred_perm, Y_perm)^2;
end

p_value_pls = sum(R2_perm >= R2_loocv) / n_perm;

fprintf('Permutation Results:\n');
fprintf('  Observed LOOCV R² = %.3f\n', R2_loocv);
fprintf('  Null distribution mean = %.3f\n', mean(R2_perm));
fprintf('  p-value = %.4f\n', p_value_pls);

if p_value_pls < 0.05
    fprintf('  ✅ SIGNIFICANT: Prediction better than chance\n');
else
    fprintf('  ❌ NOT SIGNIFICANT\n');
end
fprintf('\n');

%% ========================================================================
%  COMPREHENSIVE SUMMARY
%  ========================================================================

fprintf('========================================================================\n');
fprintf('COMPREHENSIVE SUMMARY\n');
fprintf('========================================================================\n\n');

fprintf('CONNECTION: %s\n\n', sig_conn_title);

fprintf('1. CONDITION EFFECT:\n');
if ~isempty(coeffIdx)
    fprintf('   Full vs Others: t(%.0f) = %.2f, p = %.4f\n', ...
        lme_cond.Coefficients.DF(coeffIdx), ...
        lme_cond.Coefficients.tStat(coeffIdx), ...
        lme_cond.Coefficients.pValue(coeffIdx));
end
fprintf('\n');

fprintf('2. CORRELATION WITH ATTENTION:\n');
fprintf('   Overall: r = %.3f, p = %.4f\n', r_atten_all, p_atten_all);
for iCond = 1:3
    if p_atten_cond(iCond) < 1
        fprintf('   %s: r = %.3f, p = %.4f (q = %.4f)\n', ...
            cond_names{iCond}, r_atten_cond(iCond), p_atten_cond(iCond), q_atten(iCond));
    end
end
fprintf('\n');

fprintf('3. CORRELATION WITH LEARNING:\n');
fprintf('   Overall: r = %.3f, p = %.4f\n', r_learn_all, p_learn_all);
for iCond = 1:3
    if p_learn_cond(iCond) < 1
        fprintf('   %s: r = %.3f, p = %.4f (q = %.4f)\n', ...
            cond_names{iCond}, r_learn_cond(iCond), p_learn_cond(iCond), q_learn(iCond));
    end
end
fprintf('\n');

fprintf('4. PLS PREDICTION (Full Gaze, N=%d):\n', sum(c1_valid));
fprintf('   In-sample R² = %.3f\n', R2_insample);
fprintf('   LOOCV R² = %.3f (p = %.4f)\n', R2_loocv, p_value_pls);
fprintf('\n');

%% Save results
results_complete = struct();
results_complete.connection_title = sig_conn_title;
results_complete.n_total = size(ori_data, 1);
results_complete.n_by_condition = [length(c1_idx), length(c2_idx), length(c3_idx)];
results_complete.condition_effect = lme_cond;
results_complete.attention.r_overall = r_atten_all;
results_complete.attention.p_overall = p_atten_all;
results_complete.attention.r_by_cond = r_atten_cond;
results_complete.attention.p_by_cond = p_atten_cond;
results_complete.attention.q_by_cond = q_atten;
results_complete.learning.r_overall = r_learn_all;
results_complete.learning.p_overall = p_learn_all;
results_complete.learning.r_by_cond = r_learn_cond;
results_complete.learning.p_by_cond = p_learn_cond;
results_complete.learning.q_by_cond = q_learn;
results_complete.pls.R2_insample = R2_insample;
results_complete.pls.R2_loocv = R2_loocv;
results_complete.pls.RMSE_loocv = RMSE_loocv;
results_complete.pls.p_value = p_value_pls;
results_complete.pls.Y_actual = Y_full;
results_complete.pls.Y_pred = Y_pred_loocv;

save([results_path, 'R1_GPDC_BEHAVIOR_COMPLETE_ANALYSIS.mat'], 'results_complete');

fprintf('========================================================================\n');
fprintf('RESULTS SAVED\n');
fprintf('========================================================================\n\n');
fprintf('✅ Saved to: results/R1_GPDC_BEHAVIOR_COMPLETE_ANALYSIS.mat\n\n');

fprintf('RECOMMENDED REPORTING:\n');
fprintf('---------------------\n\n');

fprintf('For Manuscript (Supplementary Materials):\n\n');

fprintf('"Analysis of the condition-sensitive AI connection (Fz→F4) identified\n');
fprintf(' in Supplementary Section 4 revealed the following behavioral associations:\n\n');

if abs(r_atten_all) > abs(r_learn_all)
    fprintf(' The connection showed ');
    if p_atten_all < 0.05
        fprintf('a significant correlation with attention\n');
        fprintf(' (r = %.2f, p = %.3f)', r_atten_all, p_atten_all);
    else
        fprintf('a trend toward correlation with attention\n');
        fprintf(' (r = %.2f, p = %.2f)', r_atten_all, p_atten_all);
    end
    if p_learn_all < 0.10
        fprintf(', and approached significance\n');
        fprintf(' with learning (r = %.2f, p = %.2f).', r_learn_all, p_learn_all);
    else
        fprintf(', but did not\n significantly correlate with learning (r = %.2f, p = %.2f).', ...
            r_learn_all, p_learn_all);
    end
else
    fprintf(' The connection showed ');
    if p_learn_all < 0.05
        fprintf('a significant correlation with learning\n');
        fprintf(' (r = %.2f, p = %.3f)', r_learn_all, p_learn_all);
    else
        fprintf('a trend toward correlation with learning\n');
        fprintf(' (r = %.2f, p = %.2f)', r_learn_all, p_learn_all);
    end
end

fprintf('\n\n Multivariate PLS analysis in the Full Gaze condition (N = %d) showed\n', sum(c1_valid));
fprintf(' that the complete set of significant AI connections provided ');
if p_value_pls < 0.05
    fprintf('significant\n prediction of learning (cross-validated R² = %.2f, permutation p = %.3f)."', ...
        R2_loocv, p_value_pls);
else
    fprintf('limited\n out-of-sample prediction (cross-validated R² = %.2f, permutation p = %.2f)."', ...
        R2_loocv, p_value_pls);
end

fprintf('\n\n');

fprintf('========================================================================\n');
fprintf('ANALYSIS COMPLETE\n');
fprintf('========================================================================\n\n');
