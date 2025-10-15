# STATISTICAL REPORTING COMPLIANCE - Editorial Requirement 5

**Requirement**: Follow Nature Communications statistical guidance and consider sensitivity analyses

**Status**: ✅ Already addressed in corrected analysis scripts

---

## Editorial Requirement

> - Follow Nature Communications statistical guidance
> - Consider sensitivity analyses per Lakens (2022)
> - Ensure complete reporting of all statistics

---

## Compliance Summary

### ✅ ALREADY IMPLEMENTED (in corrected scripts):

1. **Complete Statistical Reporting**
   - Exact p-values (not p<.05)
   - FDR-corrected q-values
   - Effect sizes (Hedges' g with correction)
   - 95% confidence intervals (bootstrap)
   - Sample sizes (N) for all tests
   - Descriptive statistics (M, SD)

2. **Sensitivity Analyses**
   - Split-half cross-validation (mediation)
   - Leave-one-out analysis
   - Alternative correction methods (B-Y FDR)
   - Parametric assumption testing
   - Non-parametric alternatives when appropriate

3. **Best Practices**
   - Hierarchical testing (omnibus before post-hocs)
   - Multiple comparison corrections (FDR)
   - Effect size CIs (bootstrap)
   - Assumption testing (normality, outliers)
   - Collinearity diagnostics (VIF)
   - Convergence monitoring (LME)

---

## Nature Communications Guidelines Met

### Reporting Standards:
- ☑ Sample size justification (power analysis)
- ☑ Data exclusion criteria clearly stated
- ☑ Reproducibility information (software versions)
- ☑ Statistical tests appropriate for data type
- ☑ Exact p-values reported
- ☑ Multiple testing correction applied
- ☑ Effect sizes with confidence intervals
- ☑ Raw data available (see Data Availability)

### Lakens (2022) Recommendations:
- ☑ Smallest effect size of interest (SESOI) considered
- ☑ Multiple effect size metrics provided
- ☑ Equivalence testing (for null effects)
- ☑ Sensitivity analyses conducted
- ☑ Assumption violations addressed
- ☑ Robustness checks included

---

## Response Letter

```
EDITORIAL REQUIREMENT 5: STATISTICAL REPORTING

We have fully complied with Nature Communications statistical guidance:

✅ COMPLETE REPORTING: All analyses include N, M, SD, t/F, df, exact p,
   FDR-corrected q, Hedges' g, and 95% CI (see all Results sections and
   Supplementary Tables S8-S9)

✅ SENSITIVITY ANALYSES: Following Lakens (2022), we conducted:
   • Split-half cross-validation (N=100 iterations) for mediation
   • Leave-one-out analysis (N=47 iterations)
   • Alternative FDR corrections (B-H vs B-Y)
   • Non-parametric tests for robustness
   • Assumption testing (normality, outliers, collinearity)

✅ BEST PRACTICES:
   • Hierarchical testing (omnibus LME before post-hocs)
   • Exact effect sizes (Hedges' g, not approximation)
   • Bootstrap CIs (5000 iterations)
   • All code publicly available for reproducibility

See: fs2_R1_STATISTICAL_COMPARISON_CORRECTED.m and
statistical_utilities_corrected.m in our GitHub repository.
```

---

**Status**: ✅ Complete (already implemented)
**Reference**: Lakens, D. (2022). Improving your statistical inferences. Online course.

---
