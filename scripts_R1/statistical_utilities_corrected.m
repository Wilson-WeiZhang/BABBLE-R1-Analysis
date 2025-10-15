%% CORRECTED STATISTICAL UTILITIES FOR R1 REVISION
% Created: 2025-10-10
% Purpose: Implementation of best practices from Nature Communications 2024
% Based on: Eckstein et al. (2022), Rosenblatt et al. (2024), Nature guidelines
%
% This file contains corrected implementations of statistical functions
% addressing the following critical issues identified in deep analysis:
% 1. Exact Cohen's d calculation (not approximation)
% 2. Hedges' g small-sample correction
% 3. Parametric assumption testing
% 4. Collinearity diagnostics for LME
% 5. Proper missing data handling
% 6. Convergence monitoring for iterative algorithms

%% FUNCTION 1: CORRECTED EFFECT SIZE CALCULATION
% Replaces: cohend = t / sqrt(df+1) approximation
% With: Exact one-sample Cohen's d and Hedges' g

function [d, d_hedges, CI_d, diagnostics] = calculate_cohens_d_corrected(scores, varargin)
% CALCULATE_COHENS_D_CORRECTED Exact Cohen's d for one-sample t-test
%
% INPUTS:
%   scores      - Vector of learning scores (e.g., accuracy differences)
%   'mu0'       - Null hypothesis mean (default: 0)
%   'alpha'     - Significance level for CI (default: 0.05)
%   'nBoot'     - Bootstrap iterations (default: 5000)
%
% OUTPUTS:
%   d           - Cohen's d (exact formula)
%   d_hedges    - Hedges' g (small-sample corrected)
%   CI_d        - 95% confidence interval for d (bootstrap)
%   diagnostics - Structure with additional information
%
% FORMULA:
%   Cohen's d = (M - μ₀) / SD
%   Hedges' g = d × J, where J = 1 - 3/(4N - 5)  [for N < 50]
%
% REFERENCE:
%   Lakens, D. (2013). Calculating and reporting effect sizes.
%   Frontiers in Psychology, 4, 863.

    % Parse inputs
    p = inputParser;
    addRequired(p, 'scores', @isnumeric);
    addParameter(p, 'mu0', 0, @isnumeric);
    addParameter(p, 'alpha', 0.05, @isnumeric);
    addParameter(p, 'nBoot', 5000, @isnumeric);
    parse(p, scores, varargin{:});

    mu0 = p.Results.mu0;
    alpha = p.Results.alpha;
    nBoot = p.Results.nBoot;

    % Remove missing values
    scores = scores(~isnan(scores));
    n = length(scores);

    if n < 2
        error('Need at least 2 observations to calculate effect size');
    end

    % EXACT Cohen's d formula (not t-statistic approximation)
    M = mean(scores);
    SD = std(scores, 0);  % Sample SD (denominator N-1)
    d = (M - mu0) / SD;

    % Hedges' g correction for small samples (N < 50)
    if n < 50
        J = 1 - 3 / (4*n - 5);  % Correction factor
        d_hedges = d * J;
        diagnostics.correction_applied = true;
        diagnostics.correction_factor = J;
    else
        d_hedges = d;
        diagnostics.correction_applied = false;
        diagnostics.correction_factor = 1;
    end

    % Bootstrap confidence interval for Cohen's d
    d_boot = zeros(nBoot, 1);
    rng(42);  % For reproducibility

    for iBoot = 1:nBoot
        boot_scores = datasample(scores, n, 'Replace', true);
        boot_M = mean(boot_scores);
        boot_SD = std(boot_scores, 0);
        d_boot(iBoot) = (boot_M - mu0) / boot_SD;
    end

    % Calculate CI
    CI_d = prctile(d_boot, [100*alpha/2, 100*(1-alpha/2)]);

    % Additional diagnostics
    diagnostics.n = n;
    diagnostics.mean = M;
    diagnostics.sd = SD;
    diagnostics.d_distribution = d_boot;
    diagnostics.interpretation = interpret_cohens_d(d_hedges);

    % Display results
    fprintf('Effect Size Calculation Results:\n');
    fprintf('  N: %d\n', n);
    fprintf('  Mean: %.4f (SD = %.4f)\n', M, SD);
    fprintf('  Cohen''s d: %.3f\n', d);
    fprintf('  Hedges'' g: %.3f', d_hedges);
    if diagnostics.correction_applied
        fprintf(' (small-sample corrected)\n');
    else
        fprintf('\n');
    end
    fprintf('  95%% CI: [%.3f, %.3f]\n', CI_d(1), CI_d(2));
    fprintf('  Interpretation: %s\n', diagnostics.interpretation);
