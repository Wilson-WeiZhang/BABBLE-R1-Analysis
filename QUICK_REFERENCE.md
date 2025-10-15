# Quick Reference Guide - R1 Code Documentation System

**Created**: 2025-10-09
**Purpose**: Fast orientation to the code-manuscript mapping system

---

## What This Is

This is the R1 (first revision) codebase for a Nature Communications manuscript on adult-infant neural coupling and statistical learning. The code has been comprehensively documented to map every statistical result in the manuscript to exact code locations.

---

## Key Documentation Files

### 📘 MASTER_CODE_MAPPING.md (47KB)
**Use this to**: Find any manuscript result's code location
- Maps all 18 results (10 main + 8 supplementary)
- Complete dependency documentation
- Parameter specifications
- Verification checklist

**Quick search examples**:
- Search "t(98) = 2.66" → Find learning analysis
- Search "R² = 24.6%" → Find AI GPDC → Learning PLS
- Search "Result 2.3" → Find NSE analysis

### 📗 HOW_TO_USE_CODE_MAPPING.md (10KB)
**Use this to**: Learn how to navigate the documentation
- 4 detailed usage scenarios
- Code marking system (`%% R1` tags)
- Q&A for common problems
- Troubleshooting guide

### 📙 SUPPLEMENTARY_CODE_MAP.md (8KB)
**Use this to**: Find supplementary section code
- Sections S1-S7, S11 mapped
- Line-by-line annotations
- Statistical results included

---

## Main Analysis Files

### Core Scripts (Priority Order)

1. **fs1_behav_calculation.m** - START HERE
   - Calculate learning from raw looking time data
   - Output: `behaviour2.5sd.xlsx`
   - Result 2.1.1: Learning in Full gaze (t=2.66, p<.05)

2. **fs2_fig2_behaviouranaylse.m**
   - Behavioral statistics (learning, attention)
   - Result 2.1.1-2.1.2: Gaze effects on learning/attention
   - Figure 1d, Figure 2

3. **fs8_entrain6_conditionsandpermutations_figure5bc.m**
   - NSE (Neural Speech Entrainment) significance testing
   - Result 2.3.1: 5 significant NSE features in Full gaze
   - Figure 5b-c

4. **fs9_f4_newest.m** - MOST COMPLEX
   - PLS regression: GPDC → Learning/CDI
   - Result 2.2.1: AI → Learning (R²=24.6%)
   - Result 2.2.2: II → CDI (R²=33.7%)
   - Result 2.2.3: Double dissociation (t=44.7)
   - Figure 4a-d
   - **Header**: Lines 1-213 (read this first!)

5. **fs9_redof6.m**
   - Mediation analysis: Gaze → AI/NSE → Learning
   - Result 2.4.1: AI mediates (β=0.66, p<.001)
   - Supplementary S5-S7 (NSE features, country effects, mediation)
   - Figure 6

---

## Key Data Files

### Input Files (In Order of Creation)

1. **Raw data** (not in code folder)
   - CAM_AllData.txt (UK looking times)
   - SG_AllData_040121.txt (SG looking times)
   - EEG .set files (preprocessed)

2. **Behavioral data** (from fs1)
   - `behaviour2.5sd.xlsx` (226 trials)
   - Columns: country, ID, age, sex, block, condition, learning, attention

3. **GPDC data** (from fs3_pdc_nosurr_v2.m)
   - `dataGPDC.mat` (226×972 connections)
   - `data_read_surr_gpdc2.mat` (full dataset 226×982)

4. **NSE data** (from fs8_entrain2_surr.m)
   - `ENTRIANSURR.mat` (NSE + 1000 surrogates)

5. **Filtered connections** (from fs5_strongpdc.m)
   - `stronglistfdr5_gpdc_AI.mat` (12 significant AI connections)
   - `stronglistfdr5_gpdc_II.mat` (13 significant II connections)
   - `stronglistfdr5_gpdc_IIdelta.mat` (delta band)
   - `stronglistfdr5_gpdc_IItheta.mat` (theta band)

