# BABBLE Study Scripts - Detailed Annotations
## Quick Reference Guide for Each Analysis Script

---

## ✅ COMPLETED - Scripts with Full Header Comments

### STEP 0: Data Preparation & Quality Control

#### `fs0_eegratio.m` ✓
- **Purpose:** Calculate EEG rejection ratios
- **Output:** Supplementary Table S7
- **Key Result:** 32.9% data retained after artifact rejection

#### `fs0_findattendonset.m` ✓
- **Purpose:** Calculate visual attention metrics
- **Output:** Figure 2a attention measures
- **Key Finding:** No attention difference across gaze conditions

#### `fs0_samplesize_estimate.m` ✓
- **Purpose:** A priori power analysis
- **Output:** N=45 required sample size
- **Parameters:** d=0.43, α=0.05, power=0.80

### STEP 1: Behavioral Analysis

#### `fs1_behav_calculation.m` ✓
- **Purpose:** Calculate learning from looking times
- **Output:** behaviour2.5sd.xlsx, Figure 1d
- **Key Result:** Full gaze: t(98)=2.66, p<.05

#### `fs2_fig2_behaviouranaylse.m` ✓
- **Purpose:** Attention-learning dissociation analysis
- **Output:** Figure 2, Supplementary Fig S2
- **Key Finding:** SG>UK attention but no learning difference

### STEP 3: Neural Connectivity

#### `fs3_pdc_nosurr_v2.m` ✓
- **Purpose:** Calculate GPDC connectivity
- **Output:** GPDC matrices (AA, II, AI, IA)
- **Parameters:** Model order=7, window=1.5s, alpha band 6-9Hz

#### `fs3_makesurr3_nonor.m` ✓
- **Purpose:** Generate 1000 surrogate datasets
- **Output:** Surrogate distributions for significance testing
- **Method:** Random epoch shuffling preserving spectral content

---

## 📝 TO BE ANNOTATED - Remaining Key Scripts

### STEP 4: Load Neural Data

#### `fs4_readdata.m`
```matlab
%% ========================================================================
%  STEP 4: Load and Organize GPDC Connectivity Data
%  ========================================================================
%
%  PURPOSE:
%  Load GPDC matrices from previous analysis and partition into network
%  sub-matrices (AA, II, AI, IA) for subsequent statistical analysis.
%
%  CORRESPONDS TO:
%  - Figure 3a (Dyadic connectivity network illustration)
%  - Preparation for PLS regression analysis
%
%  DATA STRUCTURE:
%  - Loads GPDC values computed in fs3_pdc_nosurr_v2.m
%  - Organizes by: participant × condition × block × frequency band
%  - Separates adult channels (1-9) from infant channels (10-18)
%
%  PARTITIONING SCHEME:
%  - AA: Adult channels → Adult channels
%  - II: Infant channels → Infant channels
%  - AI: Adult channels → Infant channels (interpersonal)
%  - IA: Infant channels → Adult channels (should be spurious)
%
%  OUTPUT:
%  - Organized matrices ready for significance testing (Step 5)
%  - Input for PLS regression analysis (Step 7)
%
%  ========================================================================
```

### STEP 5: Identify Significant Connections

#### `fs5_strongpdc.m`
```matlab
%% ========================================================================
%  STEP 5: Identify Significant GPDC Connections
%  ========================================================================
%
%  PURPOSE:
%  Compare real GPDC values to surrogate distribution to identify
%  statistically significant connections after BHFDR correction.
%
%  CORRESPONDS TO:
%  - Figure 3b (Ranked GPDC strength vs surrogate)
%  - Methods 4.3.4 (Significance testing)
%  - Supplementary Section 4 (Channel-level gaze modulation)
%
%  ANALYSIS METHOD:
%  1. Load real GPDC and 1000 surrogate datasets
%  2. Calculate 95% CI upper bound of surrogate distribution
%  3. Apply Benjamini-Hochberg FDR correction
%  4. Identify connections exceeding threshold
%
%  KEY FINDINGS (Fig 3b):
%  - Significant connections in AA, II, AI directions
%  - No significant IA connections (validates pre-recorded design)
%  - Only AI Fz→infant F4 shows gaze modulation (t221=3.48, p<.05)
%    (Supplementary Fig S4)
%
%  OUTPUT:
%  - stronglistfdr5_gpdc*.mat files
%  - Binary masks of significant connections
%  - Used as input for PLS regression (Step 7)
%
%  ========================================================================
```

#### `fs5n_strongpdc_f3.m`
```matlab
%% Alternative version for frequency/channel-specific analysis
%% Similar to fs5_strongpdc.m but focuses on specific frequency bands
```

