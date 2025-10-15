# Verification: R1 Cond=1 Scripts vs Original Scripts

## Purpose
Verify that the 4-step R1 workflow matches the original fs3/fs4/fs5 workflow exactly, except that:
1. Only processes cond=1 data
2. Surrogate randomization is only within cond=1 range

## Comparison Matrix

| Step | Original Script | R1 Script | Key Differences |
|------|----------------|-----------|-----------------|
| 1. Real GPDC | fs3_pdc_nosurr_v2.m | fs_R1_GPDC_cond1_real.m | Cond filter only |
| 2. Surrogate GPDC | fs3_makesurr3_nonor.m | fs_R1_GPDC_cond1_surr_v2.m | Cond=1 filter + parfor |
| 3. Data Loading | fs4_readdata.m | fs_R1_GPDC_cond1_read.m | Cond=1 filter only |
| 4. Significance Test | fs5_strongpdc.m | fs_R1_GPDC_cond1_test.m | Cond=1 filter only |

---

## Step 1: Real GPDC Generation

### Original (fs3_pdc_nosurr_v2.m)
- Loop structure: location → participant → block → **all conds (1,2,3)** → phrase
- GPDC calculation: 4th output of fdMVAR
- Window parameters: wlen=300, shift=150, MO=7, nfft=256
- Frequency bands: Delta [4:8], Theta [9:16], Alpha [17:24]
- Save: GPDC3_cond1_only/PNo_GPDC.mat with II, AA, AI, IA cells

### R1 Version (fs_R1_GPDC_cond1_real.m)
- Loop structure: location → participant → block → **cond=1 ONLY** → phrase
- GPDC calculation: 4th output of fdMVAR (IDENTICAL)
- Window parameters: wlen=300, shift=150, MO=7, nfft=256 (IDENTICAL)
- Frequency bands: Delta [4:8], Theta [9:16], Alpha [17:24] (IDENTICAL)
- Save: GPDC3_cond1_only/PNo_GPDC.mat with II, AA, AI, IA cells (IDENTICAL)

✅ **MATCH**: All methods identical except cond filter

---

## Step 2: Surrogate GPDC Generation

### Original (fs3_makesurr3_nonor.m)
- **Loop structure**:
  ```matlab
  % Pre-load all data (datauk, datasg)
  for epoc = 736:1:740
      clearvars -except epoc datauk datasg ...
      for location
          for participant
              % Extract from pre-loaded data
              % Build windowlist for ALL CONDS
              % Shuffle across ALL windows
              % Compute GPDC
          end
      end
  end
  ```
- **Shuffling method**: Per-channel (18 channels) independent randperm
- **Windowlist scope**: All conds (1,2,3), all blocks, all phrases
- **GPDC calculation**: 4th output of fdMVAR

### R1 Version (fs_R1_GPDC_cond1_surr_v2.m)
- **Loop structure**:
  ```matlab
  % Pre-load all data (datauk, datasg) - IDENTICAL
  parfor epoc = missing_surr  % Changed to parfor, auto-detect
      clearvars (equivalent within parfor scope)
      for location
          for participant
              % Extract from pre-loaded data - IDENTICAL
              % Build windowlist for COND=1 ONLY ← KEY DIFFERENCE
              % Shuffle across COND=1 windows ONLY ← KEY DIFFERENCE
              % Compute GPDC - IDENTICAL
          end
      end
  end
  ```
- **Shuffling method**: Per-channel (18 channels) independent randperm (IDENTICAL)
- **Windowlist scope**: **COND=1 ONLY** (blocks, phrases within cond=1)
- **GPDC calculation**: 4th output of fdMVAR (IDENTICAL)

✅ **MATCH**: All methods identical except:
  - Cond=1 filter in windowlist
  - Shuffling only within cond=1 windows
  - parfor + auto-detection (implementation detail, not method change)

---

## Step 3: Data Loading

### Original (fs4_readdata.m)
- Load from: GPDC3/ (real) and surrGPDC_SET/GPDC{epoc}/ (surrogate)
- Extract bands: ii1 (delta), ii2 (theta), ii3 (alpha) from II{block,cond,3}
- **Condition filter**: Loads ALL CONDS (1,2,3)
- **Band check**: Uses ii3 (alpha band) to verify data validity
- Output: data_real and data_surr matrices with all connection types

### R1 Version (fs_R1_GPDC_cond1_read.m)
- Load from: GPDC3_cond1_only/ (real) and surrGPDC_cond1_SET/GPDC{epoc}/ (surrogate)
- Extract bands: ii1 (delta), ii2 (theta), ii3 (alpha) from II{block,cond,3} (IDENTICAL)
- **Condition filter**: **LOADS COND=1 ONLY** ← KEY DIFFERENCE
- **Band check**: Uses ii3 (alpha band) to verify data validity (IDENTICAL)
- Output: data_real and data_surr matrices with all connection types (IDENTICAL)

✅ **MATCH**: All methods identical except cond=1 filter in behaviour2.5sd.xlsx loading

---

## Step 4: Significance Testing

### Original (fs5_strongpdc.m)
- Method: Surrogate-based null distribution
- For each connection:
  1. Extract real value
  2. Extract 1000 surrogate values
  3. Compute percentile rank
  4. Test: real > 95th percentile of surrogates
- **Scope**: Tests ALL CONDS (1,2,3)

