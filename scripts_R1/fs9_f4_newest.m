%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 MAIN ANALYSIS - FIGURE 4 & SECTION 2.2-2.4
%%
%% PURPOSE:
%% This script performs the core PLS analyses linking neural connectivity
%% to behavioral outcomes, demonstrating the double dissociation between
%% AI and II GPDC (Section 2.2), and tests mediation models (Section 2.4).
%%
%% MANUSCRIPT RESULTS PRODUCED BY THIS FILE:
%% - Result 2.2.1: AI GPDC → Learning (R² = 24.6%)
%% - Result 2.2.2: II GPDC → CDI gestures (R² = 33.7%)
%% - Result 2.2.3: Double dissociation (t1998 = 27.7 and 44.7, p < .0001)
%% - Result 2.4.1: AI GPDC mediates Gaze → Learning (β = 0.52, p < .01)
%% - Supp Section 3: Delta and Theta band GPDC analysis
%%
%% MANUSCRIPT QUOTES:
%% "As shown in Fig. 4a, the PLS analyses revealed that only adult-infant
%% (AI) GPDC connectivity significantly predicted infant learning, with the
%% first AI GPDC component explaining 24.6% of variance in infant learning.
%% By contrast, within-infant (II) GPDC connectivity did not significantly
%% predict infant learning. However, II GPDC components did significantly
%% predict infants' CDI gesture scores (see Fig. 4b), with the first II
%% component explaining 33.7% of variance in CDI gesture."
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REQUIRED INPUT FILES (DEPENDENCIES):
%%
%% 1. ENTRIANSURR.mat - Neural speech entrainment data
%%    - Source: fs8_entrain2_surr.m
%%    - Contains: 1000 permutation surrogates + real NSE data
%%    - Variables: permutable (cell array of surrogate tables)
%%
%% 2. dataGPDC.mat - GPDC connectivity data
%%    - Source: fs3_pdc_nosurr_v2.m
%%    - Contains: Real GPDC matrices (226 trials × 972 connections)
%%    - Variables: data matrix with columns:
%%      [Country, ID, Age, Sex, Block, Condition, Learning, CDI, ...]
%%
%% 3. data_read_surr_gpdc2.mat - GPDC with surrogates
%%    - Source: fs5_strongpdc.m preprocessing
%%    - Contains: data (real), data_surr (1000 surrogates)
%%    - Size: 226 trials × (10 demo cols + 972 GPDC connections)
%%
%% 4. stronglistfdr5_gpdc_II.mat - Significant II connections
%%    - Source: fs5_strongpdc.m
%%    - Contains: s4 (indices of significant connections, FDR < 0.05)
%%    - For alpha band: ~30-50 significant II connections
%%
%% 5. stronglistfdr5_gpdc_AI.mat - Significant AI connections
%%    - Source: fs5_strongpdc.m
%%    - Contains: s4 (indices of significant connections, FDR < 0.05)
%%    - For alpha band: ~30-50 significant AI connections
%%
%% 6. stronglistfdr5_gpdc_AA.mat - Significant AA connections
%%    - Source: fs5_strongpdc.m
%%    - Contains: s4 (indices)
%%
%% 7. CDI2.mat - MacArthur-Bates CDI gesture scores
%%    - Source: Behavioral assessment
%%    - Variables: CDIG (CDI gesture production scores)
%%
%% 8. TABLE.xlsx - NSE data organized by condition
%%    - Source: fs8_entrain5_surrread.m
%%    - Columns: ID, Block, Condition, Phrase, NSE features (54 cols)
%%    - NSE columns: alpha_peak(9), alpha_lag(9), theta_peak(9),
%%                   theta_lag(9), delta_peak(9), delta_lag(9)
%%
%% FOR SUPPLEMENTARY SECTION 3 (Other frequency bands):
%% 9. stronglistfdr5_gpdc_IItheta.mat - Theta band (4-6 Hz)
%% 10. stronglistfdr5_gpdc_AItheta.mat
%% 11. stronglistfdr5_gpdc_IIdelta.mat - Delta band (1-3 Hz)
%% 12. stronglistfdr5_gpdc_AIdelta.mat
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KEY PARAMETERS (DO NOT MODIFY - THESE ENSURE REPRODUCIBILITY):
%%
%% GPDC DATA STRUCTURE:
%% - data matrix size: 226 rows (trials) × 982 columns
%% - Column 1: Country (1=UK, 2=SG)
%% - Column 2: Subject ID (1101-1135 for UK, 2101-2127 for SG)
%% - Column 3: Age (months)
%% - Column 4: Sex (1=Male, 2=Female)
%% - Column 5: Block (1, 2, or 3)
%% - Column 6: Condition (1=Full gaze, 2=Partial, 3=No gaze)
%% - Column 7: Learning (looking time difference: nonword - word)
%% - Column 8: LEARN (alternative learning measure)
%% - Column 9: Attention (total attention duration)
%% - Column 10: (unused)
%% - Columns 11-982: GPDC connections (972 total)
%%   - Columns 11-91:   II delta (81 connections: 9×9 infant→infant)
%%   - Columns 92-172:  II theta (81 connections)
%%   - Columns 173-253: II alpha (81 connections) [MAIN TEXT]
%%   - Columns 254-334: AA delta (81 connections: 9×9 adult→adult)
%%   - Columns 335-415: AA theta (81 connections)
%%   - Columns 416-496: AA alpha (81 connections)
%%   - Columns 497-577: AI delta (81 connections: 9×9 adult→infant)
%%   - Columns 578-658: AI theta (81 connections)
%%   - Columns 659-739: AI alpha (81 connections) [MAIN TEXT]
%%   - Columns 740-820: IA delta (81 connections: 9×9 infant→adult)
%%   - Columns 821-901: IA theta (81 connections)
%%   - Columns 902-982: IA alpha (81 connections)
%%
%% NSE DATA STRUCTURE (data2 matrix):
%% - Size: 226 rows × 54 columns
%% - Columns 1-3: (unused in this file)
%% - Columns 4-12: alpha_peak (9 channels: F3, Fz, F4, C3, Cz, C4, P3, Pz, P4)
%% - Columns 13-21: alpha_lag
%% - Columns 22-30: theta_peak (9 channels)
%% - Columns 31-39: theta_lag
%% - Columns 40-48: delta_peak (9 channels)
%% - Columns 49-54: delta_lag (first 6 channels only)
%%
%% CRITICAL FEATURE COLUMNS (used in mediation analysis):
%% - alphac3 = data2(:,4)   = column 4  (alpha C3 peak)
%% - alphapz = data2(:,8)   = column 8  (alpha Pz peak)
%% - thetaf4 = data2(:,21)  = column 21 (theta F4 peak)
%% - deltaf4 = data2(:,39)  = column 39 (delta F4 peak)
%%
%% PLS PARAMETERS:
%% - n_components = 1 for variance explained analyses (Results 2.2.1-2.2.2)
%% - n_components = 10 for cross-validation (Result 2.2.3)
%% - n_bootstrap = 1000 for double dissociation (Result 2.2.3)
%% - n_folds = 10 for cross-validation (Result 2.2.3)
%%
%% TRANSFORMATION:
%% - GPDC values are SQUARE-ROOT transformed: sqrt(GPDC)
%%   Reason: Normalize distribution for statistical testing
%% - All variables z-scored before PLS: zscore(X)
%%   Reason: Standardize scales for regression
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CODE FLOW OVERVIEW:
%%
%% SECTION 1: Data Loading and Preparation (Lines 1-180)
%%   - Load all required .mat files
%%   - Match NSE data with GPDC data by subject/block/condition
%%   - Extract significant connection indices
%%   - Apply square-root transformation to GPDC
%%
%% SECTION 2: Frequency Band Selection (Lines 149-230)
%%   - Lines 149-172: Alpha band (MAIN TEXT - currently active)
%%   - Lines 196-207: Theta band (Supp S3 - commented out)
%%   - Lines 220-230: Delta band (Supp S3 - commented out)
%%   ⚠️ IMPORTANT: Only uncomment ONE band at a time!
%%
%% SECTION 3: PLS Component Creation (Lines 228-260)
%%   - Create AI and II GPDC components using PLS
%%   - Extract first component scores (XS(:,1))
%%   - These components used in subsequent analyses
%%
%% SECTION 4: Double Dissociation Analysis (Lines 664-1050)
%%   Part A (Lines 664-751): AI vs II for predicting CDI gestures
%%     - 10-fold cross-validation with 1000 bootstrap iterations
%%     - Result: II better than AI (t1998 = 44.7, p < .0001)
%%   Part B (Lines 767-848): AI vs II for predicting Learning
%%     - Same bootstrap CV structure
%%     - Result: AI better than II (t1998 = 27.7, p < .0001)
%%   Part C (Lines 869-969): Repeat for Learning → CDI comparison
%%     - t-tests comparing performance distributions
%%
%% SECTION 5: Figure 4C - PLS Component Loadings (Lines 1135-1349)
%%   - Visualize which connections contribute to components
%%   - Create 9×9 heatmaps showing loading strength
%%   - Separate plots for II and AI GPDC
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NOTES FOR REPRODUCIBILITY:
%%
%% 1. FILE PATHS:
%%    - Update 'path' variable (Line 7-8) to match your directory structure
%%    - All other paths are relative to this base path
%%
%% 2. FREQUENCY BAND SWITCHING (for Supplementary Section 3):
%%    - To run THETA band analysis:
%%      a) Comment out Lines 157-162 (alpha band loading)
%%      b) Uncomment Lines 196-207 (theta band loading)
%%      c) Run entire script
%%    - To run DELTA band analysis:
%%      a) Comment out Lines 157-162 (alpha band loading)
%%      b) Uncomment Lines 220-230 (delta band loading)
%%      c) Run entire script
%%    - ⚠️ DO NOT uncomment multiple bands simultaneously!
%%
%% 3. VARIABLE NAME CONSISTENCY:
%%    - Despite band switching, variable names remain 'ii', 'ai', 'aa'
%%    - This is intentional to avoid changing downstream code
%%    - The actual frequency content changes based on which .mat is loaded
%%
%% 4. SAVE COMMANDS:
%%    - All save() commands commented out with "%%" prefix (R1 safety)
%%    - Uncomment only if you need to regenerate intermediate files
%%    - Recommended: Keep commented to prevent accidental overwrites
%%
%% 5. RANDOM SEED:
%%    - Bootstrap resampling uses MATLAB's default random seed
%%    - For exact reproducibility, add: rng(0, 'twister') at line 665
%%    - Current version uses unseeded random for robustness demonstration
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CROSS-REFERENCE TO OTHER SCRIPTS:
%%
%% This file depends on outputs from:
%% - fs3_pdc_nosurr_v2.m (GPDC calculation)
%% - fs5_strongpdc.m (significance testing)
%% - fs8_entrain1.m, fs8_entrain2_surr.m (NSE calculation)
%%
%% This file's outputs used in:
%% - fs11_testplotfigure4CD.m (Figure 4D scalp topoplots)
%% - fs9_redof6.m (Mediation analysis - loads some same data)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LAST UPDATED: 2025-10-09 (R1 comprehensive annotation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear all
load('ENTRIANSURR.mat');
load("dataGPDC.mat");
% Read the CSV file
path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'
%path='C:\Users\Admin\OneDrive - Nanyang Technological University\/'

[a, b] = xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/entrain/TABLE.xlsx']);

tableorder=[];

data2=zeros(226,54);

for i=1:length(a)
    id=b{i+1,1};
    if isequal(id(6),'C')==1
        country=1;
    else
        country=2;
    end
   id2=str2num(id(3:5));
   bl=a(i,1);
   c=a(i,2);
   p=a(i,3);
   if p==1
       for j=1:size(data,1)
           if data(j,1)==country&&data(j,2)-data(j,1)*1000==id2&&data(j,5)==bl&& data(j,6)==c
               % only phrase 1 's entrainment versus average GPDC
               data2(j,:)=nanmean(a(i:i,4:57),1);
                   tableorder(j)=i;
               break
           end
       end
   end
end

for i=1:size(data2,1)
    if sum(data2(i,:))==0
        data2(i,:)=nan;
    end
end

alphac3=data2(:,4);
alphapz=data2(:,8);
thetaf4=data2(:,21);
deltaf4=data2(:,39);
learning=data(:,7);
learning2=data(:,8);
atten=data(:,9);

data2_surr=cell(1000,1);
for i=1:1000
    i
    tmp=permutable{i};
    tmp2=zeros(226,54);
    for j=1:226
        if tableorder(j)~=0
            tmp2(j,:)=table2array(tmp(tableorder(j),5:end));
        else
             tmp2(j,:)=nan;
        end
    end
    data2_surr{i}=tmp2;
end


%% load surr gpdc
load('data_read_surr_gpdc2.mat')
a=data;
g1=find(a(:,6)==1);
g2=find(a(:,6)==2);
g3=find(a(:,6)==3);
g4=find(a(:,6)<=2);

b1=find(a(:,5)==1);
b2=find(a(:,5)==2);
b3=find(a(:,5)==3);
AGE=a(:,3);
SEX=a(:,4);
SEX=categorical(SEX);
COUNTRY=a(:,1);
COUNTRY=categorical(COUNTRY);
blocks=a(:,5);
blocks=categorical(blocks);
CONDGROUP=a(:,6);
CONDGROUP(find(CONDGROUP==3))=2;
CONDGROUP=categorical(CONDGROUP);
learning= a(:, 7);
nww=a(:,8);
atten=a(:,9);
ID=a(:,2);
ID=categorical(ID);

% % Generate titles
countryTitles = 'Country';
sexTitles = 'Sex';
blockTitles = 'Block';
ageTitle = {'Age'};
learningTitle = {'Learning'};
attenTitle = {'atten'};
% Generate titles for the connections
nodes = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
frequencyBands = {'Delta', 'Theta', 'Alpha'};
connectionTypes = {'II', 'AA', 'AI', 'IA'};

connectionTitles = {};
for conn = 1:length(connectionTypes)
    for freq = 1:length(frequencyBands)

        for src = 1:length(nodes)
            for dest = 1:length(nodes)
                    connectionTitles{end+1} = sprintf('%s_%s_%s_to_%s', connectionTypes{conn}, frequencyBands{freq}, nodes{src},nodes{dest});
            end
        end
    end
end

% Combine all titles
titles = [countryTitles, 'ID',ageTitle, sexTitles, blockTitles,'cond', learningTitle,'LEARN',attenTitle, connectionTitles];

% within channel PDC should be nan
block_size = 81;
num_blocks = 12;
initial_cols = 10;
diag_indices = [1, 11, 21, 31, 41, 51, 61, 71, 81];
column_indices = [];
for j = 1:num_blocks
    for d = diag_indices
        col_index = initial_cols + (j-1) * block_size + d;
        column_indices = [column_indices, col_index];
    end
end

% load("data_read_surr2.mat")
% 
% listi = [11:10+243,11+243*2:10+243*3];
% listi=setdiff(listi,column_indices);
% listi = [172:252,658:738];
 ii1=[10:9+81];
 ii2=[10+81*1:9+81*2];
 ii3=[10+81*2:9+81*3];
 aa1=[10+81*3:9+81*4];
 aa2=[10+81*4:9+81*5];
 aa3=[10+81*5:9+81*6];
 ai1=[10+81*6:9+81*7];
 ai2=[10+81*7:9+81*8];
 ai3=[10+81*8:9+81*9];
 ia1=[10+81*9:9+81*10];
ia2=[10+81*10:9+81*11];
 ia3=[10+81*11:9+81*12];


% alpha
listi=[ii3];
load('stronglistfdr5_gpdc_II.mat')
listii=listi(s4);
ii=sqrt(data(:,listii));

listi=[ai3];
load('stronglistfdr5_gpdc_AI.mat')
listai=listi(s4);
ai=sqrt(data(:,listai));
% 
% ai_surr=cell(1000,1);
% ii_surr=cell(1000,1);
% for i=1:1000
%     i
%     tmp=data_surr{i};
%     ai_surr{i}=sqrt(tmp(:,listai));
%     ii_surr{i}=sqrt(tmp(:,listii));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 SUPPLEMENTARY SECTION 3 - Delta and Theta Band GPDC Analysis
%% "see Supplementary Materials Section 3 for identical analysis in the
%% delta and theta bands"
%%
%% To run delta/theta band analysis instead of alpha:
%% 1. Comment out alpha band loading (Lines 159-172)
%% 2. Uncomment one of the following sections:
%%    - Lines 181-188: Theta band (4-6 Hz)
%%    - Lines 204-211: Delta band (1-3 Hz)
%% 3. Run the same PLS analysis pipeline (Lines 228-660)
%%
%% Frequency band mapping:
%% - ii1, ai1 = Delta band (1-3 Hz) connections
%% - ii2, ai2 = Theta band (4-6 Hz) connections
%% - ii3, ai3 = Alpha band (6-9 Hz) connections [main text]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
load('CDI2.mat')
CDIG([141,142,143])=0;

%% R1: THETA BAND ANALYSIS (4-6 Hz) - Currently commented out
% % theta
% listi=[ii2];
% load('stronglistfdr5_gpdc_IItheta.mat')  % R1: Load significant theta II connections
% listii=listi(s4);
% ii=sqrt(data(:,listii));
%
% listi=[ai2];
% load('stronglistfdr5_gpdc_AItheta.mat')  % R1: Load significant theta AI connections
% listai=listi(s4);
% ai=sqrt(data(:,listai));
%

% % % theta
% listi=[ii2];
% load('stronglistfdr5_gpdc_IItheta.mat')
% listii=listi(s4);
% ii=sqrt(data(:,listii));
%
% listi=[ai2];
% load('stronglistfdr5_gpdc_AItheta.mat')
% listai=listi(s4);
% ai=sqrt(data(:,listai));

%% R1: DELTA BAND ANALYSIS (1-3 Hz) - Currently commented out
% % delta
% listi=[ii1];
% load('stronglistfdr5_gpdc_IIdelta.mat')  % R1: Load significant delta II connections
% listii=listi(s4);
% ii=sqrt(data(:,listii));
%
% listi=[ai1];
% load('stronglistfdr5_gpdc_AIdelta.mat')  % R1: Load significant delta AI connections
% listai=listi(s4);
% ai=sqrt(data(:,listai));

ai_surr=cell(1000,1);
ii_surr=cell(1000,1);
for i=1:1000
    i
    tmp=data_surr{i};
    ai_surr{i}=sqrt(tmp(:,listai));
    ii_surr{i}=sqrt(tmp(:,listii));
end
load('CDI2.mat')
CDIG([141,142,143])=0;





%% R1 FIG 4A
%% AI CDIG
colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);
valid=find(isnan(CDIG)==0);

