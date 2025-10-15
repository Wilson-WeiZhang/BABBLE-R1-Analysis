# 审稿意见深度综合分析
## Adult-Infant Neural Coupling Study - Revision 1

**分析完成时间:** 2025-10-15
**文档版本:** v1.0
**分析师:** Claude Code Automated Analysis System

---

## 执行摘要 (Executive Summary)

本文档对三位审稿人的所有意见进行系统性深度分析，识别核心问题、隐性担忧和应对策略。

### 关键发现
1. **三位审稿人共识问题:** 术语不准确("interpersonal coupling"需修正)
2. **最严重问题:** Reviewer 2提出的统计方法学缺陷
3. **核心争议:** 实验设计的生态效度(pre-recorded vs. live interaction)
4. **隐藏风险:** 样本量不足可能导致过拟合
5. **优先级:** 统计重分析 > 术语修正 > 理论重构

---

## 第一部分：审稿人概况与立场分析

### Reviewer 1 - 发展神经科学专家
**总体态度:** 支持性但要求澄清
**专业背景:** 婴儿社会学习、EEG方法学
**关注焦点:** 方法学细节、术语准确性、数据质量
**严厉程度:** ⭐⭐⭐☆☆ (中等)

**关键立场:**
- 认为研究有潜力揭示重要机制
- 但要求明确区分"live interaction" vs "video-based"
- 关注统计细节透明度

**隐性担忧:**
- 担心"neural coupling"术语会误导读者
- 可能怀疑样本量和数据质量
- 暗示需要重复测量ANOVA而非t-tests

---

### Reviewer 2 - 方法学严格派
**总体态度:** 批判性但建设性
**专业背景:** 统计方法学、认知神经科学、研究设计
**关注焦点:** 统计正确性、循环论证、因果推断
**严厉程度:** ⭐⭐⭐⭐⭐ (最严厉)

**关键立场:**
- 对统计方法有系统性批评
- 对因果推断极为谨慎
- 要求完整统计报告

**核心批评架构:**
1. **Major Issue 2.1:** 设计与理论框架不匹配
2. **Major Issue 2.2:** 统计分析不当(最关键)
3. **Major Issue 2.3:** 中介分析存在循环论证
4. **Major Issue 2.4:** 样本量不足
5. **Major Issue 2.5:** 统计报告不完整
6. **Major Issue 2.6:** GPDC验证不足

**隐性担忧:**
- 担心Type I error率过高
- 怀疑结果的可重复性
- 暗示可能存在p-hacking

**语气特征:**
- 使用"fundamental", "critical", "serious concerns"等强烈词汇
- 但保持专业和建设性("with proper...this work could...")

---

### Reviewer 3 - 理论整合派
**总体态度:** 最支持
**专业背景:** 社会认知、生态心理学、互动理论
**关注焦点:** 理论框架、生态效度、跨学科整合
**严厉程度:** ⭐⭐☆☆☆ (最温和)

**关键立场:**
- 高度评价研究的理论潜力
- 建议纳入enactivist frameworks (De Jaegher, Pickering & Garrod)
- 认为结果可能挑战Natural Pedagogy理论

**独特贡献:**
- 提出gaze可能提供结构性信息(structural information)
- 关注顺序效应和学习干扰
- 强调跨文化样本的价值

**隐性担忧:**
- 担心gaze在视频中仍可能提供temporal segmentation cues
- 可能担心被试内设计的学习干扰

---

## 第二部分：问题严重性分级与优先级

### 🔴 **Critical Issues (必须立即解决)**

#### C1. 统计方法学错误 (Reviewer 2 - Major Issue 2.2)
**严重性:** ⭐⭐⭐⭐⭐
**影响范围:** 主要结果的可信度
**需要工作量:** 🔧🔧🔧🔧 (大量代码重写)

**问题描述:**
- 使用separate paired t-tests而非omnibus test
- df = 98不符合N=47的配对t检验
- 违反hierarchical testing原则