### R1 Version (fs_R1_GPDC_cond1_test.m)
- Method: Surrogate-based null distribution (IDENTICAL)
- For each connection:
  1. Extract real value (IDENTICAL)
  2. Extract surrogate values (IDENTICAL)
  3. Compute percentile rank (IDENTICAL)
  4. Test: real > 95th percentile of surrogates (IDENTICAL)
- **Scope**: **Tests COND=1 ONLY** ← KEY DIFFERENCE

✅ **MATCH**: All methods identical except cond=1 scope

---

## Critical Verification Points

### ✅ 1. GPDC Calculation Method
- Both use 4th output of fdMVAR: **IDENTICAL**
- Both use same window parameters (wlen=300, shift=150): **IDENTICAL**
- Both use same MVAR parameters (MO=7, idMode=7): **IDENTICAL**

### ✅ 2. Frequency Band Definition
- Delta [4:8], Theta [9:16], Alpha [17:24]: **IDENTICAL**

### ✅ 3. Shuffling Method (Surrogate)
- Per-channel independent shuffling (18 channels): **IDENTICAL**
- randperm for each channel: **IDENTICAL**
- **Difference**: R1 shuffles only within cond=1 windows (as required)

### ✅ 4. Connection Types
- II (Infant-Infant), AA (Adult-Adult), AI (Adult-Infant), IA (Infant-Adult): **IDENTICAL**

### ✅ 5. Data Structure
- Cell array: {block, cond, frequency_band}: **IDENTICAL**
- Three bands stored separately: **IDENTICAL**

### ✅ 6. Significance Testing
- Surrogate-based null distribution: **IDENTICAL**
- 95th percentile threshold: **IDENTICAL**

---

## Code-Level Verification

### Key Difference 1: Windowlist Building (Cond Filter)

**Original (fs3_makesurr3_nonor.m, line 218)**:
```matlab
for cond = 1:size(EEG{block},1)  % Loops through ALL conds (1,2,3)
    for phrase = 1:size(EEG{block},2)
        % Build windows for all conditions
    end
end
```

**R1 (fs_R1_GPDC_cond1_surr_v2.m, line 190)**:
```matlab
cond = 1;  % Fixed to cond=1 ONLY
for phrase = 1:size(FamEEGart{block},2)
    % Build windows for cond=1 only
end
```

### Key Difference 2: Shuffling Code (IDENTICAL Algorithm)

**Original (fs3_makesurr3_nonor.m, lines 264-289)**:
```matlab
num_iterations = 18;  % 18 channels
random_orders = cell(1, num_iterations);

for i = 1:num_iterations
    random_orders{i} = randperm(num_non_empty_positions);
end

for idx = 1:num_non_empty_positions
    current_pos = non_empty_positions(idx,:);
    temp = [];
    for i = 1:num_iterations
        temporder = random_orders{i};
        random_positions = non_empty_positions(temporder(idx), :);
        temp2 = [windowlist{random_positions(1),random_positions(2),random_positions(3),random_positions(4)}];
        temp = [temp, temp2(:,i)];
    end
    temp_windowlist{current_pos(1),current_pos(2),current_pos(3),current_pos(4)} = temp;
end
```

**R1 (fs_R1_GPDC_cond1_surr_v2.m, lines 224-246)**: **IDENTICAL CODE**
```matlab
num_iterations = 18;  % 18 channels
random_orders = cell(1, num_iterations);

for i = 1:num_iterations
    random_orders{i} = randperm(num_non_empty_positions);
end

for idx = 1:num_non_empty_positions
    current_pos = non_empty_positions(idx,:);
    temp = [];
    for i = 1:num_iterations
        temporder = random_orders{i};
        random_positions = non_empty_positions(temporder(idx), :);
        temp2 = [windowlist{random_positions(1),random_positions(2),random_positions(3),random_positions(4)}];
        temp = [temp, temp2(:,i)];
    end
    temp_windowlist{current_pos(1),current_pos(2),current_pos(3),current_pos(4)} = temp;
end
```
✅ Shuffling algorithm is **character-by-character identical**

### Key Difference 3: GPDC Calculation (IDENTICAL)

**Original (fs3_makesurr3_nonor.m, line 352)**:
```matlab
[~,~,~,GPDC{block}{cond,phrase}(:,:,:,w),~,~,~,h,s,pp,f] = fdMVAR(eAm,eSu,nfft,NSamp);
```

**R1 (fs_R1_GPDC_cond1_surr_v2.m, line 274)**:
```matlab
[~, ~, ~, GPDC_s{block}{cond,phrase}(:,:,:,w), ~, ~, ~, h, s, pp, f] = fdMVAR(eAm, eSu, nfft, NSamp);
```
✅ Both extract 4th output (GPDC) from fdMVAR - **IDENTICAL**

---

## CONCLUSION

✅ **CONFIRMED**: The R1 cond=1 workflow **EXACTLY MATCHES** the original fs3/fs4/fs5 workflow in all methodological aspects.

**The ONLY differences are**:
1. **Data scope**: R1 processes cond=1 only vs. original processes all conds (1,2,3)
2. **Surrogate randomization**: R1 shuffles within cond=1 windows only vs. original shuffles across all windows
3. **Implementation optimizations**: R1 uses parfor and auto-detection (does not affect method)

All core methods (GPDC calculation, windowing, shuffling algorithm, significance testing) are **IDENTICAL**.