### STEP 6: Visualization

#### `fs6_FIGURE4_plotlink4c.m`
```matlab
%% ========================================================================
%  STEP 6: Visualize Connectivity Patterns - Figure 4c,d
%  ========================================================================
%
%  PURPOSE:
%  Generate topographical visualizations and connectivity diagrams showing
%  PLS component loadings for AI and II GPDC networks.
%
%  CORRESPONDS TO:
%  - Figure 4c (AI GPDC loadings for learning prediction)
%  - Figure 4d (II GPDC loadings for CDI prediction)
%
%  VISUALIZATION ELEMENTS:
%  1. PLS component loadings (bar plots)
%  2. Scalp topography maps (sender and receiver)
%  3. Connection strength visualization
%  4. Key connections highlighted (e.g., adult Fz → infant Fz)
%
%  KEY CONNECTIONS SHOWN:
%  - AI Component 1: Adult Fz → Infant Fz (peak loading)
%  - II Component 1: Infant intrahemispheric connections
%
%  OUTPUT:
%  - Figure 4c,d panels for manuscript
%  - Topographical maps with connectivity overlays
%
%  ========================================================================
```

### STEP 7: Statistical Modeling

#### `fs7_LME2_FIGURES4.m`
```matlab
%% ========================================================================
%  STEP 7: PLS Regression and LME Analysis - Figure 4 & Supp Fig S4
%  ========================================================================
%
%  PURPOSE:
%  Perform Partial Least Squares (PLS) regression to identify neural
%  predictors of learning and language development, with cross-validation.
%
%  CORRESPONDS TO:
%  - Results Section 2.2 "Adult-infant cross-brain connectivity predicts
%    selective learning whereas within-infant connectivity associates with
%    expressive language"
%  - Figure 4a,b,e,f (PLS prediction and cross-validation)
%  - Supplementary Figure S3 (Delta and theta band analysis)
%  - Supplementary Figure S4 (Channel-level gaze modulation)
%
%  KEY ANALYSES:
%
%  1. PLS REGRESSION (Methods 4.4):
%     - AI GPDC → Learning: R² = 24.6%, p < .05 (Fig 4a)
%     - II GPDC → Learning: Not significant
%     - II GPDC → CDI gestures: R² = 33.7%, p < .05 (Fig 4b)
%     - AI GPDC → CDI gestures: Not significant
%
%  2. DOUBLE DISSOCIATION:
%     - AI predicts learning > II: t(1998) = 27.7, p < .0001
%     - II predicts CDI > AI: t(1998) = 44.7, p < .0001
%
%  3. CROSS-VALIDATION (Fig 4e,f):
%     - 10-fold CV with 1000 bootstrap iterations
%     - Confirms generalizability of PLS models
%
%  4. LME CHANNEL-LEVEL ANALYSIS (Supp Fig S4):
%     - Adult Fz → Infant F4 shows gaze effect
%     - Full > Partial/No gaze: t(221) = 3.48, BHFDR p < .05
%
%  PLS METHOD:
%  - Dimensionality reduction + regression
%  - Handles collinear GPDC features
%  - Components ordered by explained covariance
%  - Bootstrapping for loading estimation
%
%  COVARIATES:
%  - Age, sex, country (fixed effects)
%  - Participant ID (random effect)
%
%  OUTPUT:
%  - PLS components and loadings
%  - Cross-validation performance metrics
%  - Figures 4a,b,e,f and Supplementary Figs S3, S4
%
%  ========================================================================
```

### STEP 8: Neural-Speech Entrainment

#### `fs8_entrain1.m`
```matlab
%% ========================================================================
%  STEP 8.1: Calculate Neural-Speech Entrainment (NSE)
%  ========================================================================
%
%  PURPOSE:
%  Measure cross-correlation between infant EEG and speech amplitude
%  envelope to quantify neural entrainment to rhythmic speech.
%
%  CORRESPONDS TO:
%  - Results Section 2.3 "Neural entrainment to speech amplitude envelope
%    is modulated by speaker gaze but does not predict learning"
%  - Figure 5a (NSE measurement schematic)
%  - Methods 4.3.3 (Measuring NSE using cross-correlation)
%
%  NSE CALCULATION:
%  1. Extract speech amplitude envelope (Hilbert transform)
%  2. Calculate EEG power in delta/theta/alpha bands
%  3. Rank-transform for Spearman correlation
%  4. Cross-correlation with frequency-specific lag window
%  5. Peak absolute correlation = entrainment strength
%
%  FREQUENCY-SPECIFIC LAGS:
%  - Lag range = ±sampling_rate / upper_freq_bound
%  - Delta (1-3 Hz): ±200/3 ≈ ±67 timepoints
%  - Theta (3-6 Hz): ±200/6 ≈ ±33 timepoints
%  - Alpha (6-9 Hz): ±200/9 ≈ ±22 timepoints
%
%  DATA SELECTION:
%  - First 6 syllables of each phrase
%  - Early phase shows strong oscillatory entrainment
%
%  OUTPUT:
%  - NSE values per participant × condition × channel × frequency
%  - Input for surrogate testing (fs8_entrain2_surr.m)
%
%  ========================================================================
```

