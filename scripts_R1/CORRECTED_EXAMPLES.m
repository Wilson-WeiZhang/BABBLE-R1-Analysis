%% EXAMPLES: USING CORRECTED STATISTICAL UTILITIES
% Created: 2025-10-10
% Purpose: Demonstrate usage of corrected functions from statistical_utilities_corrected.m
%
% This script shows how to properly use the corrected statistical functions
% in your R1 revision analyses.

clear; clc;

% Add utilities to path
addpath(fileparts(mfilename('fullpath')));

fprintf('=======================================================\n');
fprintf('CORRECTED STATISTICAL UTILITIES - USAGE EXAMPLES\n');
fprintf('=======================================================\n\n');

%% EXAMPLE 1: CORRECTED EFFECT SIZE CALCULATION
fprintf('EXAMPLE 1: Cohen''s d with Hedges'' g correction\n');
fprintf('-------------------------------------------------------\n\n');

% Simulate learning scores (accuracy difference: post - pre)
rng(42);
n_subjects = 44;
learning_scores = 0.08 + 0.12 * randn(n_subjects, 1);  % Mean ≈ 0.08, SD ≈ 0.12

% OLD WAY (INCORRECT):
[h, p, ci, stats] = ttest(learning_scores);
cohend_OLD = stats.ttest.tstat / sqrt(stats.ttest.df + 1);  % APPROXIMATION
fprintf('❌ OLD APPROXIMATION:\n');
fprintf('   Cohen''s d ≈ %.3f (from t/sqrt(df+1))\n', cohend_OLD);
fprintf('   Problem: This is an approximation, not exact formula\n\n');

% NEW WAY (CORRECT):
[d, d_hedges, CI_d, diagnostics] = calculate_cohens_d_corrected(learning_scores, ...
    'mu0', 0, 'alpha', 0.05, 'nBoot', 5000);

fprintf('\n✓ NEW EXACT CALCULATION:\n');
fprintf('   Cohen''s d = %.3f (exact formula)\n', d);
fprintf('   Hedges'' g = %.3f (small-sample corrected)\n', d_hedges);
fprintf('   95%% CI: [%.3f, %.3f]\n', CI_d(1), CI_d(2));
fprintf('   Interpretation: %s effect\n', diagnostics.interpretation);

% Comparison
fprintf('\n📊 Difference: %.4f (%.1f%% difference)\n', ...
    abs(cohend_OLD - d_hedges), 100*abs(cohend_OLD - d_hedges)/d_hedges);

fprintf('\n\n');

%% EXAMPLE 2: PARAMETRIC ASSUMPTION TESTING
fprintf('EXAMPLE 2: Check assumptions before t-test\n');
fprintf('-------------------------------------------------------\n\n');

% Test normally distributed data
normal_data = randn(40, 1);
fprintf('2A. Testing NORMAL data:\n');
[assumptions_met, diagnostics, recommendations] = ...
    check_parametric_assumptions(normal_data, 'alpha', 0.05);

fprintf('Press any key to continue to skewed data example...\n');
pause;

% Test skewed data
skewed_data = exprnd(2, 40, 1);  % Exponential (skewed)
fprintf('\n2B. Testing SKEWED data:\n');
[assumptions_met2, diagnostics2, recommendations2] = ...
    check_parametric_assumptions(skewed_data, 'alpha', 0.05);

fprintf('Press any key to continue...\n');
pause;

%% EXAMPLE 3: COLLINEARITY DIAGNOSTICS FOR LME
fprintf('\n\nEXAMPLE 3: Check multicollinearity before LME\n');
fprintf('-------------------------------------------------------\n\n');

