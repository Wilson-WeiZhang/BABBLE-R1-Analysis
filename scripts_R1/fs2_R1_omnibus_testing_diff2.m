%% ========================================================================
%  STEP 2: OMNIBUS TESTING WITH BLOCK-MATCHED DIFFERENCE SCORES (R1)
%  ========================================================================
%
%  PURPOSE:
%  Perform omnibus testing across three gaze conditions using learning
%  values calculated from block-matched differences (word2 - word1).
%
%  PREREQUISITE:
%  Run fs1_R1_LEARNING_BLOCKS_behav_calculation_diff2.m first to generate
%  MeanLook_Diff and MeanLook_Diff2 variables.
%
%  ANALYSIS APPROACH:
%  1. Load block-matched difference scores from fs1_R1_LEARNING_BLOCKS_behav_calculation_diff2.m
%  2. Create data table with learning scores, demographics, and covariates
%  3. Perform one-sample t-tests per condition (with FDR correction)
%  4. Perform omnibus test across conditions using Linear Mixed Effects (LME)
%  5. Post-hoc pairwise comparisons between conditions
%
%  KEY STATISTICAL TESTS:
%  - One-sample t-tests: Learning vs. 0 within each condition
%  - LME omnibus: learning ~ condition + age + sex + country + (1|ID)
%  - Post-hoc comparisons: Full vs. Partial, Full vs. No, Partial vs. No
%
%  ========================================================================

clear all
clc

%% STEP 1: Load block-matched difference scores
fprintf('\n========================================================================\n');
fprintf('LOADING BLOCK-MATCHED DIFFERENCE SCORES\n');
fprintf('========================================================================\n\n');

% Run the calculation script or load the workspace
path1 = 'C:\Users\Admin\OneDrive - Nanyang Technological University\';

