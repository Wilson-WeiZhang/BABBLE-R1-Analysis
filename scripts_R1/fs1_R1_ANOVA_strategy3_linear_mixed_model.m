%% ========================================================================
%  STRATEGY 3: Linear Mixed-Effects Model (LME)
%  ========================================================================
%
%  PURPOSE:
%  Use linear mixed-effects model to account for:
%  - Within-subject repeated measures (3 conditions per subject)
%  - Random intercepts for subjects
%  - Fixed effects: Condition, Age, Sex, Country
%
%  ADVANTAGES over Strategy 1:
%  - Properly accounts for non-independence of observations
%  - Better handles missing data
%  - More appropriate for repeated measures design
%
%  ========================================================================

clear all
clc
path1 = 'C:\Users\Admin\OneDrive - Nanyang Technological University\';
path1 = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'
%% Load CAM data
try
    data = textread([path1, 'infanteeg/CAM BABBLE EEG DATA/2024/looktime/CAM_AllData.txt']);
catch
    data = textread([path1, 'infanteeg/CAM BABBLE EEG DATA/2024/looktime/CAM_AllData.txt']);
end

PNo = unique(data(:,1));
PNo1 = unique(data(:,1)) + 1000;

% exclude two invalid UK subject, N from 31 to 29.
PNo1([12, 31]) = [];
PNo([12, 31]) = [];

SD_number = 2.5;

% Storage for learning differences
Learning_Diff = cell(length(PNo1), 3);  % subjects × conditions

% Initialize age and sex arrays
age_camb = zeros(1, length(PNo1));
sex_camb = zeros(1, length(PNo1));

%% Extract CAM data
for p = 1:length(PNo1)
    tmpind = find(data(:,1) == PNo(p) & data(:,9) > 0);

    age_camb(p) = data(tmpind(1), 2);
    sex_camb(p) = data(tmpind(1), 3);

    % Include block info: column 5 is block
    tmpdata = [data(tmpind, 6), data(tmpind, 8), data(tmpind, 9), data(tmpind, 5)];
    icut1 = mean(tmpdata(:, 3)) + SD_number * std(tmpdata(:, 3));

    indtest = find(tmpdata(:, 3) < icut1);

    for cond = 1:3
        ind_word1 = find(tmpdata(:, 1) == cond & tmpdata(:, 2) == 1 & tmpdata(:, 3) < icut1);
        ind_word2 = find(tmpdata(:, 1) == cond & tmpdata(:, 2) == 2 & tmpdata(:, 3) < icut1);

        word1_looks = tmpdata(ind_word1, 3);
        word2_looks = tmpdata(ind_word2, 3);
        block_word1 = tmpdata(ind_word1, 4);
        block_word2 = tmpdata(ind_word2, 4);

        % Add quality check like original script
        if length(indtest) > 1 && length(unique(tmpdata(indtest, 2))) == 2
            % METHOD: Match word1 and word2 by block, keep only paired trials
            % For each block, match the number of trials
            word1_matched = [];
            word2_matched = [];

            for blk = 1:3
                w1_blk = word1_looks(block_word1 == blk);
                w2_blk = word2_looks(block_word2 == blk);
                n_pairs = min(length(w1_blk), length(w2_blk));

                if n_pairs > 0
                    word1_matched = [word1_matched; w1_blk(1:n_pairs)];
                    word2_matched = [word2_matched; w2_blk(1:n_pairs)];
                end
            end

            learning_diff = word2_matched - word1_matched;

            % --- OTHER METHODS (COMMENTED) ---
            % METHOD 1: Simple trial pairing (old)
            % min_length = min(length(word1_looks), length(word2_looks));
            % learning_diff = word2_looks(1:min_length) - word1_looks(1:min_length);

            % METHOD 2: Pool all trials
            % learning_diff = nanmean(word2_looks) - nanmean(word1_looks);

            Learning_Diff{p, cond} = learning_diff;
        else
            Learning_Diff{p, cond} = NaN;
        end
    end
end

%% Load SG data
data = textread([path1, 'infanteeg/CAM BABBLE EEG DATA/2024/looktime/SG_AllData_040121.txt']);

PNo = unique(data(:,1));
PNo2 = unique(data(:,1)) + 2100;

Learning_Diff_sg = cell(length(PNo2), 3);

% Initialize age and sex arrays for SG
age_sg = zeros(1, length(PNo2));
sex_sg = zeros(1, length(PNo2));