for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ai(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        ais = ai_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ais(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color',[ 75/255, 116/255, 178/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 16;            % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 20, 'FontWeight', 'bold');
ylabel('CDI-G variance explained', 'FontSize', 20, 'FontWeight', 'bold');
xlim([1, compall]);
% ylim([0 0.7])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages
legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real AI GPDC'}, 'Location', 'southeast', 'FontSize', 16);
title('CDI-G prediction performance by AI GPDC', 'FontSize', 20, 'FontWeight', 'bold')
hold off;





%%  II CDIG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% % II ~learning
colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);
valid=find(isnan(CDIG)==0);
for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ii(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        iis = ii_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([iis(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color',[252/255, 140/255, 90/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 16;            % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 20, 'FontWeight', 'bold');
ylabel('CDI-G variance explained', 'FontSize', 20, 'FontWeight', 'bold');
xlim([1, compall]);
% ylim([0 0.5])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages
legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real II GPDC'}, 'Location', 'southeast', 'FontSize', 16);
title('CDI-G prediction performance by II GPDC', 'FontSize', 20, 'FontWeight', 'bold')
hold off;

%% R1 with the first II component explaining 33.7% of variance in CDI gesture scores
plotk(1,1)
%% R1 with the first II component explaining 33.7% of variance in CDI gesture scores


%%  AI TO LEARNING alpha
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% predict
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CDIG 

colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);valid=find(isnan(learning)==0);
for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ai(valid,:), data(valid, [1, 3, 4])]), zscore(learning(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        ais = ai_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ais(valid,:), data(valid, [1, 3, 4])]), zscore(learning(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color',[ 75/255, 116/255, 178/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 16;            % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 20, 'FontWeight', 'bold');
ylabel('Learning variance explained', 'FontSize', 20, 'FontWeight', 'bold');
xlim([1, compall]);
%ylim([0,0.6])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages
legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real AI GPDC'}, 'Location', 'southeast', 'FontSize', 16);
title('Learning prediction performance by AI GPDC', 'FontSize', 20, 'FontWeight', 'bold')
hold off;

%% R1 with the first AI GPDC component explaining 24.6% of variance in infant learning
plotk(1,1)
%% R1 with the first AI GPDC component explaining 24.6% of variance in infant learning



%%  II TO LEARNING ALPHA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% predict
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CDIG 

colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);valid=find(isnan(learning)==0);
for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ii(valid,:), data(valid, [1, 3, 4])]), zscore(learning(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        iis = ii_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([iis(valid,:), data(valid, [1, 3, 4])]), zscore(learning(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color',[252/255, 140/255, 90/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 16;            % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 20, 'FontWeight', 'bold');
ylabel('Learning variance explained', 'FontSize', 20, 'FontWeight', 'bold');
xlim([1, compall]);
%ylim([0,0.6])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages
legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real II GPDC'}, 'Location', 'southeast', 'FontSize', 16);
title('Learning prediction performance by II GPDC', 'FontSize', 20, 'FontWeight', 'bold')
hold off;

%% R1 FIG 4A






%%  sup Figure  ENTRAIN - CDIG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% entrain 

% Define labels
%peaklabel = [4:12, 22:30, 40:48];

colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};
entrain=data2(:,[4,5,21,26,40]);
%entrain=data2(:,peaklabel);

compall=8;
plotk = zeros(compall, 4);
valid=intersect(find(isnan(CDIG)==0),find(isnan(data2(:,4))==0));
for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([entrain(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        entrains = data2_surr{i};


        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([entrains(valid,peaklabel-3), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));

    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color', [128/255, 0/255, 128/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 16;            % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 20, 'FontWeight', 'bold');
ylabel('CDI-G variance explained', 'FontSize', 20, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.5])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages

legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real NSE'}, 'Location', 'southeast', 'FontSize', 16);
title('CDI-G prediction performance by NSE', 'FontSize', 20, 'FontWeight', 'bold')
hold off;
% 
% 
% % ENTRAIN CDIW
% 
% 
% %%  sup Figure  ENTRAIN - CDIG
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% entrain 
% 
% % Define labels
% peaklabel = [4:12, 22:30, 40:48];
% 
% colorlist={  [252/255, 140/255, 90/255],...
%     [226/255, 90/255, 80/255],...
%     [ 75/255, 116/255, 178/255],...
%     [144/255, 190/255, 224/255]};
% % entrain=data2(:,[4,5,21,26,40]);
% entrain=data2(:,peaklabel);
% 
% compall=10;
% plotk = zeros(compall, 4);
% valid=intersect(find(isnan(CDIG)==0),find(isnan(data2(:,4))==0));
% for comp = 1:compall  
%     [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([entrain(valid,:), data(valid, [1, 3, 4])]), zscore(CDIP(valid)), comp);
%     PCTVAR_real2 = sum(PCTVAR(2, :));
%     plotk(comp, 1) = PCTVAR_real2;
% 
%     PCTVAR_su2 = zeros(1000, 1);
%     for i = 1:1000
%         entrains = data2_surr{i};
% 
% 
%         [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([entrains(valid,peaklabel-3), data(valid, [1, 3, 4])]), zscore(CDIP(valid)), comp);
%         PCTVAR_su2(i) = sum(PCTVAR(2, :));
% 
%     end
% 
%     plotk(comp, 2) = prctile(PCTVAR_su2, 95);
%     plotk(comp, 3) = mean(PCTVAR_su2);
%     plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
% end
% 
% % Plot settings
% figure;
% hold on;
% 
% % Shaded 0-95% CI in gray
% fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');
% 
% % Mean of surrogates in black
% plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);
% 
% % Real mean in custom color [252, 140, 90]
% plot(1:compall, plotk(:, 1), 'Color', [128/255, 0/255, 128/255], 'LineWidth', 3);
% 
% % Customize the axes
% ax = gca;
% ax.Box = 'on';               % Show borders for all sides
% ax.XColor = 'k';              % Set color of x-axis to black
% ax.YColor = 'k';              % Set color of y-axis to black
% ax.LineWidth = 2;           % Set axis line width
% ax.FontName = 'Arial';        % Set font to Arial
% ax.FontSize = 16;            % Set font size
% ax.FontWeight = 'bold';       % Set font to bold
% ax.TickDir = 'in';            % Set ticks to point inward
% ax.Layer = 'top';             % Ensure axes lines are on top
% 
% xlabel('Component number', 'FontSize', 20, 'FontWeight', 'bold');
% ylabel('CDI-P variance explained', 'FontSize', 20, 'FontWeight', 'bold');
% xlim([1, compall]);
% ylim([0,0.6])
% % Set y-axis labels as percentages
% yticks = ax.YTick;  % Get current y-tick values
% ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages
% 
% legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real NSE'}, 'Location', 'southeast', 'FontSize', 16);
% title('CDI-P prediction performance by NSE', 'FontSize', 20, 'FontWeight', 'bold')
% hold off;
% %predict   attention failed
% 
% 
% 
% 


%% R1 Fig. 4e and 4f

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 RESULT 2.2.3 - Double dissociation Part 1: AI/II GPDC → CDI gestures
%% "This cross-validation confirmed that for PLS prediction of learning,
%% AI GPDC performance was significantly higher than that of II GPDC
%% (t1998 = 27.7, p < .0001), whereas for PLS prediction of CDI gesture
%% scores, II GPDC performance was significantly higher than that of AI
%% GPDC (t1998 = 44.7, p < .0001)"
%% Statistical values: t1998 = 44.7, p < .0001 (AI vs II for CDI prediction)
%% Analysis: 10-fold CV with 1000 bootstrap iterations, using AI GPDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cv for ai iigpdc - cdig This cross-validation confirmed that for PLS prediction of learning, AI GPDC performance was significantly higher than that of II GPDC (t1998 = 27.7, p < .0001), whereas for PLS prediction of CDI gesture scores, II GPDC performance was significantly higher than that of AI GPDC (t1998 = 44.7, p < .0001).

%%%%%%%%%%%%%%%%%%%%%%%
%% 1000 boot ii/ai cdig
% rng(28);  % For reproducibility
SEX=double(SEX);
COUNTRY=double(COUNTRY);
% entrain=data2(:,[4,5,21,26,40]);
% valid=find(isnan(data2(:,4))==0);
load('CDI2.mat');
peaklabel=[1:9,19:27,37:45];
%swap ai ii here
tbl = table(ID, atten, zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, ai, ...
    'VariableNames', {'ID','atten', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP', 'ai'});
% for entrain
% tbl=tbl(valid,:);
tbl.ai=zscore(tbl.ai);
for i=1:size(tbl,1)
    id=a(i,2);
    for j=1:47
        if a2(j,1)==id
            tbl.CDIP(i)=a2(j,2);
            tbl.CDIW(i)=a2(j,3);
            tbl.CDIG(i)=a2(j,4);
        end
    end
end
n_folds = 10;  % Number of cross-validation folds
n_bootstrap = 1000;  % Number of bootstrap iterations
mean_variance_explained_bootstrap = zeros(n_bootstrap, 1);  % Store mean variance explained per bootstrap

for boot = 1:n_bootstrap
    % Bootstrap sample of the entire dataset
    bootstrap_idx = datasample(1:height(tbl), height(tbl), 'Replace', true);
    tbl_bootstrap = tbl(bootstrap_idx, :);

    variance_explained = zeros(n_folds, 1);  % Store variance explained per fold for each bootstrap
valid=find(isnan(tbl_bootstrap.CDIG)==0);
tbl_bootstrap=tbl_bootstrap(valid,:);
    % Create cross-validation partition on the bootstrap sample
    cv = cvpartition(height(tbl_bootstrap), 'KFold', n_folds);

    for fold = 1:n_folds
        % Training and test indices based on current fold
        train_idx = training(cv, fold);
        test_idx = test(cv, fold);

        % Prepare predictors (X) and response (Y) for training
        X_train = [tbl_bootstrap.ai(train_idx,:), tbl_bootstrap.AGE(train_idx), tbl_bootstrap.SEX(train_idx), tbl_bootstrap.COUNTRY(train_idx)];
        Y_train = tbl_bootstrap.CDIG(train_idx);

        % Train PLS model
        n_components = 10;  % Number of components
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(X_train, Y_train, n_components);

        % Prepare test data
        X_test = [tbl_bootstrap.ai(test_idx,:), tbl_bootstrap.AGE(test_idx), tbl_bootstrap.SEX(test_idx), tbl_bootstrap.COUNTRY(test_idx)];
        Y_test = tbl_bootstrap.CDIG(test_idx);

        % Calculate test scores using trained model weights
        scores_test = X_test * stats.W;

        % Compute variance explained (R^2) in the test set for this fold
%         variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
%                                         corr(Y_test, scores_test(:, 2))^2, ...
%                                         corr(Y_test, scores_test(:, 3))^2, ...
%                                         corr(Y_test, scores_test(:, 4))^2, ...
%                                         corr(Y_test, scores_test(:, 5))^2]);
        % variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
        %                                 corr(Y_test, scores_test(:, 2))^2]);
        variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2]);
        
    end

    % Mean variance explained for this bootstrap iteration
    mean_variance_explained_bootstrap(boot) = mean(variance_explained);
    boot
end

% Final results
mean_variance_explained = mean(mean_variance_explained_bootstrap);
std_variance_explained = std(mean_variance_explained_bootstrap);

% Display results
fprintf('\nBootstrap Results (1000 iterations) of Mean variance explained with 10-Fold CV:\n');
fprintf('Mean of Mean variance explained = %f, Std of Mean variance explained = %f\n', mean_variance_explained, std_variance_explained);
fprintf('Range of Mean variance explained = [%f, %f]\n', min(mean_variance_explained_bootstrap), max(mean_variance_explained_bootstrap));


ai_performance=mean_variance_explained_bootstrap;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 RESULT 2.2.3 - Double dissociation Part 1: AI/II GPDC → CDI gestures
%% "This cross-validation confirmed that for PLS prediction of learning,
%% AI GPDC performance was significantly higher than that of II GPDC
%% (t1998 = 27.7, p < .0001), whereas for PLS prediction of CDI gesture
%% scores, II GPDC performance was significantly higher than that of AI
%% GPDC (t1998 = 44.7, p < .0001)"
%% Statistical values: t1998 = 44.7, p < .0001 (AI vs II for CDI prediction)
%% Analysis: 10-fold CV with 1000 bootstrap iterations, using AI GPDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cv for ai iigpdc - cdig This cross-validation confirmed that for PLS prediction of learning, AI GPDC performance was significantly higher than that of II GPDC (t1998 = 27.7, p < .0001), whereas for PLS prediction of CDI gesture scores, II GPDC performance was significantly higher than that of AI GPDC (t1998 = 44.7, p < .0001).

%%%%%%%%%%%%%%%%%%%%%%%
%% 1000 boot ii/ai cdig
% rng(28);  % For reproducibility
SEX=double(SEX);
COUNTRY=double(COUNTRY);
% entrain=data2(:,[4,5,21,26,40]);
% valid=find(isnan(data2(:,4))==0);
load('CDI2.mat');
peaklabel=[1:9,19:27,37:45];
%swap ai ii here
tbl = table(ID, atten, zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, ii, ...
    'VariableNames', {'ID','atten', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP', 'ai'});
% for entrain
% tbl=tbl(valid,:);
tbl.ai=zscore(tbl.ai);
for i=1:size(tbl,1)
    id=a(i,2);
    for j=1:47
        if a2(j,1)==id
            tbl.CDIP(i)=a2(j,2);
            tbl.CDIW(i)=a2(j,3);
            tbl.CDIG(i)=a2(j,4);
        end
    end
end
n_folds = 10;  % Number of cross-validation folds
n_bootstrap = 1000;  % Number of bootstrap iterations
mean_variance_explained_bootstrap = zeros(n_bootstrap, 1);  % Store mean variance explained per bootstrap

for boot = 1:n_bootstrap
    % Bootstrap sample of the entire dataset
    bootstrap_idx = datasample(1:height(tbl), height(tbl), 'Replace', true);
    tbl_bootstrap = tbl(bootstrap_idx, :);

    variance_explained = zeros(n_folds, 1);  % Store variance explained per fold for each bootstrap
valid=find(isnan(tbl_bootstrap.CDIG)==0);
tbl_bootstrap=tbl_bootstrap(valid,:);
    % Create cross-validation partition on the bootstrap sample
    cv = cvpartition(height(tbl_bootstrap), 'KFold', n_folds);

    for fold = 1:n_folds
        % Training and test indices based on current fold
        train_idx = training(cv, fold);
        test_idx = test(cv, fold);

        % Prepare predictors (X) and response (Y) for training
        X_train = [tbl_bootstrap.ai(train_idx,:), tbl_bootstrap.AGE(train_idx), tbl_bootstrap.SEX(train_idx), tbl_bootstrap.COUNTRY(train_idx)];
        Y_train = tbl_bootstrap.CDIG(train_idx);

        % Train PLS model
        n_components = 10;  % Number of components
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(X_train, Y_train, n_components);

        % Prepare test data
        X_test = [tbl_bootstrap.ai(test_idx,:), tbl_bootstrap.AGE(test_idx), tbl_bootstrap.SEX(test_idx), tbl_bootstrap.COUNTRY(test_idx)];
        Y_test = tbl_bootstrap.CDIG(test_idx);

        % Calculate test scores using trained model weights
        scores_test = X_test * stats.W;

        % Compute variance explained (R^2) in the test set for this fold
%         variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
%                                         corr(Y_test, scores_test(:, 2))^2, ...
%                                         corr(Y_test, scores_test(:, 3))^2, ...
%                                         corr(Y_test, scores_test(:, 4))^2, ...
%                                         corr(Y_test, scores_test(:, 5))^2]);
        % variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
        %                                 corr(Y_test, scores_test(:, 2))^2]);
        variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2]);
        
    end

    % Mean variance explained for this bootstrap iteration
    mean_variance_explained_bootstrap(boot) = mean(variance_explained);
    boot