#### `fs8_entrain2_surr.m`
```matlab
%% ========================================================================
%  STEP 8.2: Generate Surrogate Data for NSE Significance Testing
%  ========================================================================
%
%  PURPOSE:
%  Create 1000 surrogate datasets by mismatching speech and EEG to
%  establish chance-level baseline for NSE significance.
%
%  CORRESPONDS TO:
%  - Methods 4.3.4 (Surrogate generation for NSE)
%
%  SURROGATE METHOD:
%  - For each participant and channel:
%    * Replace speech segment with random segment from different language
%    * Recombine with infant EEG
%    * Calculate NSE using same pipeline
%  - Generate 1000 surrogates at group level
%  - Establish 95% CI for each channel × frequency band
%
%  SIGNIFICANCE CRITERION:
%  - Real NSE exceeding 95% CI upper bound → significant
%  - BHFDR correction for multiple comparisons
%
%  OUTPUT:
%  - Surrogate NSE distributions
%  - Used in fs8_entrain3 for visualization
%
%  ========================================================================
```

#### `fs8_entrain3_drawfigure3A.m`
```matlab
%% ========================================================================
%  STEP 8.3: Visualize NSE Results - Part of Figure 5
%  ========================================================================
%
%  PURPOSE:
%  Visualize neural-speech entrainment against surrogate distributions.
%
%  CORRESPONDS TO:
%  - Figure 5c (Example delta C3 entrainment across conditions)
%
%  VISUALIZATION:
%  - Real NSE vs surrogate 95% CI for each gaze condition
%  - Shows significance only in Full gaze condition
%
%  ========================================================================
```

#### `fs8_entrain4_readdata.m`
```matlab
%% Read and organize NSE data for statistical analysis
```

#### `fs8_entrain5_surrread.m`
```matlab
%% Read surrogate NSE distributions
```

#### `fs8_entrain6_conditionsandpermutations_figure5bc.m`
```matlab
%% ========================================================================
%  STEP 8.6: NSE Statistical Analysis and Figure 5b,c
%  ========================================================================
%
%  PURPOSE:
%  Test NSE significance across gaze conditions and assess whether NSE
%  predicts learning (it doesn't).
%
%  CORRESPONDS TO:
%  - Figure 5b (Standardized mean difference plots)
%  - Figure 5c (Example delta C3 NSE)
%  - Supplementary Figure S5 (NSE does not predict learning)
%
%  KEY FINDINGS (Fig 5b):
%  - Significant NSE only in Full gaze:
%    * Delta C3: Significant
%    * Theta F4, Pz: Significant
%    * Alpha C3, Cz: Significant
%  - No significant NSE in Partial or No gaze
%  - All corrected p < .05 (BHFDR)
%
%  PLS ANALYSIS (Supp Fig S5):
%  - NSE features do NOT predict learning
%  - Performance doesn't exceed surrogate 95% CI
%  - Confirms NSE modulated by gaze but not predictive
%
%  OUTPUT:
%  - Figure 5b,c panels
%  - NSE features for mediation analysis (Step 9)
%
%  ========================================================================
```

### STEP 9: Mediation Analysis