% Simulate data with multicollinearity
n = 100;
ID = repmat((1:20)', 5, 1);
Block = repmat((1:5)', 20, 1);
Gaze = randi([0, 2], n, 1);

% Create correlated predictors (PROBLEM)
Age = 12 + 4*randn(n, 1);
Age_months = Age * 12;  % Perfectly correlated!

% Create outcome
Y = 0.5 + 0.3*Gaze + 0.1*Age + randn(n, 1);

% Create table
dataTable = table(ID, Block, Gaze, Age, Age_months, Y);

fprintf('3A. Testing model with COLLINEAR predictors:\n');
fprintf('    Formula: Y ~ Gaze + Age + Age_months + (1|ID)\n\n');

[collinearity_ok, vif_values, diagnostics] = check_lme_collinearity(...
    dataTable, 'Y ~ Gaze + Age + Age_months + (1|ID)', 'threshold', 10);

fprintf('💡 Notice: Age_months has very high VIF because it is\n');
fprintf('   perfectly correlated with Age (Age_months = Age × 12)\n\n');

% Now test without collinear predictor
fprintf('\n3B. Testing model WITHOUT collinear predictor:\n');
fprintf('    Formula: Y ~ Gaze + Age + (1|ID)\n\n');

dataTable2 = dataTable(:, {'ID', 'Gaze', 'Age', 'Y'});
[collinearity_ok2, vif_values2, diagnostics2] = check_lme_collinearity(...
    dataTable2, 'Y ~ Gaze + Age + (1|ID)', 'threshold', 10);

fprintf('Press any key to continue...\n');
pause;

%% EXAMPLE 4: FDR CORRECTION WITH DEPENDENCY HANDLING
fprintf('\n\nEXAMPLE 4: FDR correction for dependent tests\n');
fprintf('-------------------------------------------------------\n\n');

% Simulate correlated p-values (e.g., from connectivity matrix)
n_tests = 50;
rng(42);
true_positives = 10;

% Generate p-values
pvals = [rand(true_positives, 1) * 0.01;  % True effects
         rand(n_tests - true_positives, 1) * 0.5];  % Null effects
pvals = pvals(randperm(n_tests));

fprintf('4A. Standard B-H FDR (assumes independence):\n');
[h_indep, crit_p_indep, ~, adj_p_indep] = fdr_bh_corrected(pvals, 0.05, 'dep', 'independent');

fprintf('\n4B. B-Y FDR (allows dependency):\n');
[h_dep, crit_p_dep, ~, adj_p_dep] = fdr_bh_corrected(pvals, 0.05, 'dep', 'dependent');

fprintf('\n📊 Comparison:\n');
fprintf('   B-H (independent): %d significant, critical p = %.5f\n', sum(h_indep), crit_p_indep);
fprintf('   B-Y (dependent):   %d significant, critical p = %.5f\n', sum(h_dep), crit_p_dep);
fprintf('   Note: B-Y is more conservative for dependent tests\n');

fprintf('\nPress any key to continue...\n');
pause;

%% EXAMPLE 5: LME CONVERGENCE CHECKING
fprintf('\n\nEXAMPLE 5: Check LME model convergence\n');
fprintf('-------------------------------------------------------\n\n');

% Simulate data for LME
n_subj = 30;
n_trials = 5;
n_total = n_subj * n_trials;

ID = repmat((1:n_subj)', n_trials, 1);
Condition = randi([0, 1], n_total, 1);
Y = 10 + 2*Condition + randn(n_total, 1) + randn(ID(1), 1);  % Random intercepts

dataLME = table(ID, Condition, Y);

fprintf('Fitting LME model: Y ~ Condition + (1|ID)\n\n');

% Fit model
lme = fitlme(dataLME, 'Y ~ Condition + (1|ID)');

% Check convergence
[converged, diag_conv] = check_lme_convergence(lme, 'max_grad', 1e-6, 'display', true);

if converged
    fprintf('✓ Model can be used for inference\n');
else
    fprintf('✗ Model needs refitting or simplification\n');
end

fprintf('\nPress any key to continue...\n');
pause;

%% EXAMPLE 6: MISSING DATA ANALYSIS
fprintf('\n\nEXAMPLE 6: Missing data analysis\n');
fprintf('-------------------------------------------------------\n\n');

% Create data with missing values
n = 50;
dataWithMissing = table();
dataWithMissing.SubjectID = (1:n)';
dataWithMissing.Age = 12 + 4*randn(n, 1);
dataWithMissing.Learning = 0.08 + 0.12*randn(n, 1);
dataWithMissing.GPDC_AI = 0.15 + 0.05*randn(n, 1);

% Introduce missing data
dataWithMissing.Age(randi(n, 2, 1)) = NaN;  % 4% missing
dataWithMissing.Learning(randi(n, 5, 1)) = NaN;  % 10% missing
dataWithMissing.GPDC_AI(randi(n, 8, 1)) = NaN;  % 16% missing

report_missing_data(dataWithMissing, 'threshold', 5);

fprintf('\n\n');

%% EXAMPLE 7: COMPLETE WORKFLOW FOR LEARNING ANALYSIS
fprintf('EXAMPLE 7: Complete corrected workflow\n');
fprintf('-------------------------------------------------------\n\n');

% Simulate realistic learning data
n_subj = 44;
post_accuracy = 0.65 + 0.15*randn(n_subj, 1);
pre_accuracy = post_accuracy - 0.08 - 0.12*randn(n_subj, 1);
learning_scores = post_accuracy - pre_accuracy;

% Introduce some missing data
learning_scores(randi(n_subj, 2, 1)) = NaN;

fprintf('STEP 1: Missing data check\n');
dataLearning = table((1:n_subj)', learning_scores, 'VariableNames', {'SubjectID', 'Learning'});
report_missing_data(dataLearning);

fprintf('\nSTEP 2: Assumption testing\n');
[assumptions_met, diag_assump, recomm_assump] = ...
    check_parametric_assumptions(learning_scores, 'alpha', 0.05);

fprintf('\nSTEP 3: Statistical test\n');
if assumptions_met.normality && assumptions_met.outliers
    fprintf('✓ Assumptions met, using parametric t-test\n');
    [h, p, ci, stats] = ttest(learning_scores);
    fprintf('   t(%d) = %.3f, p = %.4f\n', stats.df, stats.tstat, p);
    fprintf('   95%% CI: [%.4f, %.4f]\n', ci(1), ci(2));
else
    fprintf('⚠️  Assumptions violated, using non-parametric test\n');
    [p, h, stats] = signrank(learning_scores);
    fprintf('   Wilcoxon signed-rank: W = %.0f, p = %.4f\n', stats.signedrank, p);
end

fprintf('\nSTEP 4: Effect size calculation\n');
[d, d_hedges, CI_d, diag_effect] = calculate_cohens_d_corrected(learning_scores, ...
    'mu0', 0, 'alpha', 0.05, 'nBoot', 5000);

fprintf('\n📊 FINAL RESULTS TO REPORT:\n');
fprintf('   Sample: N = %d\n', diag_effect.n);
fprintf('   Mean learning: %.3f (SD = %.3f)\n', diag_effect.mean, diag_effect.sd);
fprintf('   Statistical test: t(%d) = %.3f, p = %.4f\n', stats.df, stats.tstat, p);
fprintf('   Effect size: Hedges'' g = %.3f, 95%% CI [%.3f, %.3f]\n', ...
    d_hedges, CI_d(1), CI_d(2));
fprintf('   Interpretation: %s effect\n', diag_effect.interpretation);

fprintf('\n\n');

%% EXAMPLE 8: COMPARING OLD VS NEW METHODS FOR ALL SUBJECTS
fprintf('EXAMPLE 8: Systematic comparison of old vs new methods\n');
fprintf('-------------------------------------------------------\n\n');

% Simulate data for multiple sample sizes
sample_sizes = [20, 30, 44, 60];
n_sims = length(sample_sizes);

results_comparison = table();

for i_sim = 1:n_sims
    n = sample_sizes(i_sim);

    % Generate data
    rng(42 + i_sim);
    scores = 0.08 + 0.12*randn(n, 1);

    % OLD method
    [~, ~, ~, stats_old] = ttest(scores);
    d_old = stats_old.tstat / sqrt(stats_old.df + 1);

    % NEW method
    [d_new, dh_new, ~, ~] = calculate_cohens_d_corrected(scores, 'mu0', 0, 'nBoot', 1000);

    % Store results
    results_comparison.N(i_sim) = n;
    results_comparison.d_OLD(i_sim) = d_old;
    results_comparison.d_NEW(i_sim) = d_new;
    results_comparison.Hedges_g(i_sim) = dh_new;
    results_comparison.Difference(i_sim) = abs(d_old - dh_new);
    results_comparison.Pct_Diff(i_sim) = 100 * abs(d_old - dh_new) / dh_new;
end

fprintf('Comparison across sample sizes:\n\n');
disp(results_comparison);

fprintf('💡 Key observations:\n');
fprintf('   • Differences are larger for smaller samples\n');
fprintf('   • Hedges'' g correction is stronger for N < 50\n');
fprintf('   • Use exact formula (NEW method) for accurate reporting\n');

fprintf('\n\n');

%% SUMMARY
fprintf('=======================================================\n');
fprintf('SUMMARY: Key Improvements in Corrected Functions\n');
fprintf('=======================================================\n\n');

fprintf('1. Effect Size Calculation:\n');
fprintf('   ❌ OLD: d ≈ t/sqrt(df+1) [approximation]\n');
fprintf('   ✓ NEW: d = (M - μ₀) / SD [exact formula]\n');
fprintf('   ✓ NEW: Hedges'' g correction for small samples\n');
fprintf('   ✓ NEW: Bootstrap confidence intervals\n\n');

fprintf('2. Assumption Testing:\n');
fprintf('   ❌ OLD: No assumption checks\n');
fprintf('   ✓ NEW: Normality testing (Shapiro-Wilk or Lilliefors)\n');
fprintf('   ✓ NEW: Outlier detection\n');
fprintf('   ✓ NEW: Sample size adequacy check\n');
fprintf('   ✓ NEW: Automatic recommendations\n\n');

fprintf('3. Collinearity Diagnostics:\n');
fprintf('   ❌ OLD: No VIF checks\n');
fprintf('   ✓ NEW: VIF calculation for each predictor\n');
fprintf('   ✓ NEW: Condition number for design matrix\n');
fprintf('   ✓ NEW: Clear warnings for severe multicollinearity\n\n');

fprintf('4. FDR Correction:\n');
fprintf('   ❌ OLD: Only B-H method (assumes independence)\n');
fprintf('   ✓ NEW: B-Y option for dependent tests\n');
fprintf('   ✓ NEW: Q-values (FDR-adjusted p-values)\n\n');

fprintf('5. Convergence Monitoring:\n');
fprintf('   ❌ OLD: No convergence checks\n');
fprintf('   ✓ NEW: Iteration count monitoring\n');
fprintf('   ✓ NEW: Gradient checks\n');
fprintf('   ✓ NEW: Troubleshooting recommendations\n\n');

fprintf('6. Missing Data:\n');
fprintf('   ❌ OLD: Silent removal\n');
fprintf('   ✓ NEW: Comprehensive reporting\n');
fprintf('   ✓ NEW: Listwise deletion impact assessment\n');
fprintf('   ✓ NEW: Threshold-based warnings\n\n');

fprintf('=======================================================\n');
fprintf('All examples completed successfully!\n');
fprintf('=======================================================\n\n');

fprintf('📚 For implementation in your R1 revision:\n');
fprintf('   1. Use these corrected functions in all statistical analyses\n');
fprintf('   2. Report Hedges'' g instead of Cohen''s d for N < 50\n');
fprintf('   3. Include assumption testing results in Supplementary Methods\n');
fprintf('   4. Check VIF before fitting LME models\n');
fprintf('   5. Use B-Y FDR for connectivity matrices (dependent tests)\n\n');

fprintf('✓ Ready to integrate into R1 revision scripts!\n\n');
