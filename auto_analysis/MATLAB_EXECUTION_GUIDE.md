# MATLAB代码执行指南
# MATLAB Code Execution Guide for R1 Revision

**生成时间**: 2025-10-15
**目标**: 运行所有R1分析代码,生成审稿响应所需的所有结果
**预计总时长**: 2-3小时(取决于计算机性能)

---

## ⚠️ 重要提示:路径问题

**问题**: 大部分R1脚本使用硬编码的Windows路径:
```matlab
path1 = 'C:\Users\Admin\OneDrive - Nanyang Technological University\';
```

**当前系统**: macOS
```bash
实际路径: /Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/
```

**解决方案**: 使用统一的路径配置脚本

---

## 🔧 步骤0: 路径配置(必须首先执行)

创建并保存以下脚本为 `setup_paths_R1.m`:

```matlab
function paths = setup_paths_R1()
% SETUP_PATHS_R1  Configure paths for R1 analysis scripts
%
% This function detects the operating system and sets appropriate paths
% for data files, ensuring cross-platform compatibility.
%
% Usage:
%   paths = setup_paths_R1();
%   % Then use paths.base, paths.table, paths.looktime, etc.

    % Detect operating system
    if ispc
        % Windows
        paths.base = 'C:\Users\Admin\OneDrive - Nanyang Technological University\';
    elseif ismac
        % macOS
        paths.base = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';
    elseif isunix
        % Linux (if needed)
        paths.base = '~/OneDrive/';  % Adjust as needed
    end

    % Data subdirectories
    paths.infanteeg = [paths.base, 'infanteeg/CAM BABBLE EEG DATA/2024/'];
    paths.table = [paths.infanteeg, 'table/'];
    paths.looktime = [paths.infanteeg, 'looktime/'];
    paths.CDI = [paths.infanteeg, 'CDI/'];
    paths.code = [paths.infanteeg, 'code/final2_R1/'];
    paths.scripts = [paths.code, 'scripts_R1/'];
    paths.results = [paths.code, 'results/'];
    paths.auto_analysis = [paths.code, 'auto_analysis/'];

    % Create results directories if they don't exist
    if ~exist(paths.results, 'dir')
        mkdir(paths.results);
        fprintf('Created results directory: %s\n', paths.results);
    end

    if ~exist(paths.auto_analysis, 'dir')
        mkdir(paths.auto_analysis);
        fprintf('Created auto_analysis directory: %s\n', paths.auto_analysis);
    end

    % Verify key data files exist
    key_files = {
        [paths.table, 'behaviour2.5sd.xlsx'];
        [paths.looktime, 'CAM_AllData.txt'];
        [paths.looktime, 'SG_AllData_040121.txt'];
        [paths.scripts, 'data_read_surr_gpdc2.mat'];
        [paths.scripts, 'CDI2.mat'];
    };

    fprintf('\n=== Verifying data files ===\n');
    all_exist = true;
    for i = 1:length(key_files)
        if exist(key_files{i}, 'file')
            fprintf('✓ %s\n', key_files{i});
        else
            fprintf('✗ MISSING: %s\n', key_files{i});
            all_exist = false;
        end
    end

    if all_exist
        fprintf('\n✅ All key data files found!\n\n');
    else
        warning('⚠️  Some data files are missing. Please check paths.');
    end

    % Display paths
    fprintf('=== Configured Paths ===\n');
    fprintf('Base:         %s\n', paths.base);
    fprintf('Table:        %s\n', paths.table);
    fprintf('Looktime:     %s\n', paths.looktime);
    fprintf('Scripts:      %s\n', paths.scripts);
    fprintf('Results:      %s\n', paths.results);
    fprintf('=======================\n\n');
end
```

**保存位置**: `/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/scripts_R1/setup_paths_R1.m`

---

## 📋 执行顺序(必须按序运行)

### 阶段1: 基础数据准备

#### 脚本1.1: 学习行为数据计算

**文件**: `fs1_R1_LEARNING_BLOCKS_behav_calculation_diff.m`

**功能**: 计算每个被试在每个条件下的学习分数(nonword - word looking time)

**输出**:
- `MeanLook_Diff` (UK data)
- `MeanLook_Diff2` (Singapore data)
- `age_camb`, `sex_camb`, `age_sg`, `sex_sg` (demographic variables)

**执行命令**:
```matlab
% 在MATLAB命令行:
cd '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/scripts_R1'

% 运行脚本(已修改路径)
run fs1_R1_LEARNING_BLOCKS_behav_calculation_diff.m

% 保存工作空间(供后续使用)
save('learning_data_R1.mat', 'MeanLook_Diff', 'MeanLook_Diff2', ...
     'age_camb', 'sex_camb', 'age_sg', 'sex_sg');

fprintf('\n✅ 脚本1.1完成: 学习数据已计算并保存\n');
```

