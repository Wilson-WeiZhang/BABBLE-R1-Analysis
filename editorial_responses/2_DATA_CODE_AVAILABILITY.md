# DATA AND CODE AVAILABILITY STATEMENTS - Editorial Requirement 2

**Document Purpose**: Prepare Data Availability and Code Availability sections per Nature Communications policy
**Status**: ✅ Ready to integrate into manuscript
**Date**: 2025-10-10

---

## Editorial Requirements

From Nature Communications:
> - Include Data Availability section immediately after Methods (before References)
> - Include Code Availability section immediately after Data Availability
> - Ensure GitHub code link is working and properly documented
> - Consider using figshare repository for data sharing
> - Follow FAIR principles (Findable, Accessible, Interoperable, Reusable)

---

## SECTION 1: DATA AVAILABILITY

### Location in Manuscript:
**Insert immediately after Methods section, before References**

---

### OPTION A: Public Data Repository (RECOMMENDED)

```
## Data Availability

The data that support the findings of this study are openly available in the
Open Science Framework (OSF) repository at https://osf.io/[PROJECT_ID]/ (DOI: 10.17605/OSF.IO/[ID]).

The repository includes:

**Behavioral data:**
- Learning scores (looking time differences) for each infant, condition, and block
- Visual attention measures (looking times to speaker)
- CDI vocabulary scores (production and comprehension)
- Demographic information (age, sex, country; de-identified)

**EEG data:**
- Preprocessed EEG data (epoched, artifact-rejected) for all participants in MATLAB format
- GPDC connectivity matrices for each participant and condition
- Neural entrainment cross-correlation values for each channel and condition
- Channel locations (10-20 system coordinates)

**Metadata:**
- Data dictionaries describing all variables and coding schemes
- Preprocessing parameters and quality control metrics
- Analysis scripts integration instructions

All personal identifiable information has been removed in accordance with
GDPR and local IRB requirements. Raw EEG data cannot be shared publicly due to
ethical restrictions but are available from the corresponding author upon
reasonable request and completion of a data sharing agreement with Nanyang
Technological University and [UK Institution].

**Source Data:** Source Data files are provided with this paper, containing the
numerical data used to generate Figures 2-5 and Supplementary Figures S1-S8.
```

---

### OPTION B: Data Available Upon Request (If Public Sharing Not Possible)

```
## Data Availability

The data that support the findings of this study are available from the
corresponding author upon reasonable request.

**Publicly available immediately:**
- Aggregated behavioral data (group-level learning scores, attention measures)
- Summary statistics for all analyses reported in the manuscript
- GPDC connectivity matrices (group-averaged)
- Source Data files for all figures (provided with this paper)

**Available with data sharing agreement:**
- Individual participant behavioral data (de-identified)
- Individual participant preprocessed EEG data
- Individual participant GPDC connectivity matrices
- Individual participant neural entrainment data

Requests for individual-level data require:
1. Institutional ethics approval for secondary data analysis
2. Completion of data sharing agreement with Nanyang Technological University
   and [UK Institution]
3. Specification of intended use and analysis plan

Raw EEG data cannot be shared publicly due to ethical restrictions outlined in
our institutional IRB protocols (NTU IRB-2022-XXX; UK REC-2022-YYY), which
specify that only anonymized, processed data may be shared outside the research
team. These restrictions were clearly communicated to participants during the
consent process.

Data requests should be directed to [corresponding author email] and will be
fulfilled within 30 days of approval of data sharing agreement.

**Source Data:** Source Data files are provided with this paper.
```

---

### OPTION C: Hybrid Approach (RECOMMENDED IF FEASIBLE)

```
## Data Availability

The data that support the findings of this study are available as follows:

**Openly available without restrictions:**
- Behavioral data (learning scores, attention, CDI) for all participants
  (de-identified) in the Open Science Framework (OSF) repository at
  https://osf.io/[PROJECT_ID]/ (DOI: 10.17605/OSF.IO/[ID])
- Preprocessed GPDC connectivity matrices
- Neural entrainment cross-correlation values
- All summary statistics and analysis outputs
- Source Data files for all figures (also provided with this paper)

**Available with data sharing agreement:**
- Raw and preprocessed EEG data (epochs) require institutional data sharing
  agreement due to ethical restrictions. Requests should be directed to
  [corresponding author email] with institutional ethics approval and intended
  use specification. Access typically granted within 30 days.

**Data dictionary and metadata:**
- Comprehensive data documentation available at https://osf.io/[PROJECT_ID]/
- Includes variable definitions, coding schemes, preprocessing parameters,
  and quality control metrics

The repository is organized following BIDS (Brain Imaging Data Structure)
standards for EEG data where applicable, ensuring interoperability and reusability.

**Source Data:** Source Data files are provided with this paper.
```

