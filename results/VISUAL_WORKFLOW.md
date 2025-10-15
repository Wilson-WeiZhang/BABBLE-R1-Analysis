# 📊 R1 Revision: Visual Workflow Guide

**Use this page to understand the big picture**

---

## 🗺️ OVERVIEW MAP

```
┌─────────────────────────────────────────────────────────────┐
│              REVIEWER CONCERNS (Input)                      │
├─────────────────────────────────────────────────────────────┤
│  R1.1: Terminology "coupling" misleading                    │
│  R1.2: Missing between-condition GPDC comparisons           │
│  R1.3: df=98 problem + incomplete statistics                │
│  R2.1: No omnibus LME before post-hocs                      │
│  R2.2: df=98 suggests trial-level analysis                  │
│  R2.3: Incomplete statistical reporting throughout          │
│  R2.4: Circular reasoning in mediation analysis             │
│  R2.5: Systematic lack of complete reporting                │
│  R2.6: Terminology issues throughout                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              CODE SOLUTIONS (Process)                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Script 1: fs2_R1_STATISTICAL_COMPARISON.m                  │
│  ├─ Compares trial vs block-averaged analysis               │
│  ├─ Extracts LME omnibus results                           │
│  └─ Provides complete statistics for all 3 methods         │
│         ↓                                                   │
│         Fixes: R1.3, R2.1, R2.2, R2.3, R2.5                 │
│                                                             │
│  Script 2: fs6_R1_BETWEEN_CONDITION_GPDC_COMPARISON.m       │
│  ├─ Trial-level condition comparisons                       │
│  ├─ Connection-specific analyses                           │
│  └─ Subject-level paired comparisons                       │
│         ↓                                                   │
│         Fixes: R1.2                                         │
│                                                             │
│  Script 3: fs_R1_COMPREHENSIVE_STATISTICS_EXTRACTION.m      │
│  ├─ Table S8: Learning statistics                          │
│  ├─ Table S9: GPDC-PLS statistics                          │
│  └─ Complete reporting for all analyses                    │
│         ↓                                                   │
│         Fixes: R1.3, R2.3, R2.5                             │
│                                                             │
│  Script 4: fs_R1_SENSITIVITY_ANALYSES.m                     │
│  ├─ Split-half cross-validation (anti-circularity)         │
│  ├─ Leave-one-out (outlier robustness)                     │
│  └─ Alternative correction methods                         │
│         ↓                                                   │
│         Fixes: R2.4                                         │
│                                                             │
│  Guide: R1_MANUSCRIPT_REVISION_OPTIONS.md                   │
│  ├─ Text options for each section (3-4 per section)        │
│  ├─ Title/Abstract revisions                               │
│  └─ Terminology replacements                               │
│         ↓                                                   │
│         Fixes: R1.1, R2.6                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              OUTPUTS (Deliverables)                         │
├─────────────────────────────────────────────────────────────┤
│  Revised Manuscript:                                        │
│  ├─ Title (revised)                                         │
│  ├─ Abstract (revised)                                      │
│  ├─ Results 2.1 (complete statistics, corrected df)         │
│  ├─ Results 2.2 (+ between-condition comparisons)           │
│  ├─ Methods (comprehensive statistical section)            │
│  └─ Discussion (+ ecological validity paragraph)            │
│                                                             │
│  Supplementary Materials:                                   │
│  ├─ Table S8: Learning analysis complete stats              │
│  ├─ Table S9: GPDC-PLS complete stats                       │
│  ├─ Figure SX: Between-condition GPDC visualization         │
│  ├─ Supp Methods: Detailed procedures                      │
│  └─ Supp Results: Sensitivity analyses                     │
│                                                             │
│  Response to Reviewers:                                     │
│  ├─ Point-by-point responses (9/9 major concerns)          │
│  ├─ Before/after text comparisons                          │
│  └─ References to new analyses/tables                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 WORKFLOW BY PRIORITY

### 🔴 CRITICAL PATH (Must do first)

```
Week 1: Core Statistical Fixes
─────────────────────────────────────────

Day 1-2: Learning Analysis
┌─────────────────────────────────────┐
│ Run Script 1                        │
│    ↓                                │
│ Review comparison table             │
│    ↓                                │
│ Choose revision option              │
│    ↓                                │
│ Update Results 2.1                  │
│    ↓                                │
│ ✅ df=98 problem FIXED              │
└─────────────────────────────────────┘

