%% Simplified Three-Part Analysis with Bootstrapping
% Part 1: Attention ~ AI*CONDGROUP interaction
% Part 2: CDI ~ AI (no association)
% Part 3: Mediation (report ONLY indirect effect with bootstrap CI)

clc
clear all
load('data_read_surr_gpdc2.mat','data')
load("CDI2.mat")

a=data;
g1=find(a(:,6)==1);
g2=find(a(:,6)==2);
g3=find(a(:,6)==3);
AGE=a(:,3);
SEX=a(:,4);
SEX=categorical(SEX);
COUNTRY=a(:,1);
COUNTRY=categorical(COUNTRY);
blocks=a(:,5);
blocks=categorical(blocks);
CONDGROUP_ori=a(:,6);
CONDGROUP=a(:,6);
CONDGROUP(find(CONDGROUP==3))=2;
CONDGROUP=categorical(CONDGROUP);
learning= a(:, 7);
atten=a(:,9);
ID=a(:,2);
ID=categorical(ID);

% Extract AI alpha connections
ai3=[10+81*8:9+81*9];
data_conn=sqrt(data(:,ai3));

Y = data_conn(:, 12); % AI_Alpha_Fz_to_F4 connection

fprintf('\n========================================================================\n');
fprintf('THREE-PART ANALYSIS: AI_Alpha_Fz_to_F4\n');
fprintf('========================================================================\n\n');

% Prepare data table
tbl_analysis = table(ID, zscore(learning), zscore(atten), zscore(AGE), SEX, COUNTRY, ...
    zscore(Y), blocks, CONDGROUP, 'VariableNames',...
    {'ID', 'learning', 'atten', 'AGE', 'SEX', 'COUNTRY', 'AI_conn', 'block', 'CONDGROUP'});

%% ========================================================================
%  PART 1: Interaction Analysis - Attention ~ AI*CONDGROUP
%  ========================================================================

fprintf('\n========================================================================\n');
fprintf('PART 1: INTERACTION ANALYSIS\n');
fprintf('========================================================================\n\n');

fprintf('Model: attention ~ AI_conn * CONDGROUP + AGE + SEX + COUNTRY + (1|ID)\n\n');

lme_interaction = fitlme(tbl_analysis, 'atten ~ AI_conn * CONDGROUP + AGE + SEX + COUNTRY + (1|ID)');
disp(lme_interaction);

tabulate(CONDGROUP_ori)
% Extract interaction term
coeffIdx_int = strcmp(lme_interaction.Coefficients.Name, 'AI_conn:CONDGROUP_2');
if any(coeffIdx_int)
    beta_int = lme_interaction.Coefficients.Estimate(coeffIdx_int);
    se_int = lme_interaction.Coefficients.SE(coeffIdx_int);
    t_int = lme_interaction.Coefficients.tStat(coeffIdx_int);
    p_int = lme_interaction.Coefficients.pValue(coeffIdx_int);

    fprintf('\n--- Key Result ---\n');
    fprintf('Interaction effect (AI*Gaze):\n');
    fprintf('  β = %.4f, SE = %.4f, t = %.4f, p = %.4f%s\n\n', ...
        beta_int, se_int, t_int, p_int, get_sig_star(p_int));

    if p_int < 0.05
        fprintf('*** SIGNIFICANT INTERACTION DETECTED ***\n');
        fprintf('The relationship between AI connection and attention differs by gaze condition.\n\n');
    end
end

fprintf('========================================================================\n\n');

%% ========================================================================
%  PART 2: CDI Analysis - CDI ~ Subject-Averaged AI Connection
%  ========================================================================

fprintf('\n========================================================================\n');
fprintf('PART 2: CDI ANALYSIS (Between-Subject)\n');
fprintf('========================================================================\n\n');

fprintf('NOTE: CDI is a between-subject variable (one value per infant)\n');
fprintf('Computing subject-averaged AI connection strength...\n\n');

% Calculate subject-averaged AI connection
unique_IDs = unique(ID);
n_subjects = length(unique_IDs);

AI_subj_mean = zeros(n_subjects, 1);
AGE_subj = zeros(n_subjects, 1);
SEX_subj = zeros(n_subjects, 1);
COUNTRY_subj = zeros(n_subjects, 1);
CDI_subj = zeros(n_subjects, 1);

for i = 1:n_subjects
    subj_idx = (ID == unique_IDs(i));
    AI_subj_mean(i) = mean(Y(subj_idx));
    AGE_subj(i) = AGE(find(subj_idx, 1));
    SEX_subj(i) = double(SEX(find(subj_idx, 1)));
    COUNTRY_subj(i) = double(COUNTRY(find(subj_idx, 1)));

    % Get CDI for this subject from a2 (column 4)
    % Convert categorical ID to numeric for matching
    subj_id_num = str2double(char(unique_IDs(i)));
    cdi_idx = find(a2(:,1) == subj_id_num, 1);
    if ~isempty(cdi_idx)
        CDI_subj(i) = a2(cdi_idx, 4);
    else
        CDI_subj(i) = NaN;
    end
