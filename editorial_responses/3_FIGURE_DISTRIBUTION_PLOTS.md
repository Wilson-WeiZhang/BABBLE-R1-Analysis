# FIGURE REPLACEMENT - Distribution Plots - Editorial Requirement 3

**Requirement**: Replace bar graphs with distribution plots showing individual data points

**Status**: ✅ Ready to implement

---

## Editorial Requirement

> "Replace bar graphs with distribution plots"
> - Show all data points for n<10
> - Use box-and-whisker or violin plots for larger samples
> - Include measures of centrality, dispersion, error bars

---

## Figures to Update

### Figure 2: Learning Results
**Current**: Bar graph with error bars
**Required**: Violin plot + individual points + box-and-whisker overlay

**MATLAB Code**:
```matlab
figure;
conditions = {'Full Gaze', 'Partial Gaze', 'No Gaze'};
data = {learning_full, learning_partial, learning_none};
colors = [0.2 0.6 0.8; 0.4 0.7 0.5; 0.8 0.5 0.3];

for i = 1:3
    % Violin plot (distribution)
    violin_h = violinplot(data{i}, i, 'Width', 0.3, ...
        'ViolinColor', colors(i,:), 'ViolinAlpha', 0.3);

    % Box plot overlay
    boxplot(data{i}, 'positions', i, 'widths', 0.15, ...
        'colors', colors(i,:)*0.6, 'Symbol', '');

    % Individual data points (jittered)
    x_jitter = i + 0.1*randn(length(data{i}),1);
    scatter(x_jitter, data{i}, 30, colors(i,:), 'filled', ...
        'MarkerFaceAlpha', 0.6, 'MarkerEdgeColor', 'k', ...
        'MarkerEdgeAlpha', 0.3, 'LineWidth', 0.5);

    % Mean (horizontal line)
    plot([i-0.2, i+0.2], [mean(data{i}), mean(data{i})], ...
        'k-', 'LineWidth', 2);
end

set(gca, 'XTick', 1:3, 'XTickLabel', conditions);
ylabel('Learning Score (proportion)');
ylim([-0.3, 0.4]);
box off; grid on; grid minor;
```

### Figure 3: GPDC Connectivity
**Current**: Heatmap only
**Required**: Add distribution plot panel showing individual GPDC values

### Figure 5: Neural Entrainment
**Current**: Topoplots + bar graph
**Required**: Replace bar with violin plot

---

## Implementation Checklist

- [ ] Figure 2: Replace bar graph with violin + box + points
- [ ] Figure 3: Add panel B with GPDC distribution
- [ ] Figure 5: Replace bar graph with violin plot
- [ ] Supplementary Figures: Review all for bar graphs
- [ ] Update figure legends with distribution plot descriptions
- [ ] Ensure all individual data points visible (n=42-47)
- [ ] Add color legend for male/female if showing sex disaggregation

---

## Response Letter Text

```
EDITORIAL REQUIREMENT 3: FIGURE DISTRIBUTION PLOTS

We have replaced all bar graphs with distribution plots as required:

✅ FIGURE 2: Learning results now shown as violin plots with overlaid
   box-and-whisker plots and individual data points (N=42-47 per condition).
   Mean indicated by horizontal black line, median by box center line.

✅ FIGURE 3: Added Panel B showing distribution of GPDC AI connectivity
   values across participants with individual points visible.

✅ FIGURE 5: Neural entrainment bar graph replaced with violin plot
   showing full distribution of cross-correlation magnitudes.

All plots include:
• Full distribution shape (violin)
• Quartiles and median (box-and-whisker)
• Individual participant data points (jittered for visibility)
• Mean (horizontal line) and 95% CI (error bars where applicable)

This enhances transparency by showing complete data distributions rather
than summary statistics alone.
```

---

**Status**: ✅ Ready
**Time**: 2-3 hours to regenerate figures

---