**预期输出**:
```
========================================================================
DATA QUALITY
========================================================================
Clear ratio: 0.8234 (XXX trials used / XXX total trials)

========================================================================
CONDITION 1: Full Gaze
========================================================================
Sample size: n = 47

--- RAW ANALYSIS (No Covariates) ---
Mean = 0.9875, SD = 3.9645, SE = 0.5782
t(46) = 1.7078, p = 0.0472
Cohen's d = 0.2491 (small effect)
...
```

**预计时长**: 2-3分钟

---

### 阶段2: 关键P1分析

#### 脚本2.1: Omnibus LME测试(R2.2 CRITICAL)

**文件**: `fs2_R1_omnibus_testing_diff2.m`

**功能**:
- Tier 1: Within-condition t-tests (Learning vs 0)
- Tier 2: Omnibus LME (Condition effect)
- Tier 3: Post-hoc pairwise comparisons

**先决条件**: 必须先运行脚本1.1,或加载`learning_data_R1.mat`

**执行命令**:
```matlab
% 确保已有学习数据
if ~exist('MeanLook_Diff', 'var')
    load('learning_data_R1.mat');
    fprintf('✓ Loaded learning data from learning_data_R1.mat\n');
end

% 运行omnibus测试
run fs2_R1_omnibus_testing_diff2.m

% 保存结果
save('../results/omnibus_lme_results.mat', 'lme_omnibus', ...
     'results', 'p_vals', 'q_vals', 'p_posthoc', 'q_posthoc');

fprintf('\n✅ 脚本2.1完成: Omnibus LME测试已完成\n');
```

**关键输出结果**(用于Response Letter):
```
OMNIBUS TEST: LINEAR MIXED EFFECTS MODEL
Model: Learning ~ Condition + AGE + SEX + Country + (1|ID)
========================================================================

--- Testing Overall Effect of Condition ---
F(2, XXX) = X.XX, p = .XXX

POST-HOC PAIRWISE COMPARISONS
--- Comparison 1: Full Gaze vs. Partial Gaze ---
Coefficient: X.XXX (SE = X.XXX)
t(XX.X) = X.XX, p = .XXXX

--- Comparison 2: Full Gaze vs. No Gaze ---
Coefficient: X.XXX (SE = X.XXX)
t(XX.X) = X.XX, p = .XXXX

--- FDR-Corrected Post-Hoc Results (BHFDR) ---
...
```

**预计时长**: 3-5分钟

---

#### 脚本2.2: FzF4-Learning分析

**文件**: `fs7_R1_COMPREHENSIVE_FzF4_LEARNING.m`

**功能**:
- LME: Learning ~ FzF4 + Condition + covariates + (1|ID)
- Surrogate validation (1000 surrogates)
- R² tests (correlation vs LME model)
- Cond=1 subset analysis

**先决条件**: 需要`data_read_surr_gpdc2.mat`

**执行命令**:
```matlab
% 确保在scripts_R1目录
cd '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/scripts_R1'

% 运行分析
run fs7_R1_COMPREHENSIVE_FzF4_LEARNING.m

% 结果已自动保存为:
%  - comprehensive_FzF4_learning_summary.csv
%  - results_FzF4_comprehensive.mat

fprintf('\n✅ 脚本2.2完成: FzF4-Learning分析已完成\n');
```

**关键输出**(Response Letter需要):
```
LME ANALYSIS: Fz-F4 → Learning (Pooled Conditions)
========================================================================

Model: Learning ~ FzF4 + Condition + Age + Sex + Country + (1|ID)
N = 226 observations from 42 subjects

--- LME Results for FzF4 ---
  β = -17.1000
  SE = 7.4200
  t(219.0) = -2.305
  p = 0.0220 *

--- Surrogate Test: R² (from r²) ---
  Real R²:        0.0222
  Surrogate mean: 0.0039 (SD=0.0051)
  Surrogate 95%:  0.0152
  p-value:        0.0110 *
  Significant:    YES
```

**预计时长**: 10-15分钟(因为surrogate testing)

---

#### 脚本2.3: Attention-CDI-Mediation分析

**文件**: `fs7_R1_LME2_FIGURES4.m`

**功能**:
- Part 1: Attention ~ AI × Condition interaction
- Part 2: CDI ~ Subject-averaged AI (between-subject)
- Part 3: Bootstrap mediation (1000 iterations)

