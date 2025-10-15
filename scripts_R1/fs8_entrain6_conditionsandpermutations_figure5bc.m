%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 RESULT 2.3.1 - NSE significant only in Full gaze condition
%% "Compared to a surrogate distribution (95% CI upper bound), significant NSE
%% was observed only in the Full gaze condition. Entrainment was detected across
%% three frequency bands—delta, theta, and alpha—and nine EEG channels (Fig. 5b),
%% after correcting for multiple comparisons. Specifically, significant NSE was
%% identified in the delta band at C3, theta band at F4 and Pz, and alpha band
%% at C3 and Cz (all at corrected p < .05)"
%%
%% Statistical method:
%% - Compare real NSE peak values to surrogate distribution (1000 permutations)
%% - p-value = proportion of surrogate values >= real value
%% - BHFDR correction for multiple comparisons (mafdr)
%% - Significant if FDR-corrected q <= 0.05
%%
%% Channel order: F3, FZ, F4, C3, CZ, C4, P3, PZ, P4
%% Significant features (Condition 1 = Full gaze only):
%% - Delta C3 (column 43 = 40+3)
%% - Theta F4 (column 24 = 22+2)
%% - Theta Pz (column 29 = 22+7)
%% - Alpha C3 (column 7 = 4+3)
%% - Alpha Cz (column 8 = 4+4)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%figure 5b
%% outlier for each cond
% from fs8_entrain4_readdata.m
% first ph
path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'
phrase=1;
[a, b] = xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/code/final2/ENTRAINTABLE.xlsx']);
% pick only phrase 1 of each block data, to get first six syllabels
% entrainment
a=a(find(a(:,3)==phrase),:);
c1=find(a(:,2)==1);
c2=find(a(:,2)==2);
c3=find(a(:,2)==3);
% load surrogation data of 1000 times
load('ENTRIANSURR.mat')
nmean1 = [];
nmean2 = [];
nmean3 = [];

for i = 1:length(permutable)
    if ~isempty(permutable{i})
        tmp = permutable{i};
        tmp = table2array(tmp(:,2:end));
        tmp(abs(tmp) < 1) = abs(tmp(abs(tmp) < 1));
        tmp=tmp(find(tmp(:,3)==phrase),:);
        % tmp=tmp(intersect(find(a(:,3)==phrase),find(a(:,1)==phrase)),:);
        tmp_g1 = tmp(tmp(:,2)==1,:);
        tmp_g2 = tmp(tmp(:,2)==2,:);
        tmp_g3 = tmp(tmp(:,2)==3,:);
        nmean1 = [nmean1; nanmean(tmp_g1)];
        nmean2 = [nmean2; nanmean(tmp_g2)];
        nmean3 = [nmean3; nanmean(tmp_g3)];
    end
end

% Define labels
peaklabel = [4:12, 22:30, 40:48];
laglabel = [13:21, 31:39, 49:57];

% Process real data
a(abs(a) < 1) = abs(a(abs(a) < 1));
realmean1 = nanmean(a(a(:,2)==1,:));
realmean2 = nanmean(a(a(:,2)==2,:));
realmean3 = nanmean(a(a(:,2)==3,:));

%% plot f5
prctile(nmean1(:,24), 95)
realmean1(:,24)

prctile(nmean2(:,24), 95)
realmean2(:,24)

prctile(nmean3(:,24), 95)
realmean3(:,24)

%% R1 RESULT 2.3.1 - Condition 1 (Full gaze) significance testing
% Process Condition 1
sig_peak_cols1 = [];
peak_p_values1 = [];
sig_lag_cols1 = [];
lag_outliers1 = [];
lag_p_values1 = [];

for i = 1:length(peaklabel)
    col = peaklabel(i);
    % R1: Calculate p-value as proportion of surrogate >= real
    p_value = sum(nmean1(:,col) >= realmean1(col)) / size(nmean1, 1);
    if p_value <= 1
        sig_peak_cols1 = [sig_peak_cols1, col];
        peak_p_values1 = [peak_p_values1, p_value];
    end
end
% q=mafdr(peak_p_values1,'BHFDR',true)

for i = 1:length(laglabel)
    col = laglabel(i);
    lower_percentile = prctile(nmean1(:,col), 2.5);
    upper_percentile = prctile(nmean1(:,col), 97.5);

    if realmean1(col) < lower_percentile
        p_value = sum(nmean1(:,col) <= realmean1(col)) / size(nmean1, 1);
        outlier_status = "< 2.5%";
    elseif realmean1(col) > upper_percentile
        p_value = sum(nmean1(:,col) >= realmean1(col)) / size(nmean1, 1);
        outlier_status = "> 97.5%";
    else
        p_value = 2 * min(sum(nmean1(:,col) <= realmean1(col)), sum(nmean1(:,col) >= realmean1(col))) / size(nmean1, 1);
        outlier_status = "Not significant";
    end

    if p_value <= 1
        sig_lag_cols1 = [sig_lag_cols1, col];
        lag_outliers1 = [lag_outliers1, outlier_status];
        lag_p_values1 = [lag_p_values1, p_value];
    end