% Check if variables exist, otherwise run the calculation script
if ~exist('MeanLook_Diff', 'var') || ~exist('MeanLook_Diff2', 'var')
    fprintf('Running fs1_R1_LEARNING_BLOCKS_behav_calculation_diff2.m...\n');
    run([path1, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/scripts_R1/fs1_R1_LEARNING_BLOCKS_behav_calculation_diff2.m']);
    fprintf('Done.\n\n');
else
    fprintf('Variables MeanLook_Diff and MeanLook_Diff2 already exist.\n\n');
end

%% STEP 2: Create data table with block-matched learning scores
fprintf('========================================================================\n');
fprintf('CREATING DATA TABLE FROM BLOCK-MATCHED DIFFERENCE SCORES\n');
fprintf('========================================================================\n\n');

% Initialize arrays
Country_vec = [];
ID_vec = [];
AGE_vec = [];
SEX_vec = [];
Condition_vec = [];
Block_vec = [];
Learning_vec = [];

% UK data (Cambridge) - MeanLook_Diff
PNo1 = unique(data(:,1))+1000;
PNo1([12,31])=[];

for p = 1:length(PNo1)
    for cond = 1:3
        if ~isnan(MeanLook_Diff{p,cond}) && ~isempty(MeanLook_Diff{p,cond})
            % Get all difference scores for this participant and condition
            diffs = MeanLook_Diff{p,cond};
            n_diffs = length(diffs);

            % For now, store the mean across all blocks
            % (Alternative: store each block separately)
            Country_vec = [Country_vec; 1];  % UK = 1
            ID_vec = [ID_vec; PNo1(p)];
            AGE_vec = [AGE_vec; age_camb(p)];
            SEX_vec = [SEX_vec; sex_camb(p)];
            Condition_vec = [Condition_vec; cond];
            Block_vec = [Block_vec; NaN];  % Mean across blocks
            Learning_vec = [Learning_vec; nanmean(diffs)];
        end
    end
end

% SG data (Singapore) - MeanLook_Diff2
data_sg = textread([path1,'infanteeg/CAM BABBLE EEG DATA/2024/looktime/SG_AllData_040121.txt']);
PNo2 = unique(data_sg(:,1))+2100;

for p = 1:length(PNo2)
    for cond = 1:3
        if ~isnan(MeanLook_Diff2{p,cond}) && ~isempty(MeanLook_Diff2{p,cond})
            % Get all difference scores for this participant and condition
            diffs = MeanLook_Diff2{p,cond};
            n_diffs = length(diffs);

            % Store the mean across all blocks
            Country_vec = [Country_vec; 2];  % SG = 2
            ID_vec = [ID_vec; PNo2(p)];
            AGE_vec = [AGE_vec; age_sg(p)];
            SEX_vec = [SEX_vec; sex_sg(p)];
            Condition_vec = [Condition_vec; cond];
            Block_vec = [Block_vec; NaN];  % Mean across blocks
            Learning_vec = [Learning_vec; nanmean(diffs)];
        end
    end
end

% Create categorical variables
Country = categorical(Country_vec);
ID = categorical(ID_vec);
SEX = categorical(SEX_vec);
Condition = categorical(Condition_vec);

% Create data table
dataTable = table(Country, ID, AGE_vec, SEX, Condition, Learning_vec, ...
    'VariableNames', {'Country', 'ID', 'AGE', 'SEX', 'Condition', 'Learning'});

fprintf('Data table created:\n');
fprintf('Total observations: %d\n', height(dataTable));
fprintf('Unique subjects: %d\n', length(unique(ID_vec)));
fprintf('Conditions: %d\n', length(unique(Condition_vec)));
fprintf('Countries: UK=%d, SG=%d\n', sum(Country_vec==1), sum(Country_vec==2));

% Define condition indices
c1 = find(Condition_vec == 1);  % Full Gaze
c2 = find(Condition_vec == 2);  % Partial Gaze
c3 = find(Condition_vec == 3);  % No Gaze

fprintf('\nObservations per condition:\n');
fprintf('Full Gaze:    %d\n', length(c1));
fprintf('Partial Gaze: %d\n', length(c2));
fprintf('No Gaze:      %d\n', length(c3));

%% STEP 3: One-sample t-tests per condition (learning vs 0)
fprintf('\n========================================================================\n');
fprintf('ONE-SAMPLE T-TESTS: LEARNING vs ZERO (WITH COVARIATES)\n');
fprintf('Method: Regress out covariates, then one-sample t-test\n');
fprintf('========================================================================\n\n');

% Condition 1: Full Gaze
fprintf('--- Condition 1: Full Gaze ---\n');
X1 = [ones(size(AGE_vec(c1))) Country_vec(c1) AGE_vec(c1) SEX_vec(c1)];
[~,~,resid1] = regress(Learning_vec(c1), X1);
adjusted_scores1 = resid1 + nanmean(Learning_vec(c1));

[h1, p1, ci1, stats1] = ttest(adjusted_scores1);
fprintf('N = %d\n', length(adjusted_scores1));
fprintf('Mean = %.4f (SE = %.4f)\n', mean(adjusted_scores1), std(adjusted_scores1)/sqrt(length(adjusted_scores1)));
fprintf('t(%d) = %.2f, p = %.4f (uncorrected)\n\n', stats1.df, stats1.tstat, p1);

% Condition 2: Partial Gaze
fprintf('--- Condition 2: Partial Gaze ---\n');
X2 = [ones(size(AGE_vec(c2))) Country_vec(c2) AGE_vec(c2) SEX_vec(c2)];
[~,~,resid2] = regress(Learning_vec(c2), X2);
adjusted_scores2 = resid2 + nanmean(Learning_vec(c2));

[h2, p2, ci2, stats2] = ttest(adjusted_scores2);
fprintf('N = %d\n', length(adjusted_scores2));
fprintf('Mean = %.4f (SE = %.4f)\n', mean(adjusted_scores2), std(adjusted_scores2)/sqrt(length(adjusted_scores2)));
fprintf('t(%d) = %.2f, p = %.4f (uncorrected)\n\n', stats2.df, stats2.tstat, p2);

% Condition 3: No Gaze
fprintf('--- Condition 3: No Gaze ---\n');
X3 = [ones(size(AGE_vec(c3))) Country_vec(c3) AGE_vec(c3) SEX_vec(c3)];
[~,~,resid3] = regress(Learning_vec(c3), X3);
adjusted_scores3 = resid3 + nanmean(Learning_vec(c3));

[h3, p3, ci3, stats3] = ttest(adjusted_scores3);
fprintf('N = %d\n', length(adjusted_scores3));
fprintf('Mean = %.4f (SE = %.4f)\n', mean(adjusted_scores3), std(adjusted_scores3)/sqrt(length(adjusted_scores3)));
fprintf('t(%d) = %.2f, p = %.4f (uncorrected)\n\n', stats3.df, stats3.tstat, p3);

% FDR correction
fprintf('--- FDR-Corrected Results (BHFDR) ---\n');
p_vals = [p1; p2; p3];
q_vals = mafdr(p_vals, 'BHFDR', true);

fprintf('%-20s %12s %12s\n', 'Condition', 'p-value', 'q-value');
fprintf('%-20s %12s %12s\n', repmat('-',1,20), repmat('-',1,12), repmat('-',1,12));
fprintf('%-20s %12.4f %12.4f', 'Full Gaze', p1, q_vals(1));
if q_vals(1) < 0.05, fprintf(' ***\n'); else, fprintf('\n'); end
fprintf('%-20s %12.4f %12.4f', 'Partial Gaze', p2, q_vals(2));
if q_vals(2) < 0.05, fprintf(' ***\n'); else, fprintf('\n'); end
fprintf('%-20s %12.4f %12.4f', 'No Gaze', p3, q_vals(3));
if q_vals(3) < 0.05, fprintf(' ***\n'); else, fprintf('\n'); end

%% STEP 4: Omnibus test - LME across conditions
fprintf('\n========================================================================\n');
fprintf('OMNIBUS TEST: LINEAR MIXED EFFECTS MODEL\n');
fprintf('Model: Learning ~ Condition + AGE + SEX + Country + (1|ID)\n');
fprintf('========================================================================\n\n');

% Fit LME model with condition as fixed effect
lme_omnibus = fitlme(dataTable, 'Learning ~ Condition + AGE + SEX + Country + (1|ID)');

% Display model summary
disp(lme_omnibus);

% Test for overall effect of Condition
fprintf('\n--- Testing Overall Effect of Condition ---\n');
[pVal_omnibus, F_omnibus, DF1_omnibus, DF2_omnibus] = coefTest(lme_omnibus, [0 1 0 0 0 0; 0 0 1 0 0 0]);
fprintf('F(%d, %d) = %.2f, p = %.4f\n', DF1_omnibus, DF2_omnibus, F_omnibus, pVal_omnibus);

if pVal_omnibus < 0.05
    fprintf('\n*** SIGNIFICANT OMNIBUS EFFECT OF CONDITION ***\n');
    fprintf('At least one condition differs significantly from the reference.\n');
else
    fprintf('\nNo significant omnibus effect of condition (p = %.4f)\n', pVal_omnibus);
end

%% STEP 5: Post-hoc pairwise comparisons
fprintf('\n========================================================================\n');
fprintf('POST-HOC PAIRWISE COMPARISONS BETWEEN CONDITIONS\n');
fprintf('Method: LME with contrast coding\n');
fprintf('========================================================================\n\n');

% Comparison 1: Full Gaze vs. Partial Gaze
fprintf('--- Comparison 1: Full Gaze vs. Partial Gaze ---\n');
dataTable_12 = dataTable(Condition_vec == 1 | Condition_vec == 2, :);
lme_12 = fitlme(dataTable_12, 'Learning ~ Condition + AGE + SEX + Country + (1|ID)');
coef_12 = lme_12.Coefficients;
% Find the condition effect row
cond_idx = find(contains(coef_12.Name, 'Condition_2'));
if ~isempty(cond_idx)
    fprintf('Coefficient: %.4f (SE = %.4f)\n', coef_12.Estimate(cond_idx), coef_12.SE(cond_idx));
    fprintf('t(%.1f) = %.2f, p = %.4f\n\n', coef_12.DF(cond_idx), coef_12.tStat(cond_idx), coef_12.pValue(cond_idx));
    p_12 = coef_12.pValue(cond_idx);
else
    fprintf('Could not find Condition effect in model.\n\n');
    p_12 = NaN;
end

% Comparison 2: Full Gaze vs. No Gaze
fprintf('--- Comparison 2: Full Gaze vs. No Gaze ---\n');
dataTable_13 = dataTable(Condition_vec == 1 | Condition_vec == 3, :);
lme_13 = fitlme(dataTable_13, 'Learning ~ Condition + AGE + SEX + Country + (1|ID)');
coef_13 = lme_13.Coefficients;
cond_idx = find(contains(coef_13.Name, 'Condition_3'));
if ~isempty(cond_idx)
    fprintf('Coefficient: %.4f (SE = %.4f)\n', coef_13.Estimate(cond_idx), coef_13.SE(cond_idx));
    fprintf('t(%.1f) = %.2f, p = %.4f\n\n', coef_13.DF(cond_idx), coef_13.tStat(cond_idx), coef_13.pValue(cond_idx));
    p_13 = coef_13.pValue(cond_idx);
else
    fprintf('Could not find Condition effect in model.\n\n');
    p_13 = NaN;
end

% Comparison 3: Partial Gaze vs. No Gaze
fprintf('--- Comparison 3: Partial Gaze vs. No Gaze ---\n');
dataTable_23 = dataTable(Condition_vec == 2 | Condition_vec == 3, :);
lme_23 = fitlme(dataTable_23, 'Learning ~ Condition + AGE + SEX + Country + (1|ID)');
coef_23 = lme_23.Coefficients;
cond_idx = find(contains(coef_23.Name, 'Condition_3'));
if ~isempty(cond_idx)
    fprintf('Coefficient: %.4f (SE = %.4f)\n', coef_23.Estimate(cond_idx), coef_23.SE(cond_idx));
    fprintf('t(%.1f) = %.2f, p = %.4f\n\n', coef_23.DF(cond_idx), coef_23.tStat(cond_idx), coef_23.pValue(cond_idx));
    p_23 = coef_23.pValue(cond_idx);
else
    fprintf('Could not find Condition effect in model.\n\n');
    p_23 = NaN;
end

% FDR correction for post-hoc comparisons
fprintf('--- FDR-Corrected Post-Hoc Results (BHFDR) ---\n');
p_posthoc = [p_12; p_13; p_23];
q_posthoc = mafdr(p_posthoc, 'BHFDR', true);

fprintf('%-30s %12s %12s\n', 'Comparison', 'p-value', 'q-value');
fprintf('%-30s %12s %12s\n', repmat('-',1,30), repmat('-',1,12), repmat('-',1,12));
fprintf('%-30s %12.4f %12.4f', 'Full vs. Partial', p_12, q_posthoc(1));
if q_posthoc(1) < 0.05, fprintf(' ***\n'); else, fprintf('\n'); end
fprintf('%-30s %12.4f %12.4f', 'Full vs. No Gaze', p_13, q_posthoc(2));
if q_posthoc(2) < 0.05, fprintf(' ***\n'); else, fprintf('\n'); end
fprintf('%-30s %12.4f %12.4f', 'Partial vs. No Gaze', p_23, q_posthoc(3));
if q_posthoc(3) < 0.05, fprintf(' ***\n'); else, fprintf('\n'); end

%% STEP 6: Summary of results
fprintf('\n========================================================================\n');
fprintf('SUMMARY OF OMNIBUS TESTING RESULTS\n');
fprintf('========================================================================\n\n');

fprintf('ONE-SAMPLE T-TESTS (Learning vs. 0):\n');
fprintf('  Full Gaze:    t(%d) = %.2f, q = %.4f', stats1.df, stats1.tstat, q_vals(1));
if q_vals(1) < 0.05, fprintf(' [SIGNIFICANT]\n'); else, fprintf('\n'); end
fprintf('  Partial Gaze: t(%d) = %.2f, q = %.4f', stats2.df, stats2.tstat, q_vals(2));
if q_vals(2) < 0.05, fprintf(' [SIGNIFICANT]\n'); else, fprintf('\n'); end
fprintf('  No Gaze:      t(%d) = %.2f, q = %.4f', stats3.df, stats3.tstat, q_vals(3));
if q_vals(3) < 0.05, fprintf(' [SIGNIFICANT]\n'); else, fprintf('\n'); end

fprintf('\nOMNIBUS TEST (Condition Effect):\n');
fprintf('  F(%d, %d) = %.2f, p = %.4f', DF1_omnibus, DF2_omnibus, F_omnibus, pVal_omnibus);
if pVal_omnibus < 0.05, fprintf(' [SIGNIFICANT]\n'); else, fprintf('\n'); end

fprintf('\nPOST-HOC PAIRWISE COMPARISONS:\n');
fprintf('  Full vs. Partial:   q = %.4f', q_posthoc(1));
if q_posthoc(1) < 0.05, fprintf(' [SIGNIFICANT]\n'); else, fprintf('\n'); end
fprintf('  Full vs. No Gaze:   q = %.4f', q_posthoc(2));
if q_posthoc(2) < 0.05, fprintf(' [SIGNIFICANT]\n'); else, fprintf('\n'); end
fprintf('  Partial vs. No:     q = %.4f', q_posthoc(3));
if q_posthoc(3) < 0.05, fprintf(' [SIGNIFICANT]\n'); else, fprintf('\n'); end

fprintf('\n========================================================================\n');
fprintf('ANALYSIS COMPLETE\n');
fprintf('========================================================================\n');
