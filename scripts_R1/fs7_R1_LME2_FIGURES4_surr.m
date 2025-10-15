%% ========================================================================
%  fs7_R1_LME2_FIGURES4_surr.m
%  ========================================================================
%
%  PURPOSE:
%  Supplementary analysis for Adult Fz → Infant F4 connection
%  Addresses Reviewer Comment 1.2:
%    - Test gaze-modulated connection against surrogate data
%    - Examine behavioral relevance (Learning prediction)
%
%  ANALYSES:
%  Part 1: Surrogate Tests (4 conditions)
%    - Cond 1 (Full gaze) vs surrogate
%    - Cond 2 (Partial gaze) vs surrogate
%    - Cond 3 (No gaze) vs surrogate
%    - Cond pooled (1-3) vs surrogate
%
%  Part 2: Behavioral Analysis
%    - Linear model: Fz-F4 → Learning (controlling covariates)
%    - Extract statistics for reporting
%
%  INPUT:
%  - data_read_surr_gpdc2.mat (from fs4_readdata.m)
%
%  OUTPUT:
%  - Console output with detailed statistics
%  - Figure with surrogate tests and behavioral correlation
%  - Results saved to results_FzF4_surr_learning.mat
%
%  RELATED FILES:
%  - fs7_R1_LME2_FIGURES4.m (main behavioral analysis)
%  - fs5_strongpdc.m (surrogate test template)
%
%  DATE: 2025-10-15
%  ========================================================================

clc
clear all

fprintf('========================================================================\n');
fprintf('SUPPLEMENTARY ANALYSIS: Adult Fz → Infant F4 Connection\n');
fprintf('Surrogate Testing + Learning Prediction\n');
fprintf('========================================================================\n\n');

%% Load data
fprintf('Loading data...\n');
load('data_read_surr_gpdc2.mat', 'data_surr', 'data');
fprintf('  Data loaded: %d samples, %d surrogates\n', size(data, 1), length(data_surr));

%% Extract behavioral variables
a = data;
AGE = a(:, 3);
SEX = a(:, 4);
SEX_cat = categorical(SEX);
COUNTRY = a(:, 1);
COUNTRY_cat = categorical(COUNTRY);
blocks = a(:, 5);
CONDGROUP = a(:, 6);
learning = a(:, 7);
atten = a(:, 9);
ID = a(:, 2);
ID_cat = categorical(ID);

fprintf('\nSample composition:\n');
fprintf('  Total samples: %d\n', size(a, 1));
fprintf('  Condition 1 (Full gaze): %d\n', sum(CONDGROUP == 1));
fprintf('  Condition 2 (Partial gaze): %d\n', sum(CONDGROUP == 2));
fprintf('  Condition 3 (No gaze): %d\n', sum(CONDGROUP == 3));
fprintf('\n');

%% Define Fz-F4 connection

% Extract AI alpha connections (same as fs7_R1_LME2_FIGURES4.m)
ai3 = [10+81*8:9+81*9];  % AI Alpha band columns
data_conn = sqrt(data(:, ai3));

% Fz-F4 is column 12 in AI alpha band
% This corresponds to: Adult Fz (source) → Infant F4 (destination)
col_FzF4 = 12;
connection_name = 'AI_Alpha_Fz_to_F4';

fprintf('Target connection: %s\n', connection_name);
fprintf('Column index in AI Alpha: %d\n', col_FzF4);
fprintf('Global column index: %d\n\n', ai3(col_FzF4));

% Extract Fz-F4 data (sqrt-transformed)
real_FzF4 = data_conn(:, col_FzF4);

%% Define condition groups
group1_idx = find(CONDGROUP == 1);  % Full gaze
group2_idx = find(CONDGROUP == 2);  % Partial gaze
group3_idx = find(CONDGROUP == 3);  % No gaze
group4_idx = 1:size(a, 1);          % Pooled (all conditions)
group5_idx = find(CONDGROUP == 2 | CONDGROUP == 3);  % Partial + No gaze pooled

%% ========================================================================
%  PART 1: SURROGATE TESTS
%  ========================================================================

