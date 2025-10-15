%% ========================================================================
%  STEP 1: Calculate Behavioral Learning Metrics (DIFFERENCE VERSION)
%  ========================================================================
%
%  PURPOSE:
%  Calculate infant learning performance from raw looking time data during
%  the Testing phase. This version computes within-trial differences between
%  word1 and word2 looking times.
%
%  KEY MODIFICATION:
%  Instead of storing word1 and word2 separately, this algorithm:
%  - Extracts both word=1 and word=2 trials simultaneously
%  - Computes the difference (word2 - word1) within each condition/trial
%  - Stores the difference scores for analysis
%
%  LEARNING METRIC:
%  - Looking time difference: Word2 - Word1 (in seconds)
%  - Computed at the trial level before averaging
%
%  DATA QUALITY CONTROL:
%  - Outlier exclusion: Trials exceeding mean + 2.5 SD are rejected
%  - Requires both valid word and nonword looks per testing phase
%
%  STATISTICS REPORTED:
%  - Cohen's d (effect size)
%  - Normality tests (Shapiro-Wilk, Lilliefors)
%  - Q-Q plots for visual normality assessment
%  - Bonferroni-corrected p-values
%
%  ========================================================================

%% this step calculates learning and attention from raw data file
clear all
clc
path1 ='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'

%% camb data learning calculation
try
    data = textread([path1,'infanteeg/CAM BABBLE EEG DATA/2024/looktime/CAM_AllData.txt']);
catch
    data = textread([path1,'infanteeg/CAM BABBLE EEG DATA/2024/looktime/CAM_AllData.txt']);
end
% get ID list
PNo = unique(data(:,1));
PNo1 = unique(data(:,1))+1000;
PNo1([12,31])=[];
PNo([12,31])=[];

% cutoff setting
SD_number=2.5;

% count samples
count=0;
count_clear=0;


for p = 1:length(PNo1)
    tmpind = find(data(:,1) == PNo(p) & data(:,9)>0); % non-zero looks
    %     record age sex
    age_camb(p)=data(tmpind(1),2);
    sex_camb(p)=data(tmpind(1),3);
    %   in data, the column No.:  6 cond, 8 word, 9 learning, 10 error, 5 block
    tmpdata = [data(tmpind,6), data(tmpind,8), data(tmpind,9), data(tmpind,10),data(tmpind,5)]; % RAW/Z looking times by participant

    icut1 = mean(tmpdata(:,3)) + SD_number*std(tmpdata(:,3)); % individual threshold as SD (default = 2.5 SD above mean)

    indtest = find( tmpdata(:,3) < icut1);

    for cond = 1:3

        % NEW ALGORITHM: Extract both word=1 and word=2 simultaneously
        % and compute difference within each trial
        ind_word1 = find(tmpdata(:,1) == cond & tmpdata(:,2) == 1 & tmpdata(:,3) < icut1);
        ind_word2 = find(tmpdata(:,1) == cond & tmpdata(:,2) == 2 & tmpdata(:,3) < icut1);

        % Get the looking times for each word type
        word1_looks = tmpdata(ind_word1, 3);
        word2_looks = tmpdata(ind_word2, 3);

        % Calculate difference (word2 - word1)
        % Match trials by taking minimum length
        min_length = min(length(word1_looks), length(word2_looks));

        if min_length > 0 && length(indtest) > 1 && length(unique(tmpdata(indtest,2)))==2
            % Compute trial-by-trial difference
            look_diff = word2_looks(1:min_length) - word1_looks(1:min_length);

            % Store the difference scores
            MeanLook_Diff{p,cond} = look_diff;

            count_clear = count_clear + min_length;
            count = count + length(ind_word1) + length(ind_word2);
        else
            MeanLook_Diff{p,cond} = NaN;
        end

    end
end
clear tmpind tmpdata


%% SG learning calculation

data = textread([path1,'infanteeg/CAM BABBLE EEG DATA/2024/looktime/SG_AllData_040121.txt']);

% get ID list
PNo = unique(data(:,1));
PNo2 = unique(data(:,1))+2100;