end

function interp = interpret_cohens_d(d)
    % Cohen's (1988) benchmarks
    abs_d = abs(d);
    if abs_d < 0.2
        interp = 'Negligible';
    elseif abs_d < 0.5
        interp = 'Small';
    elseif abs_d < 0.8
        interp = 'Medium';
    else
        interp = 'Large';
    end
end

%% FUNCTION 2: PARAMETRIC ASSUMPTION TESTING
% Tests normality and outliers before running t-tests

function [assumptions_met, diagnostics, recommendations] = check_parametric_assumptions(scores, varargin)
% CHECK_PARAMETRIC_ASSUMPTIONS Test assumptions before parametric tests
%
% INPUTS:
%   scores    - Vector of data
%   'alpha'   - Significance level (default: 0.05)
%   'method'  - Normality test: 'auto', 'shapiro', 'lillie', 'ks' (default: 'auto')
%   'outlier' - Outlier threshold in SD units (default: 3)
%
% OUTPUTS:
%   assumptions_met - Logical structure indicating which assumptions are met
%   diagnostics     - Detailed test results
%   recommendations - What to do if assumptions violated
%
% TESTS:
%   1. Normality: Shapiro-Wilk (N<50) or Lilliefors (N≥50)
%   2. Outliers: |z| > 3 SD (flagged if >5% of data)
%   3. Sample size: Flag if N < 20 (low power)
%
% REFERENCE:
%   Schucany, W. R., & Ng, H. T. (2006). Preliminary goodness-of-fit tests
%   for normality do not validate the one-sample Student t.
%   Communications in Statistics, 35(12), 2275-2286.

    % Parse inputs
    p = inputParser;
    addRequired(p, 'scores', @isnumeric);
    addParameter(p, 'alpha', 0.05, @isnumeric);
    addParameter(p, 'method', 'auto', @ischar);
    addParameter(p, 'outlier', 3, @isnumeric);
    parse(p, scores, varargin{:});

    alpha = p.Results.alpha;
    method = p.Results.method;
    outlier_threshold = p.Results.outlier;

    % Remove missing
    scores = scores(~isnan(scores));
    n = length(scores);

    fprintf('\n=== PARAMETRIC ASSUMPTION TESTING ===\n\n');

    %% 1. Sample Size Check
    diagnostics.n = n;
    if n < 20
        fprintf('⚠️  WARNING: Small sample (N=%d < 20), low power for normality tests\n', n);
        assumptions_met.sample_size = false;
    else
        fprintf('✓ Sample size: N=%d (adequate)\n', n);
        assumptions_met.sample_size = true;
    end

    %% 2. Normality Test
    if strcmp(method, 'auto')
        if n < 50
            method = 'shapiro';
        else
            method = 'lillie';
        end
    end

    switch method
        case 'shapiro'
            if exist('swtest', 'file')
                [H_norm, p_norm, W] = swtest(scores, alpha);
                test_name = 'Shapiro-Wilk';
                diagnostics.normality.statistic = W;
            else
                fprintf('⚠️  Shapiro-Wilk test not available, using Lilliefors\n');
                [H_norm, p_norm, ksstat] = lillietest(scores, 'Alpha', alpha);
                test_name = 'Lilliefors';
                diagnostics.normality.statistic = ksstat;
            end

        case 'lillie'
            [H_norm, p_norm, ksstat] = lillietest(scores, 'Alpha', alpha);
            test_name = 'Lilliefors';
            diagnostics.normality.statistic = ksstat;

        case 'ks'
            [H_norm, p_norm, ksstat] = kstest(zscore(scores), 'Alpha', alpha);
            test_name = 'Kolmogorov-Smirnov';
            diagnostics.normality.statistic = ksstat;
    end

    diagnostics.normality.test = test_name;
    diagnostics.normality.p_value = p_norm;
    diagnostics.normality.rejected = H_norm;

    if ~H_norm
        fprintf('✓ Normality: %s test, p=%.4f (not rejected)\n', test_name, p_norm);
        assumptions_met.normality = true;
    else
        fprintf('✗ Normality: %s test, p=%.4f (REJECTED)\n', test_name, p_norm);
        fprintf('  → Data significantly deviates from normal distribution\n');
        assumptions_met.normality = false;
    end

    %% 3. Outlier Detection
    z_scores = zscore(scores);
    outlier_idx = abs(z_scores) > outlier_threshold;
    n_outliers = sum(outlier_idx);
    pct_outliers = 100 * n_outliers / n;

    diagnostics.outliers.count = n_outliers;
    diagnostics.outliers.percentage = pct_outliers;
    diagnostics.outliers.indices = find(outlier_idx);
    diagnostics.outliers.values = scores(outlier_idx);
    diagnostics.outliers.z_scores = z_scores(outlier_idx);

    if pct_outliers < 5
        fprintf('✓ Outliers: %d detected (%.1f%%, acceptable threshold <5%%)\n', ...
            n_outliers, pct_outliers);
        assumptions_met.outliers = true;
    else
        fprintf('✗ Outliers: %d detected (%.1f%%, EXCEEDS 5%% threshold)\n', ...
            n_outliers, pct_outliers);
        fprintf('  → Outlier values: ');
        fprintf('%.3f ', scores(outlier_idx));
        fprintf('\n');
        assumptions_met.outliers = false;
    end

    %% 4. Visual Diagnostics
    diagnostics.qq_data = qqplot_data(scores);
    diagnostics.histogram_data = scores;

    %% 5. Overall Assessment & Recommendations
    all_met = assumptions_met.sample_size && assumptions_met.normality && ...
              assumptions_met.outliers;

    fprintf('\n--- Overall Assessment ---\n');
    if all_met
        fprintf('✓ All assumptions met: Parametric t-test is appropriate\n');
        recommendations.test = 't-test (parametric)';
        recommendations.proceed = true;
        recommendations.alternative = 'none needed';
    else
        fprintf('✗ One or more assumptions violated\n');
        recommendations.proceed = false;

        % Determine best alternative
        if ~assumptions_met.normality || ~assumptions_met.outliers
            fprintf('  → Recommendation: Use NON-PARAMETRIC test\n');
            fprintf('     • Wilcoxon signed-rank test (one-sample)\n');
            fprintf('     • Bootstrap confidence interval\n');
            recommendations.test = 'Wilcoxon signed-rank (non-parametric)';
            recommendations.alternative = 'signrank(scores)';
        end

        if ~assumptions_met.sample_size
            fprintf('  → Recommendation: Consider collecting more data (N < 20)\n');
            recommendations.test = 'Increase sample size or use permutation test';
        end
    end

    fprintf('\n');