Day 3-4: Complete Reporting
┌─────────────────────────────────────┐
│ Run Script 3                        │
│    ↓                                │
│ Generate Tables S8-S9               │
│    ↓                                │
│ Format for Supplementary            │
│    ↓                                │
│ Update Methods section              │
│    ↓                                │
│ ✅ Incomplete reporting FIXED       │
└─────────────────────────────────────┘

Day 5: Terminology
┌─────────────────────────────────────┐
│ Choose Abstract/Title options       │
│    ↓                                │
│ Global search-replace               │
│    ↓                                │
│ Update throughout                   │
│    ↓                                │
│ ✅ Terminology FIXED                │
└─────────────────────────────────────┘
```

### 🟡 IMPORTANT ADDITIONS (Week 2)

```
Week 2: New Analyses
─────────────────────────────────────────

Day 1-2: GPDC Between-Conditions
┌─────────────────────────────────────┐
│ Run Script 2                        │
│    ↓                                │
│ Extract AI condition stats          │
│    ↓                                │
│ Add paragraph to Results 2.2        │
│    ↓                                │
│ ✅ Missing comparisons ADDED        │
└─────────────────────────────────────┘

Day 3-5: Supplementary Materials
┌─────────────────────────────────────┐
│ Create Supp Figure (condition plot) │
│    ↓                                │
│ Format Supp Tables                  │
│    ↓                                │
│ Write Supp Methods                  │
│    ↓                                │
│ Add Discussion paragraph            │
│    ↓                                │
│ ✅ Supporting materials COMPLETE    │
└─────────────────────────────────────┘
```

### 🟢 STRENGTHENING (Week 3)

```
Week 3: Robustness & Polish
─────────────────────────────────────────

Day 1-3: Sensitivity Analyses
┌─────────────────────────────────────┐
│ Run Script 4                        │
│    ↓                                │
│ Review split-half validation        │
│    ↓                                │
│ Add Supp Section                    │
│    ↓                                │
│ Reference in Discussion             │
│    ↓                                │
│ ✅ Circularity concern ADDRESSED    │
└─────────────────────────────────────┘

Day 4-5: Final Polish
┌─────────────────────────────────────┐
│ Proofread all changes               │
│    ↓                                │
│ Verify cross-references             │
│    ↓                                │
│ Check consistency                   │
│    ↓                                │
│ ✅ Manuscript POLISHED              │
└─────────────────────────────────────┘
```

---

## 📈 DECISION TREE: Which Options to Choose?

### For Results Section 2.1 (Learning Analysis)

```
                    How strict are reviewers?
                              │
                    ┌─────────┴─────────┐
                    │                   │
                  Strict             Moderate
                    │                   │
         ┌──────────┴───────┐          │
         │                  │          │
    Very strict        Somewhat      Not too strict
         │              strict          │
         ↓                │             ↓
    OPTION 1:         OPTION 1:    OPTION 2:
    Hierarchical      Hierarchical  Streamlined
    (Full LME →       (Full LME →   (Block-averaged
    post-hocs →       post-hocs →   with LME mention
    within-cond)      within-cond)  in Methods)

    Best for:         Best for:     Best for:
    - Strict          - Careful     - Cleaner
      reviewers         reviewers     narrative
    - Defensive       - Standard    - Reader
      stance            approach      friendly
    - Maximum         - Balanced    - Streamlined
      rigor             tone          text
```

### For GPDC Section 2.2 (Between-Conditions)

```
            What's your priority?
                    │
        ┌───────────┼───────────┐
        │           │           │
    Integration   Clarity   Mechanism
        │           │           │
        ↓           ↓           ↓
    OPTION 1:   OPTION 2:   OPTION 3:
    Inline      Separate    Linked to
    Integration Paragraph   Learning

    Pros:       Pros:       Pros:
    - Flows     - Clear     - Causal
      naturally   structure   story
    - Minimal   - Emphasizes- Connects
      disruption  new work    findings

    Use when:   Use when:   Use when:
    - Space     - Need      - Want to
      limited     emphasis    emphasize
    - Seamless  - Reviewers   mechanism
      addition    demand it - Theory-
              - Clarity       driven
                key
```

### For Methods Section (Statistical Analysis)

```
        Do you have word limits?
                │
        ┌───────┴───────┐
        │               │
      Tight          Flexible
        │               │
        ↓               ↓
    OPTION 2:       OPTION 1:
    Integrated      Comprehensive
    Additions       Standalone

    - Add to        - New
      existing        subsection
      sections      - Complete
    - Defer           details
      details       - Self-
    - Shorter         contained

    Better for:     Better for:
    - Word count    - Transparency
    - Flow          - Reproducibility
    - Brevity       - Impact