end

% Remove subjects with missing CDI
valid_idx = ~isnan(CDI_subj);
AI_subj_mean = AI_subj_mean(valid_idx);
AGE_subj = AGE_subj(valid_idx);
SEX_subj = categorical(SEX_subj(valid_idx));
COUNTRY_subj = categorical(COUNTRY_subj(valid_idx));
CDI_subj = CDI_subj(valid_idx);

fprintf('Valid subjects with CDI data: %d\n\n', sum(valid_idx));

% Between-subject regression: CDI ~ AI_mean + covariates
fprintf('Model: CDI ~ Subject-Averaged-AI + AGE + SEX + COUNTRY\n\n');

tbl_cdi_between = table(zscore(AI_subj_mean), zscore(AGE_subj), SEX_subj, COUNTRY_subj, zscore(CDI_subj), ...
    'VariableNames', {'AI_conn_mean', 'AGE', 'SEX', 'COUNTRY', 'CDI'});

mdl_cdi = fitlm(tbl_cdi_between, 'CDI ~ AI_conn_mean + AGE + SEX + COUNTRY');
disp(mdl_cdi);

% Extract AI connection effect on CDI
coeffIdx_ai = find(strcmp(mdl_cdi.CoefficientNames, 'AI_conn_mean'));
if ~isempty(coeffIdx_ai)
    beta_ai_cdi = mdl_cdi.Coefficients.Estimate(coeffIdx_ai);
    se_ai_cdi = mdl_cdi.Coefficients.SE(coeffIdx_ai);
    t_ai_cdi = mdl_cdi.Coefficients.tStat(coeffIdx_ai);
    p_ai_cdi = mdl_cdi.Coefficients.pValue(coeffIdx_ai);

    fprintf('\n--- Key Result ---\n');
    fprintf('Subject-Averaged AI connection → CDI:\n');
    fprintf('  β = %.4f, SE = %.4f, t = %.4f, p = %.4f%s\n\n', ...
        beta_ai_cdi, se_ai_cdi, t_ai_cdi, p_ai_cdi, get_sig_star(p_ai_cdi));

    if p_ai_cdi >= 0.05
        fprintf('No significant association between AI connection and CDI.\n\n');
    else
        fprintf('Significant association detected between AI connection and CDI.\n\n');
    end
end

fprintf('========================================================================\n\n');

%% ========================================================================
%  PART 3: Mediation Analysis with Bootstrap CI
%  ========================================================================

fprintf('\n========================================================================\n');
fprintf('PART 3: MEDIATION ANALYSIS (Bootstrap 95%% CI)\n');
fprintf('========================================================================\n\n');

fprintf('Computing mediation effects with bootstrapping...\n');
fprintf('(This may take a few minutes)\n\n');

% Set bootstrap parameters
nboot = 1000; % Reduced for computational efficiency
rng(42); % Set seed for reproducibility

% Prepare data for bootstrapping
data_for_boot = [double(ID), learning, atten, AGE, double(SEX), double(COUNTRY), Y, double(CONDGROUP)];

% Bootstrap function for mediation
boot_mediation = @(data_boot) compute_mediation_effects(data_boot);

% Run bootstrap
fprintf('Running %d bootstrap samples...\n', nboot);
boot_results = bootstrp(nboot, boot_mediation, data_for_boot);

% Original estimates
original_effects = compute_mediation_effects(data_for_boot);

% Extract bootstrap distributions
indirect_boot = boot_results(:, 1);
direct_boot = boot_results(:, 2);
total_boot = boot_results(:, 3);

% Calculate 95% CI
indirect_ci = prctile(indirect_boot, [2.5, 97.5]);
direct_ci = prctile(direct_boot, [2.5, 97.5]);
total_ci = prctile(total_boot, [2.5, 97.5]);

% Calculate p-value for indirect effect (proportion of bootstrap samples with opposite sign)
p_indirect_boot = mean(indirect_boot * sign(original_effects(1)) < 0) * 2;
p_indirect_boot = min(p_indirect_boot, 1); % Cap at 1

% Calculate p-value for direct effect
p_direct_boot = mean(direct_boot * sign(original_effects(2)) < 0) * 2;
p_direct_boot = min(p_direct_boot, 1); % Cap at 1

fprintf('\n========================================================================\n');
fprintf('MEDIATION RESULTS (Bootstrap Method)\n');
fprintf('========================================================================\n\n');

fprintf('Effects:\n');
fprintf('  Indirect effect (a×b):  β = %.4f, 95%% CI [%.4f, %.4f], p = %.4f%s\n', ...
    abs(original_effects(1)), indirect_ci(1), indirect_ci(2), p_indirect_boot, ...
    get_sig_star(p_indirect_boot));