6. **CDI data**
   - `CDI2.mat` (gesture production scores)

---

## Quick Task Guide

### Task 1: Verify a Statistical Result

1. Open `MASTER_CODE_MAPPING.md`
2. Search for the statistic (e.g., "t(98) = 2.66")
3. Note the file and line numbers
4. Open the code file
5. Search for `%% R1 RESULT` marker
6. Check dependencies listed in header
7. Verify logic matches manuscript

### Task 2: Run an Analysis

1. Check `MASTER_CODE_MAPPING.md` for dependencies
2. Ensure all .mat files exist (see File Dependency Tree section)
3. Read the code header (Lines 1-50 typically)
4. Check KEY PARAMETERS section
5. Run the script
6. Compare output to manuscript values

### Task 3: Switch Frequency Bands (Alpha/Theta/Delta)

1. Open `fs9_f4_newest.m`
2. Read Lines 173-182 for instructions
3. Comment current band's load commands
4. Uncomment target band's load commands
5. Run script
6. **Important**: Only one band active at a time!

### Task 4: Understand Data Flow

See `MASTER_CODE_MAPPING.md` → "File Dependency Tree" section

```
Raw EEG → fs3 → dataGPDC.mat → fs5 → stronglistfdr5 → fs9 → Results
Raw looking → fs1 → behaviour2.5sd.xlsx → fs2, fs9 → Results
EEG + Speech → fs8_entrain1-6 → ENTRIANSURR.mat → fs9 → Results
```

---

## Code Marking System

All important sections marked with `%% R1` tags:

**Result markers**:
```matlab
%% R1 RESULT 2.X.X - [Description]
```

**Figure markers**:
```matlab
%% R1 FIGURE X / TABLE X
```

**Dependency markers**:
```matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REQUIRED INPUT FILES (DEPENDENCIES):
%% 1. file1.mat - Description
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```

**Parameter markers**:
```matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KEY PARAMETERS (DO NOT MODIFY):
%% - param1 = value1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```

---

## Critical Concepts

### GPDC Matrix Structure (226×982)
- Columns 1-10: Demographics (country, ID, age, sex, etc.)
- Columns 11-91: II delta (81 connections)
- Columns 92-172: II theta
- **Columns 173-253: II alpha** ← Main text
- Columns 254-334: II AA transition
- Columns 335-415: AA delta
- Columns 416-496: AA theta
- **Columns 497-577: AA alpha** ← Main text
- Columns 578-658: AA IA transition
- **Columns 659-739: AI alpha** ← Main text
- Columns 740-820: AI theta
- Columns 821-901: AI delta
- Columns 902-982: IA (infant→adult)

### PLS Analysis Pipeline
1. Load GPDC data (226 trials × connections)
2. Apply square-root transform: `sqrt(GPDC)`
3. Select significant connections from `stronglistfdr5`
4. Z-score standardization: `zscore(X)`
5. PLS regression: `[XL,YL,XS,YS,BETA,PCTVAR] = plsregress(X,Y,ncomp)`
6. Bootstrap cross-validation (1000 iterations, 10-fold)
7. Compute R² and significance

### NSE Calculation
1. Band-pass filter EEG (delta/theta/alpha)
2. Compute power envelope
3. Extract speech envelope from audio
4. Cross-correlate with lags 0-400ms
5. Find peak correlation and lag
6. Compare to 1000 surrogates (permutation test)
7. FDR correction (BHFDR)

---

## Common Data Locations

**Behavioral data**:
- Learning: `behaviour2.5sd.xlsx` column 7
- Attention: `behaviour2.5sd.xlsx` column 9
- CDI: `CDI2.mat`

**Neural data**:
- AI alpha GPDC: `data(:,659:739)` from `data_read_surr_gpdc2.mat`
- II alpha GPDC: `data(:,173:253)`
- NSE Delta C3: `data2(:,40)` from `ENTRIANSURR.mat`

**Channel order** (9 channels):
F3, Fz, F4, C3, Cz, C4, P3, Pz, P4