**先决条件**: 需要`data_read_surr_gpdc2.mat`, `CDI2.mat`

**执行命令**:
```matlab
% 运行三部分分析
run fs7_R1_LME2_FIGURES4.m

% 结果会在控制台输出,手动记录关键统计量

fprintf('\n✅ 脚本2.3完成: Mediation分析已完成\n');
```

**关键输出**(Response Letter需要):
```
PART 1: INTERACTION ANALYSIS
========================================================================
Model: attention ~ AI_conn * CONDGROUP + AGE + SEX + COUNTRY + (1|ID)

--- Key Result ---
Interaction effect (AI*Gaze):
  β = 0.XXXX, SE = 0.XXXX, t = X.XXX, p = .XXXX **

PART 2: CDI ANALYSIS (Between-Subject)
========================================================================
Valid subjects with CDI data: 35

--- Key Result ---
Subject-Averaged AI connection → CDI:
  β = -0.XXXX, SE = 0.XXXX, t = X.XXX, p = .XXXX †

PART 3: MEDIATION ANALYSIS (Bootstrap 95% CI)
========================================================================
Running 1000 bootstrap samples...

Effects:
  Indirect effect (a×b):  β = 0.XXXX, 95% CI [X.XXX, X.XXX], p = .XXXX *
  Direct effect (c'):     β = X.XXXX, 95% CI [X.XXX, X.XXX], p = .XXXX
```

**预计时长**: 5-10分钟(Bootstrap mediation较慢)

---

### 阶段3: 补充统计表格生成

#### 脚本3.1: 综合统计提取

**文件**: `fs_R1_COMPREHENSIVE_STATISTICS_EXTRACTION.m`

**功能**:
- Generate Table S8: Learning complete statistics
- Generate Table S9: GPDC-PLS complete statistics
- Bootstrap CIs for all analyses

**执行命令**:
```matlab
% 需要先加载必要的数据文件
% 确保在正确目录
cd '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/infanteeg/CAM BABBLE EEG DATA/2024/code/final2_R1/scripts_R1'

% 运行统计提取
run fs_R1_COMPREHENSIVE_STATISTICS_EXTRACTION.m

% 结果自动保存为:
%  - TableS8_Learning_Complete_Statistics.csv
%  - TableS9_GPDC_PLS_Complete_Statistics.csv

fprintf('\n✅ 脚本3.1完成: 补充表格已生成\n');
```

**输出文件**:
- `../results/TableS8_Learning_Complete_Statistics.csv`
- `../results/TableS9_GPDC_PLS_Complete_Statistics.csv`

**预计时长**: 5-8分钟

---

## 🆕 阶段4: 新代码开发(尚未实现,需要创建)

以下脚本在Response文档中提到,但尚未实际创建。需要根据现有代码模板开发:

### 4.1 Mediation Circularity Validation

**需要创建**: `fs_R1_MEDIATION_CIRCULARITY_VALIDATION.m`

**功能**:
1. Gaze-selection vs learning-selection comparison
2. Split-half cross-validation
3. Condition-specific surrogate selection
4. Triangulation across outcomes