for p = 1:length(PNo2)
    tmpind = find(data(:,1) == PNo(p) & data(:,9) > 0);

    age_sg(p) = data(tmpind(1), 2);
    sex_sg(p) = data(tmpind(1), 3);

    tmpdata = [data(tmpind, 6), data(tmpind, 8), data(tmpind, 9), data(tmpind, 5)];
    icut1 = mean(tmpdata(:, 3)) + SD_number * std(tmpdata(:, 3));

    indtest = find(tmpdata(:, 3) < icut1);

    for cond = 1:3
        ind_word1 = find(tmpdata(:, 1) == cond & tmpdata(:, 2) == 1 & tmpdata(:, 3) < icut1);
        ind_word2 = find(tmpdata(:, 1) == cond & tmpdata(:, 2) == 2 & tmpdata(:, 3) < icut1);

        word1_looks = tmpdata(ind_word1, 3);
        word2_looks = tmpdata(ind_word2, 3);
        block_word1 = tmpdata(ind_word1, 4);
        block_word2 = tmpdata(ind_word2, 4);

        if length(indtest) > 1 && length(unique(tmpdata(indtest, 2))) == 2
            % METHOD: Match word1 and word2 by block, keep only paired trials
            % For each block, match the number of trials
            word1_matched = [];
            word2_matched = [];

            for blk = 1:3
                w1_blk = word1_looks(block_word1 == blk);
                w2_blk = word2_looks(block_word2 == blk);
                n_pairs = min(length(w1_blk), length(w2_blk));

                if n_pairs > 0
                    word1_matched = [word1_matched; w1_blk(1:n_pairs)];
                    word2_matched = [word2_matched; w2_blk(1:n_pairs)];
                end
            end

            learning_diff = word2_matched - word1_matched;

            % --- OTHER METHODS (COMMENTED) ---
            % METHOD 1: Simple trial pairing (old)
            % min_length = min(length(word1_looks), length(word2_looks));
            % learning_diff = word2_looks(1:min_length) - word1_looks(1:min_length);

            % METHOD 2: Pool all trials
            % learning_diff = nanmean(word2_looks) - nanmean(word1_looks);

            Learning_Diff_sg{p, cond} = learning_diff;
        else
            Learning_Diff_sg{p, cond} = NaN;
        end
    end
end

%% Prepare data for LME (long format with subject ID)
age_all = [age_camb, age_sg];
sex_all = [sex_camb, sex_sg];
country_all = [ones(1, 29), 2 * ones(1, 18)];

n_subjects = length(age_all);

% Calculate mean learning for each subject × condition
learning_mean = nan(n_subjects, 3);

for p = 1:29
    for cond = 1:3
        if ~isempty(Learning_Diff{p, cond}) && ~any(isnan(Learning_Diff{p, cond}))
            learning_mean(p, cond) = mean(Learning_Diff{p, cond}, 'omitnan');
        end
    end
end

for p = 1:18
    for cond = 1:3
        if ~isempty(Learning_Diff_sg{p, cond}) && ~any(isnan(Learning_Diff_sg{p, cond}))
            learning_mean(p + 29, cond) = mean(Learning_Diff_sg{p, cond}, 'omitnan');
        end
    end
end


%% Create long-format table for LME
subject_id = [];
condition = [];
age = [];
sex = [];
country = [];
learning = [];

for subj = 1:n_subjects
    for cond = 1:3
        if ~isnan(learning_mean(subj, cond))
            subject_id = [subject_id; subj];
            condition = [condition; cond];
            age = [age; age_all(subj)];
            sex = [sex; sex_all(subj)];
            country = [country; country_all(subj)];
            learning = [learning; learning_mean(subj, cond)];
        end
    end
end

% Create table
tbl = table(subject_id, condition, age, sex, country, learning, ...
    'VariableNames', {'Subject', 'Condition', 'Age', 'Sex', 'Country', 'Learning'});

tbl.Subject = categorical(tbl.Subject);
tbl.Condition = categorical(tbl.Condition, [1, 2, 3], {'FullGaze', 'PartialGaze', 'NoGaze'});
tbl.Sex = categorical(tbl.Sex);
tbl.Country = categorical(tbl.Country, [1, 2], {'UK', 'SG'});

fprintf('========================================================================\n');
fprintf('STRATEGY 3: Linear Mixed-Effects Model (LME)\n');
fprintf('========================================================================\n\n');

fprintf('Data Summary:\n');
fprintf('  Total observations: %d\n', height(tbl));
fprintf('  Number of subjects: %d\n', length(unique(subject_id)));
fprintf('  Observations per subject: %.2f (range: %d-%d)\n', ...
    mean(histcounts(subject_id)), ...
    min(histcounts(subject_id)), ...
    max(histcounts(subject_id)));
fprintf('  DV: Learning = look2 - look1\n');
fprintf('  Fixed effects: Condition, Age, Sex, Country\n');
fprintf('  Random effects: Subject (random intercept)\n\n');