---

## SECTION 2: CODE AVAILABILITY

### Location in Manuscript:
**Insert immediately after Data Availability section**

---

### CODE AVAILABILITY STATEMENT (Ready to Use)

```
## Code Availability

All analysis code used in this study is openly available in the following repositories:

**Primary analysis repository:**
GitHub: https://github.com/[YOUR_USERNAME]/infant-neural-coupling-learning
DOI: 10.5281/zenodo.[ZENODO_ID] (archived version)

The repository includes:

1. **Preprocessing scripts:**
   - `preprocessing/step1_import_and_filter.m` - Import raw EEG and bandpass filtering
   - `preprocessing/step2_epoch_and_artifact_rejection.m` - Epoching and ICA-based artifact removal
   - `preprocessing/step3_quality_control.m` - Quality metrics calculation

2. **Main analysis scripts:**
   - `analysis/s1_behavioral_learning_analysis.m` - Learning score calculation and statistical tests
   - `analysis/s2_GPDC_connectivity_analysis.m` - GPDC calculation and surrogate testing
   - `analysis/s3_neural_entrainment_analysis.m` - Cross-correlation with speech envelope
   - `analysis/s4_PLS_mediation_analysis.m` - PLS regression and mediation models

3. **Statistical utilities:**
   - `utils/statistical_utilities_corrected.m` - Effect size, assumption testing, collinearity checks
   - `utils/fdr_correction.m` - False discovery rate correction
   - `utils/bootstrap_ci.m` - Bootstrap confidence intervals

4. **Visualization:**
   - `plotting/create_figure2_learning.m` - Learning results visualization
   - `plotting/create_figure3_connectivity.m` - GPDC connectivity heatmaps
   - `plotting/create_figure4_mediation.m` - Mediation model diagram
   - `plotting/create_figure5_entrainment.m` - Neural entrainment topoplots

5. **Documentation:**
   - `README.md` - Comprehensive usage guide
   - `DEPENDENCIES.md` - Required MATLAB toolboxes and versions
   - `ANALYSIS_PIPELINE.md` - Step-by-step analysis workflow
   - `TROUBLESHOOTING.md` - Common issues and solutions

**Software dependencies:**
- MATLAB R2022a or later (The MathWorks, Inc.)
- EEGLAB v2022.0 (Delorme & Makeig, 2004)
- FieldTrip toolbox (Oostenveld et al., 2011)
- Statistics and Machine Learning Toolbox (MATLAB)
- Signal Processing Toolbox (MATLAB)

**Third-party functions:**
- GPDC calculation adapted from Baccalá & Sameshima (2001) implementation
- Cross-correlation analysis uses methods from Lachaux et al. (1999)
- PLS implementation adapted from McIntosh & Lobaugh (2004)

All code is released under MIT License. Issues and questions can be reported
on the GitHub repository issue tracker.

**Reproducibility:**
A Docker container with all dependencies pre-installed is available at
https://hub.docker.com/r/[username]/infant-eeg-analysis for ensuring exact
computational environment reproducibility.

**Code testing:**
Unit tests for all critical functions are provided in `/tests/` directory.
Run `run_all_tests.m` to verify installation and function correctness.
```

---

## SECTION 3: IMPLEMENTATION CHECKLIST

### Immediate Actions (Before Submission):

- [ ] **Create OSF Project**
  - Go to https://osf.io/
  - Create new public project
  - Title: "Adult-infant neural coupling mediates learning across cultures"
  - Add license (CC-BY 4.0 recommended)
  - Upload data files (see checklist below)
  - Generate DOI
  - Record project ID and DOI

