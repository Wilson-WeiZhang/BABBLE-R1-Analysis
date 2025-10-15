%% AGE SEX COUNTRY INTO TABLE
%read demo table
clear all
path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'
[a,b]=xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/table/behaviour2.5sd.xlsx']); 

% features
Country = a(:, 1);    % country
ID = a(:, 2);        % ID
AGE = a(:, 3);                    % age
SEX = a(:, 4);       % sex
learning = a(:, 7);               %learning
Attention = a(:, 9);              % atten
learning2 = a(:, 8);   
blocks=a(:,5);
c1=find(a(:,6)==1);
c2=find(a(:,6)==2);
c3=find(a(:,6)==3);
uk=find(a(:,1)==1);
sg=find(a(:,1)==2);
cond=a(:,6);% Initialize arrays
id_col = [];
block_col = [];
learning_cond1 = [];
learning_cond2 = [];
learning_cond3 = [];
% Initialize arrays
id_col = [];
block_col = [];
learning_cond1 = [];
learning_cond2 = [];
learning_cond3 = [];

% For each unique ID
unique_ids = unique(ID);
for i = 1:length(unique_ids)
    current_id = unique_ids(i);
    id_indices = find(ID == current_id);
    
    % For each block
    for block = 1:3
        block_indices = id_indices(blocks(id_indices) == block);
        
        % Get learning values for each condition
        learning_values = nan(1,3);
        has_all_values = true;
        
        for condition = 1:3
            cond_idx = block_indices(cond(block_indices) == condition);
            if ~isempty(cond_idx) && ~isnan(learning(cond_idx))
                learning_values(condition) = learning(cond_idx);
            else
                has_all_values = false;
                break;
            end
        end
        
        % Add row only if we have all three values
        if has_all_values
            id_col = [id_col; current_id];
            block_col = [block_col; block];
            learning_cond1 = [learning_cond1; learning_values(1)];
            learning_cond2 = [learning_cond2; learning_values(2)];
            learning_cond3 = [learning_cond3; learning_values(3)];
        end
    end
end

% Create the matrix
results_matrix = [id_col block_col learning_cond1 learning_cond2 learning_cond3];

% Display first few rows
disp('First rows of clean results matrix:');
disp('Columns: ID, Block, Learning_Cond1, Learning_Cond2, Learning_Cond3');
disp(results_matrix(1:5,:));

% Display matrix size
[rows, cols] = size(results_matrix);
fprintf('Matrix size: %d rows x %d columns\n', rows, cols);
% 
% fit surface plot 3d of results_matrix column no.3,4,5 as three dimentions.
% 
% then the color of the surface is by the mean learning of this id, average all column no.3.4.5 for this id as a mean value

% Get learning values
x = results_matrix(:,3); % condition 1
y = results_matrix(:,4); % condition 2
z = results_matrix(:,5); % condition 3
ids = results_matrix(:,1); % IDs

% Calculate mean learning per ID
unique_ids = unique(ids);
id_means = zeros(size(ids));
for i = 1:length(unique_ids)
    id_idx = ids == unique_ids(i);
    curr_mean = mean([x(id_idx), y(id_idx), z(id_idx)], 'all');
    id_means(id_idx) = curr_mean;
end


result = zeros(96, 3);
for i = 1:96
    if x(i) > y(i) && x(i) > z(i) && x(i) > 0
        result(i, 1) = 1;
    elseif y(i) > x(i) && y(i) > z(i) && y(i) > 0
        result(i, 2) = 1;
    elseif z(i) > x(i) && z(i) > y(i) && z(i) > 0
        result(i, 3) = 1;
    end
end

% Initialize variables for subject-level analysis
unique_ids = unique(ids);
n_subjects = length(unique_ids);
age_subj = zeros(n_subjects, 1);
sex_subj = zeros(n_subjects, 1);
country_subj = zeros(n_subjects, 1);
mean_learning_subj = zeros(n_subjects, 1);
group_cond1 = zeros(n_subjects, 1);  % For condition 1
group_cond2 = zeros(n_subjects, 1);  % For condition 2
group_cond3 = zeros(n_subjects, 1);  % For condition 3