end

% Final results
mean_variance_explained = mean(mean_variance_explained_bootstrap);
std_variance_explained = std(mean_variance_explained_bootstrap);

% Display results
fprintf('\nBootstrap Results (1000 iterations) of Mean variance explained with 10-Fold CV:\n');
fprintf('Mean of Mean variance explained = %f, Std of Mean variance explained = %f\n', mean_variance_explained, std_variance_explained);
fprintf('Range of Mean variance explained = [%f, %f]\n', min(mean_variance_explained_bootstrap), max(mean_variance_explained_bootstrap));


ii_performance=mean_variance_explained_bootstrap;

%% R1 , II GPDC performance was significantly higher than that of AI GPDC (t1998 = 44.7, p < .0001).
[h,p,s,t]=ttest2(ai_performance,ii_performance)
%% R1 , II GPDC performance was significantly higher than that of AI GPDC (t1998 = 44.7, p < .0001).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 RESULT 2.2.3 - Double dissociation Part 2: II/AI GPDC → Learning
%% "This cross-validation confirmed that for PLS prediction of learning,
%% AI GPDC performance was significantly higher than that of II GPDC
%% (t1998 = 27.7, p < .0001), whereas for PLS prediction of CDI gesture
%% scores, II GPDC performance was significantly higher than that of AI
%% GPDC (t1998 = 44.7, p < .0001)"
%% Statistical values: t1998 = 27.7, p < .0001 (AI vs II for Learning prediction)
%% Analysis: 10-fold CV with 1000 bootstrap iterations, using II GPDC (line 767 uses 'ii' variable)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%% 1000 boot ii/ai learning This cross-validation confirmed that for PLS prediction of learning, AI GPDC performance was significantly higher than that of II GPDC (t1998 = 27.7, p < .0001), whereas for PLS prediction of CDI gesture scores, II GPDC performance was significantly higher than that of AI GPDC (t1998 = 44.7, p < .0001).
% rng(28);  % For reproducibility
SEX=double(SEX);
COUNTRY=double(COUNTRY);
% entrain=data2(:,[4,5,21,26,40]);
% valid=find(isnan(data2(:,4))==0);
load('CDI2.mat');
peaklabel=[1:9,19:27,37:45];
%swap ai ii here
tbl = table(ID, atten, zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, ii, ...
    'VariableNames', {'ID','atten', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP', 'ai'});
% for entrain
% tbl=tbl(valid,:);
tbl.ai=zscore(tbl.ai);
for i=1:size(tbl,1)
    id=a(i,2);
    for j=1:47
        if a2(j,1)==id
            tbl.CDIP(i)=a2(j,2);
            tbl.CDIW(i)=a2(j,3);
            tbl.CDIG(i)=a2(j,4);
        end
    end
end
n_folds = 10;  % Number of cross-validation folds
n_bootstrap = 1000;  % Number of bootstrap iterations
mean_variance_explained_bootstrap = zeros(n_bootstrap, 1);  % Store mean variance explained per bootstrap

for boot = 1:n_bootstrap
    % Bootstrap sample of the entire dataset
    bootstrap_idx = datasample(1:height(tbl), height(tbl), 'Replace', true);
    tbl_bootstrap = tbl(bootstrap_idx, :);

    variance_explained = zeros(n_folds, 1);  % Store variance explained per fold for each bootstrap
valid=find(isnan(tbl_bootstrap.learning)==0);
tbl_bootstrap=tbl_bootstrap(valid,:);
    % Create cross-validation partition on the bootstrap sample
    cv = cvpartition(height(tbl_bootstrap), 'KFold', n_folds);

    for fold = 1:n_folds
        % Training and test indices based on current fold
        train_idx = training(cv, fold);
        test_idx = test(cv, fold);

        % Prepare predictors (X) and response (Y) for training
        X_train = [tbl_bootstrap.ai(train_idx,:), tbl_bootstrap.AGE(train_idx), tbl_bootstrap.SEX(train_idx), tbl_bootstrap.COUNTRY(train_idx)];
        Y_train = tbl_bootstrap.learning(train_idx);

        % Train PLS model
        n_components = 10;  % Number of components
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(X_train, Y_train, n_components);

        % Prepare test data
        X_test = [tbl_bootstrap.ai(test_idx,:), tbl_bootstrap.AGE(test_idx), tbl_bootstrap.SEX(test_idx), tbl_bootstrap.COUNTRY(test_idx)];
        Y_test = tbl_bootstrap.learning(test_idx);

        % Calculate test scores using trained model weights
        scores_test = X_test * stats.W;

        % Compute variance explained (R^2) in the test set for this fold
%         variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
%                                         corr(Y_test, scores_test(:, 2))^2, ...
%                                         corr(Y_test, scores_test(:, 3))^2, ...
%                                         corr(Y_test, scores_test(:, 4))^2, ...
%                                         corr(Y_test, scores_test(:, 5))^2]);
        % variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
        %                                 corr(Y_test, scores_test(:, 2))^2]);
        variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2]);
    end

    % Mean variance explained for this bootstrap iteration
    mean_variance_explained_bootstrap(boot) = mean(variance_explained);
    boot