fprintf('========================================================================\n');
fprintf('PART 1: SURROGATE TESTS FOR Fz-F4 CONNECTION\n');
fprintf('========================================================================\n\n');

n_surr = length(data_surr);
fprintf('Extracting surrogate data for Fz-F4 connection...\n');
fprintf('Number of surrogates: %d\n\n', n_surr);

% Initialize surrogate data matrix
surr_FzF4 = zeros(size(a, 1), n_surr);

% Extract Fz-F4 from each surrogate
for i = 1:n_surr
    if mod(i, 100) == 0
        fprintf('  Processing surrogate %d/%d...\n', i, n_surr);
    end

    % Extract AI alpha from surrogate
    surr_conn = sqrt(data_surr{i}(:, ai3));
    surr_FzF4(:, i) = surr_conn(:, col_FzF4);
end
fprintf('Done!\n\n');

%% Calculate means for each condition

% Real data means
real_mean_g1 = nanmean(real_FzF4(group1_idx));
real_mean_g2 = nanmean(real_FzF4(group2_idx));
real_mean_g3 = nanmean(real_FzF4(group3_idx));
real_mean_g4 = nanmean(real_FzF4(group4_idx));
real_mean_g5 = nanmean(real_FzF4(group5_idx));

% Surrogate means for each condition
surr_mean_g1 = zeros(n_surr, 1);
surr_mean_g2 = zeros(n_surr, 1);
surr_mean_g3 = zeros(n_surr, 1);
surr_mean_g4 = zeros(n_surr, 1);
surr_mean_g5 = zeros(n_surr, 1);

fprintf('Computing surrogate distributions by condition...\n');
for i = 1:n_surr
    surr_mean_g1(i) = nanmean(surr_FzF4(group1_idx, i));
    surr_mean_g2(i) = nanmean(surr_FzF4(group2_idx, i));
    surr_mean_g3(i) = nanmean(surr_FzF4(group3_idx, i));
    surr_mean_g4(i) = nanmean(surr_FzF4(group4_idx, i));
    surr_mean_g5(i) = nanmean(surr_FzF4(group5_idx, i));
end
fprintf('Done!\n\n');

%% Statistical testing

% Calculate p-values (permutation test)
p_g1 = (sum(surr_mean_g1 >= real_mean_g1) + 1) / (n_surr + 1);
p_g2 = (sum(surr_mean_g2 >= real_mean_g2) + 1) / (n_surr + 1);
p_g3 = (sum(surr_mean_g3 >= real_mean_g3) + 1) / (n_surr + 1);
p_g4 = (sum(surr_mean_g4 >= real_mean_g4) + 1) / (n_surr + 1);
p_g5 = (sum(surr_mean_g5 >= real_mean_g5) + 1) / (n_surr + 1);

% Calculate percentiles
surr_mean_g1_mean = mean(surr_mean_g1);
surr_mean_g2_mean = mean(surr_mean_g2);
surr_mean_g3_mean = mean(surr_mean_g3);
surr_mean_g4_mean = mean(surr_mean_g4);
surr_mean_g5_mean = mean(surr_mean_g5);

surr_mean_g1_std = std(surr_mean_g1);
surr_mean_g2_std = std(surr_mean_g2);
surr_mean_g3_std = std(surr_mean_g3);
surr_mean_g4_std = std(surr_mean_g4);
surr_mean_g5_std = std(surr_mean_g5);

surr_95_g1 = prctile(surr_mean_g1, 95);
surr_95_g2 = prctile(surr_mean_g2, 95);
surr_95_g3 = prctile(surr_mean_g3, 95);
surr_95_g4 = prctile(surr_mean_g4, 95);
surr_95_g5 = prctile(surr_mean_g5, 95);

%% Display results

fprintf('========================================================================\n');
fprintf('SURROGATE TEST RESULTS: %s\n', connection_name);
fprintf('========================================================================\n\n');