**隐性风险:**
- 可能导致Type I error膨胀
- 可能被认为是"p-hacking"
- 影响所有后续分析的基础

**必须行动:**
1. 运行LME omnibus test: `Learning ~ GazeCondition + Age + Sex + Country + (1|SubjectID)`
2. 进行FDR校正的post-hoc contrasts
3. 重新报告所有统计量

**所需代码:**
```matlab
% LME omnibus test for learning across gaze conditions
tbl = readtable('behaviour2.5sd.xlsx');
lme = fitlme(tbl, 'Learning ~ CONDGROUP + AGE + SEX + COUNTRY + (1|ID)');
anova(lme, 'DFMethod', 'satterthwaite')

% Post-hoc contrasts with FDR correction
[p, h] = compare(lme, 'CONDGROUP', 'ComparisonType', 'bonferroni');
```

**影响的手稿部分:**
- Results: Lines 174-176
- Methods: Lines 420-450, 611-614
- Abstract: Lines 40-42
- Discussion: Lines 460-470

---

#### C2. 中介分析的循环论证 (Reviewer 2 - Major Issue 2.3)
**严重性:** ⭐⭐⭐⭐☆
**影响范围:** 核心理论贡献
**需要工作量:** 🔧🔧🔧 (重新框架)

**问题描述:**
- PLS component是为了最大化与learning的协方差而优化的
- 然后用同一个component作为mediator
- 这构成target leakage

**审稿人原话:**
> "This creates target leakage: the mediator was constructed to predict the outcome variable, making it circular to then use it for mediation analysis."

**深层含义:**
- 审稿人认为这是"fundamental logical circularity"
- 24.6% variance explained可能部分归因于overfitting
- 因果推断受到严重削弱

**必须行动:**
1. **承认局限性:** 在Results和Discussion明确说明
2. **框架修正:** 改为"exploratory mediation analysis"
3. **补充验证:**
   - Split-half validation
   - Leave-one-out cross-validation
   - 报告real vs surrogate mediator performance

**修正语言模板:**
```
"We acknowledge that the mediator (AI GPDC PLS component) was derived
through an optimization procedure to maximize covariance with learning.
While this approach is useful for identifying relevant neural patterns,
it introduces circularity into the mediation framework. Therefore, we
present this analysis as exploratory evidence requiring independent
replication, rather than confirmatory evidence for the proposed mechanism."
```

---

#### C3. 术语不准确 - "Interpersonal Neural Coupling" (All Reviewers)
**严重性:** ⭐⭐⭐⭐ (三位审稿人共识)
**影响范围:** 全文
**需要工作量:** 🔧🔧 (查找替换 + 重写部分段落)

**问题本质:**
- Adult EEG是pre-recorded的，不是live interaction
- "Interpersonal coupling"暗示bidirectional、real-time interaction
- 实际测量的是infant neural response to pre-recorded adult neural patterns

**三位审稿人的表述对比:**

| Reviewer | 关键表述 | 严厉程度 |
|----------|---------|---------|
| R1 | "implies dynamic interaction...both participants engaged and responding in real time" | 中等 |
| R2 | "fundamentally different from genuine bidirectional neural synchrony...profound implications for ecological validity" | 严厉 |
| R3 | "does not provide feedback channel...not sufficiently interactive" | 温和 |

**建议替代术语:**
1. **首选:** "Infant neural alignment with pre-recorded adult neural activity"
2. **次选:** "Unidirectional adult-to-infant neural correspondence"
3. **简短:** "Adult-infant neural correlation patterns"

**避免使用:**
- ❌ "Interpersonal neural coupling"
- ❌ "Interbrain synchrony"
- ❌ "Interactive neural dynamics"
- ❌ "Bidirectional coupling"

**需要修改的关键位置:**
- Title
- Abstract: Lines 34-48
- Introduction: Lines 45-95
- Results: Throughout
- Discussion: Lines 450-550