end

%% R1: Apply BHFDR correction for multiple comparisons (corrected p < .05)
q_peak1 = mafdr(peak_p_values1,'BHFDR',true);
q_lag1 = mafdr(lag_p_values1,'BHFDR',true);

% q=mafdr(lag_p_values1,'BHFDR',true)

% Process Condition 2
sig_peak_cols2 = [];
peak_p_values2 = [];
sig_lag_cols2 = [];
lag_outliers2 = [];
lag_p_values2 = [];

for i = 1:length(peaklabel)
    col = peaklabel(i);
    p_value = sum(nmean2(:,col) >= realmean2(col)) / size(nmean2, 1);
    if p_value <= 1
        sig_peak_cols2 = [sig_peak_cols2, col];
        peak_p_values2 = [peak_p_values2, p_value];
    end
end
% q=mafdr(peak_p_values2,'BHFDR',true)

for i = 1:length(laglabel)
    col = laglabel(i);
    lower_percentile = prctile(nmean2(:,col), 2.5);
    upper_percentile = prctile(nmean2(:,col), 97.5);
    
    if realmean2(col) < lower_percentile
        p_value = sum(nmean2(:,col) <= realmean2(col)) / size(nmean2, 1);
        outlier_status = "< 2.5%";
    elseif realmean2(col) > upper_percentile
        p_value = sum(nmean2(:,col) >= realmean2(col)) / size(nmean2, 1);
        outlier_status = "> 97.5%";
    else
        p_value = 2 * min(sum(nmean2(:,col) <= realmean2(col)), sum(nmean2(:,col) >= realmean2(col))) / size(nmean2, 1);
        outlier_status = "Not significant";
    end
    
    if p_value <= 1
        sig_lag_cols2 = [sig_lag_cols2, col];
        lag_outliers2 = [lag_outliers2, outlier_status];
        lag_p_values2 = [lag_p_values2, p_value];
    end
end

% q=mafdr(lag_p_values2,'BHFDR',true)
q_peak2 = mafdr(peak_p_values2,'BHFDR',true);
q_lag2 = mafdr(lag_p_values2,'BHFDR',true);

% Process Condition 3
sig_peak_cols3 = [];
peak_p_values3 = [];
sig_lag_cols3 = [];
lag_outliers3 = [];
lag_p_values3 = [];

for i = 1:length(peaklabel)
    col = peaklabel(i);
    p_value = sum(nmean3(:,col) >= realmean3(col)) / size(nmean3, 1);
    if p_value <= 1
        sig_peak_cols3 = [sig_peak_cols3, col];
        peak_p_values3 = [peak_p_values3, p_value];
    end
end
% q=mafdr(peak_p_values3,'BHFDR',true)

for i = 1:length(laglabel)
    col = laglabel(i);
    lower_percentile = prctile(nmean3(:,col), 2.5);
    upper_percentile = prctile(nmean3(:,col), 97.5);
    
    if realmean3(col) < lower_percentile
        p_value = sum(nmean3(:,col) <= realmean3(col)) / size(nmean3, 1);
        outlier_status = "< 2.5%";
    elseif realmean3(col) > upper_percentile
        p_value = sum(nmean3(:,col) >= realmean3(col)) / size(nmean3, 1);
        outlier_status = "> 97.5%";
    else
        p_value = 2 * min(sum(nmean3(:,col) <= realmean3(col)), sum(nmean3(:,col) >= realmean3(col))) / size(nmean3, 1);
        outlier_status = "Not significant";
    end
    
    if p_value <= 1
        sig_lag_cols3 = [sig_lag_cols3, col];
        lag_outliers3 = [lag_outliers3, outlier_status];
        lag_p_values3 = [lag_p_values3, p_value];
    end
end
% q=mafdr(lag_p_values3,'BHFDR',true)

q_peak3 = mafdr(peak_p_values3,'BHFDR',true);
q_lag3 = mafdr(lag_p_values3,'BHFDR',true);

% Display results for Condition 1

%% R1 RESULT 2.3.1 - Display significant NSE features (Full gaze only)
%% Expected output: Delta C3, Theta F4, Theta Pz, Alpha C3, Alpha Cz (all q < .05)
% Display results for Condition 1
fprintf('Results for Condition 1:/n');
fprintf('Significant peak columns after FDR correction (q <= 0.05):/n');
for i = 1:length(sig_peak_cols1)
    col = sig_peak_cols1(i);
    if q_peak1(i) <= 0.05
        fprintf('%s (Column %d): q = %.4f/n', b{1, col + 1}, col, q_peak1(i));
    end