fprintf('Condition 1 (Full Gaze):\n');
fprintf('  N = %d samples\n', length(group1_idx));
fprintf('  Real mean:        %.6f\n', real_mean_g1);
fprintf('  Surrogate mean:   %.6f (SD = %.6f)\n', surr_mean_g1_mean, surr_mean_g1_std);
fprintf('  Surrogate 95%%:    %.6f\n', surr_95_g1);
fprintf('  p-value:          %.4f %s\n', p_g1, get_sig_stars(p_g1));
fprintf('  Significant:      %s\n\n', iif(real_mean_g1 > surr_95_g1, 'YES (Real > Surrogate)', 'NO'));

fprintf('Condition 2 (Partial Gaze):\n');
fprintf('  N = %d samples\n', length(group2_idx));
fprintf('  Real mean:        %.6f\n', real_mean_g2);
fprintf('  Surrogate mean:   %.6f (SD = %.6f)\n', surr_mean_g2_mean, surr_mean_g2_std);
fprintf('  Surrogate 95%%:    %.6f\n', surr_95_g2);
fprintf('  p-value:          %.4f %s\n', p_g2, get_sig_stars(p_g2));
fprintf('  Significant:      %s\n\n', iif(real_mean_g2 > surr_95_g2, 'YES (Real > Surrogate)', 'NO'));

fprintf('Condition 3 (No Gaze):\n');
fprintf('  N = %d samples\n', length(group3_idx));
fprintf('  Real mean:        %.6f\n', real_mean_g3);
fprintf('  Surrogate mean:   %.6f (SD = %.6f)\n', surr_mean_g3_mean, surr_mean_g3_std);
fprintf('  Surrogate 95%%:    %.6f\n', surr_95_g3);
fprintf('  p-value:          %.4f\n', p_g3);
fprintf('  Significant:      %s\n\n', iif(real_mean_g3 > surr_95_g3, 'YES (Real > Surrogate)', 'NO'));

fprintf('Condition Pooled (All Conditions):\n');
fprintf('  N = %d samples\n', length(group4_idx));
fprintf('  Real mean:        %.6f\n', real_mean_g4);
fprintf('  Surrogate mean:   %.6f (SD = %.6f)\n', surr_mean_g4_mean, surr_mean_g4_std);
fprintf('  Surrogate 95%%:    %.6f\n', surr_95_g4);
fprintf('  p-value:          %.4f %s\n', p_g4, get_sig_stars(p_g4));
fprintf('  Significant:      %s\n\n', iif(real_mean_g4 > surr_95_g4, 'YES (Real > Surrogate)', 'NO'));

fprintf('Condition Pooled (Partial + No Gaze):\n');
fprintf('  N = %d samples\n', length(group5_idx));
fprintf('  Real mean:        %.6f\n', real_mean_g5);
fprintf('  Surrogate mean:   %.6f (SD = %.6f)\n', surr_mean_g5_mean, surr_mean_g5_std);
fprintf('  Surrogate 95%%:    %.6f\n', surr_95_g5);
fprintf('  p-value:          %.4f %s\n', p_g5, get_sig_stars(p_g5));
fprintf('  Significant:      %s\n\n', iif(real_mean_g5 > surr_95_g5, 'YES (Real > Surrogate)', 'NO'));

fprintf('========================================================================\n\n');

%% ========================================================================
%  PART 2: BEHAVIORAL ANALYSIS - Fz-F4 → Learning
%  ========================================================================

fprintf('========================================================================\n');
fprintf('PART 2: BEHAVIORAL ANALYSIS - Fz-F4 → Learning\n');
fprintf('========================================================================\n\n');

fprintf('NOTE: Using Condition 1 (Full Gaze) only for behavioral analysis\n');
fprintf('Rationale: Condition 1 shows strongest Fz-F4 connection\n\n');

% Extract Condition 1 data
FzF4_cond1 = real_FzF4(group1_idx);
learning_cond1 = learning(group1_idx);
age_cond1 = AGE(group1_idx);
sex_cond1 = SEX(group1_idx);
country_cond1 = COUNTRY(group1_idx);
id_cond1 = ID(group1_idx);