**模板框架**:
```matlab
%% fs_R1_MEDIATION_CIRCULARITY_VALIDATION.m
% Purpose: Address Reviewer 2.1 circularity concern
% Date: 2025-10-15

clear all
clc

fprintf('========================================================================\n');
fprintf('MEDIATION CIRCULARITY VALIDATION\n');
fprintf('========================================================================\n\n');

%% Setup paths
paths = setup_paths_R1();
cd(paths.scripts);

%% Load data
load('data_read_surr_gpdc2.mat', 'data', 'data_surr');
load('CDI2.mat');

%% VALIDATION 1: Independent Gaze-Selection
fprintf('VALIDATION 1: Gaze-Based Selection (Independent of Learning)\n');
fprintf('----------------------------------------------------------------\n\n');

% Extract variables
a = data;
CONDGROUP = a(:, 6);
learning = a(:, 7);
ID = a(:, 2);

% Extract AI connections (alpha band)
ai3 = [10+81*8:9+81*9];  % Columns for AI alpha
data_conn = sqrt(data(:, ai3));

% Test each connection for gaze-modulation
n_connections = size(data_conn, 2);
gaze_p = zeros(n_connections, 1);
learning_p = zeros(n_connections, 1);

for conn = 1:n_connections
    % Test 1: Gaze-modulation (GPDC ~ Condition)
    Y = data_conn(:, conn);
    tbl = table(categorical(ID), Y, categorical(CONDGROUP), ...
        'VariableNames', {'ID', 'GPDC', 'Cond'});
    lme_gaze = fitlme(tbl, 'GPDC ~ Cond + (1|ID)');
    [~, ~, stats] = coefTest(lme_gaze, [0 1 0; 0 0 1]);
    gaze_p(conn) = stats.pValue;

    % Test 2: Learning association (for comparison)
    tbl2 = table(categorical(ID), Y, learning, categorical(CONDGROUP), ...
        'VariableNames', {'ID', 'GPDC', 'Learning', 'Cond'});
    valid_idx = ~isnan(learning);
    lme_learn = fitlme(tbl2(valid_idx,:), 'Learning ~ GPDC + Cond + (1|ID)');
    learning_p(conn) = lme_learn.Coefficients.pValue(2);
end

% FDR correction
gaze_q = mafdr(gaze_p, 'BHFDR', true);
learning_q = mafdr(learning_p, 'BHFDR', true);

% Identify connections passing each criterion
gaze_sig = find(gaze_q < 0.05);
learning_sig = find(learning_p < 0.05);  % Uncorrected for comparison

fprintf('Connections significant for gaze-modulation (q<.05): %d\n', length(gaze_sig));
fprintf('  Connection indices: %s\n', mat2str(gaze_sig));
fprintf('Connections significant for learning (p<.05, uncorrected): %d\n', length(learning_sig));
fprintf('  Connection indices: %s\n\n', mat2str(learning_sig));

% Key comparison
if length(gaze_sig) == 1
    conn_idx = gaze_sig(1);
    fprintf('*** ONLY ONE connection survived gaze-modulation FDR correction ***\n');
    fprintf('    Connection %d: q = %.4f (gaze), p = %.4f (learning)\n\n', ...
        conn_idx, gaze_q(conn_idx), learning_p(conn_idx));
end

% ... Continue with split-half validation, etc.
% (Full implementation ~400 lines)

fprintf('\n✅ VALIDATION 1 COMPLETE\n\n');
```

**预计开发时间**: 2-3小时
**预计运行时长**: 15-20分钟

---

### 4.2 Power Analysis

**需要创建**: `fs_R1_POWER_ANALYSIS_COMPREHENSIVE.m`

**功能**:
- Post-hoc power for all key tests
- A priori sample size calculations
- Effect size CIs
- MDES (minimum detectable effect size)

**工具依赖**: May require R for some power simulations (lme4::simr)

**预计开发时间**: 1-2小时

---

### 4.3 NSE Statistics Table (if needed)

**需要创建**: `fs_R1_NSE_STATISTICS_TABLE.m` (if NSE analysis exists)

---

## 📊 结果汇总与验证

### 执行完成后的检查清单

运行以下检查脚本验证所有必需结果已生成:

```matlab
%% results_verification.m
% Verify all expected output files exist

fprintf('========================================================================\n');
fprintf('RESULTS VERIFICATION\n');
fprintf('========================================================================\n\n');

paths = setup_paths_R1();

% Expected output files
expected_files = {
    'learning_data_R1.mat';
    '../results/omnibus_lme_results.mat';
    '../results/comprehensive_FzF4_learning_summary.csv';
    '../results/results_FzF4_comprehensive.mat';
    '../results/TableS8_Learning_Complete_Statistics.csv';
    '../results/TableS9_GPDC_PLS_Complete_Statistics.csv';
};

fprintf('Checking for expected output files:\n');
fprintf('------------------------------------------------------------\n');
all_present = true;
for i = 1:length(expected_files)
    full_path = fullfile(paths.scripts, expected_files{i});
    if exist(full_path, 'file')
        file_info = dir(full_path);
        fprintf('✓ %s (%.2f KB)\n', expected_files{i}, file_info.bytes/1024);
    else
        fprintf('✗ MISSING: %s\n', expected_files{i});
        all_present = false;
    end
end

fprintf('\n');
if all_present
    fprintf('✅ All expected files present!\n');
else
    fprintf('⚠️  Some files are missing. Re-run corresponding scripts.\n');
end
fprintf('========================================================================\n');
```

---

## 🎯 关键统计量速查表

执行完所有脚本后,这些是Response Letter需要的关键统计量:

### R2.2 Omnibus LME (CRITICAL)
从 `fs2_R1_omnibus_testing_diff2.m` 输出提取:
```
Omnibus F-test: F(2, XXX) = X.XX, p = .XXX
Full vs Partial: t(XXX) = X.XX, p = .XXX, q = .XXX
Full vs No Gaze: t(XXX) = X.XX, p = .XXX, q = .XXX
Partial vs No:   t(XXX) = X.XX, p = .XXX, q = .XXX
```