%% Model 2: LME with interactions
fprintf('\n========================================================================\n');
fprintf('MODEL 2: LME with Interactions\n');
fprintf('========================================================================\n\n');

lme_full = fitlme(tbl, 'Learning ~ Condition*Age + Condition*Sex + Condition*Country + (1|Subject)');

fprintf('Model Summary:\n');
disp(lme_full);

fprintf('\n--- Fixed Effects ---\n');
disp(lme_full.Coefficients);

fprintf('\n--- Random Effects ---\n');
fprintf('(See Random Effects Covariance Parameters in model summary above)\n');

fprintf('\n--- Model Fit Statistics ---\n');
fprintf('AIC: %.4f\n', lme_full.ModelCriterion.AIC);
fprintf('BIC: %.4f\n', lme_full.ModelCriterion.BIC);
fprintf('Log-Likelihood: %.4f\n', lme_full.LogLikelihood);



anova(lme_full)



%% ========================================================================
%  ALTERNATIVE METHOD (COMMENTED OUT): Split-data pairwise comparisons
%  NOTE: This approach splits data and refits separate LME models for each pair.
%        It is more liberal and changes SE/DF compared to the omnibus model.
%        The contrast-based method below is more statistically rigorous.
%% ========================================================================
%
% fprintf('\n========================================================================\n');
% fprintf('PAIRWISE CONDITION COMPARISONS (with interactions)\n');
% fprintf('========================================================================\n\n');
%
% % Compare Full vs Partial (exclude NoGaze)
% tbl_12 = tbl(tbl.Condition ~= 'NoGaze', :);
% tbl_12.Condition = removecats(tbl_12.Condition);
% lme_12 = fitlme(tbl_12, 'Learning ~ Condition*Age + Condition*Sex + Condition*Country + (1|Subject)');
% fprintf('Full vs Partial Gaze:\n');
% disp(lme_12.Coefficients);
%
% % Compare Full vs NoGaze (exclude Partial)
% tbl_13 = tbl(tbl.Condition ~= 'PartialGaze', :);
% tbl_13.Condition = removecats(tbl_13.Condition);
% lme_13 = fitlme(tbl_13, 'Learning ~ Condition*Age + Condition*Sex + Condition*Country + (1|Subject)');
% fprintf('\nFull vs No Gaze:\n');
% disp(lme_13.Coefficients);
%
% % Compare Partial vs NoGaze (exclude Full)
% tbl_23 = tbl(tbl.Condition ~= 'FullGaze', :);
% tbl_23.Condition = removecats(tbl_23.Condition);
% lme_23 = fitlme(tbl_23, 'Learning ~ Condition*Age + Condition*Sex + Condition*Country + (1|Subject)');
% fprintf('\nPartial vs No Gaze:\n');
% disp(lme_23.Coefficients);
%
% % Extract p-values for Condition main effect from coefficients
% p_cond = [lme_12.Coefficients.pValue(2), lme_13.Coefficients.pValue(2), lme_23.Coefficients.pValue(2)];
% q_cond = mafdr(p_cond, 'BHFDR', true);
%
% fprintf('\n--- FDR-Corrected Pairwise Comparisons ---\n');
% fprintf('Full vs Partial:  p=%.4f, q=%.4f\n', p_cond(1), q_cond(1));
% fprintf('Full vs No Gaze:  p=%.4f, q=%.4f\n', p_cond(2), q_cond(2));
% fprintf('Partial vs No:    p=%.4f, q=%.4f\n', p_cond(3), q_cond(3));

%% Post-hoc: Contrast-based Pairwise Comparisons
fprintf('\n========================================================================\n');
fprintf('POST-HOC: CONTRAST-BASED PAIRWISE COMPARISONS\n');
fprintf('(Uses coefTest on omnibus LME model with covariates)\n');
fprintf('========================================================================\n\n');

% Full vs Partial: test if Condition_PartialGaze coefficient = 0
% H = [0 1 0 0 0 0 0 0 0 0 0 0] tests beta(Condition_PartialGaze) = 0
p_12 = lme_full.Coefficients.pValue(2);
est_12 = lme_full.Coefficients.Estimate(2);
se_12 = lme_full.Coefficients.SE(2);

% Full vs NoGaze: test if Condition_NoGaze coefficient = 0
% H = [0 0 1 0 0 0 0 0 0 0 0 0] tests beta(Condition_NoGaze) = 0
p_13 = lme_full.Coefficients.pValue(3);
est_13 = lme_full.Coefficients.Estimate(3);
se_13 = lme_full.Coefficients.SE(3);

