%% ========================================================================
%  fs7_R1_COMPREHENSIVE_FzF4_LEARNING.m
%  ========================================================================
%
%  PURPOSE:
%  LME analysis: Fz-F4 → Learning (Pooled conditions only)
%
%  MODEL:
%  Learning ~ FzF4 + Condition + Age + Sex + Country + (1|ID)
%
%  OUTPUT:
%  - LME coefficients (β, t, p)
%  - R² (from r²): correlation squared
%  - R² (LME model): full model R²
%  - Surrogate tests for both R²
%
%  DATE: 2025-10-15
%  ========================================================================

clc
clear all

fprintf('========================================================================\n');
fprintf('LME ANALYSIS: Fz-F4 → Learning (Pooled Conditions)\n');
fprintf('========================================================================\n\n');

%% Load data
fprintf('Loading data...\n');
load('data_read_surr_gpdc2.mat', 'data_surr', 'data');
fprintf('  Data loaded: %d samples, %d surrogates\n\n', size(data, 1), length(data_surr));

%% Extract variables
a = data;
AGE = a(:, 3);
SEX = a(:, 4);
COUNTRY = a(:, 1);
CONDGROUP = a(:, 6);
learning = a(:, 7);
ID = a(:, 2);

fprintf('Sample composition:\n');
fprintf('  Total samples: %d\n', size(a, 1));
fprintf('  Condition 1 (Full gaze): %d\n', sum(CONDGROUP == 1));
fprintf('  Condition 2 (Partial gaze): %d\n', sum(CONDGROUP == 2));
fprintf('  Condition 3 (No gaze): %d\n', sum(CONDGROUP == 3));
fprintf('  Unique subjects: %d\n\n', length(unique(ID)));

%% Extract Fz-F4 connection
ai3 = [10+81*8:9+81*9];
data_conn = sqrt(data(:, ai3));
col_FzF4 = 12;
connection_name = 'AI_Alpha_Fz_to_F4';

fprintf('Target connection: %s (column %d)\n\n', connection_name, col_FzF4);
real_FzF4 = data_conn(:, col_FzF4);

%% Extract surrogate Fz-F4 data
n_surr = length(data_surr);
fprintf('Extracting %d surrogates...\n', n_surr);

surr_FzF4 = zeros(size(a, 1), n_surr);
for i = 1:n_surr
    if mod(i, 100) == 0
        fprintf('  Processing surrogate %d/%d...\n', i, n_surr);
    end
    surr_conn = sqrt(data_surr{i}(:, ai3));
    surr_FzF4(:, i) = surr_conn(:, col_FzF4);
end
fprintf('Done!\n\n');

%% Prepare pooled data
group_idx = 1:size(a, 1);  % All samples

FzF4_group = real_FzF4(group_idx);
learning_group = learning(group_idx);
age_group = AGE(group_idx);
sex_group = SEX(group_idx);
country_group = COUNTRY(group_idx);
id_group = ID(group_idx);
cond_group = CONDGROUP(group_idx);

% Remove NaN
valid_idx = ~isnan(learning_group);
FzF4_valid = FzF4_group(valid_idx);
learning_valid = learning_group(valid_idx);
age_valid = age_group(valid_idx);
sex_valid = sex_group(valid_idx);
country_valid = country_group(valid_idx);
id_valid = id_group(valid_idx);
cond_valid = cond_group(valid_idx);

n_valid = sum(valid_idx);
n_subjects = length(unique(id_valid));

fprintf('Valid samples: %d\n', n_valid);
fprintf('Subjects: %d\n\n', n_subjects);

%% Build LME model
fprintf('Model: Learning ~ FzF4 + Condition + Age + Sex + Country + (1|ID)\n\n');

tbl_lme = table(FzF4_valid, learning_valid, age_valid, ...
    categorical(sex_valid), categorical(country_valid), ...
    categorical(cond_valid), categorical(id_valid), ...
    'VariableNames', {'FzF4', 'Learning', 'Age', 'Sex', 'Country', 'Condition', 'ID'});

lme_real = fitlme(tbl_lme, 'Learning ~ FzF4 + Condition + Age + Sex + Country + (1|ID)');

% Display model
disp(lme_real);

%% Extract statistics
beta_lme = lme_real.Coefficients.Estimate(2);
se_lme = lme_real.Coefficients.SE(2);
t_lme = lme_real.Coefficients.tStat(2);
df_lme = lme_real.Coefficients.DF(2);
p_lme = lme_real.Coefficients.pValue(2);
R2_lme_model = lme_real.Rsquared.Ordinary;
R2_lme_adj = lme_real.Rsquared.Adjusted;

% Calculate R² from correlation
[r_simple, ~] = corr(FzF4_valid, learning_valid);
R2_simple = r_simple^2;

