# BABBLE Study Analysis Pipeline
## Adult-Infant Neural Coupling Mediates Selection of Socially-Relevant Stimuli for Learning Across Cultures

**Reference:** Zhang, Wei et al. Nature Communications (Main manuscript + Supplementary Materials)

---

## Analysis Pipeline Overview

### STEP 0: Data Preparation & Quality Control
**Corresponds to:** Methods 4.3.1 (EEG acquisition and preprocessing) & Supplementary Section 12 (EEG data retention)

- `fs0_eegratio.m` - Calculate EEG rejection ratios (777=unattend, 999=auto reject, 888=manual reject)
  - **Output:** Supplementary Table S7 (EEG data retention breakdown)
  - **Key results:** 36.4% attended data retained, 32.9% after artifact rejection

- `fs0_findattendonset.m` - Calculate attention onset and duration from EEG segments
  - **Output:** Visual attention metrics (onset, duration) saved to mat files
  - **Corresponds to:** Section 2.1 & Fig 2a (visual attention measures)

- `fs0_samplesize_estimate.m` - A priori power calculation
  - **Corresponds to:** Methods 4.1 (sample size estimation, N=45 for power=0.8)
  - Cohen's d = 0.43 from previous studies

---

### STEP 1: Behavioral Analysis
**Corresponds to:** Results Section 2.1 (Speaker gaze modulates learning)

- `fs1_behav_calculation.m` - Calculate infant learning metrics
  - **Output:** Looking time differences (nonwords - words) as measure of learning
  - **Key result:** Fig 1d - Learning significant only in Full gaze condition (t98=2.66, p<.05)

- `fs2_fig2_behaviouranaylse.m` - Behavioral analysis and Figure 2
  - **Output:** Figure 2 (relationship between visual attention and learning)
  - **Key findings:**
    - No difference in visual attention across gaze conditions (Fig 2b)
    - No correlation between attention and learning (Fig 2c)
    - SG infants attended longer than UK infants (t290=5.83, p<.0001) but no difference in learning

---

### STEP 3: Neural Connectivity Analysis (GPDC/PDC)
**Corresponds to:** Methods 4.3.2-4.3.3 (GPDC), Results Section 2.2, Supplementary Section 13

- `fs3_pdc_nosurr_v2.m` - Calculate PDC connectivity (no surrogate version)
  - Partial Directed Coherence analysis for directed brain connectivity

- `fs3_makesurr3_nonor.m` - Generate surrogate data for connectivity significance testing
  - **Corresponds to:** Methods 4.3.4 (Generation of surrogate data)
  - Creates 1000 surrogate datasets by shuffling temporal dependencies
  - **Output:** Surrogate distributions for GPDC significance testing (95% CI)

---

### STEP 4: Load and Organize Neural Connectivity Data

- `fs4_readdata.m` - Read connectivity data from GPDC analysis
  - Loads GPDC matrices partitioned into: AA (adult-adult), II (infant-infant), AI (adult-infant), IA (infant-adult)
  - **Corresponds to:** Fig 3a (illustration of dyadic connectivity network)

---

### STEP 5: Identify Significant Connections
**Corresponds to:** Results Section 2.2, Supplementary Section 4

- `fs5_strongpdc.m` - Identify significant GPDC connections above surrogate threshold
  - Compares real GPDC to surrogate distribution (BHFDR corrected)
  - **Output:** Fig 3b (significant connections in AA, II, AI but not IA)

- `fs5n_strongpdc_f3.m` - Alternative version for specific frequency/channel analysis

---

### STEP 6: Visualization of Connectivity Patterns

- `fs6_FIGURE4_plotlink4c.m` - Plot connectivity links for Figure 4
  - **Output:** Fig 4c,d (PLS component loadings and topographical maps)
  - Shows key connections loading on AI and II GPDC components

---

### STEP 7: Statistical Modeling - LME & PLS Analysis
**Corresponds to:** Results Section 2.2 (PLS regression), Section 2.4 (Mediation analysis), Methods 4.4-4.5

- `fs7_LME2_FIGURES4.m` - Linear Mixed Effects models and PLS regression for Figure S4
  - **Key analyses:**
    1. PLS regression: AI GPDC predicts learning (R²=24.6%, Fig 4a)
    2. PLS regression: II GPDC predicts CDI gestures (R²=33.7%, Fig 4b)
    3. 10-fold cross-validation with 1000 bootstrap iterations (Fig 4e,f)
  - **Double dissociation:** AI↔Learning, II↔Language development
  - **Output:** Supplementary Fig S4 (channel-level gaze modulation, adult Fz→infant F4)

---

### STEP 8: Neural-Speech Entrainment Analysis
**Corresponds to:** Results Section 2.3 & 2.4, Methods 4.3.3, Supplementary Section 5

- `fs8_entrain1.m` - Calculate neural entrainment to speech (Step 1)
  - Measures cross-correlation between infant EEG and speech amplitude envelope

- `fs8_entrain2_surr.m` - Generate surrogate data for entrainment significance testing
  - Shuffles speech-EEG temporal alignment (1000 surrogates)