for p = 1:length(PNo2)
    tmpind = find(data(:,1) == PNo(p) & data(:,9)>0); % non-zero looks
    %     record age sex
    age_sg(p)=data(tmpind(1),2);
    sex_sg(p)=data(tmpind(1),3);
    %   in data, the column No.:  6 cond, 8 word, 9 learning, 10 error, 5 block
    tmpdata = [data(tmpind,6), data(tmpind,8), data(tmpind,9), data(tmpind,10),data(tmpind,5)]; % RAW/Z looking times by participant

    icut1 = mean(tmpdata(:,3)) + SD_number*std(tmpdata(:,3)); % individual threshold as SD (default = 2.5 SD above mean)

    indtest = find( tmpdata(:,3) < icut1);

    for cond = 1:3

        % NEW ALGORITHM: Extract both word=1 and word=2 simultaneously
        % and compute difference within each trial
        ind_word1 = find(tmpdata(:,1) == cond & tmpdata(:,2) == 1 & tmpdata(:,3) < icut1);
        ind_word2 = find(tmpdata(:,1) == cond & tmpdata(:,2) == 2 & tmpdata(:,3) < icut1);

        % Get the looking times for each word type
        word1_looks = tmpdata(ind_word1, 3);
        word2_looks = tmpdata(ind_word2, 3);

        % Calculate difference (word2 - word1)
        % Match trials by taking minimum length
        min_length = min(length(word1_looks), length(word2_looks));

        if min_length > 0 && length(indtest) > 1 && length(unique(tmpdata(indtest,2)))==2
            % Compute trial-by-trial difference
            look_diff = word2_looks(1:min_length) - word1_looks(1:min_length);

            % Store the difference scores
            MeanLook_Diff2{p,cond} = look_diff;

            count_clear = count_clear + min_length;
            count = count + length(ind_word1) + length(ind_word2);
        else
            MeanLook_Diff2{p,cond} = NaN;
        end

    end
end
clear tmpind tmpdata

% clear ratio
fprintf('\n========================================================================\n');
fprintf('DATA QUALITY\n');
fprintf('========================================================================\n');
fprintf('Clear ratio: %.4f (%.0f trials used / %.0f total trials)\n\n', ...
    count_clear/count, count_clear, count);


%% R1 - Add covariates (age, sex, country) for ANCOVA

% Prepare covariates
age_all = [age_camb, age_sg];
sex_all = [sex_camb, sex_sg];
country_all = [ones(1,29), 2*ones(1,18)]; % 1=UK, 2=SG

% Storage for results
results = struct();
results.condition = {'Full Gaze', 'Partial Gaze', 'No Gaze'};
results.n = zeros(3,1);
results.mean_raw = zeros(3,1);
results.sd_raw = zeros(3,1);
results.t_raw = zeros(3,1);
results.p_raw = zeros(3,1);
results.cohens_d = zeros(3,1);
results.mean_adj = zeros(3,1);
results.sd_adj = zeros(3,1);
results.t_adj = zeros(3,1);
results.p_adj = zeros(3,1);
results.normality_h = zeros(3,1);
results.normality_p = zeros(3,1);

%% ========================================================================
%% CONDITION 1 (Full Gaze)
%% ========================================================================

diff_learning = [];
for i = 1:29
    if ~isempty(MeanLook_Diff{i,1}) && ~any(isnan(MeanLook_Diff{i,1}))
        diff_learning(i) = nanmean(MeanLook_Diff{i,1});
    else
        diff_learning(i) = NaN;
    end
end

for i = 1:18
    if ~isempty(MeanLook_Diff2{i,1}) && ~any(isnan(MeanLook_Diff2{i,1}))
        diff_learning(i+29) = nanmean(MeanLook_Diff2{i,1});
    else
        diff_learning(i+29) = NaN;
    end
end

fprintf('========================================================================\n');
fprintf('CONDITION 1: Full Gaze\n');
fprintf('========================================================================\n\n');

% Remove NaN values
valid_idx = ~isnan(diff_learning);
diff_learning_clean = diff_learning(valid_idx);
n_cond1 = length(diff_learning_clean);

fprintf('Sample size: n = %d\n\n', n_cond1);

% Original t-test (no covariates)
[h,p,ci,stats] = ttest(diff_learning_clean, 0, 'Tail', 'both');
mean_raw = nanmean(diff_learning_clean);
sd_raw = nanstd(diff_learning_clean);
se_raw = sd_raw / sqrt(n_cond1);