% For each subject
for i = 1:n_subjects
    curr_id = unique_ids(i);
    id_indices = find(ID == curr_id);
    
    % Demographics
    age_subj(i) = AGE(id_indices(1));
    sex_subj(i) = SEX(id_indices(1));
    country_subj(i) = Country(id_indices(1));
    
    % Learning performance
    subj_trials = find(ids == curr_id);
    mean_learning_subj(i) = mean(id_means(subj_trials));
    
    % Get result matrix for this subject's trials
    subj_result = result(subj_trials, :);
    
    % Convert to binary (0/1) based on if there's any dominance
    group_cond1(i) = any(subj_result(:,1));  % 1 if any trial shows condition 1 dominance
    group_cond2(i) = any(subj_result(:,2));  % 1 if any trial shows condition 2 dominance
    group_cond3(i) = any(subj_result(:,3));  % 1 if any trial shows condition 3 dominance
end

% Create analysis table with proper categorical variables
T = table(mean_learning_subj, age_subj, ...
          categorical(sex_subj), ...    % Convert sex to categorical
          categorical(country_subj), ... % Convert country to categorical
          categorical(group_cond1), ...  % Convert group_cond1 to categorical
          categorical(group_cond2), ...  % Convert group_cond2 to categorical
          categorical(group_cond3), ...  % Convert group_cond3 to categorical
          unique_ids, ...
    'VariableNames', {'mean_learning', 'age', 'sex', 'country', ...
                      'group_cond1', 'group_cond2', 'group_cond3', ...
                      'id'});

% Fit LME model with categorical predictors
lme = fitlme(T, 'mean_learning ~ age + sex + country + group_cond1 + group_cond2 + group_cond3 + (1|id)');

% Display results
disp('Linear Mixed Effects Model Results:');
disp(lme);

% Additional summary statistics
fprintf('\nDistribution of subjects across conditions:\n');
fprintf('Condition 1: %d subjects\n', sum(group_cond1));
fprintf('Condition 2: %d subjects\n', sum(group_cond2));
fprintf('Condition 3: %d subjects\n', sum(group_cond3));

% Visualization
figure;
subplot(1,2,1);
bar([sum(group_cond1), sum(group_cond2), sum(group_cond3)]);
xticklabels({'Condition 1', 'Condition 2', 'Condition 3'});
title('Number of Subjects Showing Each Condition');
ylabel('Number of Subjects');

subplot(1,2,2);
boxplot(T.mean_learning, T.group_cond1);
title('Learning Performance by Condition 1');
xlabel('Condition 1 Present');
ylabel('Mean Learning');



rec=[];
for i=1:96
    if x(i)>y(i)&&x(i)>z(i)&&x(i)>0
        rec=[rec,i];
    end
end



rec=[];
for i=1:96
    if y(i)>x(i)&&y(i)>z(i)&&y(i)>0
        rec=[rec,i];
    end
end


rec=[];
for i=1:96
    if z(i)>x(i)&&z(i)>y(i)&&z(i)>0
        rec=[rec,i];
    end
end
a1=unique(id_col(rec));

a2=setdiff(unique(ids),a1);


% [h,p]=ttest2(),id_means(a2))

otherrec=setdiff(1:96,rec);

[h,p]=ttest2(unique(id_means(rec)),setdiff(unique(id_means),unique(id_means(rec))))


[h,p]=ttest2(id_means(rec),id_means(otherrec))
% First identify the dominant conditions


%% mesh

% Get learning values
x = results_matrix(:,3); % condition 1
y = results_matrix(:,4); % condition 2
z = results_matrix(:,5); % condition 3
ids = results_matrix(:,1); % IDs

% Calculate mean learning per ID
unique_ids = unique(ids);
id_means = zeros(size(ids));
for i = 1:length(unique_ids)
    id_idx = ids == unique_ids(i);
    curr_mean = mean([x(id_idx), y(id_idx), z(id_idx)], 'all');
    id_means(id_idx) = curr_mean;
end

% Create finer grid for smoother surface
[xi, yi] = meshgrid(linspace(min(x), max(x), 100), linspace(min(y), max(y), 100));

% Use 'v4' method for smoother interpolation
zi = griddata(x, y, z, xi, yi, 'v4');
ci = griddata(x, y, id_means, xi, yi, 'v4');