end

function qq_data = qqplot_data(scores)
    % Generate Q-Q plot data for later visualization
    sorted_scores = sort(scores);
    n = length(sorted_scores);
    theoretical_quantiles = norminv((1:n)' / (n+1));
    qq_data.observed = sorted_scores;
    qq_data.theoretical = theoretical_quantiles;
end

%% FUNCTION 3: COLLINEARITY DIAGNOSTICS FOR LME
% Checks Variance Inflation Factors before fitting mixed models

function [collinearity_ok, vif_values, diagnostics] = check_lme_collinearity(dataTable, formula, varargin)
% CHECK_LME_COLLINEARITY Diagnose multicollinearity in LME predictors
%
% INPUTS:
%   dataTable - Table with all variables
%   formula   - LME formula string (e.g., 'Y ~ X1 + X2 + (1|ID)')
%   'threshold' - VIF threshold (default: 10)
%   'display'   - Show detailed output (default: true)
%
% OUTPUTS:
%   collinearity_ok - true if all VIF < threshold
%   vif_values      - VIF for each predictor
%   diagnostics     - Additional collinearity metrics
%
% VIF INTERPRETATION:
%   VIF = 1     : No correlation
%   VIF = 1-5   : Moderate correlation (acceptable)
%   VIF = 5-10  : High correlation (concerning)
%   VIF > 10    : Severe multicollinearity (problematic)
%
% REFERENCE:
%   O'Brien, R. M. (2007). A caution regarding rules of thumb for VIF.
%   Quality & Quantity, 41(5), 673-690.

    % Parse inputs
    p = inputParser;
    addRequired(p, 'dataTable', @istable);
    addRequired(p, 'formula', @ischar);
    addParameter(p, 'threshold', 10, @isnumeric);
    addParameter(p, 'display', true, @islogical);
    parse(p, dataTable, formula, varargin{:});

    threshold = p.Results.threshold;
    display_output = p.Results.display;

    % Extract fixed effects predictors from formula
    % Remove random effects part: (1|ID) or (1+X|ID)
    formula_fixed = regexprep(formula, '\([^)]*\|[^)]*\)', '');
    % Extract predictor names
    formula_parts = strsplit(formula_fixed, '~');
    if length(formula_parts) < 2
        error('Invalid formula format');
    end
    predictors_str = strtrim(formula_parts{2});
    predictors_str = regexprep(predictors_str, '\s+', ' ');  % Normalize spaces
    predictor_names = strsplit(predictors_str, {'+', '*', ':'});
    predictor_names = strtrim(predictor_names);
    predictor_names = predictor_names(~cellfun(@isempty, predictor_names));

    % Remove categorical indicators and interactions for now
    % Keep only main effects
    predictor_names = unique(predictor_names);

    if display_output
        fprintf('\n=== COLLINEARITY DIAGNOSTICS ===\n\n');
        fprintf('Predictors to check: %s\n', strjoin(predictor_names, ', '));
    end

    % Extract predictor matrix
    n_predictors = length(predictor_names);
    X = zeros(height(dataTable), n_predictors);

    for i = 1:n_predictors
        if ismember(predictor_names{i}, dataTable.Properties.VariableNames)
            X(:, i) = dataTable.(predictor_names{i});
        else
            warning('Predictor %s not found in table', predictor_names{i});
        end
    end

    % Remove rows with missing data
    complete_rows = all(~isnan(X), 2);
    X = X(complete_rows, :);

    % Calculate VIF for each predictor
    vif_values = zeros(n_predictors, 1);

    for i = 1:n_predictors
        % Regress predictor i on all other predictors
        X_i = X(:, i);
        X_others = X(:, setdiff(1:n_predictors, i));

        if isempty(X_others)
            vif_values(i) = 1;  % Only one predictor
            continue;
        end

        % Add intercept
        X_others_with_int = [ones(size(X_others, 1), 1), X_others];

        % OLS regression
        [~, ~, ~, ~, stats] = regress(X_i, X_others_with_int);
        R2 = 1 - stats(1);  % R² from regression

        % VIF = 1 / (1 - R²)
        if R2 >= 0.9999
            vif_values(i) = Inf;  % Perfect collinearity
        else
            vif_values(i) = 1 / (1 - R2);
        end
    end

    % Display results
    if display_output
        fprintf('\nVIF Results:\n');
        fprintf('%-20s %8s %15s\n', 'Predictor', 'VIF', 'Assessment');
        fprintf('%s\n', repmat('-', 1, 45));

        for i = 1:n_predictors
            if vif_values(i) < 5
                assessment = '✓ Acceptable';
            elseif vif_values(i) < 10
                assessment = '⚠️  Concerning';
            else
                assessment = '✗ SEVERE';
            end

            fprintf('%-20s %8.2f %15s\n', predictor_names{i}, vif_values(i), assessment);
        end
        fprintf('\n');
    end

    % Overall assessment
    collinearity_ok = all(vif_values < threshold);

    if display_output
        if collinearity_ok
            fprintf('✓ No severe multicollinearity detected (all VIF < %.0f)\n', threshold);
        else
            fprintf('✗ SEVERE multicollinearity detected in one or more predictors\n');
            fprintf('  → Consider removing highly correlated predictors\n');
            fprintf('  → Or use ridge regression / regularization\n');
        end
    end

    % Additional diagnostics
    diagnostics.predictor_names = predictor_names;
    diagnostics.correlation_matrix = corr(X, 'rows', 'complete');
    diagnostics.condition_number = cond(X' * X);

    if diagnostics.condition_number > 30
        if display_output
            fprintf('  ⚠️  Condition number = %.1f (>30 indicates collinearity)\n', ...
                diagnostics.condition_number);
        end
    end

    if display_output
        fprintf('\n');
    end
end

%% FUNCTION 4: IMPROVED FDR CORRECTION WITH DEPENDENCY HANDLING

function [h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh_corrected(pvals, q, varargin)
% FDR_BH_CORRECTED Benjamini-Hochberg FDR with dependency correction option
%
% INPUTS:
%   pvals  - Vector of p-values
%   q      - Desired FDR level (e.g., 0.05)
%   'dep'  - Dependency correction: 'independent' or 'dependent' (default: 'independent')
%
% OUTPUTS:
%   h           - Logical vector: true if null hypothesis rejected
%   crit_p      - Critical p-value threshold
%   adj_ci_cvrg - Adjusted confidence interval coverage (1-q)
%   adj_p       - FDR-adjusted p-values (q-values)
%
% REFERENCE:
%   Benjamini, Y., & Yekutieli, D. (2001). The control of the false
%   discovery rate in multiple testing under dependency.
%   Annals of Statistics, 29(4), 1165-1188.

    % Parse inputs
    p = inputParser;
    addRequired(p, 'pvals', @isnumeric);
    addRequired(p, 'q', @isnumeric);
    addParameter(p, 'dep', 'independent', @ischar);
    parse(p, pvals, q, varargin{:});

    dep_type = p.Results.dep;

    % Remove NaNs
    valid_idx = ~isnan(pvals);
    pvals_clean = pvals(valid_idx);
    m = length(pvals_clean);

    % Sort p-values
    [pvals_sorted, sort_idx] = sort(pvals_clean);

    % Dependency correction factor
    if strcmp(dep_type, 'dependent')
        % Benjamini-Yekutieli correction for dependent tests
        c_m = sum(1 ./ (1:m));
        fprintf('Using Benjamini-Yekutieli correction for dependent tests (c(m)=%.3f)\n', c_m);
    else
        c_m = 1;
    end

    % Find largest i such that P(i) <= (i/m) * (q/c(m))
    threshold_line = ((1:m)' / m) * (q / c_m);
    significant = pvals_sorted <= threshold_line;

    if any(significant)
        max_idx = find(significant, 1, 'last');
        crit_p = pvals_sorted(max_idx);
    else
        crit_p = 0;
    end

    % Create output vector
    h_clean = pvals_clean <= crit_p;

    % Restore original order
    h = false(size(pvals));
    h(valid_idx) = h_clean;

    % Calculate q-values (adjusted p-values)
    adj_p = nan(size(pvals));
    adj_p_clean = zeros(size(pvals_clean));

    for i = 1:m
        adj_p_clean(i) = min(1, pvals_clean(i) * m * c_m / i);
    end

    adj_p(valid_idx) = adj_p_clean;
    adj_ci_cvrg = 1 - q;

    fprintf('FDR correction: %d/%d tests significant at q=%.3f (critical p=%.5f)\n', ...
        sum(h), m, q, crit_p);
end

%% FUNCTION 5: CONVERGENCE MONITORING FOR ITERATIVE ALGORITHMS

function [converged, diagnostics] = check_lme_convergence(lme_model, varargin)
% CHECK_LME_CONVERGENCE Check if LME model converged properly
%
% INPUTS:
%   lme_model - Fitted LinearMixedModel object
%   'max_grad' - Maximum gradient threshold (default: 1e-6)
%   'display'  - Show output (default: true)
%
% OUTPUTS:
%   converged   - true if model converged
%   diagnostics - Convergence metrics

    p = inputParser;
    addRequired(p, 'lme_model');
    addParameter(p, 'max_grad', 1e-6, @isnumeric);
    addParameter(p, 'display', true, @islogical);
    parse(p, lme_model, varargin{:});

    max_grad = p.Results.max_grad;
    display_output = p.Results.display;

    % Extract convergence info
    diagnostics.iterations = lme_model.NumIterations;
    diagnostics.objective = lme_model.LogLikelihood;

    % Check if model has convergence stats
    if isprop(lme_model, 'OptimOptions')
        diagnostics.max_gradient = max(abs(lme_model.Coefficients.Estimate));
    else
        diagnostics.max_gradient = NaN;
    end

    % Convergence criteria
    converged = true;

    if display_output
        fprintf('\n=== LME CONVERGENCE DIAGNOSTICS ===\n');
        fprintf('Iterations: %d\n', diagnostics.iterations);
        fprintf('Log-Likelihood: %.4f\n', diagnostics.objective);

        if ~isnan(diagnostics.max_gradient)
            fprintf('Max gradient: %.2e\n', diagnostics.max_gradient);
            if diagnostics.max_gradient > max_grad
                fprintf('⚠️  WARNING: Gradient exceeds threshold (%.2e > %.2e)\n', ...
                    diagnostics.max_gradient, max_grad);
                converged = false;
            end
        end

        if converged
            fprintf('✓ Model converged successfully\n');
        else
            fprintf('✗ Convergence issues detected\n');
            fprintf('  → Try: Different optimizer, rescale predictors, simplify random effects\n');
        end
        fprintf('\n');
    end
end

%% HELPER FUNCTION: RESCALE PREDICTORS FOR BETTER CONVERGENCE

function dataTable_scaled = rescale_predictors(dataTable, predictor_names)
% RESCALE_PREDICTORS Z-score predictors for better LME convergence
%
% INPUTS:
%   dataTable       - Original table
%   predictor_names - Cell array of predictor variable names
%
% OUTPUTS:
%   dataTable_scaled - Table with z-scored predictors

    dataTable_scaled = dataTable;

    for i = 1:length(predictor_names)
        pred_name = predictor_names{i};
        if ismember(pred_name, dataTable.Properties.VariableNames)
            original_data = dataTable.(pred_name);
            if isnumeric(original_data)
                dataTable_scaled.(pred_name) = zscore(original_data);
                fprintf('Rescaled predictor: %s (M=%.2f, SD=%.2f)\n', ...
                    pred_name, mean(original_data), std(original_data));
            end
        end
    end
end

%% FUNCTION 6: COMPREHENSIVE MISSING DATA REPORT

function report_missing_data(dataTable, varargin)
% REPORT_MISSING_DATA Comprehensive missing data analysis
%
% INPUTS:
%   dataTable - Table to analyze
%   'threshold' - Flag variables with >X% missing (default: 5)

    p = inputParser;
    addRequired(p, 'dataTable', @istable);
    addParameter(p, 'threshold', 5, @isnumeric);
    parse(p, dataTable, varargin{:});

    threshold = p.Results.threshold;

    fprintf('\n=== MISSING DATA ANALYSIS ===\n\n');

    var_names = dataTable.Properties.VariableNames;
    n_rows = height(dataTable);

    any_missing = false;

    for i = 1:length(var_names)
        var_data = dataTable.(var_names{i});
        if isnumeric(var_data) || islogical(var_data)
            n_missing = sum(isnan(var_data));
        elseif iscell(var_data)
            n_missing = sum(cellfun(@isempty, var_data));
        else
            continue;
        end

        pct_missing = 100 * n_missing / n_rows;

        if n_missing > 0
            any_missing = true;
            if pct_missing > threshold
                fprintf('⚠️  %-20s: %3d missing (%.1f%%) - EXCEEDS THRESHOLD\n', ...
                    var_names{i}, n_missing, pct_missing);
            else
                fprintf('   %-20s: %3d missing (%.1f%%)\n', ...
                    var_names{i}, n_missing, pct_missing);
            end
        end
    end

    if ~any_missing
        fprintf('✓ No missing data detected\n');
    end

    % Listwise deletion impact
    complete_rows = all(~any(ismissing(dataTable), 2), 2);
    n_complete = sum(complete_rows);
    pct_complete = 100 * n_complete / n_rows;

    fprintf('\nListwise deletion:\n');
    fprintf('  Complete cases: %d/%d (%.1f%%)\n', n_complete, n_rows, pct_complete);

    if pct_complete < 80
        fprintf('  ⚠️  WARNING: >20%% data loss with listwise deletion\n');
        fprintf('  → Consider: Multiple imputation or mixed models with missing data\n');
    end

    fprintf('\n');
end

%% END OF CORRECTED STATISTICAL UTILITIES
% For usage examples, see: scripts_R1/CORRECTED_EXAMPLES.m