end

% Final results
mean_variance_explained = mean(mean_variance_explained_bootstrap);
std_variance_explained = std(mean_variance_explained_bootstrap);

% Display results
fprintf('\nBootstrap Results (1000 iterations) of Mean variance explained with 10-Fold CV:\n');
fprintf('Mean of Mean variance explained = %f, Std of Mean variance explained = %f\n', mean_variance_explained, std_variance_explained);
fprintf('Range of Mean variance explained = [%f, %f]\n', min(mean_variance_explained_bootstrap), max(mean_variance_explained_bootstrap));


ii_performance=mean_variance_explained_bootstrap;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 RESULT 2.2.3 - Double dissociation Part 2: II/AI GPDC → Learning
%% "This cross-validation confirmed that for PLS prediction of learning,
%% AI GPDC performance was significantly higher than that of II GPDC
%% (t1998 = 27.7, p < .0001), whereas for PLS prediction of CDI gesture
%% scores, II GPDC performance was significantly higher than that of AI
%% GPDC (t1998 = 44.7, p < .0001)"
%% Statistical values: t1998 = 27.7, p < .0001 (AI vs II for Learning prediction)
%% Analysis: 10-fold CV with 1000 bootstrap iterations, using II GPDC (line 767 uses 'ii' variable)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%% 1000 boot ii/ai learning This cross-validation confirmed that for PLS prediction of learning, AI GPDC performance was significantly higher than that of II GPDC (t1998 = 27.7, p < .0001), whereas for PLS prediction of CDI gesture scores, II GPDC performance was significantly higher than that of AI GPDC (t1998 = 44.7, p < .0001).
% rng(28);  % For reproducibility
SEX=double(SEX);
COUNTRY=double(COUNTRY);
% entrain=data2(:,[4,5,21,26,40]);
% valid=find(isnan(data2(:,4))==0);
load('CDI2.mat');
peaklabel=[1:9,19:27,37:45];
%swap ai ii here
tbl = table(ID, atten, zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, ai, ...
    'VariableNames', {'ID','atten', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP', 'ai'});
% for entrain
% tbl=tbl(valid,:);
tbl.ai=zscore(tbl.ai);
for i=1:size(tbl,1)
    id=a(i,2);
    for j=1:47
        if a2(j,1)==id
            tbl.CDIP(i)=a2(j,2);
            tbl.CDIW(i)=a2(j,3);
            tbl.CDIG(i)=a2(j,4);
        end
    end
end
n_folds = 10;  % Number of cross-validation folds
n_bootstrap = 1000;  % Number of bootstrap iterations
mean_variance_explained_bootstrap = zeros(n_bootstrap, 1);  % Store mean variance explained per bootstrap

for boot = 1:n_bootstrap
    % Bootstrap sample of the entire dataset
    bootstrap_idx = datasample(1:height(tbl), height(tbl), 'Replace', true);
    tbl_bootstrap = tbl(bootstrap_idx, :);

    variance_explained = zeros(n_folds, 1);  % Store variance explained per fold for each bootstrap
valid=find(isnan(tbl_bootstrap.learning)==0);
tbl_bootstrap=tbl_bootstrap(valid,:);
    % Create cross-validation partition on the bootstrap sample
    cv = cvpartition(height(tbl_bootstrap), 'KFold', n_folds);

    for fold = 1:n_folds
        % Training and test indices based on current fold
        train_idx = training(cv, fold);
        test_idx = test(cv, fold);

        % Prepare predictors (X) and response (Y) for training
        X_train = [tbl_bootstrap.ai(train_idx,:), tbl_bootstrap.AGE(train_idx), tbl_bootstrap.SEX(train_idx), tbl_bootstrap.COUNTRY(train_idx)];
        Y_train = tbl_bootstrap.learning(train_idx);

        % Train PLS model
        n_components = 10;  % Number of components
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(X_train, Y_train, n_components);

        % Prepare test data
        X_test = [tbl_bootstrap.ai(test_idx,:), tbl_bootstrap.AGE(test_idx), tbl_bootstrap.SEX(test_idx), tbl_bootstrap.COUNTRY(test_idx)];
        Y_test = tbl_bootstrap.learning(test_idx);

        % Calculate test scores using trained model weights
        scores_test = X_test * stats.W;

        % Compute variance explained (R^2) in the test set for this fold
%         variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
%                                         corr(Y_test, scores_test(:, 2))^2, ...
%                                         corr(Y_test, scores_test(:, 3))^2, ...
%                                         corr(Y_test, scores_test(:, 4))^2, ...
%                                         corr(Y_test, scores_test(:, 5))^2]);
        % variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
        %                                 corr(Y_test, scores_test(:, 2))^2]);
        variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2]);
    end

    % Mean variance explained for this bootstrap iteration
    mean_variance_explained_bootstrap(boot) = mean(variance_explained);
    boot