end
fprintf('/nSignificant lag columns after FDR correction (q <= 0.05):/n');
for i = 1:length(sig_lag_cols1)
    col = sig_lag_cols1(i);
    if q_lag1(i) <= 0.05
        fprintf('%s (Column %d): %s, q = %.4f/n', b{1, col + 1}, col, lag_outliers1{i}, q_lag1(i));
    end
end
fprintf('/n');

% Display results for Condition 2
fprintf('Results for Condition 2:/n');
fprintf('Significant peak columns after FDR correction (q <= 0.05):/n');
for i = 1:length(sig_peak_cols2)
    col = sig_peak_cols2(i);
    if q_peak2(i) <= 0.05
        fprintf('%s (Column %d): q = %.4f/n', b{1, col + 1}, col, q_peak2(i));
    end
end
fprintf('/nSignificant lag columns after FDR correction (q <= 0.05):/n');
for i = 1:length(sig_lag_cols2)
    col = sig_lag_cols2(i);
    if q_lag2(i) <= 0.05
        fprintf('%s (Column %d): %s, q = %.4f/n', b{1, col + 1}, col, lag_outliers2{i}, q_lag2(i));
    end
end
fprintf('/n');

% Display results for Condition 3
fprintf('Results for Condition 3:/n');
fprintf('Significant peak columns after FDR correction (q <= 0.05):/n');
for i = 1:length(sig_peak_cols3)
    col = sig_peak_cols3(i);
    if q_peak3(i) <= 0.05
        fprintf('%s (Column %d): q = %.4f/n', b{1, col + 1}, col, q_peak3(i));
    end
end
fprintf('/nSignificant lag columns after FDR correction (q <= 0.05):/n');
for i = 1:length(sig_lag_cols3)
    col = sig_lag_cols3(i);
    if q_lag3(i) <= 0.05
        fprintf('%s (Column %d): %s, q = %.4f/n', b{1, col + 1}, col, lag_outliers3{i}, q_lag3(i));
    end
end
fprintf('/n');
% Create figures for peak and lag data
figure('Position', [100, 100, 1500, 500]);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% figure 3b %%%%%%%%%% 
% Call the function to create the visualization
create_statistical_matrices(peak_p_values1, q_peak1, realmean1, nmean1, peaklabel, ...
                            peak_p_values2, q_peak2, realmean2, nmean2, ...
                            peak_p_values3, q_peak3, realmean3, nmean3);

%%%%%%%%%%%% figure 3b above %%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% figure 3c %%%%%%%%%% plot surr violin and real data
% 创建图形
% 假设 nmean1 和 realmean 已经在工作空间中定义
% 创建图形figure;

% 绘制直方图,使用灰色填充,减小bin大小
label=7 %alpha c3
label= 43 %delta c3
 
surdata=nmean1;
realdata=realmean1;
surdata(:,label)
prctile(surdata(:,label),95)
realdata(label)

surdata=nmean2;
realdata=realmean2;
surdata(:,label)
prctile(surdata(:,label),95)
realdata(label)


surdata=nmean3;
realdata=realmean3;
surdata(:,label)
prctile(surdata(:,label),95)
realdata(label)

%%%%%%%%%%%% figure 3c above %%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot peak data
% Function to calculate MAD as effect size (not cohens d)
function cohens_d_values = calculate_cohens_d(realmean, nmean)
    [n_samples, n_cols] = size(nmean);
    cohens_d_values = zeros(1, n_cols);
    
    for i = 1:n_cols
        group1 = repmat(realmean(i), n_samples, 1);
        group2 = nmean(:,i);
        
        s1 = std(group1);  % 这将始终为0
        s2 = std(group2);
        
        % 使用仅基于group2的标准差
        d = (mean(group1) - mean(group2)) / s2;
        
        cohens_d_values(i) = d;
    end
end