#### `fs9_f4_newest.m`
```matlab
%% ========================================================================
%  STEP 9: Mediation Analysis - Figure 6 (MAIN RESULT)
%  ========================================================================
%
%  PURPOSE:
%  Test whether AI connectivity and NSE mediate the effect of ostensive
%  gaze on infant learning. This is the KEY analysis demonstrating that
%  interpersonal neural coupling, not entrainment, mediates learning.
%
%  CORRESPONDS TO:
%  - Results Section 2.4 "Interbrain connectivity mediates gaze-selective
%    learning independent of entrainment"
%  - Figure 6 (Complete mediation model)
%  - Methods 4.5 (Mediation analyses)
%  - Supplementary Section 7 (Alternative mediator tests)
%
%  MEDIATION FRAMEWORK (Fig 6, middle panel):
%
%  Independent Variable: Gaze condition (Full/Partial/No)
%  Potential Mediators: AI GPDC, NSE (delta C3)
%  Dependent Variable: Infant learning
%
%  KEY RESULTS:
%
%  1. AI GPDC MEDIATES GAZE → LEARNING ✓ (Fig 6a,b):
%     - Indirect effect: β = 0.52 ± 0.23, p < .01
%     - Full gaze → higher AI GPDC: β = 1.01, t(111) = 2.53, p < .05
%     - Higher AI → more learning: β = 0.50, t(224) = 8.58, p < .0001
%     - Correlation: r = 0.49, p < .0001
%     - Direct effect of gaze: β = 0.06 ± 0.12, p = .65 (not significant)
%     - CONCLUSION: Full mediation by AI connectivity
%
%  2. NSE DOES NOT MEDIATE ✗ (Fig 6c,d):
%     - Full gaze → higher NSE delta C3: β = 0.40, t(112) = 2.28, p < .05
%     - NSE → learning: β = -0.12, t(112) = -1.22, p = .23 (not sig)
%     - Correlation: r = -0.11, p = .24
%     - Indirect effect: β = -0.05 ± 0.04, p = .16
%     - Direct effect: β = 0.35 ± 0.20, p = .08
%     - CONCLUSION: NSE modulated by gaze but doesn't predict learning
%
%  3. MODULATORY EFFECT (Fig 6e):
%     - Gaze × NSE interaction on AI connectivity
%     - In No gaze: NSE → AI (β = 0.34, t(111) = 2.02, p < .05)
%     - In Full/Partial: No relationship
%     - INTERPRETATION: Compensatory mechanism - when visual cues absent,
%       infants may enhance sensory-neural coupling
%
%  4. OTHER NSE FEATURES (Supp Table S2):
%     - Theta F4, Pz; Alpha C3, Cz: None mediate
%     - Only delta C3 shows gaze modulation
%
%  5. II GPDC (Supp Fig S6):
%     - Does not mediate gaze → learning
%     - Indirect effect: β = 0.06 ± 0.25, p = .82
%
%  STATISTICAL METHODS:
%  - Linear Mixed Effects models
%  - 1000 bootstrap iterations for effect size CIs
%  - Standardized coefficients reported
%  - Age, sex, country as covariates
%  - Participant ID as random effect
%
%  INTERPRETATION (Discussion):
%  - Interpersonal neural coupling (AI) is the mechanism linking ostensive
%    gaze to selective learning
%  - Entrainment reflects phonological encoding but not learning per se
%  - AI connectivity may reflect social valuation processes (mPFC-based)
%  - Analogous to pair-bonding circuits in prairie voles (PFC-NAc coupling)
%
%  OUTPUT:
%  - Figure 6 (main mediation figure)
%  - Mediation path coefficients
%  - Bootstrap confidence intervals
%
%  ========================================================================
```

#### `fs9_redof6.m`
```matlab
%% Alternative/refined mediation analysis version
%% Similar to fs9_f4_newest.m but may include sensitivity analyses
```

### STEP 11: Additional Visualization

#### `fs11_testplotfigure4CD.m`
```matlab
%% ========================================================================
%  STEP 11: Test Visualization for Figure 4C,D
%  ========================================================================
%
%  PURPOSE:
%  Generate and test topographical plots and component loading
%  visualizations for PLS analysis results.
%
%  CORRESPONDS TO:
%  - Figure 4c (AI GPDC component loadings)
%  - Figure 4d (II GPDC component loadings)
%
%  VISUALIZATION COMPONENTS:
%  - PLS loading bar plots
%  - Sender and receiver scalp topographies
%  - Connection strength overlays
%
%  ========================================================================
```

### STEP 12: Individual Differences