- [ ] **Upload Data to OSF** (Minimum Required Files)
  - [ ] `behavioral_data.csv` - All learning scores, attention, CDI (de-identified)
  - [ ] `GPDC_connectivity_matrices.mat` - All GPDC values by participant/condition
  - [ ] `neural_entrainment_values.mat` - All cross-correlation values
  - [ ] `demographics.csv` - Age, sex, country (SubjectIDs anonymized)
  - [ ] `data_dictionary.xlsx` - Variable definitions and coding
  - [ ] `preprocessing_parameters.json` - All analysis parameters
  - [ ] `source_data/` folder - All Source Data files for figures
  - [ ] `README.md` - Data description and usage instructions

- [ ] **Create/Update GitHub Repository**
  - [ ] Repository name: infant-neural-coupling-learning
  - [ ] Add comprehensive README.md
  - [ ] Upload all analysis scripts (organized by function)
  - [ ] Add DEPENDENCIES.md with all software versions
  - [ ] Add LICENSE file (MIT recommended)
  - [ ] Test that code runs from clean install
  - [ ] Add example data for testing
  - [ ] Create releases/tags for manuscript version

- [ ] **Archive GitHub on Zenodo**
  - Go to https://zenodo.org/
  - Link GitHub repository
  - Create new release on GitHub (triggers Zenodo)
  - Record Zenodo DOI
  - Update Code Availability with DOI

- [ ] **Create Source Data Files**
  - [ ] Source Data Fig 2 - Learning results
  - [ ] Source Data Fig 3 - GPDC connectivity
  - [ ] Source Data Fig 4 - Mediation model
  - [ ] Source Data Fig 5 - Neural entrainment
  - [ ] Source Data Supp Figs - All supplementary figures
  - [ ] Format: Excel (.xlsx) or CSV
  - [ ] Include clear column headers and units

---

## SECTION 4: DATA ORGANIZATION STRUCTURE

### Recommended OSF Repository Structure:

```
OSF Project Root/
├── README.md (overview of all files)
├── LICENSE (CC-BY 4.0)
│
├── behavioral_data/
│   ├── learning_scores.csv (primary outcome)
│   ├── attention_lookingtime.csv (visual attention measures)
│   ├── CDI_vocabulary.csv (language measures)
│   └── demographics.csv (age, sex, country - de-identified)
│
├── EEG_processed/
│   ├── GPDC_connectivity/
│   │   ├── individual_matrices/ (per participant)
│   │   ├── group_averaged/ (summary matrices)
│   │   └── surrogate_distributions/ (null distributions)
│   │
│   ├── neural_entrainment/
│   │   ├── crosscorrelation_values.csv
│   │   └── channel_coordinates.csv
│   │
│   └── preprocessing_info/
│       ├── quality_metrics.csv (trial counts, SNR, etc.)
│       ├── artifact_rejection_log.csv
│       └── preprocessing_parameters.json
│
├── source_data/
│   ├── Source_Data_Fig2.xlsx
│   ├── Source_Data_Fig3.xlsx
│   ├── Source_Data_Fig4.xlsx
│   ├── Source_Data_Fig5.xlsx
│   └── Source_Data_Supplementary_Figs.xlsx
│
├── metadata/
│   ├── data_dictionary.xlsx (all variable definitions)
│   ├── analysis_parameters.json (all analysis settings)
│   └── channel_info.csv (EEG 10-20 locations)
│
└── documentation/
    ├── preprocessing_pipeline.pdf
    ├── analysis_workflow.pdf
    └── BIDS_description.json
```

---

## SECTION 5: DATA DICTIONARY TEMPLATE

### Create `data_dictionary.xlsx` with these sheets:

**Sheet 1: Behavioral Variables**

| Variable | Description | Type | Range/Values | Units | Missing Code |
|----------|-------------|------|--------------|-------|--------------|
| SubjectID | Anonymous participant identifier | String | SG_101 to UK_135 | - | NA |
| Age | Age at testing | Numeric | 8.5-10.5 | months | -999 |
| Sex | Biological sex | Categorical | 1=Male, 2=Female | - | -999 |
| Country | Testing site | Categorical | 1=Singapore, 2=UK | - | NA |
| Condition | Gaze condition | Categorical | 1=Full, 2=Partial, 3=No | - | NA |
| Block | Block number | Integer | 1-3 | - | NA |
| Learning | Post-pre looking time difference | Numeric | -0.5 to 0.5 | proportion | -999 |
| LookingTime_Post | Looking time to nonword | Numeric | 0-30 | seconds | -999 |
| LookingTime_Pre | Looking time to word | Numeric | 0-30 | seconds | -999 |
| Attention | Looking time to speaker | Numeric | 0-60 | seconds | -999 |
| CDI_Production | Words produced | Integer | 0-100 | count | -999 |
| CDI_Comprehension | Words understood | Integer | 0-100 | count | -999 |