% Cohen's d for one-sample t-test: d = mean / sd
cohens_d_cond1 = mean_raw / sd_raw;

fprintf('--- RAW ANALYSIS (No Covariates) ---\n');
fprintf('Mean = %.4f, SD = %.4f, SE = %.4f\n', mean_raw, sd_raw, se_raw);
fprintf('t(%d) = %.4f, p = %.4f\n', stats.df, stats.tstat, p);
fprintf('Cohen''s d = %.4f ', cohens_d_cond1);
if abs(cohens_d_cond1) < 0.2
    fprintf('(negligible effect)\n');
elseif abs(cohens_d_cond1) < 0.5
    fprintf('(small effect)\n');
elseif abs(cohens_d_cond1) < 0.8
    fprintf('(medium effect)\n');
else
    fprintf('(large effect)\n');
end
fprintf('95%% CI: [%.4f, %.4f]\n\n', ci(1), ci(2));

% Store raw results
results.n(1) = n_cond1;
results.mean_raw(1) = mean_raw;
results.sd_raw(1) = sd_raw;
results.t_raw(1) = stats.tstat;
results.p_raw(1) = p;
results.cohens_d(1) = cohens_d_cond1;

% Covariate adjustment
Y = diff_learning(valid_idx)';
age_cov = age_all(valid_idx)';
sex_cov = sex_all(valid_idx)';
country_cov = country_all(valid_idx)';

% Create design matrix with intercept and covariates
X = [ones(size(Y)), age_cov, sex_cov, country_cov];
[~, ~, resid] = regress(Y, X);

% Adjusted scores = residuals + grand mean
adjusted_scores = resid + nanmean(Y);

% One-sample t-test on adjusted scores
[h_adj, p_adj, ci_adj, stats_adj] = ttest(adjusted_scores, 0, 'Tail', 'both');
mean_adj = mean(adjusted_scores);
sd_adj = std(adjusted_scores);
se_adj = sd_adj / sqrt(length(adjusted_scores));

fprintf('--- COVARIATE-ADJUSTED ANALYSIS (Age, Sex, Country) ---\n');
fprintf('Adjusted Mean = %.4f, SD = %.4f, SE = %.4f\n', mean_adj, sd_adj, se_adj);
fprintf('t(%d) = %.4f, p = %.4f\n', stats_adj.df, stats_adj.tstat, p_adj);
fprintf('95%% CI: [%.4f, %.4f]\n\n', ci_adj(1), ci_adj(2));

% Store adjusted results
results.mean_adj(1) = mean_adj;
results.sd_adj(1) = sd_adj;
results.t_adj(1) = stats_adj.tstat;
results.p_adj(1) = p_adj;

% Normality test - Lilliefors (Kolmogorov-Smirnov)
fprintf('--- NORMALITY TEST ---\n');
[h_lillie, p_lillie] = lillietest(adjusted_scores);
fprintf('Lilliefors test: h = %d, p = %.4f ', h_lillie, p_lillie);
if h_lillie == 0
    fprintf('✓ Normal distribution\n');
else
    fprintf('✗ Non-normal distribution\n');
end
results.normality_p(1) = p_lillie;
results.normality_h(1) = h_lillie;

fprintf('\n');


%% ========================================================================
%% CONDITION 2 (Partial Gaze)
%% ========================================================================

diff_learning = [];
for i = 1:29
    if ~isempty(MeanLook_Diff{i,2}) && ~any(isnan(MeanLook_Diff{i,2}))
        diff_learning(i) = nanmean(MeanLook_Diff{i,2});
    else
        diff_learning(i) = NaN;
    end
end

for i = 1:18
    if ~isempty(MeanLook_Diff2{i,2}) && ~any(isnan(MeanLook_Diff2{i,2}))
        diff_learning(i+29) = nanmean(MeanLook_Diff2{i,2});
    else
        diff_learning(i+29) = NaN;
    end
end

fprintf('========================================================================\n');
fprintf('CONDITION 2: Partial Gaze\n');
fprintf('========================================================================\n\n');

% Remove NaN values
valid_idx = ~isnan(diff_learning);
diff_learning_clean = diff_learning(valid_idx);
n_cond2 = length(diff_learning_clean);

fprintf('Sample size: n = %d\n\n', n_cond2);

