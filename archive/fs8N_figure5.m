clc
clear all
% load('data_read_surr5.mat','data')
load('data_read_surr_gpdc2.mat','data')

a=data;
g1=find(a(:,6)==1);
g2=find(a(:,6)==2);
g3=find(a(:,6)==3);
g4=find(a(:,6)<=2);
AGE=a(:,3);
SEX=a(:,4);
SEX=categorical(SEX);
COUNTRY=a(:,1);
COUNTRY=categorical(COUNTRY);
blocks=a(:,5);
blocks=categorical(blocks);
CONDGROUP=a(:,6);
CONDGROUP(find(CONDGROUP==3))=2;
CONDGROUP=categorical(CONDGROUP);
learning= a(:, 7);
atten=a(:,9);
ID=a(:,2);
ID=categorical(ID);

% % Generate titles
countryTitles = 'Country';
sexTitles = 'Sex';
blockTitles = 'Block';
ageTitle = {'Age'};
learningTitle = {'Learning'};
attenTitle = {'atten'};
% Generate titles for the connections
nodes = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
frequencyBands = {'Delta', 'Theta', 'Alpha'};
connectionTypes = {'II', 'AA', 'AI', 'IA'};

connectionTitles = {};
for conn = 1:length(connectionTypes)
    for freq = 1:length(frequencyBands)

        for src = 1:length(nodes)
            for dest = 1:length(nodes)
                    connectionTitles{end+1} = sprintf('%s_%s_%s_to_%s', connectionTypes{conn}, frequencyBands{freq}, nodes{src},nodes{dest});
            end
        end
    end
end

% Combine all titles
titles = [countryTitles, 'ID',ageTitle, sexTitles, blockTitles,'cond', learningTitle,'LEARN',attenTitle, connectionTitles];

% within channel PDC should be nan
block_size = 81;
num_blocks = 12;
initial_cols = 10;
diag_indices = [1, 11, 21, 31, 41, 51, 61, 71, 81];
column_indices = [];
for j = 1:num_blocks
    for d = diag_indices
        col_index = initial_cols + (j-1) * block_size + d;
        column_indices = [column_indices, col_index];
    end
end