fprintf('\n--- LME Results for FzF4 ---\n');
fprintf('  β = %.4f\n', beta_lme);
fprintf('  SE = %.4f\n', se_lme);
fprintf('  t(%.1f) = %.3f\n', df_lme, t_lme);
fprintf('  p = %.4f %s\n', p_lme, get_sig_stars(p_lme));
fprintf('  r = %.4f\n', r_simple);
fprintf('  R² (from r²) = %.4f\n', R2_simple);
fprintf('  R² (LME model) = %.4f\n', R2_lme_model);
fprintf('  Adjusted R² = %.4f\n\n', R2_lme_adj);

%% Surrogate analysis
fprintf('Computing surrogate LME models...\n');
fprintf('(This may take several minutes...)\n\n');

surr_r2_simple = zeros(n_surr, 1);  % R² from correlation
surr_r2_lme = zeros(n_surr, 1);     % R² from LME model

for i = 1:n_surr
    if mod(i, 50) == 0
        fprintf('  Surrogate %d/%d...\n', i, n_surr);
    end

    % Extract surrogate FzF4
    surr_FzF4_valid = surr_FzF4(group_idx, i);
    surr_FzF4_valid = surr_FzF4_valid(valid_idx);

    % Calculate R² from correlation
    r_surr = corr(surr_FzF4_valid, learning_valid);
    surr_r2_simple(i) = r_surr^2;

    % Build surrogate LME
    tbl_surr = table(surr_FzF4_valid, learning_valid, age_valid, ...
        categorical(sex_valid), categorical(country_valid), ...
        categorical(cond_valid), categorical(id_valid), ...
        'VariableNames', {'FzF4', 'Learning', 'Age', 'Sex', 'Country', 'Condition', 'ID'});
    lme_surr = fitlme(tbl_surr, 'Learning ~ FzF4 + Condition + Age + Sex + Country + (1|ID)', ...
        'Verbose', 0);

    % Extract LME R²
    surr_r2_lme(i) = lme_surr.Rsquared.Ordinary;
end
fprintf('Done!\n\n');

%% Statistics - R² (from r²)
surr_r2_simple_mean = mean(surr_r2_simple);
surr_r2_simple_std = std(surr_r2_simple);
surr_r2_simple_95 = prctile(surr_r2_simple, 95);
p_surr_r2_simple = (sum(surr_r2_simple >= R2_simple) + 1) / (n_surr + 1);

fprintf('--- Surrogate Test: R² (from r²) ---\n');
fprintf('  Real R²:        %.4f\n', R2_simple);
fprintf('  Surrogate mean: %.4f (SD=%.4f)\n', surr_r2_simple_mean, surr_r2_simple_std);
fprintf('  Surrogate 95%%:  %.4f\n', surr_r2_simple_95);
fprintf('  p-value:        %.4f %s\n', p_surr_r2_simple, get_sig_stars(p_surr_r2_simple));
fprintf('  Significant:    %s\n\n', iif(p_surr_r2_simple < 0.05, 'YES', 'NO'));

%% Statistics - R² (LME model)
surr_r2_lme_mean = mean(surr_r2_lme);
surr_r2_lme_std = std(surr_r2_lme);
surr_r2_lme_95 = prctile(surr_r2_lme, 95);
p_surr_r2_lme = (sum(surr_r2_lme >= R2_lme_model) + 1) / (n_surr + 1);

fprintf('--- Surrogate Test: R² (LME model) ---\n');
fprintf('  Real R²:        %.4f\n', R2_lme_model);
fprintf('  Surrogate mean: %.4f (SD=%.4f)\n', surr_r2_lme_mean, surr_r2_lme_std);
fprintf('  Surrogate 95%%:  %.4f\n', surr_r2_lme_95);
fprintf('  p-value:        %.4f %s\n', p_surr_r2_lme, get_sig_stars(p_surr_r2_lme));
fprintf('  Significant:    %s\n\n', iif(p_surr_r2_lme < 0.05, 'YES', 'NO'));

%% ========================================================================
%  ADDITIONAL ANALYSIS: Extract Cond=1 from pooled model
%  ========================================================================

fprintf('========================================================================\n');
fprintf('ADDITIONAL ANALYSIS: Cond=1 Subset from Pooled Model\n');
fprintf('========================================================================\n\n');

% Extract Cond=1 indices
cond1_idx_in_valid = (cond_valid == 1);
n_cond1 = sum(cond1_idx_in_valid);

fprintf('Extracting Cond=1 samples from pooled analysis...\n');
fprintf('  Cond=1 samples: %d\n\n', n_cond1);

% Get predicted values from pooled LME model for Cond=1 only
FzF4_cond1 = FzF4_valid(cond1_idx_in_valid);
learning_cond1 = learning_valid(cond1_idx_in_valid);

% Calculate correlation for Cond=1 only
[r_cond1, ~] = corr(FzF4_cond1, learning_cond1);
R2_cond1 = r_cond1^2;

fprintf('--- Cond=1 Statistics (from pooled model) ---\n');
fprintf('  r = %.4f\n', r_cond1);
fprintf('  R² (from r²) = %.4f\n\n', R2_cond1);

% Surrogate test for Cond=1 R²
fprintf('Computing surrogate R² for Cond=1 subset...\n\n');

surr_r2_cond1 = zeros(n_surr, 1);

