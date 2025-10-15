%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 SUPPLEMENTARY FIGURE S1 - Individual Learning Patterns
%% "Supplementary Materials Section 1 illustrates that individual infants
%% with the highest overall learning also showed strongest learning in the
%% Full gaze condition, but little or no learning with Partial or No speaker gaze."
%%
%% Shows individual subject-level learning across three gaze conditions
%% Purpose: Demonstrate that high learners excel in Full gaze, but not in Partial/No gaze
%%
%% Analysis: For each infant, calculate mean learning per condition (across blocks)
%% Visualization: 3D scatter plot or individual learning profiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% subjectlevel
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
% Initialize arrays for the pooled data
unique_ids = unique(ID);
id_col = [];
mean_cond1 = [];
mean_cond2 = [];
mean_cond3 = [];

% For each unique ID
for i = 1:length(unique_ids)
    current_id = unique_ids(i);
    id_indices = find(ID == current_id);
    
    % Get all values for each condition (across all blocks)
    cond1_vals = learning(id_indices(cond(id_indices) == 1));
    cond2_vals = learning(id_indices(cond(id_indices) == 2));
    cond3_vals = learning(id_indices(cond(id_indices) == 3));
    
    % Only include subject if they have data for all conditions
    if ~isempty(cond1_vals) && ~isempty(cond2_vals) && ~isempty(cond3_vals)
        id_col = [id_col; current_id];
        mean_cond1 = [mean_cond1; mean(cond1_vals, 'omitnan')];
        mean_cond2 = [mean_cond2; mean(cond2_vals, 'omitnan')];
        mean_cond3 = [mean_cond3; mean(cond3_vals, 'omitnan')];
    end
end

% Create the final matrix
results_matrix = [id_col mean_cond1 mean_cond2 mean_cond3];

% Display first few rows
disp('First rows of pooled results matrix:');
disp('Columns: ID, Mean_Cond1, Mean_Cond2, Mean_Cond3');
disp(results_matrix(1:5,:));

% Display matrix size
[rows, cols] = size(results_matrix);
fprintf('Matrix size: %d rows x %d columns\n', rows, cols);


% then the color of the surface is by the mean learning of this id, average all column no.3.4.5 for this id as a mean value

% Get learning values
x = results_matrix(:,2); % condition 1
y = results_matrix(:,3); % condition 2
z = results_matrix(:,4); % condition 3
ids = results_matrix(:,1); % IDs
% Initialize arrays\\


unique_ids = unique(ID);
id_means = zeros(length(unique_ids), 2); % Column 1 for ID, Column 2 for mean

% Calculate mean for each ID across all blocks and conditions
for i = 1:length(unique_ids)
    current_id = unique_ids(i);
    id_indices = find(ID == current_id);
    
    % Get all learning values for this ID
    all_learning = learning(id_indices);
    
    % Store ID and mean
    id_means(i,1) = current_id;
    id_means(i,2) = mean(all_learning, 'omitnan');
end

% Display first few rows
disp('First rows of overall learning means:');
disp('Columns: ID, Overall_Mean');
disp(id_means(1:5,:));

% Display matrix size
[rows, cols] = size(id_means);
fprintf('Matrix size: %d rows x %d columns\n', rows, cols);



% result = zeros(47, 3);
% for i = 1:47
%     if x(i) > y(i) && x(i) > z(i) 
%         result(i, 1) = 1;
%     elseif y(i) > x(i) && y(i) > z(i) 
%         result(i, 2) = 1;
%     elseif z(i) > x(i) && z(i) > y(i)
%         result(i, 3) = 1;
%     end
% end

result = zeros(47, 3);
for i = 1:47
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
group_cat = zeros(n_subjects, 1); % Single categorical group variable

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
    mean_learning_subj(i) = mean(id_means(subj_trials,2));
    
    % Get result matrix for this subject's trials
    subj_result = result(i, :);
    
    % Determine group category (1, 2, or 3)
    if any(subj_result(:,1))
        group_cat(i) = 1; % Full advantage
    elseif any(subj_result(:,2))
        group_cat(i) = 2; % Partial advantage
    elseif any(subj_result(:,3))

        group_cat(i) = 3; % No advantage
    else
        group_cat(i) = 0;
    end
end