% Apply smoothing using gaussian filter
smoothing_sigma = 10;
zi = imgaussfilt(zi, smoothing_sigma);
ci = imgaussfilt(ci, smoothing_sigma);

figure;
mesh(xi, yi, zi, ci);
colorbar;
colormap('jet');


xlabel('full');
ylabel('partial');
zlabel('no');
title('3D Mesh Plot of Learning Conditions');
grid on;
hold on
%scatter3(x, y, z, 50, id_means, 'filled') % 50是点的大小
hold off


%% f p mean
% Get learning values
x = results_matrix(:,3); % condition 1
y = results_matrix(:,4); % condition 2
ids = results_matrix(:,1); % IDs

% Calculate overall mean learning for each ID (average of conditions 1,2,3)
unique_ids = unique(ids);
id_means = zeros(size(ids));
for i = 1:length(unique_ids)
    id_idx = ids == unique_ids(i);
    % Calculate mean of all three conditions
    curr_mean = mean([results_matrix(id_idx,3:5)], 'all');
    id_means(id_idx) = curr_mean;
end

% Create grid for contour
[xi, yi] = meshgrid(linspace(min(x), max(x), 100), linspace(min(y), max(y), 100));
mean_interpolated = griddata(x, y, id_means, xi, yi, 'v4');

% Apply smoothing
smoothing_sigma = 10;
mean_interpolated = imgaussfilt(mean_interpolated, smoothing_sigma);

% Create figure
figure;

% Create filled contour plot
contourf(xi, yi, mean_interpolated, 20, 'LineColor', 'none');
colorbar;
colormap('jet');

% Labels and title
xlabel('full');
ylabel('partial');
title('Learning Pattern Map');
;
% Add colorbar and set its range
c = colorbar;
ylabel(c, 'Mean Learning Value (across all conditions)');

% Make it pretty
grid on;
axis square;

% Display stats
fprintf('Overall mean learning range: %.2f to %.2f\n', min(id_means), max(id_means));


%% f p mean
% Get learning values
x = results_matrix(:,3); % condition 1
y = results_matrix(:,5); % condition 2
ids = results_matrix(:,1); % IDs

% Calculate overall mean learning for each ID (average of conditions 1,2,3)
unique_ids = unique(ids);
id_means = zeros(size(ids));
for i = 1:length(unique_ids)
    id_idx = ids == unique_ids(i);
    % Calculate mean of all three conditions
    curr_mean = mean([results_matrix(id_idx,3:5)], 'all');
    id_means(id_idx) = curr_mean;
end

% Create grid for contour
[xi, yi] = meshgrid(linspace(min(x), max(x), 100), linspace(min(y), max(y), 100));
mean_interpolated = griddata(x, y, id_means, xi, yi, 'v4');

% Apply smoothing
smoothing_sigma = 10;
mean_interpolated = imgaussfilt(mean_interpolated, smoothing_sigma);

% Create figure
figure;

% Create filled contour plot
contourf(xi, yi, mean_interpolated, 20, 'LineColor', 'none');


% Add colorbar label
c = colorbar;
colormap('jet');

% Labels and title
xlabel('full');
ylabel('no');
title('Learning Pattern Map');

% Add colorbar label
ylabel(c, 'Mean Learning Value (across all conditions)');

% Make it pretty
grid on;
axis square;

% Display stats
fprintf('Overall mean learning range: %.2f to %.2f\n', min(id_means), max(id_means));


%% f p mean
% Get learning values
x = results_matrix(:,4); % condition 1
y = results_matrix(:,5); % condition 2
ids = results_matrix(:,1); % IDs

% Calculate overall mean learning for each ID (average of conditions 1,2,3)
unique_ids = unique(ids);
id_means = zeros(size(ids));
for i = 1:length(unique_ids)
    id_idx = ids == unique_ids(i);
    % Calculate mean of all three conditions
    curr_mean = mean([results_matrix(id_idx,3:5)], 'all');
    id_means(id_idx) = curr_mean;
end

% Create grid for contour
[xi, yi] = meshgrid(linspace(min(x), max(x), 100), linspace(min(y), max(y), 100));
mean_interpolated = griddata(x, y, id_means, xi, yi, 'v4');