% Partial vs NoGaze: test if beta(Partial) - beta(NoGaze) = 0
% H = [0 1 -1 0 0 0 0 0 0 0 0 0] tests beta(PartialGaze) = beta(NoGaze)
H_23 = zeros(1, length(lme_full.Coefficients.Estimate));
H_23(2) = 1;   % Condition_PartialGaze
H_23(3) = -1;  % Condition_NoGaze
[p_23, F_23] = coefTest(lme_full, H_23);
est_23 = est_12 - est_13;  % Difference: Partial - NoGaze

% FDR correction across 3 comparisons
p_contrasts = [p_12, p_13, p_23];
q_contrasts = mafdr(p_contrasts, 'BHFDR', true);

fprintf('Full vs Partial:  Estimate=%.2f (SE=%.2f), p=%.4f, q=%.4f\n', est_12, se_12, p_12, q_contrasts(1));
fprintf('Full vs NoGaze:   Estimate=%.2f (SE=%.2f), p=%.4f, q=%.4f\n', est_13, se_13, p_13, q_contrasts(2));
fprintf('Partial vs NoGaze: Estimate=%.2f, p=%.4f, q=%.4f\n', est_23, p_23, q_contrasts(3));

%% Covariate-Corrected One-Sample T-Tests
fprintf('\n========================================================================\n');
fprintf('COVARIATE-CORRECTED ONE-SAMPLE T-TESTS\n');
fprintf('(Regress out Country, Age, Sex -> Average by Subject -> t-test vs 0)\n');
fprintf('========================================================================\n\n');

% Get data for each condition
cond_idx1 = find(condition == 1);
cond_idx2 = find(condition == 2);
cond_idx3 = find(condition == 3);

% Condition 1: Full Gaze
X1 = [ones(length(cond_idx1), 1), country(cond_idx1), age(cond_idx1), double(sex(cond_idx1))];
[~, ~, resid1] = regress(learning(cond_idx1), X1);
adjusted1 = resid1 + nanmean(learning(cond_idx1));
unique_ids_c1 = unique(subject_id(cond_idx1));
avg1 = arrayfun(@(id) nanmean(adjusted1(subject_id(cond_idx1) == id)), unique_ids_c1);
avg1 = avg1(~isnan(avg1));
[h1, p1, ci1, stats1] = ttest(avg1);

% Condition 2: Partial Gaze
X2 = [ones(length(cond_idx2), 1), country(cond_idx2), age(cond_idx2), double(sex(cond_idx2))];
[~, ~, resid2] = regress(learning(cond_idx2), X2);
adjusted2 = resid2 + nanmean(learning(cond_idx2));
unique_ids_c2 = unique(subject_id(cond_idx2));
avg2 = arrayfun(@(id) nanmean(adjusted2(subject_id(cond_idx2) == id)), unique_ids_c2);
avg2 = avg2(~isnan(avg2));
[h2, p2, ci2, stats2] = ttest(avg2);

% Condition 3: No Gaze
X3 = [ones(length(cond_idx3), 1), country(cond_idx3), age(cond_idx3), double(sex(cond_idx3))];
[~, ~, resid3] = regress(learning(cond_idx3), X3);
adjusted3 = resid3 + nanmean(learning(cond_idx3));
unique_ids_c3 = unique(subject_id(cond_idx3));
avg3 = arrayfun(@(id) nanmean(adjusted3(subject_id(cond_idx3) == id)), unique_ids_c3);
avg3 = avg3(~isnan(avg3));
[h3, p3, ci3, stats3] = ttest(avg3);

fprintf('Full Gaze:    t(%d)=%.2f, p=%.4f (uncorrected)\n', stats1.df, stats1.tstat, p1);
fprintf('Partial Gaze: t(%d)=%.2f, p=%.4f (uncorrected)\n', stats2.df, stats2.tstat, p2);
fprintf('No Gaze:      t(%d)=%.2f, p=%.4f (uncorrected)\n', stats3.df, stats3.tstat, p3);

q_ttest = mafdr([p1, p2, p3], 'BHFDR', true);
fprintf('\n--- FDR-Corrected ---\n');
fprintf('Full Gaze:    q=%.4f %s\n', q_ttest(1), ternary(q_ttest(1)<0.05, '***', ''));
fprintf('Partial Gaze: q=%.4f %s\n', q_ttest(2), ternary(q_ttest(2)<0.05, '***', ''));
fprintf('No Gaze:      q=%.4f %s\n', q_ttest(3), ternary(q_ttest(3)<0.05, '***', ''));

function out = ternary(cond, true_val, false_val)
    if cond
        out = true_val;
    else
        out = false_val;
    end
end