% Original t-test (no covariates)
[h,p,ci,stats] = ttest(diff_learning_clean, 0, 'Tail', 'both');
mean_raw = nanmean(diff_learning_clean);
sd_raw = nanstd(diff_learning_clean);
se_raw = sd_raw / sqrt(n_cond2);

% Cohen's d
cohens_d_cond2 = mean_raw / sd_raw;

fprintf('--- RAW ANALYSIS (No Covariates) ---\n');
fprintf('Mean = %.4f, SD = %.4f, SE = %.4f\n', mean_raw, sd_raw, se_raw);
fprintf('t(%d) = %.4f, p = %.4f\n', stats.df, stats.tstat, p);
fprintf('Cohen''s d = %.4f ', cohens_d_cond2);
if abs(cohens_d_cond2) < 0.2
    fprintf('(negligible effect)\n');
elseif abs(cohens_d_cond2) < 0.5
    fprintf('(small effect)\n');
elseif abs(cohens_d_cond2) < 0.8
    fprintf('(medium effect)\n');
else
    fprintf('(large effect)\n');
end
fprintf('95%% CI: [%.4f, %.4f]\n\n', ci(1), ci(2));

% Store raw results
results.n(2) = n_cond2;
results.mean_raw(2) = mean_raw;
results.sd_raw(2) = sd_raw;
results.t_raw(2) = stats.tstat;
results.p_raw(2) = p;
results.cohens_d(2) = cohens_d_cond2;

% Covariate adjustment
Y = diff_learning(valid_idx)';
age_cov = age_all(valid_idx)';
sex_cov = sex_all(valid_idx)';
country_cov = country_all(valid_idx)';

X = [ones(size(Y)), age_cov, sex_cov, country_cov];
[~, ~, resid] = regress(Y, X);
adjusted_scores = resid + nanmean(Y);

[h_adj, p_adj, ci_adj, stats_adj] = ttest(adjusted_scores, 0, 'Tail', 'both');
mean_adj = mean(adjusted_scores);
sd_adj = std(adjusted_scores);
se_adj = sd_adj / sqrt(length(adjusted_scores));

fprintf('--- COVARIATE-ADJUSTED ANALYSIS (Age, Sex, Country) ---\n');
fprintf('Adjusted Mean = %.4f, SD = %.4f, SE = %.4f\n', mean_adj, sd_adj, se_adj);
fprintf('t(%d) = %.4f, p = %.4f\n', stats_adj.df, stats_adj.tstat, p_adj);
fprintf('95%% CI: [%.4f, %.4f]\n\n', ci_adj(1), ci_adj(2));

results.mean_adj(2) = mean_adj;
results.sd_adj(2) = sd_adj;
results.t_adj(2) = stats_adj.tstat;
results.p_adj(2) = p_adj;

% Normality test - Lilliefors (Kolmogorov-Smirnov)
fprintf('--- NORMALITY TEST ---\n');
[h_lillie, p_lillie] = lillietest(adjusted_scores);
fprintf('Lilliefors test: h = %d, p = %.4f ', h_lillie, p_lillie);
if h_lillie == 0
    fprintf('✓ Normal distribution\n');
else
    fprintf('✗ Non-normal distribution\n');
end
results.normality_p(2) = p_lillie;
results.normality_h(2) = h_lillie;

fprintf('\n');


%% ========================================================================
%% CONDITION 3 (No Gaze)
%% ========================================================================

diff_learning = [];
for i = 1:29
    if ~isempty(MeanLook_Diff{i,3}) && ~any(isnan(MeanLook_Diff{i,3}))
        diff_learning(i) = nanmean(MeanLook_Diff{i,3});
    else
        diff_learning(i) = NaN;
    end
end

for i = 1:18
    if ~isempty(MeanLook_Diff2{i,3}) && ~any(isnan(MeanLook_Diff2{i,3}))
        diff_learning(i+29) = nanmean(MeanLook_Diff2{i,3});
    else
        diff_learning(i+29) = NaN;
    end
end

fprintf('========================================================================\n');
fprintf('CONDITION 3: No Gaze\n');
fprintf('========================================================================\n\n');

% Remove NaN values
valid_idx = ~isnan(diff_learning);
diff_learning_clean = diff_learning(valid_idx);
n_cond3 = length(diff_learning_clean);

fprintf('Sample size: n = %d\n\n', n_cond3);