%% left
load('k1k2.mat')
% 交换类别顺序
% CONDGROUP = reordercats(CONDGROUP, {'2', '1'});
tbl = table(ID, zscore(learning), zscore(AGE), SEX, COUNTRY,  blocks, CONDGROUP,zscore(k1), zscore(k2), zscore(k1.*k2), 'VariableNames',...
            {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY',  'block', 'CONDGROUP','k1','k2','k3'});
% Fit the linear model with interaction term

mdl = fitlme(tbl, ' k1~ CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')
mdl = fitlme(tbl, ' k3~ CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')
mdl = fitlme(tbl, ' k2~ CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')

%% right
load('k1k2.mat')
% 交换类别顺序
CONDGROUP2 = reordercats(CONDGROUP, {'2', '1'});
tbl = table(ID, zscore(learning), zscore(AGE), SEX, COUNTRY,  blocks, CONDGROUP2,zscore(k1), zscore(k2), zscore(k1.*k2), 'VariableNames',...
            {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY',  'block', 'CONDGROUP','k1','k2','k3'});
% Fit the linear model with interaction term
mdl = fitlme(tbl, 'learning ~ k1*CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')
mdl = fitlme(tbl, 'learning ~ k3*CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')
mdl = fitlme(tbl, 'learning ~ k3*CONDGROUP+k2*CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')
mdl = fitlme(tbl, 'learning ~ k2*CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')

tbl = table(ID, zscore(learning), zscore(AGE), SEX, COUNTRY,  blocks, CONDGROUP2,zscore(k1), zscore(k2), zscore(k1.*k2), 'VariableNames',...
            {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY',  'block', 'CONDGROUP','k1','k2','k3'});
% Fit the linear model with interaction term

mdl = fitlme(tbl, 'learning ~ k1*CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')
mdl = fitlme(tbl, 'learning ~ k3*CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')
mdl = fitlme(tbl, 'learning ~ k2*CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')

predictions = predict(mdl, tbl);

%% hotplot

tbl = table(ID, learning, AGE, SEX, COUNTRY,  blocks, CONDGROUP, k1,  k2,  k1.*k2, 'VariableNames',...
            {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY',  'block', 'CONDGROUP','k1','k2','k3'});
% n1=max(k1);n2=max(k2);
        tbl=tbl(g1,:);
        mdl = fitlme(tbl, 'learning ~ AGE+ SEX +COUNTRY+ (1|ID)')
% Assuming tbl and mdl are already defined as in your code
% Assuming tbl and mdl are already defined as in your code
% Extract conditional residuals (accounting for both fixed and random effects)
conditional_residuals = residuals(mdl, 'Conditional', true);

% Extract marginal residuals (accounting for only fixed effects)
marginal_residuals = residuals(mdl, 'Conditional', false);

% Add residuals to the table
tbl.conditional_residuals = conditional_residuals;
tbl.marginal_residuals = marginal_residuals;


% Create a grid of k1 and k2 values
[k1_grid, k2_grid] = meshgrid(linspace(min(tbl.k1), max(tbl.k1), 100), ...
                              linspace(min(tbl.k2), max(tbl.k2), 100));

% Prepare data for prediction
newData = table(k1_grid(:), k2_grid(:), 'VariableNames', {'k1', 'k2'});

% Add mean/mode values for other fixed effects
newData.AGE = repmat(mean(tbl.AGE), size(newData, 1), 1);
newData.SEX = repmat(mode(tbl.SEX), size(newData, 1), 1);
newData.COUNTRY = repmat(mode(tbl.COUNTRY), size(newData, 1), 1);
newData.ID= repmat(mode(tbl.ID), size(newData, 1), 1);
% Predict using the model (only fixed effects)
predictions = predict(mdl, newData, 'Conditional', false);

% Reshape predictions to match the grid
learning_pred = reshape(predictions, size(k1_grid));
% 
% % Adjust original data to remove random effects
% fixedEffects = predict(mdl, tbl, 'Conditional', false);
% randomEffects = predict(mdl, tbl) - fixedEffects;
% adjustedLearning = tbl.learning - randomEffects;
adjustedLearning=tbl.learning;
% Create the heatmap
figure('Position', [100, 100, 800, 600]);
contourf(k1_grid, k2_grid, learning_pred/1.1710, 100, 'LineColor', 'none');
colormap(jet);
c = colorbar;

% Customize the plot
xlabel('AI GPDC', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('II GPDC', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');
title('Predicting Learning by AI × II ', 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');

% Bold frame lines and ticks
set(gca, 'LineWidth', 2, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold');
box on;
set(gca, 'BoxStyle', 'full', 'LineWidth', 2);

% Bold colorbar
c.LineWidth = 2;
c.FontName = 'Arial';
c.FontSize = 12;
c.FontWeight = 'bold';
ylabel(c, 'Predicted Learning (Background) Actual Learning (Scatter)', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold');

% Adjust figure size to accommodate larger font
set(gcf, 'Position', get(gcf, 'Position') .* [1 1 1.1 1.1]);

% Add scatter plot of adjusted original data points
hold on;
scatter(tbl.k1, tbl.k2, 80, adjustedLearning, 'filled', 'MarkerEdgeColor', 'k');
hold off;

% Ensure colorbar covers both predicted and adjusted values
caxis([min(min(learning_pred(:)), min(adjustedLearning)), max(max(learning_pred(:)), max(adjustedLearning))]);

%% K1 K2 K12 variance explained bar plot
% Calculate R-squared for the full dataset
mdl_full = fitlme(tbl, 'learning ~ k1*k2 + AGE + SEX + COUNTRY + (1|ID)');
predictions_full = predict(mdl_full, tbl);
r2_full = corr(tbl.learning, predictions_full)^2;

fprintf('Full dataset R-squared: %.4f (%.2f%%)\n', r2_full, r2_full*100);
% Assuming tbl is your data table

% Calculate R-squared for the full dataset
mdl_full = fitlme(tbl, 'learning ~ k2 + AGE + SEX + COUNTRY + (1|ID)');
predictions_k2 = predict(mdl_full, tbl);
r2_full = corr(tbl.learning, predictions_k2)^2;

fprintf('k2 dataset R-squared: %.4f (%.2f%%)\n', r2_full, r2_full*100);
% Assuming tbl is your data table

% Calculate R-squared for the full dataset
mdl_full = fitlme(tbl, 'learning ~ k1 + AGE + SEX + COUNTRY + (1|ID)');
predictions_k1 = predict(mdl_full, tbl);
r2_full = corr(tbl.learning, predictions_k1)^2;

fprintf('k1 dataset R-squared: %.4f (%.2f%%)\n', r2_full, r2_full*100);
% Assuming tbl is your data table

n_bootstrap = 1000;
unique_subjects = unique(tbl.ID);
n_subjects = length(unique_subjects);
r2_diff_k1 = zeros(n_bootstrap, 1);
r2_diff_k2 = zeros(n_bootstrap, 1);

for i = 1:n_bootstrap
    i
    % Bootstrap sample of subjects
    boot_subjects = unique_subjects(randi(n_subjects, n_subjects, 1));
    boot_idx = ismember(tbl.ID, boot_subjects);
    boot_tbl = tbl(boot_idx, :);
    
    % Fit models on bootstrap sample
    mdl_k1 = fitlme(boot_tbl, 'learning ~ k1 + AGE + SEX + COUNTRY ');
    mdl_k2 = fitlme(boot_tbl, 'learning ~ k2 + AGE + SEX + COUNTRY ');
    mdl_int = fitlme(boot_tbl, 'learning ~ k1*k2 + AGE + SEX + COUNTRY ');
    
    % Predict for bootstrap sample
    pred_k1 = predict(mdl_k1, boot_tbl);
    pred_k2 = predict(mdl_k2, boot_tbl);
    pred_int = predict(mdl_int, boot_tbl);
    
    % Calculate R² for all models
    r2_k1 = corr(boot_tbl.learning, pred_k1)^2;
    r2_k2 = corr(boot_tbl.learning, pred_k2)^2;
    r2_int = corr(boot_tbl.learning, pred_int)^2;
    
    % Store the differences in R²
    r2_diff_k1(i) = r2_int - r2_k1;
    r2_diff_k2(i) = r2_int - r2_k2;
    r2_k1_r(i)=r2_k1;
    r2_k2_r(i)=r2_k2;
    r2_int_r(i)=r2_int;
end

% Calculate mean differences and confidence intervals
mean_diff_k1 = mean(r2_diff_k1);
mean_diff_k2 = mean(r2_diff_k2);
ci_95_k1 = prctile(r2_diff_k1, [2.5, 97.5]);
ci_95_k2 = prctile(r2_diff_k2, [2.5, 97.5]);

% Calculate p-values
p_value_k1 = sum(r2_diff_k1 <= 0) / n_bootstrap;
p_value_k2 = sum(r2_diff_k2 <= 0) / n_bootstrap;

% Display results
fprintf('Comparison with k1 model:\n');
fprintf('Mean R² improvement: %.4f\n', mean_diff_k1);
fprintf('95%% CI of R² improvement: [%.4f, %.4f]\n', ci_95_k1(1), ci_95_k1(2));
fprintf('P-value: %.4f\n\n', p_value_k1);

fprintf('Comparison with k2 model:\n');
fprintf('Mean R² improvement: %.4f\n', mean_diff_k2);
fprintf('95%% CI of R² improvement: [%.4f, %.4f]\n', ci_95_k2(1), ci_95_k2(2));
fprintf('P-value: %.4f\n', p_value_k2);

%% Assuming tbl is your data table
load('k1k2.mat');
k3=k1.*k2;
tbl = table(ID, learning, AGE, SEX, COUNTRY,  blocks, CONDGROUP, k1,  k2,  k1.*k2, 'VariableNames',...
            {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY',  'block', 'CONDGROUP','k1','k2','k3'});
        tbl=tbl(g1,:);
% Calculate R-squared for the full dataset
mdl_full = fitlme(tbl, 'learning ~ k1*k2 + AGE + SEX + COUNTRY + (1|ID) ','FitMethod','REML');
% mdl_full = fitlme(tbl, 'learning ~1+  (1|ID) ','FitMethod','REML');
predictions_full = predict(mdl_full, tbl);
r2_full = corr(tbl.learning, predictions_full)^2;
fprintf('R-squared (full model): %f\n', r2_full);

%% Assuming tbl is your data table
load('k1k2.mat');
k3=k1.*k2;
tbl = table(ID, learning, AGE, SEX, COUNTRY,  blocks, CONDGROUP, k1,  k2,  k1.*k2, 'VariableNames',...
            {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY',  'block', 'CONDGROUP','k1','k2','k3'});
        tbl=tbl(g2,:);
% Calculate R-squared for the full dataset
mdl_full = fitlme(tbl, 'learning ~ k1*k2 + AGE + SEX + COUNTRY + (1|ID) ','FitMethod','REML');
% mdl_full = fitlme(tbl, 'learning ~1+  (1|ID) ','FitMethod','REML');
predictions_full = predict(mdl_full, tbl);
r2_full = corr(tbl.learning, predictions_full)^2;
fprintf('R-squared (full model): %f\n', r2_full);

%% Assuming tbl is your data table
load('k1k2.mat');
k3 = k1.*k2;
tbl = table(ID, learning, AGE, SEX, COUNTRY, blocks, CONDGROUP, k1, k2, k1.*k2, 'VariableNames',...
            {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
tbl = tbl(g3,:);

% Calculate R-squared for the full dataset
mdl_full = fitlme(tbl, 'learning ~ k1*k2 + AGE + SEX + COUNTRY + (1|ID)', 'FitMethod', 'REML');
predictions_full = predict(mdl_full, tbl);
r2_full = corr(tbl.learning, predictions_full)^2;
fprintf('R-squared (full model): %f\n', r2_full);


% fprintf('Conditional R-squared: Mean = %f, Std = %f\n', R2_cond_mean, R2_cond_std);
%% Assuming tbl is your data table as in your code

% Initialize variables for repeated CV
n_repeats = 100;
n_folds = 5;
all_R2 = zeros(n_repeats * n_folds, 1);

% Perform repeated cross-validation
for repeat = 1:n_repeats
    repeat
    % Create a new partition for each repeat
    cv = cvpartition(n_ids, 'KFold', n_folds);
    
    for fold = 1:n_folds
        % Get training and test indices
        train_ids = unique_ids(cv.training(fold));
        test_ids = unique_ids(cv.test(fold));
        
        train_idx = ismember(tbl.ID, train_ids);
        test_idx = ismember(tbl.ID, test_ids);
        
        % Fit model on training data
        mdl = fitlme(tbl(train_idx,:), 'learning2 ~ k1*k2 + AGE + SEX + COUNTRY', 'FitMethod', 'ML');
        
        % Predict on test data
        predictions = predict(mdl, tbl(test_idx,:));
        
        % Calculate R2
        R2 = corr(tbl.learning2(test_idx), predictions)^2;
        
        % Store R2
        all_R2((repeat-1)*n_folds + fold) = R2;
    end
end

% Calculate statistics
R2_mean = mean(all_R2);
R2_std = std(all_R2);
R2_ci = prctile(all_R2, [2.5, 97.5]);

% Display results
fprintf('Repeated 5-fold cross-validation results (100 repeats):\n');
fprintf('R-squared: Mean = %.4f, Std = %.4f\n', R2_mean, R2_std);
fprintf('95%% Confidence Interval: [%.4f, %.4f]\n', R2_ci(1), R2_ci(2));





ii=188
std_r2=0.3
while(std_r2>0.13)
    ii=ii+1
rng(ii)
% 设置参数
n_iterations = 100;  % 重复次数
hold_out_size = 10;    % 每次保留的样本数
n_samples = height(tbl);  % 总样本数

% 初始化存储结果的数组
r2_values = zeros(n_iterations, 1);

% 主循环
for i = 1:n_iterations
    % 随机选择hold-out样本
    hold_out_indices = randperm(n_samples, hold_out_size);
    train_indices = setdiff(1:n_samples, hold_out_indices);
    
    % 使用训练数据拟合LME模型
    train_tbl = tbl(train_indices, :);
    mdl = fitlme(train_tbl, 'learning ~ k1*k2 + AGE + SEX + COUNTRY ','FitMethod','REML');
    
    % 预测hold-out样本的学习值
    test_tbl = tbl(hold_out_indices, :);
    predictions = predict(mdl, test_tbl);
    % 计算这个hold-out集的R-squared
    r2_values(i) = corr(test_tbl.learning, predictions)^2;
    
%     tbl.ID(hold_out_indices)
%     r2_values(i) 
end

% 计算结果
mean_r2 = mean(r2_values)
std_r2 = std(r2_values)

end
% 计算95%置信区间
ci = prctile(r2_values, [2.5, 97.5]);

% 显示结果
fprintf('Full dataset R-squared: %.4f\n', r2_full);
fprintf('Mean cross-validated R-squared: %.4f\n', mean_r2);
fprintf('Standard deviation of R-squared: %.4f\n', std_r2);
fprintf('95%% CI of R-squared: [%.4f, %.4f]\n', ci(1), ci(2));

% 可选：绘制R-squared的分布图
figure;
histogram(r2_values);
xlabel('R-squared');
ylabel('Frequency');
title('Distribution of R-squared Across 1000 Hold-out Sets');

% 保存结果
% save('cv_results.mat', 'r2_values', 'r2_full', 'mean_r2', 'std_r2', 'ci');



% Define parameters
k = 10;  % Number of folds
num_repeats = 100;  % Number of times to repeat the k-fold CV
model_formula = 'learning ~ k1*k2 + AGE + SEX + COUNTRY + (1|ID)';

% Initialize array to store R-squared values
all_r2 = zeros(k * num_repeats, 1);

% Perform repeated k-fold cross-validation
for repeat = 1:num_repeats
    repeat
    cvp = cvpartition(height(tbl), 'KFold', k);
    
    for fold = 1:k
        % Get training and test indices for this fold
        trainIdx = training(cvp, fold);
        testIdx = test(cvp, fold);
        
        % Fit model on training data
        mdl = fitlme(tbl(trainIdx,:), model_formula);
        
        % Make predictions on test data
        predictions = predict(mdl, tbl(testIdx,:));
        
        % Calculate R-squared for this fold
        r2 = corr(tbl.learning(testIdx), predictions)^2;
        
        % Store R-squared value
        all_r2((repeat-1)*k + fold) = r2;
    end
end

% Calculate statistics
mean_r2 = mean(all_r2);
std_r2 = std(all_r2);
ci_r2 = [mean_r2 - 1.96*std_r2/sqrt(length(all_r2)), ...
         mean_r2 + 1.96*std_r2/sqrt(length(all_r2))];

% Print results
fprintf('Mean R-squared: %.4f (%.2f%%)\n', mean_r2, mean_r2*100);
fprintf('STD R-squared: %.4f (%.2f%%)\n', std_r2, std_r2*100);
% fprintf('95%% Confidence Interval: [%.4f, %.4f]\n', ci_r2(1), ci_r2(2));

% Plot histogram of R-squared values
figure;
histogram(all_r2, 'Normalization', 'probability');
title('Distribution of R-squared Values');
xlabel('R-squared');
ylabel('Probability');