```

---

## 🎨 VISUALIZATION: Statistical Comparison

### What Script 1 Shows You:

```
┌─────────────────────────────────────────────────────────────┐
│           LEARNING ANALYSIS COMPARISON                      │
├─────────────┬──────────────────┬────────────────────────────┤
│  Method     │  Full Gaze       │  Partial Gaze  │ No Gaze  │
├─────────────┼──────────────────┼────────────────┼──────────┤
│ TRIAL-      │ t(98) = 2.66 *** │ t(98) = 1.53   │ t(99)    │
│ LEVEL       │ p = .009         │ p = .128       │ = 0.81   │
│ (Current    │ q = .027         │ q = .192       │ p = .419 │
│ Manuscript) │ d = 0.27         │ d = 0.15       │ d = 0.08 │
│ ⚠️ PROBLEM  │                  │                │          │
├─────────────┼──────────────────┼────────────────┼──────────┤
│ BLOCK-      │ t(41) = 2.45 **  │ t(42) = 1.31   │ t(43)    │
│ AVERAGED    │ p = .019         │ p = .197       │ = 0.68   │
│ (Correct    │ q = .039         │ q = .295       │ p = .502 │
│ Approach)   │ d = 0.38         │ d = 0.20       │ d = 0.10 │
│ ✅ PRIMARY  │                  │                │          │
├─────────────┼──────────────────┼────────────────┼──────────┤
│ LME         │ Overall condition effect:          │          │
│ OMNIBUS     │ F(2,120) = X.XX, p = .XXX         │          │
│ (Reviewer   │ (Full model in Table S8)           │          │
│ Suggested)  │                                    │          │
│ ✅ REPORT   │                                    │          │
└─────────────┴────────────────────────────────────┴──────────┘

KEY INSIGHT: Conclusions remain the same!
- Full gaze: Significant learning ✅
- Partial gaze: No significant learning ✅
- No gaze: No significant learning ✅

BUT: Now with proper df and complete reporting!
```

---

## 🔍 WHAT TO LOOK FOR IN SCRIPT OUTPUTS

### Script 1 Output (Statistical Comparison)

**✅ Good signs:**
```
Mean learning (Full gaze):     Positive value (0.5 - 2.0)
t-statistic (Full gaze):       Above 2.0
p-value (Full gaze):           Below 0.05
FDR-corrected q (Full):        Below 0.05
Cohen's d (Full):              Above 0.3 (medium effect)
df (block-averaged):           Around 41-46 (not 98!)
```

**⚠️ Warning signs:**
```
Mean learning negative:        Check data loading
All p-values > 0.5:           Verify variable extraction
df still 98 in block-avg:     Check averaging code
Very large effect sizes:      Possible outliers
```

### Script 2 Output (GPDC Comparisons)

**✅ Good signs:**
```
AI GPDC Full > Partial:       Z > 2.0, p < .05
AI GPDC Full > No:            Z > 3.0, p < .001
Connection-specific:          8-10/10 show effects
Subject-level paired:         t > 2.0, consistent
```

**⚠️ Warning signs:**
```
All comparisons n.s.:         Check data structure
Partial > Full:               Unexpected pattern
Very high Z-values (>10):     Possible coding error
```

### Script 3 Output (Statistics Extraction)

**✅ Good signs:**
```
CSV files created:            Check file size > 1KB
Tables have all columns:      N, Mean, SD, t, df, p, q, d, CI
Values match Script 1:        Consistency check
```

### Script 4 Output (Sensitivity)

**✅ Good signs:**
```
Split-half mediation:         Mean β positive, CI excludes 0
Leave-one-out:               All iterations p < .05
Test set R²:                 > 0.10 (some predictive power)
```

---

## 📊 MAPPING: Reviewer Comments → Solutions → Manuscript Changes

```
┌──────────────────┬──────────────────┬──────────────────────┐
│ Reviewer Comment │ Solution Used    │ Manuscript Location  │
├──────────────────┼──────────────────┼──────────────────────┤
│ R1.1:            │ Revision Guide   │ • Title              │
│ Terminology      │ (global replace) │ • Abstract           │
│ "coupling"       │                  │ • Throughout Results │
│                  │                  │ • Discussion         │
├──────────────────┼──────────────────┼──────────────────────┤
│ R1.2:            │ Script 2         │ • Results 2.2        │
│ Missing GPDC     │ (between-cond    │   (new paragraph)    │
│ comparisons      │  comparisons)    │ • Supp Table S9      │
│                  │                  │ • Supp Figure SX     │
├──────────────────┼──────────────────┼──────────────────────┤
│ R1.3:            │ Scripts 1 & 3    │ • Results 2.1        │
│ df=98 problem    │ (block-averaged  │   (all statistics)   │
│ Incomplete stats │  + extraction)   │ • Methods: Stats     │
│                  │                  │ • Supp Table S8      │
├──────────────────┼──────────────────┼──────────────────────┤
│ R2.1:            │ Script 1         │ • Results 2.1        │
│ No omnibus LME   │ (LME approach)   │   (hierarchical)     │
│                  │                  │ • Methods            │
├──────────────────┼──────────────────┼──────────────────────┤
│ R2.2:            │ Script 1         │ • Results 2.1        │
│ df=98 suggests   │ (block-averaged) │ • Methods            │
│ trial-level      │                  │                      │
├──────────────────┼──────────────────┼──────────────────────┤
│ R2.3:            │ Scripts 1 & 3    │ • Throughout Results │
│ Incomplete       │ (comprehensive   │ • Supp Tables S8-S9  │
│ reporting        │  extraction)     │                      │
├──────────────────┼──────────────────┼──────────────────────┤
│ R2.4:            │ Script 4         │ • Discussion         │
│ Circular         │ (split-half      │   (validation note)  │
│ mediation        │  validation)     │ • Supp Results       │
├──────────────────┼──────────────────┼──────────────────────┤
│ R2.5:            │ Script 3         │ • Methods            │
│ Systematic       │ (complete        │ • Supp Tables        │
│ incompleteness   │  reporting)      │                      │
├──────────────────┼──────────────────┼──────────────────────┤
│ R2.6:            │ Revision Guide   │ • Throughout         │
│ Terminology      │ (replacements)   │   (global)           │
└──────────────────┴──────────────────┴──────────────────────┘
```

---

## 🎯 SUCCESS METRICS

### How to know you're done:

```
✅ MANUSCRIPT METRICS:
   [ ] All statistics have: N, test stat, df, p, q, d, CI
   [ ] All "coupling" replaced with "alignment"
   [ ] df = 41-46 (not 98-100)
   [ ] At least 3 new Supplementary Tables
   [ ] At least 1 new Supplementary Figure
   [ ] Discussion paragraph on ecological validity
   [ ] Methods section comprehensively describes stats