% Function to plot a single matrix
function h = plot_matrix(subplot_idx, pvalues, qvalues, realmean, nmean, cols)
    h = subplot(1, 3, subplot_idx);
    
    % Calculate mean differences and Cohen's d
    mean_diff = realmean(cols) - mean(nmean(:,cols));
    for i = 1:length(cols)
        % cohens_d_values(i) = cohens_d(repmat(realmean(cols(i)), size(nmean, 1), 1), nmean(:,cols(i)));
        cohens_d_values(i) =calculate_cohens_d(realmean(cols(i)), nmean(:,cols(i)));
    end
    
    % Reshape data for 9x3 matrix
    mean_diff_matrix = reshape(mean_diff, [9, 3]);
    cohens_d_matrix = reshape(cohens_d_values, [9, 3]);
    pvalues_matrix = reshape(pvalues, [9, 3]);
    qvalues_matrix = reshape(qvalues, [9, 3]);
    
    % Reverse the order of columns
    cohens_d_matrix = fliplr(cohens_d_matrix);
    qvalues_matrix = fliplr(qvalues_matrix);
    
    % Use Cohen's d for coloring
    imagesc(cohens_d_matrix);
    
    % Add statistical information
    [rows, cols] = size(cohens_d_matrix);
    hold on;
    for i = 1:rows
        for j = 1:cols
            % Add significance stars based on q-value
            if qvalues_matrix(i,j) < 0.05
                % text(j, i, '*', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'k', 'FontSize', 50, 'FontWeight', 'bold');
            end
        end
    end
    hold off;
    
    % Customize the plot
    set(gca, 'XTick', 1:cols, 'YTick', 1:rows);
    set(gca, 'XTickLabel', {'Delta', 'Theta', 'Alpha'}); % Reversed order
    set(gca, 'YTickLabel', {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'});
    if subplot_idx == 1
        ylabel('Channel', 'FontSize', 16, 'FontWeight', 'bold');
    end
    if subplot_idx == 2
        xlabel('Frequency Band', 'FontSize', 20, 'FontWeight', 'bold');
    end
    
    % Increase font size and make bold
    set(gca, 'FontSize', 20, 'FontWeight', 'bold');
    
    % Remove inner ticks
    set(gca, 'TickDir', 'out');

    % Make border thicker
    set(gca, 'LineWidth', 3);
    
    % Adjust figure to remove extra white space
    set(gca, 'LooseInset', get(gca, 'TightInset'));
end

% Main function to create the figure
function create_statistical_matrices(peak_p_values1, q_peak1, realmean1, nmean1, peaklabel, ...
                                     peak_p_values2, q_peak2, realmean2, nmean2, ...
                                     peak_p_values3, q_peak3, realmean3, nmean3)
    % Create figure
    figure('Position', [100, 100, 1600, 500]); % Increased width to accommodate colorbar
    
    % Plot data for each condition
    h1 = plot_matrix(1, peak_p_values1, q_peak1, realmean1, nmean1, peaklabel);
    h2 = plot_matrix(2, peak_p_values2, q_peak2, realmean2, nmean2, peaklabel);
    h3 = plot_matrix(3, peak_p_values3, q_peak3, realmean3, nmean3, peaklabel);
    
    % Create a unified colorbar based on all subplots
    colormap(redblue(256)); % Custom colormap
    c = colorbar;
    max_abs_d = max([max(abs(get(h1, 'CLim'))), max(abs(get(h2, 'CLim'))), max(abs(get(h3, 'CLim')))]);
    set([h1 h2 h3], 'CLim', [-max_abs_d, max_abs_d]);
    % set([h1 h2 h3], 'CLim', [-5, 5]);
    
    % Customize colorbar
    c.LineWidth = 3;
    c.FontSize = 20;
    c.FontWeight = 'bold';
    c.Label.String = 'Cohen''s d';
    c.Label.FontSize = 20;
    c.Label.FontWeight = 'bold';
    
    % Adjust colorbar position
    c_pos = c.Position;
    c.Position = [c_pos(1)+0.08 c_pos(2) c_pos(3)*1 c_pos(4)]; % Moved further right
    
    % Add labels for each condition
    % text(0.2, 1.05, 'Condition 1', 'Units', 'normalized', 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    % text(0.5, 1.05, 'Condition 2', 'Units', 'normalized', 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    % text(0.8, 1.05, 'Condition 3', 'Units', 'normalized', 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end


%% former color
% function cmap = redblue(m)
% if nargin < 1, m = 64; end
% 
% % Define the maximum intensity for red and blue (0.8 for softer colors)
% max_intensity = 1;
% 
% if mod(m,2) == 0
%     % From [0 0 max_intensity] to [1 1 1], then [1 1 1] to [max_intensity 0 0];
%     m1 = m*0.5;
%     r = (0:m1-1)'/max(m1-1,1) * max_intensity;
%     g = r;
%     r = [r; ones(m1,1)];
%     g = [g; flipud(g)];
%     b = flipud(r);
% else
%     % From [0 0 max_intensity] to [1 1 1] to [max_intensity 0 0];
%     m1 = floor(m*0.5);
%     r = (0:m1-1)'/max(m1,1) * max_intensity;
%     g = r;
%     r = [r; ones(m1+1,1)];
%     g = [g; 1; flipud(g)];
%     b = flipud(r);
% end
% 
% cmap = [r g b];
% end

function cmap = redblue(m)
if nargin < 1, m = 64; end
% Create a gradient from white to red
r = ones(m, 1);
g = linspace(1, 0.2, m)';
b = g;

cmap = [r g b];
end