**Sheet 2: EEG Variables**

| Variable | Description | Type | Range/Values | Units | Missing Code |
|----------|-------------|------|--------------|-------|--------------|
| GPDC_AI | Adult-to-infant connectivity | Numeric | 0-1 | normalized | -999 |
| GPDC_IA | Infant-to-adult connectivity | Numeric | 0-1 | normalized | -999 |
| Connection | Channel pair | String | e.g., "Fz_F4" | - | NA |
| FreqBand | Frequency band | String | "delta", "theta", "alpha" | - | NA |
| CrossCorr | Neural-speech cross-correlation | Numeric | -1 to 1 | Pearson r | -999 |
| Channel | EEG channel | String | Fz, F3, F4, Cz, etc. | - | NA |
| Lag | Time lag | Integer | -500 to 500 | milliseconds | NA |
| TrialCount | Number of clean epochs | Integer | 10-100 | count | -999 |
| SNR | Signal-to-noise ratio | Numeric | 1-20 | dB | -999 |

---

## SECTION 6: GITHUB REPOSITORY README TEMPLATE

### Create `README.md` for GitHub repository:

````markdown
# Adult-Infant Neural Coupling and Social Learning

Analysis code for: **"Adult-infant neural coupling mediates infants' selection of socially-relevant stimuli for learning across cultures"**

[Authors], Nature Communications, 2025

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXX)

## Overview

This repository contains all analysis code used to process EEG data, calculate connectivity metrics, and perform statistical analyses for our study on how adult speaker gaze modulates infant neural coupling and learning.

## Repository Structure

```
├── preprocessing/           # EEG preprocessing scripts
├── analysis/               # Main statistical analyses
├── utils/                  # Utility functions
├── plotting/               # Figure generation scripts
├── tests/                  # Unit tests
└── docs/                   # Documentation
```

## Quick Start

1. **Install dependencies** (see DEPENDENCIES.md)
2. **Download data** from OSF: https://osf.io/[ID]/
3. **Run preprocessing**: `preprocessing/run_all_preprocessing.m`
4. **Run analyses**: `analysis/run_main_analyses.m`
5. **Generate figures**: `plotting/create_all_figures.m`

## Requirements

- MATLAB R2022a or later
- EEGLAB v2022.0
- FieldTrip toolbox
- Statistics and Machine Learning Toolbox

See `DEPENDENCIES.md` for complete list and installation instructions.

## Data

Data are available at: https://osf.io/[PROJECT_ID]/

## Citation

If you use this code, please cite:

```
[Your citation here]
```

## License

MIT License - see LICENSE file

## Contact

Questions? Open an issue or contact [corresponding author email]
````

---

## SECTION 7: ZENODO ARCHIVING INSTRUCTIONS

### Step-by-Step Zenodo Integration:

1. **Enable Zenodo-GitHub Integration**
   - Log in to Zenodo: https://zenodo.org/
   - Go to GitHub settings: https://zenodo.org/account/settings/github/
   - Find your repository and flip the switch to ON

2. **Create GitHub Release**
   - Go to your GitHub repository
   - Click "Releases" → "Create a new release"
   - Tag version: `v1.0.0` (for initial submission)
   - Release title: "Publication Version - Nature Communications"
   - Description: "Code as used in [Your paper title]. DOI: [manuscript DOI once available]"
   - Click "Publish release"

3. **Get Zenodo DOI**
   - Go back to Zenodo
   - Your release should now appear
   - Get the DOI badge markdown
   - Add to GitHub README
   - Copy DOI for Code Availability statement

---

## SECTION 8: SOURCE DATA FILE PREPARATION

### For Each Figure, Create Excel File with These Sheets:

**Example: Source_Data_Fig2.xlsx**