- `fs8_entrain3_drawfigure3A.m` - Visualization for entrainment results
  - **Output:** Part of Figure 5 visualization

- `fs8_entrain4_readdata.m` - Read entrainment data

- `fs8_entrain5_surrread.m` - Read surrogate entrainment data

- `fs8_entrain6_conditionsandpermutations_figure5bc.m` - Statistical analysis and Figure 5
  - **Output:** Fig 5b,c (NSE significant only in Full gaze: delta C3, theta F4/Pz, alpha C3/Cz)
  - **Key finding:** NSE modulated by gaze but does NOT predict learning (Supp Fig S5)

---

### STEP 9: Mediation Analysis
**Corresponds to:** Results Section 2.4 (Mediation pathways), Methods 4.5, Supplementary Section 7

- `fs9_f4_newest.m` - Main mediation analysis (Figure 4 updated version)
  - Tests whether AI GPDC and NSE mediate gaze→learning pathway
  - **Key results (Fig 6):**
    - AI GPDC significantly mediates gaze→learning (indirect β=0.52±0.23, p<.01)
    - Full gaze → higher AI connectivity (β=1.01, p<.05)
    - Higher AI → increased learning (β=0.50, p<.0001, r=0.49)
    - NSE does NOT mediate gaze→learning
    - NSE positively correlates with AI only in No gaze condition (modulatory effect)

- `fs9_redof6.m` - Alternative/refined version of mediation analysis

---

### STEP 11: Additional Visualization

- `fs11_testplotfigure4CD.m` - Test plotting for Figure 4C,D
  - Visualization of PLS component loadings and topographies

---

### STEP 12: Individual Differences Analysis
**Corresponds to:** Supplementary Section 1

- `fs12_clusteringlearning_subjectlevel_FIGS1.m` - Subject-level clustering analysis
  - **Output:** Supplementary Fig S1 (individual learning patterns)
  - **Key findings:**
    - 38.3% infants show Full gaze advantage
    - 70.2% show Full or Partial gaze advantage
    - Full gaze advantage group has better overall learning (t39=2.16, p<.05)

---

### Utility Functions

- `create_heatmap.m` - Utility for creating heatmap visualizations
- `vl_cluster.m` - Clustering analysis utility

---

## Key Results Summary

### Main Findings:
1. **Selective Learning (Fig 1d, Table 1):** Learning significant only with Full gaze (t98=2.66, p<.05)
2. **Attention-Learning Dissociation (Fig 2):** Visual attention did not differ across gaze conditions or correlate with learning
3. **AI Connectivity Predicts Learning (Fig 4a):** Only AI GPDC (not II) predicts learning (R²=24.6%)
4. **II Connectivity Predicts Language (Fig 4b):** II GPDC predicts CDI gestures (R²=33.7%)
5. **Entrainment Gaze-Sensitive but Non-Predictive (Fig 5):** NSE significant only in Full gaze but doesn't predict learning
6. **Mediation by AI Connectivity (Fig 6):** AI GPDC mediates Full gaze→learning (β=0.52, p<.01); NSE does not

### Cross-Cultural Consistency (Supplementary Section 6):
- No country effects on learning, AI GPDC, or NSE
- SG and UK infants show similar gaze-modulated learning despite attention differences

---

## Data Files Location

- **Preprocessed EEG:** `../Preprocessed Data_sg/` and `../Preprocessed Data_camb/`
- **Behavioral data:** CDI scores, looking time data
- **Connectivity matrices:** GPDC/PDC results stored in `../data/` folder
- **Surrogate distributions:** For GPDC and NSE significance testing

---

## Analysis Parameters

### EEG Preprocessing (Methods 4.3.1):
- Sampling rate: 500 Hz → downsampled to 200 Hz
- Filter: 0.1-45 Hz bandpass (inverse FFT filter)
- Artifact rejection: Manual (video-coded) + automated (±150 μV threshold)
- Average retention: 32.9% of data per participant

### GPDC Parameters (Supplementary Section 13):
- Model order: 7 (Bayesian Information Criterion optimized)
- Window: 1.5s with 50% overlap (300 samples at 200 Hz)
- FFT points: 256 (frequency resolution: 0.67 Hz)
- Method: Nuttall-Strand unbiased partial correlation
- Channels: 9-channel grid (F3,Fz,F4,C3,Cz,C4,P3,Pz,P4)

### Frequency Bands:
- Delta: 1-3 Hz
- Theta: 3-6 Hz
- Alpha (infant): 6-9 Hz (used for main GPDC analysis)

### Statistical Thresholds:
- Multiple comparison correction: Benjamini-Hochberg FDR
- Surrogate significance: 95% CI upper bound (p<.05)
- Bootstrap iterations: 1000
- Cross-validation: 10-fold

---

## Citation
Zhang, W., Clackson, K., Georgieva, S., Santamaria, L., Reindl, V., Noreika, V., Darby, N., Valsdottir, V., Santhanakrishnan, P., & Leong, V. (2025). Adult-infant neural coupling mediates infants' selection of socially-relevant stimuli for learning across cultures. Nature Communications.