end

% Final results
mean_variance_explained = mean(mean_variance_explained_bootstrap);
std_variance_explained = std(mean_variance_explained_bootstrap);

% Display results
fprintf('\nBootstrap Results (1000 iterations) of Mean variance explained with 10-Fold CV:\n');
fprintf('Mean of Mean variance explained = %f, Std of Mean variance explained = %f\n', mean_variance_explained, std_variance_explained);
fprintf('Range of Mean variance explained = [%f, %f]\n', min(mean_variance_explained_bootstrap), max(mean_variance_explained_bootstrap));


ai_performance=mean_variance_explained_bootstrap;




%% R1  AI GPDC performance was significantly higher than that of II GPDC (t1998 = 27.7, p < .0001)
[h,p,s,t]=ttest2(ai_performance,ii_performance)


%% R1  AI GPDC performance was significantly higher than that of II GPDC (t1998 = 27.7, p < .0001).






%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bootstrap iI cdig loadings and plot fig 5 at fs11
n_nodes = 64;               % Number of nodes in MSNs
n_components = 1;            % Number of PLS components (adjust as necessary)
n_iterations = 1000;         % Number of bootstrap iterations
valid=find(isnan(CDIG)==0);
% Initialize storage for bootstrap weights on each component
bootstrap_weights = zeros(n_nodes, n_components, n_iterations);
X_train=zscore([ii(valid,:), data(valid, [1, 3, 4])]);
Y_train=zscore(CDIG(valid));
for iter = 1:n_iterations
    % Perform bootstrap sampling of data
    sample_idx = randi(size(X_train, 1), size(X_train, 1), 1); % Bootstrap sample indices
    X_bootstrap = X_train(sample_idx, :);
    Y_bootstrap = Y_train(sample_idx);

    % Fit PLS model on bootstrap sample
    [XL, ~, ~, ~, ~, ~, ~, ~] = plsregress(X_bootstrap, Y_bootstrap, n_components);

    % Store the weights for each component
    bootstrap_weights(:, :, iter) = XL(1:n_nodes,:); % Assuming XL contains weights for nodes