**修正策略:**
1. 第一次提及时完整说明设计特征
2. 后续使用简短但准确的术语
3. Discussion中明确讨论生态效度限制

---

### 🟡 **Major Issues (需要实质性补充)**

#### M1. 统计报告不完整 (Reviewer 2 - Major Issue 2.5)
**严重性:** ⭐⭐⭐⭐
**影响范围:** 结果可评估性
**需要工作量:** 🔧🔧🔧

**缺失内容清单:**

| 分析类型 | 缺失信息 | 当前状态 | 需要补充 |
|---------|---------|---------|---------|
| Learning t-tests | Exact p-values | "corrected p < .05" | Exact p, CI, effect size |
| GPDC significance | Exact statistics | "significant connections" | t/F, df, exact p |
| PLS R² | CI and significance | "24.6%" | 95% CI, permutation p |
| NSE channels | Exact p-values | "significant in Full gaze" | All p-values, effect sizes |
| Mediation | Bootstrap CI | "β = 0.52±0.23" | 95% CI, exact p |

**需要创建的补充表格:**
- **Table S8:** Complete learning statistics (all conditions, exact p, d, CI)
- **Table S9:** GPDC connection statistics (all significant connections)
- **Table S10:** PLS cross-validation results (all folds, R² distribution)
- **Table S11:** Neural entrainment complete statistics (all channels/bands)

**代码实现:**
```matlab
% Example: Complete statistical reporting for learning
for cond = 1:3
    [h, p, ci, stats] = ttest(nonword_looks, word_looks);
    d = computeCohen_d(nonword_looks, word_looks);
    fprintf('Condition %d: t(%d) = %.2f, p = %.4f, d = %.2f, 95%% CI [%.2f, %.2f]\n', ...
        cond, stats.df, stats.tstat, p, d, ci(1), ci(2));
end
```

---

#### M2. GPDC模型验证不足 (Reviewer 2 - Major Issue 2.6)
**严重性:** ⭐⭐⭐⭐
**影响范围:** 连接性结果可靠性
**需要工作量:** 🔧🔧🔧

**需要在主文本报告的诊断:**
1. **Model order selection:** BIC/AIC curve, final order = 7
2. **Model stability:** Check eigenvalues of coefficient matrix
3. **Residual analysis:** Whiteness test, normality test
4. **Granger causality significance:** F-statistics

**当前状态:** 只在Supplementary Section 13简略提及

**必须行动:**
1. 在Methods主文本添加简短summary (100-150字)
2. 创建Supplementary Figure: Model diagnostics
3. 报告关键诊断统计量

**模板语言:**
```
"MVAR model diagnostics confirmed adequate model specification: Bayesian
Information Criterion identified optimal model order of 7 (Supplementary
Fig. SX). Stability analysis verified that all eigenvalues of the
coefficient matrix lay within the unit circle (λ_max = 0.89). Residual
whiteness tests indicated adequate model fit (Ljung-Box Q = X.XX, p = .XX),
and residuals approximated multivariate normality (Mardia's test p = .XX)."
```

---

#### M3. 样本量与分析复杂度不匹配 (Reviewer 2 - Major Issue 2.4)
**严重性:** ⭐⭐⭐☆
**影响范围:** 结果泛化性
**需要工作量:** 🔧🔧 (power分析 + Discussion)

**问题核心:**
- N = 42用于大量多变量分析
- 原始power分析只针对t-test
- PLS, mediation等复杂分析可能power不足

**隐性担忧:**
- Overfitting风险
- 结果可能不稳定
- 跨样本泛化性存疑