% Remove NaN in learning
valid_idx = ~isnan(learning_cond1);
FzF4_cond1_valid = FzF4_cond1(valid_idx);
learning_cond1_valid = learning_cond1(valid_idx);
age_cond1_valid = age_cond1(valid_idx);
sex_cond1_valid = sex_cond1(valid_idx);
country_cond1_valid = country_cond1(valid_idx);
id_cond1_valid = id_cond1(valid_idx);

fprintf('Valid samples for analysis: %d\n\n', sum(valid_idx));

%% Simple correlation
fprintf('Analysis 1: Simple Correlation\n');
fprintf('------------------------------------------------------------\n');

[r_simple, p_simple] = corr(FzF4_cond1_valid, learning_cond1_valid);

fprintf('  r = %.4f\n', r_simple);
fprintf('  p = %.4f %s\n\n', p_simple, get_sig_stars(p_simple));

%% Partial correlation (controlling covariates)
fprintf('Analysis 2: Partial Correlation (controlling Age, Sex, Country)\n');
fprintf('------------------------------------------------------------\n');

covariates = [age_cond1_valid, sex_cond1_valid, country_cond1_valid];
[r_partial, p_partial] = partialcorr(learning_cond1_valid, FzF4_cond1_valid, covariates);

fprintf('  r = %.4f\n', r_partial);
fprintf('  p = %.4f %s\n\n', p_partial, get_sig_stars(p_partial));

%% Linear regression
fprintf('Analysis 3: Linear Regression Model\n');
fprintf('------------------------------------------------------------\n');
fprintf('Model: Learning ~ Fz-F4 + Age + Sex + Country\n\n');

% Create table
tbl = table(FzF4_cond1_valid, learning_cond1_valid, age_cond1_valid, ...
    categorical(sex_cond1_valid), categorical(country_cond1_valid), ...
    'VariableNames', {'FzF4', 'Learning', 'Age', 'Sex', 'Country'});

% Fit model
mdl_learning = fitlm(tbl, 'Learning ~ FzF4 + Age + Sex + Country');

% Display full model
disp(mdl_learning);

% Extract key statistics for Fz-F4
beta_FzF4 = mdl_learning.Coefficients{'FzF4', 'Estimate'};
se_FzF4 = mdl_learning.Coefficients{'FzF4', 'SE'};
t_FzF4 = mdl_learning.Coefficients{'FzF4', 'tStat'};
p_FzF4 = mdl_learning.Coefficients{'FzF4', 'pValue'};
df_error = mdl_learning.DFE;
R2_model = mdl_learning.Rsquared.Ordinary;  % Full model R²
R2_adj = mdl_learning.Rsquared.Adjusted;

% Calculate R² from simple correlation (r²)
R2 = r_simple^2;

fprintf('\n--- KEY RESULTS FOR Fz-F4 PREDICTOR ---\n');
fprintf('  β (unstandardized) = %.4f\n', beta_FzF4);
fprintf('  SE = %.4f\n', se_FzF4);
fprintf('  t(%d) = %.3f\n', df_error, t_FzF4);
fprintf('  p = %.4f %s\n', p_FzF4, get_sig_stars(p_FzF4));
fprintf('\n  R² (from r²) = %.4f\n', R2);
fprintf('  Full model R² = %.4f\n', R2_model);
fprintf('  Adjusted R² = %.4f\n', R2_adj);
fprintf('\n');

%% Analysis 4: Surrogate test for R² (behavioral prediction)
fprintf('Analysis 4: Surrogate Test for Behavioral Prediction\n');
fprintf('------------------------------------------------------------\n');
fprintf('Testing if real R² exceeds surrogate R² distribution...\n\n');

% Extract surrogate Fz-F4 for Cond=1, valid samples
surr_r2 = zeros(n_surr, 1);

fprintf('Computing correlation for each surrogate...\n');
for i = 1:n_surr
    if mod(i, 100) == 0
        fprintf('  Processing surrogate %d/%d...\n', i, n_surr);
    end

    % Extract surrogate Fz-F4 for cond=1, valid samples
    surr_FzF4_cond1 = surr_FzF4(group1_idx, i);
    surr_FzF4_cond1_valid = surr_FzF4_cond1(valid_idx);

    % Compute correlation with learning
    r_surr = corr(surr_FzF4_cond1_valid, learning_cond1_valid);
    surr_r2(i) = r_surr^2;