%%
fulladv=id_col(find(group_cat==1));
paradv=id_col(find(group_cat==2));
noadv=id_col(find(group_cat==3));
m1=[];
for i=1:length(fulladv)
    current_id = fulladv(i);
    id_indices = find(ID == current_id);
    % Get all learning values for this ID
    all_learning = learning(id_indices);
    % Store ID and mean
    
    m1 = [m1;all_learning];
end
[nanmean(m1),nanstd(m1)]
m2=[];
for i=1:length(paradv)
    current_id = paradv(i);
    id_indices = find(ID == current_id);
    % Get all learning values for this ID
    all_learning = learning(id_indices);
    % Store ID and mean
       m2 = [m2;all_learning];
end

[nanmean(m2),nanstd(m2)]
m3=[];
for i=1:length(noadv)
    current_id = noadv(i);
    id_indices = find(ID == current_id);
    % Get all learning values for this ID
    all_learning = learning(id_indices);
    % Store ID and mean
        m3 = [m3;all_learning];
end

[nanmean(m3),nanstd(m3)]
%%
load('buggy.mat')
for i=1:length(buggy_inout)
    if buggy_inout(i)>=40
        buggytype(i)=1;
    elseif buggy_inout(i)<=-40
        buggytype(i)=-1;
    elseif isnan(buggy_inout(i))==0
        buggytype(i)=0;
    else
        buggytype(i)=nan;
    end
end
buggytype=buggytype';

group_cat2=group_cat;
group_cat2(find(group_cat2==2))=1;
valid=intersect(find(group_cat2>0),find(isnan(buggytype)==0));
buggytype2=buggytype(valid);
group_cat2=group_cat2(valid);
[tbl,chi2,p,labels] = crosstab(group_cat2,buggytype2)


% %Create analysis table with proper categorical variables
T = table(mean_learning_subj, age_subj, ...
    categorical(sex_subj), ... % Convert sex to categorical
    categorical(country_subj), ... % Convert country to categorical
    categorical(group_cat), ... % Convert group to categorical
    unique_ids,buggyin,buggytype, ...
    'VariableNames', {'mean_learning', 'age', 'sex', 'country', ...
    'group', 'id','buggy','buggytype'});
% Fit LME model with categorical predictors
lme = fitlme(T, 'mean_learning ~ age + sex + country+ group +(1|id)')
lme = fitlme(T, 'mean_learning ~ age + sex + country+ buggytype +(1|id)')
lme = fitlme(T, 'buggy ~ age + sex + country+ group +(1|id)')


% sup fig1a
group_cat3=group_cat;
group_cat3(find(group_cat==2))=3;
% Create analysis table with proper categorical variables
T = table(mean_learning_subj(find(group_cat>0)), age_subj(find(group_cat>0)), ...
    categorical(sex_subj(find(group_cat>0))), ... % Convert sex to categorical
    categorical(country_subj(find(group_cat>0))), ... % Convert country to categorical
    categorical(group_cat3(find(group_cat>0))), ... % Convert group to categorical
    unique_ids(find(group_cat>0)),buggy_inout(find(group_cat>0)), ...
    'VariableNames', {'mean_learning', 'age', 'sex', 'country', ...
    'group', 'id','buggy'});
% Fit LME model with categorical predictors
lme = fitlme(T, 'mean_learning ~ age + sex + country+ group ')
lme = fitlme(T, 'buggy ~ age + sex + country+ group')



%% block wise fig s1 bcd

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

F = scatteredInterpolant(x, y, id_means, 'natural');
ci = F(xi, yi);
% Apply smoothing using gaussian filter 
smoothing_sigma = 10;
xi= imgaussfilt(xi, smoothing_sigma);
yi= imgaussfilt(yi, smoothing_sigma);
 zi = imgaussfilt(zi, smoothing_sigma);
ci = imgaussfilt(ci, smoothing_sigma);

% Create the figure
figure;
surf(xi, yi, zi, ci);
colorbar;
colormap('jet');

% 设置字体和轴线
set(gca, 'FontName', 'Arial', 'FontSize', 20, 'FontWeight', 'bold', 'LineWidth', 2);