% Original t-test (no covariates)
[h,p,ci,stats] = ttest(diff_learning_clean, 0, 'Tail', 'both');
mean_raw = nanmean(diff_learning_clean);
sd_raw = nanstd(diff_learning_clean);
se_raw = sd_raw / sqrt(n_cond3);

% Cohen's d
cohens_d_cond3 = mean_raw / sd_raw;

fprintf('--- RAW ANALYSIS (No Covariates) ---\n');
fprintf('Mean = %.4f, SD = %.4f, SE = %.4f\n', mean_raw, sd_raw, se_raw);
fprintf('t(%d) = %.4f, p = %.4f\n', stats.df, stats.tstat, p);
fprintf('Cohen''s d = %.4f ', cohens_d_cond3);
if abs(cohens_d_cond3) < 0.2
    fprintf('(negligible effect)\n');
elseif abs(cohens_d_cond3) < 0.5
    fprintf('(small effect)\n');
elseif abs(cohens_d_cond3) < 0.8
    fprintf('(medium effect)\n');
else
    fprintf('(large effect)\n');
end
fprintf('95%% CI: [%.4f, %.4f]\n\n', ci(1), ci(2));

% Store raw results
results.n(3) = n_cond3;
results.mean_raw(3) = mean_raw;
results.sd_raw(3) = sd_raw;
results.t_raw(3) = stats.tstat;
results.p_raw(3) = p;
results.cohens_d(3) = cohens_d_cond3;

% Covariate adjustment
Y = diff_learning(valid_idx)';
age_cov = age_all(valid_idx)';
sex_cov = sex_all(valid_idx)';
country_cov = country_all(valid_idx)';

X = [ones(size(Y)), age_cov, sex_cov, country_cov];
[~, ~, resid] = regress(Y, X);
adjusted_scores = resid + nanmean(Y);

[h_adj, p_adj, ci_adj, stats_adj] = ttest(adjusted_scores, 0, 'Tail', 'both');
mean_adj = mean(adjusted_scores);
sd_adj = std(adjusted_scores);
se_adj = sd_adj / sqrt(length(adjusted_scores));

fprintf('--- COVARIATE-ADJUSTED ANALYSIS (Age, Sex, Country) ---\n');
fprintf('Adjusted Mean = %.4f, SD = %.4f, SE = %.4f\n', mean_adj, sd_adj, se_adj);
fprintf('t(%d) = %.4f, p = %.4f\n', stats_adj.df, stats_adj.tstat, p_adj);
fprintf('95%% CI: [%.4f, %.4f]\n\n', ci_adj(1), ci_adj(2));

results.mean_adj(3) = mean_adj;
results.sd_adj(3) = sd_adj;
results.t_adj(3) = stats_adj.tstat;
results.p_adj(3) = p_adj;

% Normality test - Lilliefors (Kolmogorov-Smirnov)
fprintf('--- NORMALITY TEST ---\n');
[h_lillie, p_lillie] = lillietest(adjusted_scores);
fprintf('Lilliefors test: h = %d, p = %.4f ', h_lillie, p_lillie);
if h_lillie == 0
    fprintf('✓ Normal distribution\n');
else
    fprintf('✗ Non-normal distribution\n');
end
results.normality_p(3) = p_lillie;
results.normality_h(3) = h_lillie;

fprintf('\n');


%% ========================================================================
%% MULTIPLE COMPARISON CORRECTION
%% ========================================================================

fprintf('========================================================================\n');
fprintf('MULTIPLE COMPARISON CORRECTION\n');
fprintf('========================================================================\n\n');

% Bonferroni correction
p_bonf_raw = results.p_raw * 3;
p_bonf_raw(p_bonf_raw > 1) = 1;

p_bonf_adj = results.p_adj * 3;
p_bonf_adj(p_bonf_adj > 1) = 1;