end
fprintf('Done!\n\n');

% Calculate statistics
surr_r2_mean = mean(surr_r2);
surr_r2_std = std(surr_r2);
surr_r2_95 = prctile(surr_r2, 95);

% Calculate p-value (permutation test)
p_r2 = (sum(surr_r2 >= R2) + 1) / (n_surr + 1);

fprintf('Results:\n');
fprintf('  Real R²:         %.4f\n', R2);
fprintf('  Surrogate mean:  %.4f (SD = %.4f)\n', surr_r2_mean, surr_r2_std);
fprintf('  Surrogate 95%%:   %.4f\n', surr_r2_95);
fprintf('  p-value:         %.4f %s\n', p_r2, get_sig_stars(p_r2));
fprintf('  Significant:     %s\n\n', iif(R2 > surr_r2_95, 'YES (Real > Surrogate)', 'NO'));

if p_r2 < 0.05
    fprintf('*** SIGNIFICANT BEHAVIORAL PREDICTION DETECTED ***\n');
    fprintf('Fz-F4 connectivity significantly predicts learning beyond chance.\n\n');
else
    fprintf('Fz-F4 does not predict learning beyond chance level.\n\n');
end

fprintf('========================================================================\n\n');

%% ========================================================================
%  PART 3: VISUALIZATION
%  ========================================================================

fprintf('Creating visualization...\n');

figure('Position', [100, 100, 1600, 900]);

%% Subplot 1: Bar plot - Surrogate test by condition
subplot(2, 4, 1);
conds = {'Full\nGaze', 'Partial\nGaze', 'No\nGaze', 'All\nPooled', 'P+N\nPooled'};
real_means = [real_mean_g1, real_mean_g2, real_mean_g3, real_mean_g4, real_mean_g5];
surr_95s = [surr_95_g1, surr_95_g2, surr_95_g3, surr_95_g4, surr_95_g5];
p_values = [p_g1, p_g2, p_g3, p_g4, p_g5];

b = bar(1:5, real_means, 'FaceColor', 'flat');
% Color by significance
for i = 1:5
    if p_values(i) < 0.05
        b.CData(i,:) = [0.2, 0.6, 0.8];  % Blue for significant
    else
        b.CData(i,:) = [0.7, 0.7, 0.7];  % Gray for non-significant
    end
end

hold on;
plot(1:5, surr_95s, 'r--', 'LineWidth', 2, 'DisplayName', 'Surrogate 95%');