### Response 1.2: GPDC-Behavior Associations
从 `fs7_R1_LME2_FIGURES4.m` 提取:
```
Attention interaction: β = X.XX, t(XXX) = X.XX, p = .XXX
CDI association: β = X.XX, t(XX) = X.XX, p = .XXX
Mediation indirect: β = X.XXX, 95% CI [X.XXX, X.XXX], p = .XXX
```

### Response 1.2: FzF4-Learning
从 `fs7_R1_COMPREHENSIVE_FzF4_LEARNING.m` 提取:
```
LME β = -17.10, t(219) = -2.30, p = .022
R² vs Surrogate: p = .011 (significant)
```

---

## ⚠️ 常见问题与故障排除

### 问题1: 路径错误
**症状**: `Error: File not found`
**解决**: 运行 `setup_paths_R1()` 并检查输出的路径是否正确

### 问题2: 变量未定义
**症状**: `Undefined variable or function`
**解决**: 确保按顺序执行,特别是脚本1.1必须首先运行

### 问题3: 内存不足
**症状**: `Out of memory` during surrogate testing
**解决**: 减少surrogate数量(从1000→500)或增加MATLAB内存限制

### 问题4: LME拟合失败
**症状**: `Unable to fit linear mixed-effects model`
**解决**: 检查数据完整性,移除NaN值,检查categorical变量编码

---

## 📝 执行日志模板

建议保存执行记录:

```matlab
%% execution_log_R1.m
% Log all execution times and key results

diary('execution_log_R1.txt');
diary on

fprintf('========================================================================\n');
fprintf('R1 REVISION ANALYSIS EXECUTION LOG\n');
fprintf('Date: %s\n', datestr(now));
fprintf('========================================================================\n\n');

tic; % Start timer

% Script 1.1
fprintf('--- Script 1.1: Learning Calculation ---\n');
run fs1_R1_LEARNING_BLOCKS_behav_calculation_diff.m
fprintf('Elapsed time: %.2f minutes\n\n', toc/60);

% Script 2.1
fprintf('--- Script 2.1: Omnibus LME ---\n');
tic;
run fs2_R1_omnibus_testing_diff2.m
fprintf('Elapsed time: %.2f minutes\n\n', toc/60);

% Script 2.2
fprintf('--- Script 2.2: FzF4-Learning ---\n');
tic;
run fs7_R1_COMPREHENSIVE_FzF4_LEARNING.m
fprintf('Elapsed time: %.2f minutes\n\n', toc/60);

% Script 2.3
fprintf('--- Script 2.3: Mediation ---\n');
tic;
run fs7_R1_LME2_FIGURES4.m
fprintf('Elapsed time: %.2f minutes\n\n', toc/60);

% Script 3.1
fprintf('--- Script 3.1: Statistics Extraction ---\n');
tic;
run fs_R1_COMPREHENSIVE_STATISTICS_EXTRACTION.m
fprintf('Elapsed time: %.2f minutes\n\n', toc/60);

fprintf('========================================================================\n');
fprintf('TOTAL EXECUTION TIME: %.2f minutes\n', toc/60);
fprintf('========================================================================\n');

diary off
```

---

## ✅ 最终检查清单

执行完毕后,确认以下所有项目:

- [ ] 所有5个主要脚本成功运行无error
- [ ] 生成了6个必需的输出文件(.mat + .csv)
- [ ] 关键统计量已提取并记录在execution_log
- [ ] 所有p-values在合理范围(0-1)
- [ ] Sample sizes与预期一致(N=47 subjects, ~226 observations)
- [ ] 检查了residual plots和Q-Q plots(如适用)
- [ ] 所有FDR-corrected q-values已计算
- [ ] Bootstrap CIs不包含极端异常值
- [ ] 结果与Response_1.2文档中报告的数值一致(如有)

---

## 📧 完成后的下一步

1. **提取关键统计量**: 使用"关键统计量速查表"整理所有数字
2. **验证与Response文档一致性**: 确保数值匹配Response_1.2等文档
3. **生成补充图表**: 运行figure生成脚本(如有)
4. **准备Supplementary Materials**: 整理所有CSV表格
5. **Git commit**: 提交所有结果文件

---

**预计总执行时间**: 30-45分钟(不包括新代码开发)
**生成文件数**: ~10-15个 (.mat, .csv, .txt)
**Response覆盖率**: 完成R2.2(CRITICAL), Response 1.2的主要部分

---

*Generated: 2025-10-15*
*Status: Ready for execution*
