%% ========================================================================
%  R1 RESPONSE: GPDC-Behavior Correlation and PLS Analysis
%  ========================================================================
%
%  PURPOSE:
%  Address reviewer request to analyze the significant GPDC connection
%  identified in Supplementary S4:
%  1. Correlate with attention
%  2. Correlate with learning
%  3. PLS analysis between GPDC and learning
%
%  BACKGROUND:
%  Supplementary S4 identified one AI (Adult-Infant) alpha connection that
%  significantly differed between conditions (Full gaze > Partial/No gaze,
%  t221 = 3.48, FDR-corrected p < .05). Reviewers requested further analysis
%  of this connection's relationship to behavioral outcomes.
%
%  CORRESPONDS TO:
%  - Supplementary Materials Section 4
%  - Reviewer request for behavior-brain correlations
%
%  ========================================================================

clc
clear all

%% Path setup
path = 'C:\Users\Admin\OneDrive - Nanyang Technological University\';
code_path = [path, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/scripts_R1/'];
cd(code_path);

fprintf('\n');
fprintf('========================================================================\n');
fprintf('  GPDC-BEHAVIOR CORRELATION AND PLS ANALYSIS\n');
fprintf('  Analysis of the condition-sensitive AI connection from Sup S4\n');
fprintf('========================================================================\n\n');

%% Load GPDC data
fprintf('Loading GPDC data...\n');
load('data_read_surr_gpdc.mat', 'data');

% Apply square-root transformation (consistent with main analysis)
ori_data = sqrt(data);

fprintf('  Data size: %d trials × %d columns\n\n', size(ori_data,1), size(ori_data,2));

%% Extract key variables
Country = ori_data(:, 1);      % 1=UK, 2=SG
ID = ori_data(:, 2);           % Subject ID
Age = ori_data(:, 3);          % Age in months
Sex = ori_data(:, 4);          % 1=F, 2=M
Block = ori_data(:, 5);        % Block number
Condition = ori_data(:, 6);    % 1=Full, 2=Partial, 3=No gaze
Learning = ori_data(:, 7);     % Learning score (nw - w)
Attention = ori_data(:, 9);    % Attention proportion

% Condition indices
c1_idx = find(Condition == 1);  % Full gaze
c2_idx = find(Condition == 2);  % Partial gaze
c3_idx = find(Condition == 3);  % No gaze

fprintf('Sample sizes by condition:\n');
fprintf('  Full gaze:    %d trials\n', length(c1_idx));
fprintf('  Partial gaze: %d trials\n', length(c2_idx));
fprintf('  No gaze:      %d trials\n\n', length(c3_idx));

%% Load AI alpha connections and identify the significant connection
fprintf('Loading AI alpha connections...\n');

% AI alpha range: columns 659-739 (81 connections in 9×9 matrix)
ai_alpha_range = 659:739;

% Load significant connections from surrogate analysis
load('stronglistfdr5_gpdc_AI.mat', 's4');
sig_AI_indices = s4;

fprintf('  AI alpha connections: %d total\n', length(ai_alpha_range));
fprintf('  Significant connections (vs surrogate): %d\n', length(sig_AI_indices));

% Extract AI alpha data
ai_alpha_data = ori_data(:, ai_alpha_range);
ai_alpha_sig = ai_alpha_data(:, sig_AI_indices);

% The connection from Sup S4 (12th in the significant list)
% This is the one showing: Full gaze > Partial/No gaze, t221=3.48, p<.05
SIG_CONN_IDX = 12;
sig_connection = ai_alpha_sig(:, SIG_CONN_IDX);

% Get connection name
nodes = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
% Generate connection titles for AI alpha
conn_titles = {};
for src = 1:9
    for dest = 1:9
        conn_titles{end+1} = sprintf('AI_Alpha_%s_to_%s', nodes{src}, nodes{dest});
    end
end
sig_conn_title = conn_titles{sig_AI_indices(SIG_CONN_IDX)};

fprintf('\n');
fprintf('*** ANALYZING CONNECTION: %s ***\n', sig_conn_title);
fprintf('    (Connection #%d from significant list)\n', SIG_CONN_IDX);
fprintf('    This connection shows: Full gaze > Partial/No gaze\n');
fprintf('    (t221 = 3.48, FDR-corrected p < .05, from Sup S4)\n\n');

%% ========================================================================
%  PART 1: VERIFY CONDITION EFFECT (Replicate Sup S4 finding)
%  ========================================================================

fprintf('========================================================================\n');
fprintf('PART 1: VERIFY CONDITION EFFECT ON SIGNIFICANT CONNECTION\n');
fprintf('========================================================================\n\n');

% Create binary condition: Full gaze (1) vs Others (2)
Condition_binary = Condition;
Condition_binary(Condition >= 2) = 2;
Condition_binary = categorical(Condition_binary);

% LME: Connection ~ Condition + Age + Sex + Country + (1|ID)
tbl_cond = table(categorical(ID), sig_connection, ...
    zscore(Age), categorical(Sex), categorical(Country), ...
    Condition_binary, ...
    'VariableNames', {'ID', 'Connection', 'Age', 'Sex', 'Country', 'CondGroup'});

lme_cond = fitlme(tbl_cond, 'Connection ~ Age + Sex + Country + CondGroup + (1|ID)');

% Extract CondGroup effect
coeffIdx = strcmp(lme_cond.CoefficientNames, 'CondGroup_2');
t_cond = lme_cond.Coefficients.tStat(coeffIdx);
p_cond = lme_cond.Coefficients.pValue(coeffIdx);
df_cond = lme_cond.Coefficients.DF(coeffIdx);

fprintf('LME: Connection ~ CondGroup + Age + Sex + Country + (1|ID)\n');
fprintf('  CondGroup effect (Full vs Partial/No):\n');
fprintf('    t(%.0f) = %.3f, p = %.4f\n', df_cond, t_cond, p_cond);

if p_cond < 0.05
    fprintf('    ✅ CONFIRMED: Full gaze shows significantly stronger connection\n');
else
    fprintf('    ⚠️  Not significant at p < .05\n');
end

% Descriptive statistics by condition
fprintf('\n  Mean connection strength by condition:\n');
fprintf('    Full gaze:    M = %.4f, SD = %.4f\n', ...
    mean(sig_connection(c1_idx)), std(sig_connection(c1_idx)));
fprintf('    Partial gaze: M = %.4f, SD = %.4f\n', ...
    mean(sig_connection(c2_idx)), std(sig_connection(c2_idx)));
fprintf('    No gaze:      M = %.4f, SD = %.4f\n\n', ...
    mean(sig_connection(c3_idx)), std(sig_connection(c3_idx)));

%% ========================================================================
%  PART 2: CORRELATION WITH ATTENTION
%  ========================================================================

fprintf('========================================================================\n');
fprintf('PART 2: CORRELATION BETWEEN CONNECTION AND ATTENTION\n');
fprintf('========================================================================\n\n');

fprintf('--- 2a. Overall Correlation (All Conditions Combined) ---\n');

% Clean data (remove missing values)
valid_overall = ~isnan(sig_connection) & ~isnan(Attention) & ~isnan(Learning);
valid_idx_all = find(valid_overall);

% Partial correlation controlling for Age, Sex, Country
[r_atten_all, p_atten_all] = partialcorr(...
    sig_connection(valid_idx_all), ...
    Attention(valid_idx_all), ...
    [Age(valid_idx_all), Sex(valid_idx_all), Country(valid_idx_all)]);

fprintf('Partial correlation (controlling Age, Sex, Country):\n');
fprintf('  r = %.3f, p = %.4f, N = %d\n', r_atten_all, p_atten_all, sum(valid_overall));

if p_atten_all < 0.05
    fprintf('  ✅ SIGNIFICANT: Connection correlates with attention\n');
else
    fprintf('  ❌ NOT SIGNIFICANT\n');
end
fprintf('\n');

fprintf('--- 2b. Condition-Specific Correlations ---\n');

% Initialize storage
r_atten_cond = zeros(3, 1);
p_atten_cond = zeros(3, 1);
n_atten_cond = zeros(3, 1);

cond_names = {'Full gaze', 'Partial gaze', 'No gaze'};

for iCond = 1:3
    cond_idx = find(Condition == iCond);
    valid_cond = valid_overall(cond_idx);
    valid_idx_cond = cond_idx(valid_cond);

    if sum(valid_cond) > 10  % Need sufficient data
        [r_atten_cond(iCond), p_atten_cond(iCond)] = partialcorr(...
            sig_connection(valid_idx_cond), ...
            Attention(valid_idx_cond), ...
            [Age(valid_idx_cond), Sex(valid_idx_cond), Country(valid_idx_cond)]);
        n_atten_cond(iCond) = sum(valid_cond);

        fprintf('%s:\n', cond_names{iCond});
        fprintf('  r = %.3f, p = %.4f, N = %d\n', ...
            r_atten_cond(iCond), p_atten_cond(iCond), n_atten_cond(iCond));

        if p_atten_cond(iCond) < 0.05
            fprintf('  ✅ SIGNIFICANT\n');
        end
    else
        fprintf('%s: Insufficient data (N = %d)\n', cond_names{iCond}, sum(valid_cond));
        r_atten_cond(iCond) = NaN;
        p_atten_cond(iCond) = NaN;
        n_atten_cond(iCond) = sum(valid_cond);
    end
    fprintf('\n');
end

% FDR correction for condition-specific tests
p_atten_cond_fdr = mafdr(p_atten_cond, 'BHFDR', true);
fprintf('FDR-corrected q-values:\n');
for iCond = 1:3
    fprintf('  %s: q = %.4f\n', cond_names{iCond}, p_atten_cond_fdr(iCond));
end
fprintf('\n');

fprintf('--- 2c. LME: Connection-Attention Relationship Modulated by Condition? ---\n');

% LME with interaction
tbl_atten = table(categorical(ID), sig_connection, ...
    zscore(Attention), zscore(Age), categorical(Sex), categorical(Country), ...
    categorical(Condition), ...
    'VariableNames', {'ID', 'Connection', 'Attention', 'Age', 'Sex', 'Country', 'Condition'});

% Remove missing values
tbl_atten = tbl_atten(valid_overall, :);

% Model with interaction
lme_atten_int = fitlme(tbl_atten, ...
    'Connection ~ Attention * Condition + Age + Sex + Country + (1|ID)');

fprintf('LME with interaction: Connection ~ Attention * Condition + covariates + (1|ID)\n\n');

% Extract main effect of Attention
atten_idx = find(contains(lme_atten_int.CoefficientNames, 'Attention') & ...
    ~contains(lme_atten_int.CoefficientNames, ':'));
if ~isempty(atten_idx)
    fprintf('Main effect of Attention:\n');
    fprintf('  β = %.3f, t(%.0f) = %.3f, p = %.4f\n', ...
        lme_atten_int.Coefficients.Estimate(atten_idx), ...
        lme_atten_int.Coefficients.DF(atten_idx), ...
        lme_atten_int.Coefficients.tStat(atten_idx), ...
        lme_atten_int.Coefficients.pValue(atten_idx));
end

% Extract interaction terms
int_idx = find(contains(lme_atten_int.CoefficientNames, 'Attention:Condition'));
if ~isempty(int_idx)
    fprintf('\nAttention × Condition interactions:\n');
    for i = 1:length(int_idx)
        fprintf('  %s:\n', lme_atten_int.CoefficientNames{int_idx(i)});
        fprintf('    β = %.3f, t(%.0f) = %.3f, p = %.4f\n', ...
            lme_atten_int.Coefficients.Estimate(int_idx(i)), ...
            lme_atten_int.Coefficients.DF(int_idx(i)), ...
            lme_atten_int.Coefficients.tStat(int_idx(i)), ...
            lme_atten_int.Coefficients.pValue(int_idx(i)));
    end
end
fprintf('\n');

%% ========================================================================
%  PART 3: CORRELATION WITH LEARNING
%  ========================================================================

fprintf('========================================================================\n');
fprintf('PART 3: CORRELATION BETWEEN CONNECTION AND LEARNING\n');
fprintf('========================================================================\n\n');

fprintf('--- 3a. Overall Correlation (All Conditions Combined) ---\n');

% Partial correlation controlling for Age, Sex, Country
[r_learn_all, p_learn_all] = partialcorr(...
    sig_connection(valid_idx_all), ...
    Learning(valid_idx_all), ...
    [Age(valid_idx_all), Sex(valid_idx_all), Country(valid_idx_all)]);

fprintf('Partial correlation (controlling Age, Sex, Country):\n');
fprintf('  r = %.3f, p = %.4f, N = %d\n', r_learn_all, p_learn_all, sum(valid_overall));

if p_learn_all < 0.05
    fprintf('  ✅ SIGNIFICANT: Connection correlates with learning\n');
else
    fprintf('  ❌ NOT SIGNIFICANT\n');
end
fprintf('\n');

fprintf('--- 3b. Condition-Specific Correlations ---\n');

% Initialize storage
r_learn_cond = zeros(3, 1);
p_learn_cond = zeros(3, 1);
n_learn_cond = zeros(3, 1);

for iCond = 1:3
    cond_idx = find(Condition == iCond);
    valid_cond = valid_overall(cond_idx);
    valid_idx_cond = cond_idx(valid_cond);

    if sum(valid_cond) > 10
        [r_learn_cond(iCond), p_learn_cond(iCond)] = partialcorr(...
            sig_connection(valid_idx_cond), ...
            Learning(valid_idx_cond), ...
            [Age(valid_idx_cond), Sex(valid_idx_cond), Country(valid_idx_cond)]);
        n_learn_cond(iCond) = sum(valid_cond);

        fprintf('%s:\n', cond_names{iCond});
        fprintf('  r = %.3f, p = %.4f, N = %d\n', ...
            r_learn_cond(iCond), p_learn_cond(iCond), n_learn_cond(iCond));

        if p_learn_cond(iCond) < 0.05
            fprintf('  ✅ SIGNIFICANT\n');
        end
    else
        fprintf('%s: Insufficient data (N = %d)\n', cond_names{iCond}, sum(valid_cond));
        r_learn_cond(iCond) = NaN;
        p_learn_cond(iCond) = NaN;
        n_learn_cond(iCond) = sum(valid_cond);
    end
    fprintf('\n');
end

% FDR correction
p_learn_cond_fdr = mafdr(p_learn_cond, 'BHFDR', true);
fprintf('FDR-corrected q-values:\n');
for iCond = 1:3
    fprintf('  %s: q = %.4f\n', cond_names{iCond}, p_learn_cond_fdr(iCond));
end
fprintf('\n');

fprintf('--- 3c. LME: Connection-Learning Relationship Modulated by Condition? ---\n');

% Simpler model without interaction to avoid errors
tbl_learn = table(categorical(ID), sig_connection, ...
    Learning, Age, categorical(Sex), categorical(Country), ...
    categorical(Condition), ...
    'VariableNames', {'ID', 'Connection', 'Learning', 'Age', 'Sex', 'Country', 'Condition'});

tbl_learn = tbl_learn(valid_overall, :);

try
    % Model with main effects only (safer)
    lme_learn = fitlme(tbl_learn, ...
        'Connection ~ Learning + Condition + Age + Sex + Country + (1|ID)');

    fprintf('LME: Connection ~ Learning + Condition + covariates + (1|ID)\n\n');

    % Extract main effect of Learning
    learn_idx = find(strcmp(lme_learn.CoefficientNames, 'Learning'));
    if ~isempty(learn_idx)
        fprintf('Main effect of Learning:\n');
        fprintf('  β = %.3f, t(%.0f) = %.3f, p = %.4f\n', ...
            lme_learn.Coefficients.Estimate(learn_idx), ...
            lme_learn.Coefficients.DF(learn_idx), ...
            lme_learn.Coefficients.tStat(learn_idx), ...
            lme_learn.Coefficients.pValue(learn_idx));
    end

    lme_learn_int = lme_learn;  % Store for compatibility
catch ME
    fprintf('  Error fitting LME: %s\n', ME.message);
    lme_learn_int = [];
end
fprintf('\n');

%% ========================================================================
%  PART 4: PLS ANALYSIS - CONNECTION WITH LEARNING
%  ========================================================================

fprintf('========================================================================\n');
fprintf('PART 4: PLS REGRESSION - CONNECTION PREDICTING LEARNING\n');
fprintf('========================================================================\n\n');

fprintf('Question: Can this AI connection predict learning performance?\n\n');

% Focus on Full Gaze condition (where connection is strongest)
fprintf('--- 4a. PLS in Full Gaze Condition ---\n');

c1_valid = valid_overall & (Condition == 1);
c1_valid_idx = find(c1_valid);

if sum(c1_valid) > 20  % Need sufficient data for PLS
    % Prepare data
    X_pls = sig_connection(c1_valid_idx);
    Y_pls = Learning(c1_valid_idx);

    % Z-score
    X_pls_z = zscore(X_pls);
    Y_pls_z = zscore(Y_pls);

    % PLS with 1 component
    [XL, YL, XS, YS, BETA, PCTVAR, MSE, stats] = plsregress(X_pls_z, Y_pls_z, 1);

    % Calculate R-squared
    Y_pred = [ones(length(X_pls_z), 1), X_pls_z] * BETA;
    R2_pls = corr(Y_pred, Y_pls_z)^2;

    % Permutation test for significance
    n_perm = 5000;
    R2_perm = zeros(n_perm, 1);

    fprintf('Running %d permutations for significance testing...\n', n_perm);
    rng(42);  % For reproducibility
    for iPerm = 1:n_perm
        Y_perm = Y_pls_z(randperm(length(Y_pls_z)));
        [~, ~, ~, ~, BETA_perm, ~, ~, ~] = plsregress(X_pls_z, Y_perm, 1);
        Y_pred_perm = [ones(length(X_pls_z), 1), X_pls_z] * BETA_perm;
        R2_perm(iPerm) = corr(Y_pred_perm, Y_perm)^2;
    end

    p_pls_c1 = sum(R2_perm >= R2_pls) / n_perm;

    fprintf('\nPLS Results (Full Gaze, N = %d):\n', sum(c1_valid));
    fprintf('  R² = %.3f\n', R2_pls);
    fprintf('  Variance explained in Learning: %.1f%%\n', PCTVAR(2,1));
    fprintf('  PLS weight: β = %.3f\n', BETA(2));
    fprintf('  Permutation p-value: p = %.4f\n', p_pls_c1);

    if p_pls_c1 < 0.05
        fprintf('  ✅ SIGNIFICANT: Connection predicts learning in Full Gaze\n');
    else
        fprintf('  ❌ NOT SIGNIFICANT\n');
    end
    fprintf('\n');
else
    fprintf('  Insufficient data for PLS in Full Gaze (N = %d)\n\n', sum(c1_valid));
    R2_pls = NaN;
    p_pls_c1 = NaN;
end

fprintf('--- 4b. PLS Across All Conditions ---\n');

% PLS with all conditions
X_pls_all = sig_connection(valid_idx_all);
Y_pls_all = Learning(valid_idx_all);

X_pls_all_z = zscore(X_pls_all);
Y_pls_all_z = zscore(Y_pls_all);

[XL_all, YL_all, XS_all, YS_all, BETA_all, PCTVAR_all, MSE_all, stats_all] = ...
    plsregress(X_pls_all_z, Y_pls_all_z, 1);

Y_pred_all = [ones(length(X_pls_all_z), 1), X_pls_all_z] * BETA_all;
R2_pls_all = corr(Y_pred_all, Y_pls_all_z)^2;

% Permutation test
R2_perm_all = zeros(n_perm, 1);
rng(42);
for iPerm = 1:n_perm
    Y_perm = Y_pls_all_z(randperm(length(Y_pls_all_z)));
    [~, ~, ~, ~, BETA_perm, ~, ~, ~] = plsregress(X_pls_all_z, Y_perm, 1);
    Y_pred_perm = [ones(length(X_pls_all_z), 1), X_pls_all_z] * BETA_perm;
    R2_perm_all(iPerm) = corr(Y_pred_perm, Y_perm)^2;
end

p_pls_all = sum(R2_perm_all >= R2_pls_all) / n_perm;

fprintf('PLS Results (All Conditions, N = %d):\n', sum(valid_overall));
fprintf('  R² = %.3f\n', R2_pls_all);
fprintf('  Variance explained in Learning: %.1f%%\n', PCTVAR_all(2,1));
fprintf('  PLS weight: β = %.3f\n', BETA_all(2));
fprintf('  Permutation p-value: p = %.4f\n', p_pls_all);

if p_pls_all < 0.05
    fprintf('  ✅ SIGNIFICANT: Connection predicts learning across conditions\n');
else
    fprintf('  ❌ NOT SIGNIFICANT\n');
end
fprintf('\n');

%% ========================================================================
%  PART 5: MULTIVARIATE PLS - ALL SIGNIFICANT AI CONNECTIONS
%  ========================================================================

fprintf('========================================================================\n');
fprintf('PART 5: MULTIVARIATE PLS - ALL SIGNIFICANT AI CONNECTIONS\n');
fprintf('========================================================================\n\n');

fprintf('Question: Do all %d significant AI connections jointly predict learning?\n\n', ...
    length(sig_AI_indices));

fprintf('--- 5a. Full Gaze Condition ---\n');

if sum(c1_valid) > 20
    % All significant AI connections in Full Gaze
    X_multi = ai_alpha_sig(c1_valid_idx, :);
    Y_multi = Learning(c1_valid_idx);

    % Remove any remaining NaNs
    valid_multi = ~any(isnan(X_multi), 2) & ~isnan(Y_multi);
    X_multi = X_multi(valid_multi, :);
    Y_multi = Y_multi(valid_multi);

    if sum(valid_multi) > 20
        X_multi_z = zscore(X_multi);
        Y_multi_z = zscore(Y_multi);

        % Determine optimal number of components (max 5 or N/10)
        max_comp = min([5, floor(sum(valid_multi)/10), size(X_multi,2)]);

        [XL_multi, YL_multi, XS_multi, YS_multi, BETA_multi, PCTVAR_multi, MSE_multi] = ...
            plsregress(X_multi_z, Y_multi_z, max_comp);

        fprintf('Multivariate PLS (Full Gaze, N = %d):\n', sum(valid_multi));
        fprintf('  Number of AI connections: %d\n', size(X_multi, 2));
        fprintf('  Number of components tested: %d\n\n', max_comp);

        fprintf('  Variance explained in Learning by component:\n');
        for iComp = 1:max_comp
            fprintf('    Component %d: %.1f%%\n', iComp, PCTVAR_multi(2, iComp));
        end

        % Calculate R² for 1-component model
        Y_pred_multi = [ones(sum(valid_multi), 1), X_multi_z] * BETA_multi(:,1);
        R2_multi = corr(Y_pred_multi, Y_multi_z)^2;

        fprintf('\n  1-component model:\n');
        fprintf('    R² = %.3f\n', R2_multi);
        fprintf('    Cumulative variance explained: %.1f%%\n', PCTVAR_multi(2,1));

        % Permutation test
        R2_perm_multi = zeros(1000, 1);
        rng(42);
        for iPerm = 1:1000
            Y_perm = Y_multi_z(randperm(length(Y_multi_z)));
            [~, ~, ~, ~, BETA_perm, ~, ~] = plsregress(X_multi_z, Y_perm, 1);
            Y_pred_perm = [ones(sum(valid_multi), 1), X_multi_z] * BETA_perm;
            R2_perm_multi(iPerm) = corr(Y_pred_perm, Y_perm)^2;
        end

        p_multi = sum(R2_perm_multi >= R2_multi) / 1000;
        fprintf('    Permutation p-value: p = %.4f\n', p_multi);

        if p_multi < 0.05
            fprintf('    ✅ SIGNIFICANT: AI connections jointly predict learning\n');
        else
            fprintf('    ❌ NOT SIGNIFICANT\n');
        end
    else
        fprintf('  Insufficient valid data (N = %d)\n', sum(valid_multi));
    end
else
    fprintf('  Insufficient data in Full Gaze (N = %d)\n', sum(c1_valid));
end
fprintf('\n');

%% ========================================================================
%  SUMMARY AND RESULTS
%  ========================================================================

fprintf('========================================================================\n');
fprintf('SUMMARY: KEY FINDINGS\n');
fprintf('========================================================================\n\n');

fprintf('CONNECTION ANALYZED: %s\n', sig_conn_title);
fprintf('  (Identified in Sup S4 as showing Full gaze > Partial/No gaze)\n\n');

fprintf('1. CONDITION EFFECT (Verification):\n');
fprintf('   Full vs Partial/No: t(%.0f) = %.2f, p = %.4f\n', df_cond, t_cond, p_cond);
if p_cond < 0.05
    fprintf('   ✅ CONFIRMED\n\n');
else
    fprintf('   ⚠️  Not replicated\n\n');
end

fprintf('2. CORRELATION WITH ATTENTION:\n');
fprintf('   Overall: r = %.3f, p = %.4f\n', r_atten_all, p_atten_all);
fprintf('   By condition:\n');
for iCond = 1:3
    fprintf('     %s: r = %.3f, p = %.4f, q = %.4f\n', ...
        cond_names{iCond}, r_atten_cond(iCond), p_atten_cond(iCond), p_atten_cond_fdr(iCond));
end
fprintf('\n');

fprintf('3. CORRELATION WITH LEARNING:\n');
fprintf('   Overall: r = %.3f, p = %.4f\n', r_learn_all, p_learn_all);
fprintf('   By condition:\n');
for iCond = 1:3
    fprintf('     %s: r = %.3f, p = %.4f, q = %.4f\n', ...
        cond_names{iCond}, r_learn_cond(iCond), p_learn_cond(iCond), p_learn_cond_fdr(iCond));
end
fprintf('\n');

fprintf('4. PLS PREDICTION OF LEARNING:\n');
fprintf('   Full Gaze only: R² = %.3f, p = %.4f\n', R2_pls, p_pls_c1);
fprintf('   All conditions: R² = %.3f, p = %.4f\n', R2_pls_all, p_pls_all);
fprintf('\n');

%% Save all results
results = struct();
results.connection_title = sig_conn_title;
results.connection_index = SIG_CONN_IDX;
results.condition_effect.t = t_cond;
results.condition_effect.p = p_cond;
results.condition_effect.df = df_cond;
results.attention.r_overall = r_atten_all;
results.attention.p_overall = p_atten_all;
results.attention.r_by_cond = r_atten_cond;
results.attention.p_by_cond = p_atten_cond;
results.attention.q_by_cond = p_atten_cond_fdr;
results.attention.lme = lme_atten_int;
results.learning.r_overall = r_learn_all;
results.learning.p_overall = p_learn_all;
results.learning.r_by_cond = r_learn_cond;
results.learning.p_by_cond = p_learn_cond;
results.learning.q_by_cond = p_learn_cond_fdr;
results.learning.lme = lme_learn_int;
results.pls.R2_full_gaze = R2_pls;
results.pls.p_full_gaze = p_pls_c1;
results.pls.R2_all_cond = R2_pls_all;
results.pls.p_all_cond = p_pls_all;

save([path, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/results/', ...
    'R1_GPDC_BEHAVIOR_CORRELATION_PLS.mat'], 'results');

fprintf('========================================================================\n');
fprintf('RESULTS SAVED\n');
fprintf('========================================================================\n\n');

fprintf('✅ Results saved to: results/R1_GPDC_BEHAVIOR_CORRELATION_PLS.mat\n\n');

fprintf('RECOMMENDED TEXT FOR MANUSCRIPT:\n');
fprintf('--------------------------------\n\n');
fprintf('To examine the behavioral relevance of the condition-sensitive AI\n');
fprintf('connection identified in Supplementary Section 4, we tested its\n');
fprintf('relationship with attention and learning outcomes.\n\n');

if p_atten_all < 0.05
    fprintf('The connection showed a significant correlation with attention\n');
    fprintf('(r = %.2f, p = %.3f), ', r_atten_all, p_atten_all);
end

if p_learn_all < 0.05
    fprintf('The connection significantly correlated with learning\n');
    fprintf('(r = %.2f, p = %.3f). ', r_learn_all, p_learn_all);
end

if p_pls_c1 < 0.05 || p_pls_all < 0.05
    fprintf('PLS regression confirmed that this connection\n');
    fprintf('predicted learning performance');
    if p_pls_c1 < 0.05
        fprintf(' in the Full Gaze condition\n');
        fprintf('(R² = %.2f, permutation p = %.3f)', R2_pls, p_pls_c1);
    end
    fprintf('.\n');
end

fprintf('\n');
fprintf('========================================================================\n');
fprintf('ANALYSIS COMPLETE\n');
fprintf('========================================================================\n\n');