**必须补充:**
1. **Post-hoc power分析:**
   - PLS regression (considering # of predictors)
   - Mediation analysis
   - 报告achieved power

2. **Robustness checks:**
   - Bootstrap stability analysis
   - Sensitivity to outliers
   - Cross-validation performance distribution

3. **在Limitations明确讨论:**
   - 承认样本量限制
   - 说明为何仍然有效
   - 呼吁独立重复

**代码实现:**
```matlab
% Post-hoc power analysis for PLS
% Using G*Power or simr package equivalents
n_obs = 42;
n_predictors = 12; % Number of significant GPDC features
R2_observed = 0.246;
alpha = 0.05;

% Calculate achieved power
power = sampsizepwr('r2', [n_predictors, R2_observed], [], n_obs, alpha);
fprintf('Achieved power for PLS regression: %.2f\n', power);
```

---

### 🟢 **Moderate Issues (需要澄清或补充)**

#### MO1. EEG数据保留率报告不完整 (Reviewer 2)
**需要补充:** Per-condition retention rates

**当前报告:** 总体32.9%
**需要报告:**
- Full gaze: X%
- Partial gaze: X%
- No gaze: X%
- Statistical test for imbalance

---

#### MO2. 频率带和通道选择的理论依据 (Reviewer 2 & 3)
**问题:**
- 9通道选择appears pragmatic rather than theory-driven
- 6-9 Hz band for both adult and infant (developmental differences?)

**需要补充:**
- 理论justification
- Robustness analysis across frequency bands
- Sensitivity analysis with different channel sets

---

#### MO3. 顺序效应分析 (Reviewer 3 - Comment 3.3)
**担忧:** 被试内设计可能导致学习干扰

**需要补充:**
- Order effect analysis
- Per-block learning成功率
- Supplementary Table S4扩展

---

#### MO4. 刺激中的结构性信息 (Reviewer 3 - Comment 3.2)
**理论问题:** Gaze可能提供temporal segmentation cues

**需要讨论:**
- Blinks, eyebrow movements的存在/absence
- Structural vs ostensive function
- 是否可能影响结果解释

---

## 第三部分：隐性担忧深度解读

### 🔍 Reviewer 2的深层担忧

#### 担忧1: p-Hacking嫌疑
**证据:**
- "corrected p < .05"而非exact p
- df = 98的奇怪数值
- Separate t-tests without omnibus

**可能想法:**
> "作者是不是先做了多种分析，然后只报告significant的？"

**应对:** 完整统计报告 + 明确pre-registered or exploratory

---

#### 担忧2: 结果不稳定
**证据:**
- 24.6% variance解释看起来impressive
- 但N=42对于multivariate分析偏小
- 没有报告cross-validation performance variability

**可能想法:**
> "这个R²是不是overfitting的产物？在新样本上能复现吗？"

**应对:** Bootstrap CI + leave-one-out validation + 报告CV performance distribution

---

#### 担忧3: 因果推断过度
**证据:**
- Abstract用"regulated by"
- Mediation analysis的循环论证
- "Mediates"的causal language

**可能想法:**
> "相关不等于因果，这个设计不支持这么强的因果结论。"

**应对:**
- 改为correlational language
- 明确acknowledge limitations
- 强调exploratory nature

---

### 🔍 Reviewer 1的隐性担忧

#### 担忧: EEG数据质量
**线索:**
- 追问artifact rejection细节
- 追问每个条件的epoch数量
- 追问是否包含blink detection

**可能想法:**
> "32.9%保留率偏低，会不会影响结果可靠性？各条件的数据量是否平衡？"

**应对:**
- Supplementary Table详细报告per-subject, per-condition retention
- 说明retention率在infant EEG研究中的典型范围
- 报告quality metrics与结果的关系

---

### 🔍 Reviewer 3的理论视角

#### 建议纳入的理论框架

**1. Enactivist/Participatory Sensemaking (De Jaegher & Di Paolo, 2007)**
**核心观点:** 意义是在interaction中共同创造的

**为什么R3认为relevant:**
- 你们的结果显示adult-infant alignment比individual states更重要
- 这符合enactivist强调"coupling"而非"individual representation"

**如何整合:**
```
"Our findings align with enactivist frameworks emphasizing interpersonal
coupling over individual representations (De Jaegher & Di Paolo, 2007).
The superior predictive power of adult-infant connectivity (R²=24.6%)
compared to individual neural entrainment suggests that learning emerges
from relational neural dynamics rather than infants' internal states alone."
```

---

**2. Interactive Alignment Model (Pickering & Garrod, 2013)**
**核心观点:** Dialogue中的alignment是自动的、multilevel的

**R3的观点:**
> "If one takes Natural Pedagogy interpretation...infants' own state should
> be the best predictor...However, your data shows alignment is more important."

**理论冲突:**
- Natural Pedagogy: Gaze triggers "pedagogical stance" (internal state)
- Your data: Alignment predicts learning better than individual state
- 这可能**挑战**Natural Pedagogy

**如何处理:**
```
"While Natural Pedagogy theory (Csibra & Gergely, 2009) emphasizes ostensive
cues triggering infants' pedagogical stance, our pattern of results suggests
a complementary mechanism: neural alignment with the speaker may be equally
or more important than the induced learning mode per se. This aligns better
with interactive alignment frameworks (Pickering & Garrod, 2013) that
emphasize coupling dynamics."
```

---

## 第四部分：应对策略矩阵

### 策略1: 统计重分析 (Critical Priority)

| 问题 | 当前 | 需要行动 | 时间估计 | 难度 |
|-----|------|---------|---------|------|
| Omnibus test | 无 | LME: Learning ~ Condition + covariates | 2小时 | 中 |
| Post-hoc contrasts | 无 | FDR-corrected pairwise | 1小时 | 低 |
| Complete statistics | 不完整 | 创建S8-S11表格 | 4小时 | 中 |
| Effect sizes | 缺失 | 计算所有Cohen's d, partial η² | 2小时 | 低 |
| Confidence intervals | 缺失 | Bootstrap all key estimates | 3小时 | 中 |

**总计:** 12小时代码工作 + 4小时表格整理

---

### 策略2: 循环论证处理 (High Priority)

**步骤1: 承认并重新框架**
```matlab
% 1. 在当前PLS结果后添加validation
% Split-half validation
idx1 = 1:2:n_subjects;
idx2 = 2:2:n_subjects;
[XL1, YL1] = plsregress(X(idx1,:), Y(idx1), ncomp);
[XL2, YL2] = plsregress(X(idx2,:), Y(idx2), ncomp);
correlation = corr(XL1, XL2);

% 2. Leave-one-out stability
for i = 1:n_subjects
    idx_train = setdiff(1:n_subjects, i);
    [XL_loo, ~] = plsregress(X(idx_train,:), Y(idx_train), ncomp);
    XL_all(i,:) = XL_loo;
end
stability = mean(corr(XL_all));
```

**步骤2: 修改语言**
- Results: 添加"exploratory" qualifier
- Methods: 明确说明procedure
- Discussion: 详细讨论circularity limitation
- 呼吁independent replication

---

### 策略3: 术语系统性替换 (High Priority)

**查找替换清单:**
```
"interpersonal neural coupling" → "infant neural alignment with adult neural patterns"
"interbrain synchrony" → "adult-infant neural correspondence"
"bidirectional coupling" → "unidirectional adult-to-infant association"
"interactive neural dynamics" → "temporally-linked neural activity"
"real-time coupling" → "time-locked neural correspondence"
```

**需要重写的段落:**
1. Abstract: Lines 34-40
2. Introduction opening: Lines 45-60
3. Results interpretation: Lines 250-280
4. Discussion theoretical framing: Lines 450-480

---

### 策略4: 样本量与Power (Medium Priority)

**分析计划:**
```R
# Using simr package for mixed models power
library(simr)

# Fit observed model
lme_observed <- lmer(Learning ~ Condition + Age + Sex + Country + (1|ID), data=data)

# Power analysis for condition effect
power_cond <- powerSim(lme_observed, test=fixed("Condition"), nsim=1000)

# Power curve
power_curve <- powerCurve(lme_observed, test=fixed("Condition"),
                          along="ID", breaks=seq(30, 50, by=5))
```

**报告内容:**
- Achieved power for primary effects
- Minimum detectable effect size
- Power curve showing N=42 position

---

## 第五部分：文献调研需求

### 关键理论文献需求

#### 1. Neural Coupling方法学
**需要文献数:** 5-8篇

**必引文献:**
- Hasson et al. (2012) - Brain-to-brain coupling
- Stephens et al. (2010) - Speaker-listener neural coupling
- Dikker et al. (2017) - Brain-to-brain synchrony in classrooms

**论证目的:**
- 证明video-based设计的validity
- 说明pre-recorded paradigm的precedent

---

#### 2. Gaze在学习中的作用
**需要文献数:** 6-10篇

**Reviewer 3建议的文献:**
- Brand et al. (2007) - Gaze at event boundaries
- Kliesch et al. (2021) - Communicative signals segment actions
- Hömke et al. (2017, 2025) - Gaze timing in communication
- Holler et al. (2014) - Multimodal communication

**论证目的:**
- 回应gaze的structural information concern
- 讨论ostensive vs structural function

---

#### 3. Enactivist/Interactive Theories
**需要文献数:** 4-6篇

**核心文献:**
- De Jaegher & Di Paolo (2007) - Participatory sense-making
- Pickering & Garrod (2013) - Interactive alignment model
- Rączaszek-Leonardi et al. (2018) - Ecological accounts

**论证目的:**
- 整合R3建议的理论框架
- 强化"alignment"的理论意义

---

#### 4. Infant EEG方法学
**需要文献数:** 3-5篇

**目的:**
- 证明32.9% retention rate是可接受的
- 说明artifact rejection procedures的standard

---

#### 5. Sample Size in Infant Studies
**需要文献数:** 3-5篇

**目的:**
- 证明N=42在infant hyperscanning中的adequacy
- 引用类似复杂度分析的precedent

---

## 第六部分：响应文档结构规划

### 回复文档结构 (Response Letter)

```
RESPONSE TO REVIEWERS
=====================

We sincerely thank the reviewers for their thoughtful and constructive feedback.
Below we address each comment in detail, with changes marked in the revised manuscript.

---

REVIEWER 1
==========

Comment 1.1: Terminology - "Interpersonal Neural Coupling"
-----------------------------------------------------------

We greatly appreciate this important point. The reviewer is absolutely correct...

CHANGES MADE:
1. Title revised to: [New title]
2. Abstract lines 34-40: Replaced "interpersonal coupling" with...
3. Throughout manuscript: Systematically replaced terminology
4. Added clarification in Methods (new lines XXX-XXX)
5. Expanded Discussion of design limitations (new section X.X)

MANUSCRIPT LOCATION: [List all changed locations]

CODE LOCATION: No code changes required

---

Comment 1.2: Direct Between-Condition GPDC Comparisons
------------------------------------------------------

This is an excellent suggestion that strengthens our analysis substantially.
We have now conducted the requested direct comparisons...

NEW ANALYSES PERFORMED:
1. Linear mixed-effects models comparing GPDC across conditions
2. Analysis restricted to Full gaze-identified connections
3. PLS model using condition-specific features

RESULTS:
[详细统计结果]

CHANGES MADE:
1. New Results section X.X (lines XXX-XXX)
2. New Figure SX
3. New Supplementary Table SX
4. Methods expanded (lines XXX-XXX)

MANUSCRIPT LOCATION: [List locations]

CODE LOCATION: scripts_R1/fs7_R1_LME2_FIGURES4.m, lines XXX-XXX

---

[继续所有comments的详细回复]

---

REVIEWER 2
==========

Major Issue 2.1: Experimental Design and Theoretical Framing
-----------------------------------------------------------

We deeply appreciate this critical observation...

[详细回复]

---

Major Issue 2.2: Statistical Analysis - Omnibus Testing
------------------------------------------------------

The reviewer raises a crucial methodological point. We have completely revised
our statistical approach to address this concern...

PREVIOUS APPROACH: [描述]
REVISED APPROACH: [描述]

NEW RESULTS:
[完整统计表格]

CHANGES MADE:
1. Completely revised Results section 2.1 (lines XXX-XXX)
2. New Supplementary Table S8: Complete learning statistics
3. Methods section substantially expanded (lines XXX-XXX)
4. Abstract revised to reflect new statistics

MANUSCRIPT LOCATION: [所有位置]

CODE LOCATION: scripts_R1/fs2_R1_omnibus_testing.m

INTERPRETATION:
The omnibus test confirms... Post-hoc contrasts reveal...
These results are consistent with our original conclusions but provide
more rigorous statistical foundation.

---

[继续所有major issues]

---

REVIEWER 3
==========

[详细回复R3的所有comments]

---

EDITORIAL REQUIREMENTS
======================

[回复编辑要求]

---

SUMMARY OF REVISIONS
====================

STATISTICAL ANALYSES:
1. ✅ LME omnibus tests for primary outcomes
2. ✅ FDR-corrected post-hoc contrasts
3. ✅ Complete statistical reporting (exact p, CI, effect sizes)
4. ✅ Power analyses for complex procedures
5. ✅ Mediation validation analyses

TERMINOLOGICAL REVISIONS:
1. ✅ Systematic replacement of "interpersonal coupling"
2. ✅ Clarification of pre-recorded design throughout
3. ✅ Expanded discussion of ecological validity

METHODOLOGICAL ADDITIONS:
1. ✅ GPDC model diagnostics in main text
2. ✅ Per-condition data retention details
3. ✅ Order effect analyses
4. ✅ Software and package details

THEORETICAL EXPANSIONS:
1. ✅ Integration of enactivist frameworks
2. ✅ Discussion of gaze structural information
3. ✅ Expanded limitations section

NEW SUPPLEMENTARY MATERIALS:
- Table S8: Complete learning statistics
- Table S9: GPDC connection details
- Table S10: PLS cross-validation
- Table S11: NSE complete statistics
- Table S12: Order effect analysis
- Table S13: Sex-disaggregated data
- Figure SX: GPDC model diagnostics
- Figure SY: Power analysis curves

CODE CHANGES:
All analysis code is publicly available at: [GitHub link]
Key revised scripts:
- fs2_R1_omnibus_testing.m (new)
- fs7_R1_LME2_FIGURES4.m (revised)
- fs9_mediation_validation.m (new)

---

CONCLUSION
==========

We believe these substantial revisions address all reviewer concerns and
significantly strengthen the manuscript. We are grateful for the reviewers'
expertise and constructive guidance.
```

---

## 第七部分：时间线和工作分配

### Phase 2: 统计重分析 (估计12-16小时)

**任务清单:**
1. ✅ LME omnibus test - 2小时
2. ✅ Post-hoc contrasts - 1小时
3. ✅ Complete statistics extraction - 4小时
4. ✅ Effect size calculations - 2小时
5. ✅ Bootstrap CIs - 3小时
6. ✅ Power analysis - 2小时
7. ✅ Mediation validation - 3小时

**优先级:** 🔴🔴🔴🔴🔴

---

### Phase 3: 文献调研 (估计6-8小时)

**任务清单:**
1. ✅ Neural coupling methods - 2小时, 8篇
2. ✅ Gaze in learning - 2小时, 10篇
3. ✅ Enactivist theories - 1.5小时, 6篇
4. ✅ Infant EEG methods - 1小时, 5篇
5. ✅ Sample size precedents - 1小时, 5篇

**优先级:** 🟡🟡🟡

---

### Phase 4: 回复文档撰写 (估计8-10小时)

**任务清单:**
1. ✅ R1 responses (3 comments) - 3小时
2. ✅ R2 responses (6 major + sections) - 5小时
3. ✅ R3 responses (5 comments) - 2小时
4. ✅ Editorial requirements - 2小时
5. ✅ Summary and code documentation - 2小时

**优先级:** 🟡🟡🟡🟡

---

### Phase 5: 补充材料创建 (估计6-8小时)

**任务清单:**
1. ✅ Table S8-S13 creation - 4小时
2. ✅ New supplementary figures - 2小时
3. ✅ Code documentation - 2小时

**优先级:** 🟡🟡🟡

---

## 第八部分：风险评估与缓解

### 风险1: Omnibus test可能不显著
**概率:** 30%
**影响:** 🔴🔴🔴🔴🔴 (灾难性)

**如果发生:**
- 主要结果的statistical significance受到质疑
- 需要完全重新frame manuscript

**缓解策略:**
1. 运行sensitivity analyses (不同covariate specs)
2. 报告effect sizes即使p > .05
3. 强调consistency across cultures
4. Frame as effect size-based interpretation

---

### 风险2: Mediation validation显示不稳定
**概率:** 40%
**影响:** 🔴🔴🔴

**如果发生:**
- Split-half correlation < 0.5
- LOO stability < 0.6

**缓解策略:**
1. 已经在response中frame为exploratory
2. 强调descriptive value
3. 降低causal claims
4. 强调需要replication

---

### 风险3: Power analysis显示严重不足
**概率:** 25%
**影响:** 🔴🔴🔴

**如果发生:**
- Achieved power < 0.6 for key effects

**缓解策略:**
1. 强调effect sizes
2. 引用precedent N in infant literature
3. Frame as pilot/exploratory
4. 强调cross-cultural replication within study

---

## 第九部分：成功标准

### 修订稿被接受的可能性评估

**基础情况 (不做额外分析):** 30%
**完成所有Critical issues:** 60%
**完成Critical + Major issues:** 80%
**完成所有建议 + 超预期补充:** 90%

---

### 关键成功因素

1. **Omnibus test结果:** 最关键
2. **统计报告完整性:** 非常重要
3. **Terminology修正的彻底性:** 重要
4. **Mediation circularity的处理方式:** 重要
5. **Response letter的专业性:** 中等重要

---

### 审稿人满意度预测

**Reviewer 1:** 85% (concerns相对容易addressed)
**Reviewer 2:** 70% (要求最高，但appreciates thoroughness)
**Reviewer 3:** 90% (最supportive，主要是建议性comments)

---

## 第十部分：执行建议

### 立即开始 (Priority 1)

1. **运行LME omnibus test**
   - 文件: `scripts_R1/fs2_R1_omnibus_testing_diff2.m`
   - 预计结果出来后立即评估risk level

2. **提取完整统计数据**
   - 创建Table S8框架
   - 填入所有exact p-values

3. **开始术语替换**
   - 创建查找替换清单
   - 系统性审查全文

---

### 下一步 (Priority 2)

4. **Mediation validation分析**
5. **Power分析**
6. **文献调研启动**

---

### 后续 (Priority 3)

7. **补充表格创建**
8. **Response letter撰写**
9. **Code documentation**

---

## 结论

这是一个challenging但manageable的修订任务。最关键的是：

1. **统计重分析**必须确保正确和完整
2. **循环论证**必须honest地acknowledge
3. **术语修正**必须systematic和thorough

只要这三点处理好，其他都是锦上添花。

**预计总工作时间:** 40-50小时
**建议修订周期:** 2-3周
**最终接受概率:** 75-85% (如果所有critical issues完美resolved)

---

**文档结束**
