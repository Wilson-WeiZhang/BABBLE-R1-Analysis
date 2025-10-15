# BABBLE Study - Adult-Infant Neural Coupling Analysis
## Final Analysis Code (Revision 1)

**Study:** Adult-infant neural coupling mediates infants' selection of socially-relevant stimuli for learning across cultures

**Authors:** Zhang, Wei et al.
**Journal:** Nature Communications

---

## 📁 Folder Structure

```
final2_R1/
├── README.md (this file)
│
├── scripts/                          # Analysis scripts
│   ├── README_ANALYSIS_PIPELINE.md   # Complete pipeline documentation
│   ├── SCRIPTS_ANNOTATION_SUMMARY.md # Detailed script annotations
│   ├── fs0_*.m                       # Step 0: Data preparation
│   ├── fs1-fs2_*.m                   # Step 1-2: Behavioral analysis
│   ├── fs3_*.m                       # Step 3: GPDC connectivity
│   ├── fs4-fs5_*.m                   # Step 4-5: Significance testing
│   ├── fs6-fs7_*.m                   # Step 6-7: PLS regression
│   ├── fs8_*.m                       # Step 8: Neural entrainment
│   ├── fs9_*.m                       # Step 9: Mediation analysis ⭐
│   ├── fs11-fs12_*.m                 # Additional analyses
│   └── *.m (utilities)               # Helper functions
│
├── archive/                          # Archived versions (fsN_*.m)
│   ├── fs*N_*.m                      # Scripts with N suffix
│   └── *.asv                         # MATLAB backup files
│
├── data/                             # Data files
│   ├── *.mat                         # MATLAB data matrices
│   ├── stronglistfdr5_*.mat         # Significant connections
│   ├── data_read_surr_*.mat         # Surrogate distributions
│   └── learning*.mat, sur*.mat      # Intermediate results
│
├── images/                           # Figure images
│   └── *.tif                         # Generated figures
│
├── documents/                        # Documentation
│   ├── main_NC.txt                   # Main manuscript text
│   ├── Supplementary Materials.txt   # Supplementary materials
│   └── *.xlsx                        # Data tables
│
├── eeg_raw/                          # Raw EEG files
│   └── S0010_*.fdt/.set             # Example EEG data
│
└── surr/                             # Surrogate data folder
    └── (surrogate datasets)
```

---

## 🚀 Quick Start Guide

### Step 1: Read the Documentation
Start with these files in order:
1. `scripts/README_ANALYSIS_PIPELINE.md` - Overview of analysis pipeline
2. `scripts/SCRIPTS_ANNOTATION_SUMMARY.md` - Detailed script descriptions

### Step 2: Understand the Analysis Flow

```
Data Preparation (fs0)
    ↓
Behavioral Analysis (fs1-fs2) → Figure 1-2
    ↓
GPDC Connectivity (fs3) → Figure 3
    ↓
Significance Testing (fs4-fs5)
    ↓
PLS Regression (fs6-fs7) → Figure 4, Supp Fig S3-S4
    ↓
Neural Entrainment (fs8) → Figure 5, Supp Fig S5
    ↓
Mediation Analysis (fs9) → Figure 6 ⭐ MAIN RESULT
    ↓
Individual Differences (fs12) → Supp Fig S1
```

### Step 3: Key Results by Figure

| Figure | Script | Finding |
|--------|--------|---------|
| **Fig 1d** | fs1 | Learning only in Full gaze (t=2.66, p<.05) |
| **Fig 2** | fs2 | Attention ≠ Learning dissociation |
| **Fig 3** | fs3, fs5 | GPDC networks (AA, II, AI significant) |
| **Fig 4** | fs7 | AI→Learning (R²=24.6%), II→CDI (R²=33.7%) |
| **Fig 5** | fs8 | NSE gaze-sensitive, not predictive |
| **Fig 6** | fs9 | **AI mediates gaze→learning** (β=0.52, p<.01) |
| **Supp S1** | fs12 | 38.3% Full gaze advantage |
| **Supp S3** | fs7 | Delta/theta band results |
| **Supp S4** | fs7 | Fz→F4 gaze modulation |
| **Supp S5** | fs8 | NSE doesn't predict learning |

---

## 📊 Main Findings

### 1. Selective Learning (Fig 1d, Table 1)
- **Full gaze:** Learning = 1.22 ± 0.46 sec, **p < .05** ✓
- **Partial gaze:** Learning = 0.76 ± 0.51 sec, p = .19
- **No gaze:** Learning = 0.34 ± 0.42 sec, p = .42

### 2. Attention-Learning Dissociation (Fig 2)
- Visual attention did **NOT** differ across gaze conditions
- SG > UK attention (t=5.83, p<.0001) but **no learning difference**
- Attention did **NOT** correlate with learning (p=.17)

### 3. Neural Connectivity Double Dissociation (Fig 4)
- **AI GPDC → Learning:** R² = 24.6%, p < .05 ✓
- **II GPDC → CDI gestures:** R² = 33.7%, p < .05 ✓
- Cross-validated with 10-fold CV, 1000 bootstraps