for i = 1:n_surr
    if mod(i, 100) == 0
        fprintf('  Surrogate %d/%d...\n', i, n_surr);
    end

    % Extract surrogate FzF4 for Cond=1 only
    surr_FzF4_valid_full = surr_FzF4(group_idx, i);
    surr_FzF4_valid_full = surr_FzF4_valid_full(valid_idx);
    surr_FzF4_cond1 = surr_FzF4_valid_full(cond1_idx_in_valid);

    % Calculate R² from correlation for Cond=1
    r_surr_cond1 = corr(surr_FzF4_cond1, learning_cond1);
    surr_r2_cond1(i) = r_surr_cond1^2;
end
fprintf('Done!\n\n');

% Statistics for Cond=1 R²
surr_r2_cond1_mean = mean(surr_r2_cond1);
surr_r2_cond1_std = std(surr_r2_cond1);
surr_r2_cond1_95 = prctile(surr_r2_cond1, 95);
p_surr_r2_cond1 = (sum(surr_r2_cond1 >= R2_cond1) + 1) / (n_surr + 1);

fprintf('--- Surrogate Test: R² (Cond=1 subset) ---\n');
fprintf('  Real R²:        %.4f\n', R2_cond1);
fprintf('  Surrogate mean: %.4f (SD=%.4f)\n', surr_r2_cond1_mean, surr_r2_cond1_std);
fprintf('  Surrogate 95%%:  %.4f\n', surr_r2_cond1_95);
fprintf('  p-value:        %.4f %s\n', p_surr_r2_cond1, get_sig_stars(p_surr_r2_cond1));
fprintf('  Significant:    %s\n\n', iif(p_surr_r2_cond1 < 0.05, 'YES', 'NO'));

fprintf('========================================================================\n\n');

%% Store and save results
results = struct();
results.connection_name = connection_name;
results.n_samples = n_valid;
results.n_subjects = n_subjects;

% Pooled results
results.pooled.lme.beta = beta_lme;
results.pooled.lme.se = se_lme;
results.pooled.lme.t = t_lme;
results.pooled.lme.df = df_lme;
results.pooled.lme.p = p_lme;
results.pooled.lme.r = r_simple;
results.pooled.lme.R2_simple = R2_simple;
results.pooled.lme.R2_model = R2_lme_model;
results.pooled.lme.R2_adj = R2_lme_adj;

results.pooled.surr_r2_simple.mean = surr_r2_simple_mean;
results.pooled.surr_r2_simple.std = surr_r2_simple_std;
results.pooled.surr_r2_simple.p95 = surr_r2_simple_95;
results.pooled.surr_r2_simple.p_value = p_surr_r2_simple;
results.pooled.surr_r2_simple.significant = p_surr_r2_simple < 0.05;
results.pooled.surr_r2_simple.distribution = surr_r2_simple;

results.pooled.surr_r2_lme.mean = surr_r2_lme_mean;
results.pooled.surr_r2_lme.std = surr_r2_lme_std;
results.pooled.surr_r2_lme.p95 = surr_r2_lme_95;
results.pooled.surr_r2_lme.p_value = p_surr_r2_lme;
results.pooled.surr_r2_lme.significant = p_surr_r2_lme < 0.05;
results.pooled.surr_r2_lme.distribution = surr_r2_lme;

% Cond=1 subset results
results.cond1.n_samples = n_cond1;
results.cond1.r = r_cond1;
results.cond1.R2 = R2_cond1;

results.cond1.surr_r2.mean = surr_r2_cond1_mean;
results.cond1.surr_r2.std = surr_r2_cond1_std;
results.cond1.surr_r2.p95 = surr_r2_cond1_95;
results.cond1.surr_r2.p_value = p_surr_r2_cond1;
results.cond1.surr_r2.significant = p_surr_r2_cond1 < 0.05;
results.cond1.surr_r2.distribution = surr_r2_cond1;

% Create summary table
summary_table = table(...
    {'Pooled (All)'; 'Cond=1 subset'}, ...
    [n_valid; n_cond1], ...
    [r_simple; r_cond1], ...
    [R2_simple; R2_cond1], ...
    [p_surr_r2_simple; p_surr_r2_cond1], ...
    [R2_lme_model; NaN], ...
    [p_surr_r2_lme; NaN], ...
    'VariableNames', {'Group', 'N', 'r', 'R2_simple', 'p_surr_r2_simple', ...
    'R2_model', 'p_surr_r2_lme'});

fprintf('\n========================================================================\n');
fprintf('SUMMARY\n');
fprintf('========================================================================\n\n');
disp(summary_table);

% Save
writetable(summary_table, 'comprehensive_FzF4_learning_summary.csv');
save('results_FzF4_comprehensive.mat', 'results', 'summary_table');

fprintf('\nResults saved to:\n');
fprintf('  - comprehensive_FzF4_learning_summary.csv\n');
fprintf('  - results_FzF4_comprehensive.mat\n\n');

fprintf('========================================================================\n');
fprintf('ANALYSIS COMPLETE\n');
fprintf('========================================================================\n');

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
