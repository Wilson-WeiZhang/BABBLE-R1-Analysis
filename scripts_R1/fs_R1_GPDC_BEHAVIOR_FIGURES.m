%% ========================================================================
%  CREATE FIGURES FOR GPDC-BEHAVIOR ANALYSIS
%  ========================================================================
%
%  PURPOSE:
%  Generate publication-quality figures showing:
%  1. Scatter plots: Connection vs Learning/Attention
%  2. PLS performance comparison
%  3. Cross-validation results
%  4. Network visualization
%
%  OUTPUTS:
%  - Supplementary Figure: GPDC-Behavior Relationships (3-4 panels)
%  - Individual panels as separate files for flexibility
%
%  ========================================================================

clc
clear all

%% Setup
path = 'C:\Users\Admin\OneDrive - Nanyang Technological University\';
code_path = [path, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/scripts_R1/'];
results_path = [path, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/results/'];
figures_path = [path, 'infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/figures/'];

cd(code_path);

% Create figures directory if it doesn't exist
if ~exist(figures_path, 'dir')
    mkdir(figures_path);
end

fprintf('\n');
fprintf('========================================================================\n');
fprintf('  CREATING GPDC-BEHAVIOR FIGURES\n');
fprintf('========================================================================\n\n');

%% Load data and results
fprintf('Loading data and results...\n');

load('data_read_surr_gpdc.mat', 'data');
ori_data = sqrt(data);

% Extract variables
Condition = ori_data(:, 6);
Learning = ori_data(:, 7);
Attention = ori_data(:, 9);

% AI alpha connections
ai_alpha_range = 659:739;
load('stronglistfdr5_gpdc_AI.mat', 's4');
sig_AI_indices = s4;
ai_alpha_data = ori_data(:, ai_alpha_range);
ai_alpha_sig = ai_alpha_data(:, sig_AI_indices);

% The significant connection (12th)
SIG_CONN_IDX = 12;
sig_connection = ai_alpha_sig(:, SIG_CONN_IDX);

% Load analysis results
try
    load([results_path, 'R1_GPDC_BEHAVIOR_CORRELATION_PLS.mat'], 'results');
    has_corr_results = true;
catch
    fprintf('  Warning: Correlation results not found\n');
    has_corr_results = false;
end

try
    load([results_path, 'R1_PLS_CROSSVALIDATION_RESULTS.mat'], 'cv_results');
    has_cv_results = true;
catch
    fprintf('  Warning: CV results not found\n');
    has_cv_results = false;
end

fprintf('  Data loaded successfully\n\n');

%% Define colors
color_full = [0.2, 0.6, 0.8];      % Blue
color_partial = [0.9, 0.6, 0.2];   % Orange
color_none = [0.4, 0.7, 0.4];      % Green
color_all = [0.5, 0.5, 0.5];       % Gray

%% ========================================================================
%  FIGURE 1: SCATTER PLOTS - CONNECTION VS BEHAVIOR
%  ========================================================================

fprintf('Creating Figure 1: Scatter plots...\n');

fig1 = figure('Position', [100, 100, 1200, 400], 'Color', 'w');

% Panel A: Connection vs Learning
subplot(1, 3, 1);
hold on;

c1_idx = Condition == 1;
valid = ~isnan(sig_connection) & ~isnan(Learning);

% Scatter by condition
scatter(sig_connection(c1_idx & valid), Learning(c1_idx & valid), ...
    60, color_full, 'filled', 'MarkerFaceAlpha', 0.6);

% Fit line
p = polyfit(sig_connection(valid), Learning(valid), 1);
x_fit = linspace(min(sig_connection(valid)), max(sig_connection(valid)), 100);
y_fit = polyval(p, x_fit);
plot(x_fit, y_fit, 'k--', 'LineWidth', 1.5);

% Add statistics
if has_corr_results
    r_val = results.learning.r_overall;
    p_val = results.learning.p_overall;
    text(0.05, 0.95, sprintf('r = %.3f\np = %.3f', r_val, p_val), ...
        'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 10, ...
        'BackgroundColor', 'w', 'EdgeColor', 'k');
end

xlabel('AI Connection Strength (Fz→F4)', 'FontSize', 12);
ylabel('Learning Score', 'FontSize', 12);
title('A. Connection vs Learning', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
box on;
set(gca, 'FontSize', 10);

% Panel B: Connection vs Attention
subplot(1, 3, 2);
hold on;

valid = ~isnan(sig_connection) & ~isnan(Attention);

scatter(sig_connection(c1_idx & valid), Attention(c1_idx & valid), ...
    60, color_full, 'filled', 'MarkerFaceAlpha', 0.6);

% Fit line
p = polyfit(sig_connection(valid), Attention(valid), 1);
x_fit = linspace(min(sig_connection(valid)), max(sig_connection(valid)), 100);
y_fit = polyval(p, x_fit);
plot(x_fit, y_fit, 'k--', 'LineWidth', 1.5);

% Add statistics
if has_corr_results
    r_val = results.attention.r_overall;
    p_val = results.attention.p_overall;
    text(0.05, 0.95, sprintf('r = %.3f\np = %.3f', r_val, p_val), ...
        'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 10, ...
        'BackgroundColor', 'w', 'EdgeColor', 'k');
end

xlabel('AI Connection Strength (Fz→F4)', 'FontSize', 12);
ylabel('Attention Proportion', 'FontSize', 12);
title('B. Connection vs Attention', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
box on;
set(gca, 'FontSize', 10);

% Panel C: PLS Prediction (Observed vs Predicted)
subplot(1, 3, 3);
hold on;

if has_cv_results
    scatter(cv_results.Y_actual, cv_results.Y_pred_loocv, ...
        60, color_full, 'filled', 'MarkerFaceAlpha', 0.6);

    % Unity line
    lims = [min([cv_results.Y_actual; cv_results.Y_pred_loocv]), ...
            max([cv_results.Y_actual; cv_results.Y_pred_loocv])];
    plot(lims, lims, 'k--', 'LineWidth', 1.5);

    % Add R²
    text(0.05, 0.95, sprintf('R² = %.3f\nLOOCV', cv_results.R2_loocv), ...
        'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 10, ...
        'BackgroundColor', 'w', 'EdgeColor', 'k');

    xlabel('Observed Learning', 'FontSize', 12);
    ylabel('Predicted Learning (LOOCV)', 'FontSize', 12);
    title('C. PLS Prediction', 'FontSize', 14, 'FontWeight', 'bold');
    grid on;
    box on;
    set(gca, 'FontSize', 10);
    axis equal;
else
    text(0.5, 0.5, 'CV results not available', 'HorizontalAlignment', 'center');
end

% Save figure
saveas(fig1, [figures_path, 'FigS_GPDC_Behavior_Scatterplots.png']);
saveas(fig1, [figures_path, 'FigS_GPDC_Behavior_Scatterplots.fig']);
fprintf('  Saved: FigS_GPDC_Behavior_Scatterplots.png\n');

%% ========================================================================
%  FIGURE 2: PLS PERFORMANCE COMPARISON
%  ========================================================================

fprintf('Creating Figure 2: PLS performance...\n');

fig2 = figure('Position', [100, 100, 800, 500], 'Color', 'w');

if has_corr_results && has_cv_results
    % Prepare data
    methods = {'Single\nConnection\n(In-sample)', 'Single\nConnection\n(All Cond)', ...
               'Multi\nConnection\n(In-sample)', 'Multi\nConnection\n(LOOCV)'};
    R2_values = [results.pls.R2_full_gaze, results.pls.R2_all_cond, ...
                 cv_results.R2_insample, cv_results.R2_loocv];
    p_values = [results.pls.p_full_gaze, results.pls.p_all_cond, ...
                NaN, cv_results.p_value_permutation];

    % Bar plot
    b = bar(R2_values, 'FaceColor', 'flat');
    b.CData = [color_full; color_full; color_partial; color_partial];

    % Add significance stars
    hold on;
    for i = 1:length(R2_values)
        if ~isnan(p_values(i))
            if p_values(i) < 0.001
                sig_text = '***';
            elseif p_values(i) < 0.01
                sig_text = '**';
            elseif p_values(i) < 0.05
                sig_text = '*';
            else
                sig_text = 'ns';
            end
            text(i, R2_values(i) + 0.05, sig_text, ...
                'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
        end
    end

    % Formatting
    set(gca, 'XTickLabel', methods, 'FontSize', 10);
    ylabel('R² (Variance Explained)', 'FontSize', 12);
    title('PLS Performance: Single vs Multi-Connection', 'FontSize', 14, 'FontWeight', 'bold');
    ylim([0, max(R2_values) * 1.2]);
    grid on;
    box on;

    % Add legend
    text(0.02, 0.98, sprintf('* p < .05\n** p < .01\n*** p < .001\nns = not significant'), ...
        'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 9, ...
        'BackgroundColor', 'w', 'EdgeColor', 'k');

    % Save figure
    saveas(fig2, [figures_path, 'FigS_PLS_Performance_Comparison.png']);
    saveas(fig2, [figures_path, 'FigS_PLS_Performance_Comparison.fig']);
    fprintf('  Saved: FigS_PLS_Performance_Comparison.png\n');
else
    close(fig2);
    fprintf('  Skipped: Missing required results\n');
end

%% ========================================================================
%  FIGURE 3: CROSS-VALIDATION RESULTS
%  ========================================================================

fprintf('Creating Figure 3: Cross-validation...\n');

fig3 = figure('Position', [100, 100, 1000, 400], 'Color', 'w');

if has_cv_results
    % Panel A: R² across CV methods
    subplot(1, 2, 1);
    methods_cv = {'In-sample', 'LOOCV', '5-Fold', '10-Fold', 'Bootstrap\nOOB', 'Optimism\nCorrected'};
    R2_cv = [cv_results.R2_insample, cv_results.R2_loocv, cv_results.R2_5fold, ...
             cv_results.R2_10fold, cv_results.R2_boot_test_mean, cv_results.R2_corrected];

    b = barh(R2_cv);
    b.FaceColor = 'flat';
    b.CData(1,:) = [0.7, 0.7, 0.7];  % In-sample (gray)
    b.CData(2:end,:) = repmat(color_full, length(R2_cv)-1, 1);  % CV methods (blue)

    set(gca, 'YTick', 1:length(methods_cv), 'YTickLabel', methods_cv, 'FontSize', 10);
    xlabel('R² (Variance Explained)', 'FontSize', 12);
    title('A. R² Across CV Methods', 'FontSize', 14, 'FontWeight', 'bold');
    xlim([0, max(R2_cv) * 1.1]);
    grid on;

    % Add values on bars
    for i = 1:length(R2_cv)
        text(R2_cv(i) + 0.02, i, sprintf('%.3f', R2_cv(i)), ...
            'VerticalAlignment', 'middle', 'FontSize', 9);
    end

    % Panel B: Shrinkage from in-sample
    subplot(1, 2, 2);
    shrinkage = (cv_results.R2_insample - R2_cv(2:end)) ./ cv_results.R2_insample * 100;
    b = barh(shrinkage);
    b.FaceColor = color_partial;

    set(gca, 'YTick', 1:length(shrinkage), 'YTickLabel', methods_cv(2:end), 'FontSize', 10);
    xlabel('Shrinkage (%)', 'FontSize', 12);
    title('B. Optimism/Shrinkage', 'FontSize', 14, 'FontWeight', 'bold');
    xlim([0, max(shrinkage) * 1.1]);
    grid on;

    % Add values
    for i = 1:length(shrinkage)
        text(shrinkage(i) + 2, i, sprintf('%.1f%%', shrinkage(i)), ...
            'VerticalAlignment', 'middle', 'FontSize', 9);
    end

    % Save figure
    saveas(fig3, [figures_path, 'FigS_CrossValidation_Results.png']);
    saveas(fig3, [figures_path, 'FigS_CrossValidation_Results.fig']);
    fprintf('  Saved: FigS_CrossValidation_Results.png\n');
else
    close(fig3);
    fprintf('  Skipped: CV results not available\n');
end

%% ========================================================================
%  FIGURE 4: NETWORK VISUALIZATION (SIMPLIFIED)
%  ========================================================================

fprintf('Creating Figure 4: Network visualization...\n');

fig4 = figure('Position', [100, 100, 600, 600], 'Color', 'w');

% Define ROI positions (infant brain layout)
nodes = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
pos = [1, 3; 2, 3; 3, 3;  % Frontal
       1, 2; 2, 2; 3, 2;  % Central
       1, 1; 2, 1; 3, 1]; % Parietal

% Plot nodes (infant)
hold on;
for i = 1:9
    scatter(pos(i,1), pos(i,2) + 0.5, 400, color_full, 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    text(pos(i,1), pos(i,2) + 0.5, nodes{i}, 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'w');
end

% Plot nodes (adult) - mirror above
for i = 1:9
    scatter(pos(i,1), pos(i,2) + 4, 400, color_partial, 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    text(pos(i,1), pos(i,2) + 4, nodes{i}, 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'w');
end

% Highlight the significant connection: Adult Fz (node 2) → Infant F4 (node 3)
adult_fz = [pos(2,1), pos(2,2) + 4];
infant_f4 = [pos(3,1), pos(3,2) + 0.5];

% Draw arrow
arrow_x = [adult_fz(1), infant_f4(1)];
arrow_y = [adult_fz(2), infant_f4(2)];
annotation('arrow', ...
    (arrow_x - 0.5) / 3.5 + 0.15, ...
    (arrow_y - 0.5) / 5.5 + 0.15, ...
    'Color', 'r', 'LineWidth', 3, 'HeadLength', 12, 'HeadWidth', 12);

% Add text
text(2, 3, 'Significant AI Connection', 'HorizontalAlignment', 'center', ...
    'FontSize', 12, 'FontWeight', 'bold', 'Color', 'r');
text(2, 2.7, 'Fz→F4 (Alpha)', 'HorizontalAlignment', 'center', ...
    'FontSize', 10, 'Color', 'r');

% Formatting
text(2, 5.5, 'Adult', 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
text(2, 0, 'Infant', 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');

xlim([0.5, 3.5]);
ylim([0, 6]);
axis off;
axis equal;

% Save figure
saveas(fig4, [figures_path, 'FigS_Network_Visualization.png']);
saveas(fig4, [figures_path, 'FigS_Network_Visualization.fig']);
fprintf('  Saved: FigS_Network_Visualization.png\n');

%% ========================================================================
%  COMBINED SUPPLEMENTARY FIGURE
%  ========================================================================

fprintf('Creating Combined Supplementary Figure...\n');

fig_combined = figure('Position', [50, 50, 1400, 1000], 'Color', 'w');

% Panel A: Connection vs Learning
subplot(2, 3, 1);
hold on;
c1_idx = Condition == 1;
valid = ~isnan(sig_connection) & ~isnan(Learning);
scatter(sig_connection(c1_idx & valid), Learning(c1_idx & valid), ...
    60, color_full, 'filled', 'MarkerFaceAlpha', 0.6);
p = polyfit(sig_connection(valid), Learning(valid), 1);
x_fit = linspace(min(sig_connection(valid)), max(sig_connection(valid)), 100);
y_fit = polyval(p, x_fit);
plot(x_fit, y_fit, 'k--', 'LineWidth', 1.5);
if has_corr_results
    text(0.05, 0.95, sprintf('r = %.3f, p = %.3f', results.learning.r_overall, results.learning.p_overall), ...
        'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 9, ...
        'BackgroundColor', 'w', 'EdgeColor', 'k');
end
xlabel('AI Connection Strength', 'FontSize', 11);
ylabel('Learning Score', 'FontSize', 11);
title('A. Connection vs Learning', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;

% Panel B: Connection vs Attention
subplot(2, 3, 2);
hold on;
valid = ~isnan(sig_connection) & ~isnan(Attention);
scatter(sig_connection(c1_idx & valid), Attention(c1_idx & valid), ...
    60, color_full, 'filled', 'MarkerFaceAlpha', 0.6);
p = polyfit(sig_connection(valid), Attention(valid), 1);
x_fit = linspace(min(sig_connection(valid)), max(sig_connection(valid)), 100);
y_fit = polyval(p, x_fit);
plot(x_fit, y_fit, 'k--', 'LineWidth', 1.5);
if has_corr_results
    text(0.05, 0.95, sprintf('r = %.3f, p = %.3f', results.attention.r_overall, results.attention.p_overall), ...
        'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 9, ...
        'BackgroundColor', 'w', 'EdgeColor', 'k');
end
xlabel('AI Connection Strength', 'FontSize', 11);
ylabel('Attention Proportion', 'FontSize', 11);
title('B. Connection vs Attention', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;

% Panel C: PLS Observed vs Predicted
subplot(2, 3, 3);
hold on;
if has_cv_results
    scatter(cv_results.Y_actual, cv_results.Y_pred_loocv, ...
        60, color_full, 'filled', 'MarkerFaceAlpha', 0.6);
    lims = [min([cv_results.Y_actual; cv_results.Y_pred_loocv]), ...
            max([cv_results.Y_actual; cv_results.Y_pred_loocv])];
    plot(lims, lims, 'k--', 'LineWidth', 1.5);
    text(0.05, 0.95, sprintf('R² = %.3f\np = %.3f', cv_results.R2_loocv, cv_results.p_value_permutation), ...
        'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 9, ...
        'BackgroundColor', 'w', 'EdgeColor', 'k');
    xlabel('Observed Learning', 'FontSize', 11);
    ylabel('Predicted (LOOCV)', 'FontSize', 11);
    title('C. PLS Prediction', 'FontSize', 12, 'FontWeight', 'bold');
    grid on; box on; axis equal;
end

% Panel D: PLS Performance
subplot(2, 3, 4);
if has_corr_results && has_cv_results
    methods = {'Single\n(Full)', 'Single\n(All)', 'Multi\n(In)', 'Multi\n(CV)'};
    R2_values = [results.pls.R2_full_gaze, results.pls.R2_all_cond, ...
                 cv_results.R2_insample, cv_results.R2_loocv];
    b = bar(R2_values, 'FaceColor', 'flat');
    b.CData = [color_full; color_full; color_partial; color_partial];
    set(gca, 'XTickLabel', methods, 'FontSize', 9);
    ylabel('R²', 'FontSize', 11);
    title('D. PLS Performance', 'FontSize', 12, 'FontWeight', 'bold');
    ylim([0, max(R2_values) * 1.2]);
    grid on; box on;
end

% Panel E: CV R² Comparison
subplot(2, 3, 5);
if has_cv_results
    methods_cv = {'In-sample', 'LOOCV', '5-Fold', '10-Fold', 'Bootstrap', 'Corrected'};
    R2_cv = [cv_results.R2_insample, cv_results.R2_loocv, cv_results.R2_5fold, ...
             cv_results.R2_10fold, cv_results.R2_boot_test_mean, cv_results.R2_corrected];
    b = barh(R2_cv);
    b.FaceColor = 'flat';
    b.CData(1,:) = [0.7, 0.7, 0.7];
    b.CData(2:end,:) = repmat(color_full, length(R2_cv)-1, 1);
    set(gca, 'YTick', 1:length(methods_cv), 'YTickLabel', methods_cv, 'FontSize', 9);
    xlabel('R²', 'FontSize', 11);
    title('E. Cross-Validation', 'FontSize', 12, 'FontWeight', 'bold');
    xlim([0, max(R2_cv) * 1.1]);
    grid on;
end

% Panel F: Network diagram (simplified text version)
subplot(2, 3, 6);
axis off;
text(0.5, 0.8, 'F. Significant Connection', 'HorizontalAlignment', 'center', ...
    'FontSize', 12, 'FontWeight', 'bold');
text(0.5, 0.6, 'Adult Fz → Infant F4', 'HorizontalAlignment', 'center', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Color', 'r');
text(0.5, 0.4, 'Alpha Band (8-12 Hz)', 'HorizontalAlignment', 'center', ...
    'FontSize', 11);
text(0.5, 0.2, sprintf('Full > Partial/No Gaze\n(Sup S4)'), 'HorizontalAlignment', 'center', ...
    'FontSize', 10);

% Overall title
sgtitle('Supplementary Figure: GPDC-Behavior Relationships', 'FontSize', 16, 'FontWeight', 'bold');

% Save combined figure
saveas(fig_combined, [figures_path, 'FigS_GPDC_Behavior_COMBINED.png']);
saveas(fig_combined, [figures_path, 'FigS_GPDC_Behavior_COMBINED.fig']);
saveas(fig_combined, [figures_path, 'FigS_GPDC_Behavior_COMBINED.pdf']);
fprintf('  Saved: FigS_GPDC_Behavior_COMBINED (png/fig/pdf)\n');

%% Summary
fprintf('\n');
fprintf('========================================================================\n');
fprintf('FIGURE GENERATION COMPLETE\n');
fprintf('========================================================================\n\n');

fprintf('Figures saved to: %s\n\n', figures_path);
fprintf('Individual figures:\n');
fprintf('  1. FigS_GPDC_Behavior_Scatterplots.png\n');
fprintf('  2. FigS_PLS_Performance_Comparison.png\n');
fprintf('  3. FigS_CrossValidation_Results.png\n');
fprintf('  4. FigS_Network_Visualization.png\n\n');

fprintf('Combined figure:\n');
fprintf('  ✅ FigS_GPDC_Behavior_COMBINED.png\n');
fprintf('  ✅ FigS_GPDC_Behavior_COMBINED.fig (editable)\n');
fprintf('  ✅ FigS_GPDC_Behavior_COMBINED.pdf (publication-ready)\n\n');

fprintf('USAGE NOTES:\n');
fprintf('  - Use .png for manuscript submission\n');
fprintf('  - Use .pdf for high-resolution printing\n');
fprintf('  - Use .fig to edit in MATLAB\n\n');

fprintf('========================================================================\n\n');