**Sheet 1: Learning_Scores**
- Columns: SubjectID, Condition, Block, Learning_Score, Age, Sex, Country
- One row per participant-condition-block combination
- Include all data points shown in figure

**Sheet 2: Summary_Statistics**
- Columns: Condition, N, Mean, SD, SE, CI_Lower, CI_Upper
- Summary stats used for error bars

**Sheet 3: Statistical_Tests**
- Columns: Comparison, Test, Statistic, df, p_value, q_value, Effect_Size, CI_Lower, CI_Upper
- All tests reported in figure caption

**Sheet 4: Figure_Metadata**
- Figure panel labels
- Colors used (RGB values)
- Symbol definitions
- Axis ranges

---

## SECTION 9: READY-TO-COPY FOR RESPONSE LETTER

```
EDITORIAL REQUIREMENT 2: DATA AND CODE AVAILABILITY

We have comprehensively addressed data and code availability as follows:

✅ DATA AVAILABILITY SECTION: Added immediately after Methods section
   • All behavioral data publicly available on OSF (https://osf.io/[ID]/)
   • GPDC connectivity matrices publicly available
   • Neural entrainment data publicly available
   • Preprocessed EEG available with data sharing agreement
   • DOI: 10.17605/OSF.IO/[ID]

✅ CODE AVAILABILITY SECTION: Added immediately after Data Availability
   • All analysis code on GitHub: https://github.com/[username]/infant-neural-coupling
   • Archived version on Zenodo: DOI 10.5281/zenodo.[ID]
   • Includes preprocessing, analysis, visualization, and utility functions
   • Comprehensive documentation (README, dependencies, troubleshooting)
   • MIT License for open reuse

✅ SOURCE DATA FILES: Created for all figures
   • Source Data Fig 2-5 (main figures)
   • Source Data Supplementary Figs (all supplementary figures)
   • Excel format with multiple sheets (data, statistics, metadata)

✅ DOCUMENTATION:
   • Comprehensive data dictionary with all variable definitions
   • Analysis parameters file (JSON format)
   • README files for both data and code repositories
   • BIDS-compliant organization where applicable

All repositories follow FAIR principles (Findable, Accessible, Interoperable, Reusable)
to maximize transparency and reproducibility.
```

---

## SECTION 10: DEPENDENCIES.md FILE CONTENT

### Create `DEPENDENCIES.md` in GitHub repository:

```markdown
# Software Dependencies

## Required Software

### MATLAB
- Version: R2022a or later
- Required Toolboxes:
  - Statistics and Machine Learning Toolbox (version 12.3 or later)
  - Signal Processing Toolbox (version 9.0 or later)
  - Parallel Computing Toolbox (optional, for speed)

### EEGLAB
- Version: v2022.0
- Download: https://sccn.ucsd.edu/eeglab/download.php
- Installation: Extract to `external/eeglab/` and run `eeglab` in MATLAB
- Required plugins:
  - clean_rawdata (v2.3)
  - Biosig (v3.7.9)

### FieldTrip
- Version: 20220104 or later
- Download: https://www.fieldtriptoolbox.org/download/
- Installation: Extract to `external/fieldtrip/` and run `ft_defaults` in MATLAB

## Installation Instructions

1. Clone this repository
2. Install MATLAB with required toolboxes
3. Download and install EEGLAB
4. Download and install FieldTrip
5. Run `setup.m` to add all paths
6. Run `run_tests.m` to verify installation

## Version Information

This analysis was conducted using:
- MATLAB R2022a (9.12.0.1884302)
- EEGLAB v2022.0
- FieldTrip-20220104
- Windows 10 / macOS 12.3 / Ubuntu 20.04

## Hardware Requirements

Minimum:
- 16 GB RAM
- 4 CPU cores
- 50 GB free disk space

Recommended:
- 32 GB RAM
- 8 CPU cores
- 100 GB SSD

## Troubleshooting

See TROUBLESHOOTING.md for common issues and solutions.
```

---

## DOCUMENT COMPLETE

**Status**: ✅ Ready for implementation
**Estimated time**: 4-6 hours
**Priority**: High (required for submission)

**Next Steps**:
1. Create OSF project and upload data
2. Create/clean GitHub repository
3. Archive on Zenodo
4. Add sections to manuscript
5. Create Source Data files

---

*End of Data/Code Availability Document*