end

% Calculate mean and standard deviation of weights across bootstraps
mean_bootstrap_weights = mean(bootstrap_weights, 3);
std_bootstrap_weights = std(bootstrap_weights, [], 3);

% Calculate standardized weights (z-scores) for each node on each component
z_scores = mean_bootstrap_weights ./ std_bootstrap_weights;

% Rank the nodes based on their standardized weights on each component
[strength, rankings] = sort(abs(z_scores), 'descend');

% Display the rankings for each component
for comp = 1:n_components
    fprintf('Top 10 Nodes for Component %d:\n', comp);
    disp(rankings(1:10, comp)); % Display top 10 nodes for each component
end
temp=abs(z_scores);
%% comment by R1 - Commented out to prevent overwriting existing data files
% save('iicdiloading.mat','temp')

%% R1 Fig. 4e and 4f



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 FIGURE 4C - PLS Component Loading Matrix
%% Shows which connections contribute most to the AI/II GPDC components
%% that predict learning and CDI scores
%%
%% Creates two 9×9 heatmaps:
%% - II GPDC Component 1 loadings (for CDI prediction)
%% - AI GPDC Component 1 loadings (for learning prediction)
%%
%% X-axis: Sender channels (Adult for AI, Infant for II)
%% Y-axis: Receiver channels (Infant for both)
%% Color: Absolute loading strength (standardized z-scores from bootstrap)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% final%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure 4c
%% loading plot