% FDR correction
q_fdr_raw = mafdr(results.p_raw', 'BHFDR', true);
q_fdr_adj = mafdr(results.p_adj', 'BHFDR', true);

fprintf('--- BONFERRONI CORRECTION (alpha = 0.05/3 = 0.0167) ---\n\n');
fprintf('%-20s %10s %12s %12s\n', 'Condition', 'p_raw', 'p_Bonf', 'Significant?');
fprintf('------------------------------------------------------------\n');
for i = 1:3
    sig_marker = '';
    if p_bonf_adj(i) < 0.0167
        sig_marker = ' *';
    end
    fprintf('%-20s %10.4f %12.4f%s\n', results.condition{i}, results.p_adj(i), p_bonf_adj(i), sig_marker);
end
fprintf('* p_Bonf < 0.0167 (significant after correction)\n\n');

fprintf('--- FDR CORRECTION (Benjamini-Hochberg) ---\n\n');
fprintf('%-20s %10s %12s %12s\n', 'Condition', 'p_raw', 'q_FDR', 'Significant?');
fprintf('------------------------------------------------------------\n');
for i = 1:3
    sig_marker = '';
    if q_fdr_adj(i) < 0.05
        sig_marker = ' *';
    end
    fprintf('%-20s %10.4f %12.4f%s\n', results.condition{i}, results.p_adj(i), q_fdr_adj(i), sig_marker);
end
fprintf('* q_FDR < 0.05 (significant after FDR correction)\n\n');


% %% ========================================================================
% %% Q-Q PLOTS FOR NORMALITY ASSESSMENT
% %% ========================================================================
% 
% fprintf('========================================================================\n');
% fprintf('GENERATING Q-Q PLOTS FOR NORMALITY ASSESSMENT\n');
% fprintf('========================================================================\n\n');
% 
% figure('Position', [100, 100, 1200, 400]);
% 
% % Recompute adjusted scores for each condition for plotting
% for cond = 1:3
%     diff_learning = [];
%     for i = 1:29
%         if ~isempty(MeanLook_Diff{i,cond}) && ~any(isnan(MeanLook_Diff{i,cond}))
%             diff_learning(i) = nanmean(MeanLook_Diff{i,cond});
%         else
%             diff_learning(i) = NaN;
%         end
%     end
% 
%     for i = 1:18
%         if ~isempty(MeanLook_Diff2{i,cond}) && ~any(isnan(MeanLook_Diff2{i,cond}))
%             diff_learning(i+29) = nanmean(MeanLook_Diff2{i,cond});
%         else
%             diff_learning(i+29) = NaN;
%         end
%     end
% 
%     valid_idx = ~isnan(diff_learning);
%     Y = diff_learning(valid_idx)';
%     age_cov = age_all(valid_idx)';
%     sex_cov = sex_all(valid_idx)';
%     country_cov = country_all(valid_idx)';
% 
%     X = [ones(size(Y)), age_cov, sex_cov, country_cov];
%     [~, ~, resid] = regress(Y, X);
%     adjusted_scores = resid + nanmean(Y);
% 
%     subplot(1, 3, cond);
%     qqplot(adjusted_scores);
%     title(sprintf('%s\np = %.4f (Shapiro-Wilk)', results.condition{cond}, results.shapiro_p(cond)));
%     xlabel('Theoretical Quantiles');
%     ylabel('Sample Quantiles');
%     grid on;
% end
% 
% sgtitle('Q-Q Plots: Normality Assessment (Covariate-Adjusted Scores)', 'FontSize', 14, 'FontWeight', 'bold');
% 
% % Save figure
% saveas(gcf, 'normality_qq_plots.png');
% fprintf('Q-Q plots saved as: normality_qq_plots.png\n\n');


%% ========================================================================
%% SUMMARY TABLE
%% ========================================================================

fprintf('========================================================================\n');
fprintf('SUMMARY TABLE - ALL CONDITIONS\n');
fprintf('========================================================================\n\n');

% Create comprehensive results table
summary_table = table(...
    results.condition', ...
    results.n, ...
    results.mean_adj, ...
    results.sd_adj, ...
    results.cohens_d, ...
    results.t_adj, ...
    results.p_adj, ...
    p_bonf_adj, ...
    q_fdr_adj(:), ...
    results.normality_p, ...
    'VariableNames', {'Condition', 'N', 'Mean', 'SD', 'Cohens_d', 't_value', 'p_value', 'p_Bonferroni', 'q_FDR', 'Lilliefors_p'});

disp(summary_table);

% Save to CSV
writetable(summary_table, 'behavioral_results_summary.csv');
fprintf('\nSummary table saved as: behavioral_results_summary.csv\n');

fprintf('\n========================================================================\n');
fprintf('ANALYSIS COMPLETE\n');
fprintf('========================================================================\n\n');