% Apply smoothing
smoothing_sigma = 10;
mean_interpolated = imgaussfilt(mean_interpolated, smoothing_sigma);

% Create figure
figure;

% Create filled contour plot
contourf(xi, yi, mean_interpolated, 20, 'LineColor', 'none');
colorbar;
colormap('jet');

% Labels and title
xlabel('partial');
ylabel('no');
title('Learning Pattern Map');

% Add colorbar label
c = colorbar;
ylabel(c, 'Mean Learning Value (across all conditions)');

% Make it pretty
grid on;
axis square;

% Display stats
fprintf('Overall mean learning range: %.2f to %.2f\n', min(id_means), max(id_means));


% 初始化存储p值的矩阵
percentiles = 50:10:90;
p_values = zeros(length(percentiles), 3);  % 3列分别存储三个条件的p值

for i = 1:length(percentiles)
    percenta = percentiles(i);
    threshold = prctile(id_means, percenta);
    high_mean_idx = id_means >= threshold;
    
    % 统计high_mean_idx中的unique ID数量
    high_ids = unique(id_col(high_mean_idx));
    num_unique_ids = length(high_ids);
    
    % 显示样本量和unique ID数量
    fprintf('\nPercentile %d%%: %d cases, %d unique subjects\n', ...
            percenta, sum(high_mean_idx), num_unique_ids);
    
    % 计算并显示均值
    fprintf('Condition 1: High = %.2f, Others = %.2f\n', ...
        mean(results_matrix(high_mean_idx,3)), mean(results_matrix(~high_mean_idx,3)));
    fprintf('Condition 2: High = %.2f, Others = %.2f\n', ...
        mean(results_matrix(high_mean_idx,4)), mean(results_matrix(~high_mean_idx,4)));
    fprintf('Condition 3: High = %.2f, Others = %.2f\n', ...
        mean(results_matrix(high_mean_idx,5)), mean(results_matrix(~high_mean_idx,5)));
    
    % 进行t检验
    [~,p1] = ttest2(results_matrix(high_mean_idx,3), results_matrix(~high_mean_idx,3));
    [~,p2] = ttest2(results_matrix(high_mean_idx,4), results_matrix(~high_mean_idx,4));
    [~,p3] = ttest2(results_matrix(high_mean_idx,5), results_matrix(~high_mean_idx,5));
    
    % 存储p值
    p_values(i,:) = [p1, p2, p3];
    
    % 显示p值
    fprintf('P-values: Cond1=%.4e, Cond2=%.4e, Cond3=%.4e\n', p1, p2, p3);
    
    % 可以选择显示具体的ID（如果需要）
    % fprintf('High performing IDs: ');
    % fprintf('%d ', high_ids);
    % fprintf('\n');
end
% 进行FDR校正（对所有p值一起校正）
all_p = p_values(:);
q_values = mafdr(all_p, 'BHFDR', true);
q_values = reshape(q_values, size(p_values));

% 显示结果表格
fprintf('\n最终结果汇总：\n');
fprintf('Percentile\tCondition\tP-value\t\tQ-value\n');
for i = 1:length(percentiles)
    for j = 1:3
        fprintf('%d%%\t\tCond%d\t\t%.4e\t%.4e\n', ...
                percentiles(i), j, p_values(i,j), q_values(i,j));
    end
end

% 可视化p值和q值
figure;
subplot(1,2,1);
imagesc(p_values);
colormap('jet');
colorbar;
title('P-values');
xlabel('Conditions');
ylabel('Percentiles');
set(gca, 'XTick', 1:3, 'XTickLabel', {'Cond1', 'Cond2', 'Cond3'});
set(gca, 'YTick', 1:length(percentiles), 'YTickLabel', percentiles);

subplot(1,2,2);
imagesc(q_values);
colormap('jet');
colorbar;
title('Q-values (FDR corrected)');
xlabel('Conditions');
ylabel('Percentiles');
set(gca, 'XTick', 1:3, 'XTickLabel', {'Cond1', 'Cond2', 'Cond3'});
set(gca, 'YTick', 1:length(percentiles), 'YTickLabel', percentiles);