% Add significance stars
for i = 1:5
    if p_values(i) < 0.001
        text(i, real_means(i), '***', 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', 'FontSize', 14);
    elseif p_values(i) < 0.01
        text(i, real_means(i), '**', 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', 'FontSize', 14);
    elseif p_values(i) < 0.05
        text(i, real_means(i), '*', 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', 'FontSize', 14);
    end
end

set(gca, 'XTickLabel', conds);
ylabel('GPDC Strength (sqrt-transformed)');
title('Fz-F4: Real vs Surrogate');
legend('Real data', 'Surrogate 95%', 'Location', 'best');
grid on;
set(gca, 'FontSize', 9);

%% Subplot 2: Histogram - Cond 1 distribution
subplot(2, 4, 2);
histogram(surr_mean_g1, 30, 'FaceColor', [0.7, 0.7, 0.7], 'FaceAlpha', 0.6, ...
    'EdgeColor', 'none', 'DisplayName', 'Surrogate');
hold on;
xline(real_mean_g1, 'b-', 'LineWidth', 3, 'DisplayName', 'Real data');
xline(surr_95_g1, 'r--', 'LineWidth', 2, 'DisplayName', '95th percentile');
xlabel('Mean GPDC');
ylabel('Frequency');
title(sprintf('Full Gaze: Real vs Surrogate\np = %.4f', p_g1));
legend('Location', 'best');
grid on;
set(gca, 'FontSize', 10);

%% Subplot 3: P-values across conditions
subplot(2, 4, 3);
b = bar(1:5, -log10(p_values));
b.FaceColor = 'flat';
for i = 1:5
    if p_values(i) < 0.05
        b.CData(i,:) = [0.8, 0.2, 0.2];  % Red for significant
    else
        b.CData(i,:) = [0.7, 0.7, 0.7];
    end
end
hold on;
yline(-log10(0.05), 'r--', 'LineWidth', 2, 'DisplayName', 'p = 0.05');
set(gca, 'XTickLabel', conds);
ylabel('-log_{10}(p-value)');
title('Significance Levels');
ylim([0, max(-log10(p_values)) * 1.2]);
grid on;
set(gca, 'FontSize', 9);

%% Subplot 4: Scatter - Fz-F4 vs Learning
subplot(2, 4, 5);
scatter(FzF4_cond1_valid, learning_cond1_valid, 60, 'filled', ...
    'MarkerFaceColor', [0.2, 0.6, 0.8], 'MarkerFaceAlpha', 0.6);
hold on;

% Add regression line
p_fit = polyfit(FzF4_cond1_valid, learning_cond1_valid, 1);
x_fit = linspace(min(FzF4_cond1_valid), max(FzF4_cond1_valid), 100);
y_fit = polyval(p_fit, x_fit);
plot(x_fit, y_fit, 'r-', 'LineWidth', 2);

xlabel('Fz-F4 Connection Strength');
ylabel('Learning Score');
title(sprintf('Fz-F4 vs Learning (Cond 1)\nr = %.3f, p = %.4f', r_simple, p_simple));
grid on;
set(gca, 'FontSize', 10);

%% Subplot 5: Residual plot
subplot(2, 4, 6);
residuals = mdl_learning.Residuals.Raw;
fitted = mdl_learning.Fitted;
scatter(fitted, residuals, 60, 'filled', ...
    'MarkerFaceColor', [0.6, 0.6, 0.6], 'MarkerFaceAlpha', 0.6);
hold on;
yline(0, 'r--', 'LineWidth', 2);
xlabel('Fitted Values');
ylabel('Residuals');
title('Regression Diagnostics');
grid on;
set(gca, 'FontSize', 10);

%% Subplot 6: R² Surrogate Distribution
subplot(2, 4, 4);
histogram(surr_r2, 30, 'FaceColor', [0.7, 0.7, 0.7], 'FaceAlpha', 0.6, ...
    'EdgeColor', 'none', 'DisplayName', 'Surrogate R²');
hold on;
xline(R2, 'b-', 'LineWidth', 3, 'DisplayName', 'Real R²');
xline(surr_r2_95, 'r--', 'LineWidth', 2, 'DisplayName', '95th percentile');
xlabel('R² (correlation squared)');
ylabel('Frequency');
title(sprintf('R² vs Surrogate Distribution\np = %.4f', p_r2));
legend('Location', 'best');
grid on;
set(gca, 'FontSize', 10);

%% Subplot 7: Summary text
subplot(2, 4, [7, 8]);
axis off;

summary_text = {
    sprintf('SUMMARY: %s', connection_name);
    '';
    '--- Surrogate Tests (GPDC Strength) ---';
    sprintf('Full gaze:  p = %.4f %s', p_g1, get_sig_stars(p_g1));
    sprintf('Partial:    p = %.4f %s', p_g2, get_sig_stars(p_g2));
    sprintf('No gaze:    p = %.4f %s', p_g3, get_sig_stars(p_g3));
    sprintf('All pooled: p = %.4f %s', p_g4, get_sig_stars(p_g4));
    sprintf('P+N pooled: p = %.4f %s', p_g5, get_sig_stars(p_g5));
    '';
    '--- Behavior (Cond 1) ---';
    sprintf('Simple r:  %.3f, p = %.4f %s', r_simple, p_simple, get_sig_stars(p_simple));
    sprintf('Partial r: %.3f, p = %.4f %s', r_partial, p_partial, get_sig_stars(p_partial));
    '';
    'Linear Model:';
    sprintf('  β = %.3f', beta_FzF4);
    sprintf('  t(%d) = %.2f', df_error, t_FzF4);
    sprintf('  p = %.4f %s', p_FzF4, get_sig_stars(p_FzF4));
    sprintf('  R² = %.4f (r²)', R2);
    '';
    '--- R² Surrogate Test ---';
    sprintf('Real R²:     %.4f', R2);
    sprintf('Surr mean:   %.4f (SD=%.4f)', surr_r2_mean, surr_r2_std);
    sprintf('Surr 95%%:    %.4f', surr_r2_95);
    sprintf('p-value:     %.4f %s', p_r2, get_sig_stars(p_r2));
    sprintf('Significant: %s', iif(p_r2 < 0.05, 'YES', 'NO'));
    '';
    'Interpretation:';
    sprintf('  %s', iif(p_g1 < 0.05 && p_r2 < 0.05, ...
        'Fz-F4 genuine & predicts learning', ...
        iif(p_g1 < 0.05, 'Genuine but weak prediction', 'Mixed evidence')));
};

text(0.05, 0.95, summary_text, 'VerticalAlignment', 'top', ...
    'FontSize', 8, 'FontName', 'FixedWidth', 'Interpreter', 'none');

%% Save figure
sgtitle(sprintf('Supplementary Analysis: %s', connection_name), ...
    'FontSize', 14, 'FontWeight', 'bold');

fprintf('Figure created!\n\n');

%% ========================================================================
%  PART 4: SAVE RESULTS
%  ========================================================================

fprintf('Saving results to file...\n');

% Create results structure
results = struct();
results.connection_name = connection_name;
results.col_index = col_FzF4;
results.global_col = ai3(col_FzF4);

% Surrogate test results
results.surrogate.cond1 = struct('n', length(group1_idx), 'real_mean', real_mean_g1, ...
    'surr_mean', surr_mean_g1_mean, 'surr_std', surr_mean_g1_std, ...
    'surr_95', surr_95_g1, 'p', p_g1, 'significant', real_mean_g1 > surr_95_g1);
results.surrogate.cond2 = struct('n', length(group2_idx), 'real_mean', real_mean_g2, ...
    'surr_mean', surr_mean_g2_mean, 'surr_std', surr_mean_g2_std, ...
    'surr_95', surr_95_g2, 'p', p_g2, 'significant', real_mean_g2 > surr_95_g2);
results.surrogate.cond3 = struct('n', length(group3_idx), 'real_mean', real_mean_g3, ...
    'surr_mean', surr_mean_g3_mean, 'surr_std', surr_mean_g3_std, ...
    'surr_95', surr_95_g3, 'p', p_g3, 'significant', real_mean_g3 > surr_95_g3);
results.surrogate.pooled = struct('n', length(group4_idx), 'real_mean', real_mean_g4, ...
    'surr_mean', surr_mean_g4_mean, 'surr_std', surr_mean_g4_std, ...
    'surr_95', surr_95_g4, 'p', p_g4, 'significant', real_mean_g4 > surr_95_g4);
results.surrogate.partial_no_pooled = struct('n', length(group5_idx), 'real_mean', real_mean_g5, ...
    'surr_mean', surr_mean_g5_mean, 'surr_std', surr_mean_g5_std, ...
    'surr_95', surr_95_g5, 'p', p_g5, 'significant', real_mean_g5 > surr_95_g5);

% Behavioral results
results.behavior.n_valid = sum(valid_idx);
results.behavior.simple_corr = struct('r', r_simple, 'p', p_simple);
results.behavior.partial_corr = struct('r', r_partial, 'p', p_partial);
results.behavior.regression = struct('beta', beta_FzF4, 'se', se_FzF4, ...
    't', t_FzF4, 'df', df_error, 'p', p_FzF4, 'R2_from_r2', R2, ...
    'R2_model', R2_model, 'R2_adj', R2_adj);

% R² surrogate test results
results.r2_surrogate = struct('real_r2', R2, 'surr_r2_mean', surr_r2_mean, ...
    'surr_r2_std', surr_r2_std, 'surr_r2_95', surr_r2_95, 'p', p_r2, ...
    'significant', p_r2 < 0.05, 'surr_r2_distribution', surr_r2);

% Save
save('results_FzF4_surr_learning.mat', 'results');

fprintf('Results saved to: results_FzF4_surr_learning.mat\n');

%% ========================================================================
%  SUMMARY
%  ========================================================================

fprintf('\n========================================================================\n');
fprintf('ANALYSIS COMPLETE - SUMMARY\n');
fprintf('========================================================================\n\n');

fprintf('Connection analyzed: %s\n\n', connection_name);

fprintf('KEY FINDINGS:\n\n');

fprintf('1. Surrogate Tests:\n');
fprintf('   Full gaze:      %s (p = %.4f)\n', ...
    iif(p_g1 < 0.05, 'SIGNIFICANT', 'Not significant'), p_g1);
fprintf('   Partial gaze:   %s (p = %.4f)\n', ...
    iif(p_g2 < 0.05, 'SIGNIFICANT', 'Not significant'), p_g2);
fprintf('   No gaze:        %s (p = %.4f)\n', ...
    iif(p_g3 < 0.05, 'SIGNIFICANT', 'Not significant'), p_g3);
fprintf('   All pooled:     %s (p = %.4f)\n', ...
    iif(p_g4 < 0.05, 'SIGNIFICANT', 'Not significant'), p_g4);
fprintf('   P+N pooled:     %s (p = %.4f)\n\n', ...
    iif(p_g5 < 0.05, 'SIGNIFICANT', 'Not significant'), p_g5);

fprintf('2. Behavioral Association (Fz-F4 → Learning):\n');
fprintf('   Partial correlation: r = %.3f, p = %.4f %s\n', ...
    r_partial, p_partial, get_sig_stars(p_partial));
fprintf('   Regression β:        %.3f, p = %.4f %s\n', ...
    beta_FzF4, p_FzF4, get_sig_stars(p_FzF4));
fprintf('   R²:                  %.4f (r²)\n\n', R2);

fprintf('3. R² Surrogate Test (Behavioral Prediction):\n');
fprintf('   Real R²:            %.4f\n', R2);
fprintf('   Surrogate R² mean:  %.4f (SD = %.4f)\n', surr_r2_mean, surr_r2_std);
fprintf('   Surrogate 95%%:      %.4f\n', surr_r2_95);
fprintf('   p-value:            %.4f %s\n', p_r2, get_sig_stars(p_r2));
fprintf('   Significant:        %s\n\n', iif(p_r2 < 0.05, 'YES', 'NO'));

fprintf('4. Interpretation:\n');
if p_g1 < 0.05 && p_r2 < 0.05
    fprintf('   ✓ Fz-F4 connection is genuine (exceeds surrogate)\n');
    fprintf('   ✓ Fz-F4 predicts learning beyond chance (R² > surrogate)\n');
    fprintf('   → This connection is behaviorally relevant\n');
elseif p_g1 < 0.05 && p_r2 >= 0.05
    fprintf('   ✓ Fz-F4 connection is genuine (exceeds surrogate)\n');
    fprintf('   ✗ Prediction strength not above chance level\n');
    fprintf('   → Connection exists but weak behavioral relevance\n');
elseif p_g1 >= 0.05 && p_r2 < 0.05
    fprintf('   ✗ Fz-F4 connection not significantly above surrogate\n');
    fprintf('   ✓ But prediction strength exceeds chance\n');
    fprintf('   → Interpret with caution\n');
else
    fprintf('   ✗ Mixed evidence - interpret with caution\n');
    fprintf('   → Both connectivity and prediction not above chance\n');
end

fprintf('\n========================================================================\n\n');

%% Helper functions

function stars = get_sig_stars(p)
    if p < 0.001
        stars = '***';
    elseif p < 0.01
        stars = '**';
    elseif p < 0.05
        stars = '*';
    else
        stars = '';
    end
end

function result = iif(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end