**Connection numbering** (81 total):
- Adult F3 → Infant F3: Connection 1
- Adult F3 → Infant Fz: Connection 2
- ... (9 adult × 9 infant = 81)

---

## Key Parameters (DO NOT MODIFY)

**Behavioral**:
- Outlier threshold: mean + 2.5 SD
- Learning = Nonword looks - Word looks

**GPDC**:
- Model order: 12
- Sampling rate: 200 Hz
- Frequency bands: Delta [1,3], Theta [4,6], Alpha [6,9] Hz
- Transform: `sqrt(GPDC)`

**PLS**:
- Number of components: 10
- Standardization: `zscore()`
- Bootstrap iterations: 1000
- Cross-validation folds: 10

**NSE**:
- Max lag: 400 ms
- Surrogates: 1000 permutations
- FDR correction: BHFDR

---

## Manuscript Results Summary

### Main Results (Section 2)

**2.1 Behavioral** (fs2_fig2_behaviouranaylse.m)
- Learning: Full > Partial/No gaze (t=2.66, p<.05)
- Attention: No gaze differences

**2.2 GPDC → Outcomes** (fs9_f4_newest.m)
- AI → Learning: R²=24.6%, p<.0001
- II → CDI: R²=33.7%, p<.0001
- Double dissociation: t(1998)=44.7, p<.0001

**2.3 NSE** (fs8_entrain6)
- 5 features significant in Full gaze only
- Delta C3, Theta F4/Pz, Alpha C3/Cz

**2.4 Mediation** (fs9_redof6.m)
- AI mediates Gaze→Learning (β=0.66, p<.001)
- NSE does not mediate

### Supplementary Results

**S1**: Individual learning patterns (fs12)
**S2**: Other attention measures (fs2, Lines 422-449)
**S3**: Delta/Theta bands (fs9_f4_newest.m, switch bands)
**S4**: Single connection LME (fs7)
**S5**: Other NSE features (fs9_redof6, Lines 271-295)
**S6**: Country effects (fs9_redof6, Lines 246-267)
**S7**: Alternative mediation models (fs9_redof6, Lines 475-560)
**S11**: Testing phase methods (fs1, header)

---

## Troubleshooting

**"File not found" error**:
→ Check `MASTER_CODE_MAPPING.md` → File Dependency Tree
→ Run source script to regenerate missing .mat file

**"Results don't match manuscript"**:
→ Check header for KEY PARAMETERS
→ Verify .mat file versions (check dates)
→ Ensure correct frequency band is loaded

**"Which frequency band is active?"**:
→ Open `fs9_f4_newest.m`
→ Check Lines 149-230
→ Uncommented load commands show active band

**"How do I find Result X.X.X?"**:
→ Search `MASTER_CODE_MAPPING.md` for "Result X.X.X"
→ Or search for the specific statistic

---

## File Paths

**Base path**: `/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/infanteeg/CAM BABBLE EEG DATA/2024/`

**Code**: `code/final2_R1/scripts/`
**Data**: `table/` (behavioral), `gpdc/` (connectivity), `entrain/` (NSE)
**Docs**: `code/final2_R1/` (all .md files)

---

## Important Notes

### Code Integrity
✅ **Never modify computational logic**
✅ **Only add comments/annotations**
✅ **Results must remain unchanged**

### Verification Checklist
For each result, confirm:
- [ ] Code logic matches manuscript description
- [ ] Statistical values exactly match
- [ ] All dependencies present
- [ ] Parameters match header specifications
- [ ] R1 annotations added

### Data Quality
- 2.28% trials excluded (outlier threshold)
- 226 total trials (99-100 per condition)
- All participants contributed all 3 conditions

---

## Contact & Documentation

**Primary documentation**: `MASTER_CODE_MAPPING.md`
**Usage guide**: `HOW_TO_USE_CODE_MAPPING.md`
**Supplementary**: `SUPPLEMENTARY_CODE_MAP.md`

**Last updated**: 2025-10-09
**Version**: R1 (First Revision)

---

**Quick Start**: Open `MASTER_CODE_MAPPING.md` and search for what you need. Everything is documented there.