fprintf('  Direct effect (c''):     β = %.4f, 95%% CI [%.4f, %.4f], p = %.4f%s\n', ...
    original_effects(2), direct_ci(1), direct_ci(2), p_direct_boot, ...
    get_sig_star(p_direct_boot));
fprintf('  Total effect (c):       β = %.4f, 95%% CI [%.4f, %.4f]\n\n', ...
    original_effects(3), total_ci(1), total_ci(2));

% Check if 95% CI excludes zero for indirect effect
if indirect_ci(1) * indirect_ci(2) > 0
    fprintf('*** SIGNIFICANT INDIRECT EFFECT DETECTED ***\n');
    fprintf('The 95%% CI does not include zero.\n');
    fprintf('The AI connection significantly mediates the gaze-learning relationship.\n\n');
else
    fprintf('The indirect effect is not significant (95%% CI includes zero).\n\n');
end

% Interpretation
if abs(original_effects(2)) < abs(original_effects(1)) && p_indirect_boot < 0.05
    fprintf('Interpretation: Full mediation detected.\n');
    fprintf('The effect of gaze on learning is primarily mediated through AI connection.\n\n');
elseif p_indirect_boot < 0.05
    fprintf('Interpretation: Partial mediation detected.\n');
    fprintf('The AI connection partially mediates the effect of gaze on learning.\n\n');
end

fprintf('========================================================================\n');
fprintf('END OF ANALYSIS\n');
fprintf('========================================================================\n\n');

%% Helper Functions

function stars = get_sig_star(p)
    if p < 0.001
        stars = ' ***';
    elseif p < 0.01
        stars = ' **';
    elseif p < 0.05
        stars = ' *';
    else
        stars = '';
    end
end

function effects = compute_mediation_effects(data_matrix)
    % Extract variables from data matrix
    ID = categorical(data_matrix(:, 1));
    learning = data_matrix(:, 2);
    atten = data_matrix(:, 3);
    AGE = data_matrix(:, 4);
    SEX = categorical(data_matrix(:, 5));
    COUNTRY = categorical(data_matrix(:, 6));
    AI_conn = data_matrix(:, 7);
    CONDGROUP = categorical(data_matrix(:, 8));

    % Z-score continuous variables
    learning_z = zscore(learning);
    atten_z = zscore(atten);
    AGE_z = zscore(AGE);
    AI_conn_z = zscore(AI_conn);

    try
        % Path a: CONDGROUP → AI_conn
        tbl_a = table(ID, AI_conn_z, AGE_z, SEX, COUNTRY, CONDGROUP, ...
            'VariableNames', {'ID', 'AI_conn', 'AGE', 'SEX', 'COUNTRY', 'CONDGROUP'});
        lme_a = fitlme(tbl_a, 'AI_conn ~ CONDGROUP + AGE + SEX + COUNTRY + (1|ID)', 'FitMethod', 'ML');
        coeffIdx_a = strcmp(lme_a.Coefficients.Name, 'CONDGROUP_2');
        a_path = lme_a.Coefficients.Estimate(coeffIdx_a);

        % Path b + direct effect: learning ~ AI_conn + CONDGROUP
        tbl_b = table(ID, learning_z, AI_conn_z, AGE_z, SEX, COUNTRY, CONDGROUP, ...
            'VariableNames', {'ID', 'learning', 'AI_conn', 'AGE', 'SEX', 'COUNTRY', 'CONDGROUP'});
        lme_b = fitlme(tbl_b, 'learning ~ AI_conn + CONDGROUP + AGE + SEX + COUNTRY + (1|ID)', 'FitMethod', 'ML');
        coeffIdx_b = strcmp(lme_b.Coefficients.Name, 'AI_conn');
        b_path = lme_b.Coefficients.Estimate(coeffIdx_b);
        coeffIdx_cprime = strcmp(lme_b.Coefficients.Name, 'CONDGROUP_2');
        cprime_path = lme_b.Coefficients.Estimate(coeffIdx_cprime);

        % Total effect: learning ~ CONDGROUP
        tbl_c = table(ID, learning_z, AGE_z, SEX, COUNTRY, CONDGROUP, ...
            'VariableNames', {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY', 'CONDGROUP'});
        lme_c = fitlme(tbl_c, 'learning ~ CONDGROUP + AGE + SEX + COUNTRY + (1|ID)', 'FitMethod', 'ML');
        coeffIdx_c = strcmp(lme_c.Coefficients.Name, 'CONDGROUP_2');
        c_path = lme_c.Coefficients.Estimate(coeffIdx_c);

        % Calculate effects
        indirect_effect = a_path * b_path;
        direct_effect = cprime_path;
        total_effect = c_path;

        effects = [indirect_effect; direct_effect; total_effect];
    catch
        % If model fails (e.g., in bootstrap), return NaN
        effects = [NaN; NaN; NaN];
    end
end