xlabel('Full-gaze learning / sec', 'FontName', 'Arial', 'FontSize', 20, 'FontWeight', 'bold');
ylabel('Partial-gaze learning / sec', 'FontName', 'Arial', 'FontSize', 20, 'FontWeight', 'bold');
zlabel('No-gaze learning / sec', 'FontName', 'Arial', 'FontSize', 20, 'FontWeight', 'bold');
title('3D Surface Plot of Learning', 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');

% 设置colorbar
c = colorbar;
set(c, 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold', 'LineWidth', 2);
ylabel(c, 'Overall learning / sec', 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');

grid on;
hold on
%scatter3(x, y, z, 50, id_means, 'filled') % 50是点的大小
hold off

%% f p mean (第一部分)
% Get learning values


x = results_matrix(:,3); % condition 1
y = results_matrix(:,4); % condition 2
ids = results_matrix(:,1); % IDs

% Calculate overall mean learning for each ID
unique_ids = unique(ids);
id_means = zeros(size(ids));
for i = 1:length(unique_ids)
    id_idx = ids == unique_ids(i);
    curr_mean = mean([results_matrix(id_idx,3:5)], 'all');
    id_means(id_idx) = curr_mean;
end

% Create grid for contour
[xi, yi] = meshgrid(linspace(min(x), max(x), 100), linspace(min(y), max(y), 100));
mean_interpolated = griddata(x, y, id_means, xi, yi, 'v4');

F = scatteredInterpolant(x, y, id_means, 'natural');
mean_interpolated = F(xi, yi);

% Apply smoothing
smoothing_sigma = 10;


mean_interpolated = imgaussfilt(mean_interpolated, smoothing_sigma);

%% Plot Full vs Partial gaze with marginals
figure('Position', [100 100 800 800]);

% Define subplot positions
mainPosition = [0.2 0.2 0.6 0.6];
topPosition = [0.2 0.8 0.6 0.15];
rightPosition = [0.8 0.2 0.15 0.6];


colorbarPosition = [0.95 0.2 0.02 0.6];

% Main contour plot
subplot('Position', mainPosition);
contourf(xi, yi, mean_interpolated, 40, 'LineColor', 'none');
hold on
%scatter(x, y, 60, id_means, 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1)
hold off
colormap('jet');
grid on;
axis square;

% 设置主图属性
set(gca, 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold', 'LineWidth', 2);
xlabel('Full-gaze learning / sec', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
ylabel('Partial-gaze learning / sec', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');


% 计算边际分布
ci = mean_interpolated;
x_margin = mean(ci, 1);
y_margin = mean(ci, 2);

% Top marginal plot
subplot('Position', topPosition);
x_values = linspace(min(x), max(x), size(ci, 2));
plot(x_values, x_margin, 'LineWidth', 3, 'Color', 'k');
xlim([min(x) max(x)]);
 grid on;
set(gca, 'XTickLabel', [], 'Color', 'w', 'GridColor', [0.8 0.8 0.8]);
ylabel('MD', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
set(gca, 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold', 'LineWidth', 2);
box on;

% Right marginal plot
subplot('Position', rightPosition);
y_values = linspace(min(y), max(y), size(ci, 1));
plot(y_margin, y_values, 'LineWidth', 3, 'Color', 'k');
ylim([min(y) max(y)]);
set(gca, 'YTickLabel', [], 'Color', 'w', 'GridColor', [0.8 0.8 0.8]);
xlabel('MD', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
set(gca, 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold', 'LineWidth', 2);
box on;



%% f p mean (第二部分)%% f p mean (第二部分)
% Get learning values

x = results_matrix(:,3); % condition 1
y = results_matrix(:,5); % condition 2
ids = results_matrix(:,1); % IDs

% Calculate overall mean learning for each ID
unique_ids = unique(ids);
id_means = zeros(size(ids));
for i = 1:length(unique_ids)
    id_idx = ids == unique_ids(i);
    curr_mean = mean([results_matrix(id_idx,3:5)], 'all');
    id_means(id_idx) = curr_mean;
end

% Create grid for contour
[xi, yi] = meshgrid(linspace(min(x), max(x), 100), linspace(min(y), max(y), 100));
mean_interpolated = griddata(x, y, id_means, xi, yi, 'v4');

F = scatteredInterpolant(x, y, id_means, 'natural');
mean_interpolated = F(xi, yi);

% Apply smoothing
smoothing_sigma = 10;


mean_interpolated = imgaussfilt(mean_interpolated, smoothing_sigma);

%% Plot Full vs Partial gaze with marginals
figure('Position', [100 100 800 800]);

% Define subplot positions
mainPosition = [0.2 0.2 0.6 0.6];
topPosition = [0.2 0.8 0.6 0.15];
rightPosition = [0.8 0.2 0.15 0.6];


colorbarPosition = [0.95 0.2 0.02 0.6];

% Main contour plot
subplot('Position', mainPosition);
contourf(xi, yi, mean_interpolated, 40, 'LineColor', 'none');
hold on
%scatter(x, y, 60, id_means, 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1)
hold off
colormap('jet');
grid on;
axis square;

% 设置主图属性
set(gca, 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold', 'LineWidth', 2);
xlabel('Full-gaze learning / sec', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
ylabel('No-gaze learning / sec', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');


% 计算边际分布
ci = mean_interpolated;
x_margin = mean(ci, 1);
y_margin = mean(ci, 2);

% Top marginal plot
subplot('Position', topPosition);
x_values = linspace(min(x), max(x), size(ci, 2));
plot(x_values, x_margin, 'LineWidth', 3, 'Color', 'k');
xlim([min(x) max(x)]);
 grid on;
set(gca, 'XTickLabel', [], 'Color', 'w', 'GridColor', [0.8 0.8 0.8]);
ylabel('MD', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
set(gca, 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold', 'LineWidth', 2);
box on;

% Right marginal plot
subplot('Position', rightPosition);
y_values = linspace(min(y), max(y), size(ci, 1));
plot(y_margin, y_values, 'LineWidth', 3, 'Color', 'k');
ylim([min(y) max(y)]);
 grid on;
set(gca, 'YTickLabel', [], 'Color', 'w', 'GridColor', [0.8 0.8 0.8]);
xlabel('MD', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
set(gca, 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold', 'LineWidth', 2);
box on;



%% f p mean (第二部分)%% f p mean (第二部分)
% Get learning values

x = results_matrix(:,4); % condition 1
y = results_matrix(:,5); % condition 2
ids = results_matrix(:,1); % IDs

% Calculate overall mean learning for each ID
unique_ids = unique(ids);
id_means = zeros(size(ids));
for i = 1:length(unique_ids)
    id_idx = ids == unique_ids(i);
    curr_mean = mean([results_matrix(id_idx,3:5)], 'all');
    id_means(id_idx) = curr_mean;
end

% Create grid for contour
[xi, yi] = meshgrid(linspace(min(x), max(x), 100), linspace(min(y), max(y), 100));
mean_interpolated = griddata(x, y, id_means, xi, yi, 'v4');

F = scatteredInterpolant(x, y, id_means, 'natural');
mean_interpolated = F(xi, yi);

% Apply smoothing
smoothing_sigma = 10;


mean_interpolated = imgaussfilt(mean_interpolated, smoothing_sigma);

%% Plot Full vs Partial gaze with marginals
figure('Position', [100 100 800 800]);

% Define subplot positions
mainPosition = [0.2 0.2 0.6 0.6];
topPosition = [0.2 0.8 0.6 0.15];
rightPosition = [0.8 0.2 0.15 0.6];


colorbarPosition = [0.95 0.2 0.02 0.6];

% Main contour plot
subplot('Position', mainPosition);
contourf(xi, yi, mean_interpolated, 40, 'LineColor', 'none');
hold on
scatter(x, y, 60, id_means, 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1)
hold off
colormap('jet');
grid on;
axis square;

% 设置主图属性
set(gca, 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold', 'LineWidth', 2);
xlabel('Partial-gaze learning / sec', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
ylabel('No-gaze learning / sec', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');


% 计算边际分布
ci = mean_interpolated;
x_margin = mean(ci, 1);
y_margin = mean(ci, 2);

% Top marginal plot
subplot('Position', topPosition);
x_values = linspace(min(x), max(x), size(ci, 2));
plot(x_values, x_margin, 'LineWidth', 3, 'Color', 'k');
xlim([min(x) max(x)]);
 grid on;
set(gca, 'XTickLabel', [], 'Color', 'w', 'GridColor', [0.8 0.8 0.8]);
ylabel('MD', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
set(gca, 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold', 'LineWidth', 2);
box on;

% Right marginal plot
subplot('Position', rightPosition);
y_values = linspace(min(y), max(y), size(ci, 1));
plot(y_margin, y_values, 'LineWidth', 3, 'Color', 'k');
ylim([min(y) max(y)]);
 grid on;
set(gca, 'YTickLabel', [], 'Color', 'w', 'GridColor', [0.8 0.8 0.8]);
xlabel('MD', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
set(gca, 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold', 'LineWidth', 2);
box on;

%%


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