### 4. Neural Entrainment (Fig 5)
- Significant **only in Full gaze**:
  - Delta C3, Theta F4/Pz, Alpha C3/Cz
- **Does NOT predict learning** (Supp Fig S5)

### 5. 🌟 Mediation by Interpersonal Connectivity (Fig 6)
**Main Result:**
- **AI GPDC mediates gaze → learning** (β=0.52, p<.01)
- Full gaze → ↑ AI connectivity → ↑ Learning
- NSE does **NOT** mediate (modulated but not predictive)
- Modulatory effect: NSE→AI only in No gaze (compensatory)

---

## 🔬 Methods Summary

### Participants
- N = 47 infants (29 UK, 18 SG)
- Age: 9.4 months (range: 8-10.5 months)
- Power: 0.80 for d=0.43 at α=0.05

### EEG Parameters
- **Sampling:** 500 Hz → 200 Hz
- **Filter:** 0.1-45 Hz bandpass
- **Channels:** 9-grid (F3,Fz,F4,C3,Cz,C4,P3,Pz,P4)
- **Artifact rejection:** ±150 μV threshold + manual
- **Retention:** 32.9% data per participant

### GPDC Parameters
- **Model order:** 7 (BIC optimized)
- **Window:** 1.5s, 50% overlap
- **FFT:** 256 points (0.67 Hz resolution)
- **Method:** Nuttall-Strand unbiased
- **Frequency:** Alpha 6-9 Hz (main), also delta/theta

### Statistical Approach
- **LME models:** Age, sex, country covariates
- **PLS regression:** Dimensionality reduction
- **Mediation:** Bootstrap with 1000 iterations
- **Correction:** Benjamini-Hochberg FDR
- **Surrogates:** 1000 permutations for significance

---

## 📝 How to Use This Code

### For Replication:
1. Ensure MATLAB R2020a or later
2. Install required toolboxes:
   - Statistics and Machine Learning
   - Signal Processing
   - EEGLAB (for preprocessing)
   - eMVAR Toolbox (for GPDC)

3. Update paths in scripts:
   ```matlab
   path = 'YOUR_PATH_HERE/infanteeg/CAM BABBLE EEG DATA/'
   ```

4. Run in order:
   ```matlab
   fs0_eegratio.m          % Quality control
   fs1_behav_calculation.m % Behavioral metrics
   fs2_fig2_behaviouranaylse.m % Fig 2
   fs3_pdc_nosurr_v2.m    % Calculate GPDC
   fs3_makesurr3_nonor.m  % Surrogates (takes time!)
   fs4_readdata.m         % Load data
   fs5_strongpdc.m        % Significance
   fs7_LME2_FIGURES4.m    % PLS & Fig 4
   fs8_entrain*.m         % Entrainment & Fig 5
   fs9_f4_newest.m        % Mediation & Fig 6 ⭐
   ```

### For Understanding:
1. Read `scripts/README_ANALYSIS_PIPELINE.md` for overview
2. Read `scripts/SCRIPTS_ANNOTATION_SUMMARY.md` for details
3. Check inline comments in each script (now added to key files)

### For Modification:
- Each script has detailed header explaining:
  - Purpose
  - Manuscript correspondence
  - Key parameters
  - Expected outputs
  - Related figures

---

## 📚 Key References

### Statistical Methods
- **GPDC:** Baccalá et al. (2007) Generalized Partial Directed Coherence
- **PLS:** Krishnan et al. (2011) PLS methods for neuroimaging
- **Mediation:** Hayes (2009) Statistical Mediation Analysis

### Theoretical Framework
- **Natural Pedagogy:** Csibra & Gergely (2009)
- **Social Gating:** Kuhl (2007) Is speech learning 'gated' by social brain?
- **Statistical Learning:** Saffran et al. (1996)

### Neural Coupling
- **Interpersonal:** Leong et al. (2017) Speaker gaze increases coupling
- **Mechanisms:** Wass et al. (2020) Interpersonal neural entrainment

---

## 📧 Contact & Citation

**Data Availability:** Available from corresponding author upon reasonable request
**Code Repository:** https://github.com/Baby-Linc-Singapore/BABBLE_CODE

**Corresponding Author:**
Victoria Leong
victorialeong@ntu.edu.sg
Nanyang Technological University, Singapore

**Citation:**
Zhang, W., Clackson, K., Georgieva, S., et al. (2025). Adult-infant neural coupling mediates infants' selection of socially-relevant stimuli for learning across cultures. *Nature Communications*.

---

## 🔄 Version History

- **final2_R1:** Current version with full annotations
- **final2:** Previous version (pre-annotation)
- **final:** Original analysis version
- **newanalysis_phraseblock:** Earlier phrase-level analysis

---

*Last updated: October 2025*
*All scripts annotated with manuscript correspondence and key findings*