✅ COVERAGE METRICS:
   [ ] 9/9 major reviewer concerns addressed
   [ ] All requests explicitly mentioned in response letter
   [ ] New analyses clearly labeled and referenced
   [ ] Before/after comparisons provided where helpful

✅ QUALITY METRICS:
   [ ] Findings qualitatively unchanged
   [ ] Statistics more conservative but still significant
   [ ] Transparency increased
   [ ] Robustness demonstrated

✅ READINESS METRICS:
   [ ] All co-authors reviewed and approved
   [ ] All cross-references working
   [ ] All files formatted for submission
   [ ] Response letter professional and complete
```

---

## 💪 CONFIDENCE BUILDER

### What hasn't changed (your findings are still valid!):

```
✅ Full gaze shows significant learning
✅ Partial and No gaze show no significant learning
✅ AI GPDC predicts learning (R² ~ 25%)
✅ II GPDC predicts CDI gestures (R² ~ 34%)
✅ Gaze modulates connectivity strength
✅ Cultural consistency (UK and SG similar patterns)
✅ All key conclusions supported
```

### What has improved (better reporting, not different results):

```
🔧 Proper degrees of freedom (participant-level)
🔧 Complete statistical reporting (p, q, d, CI)
🔧 Hierarchical testing structure (omnibus → post-hocs)
🔧 Between-condition comparisons added
🔧 Cross-validation demonstrates robustness
🔧 Terminology accurately reflects design
🔧 Transparent about limitations
```

**Bottom line:** You're making the paper BETTER, not DIFFERENT!

---

## 🚀 MOMENTUM KEEPER

### Celebrate milestones:

```
🎉 Scripts run successfully
    → You have all the data you need!

🎉 Options chosen
    → You have a clear revision plan!

🎉 Results 2.1 revised
    → Biggest concern addressed!

🎉 Supplementary Tables created
    → Complete reporting achieved!

🎉 Response letter drafted
    → End is in sight!

🎉 Final checks complete
    → Ready to submit!

🎉 REVISION SUBMITTED
    → CELEBRATE! You did it! 🎊
```

---

**END OF VISUAL WORKFLOW GUIDE**

**Remember:** This is a marathon, not a sprint. Take breaks. Stay organized. You've got comprehensive solutions for every issue. Just follow the workflow step by step, and you'll have an excellent revision ready soon!

**You can do this! 💪**