%% R1 FIG 4D loading ii~cdi
load("iicdiloading.mat")
load('dataGPDC.mat','data')
ii1=[10:9+81];
ii2=[10+81*1:9+81*2];
ii3=[10+81*2:9+81*3];
aa1=[10+81*3:9+81*4];
aa2=[10+81*4:9+81*5];
aa3=[10+81*5:9+81*6];
ai1=[10+81*6:9+81*7];
ai2=[10+81*7:9+81*8];
ai3=[10+81*8:9+81*9];
ia1=[10+81*9:9+81*10];
ia2=[10+81*10:9+81*11];
ia3=[10+81*11:9+81*12];

listi=[ii3];
load('stronglistfdr5_gpdc_II.mat')
listii=listi(s4);
ii=sqrt(data(:,listii));
n = length(s4);
full_matrix = NaN(9, 9);  % 创建一个9x9的NaN矩阵
% Step 2: 将s4的数填充到full_matrix中
full_matrix_ii(s4) = 1;  % 按列优先顺序填充
% 
% listi=[ai3];
% load('stronglistfdr5_gpdc_AI.mat')
% listai=listi(s4);
% ai=sqrt(data(:,listai));
% n = length(s4);
% full_matrix = NaN(9, 9);  % 创建一个9x9的NaN矩阵
% % Step 2: 将s4的数填充到full_matrix中
% full_matrix_ai(s4) = 1;  % 按列优先顺序填充

num_colors = 256;  % 定义颜色的级别数
blue = [0.2 0.2 1];  % 浅蓝色 (负值)
white = [1 1 1];  % 白色 (0值)
pink = [1 0.2 0.2];  % 浅粉色 (正值)

