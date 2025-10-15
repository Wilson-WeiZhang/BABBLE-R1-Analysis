%% ========================================================================
%  ENHANCED PLS ANALYSIS WITH CROSS-VALIDATION
%  ========================================================================
%
%  PURPOSE:
%  Perform rigorous PLS analysis with cross-validation to address
%  potential overfitting concerns in multivariate prediction.
%
%  METHODS:
%  1. Leave-One-Out Cross-Validation (LOOCV)
%  2. K-Fold Cross-Validation (K=5, K=10)
%  3. Bootstrap validation
%  4. Out-of-sample prediction metrics
%
%  ========================================================================

clc
clear all

%% Setup
path = 'C:\Users\Admin\OneDrive - Nanyang Technological University\';
code_path = [path, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/scripts_R1/'];
cd(code_path);

fprintf('\n');
fprintf('========================================================================\n');
fprintf('  ENHANCED PLS WITH CROSS-VALIDATION\n');
fprintf('========================================================================\n\n');

%% Load data
fprintf('Loading data...\n');
load('data_read_surr_gpdc.mat', 'data');
ori_data = sqrt(data);

% Extract variables
Country = ori_data(:, 1);
ID = ori_data(:, 2);
Age = ori_data(:, 3);
Sex = ori_data(:, 4);
Condition = ori_data(:, 6);
Learning = ori_data(:, 7);
Attention = ori_data(:, 9);

% AI alpha connections
ai_alpha_range = 659:739;
load('stronglistfdr5_gpdc_AI.mat', 's4');
sig_AI_indices = s4;

ai_alpha_data = ori_data(:, ai_alpha_range);
ai_alpha_sig = ai_alpha_data(:, sig_AI_indices);

% Focus on Full Gaze condition
c1_idx = find(Condition == 1);
valid_c1 = ~any(isnan(ai_alpha_sig(c1_idx, :)), 2) & ~isnan(Learning(c1_idx));
c1_valid_idx = c1_idx(valid_c1);

X_full = ai_alpha_sig(c1_valid_idx, :);
Y_full = Learning(c1_valid_idx);

fprintf('Full Gaze condition: N = %d participants\n', sum(valid_c1));
fprintf('Number of predictors: %d AI connections\n\n', size(X_full, 2));

%% ========================================================================
%  METHOD 1: LEAVE-ONE-OUT CROSS-VALIDATION (LOOCV)
%  ========================================================================

fprintf('========================================================================\n');
fprintf('METHOD 1: LEAVE-ONE-OUT CROSS-VALIDATION (LOOCV)\n');
fprintf('========================================================================\n\n');

n_samples = size(X_full, 1);
Y_pred_loocv = zeros(n_samples, 1);
n_components = 1;  % Use 1 component

fprintf('Running LOOCV with %d iterations...\n', n_samples);

for i = 1:n_samples
    % Training set (leave one out)
    train_idx = setdiff(1:n_samples, i);
    test_idx = i;

    X_train = X_full(train_idx, :);
    Y_train = Y_full(train_idx);
    X_test = X_full(test_idx, :);

    % Z-score training data
    [X_train_z, mu_X, sigma_X] = zscore(X_train);
    [Y_train_z, mu_Y, sigma_Y] = zscore(Y_train);

    % Z-score test data using training statistics
    X_test_z = (X_test - mu_X) ./ sigma_X;

    % Fit PLS on training data
    [~, ~, ~, ~, BETA] = plsregress(X_train_z, Y_train_z, n_components);

    % Predict on test data
    Y_pred_z = [1, X_test_z] * BETA;

    % Transform back to original scale
    Y_pred_loocv(i) = Y_pred_z * sigma_Y + mu_Y;
end

% Calculate LOOCV metrics
R2_loocv = corr(Y_pred_loocv, Y_full)^2;
MSE_loocv = mean((Y_pred_loocv - Y_full).^2);
MAE_loocv = mean(abs(Y_pred_loocv - Y_full));
RMSE_loocv = sqrt(MSE_loocv);

fprintf('\nLOOCV Results:\n');
fprintf('  R² (out-of-sample) = %.3f\n', R2_loocv);
fprintf('  MSE = %.3f\n', MSE_loocv);
fprintf('  RMSE = %.3f\n', RMSE_loocv);
fprintf('  MAE = %.3f\n\n', MAE_loocv);

% Compare to in-sample R²
X_full_z = zscore(X_full);
Y_full_z = zscore(Y_full);
[~, ~, ~, ~, BETA_full] = plsregress(X_full_z, Y_full_z, n_components);
Y_pred_insample = [ones(n_samples, 1), X_full_z] * BETA_full;
R2_insample = corr(Y_pred_insample, Y_full_z)^2;

fprintf('Comparison:\n');
fprintf('  In-sample R² = %.3f\n', R2_insample);
fprintf('  Out-of-sample R² (LOOCV) = %.3f\n', R2_loocv);
fprintf('  Shrinkage = %.3f (%.1f%%)\n', R2_insample - R2_loocv, ...
    100*(R2_insample - R2_loocv)/R2_insample);

if R2_loocv > 0.1
    fprintf('  ✅ LOOCV R² > 0.1: Reasonable out-of-sample prediction\n');
elseif R2_loocv > 0
    fprintf('  ⚠️  LOOCV R² > 0 but small: Weak out-of-sample prediction\n');
else
    fprintf('  ❌ LOOCV R² ≤ 0: Poor out-of-sample prediction\n');
end
fprintf('\n');

%% ========================================================================
%  METHOD 2: K-FOLD CROSS-VALIDATION
%  ========================================================================

fprintf('========================================================================\n');
fprintf('METHOD 2: K-FOLD CROSS-VALIDATION\n');
fprintf('========================================================================\n\n');

k_values = [5, 10];
R2_kfold = zeros(length(k_values), 1);
RMSE_kfold = zeros(length(k_values), 1);

for k_idx = 1:length(k_values)
    K = k_values(k_idx);

    fprintf('--- %d-Fold Cross-Validation ---\n', K);

    % Create folds
    rng(42);  % For reproducibility
    cv_indices = crossvalind('Kfold', n_samples, K);

    Y_pred_kfold = zeros(n_samples, 1);

    for k = 1:K
        % Split data
        test_idx = (cv_indices == k);
        train_idx = ~test_idx;

        X_train = X_full(train_idx, :);
        Y_train = Y_full(train_idx);
        X_test = X_full(test_idx, :);

        % Z-score
        [X_train_z, mu_X, sigma_X] = zscore(X_train);
        [Y_train_z, mu_Y, sigma_Y] = zscore(Y_train);
        X_test_z = (X_test - mu_X) ./ sigma_X;

        % Fit PLS
        [~, ~, ~, ~, BETA] = plsregress(X_train_z, Y_train_z, n_components);

        % Predict
        Y_pred_z = [ones(sum(test_idx), 1), X_test_z] * BETA;
        Y_pred_kfold(test_idx) = Y_pred_z * sigma_Y + mu_Y;
    end

    % Calculate metrics
    R2_kfold(k_idx) = corr(Y_pred_kfold, Y_full)^2;
    RMSE_kfold(k_idx) = sqrt(mean((Y_pred_kfold - Y_full).^2));

    fprintf('  R² (out-of-sample) = %.3f\n', R2_kfold(k_idx));
    fprintf('  RMSE = %.3f\n', RMSE_kfold(k_idx));
    fprintf('  Shrinkage from in-sample = %.3f (%.1f%%)\n\n', ...
        R2_insample - R2_kfold(k_idx), ...
        100*(R2_insample - R2_kfold(k_idx))/R2_insample);
end

%% ========================================================================
%  METHOD 3: BOOTSTRAP VALIDATION
%  ========================================================================

fprintf('========================================================================\n');
fprintf('METHOD 3: BOOTSTRAP VALIDATION\n');
fprintf('========================================================================\n\n');

n_boot = 1000;
R2_boot_train = zeros(n_boot, 1);
R2_boot_test = zeros(n_boot, 1);

fprintf('Running %d bootstrap iterations...\n', n_boot);

rng(42);
for i = 1:n_boot
    % Bootstrap sample (with replacement)
    boot_idx = randsample(n_samples, n_samples, true);
    oob_idx = setdiff(1:n_samples, unique(boot_idx));  % Out-of-bag samples

    if length(oob_idx) < 5  % Need at least 5 OOB samples
        continue;
    end

    X_boot = X_full(boot_idx, :);
    Y_boot = Y_full(boot_idx);
    X_oob = X_full(oob_idx, :);
    Y_oob = Y_full(oob_idx);

    % Z-score
    [X_boot_z, mu_X, sigma_X] = zscore(X_boot);
    [Y_boot_z, mu_Y, sigma_Y] = zscore(Y_boot);
    X_oob_z = (X_oob - mu_X) ./ sigma_X;
    Y_oob_z = (Y_oob - mu_Y) ./ sigma_Y;

    % Fit PLS
    [~, ~, ~, ~, BETA] = plsregress(X_boot_z, Y_boot_z, n_components);

    % Predict on bootstrap sample (training)
    Y_pred_boot = [ones(length(boot_idx), 1), X_boot_z] * BETA;
    R2_boot_train(i) = corr(Y_pred_boot, Y_boot_z)^2;

    % Predict on OOB samples (testing)
    Y_pred_oob = [ones(length(oob_idx), 1), X_oob_z] * BETA;
    R2_boot_test(i) = corr(Y_pred_oob, Y_oob_z)^2;
end

% Remove invalid iterations
valid_boot = R2_boot_train > 0 & R2_boot_test > -1;
R2_boot_train = R2_boot_train(valid_boot);
R2_boot_test = R2_boot_test(valid_boot);

fprintf('\nBootstrap Results (N = %d valid iterations):\n', sum(valid_boot));
fprintf('  Training R²:\n');
fprintf('    Mean = %.3f\n', mean(R2_boot_train));
fprintf('    95%% CI = [%.3f, %.3f]\n', ...
    prctile(R2_boot_train, 2.5), prctile(R2_boot_train, 97.5));

fprintf('  Out-of-Bag R² (test):\n');
fprintf('    Mean = %.3f\n', mean(R2_boot_test));
fprintf('    95%% CI = [%.3f, %.3f]\n', ...
    prctile(R2_boot_test, 2.5), prctile(R2_boot_test, 97.5));

fprintf('  Optimism (Training - Test):\n');
fprintf('    Mean = %.3f\n', mean(R2_boot_train - R2_boot_test));
fprintf('    95%% CI = [%.3f, %.3f]\n\n', ...
    prctile(R2_boot_train - R2_boot_test, 2.5), ...
    prctile(R2_boot_train - R2_boot_test, 97.5));

%% ========================================================================
%  METHOD 4: OPTIMISM-CORRECTED R² (Harrell's Method)
%  ========================================================================

fprintf('========================================================================\n');
fprintf('METHOD 4: OPTIMISM-CORRECTED R² (Harrell''s Method)\n');
fprintf('========================================================================\n\n');

% Optimism = E[R²_training - R²_test]
optimism = mean(R2_boot_train - R2_boot_test);

% Corrected R² = Apparent R² - Optimism
R2_corrected = R2_insample - optimism;

fprintf('Harrell''s Optimism-Corrected R²:\n');
fprintf('  Apparent R² (in-sample) = %.3f\n', R2_insample);
fprintf('  Mean optimism = %.3f\n', optimism);
fprintf('  Corrected R² = %.3f\n\n', R2_corrected);

if R2_corrected > 0.1
    fprintf('  ✅ Corrected R² > 0.1: Model has predictive value\n');
elseif R2_corrected > 0
    fprintf('  ⚠️  Corrected R² > 0 but small: Weak predictive value\n');
else
    fprintf('  ❌ Corrected R² ≤ 0: No predictive value after correction\n');
end
fprintf('\n');

%% ========================================================================
%  METHOD 5: PERMUTATION TEST ON CROSS-VALIDATED R²
%  ========================================================================

fprintf('========================================================================\n');
fprintf('METHOD 5: PERMUTATION TEST ON CV R²\n');
fprintf('========================================================================\n\n');

n_perm = 1000;
R2_perm_cv = zeros(n_perm, 1);

fprintf('Running %d permutations with LOOCV...\n', n_perm);

rng(42);
for p = 1:n_perm
    % Permute Y
    Y_perm = Y_full(randperm(n_samples));
    Y_pred_perm = zeros(n_samples, 1);

    % LOOCV on permuted data
    for i = 1:n_samples
        train_idx = setdiff(1:n_samples, i);
        test_idx = i;

        X_train = X_full(train_idx, :);
        Y_train = Y_perm(train_idx);
        X_test = X_full(test_idx, :);

        [X_train_z, mu_X, sigma_X] = zscore(X_train);
        [Y_train_z, mu_Y, sigma_Y] = zscore(Y_train);
        X_test_z = (X_test - mu_X) ./ sigma_X;

        [~, ~, ~, ~, BETA] = plsregress(X_train_z, Y_train_z, n_components);
        Y_pred_z = [1, X_test_z] * BETA;
        Y_pred_perm(i) = Y_pred_z * sigma_Y + mu_Y;
    end

    R2_perm_cv(p) = corr(Y_pred_perm, Y_perm)^2;
end

p_value_cv = sum(R2_perm_cv >= R2_loocv) / n_perm;

fprintf('\nPermutation Test Results:\n');
fprintf('  Observed LOOCV R² = %.3f\n', R2_loocv);
fprintf('  Permutation distribution:\n');
fprintf('    Mean = %.3f\n', mean(R2_perm_cv));
fprintf('    95th percentile = %.3f\n', prctile(R2_perm_cv, 95));
fprintf('  P-value = %.4f\n', p_value_cv);

if p_value_cv < 0.001
    fprintf('  ✅ HIGHLY SIGNIFICANT (p < .001)\n');
elseif p_value_cv < 0.01
    fprintf('  ✅ VERY SIGNIFICANT (p < .01)\n');
elseif p_value_cv < 0.05
    fprintf('  ✅ SIGNIFICANT (p < .05)\n');
else
    fprintf('  ❌ NOT SIGNIFICANT (p >= .05)\n');
end
fprintf('\n');

%% ========================================================================
%  COMPREHENSIVE SUMMARY TABLE
%  ========================================================================

fprintf('========================================================================\n');
fprintf('COMPREHENSIVE SUMMARY: ALL CV METHODS\n');
fprintf('========================================================================\n\n');

fprintf('%-30s %10s %12s\n', 'Method', 'R²', 'Status');
fprintf('%-30s %10s %12s\n', repmat('-', 1, 30), repmat('-', 1, 10), repmat('-', 1, 12));

fprintf('%-30s %10.3f %12s\n', 'In-sample (apparent)', R2_insample, 'Reference');
fprintf('%-30s %10.3f %12s\n', 'LOOCV', R2_loocv, ...
    iif(R2_loocv > 0.1, 'Good', iif(R2_loocv > 0, 'Weak', 'Poor')));
fprintf('%-30s %10.3f %12s\n', '5-Fold CV', R2_kfold(1), ...
    iif(R2_kfold(1) > 0.1, 'Good', iif(R2_kfold(1) > 0, 'Weak', 'Poor')));
fprintf('%-30s %10.3f %12s\n', '10-Fold CV', R2_kfold(2), ...
    iif(R2_kfold(2) > 0.1, 'Good', iif(R2_kfold(2) > 0, 'Weak', 'Poor')));
fprintf('%-30s %10.3f %12s\n', 'Bootstrap OOB (mean)', mean(R2_boot_test), ...
    iif(mean(R2_boot_test) > 0.1, 'Good', iif(mean(R2_boot_test) > 0, 'Weak', 'Poor')));
fprintf('%-30s %10.3f %12s\n', 'Optimism-corrected', R2_corrected, ...
    iif(R2_corrected > 0.1, 'Good', iif(R2_corrected > 0, 'Weak', 'Poor')));
fprintf('\n');

fprintf('Permutation Test:\n');
fprintf('  LOOCV R² = %.3f, p = %.4f %s\n', R2_loocv, p_value_cv, ...
    iif(p_value_cv < 0.05, '✅ SIG', '❌ NS'));
fprintf('\n');

%% ========================================================================
%  RECOMMENDATION FOR MANUSCRIPT
%  ========================================================================

fprintf('========================================================================\n');
fprintf('RECOMMENDATION FOR MANUSCRIPT\n');
fprintf('========================================================================\n\n');

% Calculate mean CV R²
mean_cv_R2 = mean([R2_loocv, R2_kfold', mean(R2_boot_test)]);

fprintf('RECOMMENDED REPORTING:\n');
fprintf('----------------------\n\n');

fprintf('Option 1 (Conservative - Report LOOCV):\n');
fprintf('"Multivariate PLS analysis with %d AI connections predicted learning\n', size(X_full, 2));
fprintf(' performance. While the apparent R² was %.2f, leave-one-out cross-\n', R2_insample);
fprintf(' validation yielded an out-of-sample R² of %.2f (permutation p = %.3f),\n', R2_loocv, p_value_cv);
fprintf(' indicating ');
if R2_loocv > 0.1 && p_value_cv < 0.05
    fprintf('modest but significant predictive value."\n\n');
elseif R2_loocv > 0 && p_value_cv < 0.05
    fprintf('weak but significant predictive value."\n\n');
else
    fprintf('limited out-of-sample predictive value."\n\n');
end

fprintf('Option 2 (Detailed - Report Multiple Methods):\n');
fprintf('"To assess the robustness of our PLS findings, we performed multiple\n');
fprintf(' cross-validation procedures. The in-sample R² of %.2f showed substantial\n', R2_insample);
fprintf(' shrinkage in cross-validation: LOOCV R² = %.2f, 5-fold CV R² = %.2f,\n', R2_loocv, R2_kfold(1));
fprintf(' 10-fold CV R² = %.2f, and bootstrap OOB R² = %.2f (mean). Harrell''s\n', R2_kfold(2), mean(R2_boot_test));
fprintf(' optimism-corrected R² was %.2f. Permutation testing confirmed that the\n', R2_corrected);
fprintf(' LOOCV R² was ');
if p_value_cv < 0.05
    fprintf('significantly better than chance (p = %.3f)."\n\n', p_value_cv);
else
    fprintf('not significantly better than chance (p = %.3f)."\n\n', p_value_cv);
end

fprintf('Option 3 (Brief - For Supplementary):\n');
fprintf('"Cross-validation analysis (LOOCV R² = %.2f, optimism-corrected R² = %.2f)\n', ...
    R2_loocv, R2_corrected);
fprintf(' indicated ');
if mean_cv_R2 > 0.1
    fprintf('moderate out-of-sample predictive value."\n\n');
elseif mean_cv_R2 > 0
    fprintf('weak but positive out-of-sample predictive value."\n\n');
else
    fprintf('limited out-of-sample predictive value."\n\n');
end

%% Save results
cv_results = struct();
cv_results.n_samples = n_samples;
cv_results.n_predictors = size(X_full, 2);
cv_results.R2_insample = R2_insample;
cv_results.R2_loocv = R2_loocv;
cv_results.MSE_loocv = MSE_loocv;
cv_results.RMSE_loocv = RMSE_loocv;
cv_results.MAE_loocv = MAE_loocv;
cv_results.R2_5fold = R2_kfold(1);
cv_results.R2_10fold = R2_kfold(2);
cv_results.R2_boot_train_mean = mean(R2_boot_train);
cv_results.R2_boot_test_mean = mean(R2_boot_test);
cv_results.R2_boot_test_ci = [prctile(R2_boot_test, 2.5), prctile(R2_boot_test, 97.5)];
cv_results.optimism = optimism;
cv_results.R2_corrected = R2_corrected;
cv_results.p_value_permutation = p_value_cv;
cv_results.Y_pred_loocv = Y_pred_loocv;
cv_results.Y_actual = Y_full;

save([path, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/results/', ...
    'R1_PLS_CROSSVALIDATION_RESULTS.mat'], 'cv_results');

fprintf('========================================================================\n');
fprintf('RESULTS SAVED\n');
fprintf('========================================================================\n\n');
fprintf('✅ Saved to: results/R1_PLS_CROSSVALIDATION_RESULTS.mat\n\n');

fprintf('INTERPRETATION GUIDE:\n');
fprintf('--------------------\n');
fprintf('R² > 0.25: Strong prediction (excellent)\n');
fprintf('R² > 0.10: Moderate prediction (good)\n');
fprintf('R² > 0.05: Weak prediction (acceptable in exploratory studies)\n');
fprintf('R² ≤ 0.05: Very weak/no prediction (poor)\n\n');

fprintf('Your results:\n');
fprintf('  In-sample: R² = %.3f (%s)\n', R2_insample, ...
    iif(R2_insample > 0.25, 'Strong', iif(R2_insample > 0.10, 'Moderate', 'Weak')));
fprintf('  LOOCV:     R² = %.3f (%s, p = %.3f)\n', R2_loocv, ...
    iif(R2_loocv > 0.25, 'Strong', iif(R2_loocv > 0.10, 'Moderate', iif(R2_loocv > 0.05, 'Weak', 'Very weak'))), ...
    p_value_cv);
fprintf('  Corrected: R² = %.3f (%s)\n\n', R2_corrected, ...
    iif(R2_corrected > 0.25, 'Strong', iif(R2_corrected > 0.10, 'Moderate', iif(R2_corrected > 0.05, 'Weak', 'Very weak'))));

fprintf('========================================================================\n');
fprintf('ANALYSIS COMPLETE\n');
fprintf('========================================================================\n\n');

% Helper function for inline if
function result = iif(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end