#### `fs12_clusteringlearning_subjectlevel_FIGS1.m`
```matlab
%% ========================================================================
%  STEP 12: Individual Differences in Learning - Supplementary Fig S1
%  ========================================================================
%
%  PURPOSE:
%  Analyze individual infant learning patterns to identify which infants
%  show gaze advantage and how this relates to overall performance.
%
%  CORRESPONDS TO:
%  - Supplementary Materials Section 1 (Individual differences)
%  - Supplementary Figure S1
%
%  ANALYSIS APPROACH:
%  1. Define "advantage condition" per infant
%     - Condition with highest positive learning score
%
%  2. Categorize infants by advantage type:
%     - Full gaze advantage: 18/47 (38.3%)
%     - Partial gaze advantage: 15/47 (31.9%)
%     - No gaze advantage: 11/47 (23.4%)
%     - No clear pattern: 3/47 (6.4%)
%
%  3. Relate advantage to overall performance:
%     - Full gaze advantage → best overall learning
%     - t(39) = 2.16, p < .05
%
%  4. 3D visualization (Supp Fig S1b):
%     - X: Full gaze learning
%     - Y: Partial gaze learning
%     - Z: No gaze learning
%     - Color: Overall performance
%     - Shows "trade-off" pattern
%
%  KEY FINDINGS:
%  - 70.2% of infants show Full or Partial gaze advantage
%  - Highest Full gaze learning associates with:
%    * High Partial gaze learning
%    * Low No gaze learning
%    * Better overall performance
%  - Supports selective learning in presence of ostensive cues
%
%  VISUALIZATION:
%  - 3D surface plot with interpolation
%  - Gaussian smoothing (σ = 10)
%  - Overall performance color gradient
%
%  OUTPUT:
%  - Supplementary Figure S1a,b
%  - Individual learning pattern classifications
%
%  ========================================================================
```

### Utility Functions

#### `create_heatmap.m`
```matlab
%% Utility function for generating heatmap visualizations
%% Used across multiple analysis steps for connectivity matrices
```

#### `vl_cluster.m`
```matlab
%% Clustering analysis utility
%% May be used for subject-level pattern identification
```

---

## Analysis Flow Summary

```
STEP 0 (Preparation)
├── fs0_eegratio.m → EEG quality metrics
├── fs0_findattendonset.m → Attention metrics
└── fs0_samplesize_estimate.m → Power analysis

STEP 1-2 (Behavior)
├── fs1_behav_calculation.m → Learning scores
└── fs2_fig2_behaviouranaylse.m → Fig 2, attention-learning dissociation

STEP 3 (Connectivity)
├── fs3_pdc_nosurr_v2.m → Calculate GPDC
└── fs3_makesurr3_nonor.m → Generate surrogates (1000×)

STEP 4-5 (Significance)
├── fs4_readdata.m → Load GPDC data
└── fs5_strongpdc.m → Identify significant connections

STEP 6-7 (PLS Analysis)
├── fs6_FIGURE4_plotlink4c.m → Visualize connectivity
└── fs7_LME2_FIGURES4.m → PLS regression, Fig 4, double dissociation

STEP 8 (Entrainment)
├── fs8_entrain1.m → Calculate NSE
├── fs8_entrain2_surr.m → NSE surrogates
├── fs8_entrain3_drawfigure3A.m → Visualize
├── fs8_entrain4_readdata.m → Load NSE
├── fs8_entrain5_surrread.m → Load surrogates
└── fs8_entrain6_...figure5bc.m → Fig 5, NSE statistics

STEP 9 (Mediation) ⭐ MAIN RESULT
├── fs9_f4_newest.m → Fig 6, mediation analysis
└── fs9_redof6.m → Alternative version

STEP 11-12 (Additional)
├── fs11_testplotfigure4CD.m → Fig 4C,D visualization
└── fs12_clusteringlearning_...FIGS1.m → Supp Fig S1, individual differences
```

---

## Key Findings Roadmap

| Step | Script | Main Finding | Figure |
|------|--------|--------------|--------|
| 1 | fs1 | Learning only in Full gaze (t=2.66, p<.05) | Fig 1d |
| 2 | fs2 | Attention ≠ Learning; SG>UK attention | Fig 2 |
| 3 | fs3 | GPDC calculated (AA, II, AI significant) | Fig 3 |
| 5 | fs5 | Fz→F4 gaze-modulated (t=3.48, p<.05) | Supp S4 |
| 7 | fs7 | AI→Learning (R²=24.6%), II→CDI (R²=33.7%) | Fig 4 |
| 8 | fs8 | NSE in Full gaze only, doesn't predict learning | Fig 5 |
| 9 | fs9 | AI mediates gaze→learning (β=0.52, p<.01) ⭐ | Fig 6 |
| 12 | fs12 | 38.3% Full gaze advantage | Supp S1 |

---

## Data Files Referenced

- **Input:** Preprocessed EEG (.mat), CDI scores (.xlsx), Looking times (.txt)
- **Intermediate:** GPDC matrices, Surrogate distributions, NSE values
- **Output:** behaviour2.5sd.xlsx, Figures 1-6, Supplementary figures

---

*This annotation summary provides context for understanding the complete analysis pipeline. Each script builds on previous steps to test the hypothesis that interpersonal neural coupling mediates ostensive gaze effects on infant learning.*