% 创建负到零的颜色过渡 (浅蓝色到白色)
neg_colors = [linspace(blue(1), white(1), num_colors/2)', ...
              linspace(blue(2), white(2), num_colors/2)', ...
              linspace(blue(3), white(3), num_colors/2)'];

% 创建零到正的颜色过渡 (白色到浅粉色)
pos_colors = [linspace(white(1), pink(1), num_colors/2)', ...
              linspace(white(2), pink(2), num_colors/2)', ...
              linspace(white(3), pink(3), num_colors/2)'];

% 合并负值和正值的颜色映射
% custom_colormap = [neg_colors; pos_colors];
custom_colormap=pos_colors;
%% 

%% R1: Plot II GPDC Component 1 loading matrix (for CDI prediction)
% 定义标签
labels = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
n_nodes=64;
n = zeros(9,9);
n(find(full_matrix_ii == 1)) = temp(1:n_nodes,1);  % R1: Fill significant connections with loading values
figure;  % 打开一个新的图形窗口
imagesc(n);  % R1: Display as heatmap

% 为 X 和 Y 轴设置标签
set(gca, 'XTick', 1:9, 'XTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 14);  % 设置 X 轴标签并加粗
set(gca, 'YTick', 1:9, 'YTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 14);  % 设置 Y 轴标签并加粗

% 设置标题和轴标签
xlabel('Sender channels', 'FontWeight', 'bold', 'FontSize', 20, 'FontName', 'Arial');  % R1: Infant sender
ylabel('Receiver channels', 'FontWeight', 'bold', 'FontSize', 20, 'FontName', 'Arial');  % R1: Infant receiver
title('Component No.1 absolute loadings for II GPDC', 'FontWeight', 'bold', 'FontSize', 20, 'FontName', 'Arial')
colormap(custom_colormap);  % 应用自定义 colormap
colorbar;  % 显示 colorbar
% Step 3: 设置颜色范围 [-0.5, 0.5]
%caxis([0, 2]);  % 设置颜色映射范围
% 添加 colorbar，并调整颜色条的属性
h = colorbar;
set(h, 'FontSize', 14, 'FontName', 'Arial','FontWeight', 'bold');  % 设置颜色条的字体和大小
% 加粗轴线
set(gca, 'LineWidth', 2);
h = colorbar;  % 创建 colorbar
set(h, 'LineWidth', 2);  % 设置 colorbar 的边框线宽为 2 磅
hold off;

%% R1 FIG 4D loading ii~cdi





%% R1 FIG 4c loading ai~learning

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bootstrap AI loadings
n_nodes = 80;               % Number of nodes in MSNs
n_components = 1;            % Number of PLS components (adjust as necessary)
n_iterations = 1000;         % Number of bootstrap iterations

% Initialize storage for bootstrap weights on each component
bootstrap_weights = zeros(n_nodes, n_components, n_iterations);
X_train=zscore([ai, data(:, [1, 3, 4])]);
Y_train=zscore(learning);
for iter = 1:n_iterations
    % Perform bootstrap sampling of data
    sample_idx = randi(size(X_train, 1), size(X_train, 1), 1); % Bootstrap sample indices
    X_bootstrap = X_train(sample_idx, :);
    Y_bootstrap = Y_train(sample_idx);

    % Fit PLS model on bootstrap sample
    [XL, ~, ~, ~, ~, ~, ~, ~] = plsregress(X_bootstrap, Y_bootstrap, n_components);

    % Store the weights for each component
    bootstrap_weights(:, :, iter) = XL(1:80,:); % Assuming XL contains weights for nodes
end

% Calculate mean and standard deviation of weights across bootstraps
mean_bootstrap_weights = mean(bootstrap_weights, 3);
std_bootstrap_weights = std(bootstrap_weights, [], 3);

% Calculate standardized weights (z-scores) for each node on each component
z_scores = mean_bootstrap_weights ./ std_bootstrap_weights;

% Rank the nodes based on their standardized weights on each component
[strength, rankings] = sort(abs(z_scores), 'descend');

% Display the rankings for each component
for comp = 1:n_components
    fprintf('Top 10 Nodes for Component %f:\n', comp);
    disp(rankings(1:10, comp)); % Display top 10 nodes for each component
end
temp=abs(z_scores);

%% comment by R1 - Commented out to prevent overwriting existing data files
% save('loadingai.mat','temp')





% listi=[ii3];
% load('stronglistfdr5_gpdc_II.mat')
% listii=listi(s4);
% ii=sqrt(data(:,listii));
% n = length(s4);
% full_matrix = NaN(9, 9);  % 创建一个9x9的NaN矩阵
% % Step 2: 将s4的数填充到full_matrix中
% full_matrix_ii(s4) = 1;  % 按列优先顺序填充

load("loadingai.mat")
listi=[ai3];
load('stronglistfdr5_gpdc_AI.mat')
listai=listi(s4);
ai=sqrt(data(:,listai));
n = length(s4);
full_matrix = NaN(9, 9);  % 创建一个9x9的NaN矩阵
% Step 2: 将s4的数填充到full_matrix中
full_matrix_ai(s4) = 1;  % 按列优先顺序填充

num_colors = 256;  % 定义颜色的级别数
blue = [0.2 0.2 1];  % 浅蓝色 (负值)
white = [1 1 1];  % 白色 (0值)
pink = [1 0.2 0.2];  % 浅粉色 (正值)

% 创建负到零的颜色过渡 (浅蓝色到白色)
neg_colors = [linspace(blue(1), white(1), num_colors/2)', ...
              linspace(blue(2), white(2), num_colors/2)', ...
              linspace(blue(3), white(3), num_colors/2)'];

% 创建零到正的颜色过渡 (白色到浅粉色)
pos_colors = [linspace(white(1), pink(1), num_colors/2)', ...
              linspace(white(2), pink(2), num_colors/2)', ...
              linspace(white(3), pink(3), num_colors/2)'];

% 合并负值和正值的颜色映射
% custom_colormap = [neg_colors; pos_colors];
custom_colormap=pos_colors;
%% 

%% R1: Plot AI GPDC Component 1 loading matrix (for learning prediction)
% 定义标签
labels = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};

n = zeros(9,9);
n(find(full_matrix_ai == 1)) = temp(1:n_nodes,1);  % R1: Fill significant connections with loading values
figure;  % 打开一个新的图形窗口
imagesc(n);  % R1: Display as heatmap

% 为 X 和 Y 轴设置标签
set(gca, 'XTick', 1:9, 'XTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 14);  % 设置 X 轴标签并加粗
set(gca, 'YTick', 1:9, 'YTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 14);  % 设置 Y 轴标签并加粗

% 设置标题和轴标签
xlabel('Sender channels', 'FontWeight', 'bold', 'FontSize', 20, 'FontName', 'Arial');  % R1: Adult sender
ylabel('Receiver channels', 'FontWeight', 'bold', 'FontSize', 20, 'FontName', 'Arial');  % R1: Infant receiver
title('Component No.1 absolute loadings for AI GPDC', 'FontWeight', 'bold', 'FontSize', 20, 'FontName', 'Arial')
colormap(custom_colormap);  % 应用自定义 colormap
colorbar;  % 显示 colorbar
% Step 3: 设置颜色范围 [-0.5, 0.5]
%caxis([0, 2]);  % 设置颜色映射范围
% 添加 colorbar，并调整颜色条的属性
h = colorbar;
set(h, 'FontSize', 14, 'FontName', 'Arial','FontWeight', 'bold');  % 设置颜色条的字体和大小
% 加粗轴线
set(gca, 'LineWidth', 2);
h = colorbar;  % 创建 colorbar
set(h, 'LineWidth', 2);  % 设置 colorbar 的边框线宽为 2 磅
hold off;


%% R1 FIG 4c loading ai~learning
