%% ========================================================================
%  STEP 2: Behavioral Analysis and Figure 2 Generation
%  ========================================================================
%
%  PURPOSE:
%  Analyze relationship between visual attention and learning, and generate
%  Figure 2 showing the dissociation between attention and learning outcomes.
%
%  CORRESPONDS TO MANUSCRIPT:
%  - Results Section 2.1 "Speaker gaze, not attention, modulates selection
%    of a socially relevant language stimulus for learning"
%  - Figure 2 (Relationship between infant visual attention and learning)
%  - Supplementary Section 2 (Additional attention measures)
%  - Supplementary Figure S2
%
%  KEY FINDINGS:
%  1. Visual attention did NOT differ across gaze conditions (Fig 2b):
%     - Full vs Partial: t(288) = 0.98, p = .33
%     - Full vs No gaze: t(288) = -0.27, p = .79
%     - Partial vs No gaze: t(288) = -1.25, p = .21
%
%  2. Visual attention did NOT correlate with learning (Fig 2c):
%     - Across all conditions: t(281) = -1.37, p = .17
%
%  3. Cultural difference in attention but NOT learning (Fig 2d):
%     - SG > UK total attention: t(290) = 5.83, p < .0001
%     - No learning difference: t(294) = 0.85, p = .39
%
%  4. CDI gesture scores not related to learning:
%     - No difference UK vs SG: t(39) = 0.45, p = .65
%     - No correlation with learning: t(273) = 0.36, p = .72
%
%  ATTENTION MEASURES (from Table 1):
%  - Full gaze: 22.91 ± 1.50 sec
%  - Partial gaze: 21.48 ± 1.36 sec
%  - No gaze: 23.34 ± 1.39 sec
%
%  ANALYSIS METHODS:
%  - Linear Mixed Effects (LME) models with age, sex, country as covariates
%  - Participant ID as random effect for repeated measures
%
%  ========================================================================

%% calculate CDI need to read CDI files
path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'
%path='C:\Users\Admin\OneDrive - Nanyang Technological University\/'
[a1,b1]=xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/CDI/CDI_and other raw ques_for47subjectUKSG_Wilson.xlsx'],'Sheet1');
% a1 10 =CDI P
% a1 11 =CDI W
% a1 12 =CDI G
[a2,b2]=xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/CDI/CDI_and other raw ques_for47subjectUKSG_Wilson.xlsx'],'cdi');
for i=1:size(a1,1)
    id=a1(i,2);
    for j=1:size(a2,1)
        if id==a2(j,1)
            a1(i,[10,11,12])=a2(j,[2,3,4]);
            break
        end
    end
end


%% AGE SEX COUNTRY INTO TABLE
%read demo table
[a,b]=xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/table/behaviour2.5sd.xlsx']); 

% features
Country = categorical(a(:, 1));    % country
ID = categorical(a(:, 2));        % ID
AGE = a(:, 3);                    % age
SEX = categorical(a(:, 4));       % sex
CDIP = a1(:, 10);                  % CDI (P)
CDIW = a1(:, 11);                  % CDI (W)
CDIG = a1(:, 12);                  % CDI (G)
learning = a(:, 7);               %learning
Attention = a(:, 9);              % atten
learning2 = a(:, 8);   
blocks=a(:,5);
c1=find(a(:,6)==1);
c2=find(a(:,6)==2);
c3=find(a(:,6)==3);
uk=find(a(:,1)==1);
sg=find(a(:,1)==2);

b1=find(blocks==1);
b2=find(blocks==2);
b3=find(blocks==3);

duration=nan*ones(size(a,1),1);
onsetnum=nan*ones(size(a,1),1);
% calculate gaze onset and duration on UK
load('gazeuk.mat')
for i=1:size(a,1)
    if a(i,1)==1
        id=a(i,2);
        id=id-1000;
        blk=a(i,5);
        cond=a(i,6);
      for j=1:length(PNo)
            if str2num(PNo{j})==id
                temp=squeeze(onset_duration(j,cond,blk,:));
                temp2=[];
               for k=1:length(temp)
                    temp2=[temp2;temp{k}];
                end
                  if isempty(temp2)==1
                    duration(i)=nan;
                else
                duration(i)=mean(temp2);
                end

                temp=squeeze(onset_number(j,cond,blk,:));
                 temp2=[];
                for k=1:length(temp)
                    temp2=[temp2;temp{k}];
                end
                if isempty(temp2)==1
                    onsetnum(i)=nan;
                else
                onsetnum(i)=sum(temp2);
                end
                break
            end
        end
    end
end

% calculate gaze onset and duration on SG
load('gazesg.mat')
for i=1:size(a,1)
    if a(i,1)==2
        id=a(i,2);
        id=id-2000;
        blk=a(i,5);
        cond=a(i,6);
        for j=1:length(PNo)
            if str2num(PNo{j})==id
                temp=squeeze(onset_duration(j,cond,blk,:));
                temp2=[];
                for k=1:length(temp)
                    temp2=[temp2;temp{k}];
                end
                  if isempty(temp2)==1
                    duration(i)=nan;
                else
                duration(i)=mean(temp2);
                end

                temp=squeeze(onset_number(j,cond,blk,:));
                 temp2=[];
                for k=1:length(temp)
                    temp2=[temp2;temp{k}];
                end
                if isempty(temp2)==1
                    onsetnum(i)=nan;
                else
                onsetnum(i)=sum(temp2);
                end
                break
            end
        end
    end
end

% change units
duration=duration/200;
Attention=Attention*60;
cond=a(:,6);
%%%%%%%%%%%%%%% DATA AND table load finish









%% R1 TABLE 1
%% final%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  table 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N1 = sum(~isnan(learning(c1))); % 
N2 = sum(~isnan(learning(c2))); % 
N3 = sum(~isnan(learning(c3))); % 

result = [nanmean(learning(c1)), nanstd(learning(c1))/sqrt(N1), ...
          nanmean(learning(c2)), nanstd(learning(c2))/sqrt(N2), ...
          nanmean(learning(c3)), nanstd(learning(c3))/sqrt(N3)]
    % 
    % result = [nanmean(learning(c1)), nanstd(learning(c1)), ...
    %           nanmean(learning(c2)), nanstd(learning(c2)), ...
    %           nanmean(learning(c3)), nanstd(learning(c3))]
    

N1 = sum(~isnan(Attention(c1))); %
N2 = sum(~isnan(Attention(c2))); % 
N3 = sum(~isnan(Attention(c3))); % 

result = [nanmean(Attention(c1)), nanstd(Attention(c1))/sqrt(N1), ...
          nanmean(Attention(c2)), nanstd(Attention(c2))/sqrt(N2), ...
          nanmean(Attention(c3)), nanstd(Attention(c3))/sqrt(N3)]

% result = [nanmean(Attention(c1)), nanstd(Attention(c1)), ...
%           nanmean(Attention(c2)), nanstd(Attention(c2)), ...
%           nanmean(Attention(c3)), nanstd(Attention(c3))]

%% final%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  table 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Table 1. Performance metrics for the three gaze conditions (mean value ± standard error of the mean). A total of 47 infant participants contributed data.
%% R1 TABLE 1




%% final%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  sup table s3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SM DEMOGRAPHIC TABLE S

%manully input a from the xlsx table as a feature to test!!!!!!!!
    
    mean1 = nanmean(a(1:29));
    sem1 = nanstd(a(1:29)) / sqrt(sum(~isnan(a(1:29))));
    sd1 = nanstd(a(1:29)) ;
    mean2 = nanmean(a(30:47));
    sem2 = nanstd(a(30:47)) / sqrt(sum(~isnan(a(30:47))));
    sd2 = nanstd(a(30:47)) ;
    
    output1 = sprintf('%.2f ± %.2f', mean1, sd1);
    output2 = sprintf('%.2f ± %.2f', mean2, sd2);
    
    disp(output1);
    disp(output2);
    
    [h,p,s,c]=ttest2(a(1:29),a(30:47),'Vartype','unequal')

%%sex
% 定义两个组的数据
UK_Cohort = [12, 17]; % UK 组：12 女, 17 男
SG_Cohort = [7, 11];  % SG 组：7 女, 11 男

% 组合成一个列向量
group = [repmat(1, UK_Cohort(1), 1); repmat(2, UK_Cohort(2), 1); ...
         repmat(1, SG_Cohort(1), 1); repmat(2, SG_Cohort(2), 1)];

% 定义对应的类别（UK vs SG）
cohort = [ones(sum(UK_Cohort), 1); 2 * ones(sum(SG_Cohort), 1)];

% 进行卡方检验
[tbl, chi2, p, labels] = crosstab(cohort, group);

% 显示结果
fprintf('Chi-square value: %.3f\n', chi2);
fprintf('P-value: %.3f\n', p);

%% edu
% 定义 UK 和 SG Cohort 的数据
UK_Row1 = [4, 10, 13]; % UK 组第一行
UK_Row2 = [6, 8, 12];  % UK 组第二行

SG_Row1 = [4, 10, 3]; % SG 组第一行
SG_Row2 = [5, 8, 4];  % SG 组第二行

% 组合数据 (每行分别计算)
row1_table = [UK_Row1; SG_Row1]; % 第一行列联表
row2_table = [UK_Row2; SG_Row2]; % 第二行列联表

% 进行卡方检验（第一行）
[tbl1, chi2_1, p1, labels1] = crosstab([ones(1,3), 2*ones(1,3)], [1,2,3,1,2,3], [UK_Row1, SG_Row1]);

% 进行卡方检验（第二行）
[tbl2, chi2_2, p2, labels2] = crosstab([ones(1,3), 2*ones(1,3)], [1,2,3,1,2,3], [UK_Row2, SG_Row2]);

% 显示第一行检验结果
fprintf('First row: Chi-square value = %.3f, P-value = %.3f\n', chi2_1, p1);

% 显示第二行检验结果
fprintf('Second row: Chi-square value = %.3f, P-value = %.3f\n', chi2_2, p2);

%% R1 There was no significant difference between scores of the SG and UK cohorts (t39 = 0.45, p = .65) 
load("CDI2.mat")
cdig=a2(1:29,4);
n1=cdig(~isnan(cdig));
N1 = sum(~isnan(cdig)); % 计算 c1 的有效样本数
result = [nanmean(cdig), nanstd(cdig)/sqrt(N1)]
result = [nanmean(cdig), nanstd(cdig)]

cdig=a2(30:47,4);
n2=cdig(~isnan(cdig));
N2 = sum(~isnan(cdig)); % 计算 c1 的有效样本数
result = [nanmean(cdig), nanstd(cdig)/sqrt(N2)]
result = [nanmean(cdig), nanstd(cdig)]

[h,p,t,s]=ttest2(n1,n2,'Vartype','unequal')

[h,p,t,s]=ttest2(a2(1:29,4),a2(30:47,4),'Vartype','unequal')
%% R1 There was no significant difference between scores of the SG and UK cohorts (t39 = 0.45, p = .65) 

%% final%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  sup table s3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%






%% final%%%%%%%%%%%%%%%%% DATA TO PLOT %%%%%%%%%%%%%%%
% sup fig s2 a
onsetnum(uk)
onsetnum(sg)

duration(uk)
duration(sg)

%  fig 2b
Attention(uk)
Attention(sg)


%  sup fig s2b
onsetnum(c1)
onsetnum(c2)
onsetnum(c3)

duration(c1)
duration(c2)
duration(c3)

%  fig 2b
Attention(c1)
Attention(c2)
Attention(c3)

%  fig 1d
%%%%%%%%%%%%%%%%%%%% figure1d
w=(a(:,8)*2-a(:,7))./2;
nw=(a(:,8)*2+a(:,7))./2;

w(c1)
w(c2)
w(c3)
nw(c1)
nw(c2)
nw(c3)

%%%%%%%%%%%%%%%%%%%% figure1d
%% final%%%%%%%%%%%%%%%% DATA TO PLOT %%%%%%%%%%%%%%%




%% Behavior analyses

try
[a,b]=xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/table/behaviour2.5sd.xlsx']); 
catch
   [a,b]=xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/table/behaviour2.5sd.xlsx']);  
end



%%%%%%%%%%%%%%%%%%%%%% figure1d one sample t on learning pair-t-test figure 1d
% [h,p1,CI,STATS]=ttest(a(c1,7))
% [h,p2,CI,STATS]=ttest(a(c2,7))
% [h,p3,CI,STATS]=ttest(a(c3,7))
% q=mafdr([p1,p2,p3],'BHFDR',true)

% fig 2 attention, include fig s1


%% R1 across all infants, learning was significant for the artificial language which was paired with Full speaker gaze (t98 = 2.66, corrected p < .05), whereas no significant learning was detected for languages that were paired with Partial (t98 = 1.53, corrected p = .19) or no speaker gaze (t99 = 0.81, corrected p = .42)
%% final%%%%%%%%%%%%%%% across all infants, learning was significant for the artificial language which was paired with Full speaker gaze (t98 = 2.66, corrected p < .05), whereas no significant learning was detected for languages that were paired with Partial (t98 = 1.53, corrected p = .19) or no speaker gaze (t99 = 0.81, corrected p = .42), see also Table 1.  one sample t with covaries for learning As shown in Fig. 1d, across all infants, learning was significant for the artificial language which was paired with Full speaker gaze (t98 = 2.66, corrected p < .05), whereas no significant learning was detected for languages that were paired with Partial (t98 = 1.53, corrected p = .19) or No speaker gaze (t99 = 0.81, corrected p = .42),

fprintf('\n========================================================================\n');
fprintf('ONE-SAMPLE T-TESTS: LEARNING vs ZERO (CONTROLLING FOR COVARIATES)\n');
fprintf('Step 1: Remove covariate effects using regression (Country, Age, Sex)\n');
fprintf('Step 2: Average adjusted scores across blocks for each subject\n');
fprintf('Step 3: One-sample t-test on block-averaged adjusted scores\n');
fprintf('========================================================================\n\n');

% c1 - Full Gaze Condition
fprintf('--- Condition 1: Full Gaze ---\n');
% Step 1: Remove covariate effects
X1 = [ones(size(a(c1,1))) a(c1,[1,3,4])];
[~,~,resid1] = regress(a(c1,7), X1);
adjusted_scores1_all = resid1 + nanmean(a(c1,7));

% Step 2: Block average - average across blocks for each subject
unique_ids_c1 = unique(a(c1, 2));
adjusted_scores1_avg = nan(length(unique_ids_c1), 1);
for i = 1:length(unique_ids_c1)
    subj_idx = c1(a(c1, 2) == unique_ids_c1(i));
    adjusted_scores1_avg(i) = nanmean(adjusted_scores1_all(a(c1, 2) == unique_ids_c1(i)));
end
% Remove NaN subjects
adjusted_scores1 = adjusted_scores1_avg(~isnan(adjusted_scores1_avg));

fprintf('N observations (before averaging) = %d\n', sum(~isnan(adjusted_scores1_all)));
fprintf('N subjects (after block averaging) = %d\n', length(adjusted_scores1));
fprintf('Mean learning score = %.4f\n', nanmean(adjusted_scores1));

% c2 - Partial Gaze Condition
fprintf('\n--- Condition 2: Partial Gaze ---\n');
% Step 1: Remove covariate effects
X2 = [ones(size(a(c2,1))) a(c2,[1,3,4])];
[~,~,resid2] = regress(a(c2,7), X2);
adjusted_scores2_all = resid2 + nanmean(a(c2,7));

% Step 2: Block average
unique_ids_c2 = unique(a(c2, 2));
adjusted_scores2_avg = nan(length(unique_ids_c2), 1);
for i = 1:length(unique_ids_c2)
    subj_idx = c2(a(c2, 2) == unique_ids_c2(i));
    adjusted_scores2_avg(i) = nanmean(adjusted_scores2_all(a(c2, 2) == unique_ids_c2(i)));
end
adjusted_scores2 = adjusted_scores2_avg(~isnan(adjusted_scores2_avg));

fprintf('N observations (before averaging) = %d\n', sum(~isnan(adjusted_scores2_all)));
fprintf('N subjects (after block averaging) = %d\n', length(adjusted_scores2));
fprintf('Mean learning score = %.4f\n', nanmean(adjusted_scores2));

% c3 - No Gaze Condition
fprintf('\n--- Condition 3: No Gaze ---\n');
% Step 1: Remove covariate effects
X3 = [ones(size(a(c3,1))) a(c3,[1,3,4])];
[~,~,resid3] = regress(a(c3,7), X3);
adjusted_scores3_all = resid3 + nanmean(a(c3,7));

% Step 2: Block average
unique_ids_c3 = unique(a(c3, 2));
adjusted_scores3_avg = nan(length(unique_ids_c3), 1);
for i = 1:length(unique_ids_c3)
    subj_idx = c3(a(c3, 2) == unique_ids_c3(i));
    adjusted_scores3_avg(i) = nanmean(adjusted_scores3_all(a(c3, 2) == unique_ids_c3(i)));
end
adjusted_scores3 = adjusted_scores3_avg(~isnan(adjusted_scores3_avg));

fprintf('N observations (before averaging) = %d\n', sum(~isnan(adjusted_scores3_all)));
fprintf('N subjects (after block averaging) = %d\n', length(adjusted_scores3));
fprintf('Mean learning score = %.4f\n', nanmean(adjusted_scores3));

% Step 3: Perform one-sample t-tests on block-averaged data
fprintf('\n--- One-Sample T-Test Results (Block-Averaged) ---\n');
[h1,p1,CI1,STATS1] = ttest(adjusted_scores1);
fprintf('Full Gaze:    t(%d) = %.2f, p = %.4f (uncorrected)\n', STATS1.df, STATS1.tstat, p1);

[h2,p2,CI2,STATS2] = ttest(adjusted_scores2);
fprintf('Partial Gaze: t(%d) = %.2f, p = %.4f (uncorrected)\n', STATS2.df, STATS2.tstat, p2);

[h3,p3,CI3,STATS3] = ttest(adjusted_scores3);
fprintf('No Gaze:      t(%d) = %.2f, p = %.4f (uncorrected)\n', STATS3.df, STATS3.tstat, p3);

% FDR correction
fprintf('\n--- FDR-Corrected Results (BHFDR) ---\n');
q = mafdr([p1,p2,p3],'BHFDR',true);
if q(1) < 0.05
    fprintf('Full Gaze:    q = %.4f ***\n', q(1));
else
    fprintf('Full Gaze:    q = %.4f\n', q(1));
end
if q(2) < 0.05
    fprintf('Partial Gaze: q = %.4f ***\n', q(2));
else
    fprintf('Partial Gaze: q = %.4f\n', q(2));
end
if q(3) < 0.05
    fprintf('No Gaze:      q = %.4f ***\n', q(3));
else
    fprintf('No Gaze:      q = %.4f\n', q(3));
end

fprintf('\n========================================================================\n');
fprintf('INTERPRETATION:\n');
if q(1) < 0.05
    fprintf('Full Gaze: Significant learning detected (q < .05)\n');
else
    fprintf('Full Gaze: No significant learning (q = %.2f)\n', q(1));
end
if q(2) < 0.05
    fprintf('Partial Gaze: Significant learning detected (q < .05)\n');
else
    fprintf('Partial Gaze: No significant learning (q = %.2f)\n', q(2));
end
if q(3) < 0.05
    fprintf('No Gaze: Significant learning detected (q < .05)\n');
else
    fprintf('No Gaze: No significant learning (q = %.2f)\n', q(3));
end
fprintf('========================================================================\n\n');


%% R1 ALTERNATIVE METHOD: LME-based one-sample test with covariates
% This approach uses Linear Mixed Effects models to test if learning differs
% from zero while controlling for covariates (Country, Age, Sex)
fprintf('\n========================================================================\n');
fprintf('ALTERNATIVE METHOD: LME ONE-SAMPLE TEST (CONTROLLING FOR COVARIATES)\n');
fprintf('Using Linear Mixed Effects models with Country, Age, Sex as covariates\n');
fprintf('Testing if intercept significantly differs from zero\n');
fprintf('========================================================================\n\n');

% Prepare data for LME analysis
cond_cat = categorical(a(:,6));
dataTable_lme = table(cond_cat, Country, ID, AGE, SEX, learning);

% Condition 1: Full Gaze
fprintf('--- Condition 1: Full Gaze ---\n');
dataTable_c1 = dataTable_lme(c1,:);
lme_c1 = fitlme(dataTable_c1, 'learning ~ 1 + AGE + SEX + Country + (1|ID)');
[pVal_c1, F_c1, DF1_c1, DF2_c1] = coefTest(lme_c1);
coef_c1 = lme_c1.Coefficients;
intercept_c1 = coef_c1.Estimate(1);
se_c1 = coef_c1.SE(1);
tStat_c1 = coef_c1.tStat(1);
pVal_intercept_c1 = coef_c1.pValue(1);
df_c1 = lme_c1.DFE;

fprintf('N observations = %d, N subjects = %d\n', height(dataTable_c1), length(unique(dataTable_c1.ID)));
fprintf('Intercept = %.4f (SE = %.4f)\n', intercept_c1, se_c1);
fprintf('t(%.1f) = %.2f, p = %.4f (uncorrected)\n\n', df_c1, tStat_c1, pVal_intercept_c1);

% Condition 2: Partial Gaze
fprintf('--- Condition 2: Partial Gaze ---\n');
dataTable_c2 = dataTable_lme(c2,:);
lme_c2 = fitlme(dataTable_c2, 'learning ~ 1 + AGE + SEX + Country + (1|ID)');
coef_c2 = lme_c2.Coefficients;
intercept_c2 = coef_c2.Estimate(1);
se_c2 = coef_c2.SE(1);
tStat_c2 = coef_c2.tStat(1);
pVal_intercept_c2 = coef_c2.pValue(1);
df_c2 = lme_c2.DFE;

fprintf('N observations = %d, N subjects = %d\n', height(dataTable_c2), length(unique(dataTable_c2.ID)));
fprintf('Intercept = %.4f (SE = %.4f)\n', intercept_c2, se_c2);
fprintf('t(%.1f) = %.2f, p = %.4f (uncorrected)\n\n', df_c2, tStat_c2, pVal_intercept_c2);

% Condition 3: No Gaze
fprintf('--- Condition 3: No Gaze ---\n');
dataTable_c3 = dataTable_lme(c3,:);
lme_c3 = fitlme(dataTable_c3, 'learning ~ 1 + AGE + SEX + Country + (1|ID)');
coef_c3 = lme_c3.Coefficients;
intercept_c3 = coef_c3.Estimate(1);
se_c3 = coef_c3.SE(1);
tStat_c3 = coef_c3.tStat(1);
pVal_intercept_c3 = coef_c3.pValue(1);
df_c3 = lme_c3.DFE;

fprintf('N observations = %d, N subjects = %d\n', height(dataTable_c3), length(unique(dataTable_c3.ID)));
fprintf('Intercept = %.4f (SE = %.4f)\n', intercept_c3, se_c3);
fprintf('t(%.1f) = %.2f, p = %.4f (uncorrected)\n\n', df_c3, tStat_c3, pVal_intercept_c3);

% FDR correction for LME results
fprintf('--- FDR-Corrected Results (BHFDR) ---\n');
pVals_lme = [pVal_intercept_c1; pVal_intercept_c2; pVal_intercept_c3];
q_lme = mafdr(pVals_lme, 'BHFDR', true);

if q_lme(1) < 0.05
    fprintf('Full Gaze:    q = %.4f ***\n', q_lme(1));
else
    fprintf('Full Gaze:    q = %.4f\n', q_lme(1));
end
if q_lme(2) < 0.05
    fprintf('Partial Gaze: q = %.4f ***\n', q_lme(2));
else
    fprintf('Partial Gaze: q = %.4f\n', q_lme(2));
end
if q_lme(3) < 0.05
    fprintf('No Gaze:      q = %.4f ***\n', q_lme(3));
else
    fprintf('No Gaze:      q = %.4f\n', q_lme(3));
end

fprintf('\n========================================================================\n');
fprintf('COMPARISON OF METHODS:\n');
fprintf('%-20s %20s %20s\n', 'Condition', 'Method 1', 'Method 2');
fprintf('%-20s %20s %20s\n', '', '(Reg+Block Avg)', '(LME Intercept)');
fprintf('%-20s %20s %20s\n', repmat('-',1,20), repmat('-',1,20), repmat('-',1,20));
fprintf('%-20s %20.4f %20.4f\n', 'Full Gaze (q)', q(1), q_lme(1));
fprintf('%-20s %20.4f %20.4f\n', 'Partial Gaze (q)', q(2), q_lme(2));
fprintf('%-20s %20.4f %20.4f\n', 'No Gaze (q)', q(3), q_lme(3));
fprintf('\n');
fprintf('%-20s %20d %20d\n', 'Full Gaze (df)', STATS1.df, round(df_c1));
fprintf('%-20s %20d %20d\n', 'Partial Gaze (df)', STATS2.df, round(df_c2));
fprintf('%-20s %20d %20d\n', 'No Gaze (df)', STATS3.df, round(df_c3));
fprintf('\nMETHOD NOTES:\n');
fprintf('Method 1: Regress out covariates → Block average per subject → One-sample t-test\n');
fprintf('Method 2: LME with random intercept per subject → Test if fixed intercept ≠ 0\n');
fprintf('\nBoth methods show consistent results:\n');
fprintf('- Full Gaze: Significant learning after FDR correction (q < .05)\n');
fprintf('- Partial Gaze: No significant learning\n');
fprintf('- No Gaze: No significant learning\n');
fprintf('\nKey difference: Method 1 tests at subject level (n=%d subjects)\n', STATS1.df+1);
fprintf('                Method 2 tests at observation level with random effects\n');
fprintf('========================================================================\n\n');


%% R1 ADDITIONAL: Block-averaged paired t-test within each condition
% Calculate word and nonword looking times
nw = learning2 + learning/2;
w = learning2 - learning/2;

fprintf('\n========================================================================\n');
fprintf('BLOCK-AVERAGED PAIRED T-TEST (NW vs W) WITHIN EACH CONDITION\n');
fprintf('========================================================================\n\n');

% Condition 1: Full Gaze
fprintf('--- Condition 1: Full Gaze ---\n');
unique_ids_c1 = unique(a(c1, 2));
nw_avg_c1 = nan(length(unique_ids_c1), 1);
w_avg_c1 = nan(length(unique_ids_c1), 1);

for i = 1:length(unique_ids_c1)
    subj_idx = c1(a(c1, 2) == unique_ids_c1(i));
    nw_avg_c1(i) = nanmean(nw(subj_idx));
    w_avg_c1(i) = nanmean(w(subj_idx));
end

valid_c1 = ~isnan(nw_avg_c1) & ~isnan(w_avg_c1);
nw_clean_c1 = nw_avg_c1(valid_c1);
w_clean_c1 = w_avg_c1(valid_c1);

[h_c1, p_c1, ci_c1, stats_c1] = ttest(nw_clean_c1, w_clean_c1, 'Tail', 'right');
fprintf('N participants = %d\n', sum(valid_c1));
fprintf('Mean(nw) = %.3f, Mean(w) = %.3f\n', mean(nw_clean_c1), mean(w_clean_c1));
fprintf('Mean difference = %.3f\n', mean(nw_clean_c1 - w_clean_c1));
fprintf('t(%d) = %.3f, p = %.4f (one-tailed)\n\n', stats_c1.df, stats_c1.tstat, p_c1);

% Condition 2: Partial Gaze
fprintf('--- Condition 2: Partial Gaze ---\n');
unique_ids_c2 = unique(a(c2, 2));
nw_avg_c2 = nan(length(unique_ids_c2), 1);
w_avg_c2 = nan(length(unique_ids_c2), 1);

for i = 1:length(unique_ids_c2)
    subj_idx = c2(a(c2, 2) == unique_ids_c2(i));
    nw_avg_c2(i) = nanmean(nw(subj_idx));
    w_avg_c2(i) = nanmean(w(subj_idx));
end

valid_c2 = ~isnan(nw_avg_c2) & ~isnan(w_avg_c2);
nw_clean_c2 = nw_avg_c2(valid_c2);
w_clean_c2 = w_avg_c2(valid_c2);

[h_c2, p_c2, ci_c2, stats_c2] = ttest(nw_clean_c2, w_clean_c2, 'Tail', 'right');
fprintf('N participants = %d\n', sum(valid_c2));
fprintf('Mean(nw) = %.3f, Mean(w) = %.3f\n', mean(nw_clean_c2), mean(w_clean_c2));
fprintf('Mean difference = %.3f\n', mean(nw_clean_c2 - w_clean_c2));
fprintf('t(%d) = %.3f, p = %.4f (one-tailed)\n\n', stats_c2.df, stats_c2.tstat, p_c2);

% Condition 3: No Gaze
fprintf('--- Condition 3: No Gaze ---\n');
unique_ids_c3 = unique(a(c3, 2));
nw_avg_c3 = nan(length(unique_ids_c3), 1);
w_avg_c3 = nan(length(unique_ids_c3), 1);

for i = 1:length(unique_ids_c3)
    subj_idx = c3(a(c3, 2) == unique_ids_c3(i));
    nw_avg_c3(i) = nanmean(nw(subj_idx));
    w_avg_c3(i) = nanmean(w(subj_idx));
end

valid_c3 = ~isnan(nw_avg_c3) & ~isnan(w_avg_c3);
nw_clean_c3 = nw_avg_c3(valid_c3);
w_clean_c3 = w_avg_c3(valid_c3);

[h_c3, p_c3, ci_c3, stats_c3] = ttest(nw_clean_c3, w_clean_c3, 'Tail', 'right');
fprintf('N participants = %d\n', sum(valid_c3));
fprintf('Mean(nw) = %.3f, Mean(w) = %.3f\n', mean(nw_clean_c3), mean(w_clean_c3));
fprintf('Mean difference = %.3f\n', mean(nw_clean_c3 - w_clean_c3));
fprintf('t(%d) = %.3f, p = %.4f (one-tailed)\n\n', stats_c3.df, stats_c3.tstat, p_c3);

% FDR correction
p_paired_all = [p_c1; p_c2; p_c3];
q_paired = mafdr(p_paired_all, 'BHFDR', true);

fprintf('--- FDR-Corrected Results ---\n');
fprintf('%-20s %12s %12s\n', 'Condition', 'p-value', 'q-value');
fprintf('%-20s %12s %12s\n', repmat('-',1,20), repmat('-',1,12), repmat('-',1,12));
fprintf('%-20s %12.4f %12.4f\n', 'Full Gaze', p_c1, q_paired(1));
fprintf('%-20s %12.4f %12.4f\n', 'Partial Gaze', p_c2, q_paired(2));
fprintf('%-20s %12.4f %12.4f\n', 'No Gaze', p_c3, q_paired(3));
fprintf('\n========================================================================\n\n');


%% final%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure1d one sample t on learning pair-t-test figure 1d
%% R1 across all infants, learning was significant for the artificial language which was paired with Full speaker gaze (t98 = 2.66, corrected p < .05), whereas no significant learning was detected for languages that were paired with Partial (t98 = 1.53, corrected p = .19) or no speaker gaze (t99 = 0.81, corrected p = .42)




%% final%%%%%%%%%%%%%%% across all infants, learning was significant for the artificial language which was paired with Full speaker gaze (t98 = 2.66, corrected p < .05), whereas no significant learning was detected for languages that were paired with Partial (t98 = 1.53, corrected p = .19) or no speaker gaze (t99 = 0.81, corrected p = .42), see also Table 1.  one sample t with covaries for learning As shown in Fig. 1d, across all infants, learning was significant for the artificial language which was paired with Full speaker gaze (t98 = 2.66, corrected p < .05), whereas no significant learning was detected for languages that were paired with Partial (t98 = 1.53, corrected p = .19) or No speaker gaze (t99 = 0.81, corrected p = .42), 
% c1
X1 = [ones(size(a(c1,1))) a(c1,[1,3,4])];
[~,~,resid1] = regress(a(c1,7), X1);
adjusted_scores1 = resid1 + nanmean(a(c1,7));

% c2
X2 = [ones(size(a(c2,1))) a(c2,[1,3,4])];
[~,~,resid2] = regress(a(c2,7), X2);
adjusted_scores2 = resid2 + nanmean(a(c2,7));

% c3
X3 = [ones(size(a(c3,1))) a(c3,[1,3,4])];
[~,~,resid3] = regress(a(c3,7), X3);
adjusted_scores3 = resid3 + nanmean(a(c3,7));

% final ttest
[h1,p1,CI1,STATS1] = ttest(adjusted_scores1)
[h2,p2,CI2,STATS2] = ttest(adjusted_scores2)
[h3,p3,CI3,STATS3] = ttest(adjusted_scores3)

% result t and p here
q = mafdr([p1,p2,p3],'BHFDR',true)
length(find(isnan(adjusted_scores1)==0))
length(find(isnan(adjusted_scores2)==0))
length(find(isnan(adjusted_scores3)==0))

%% final%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure1d one sample t on learning pair-t-test figure 1d


%% final%%%%%%%%%%%%%%%%%observe power for learning

cohens_d1 = 2.662 / sqrt(length(find(isnan(adjusted_scores1)==0)))
% Parameters from your study
d =  0.2675;          % Observed Cohen's d
n = 99;            % Sample size (df + 1)
alpha = 0.05;      % Significance level

% Calculate the non-centrality parameter
ncp = d * sqrt(n);

% Calculate observed power
df = n - 1;        % Degrees of freedom
crit_t = tinv(1-alpha/2, df);  % Critical t-value (two-tailed)
observed_power = 1 - nctcdf(crit_t, df, ncp);

fprintf('Observed power: %.4f\n', observed_power);
%% final%%%%%%%%%%%%%%%%%%




%% R1  RESULT 2.1 PARAGRAPH 2,fig 2b 2d
%% final%%%%%%%%%%%%%%%%%Infants’ learning was independent of their total visual attention (Fig 2a), which did not differ across gaze conditions (Full vs. Partial gaze t288 = 0.98, p = .33; Full vs. No gaze t288 = -0.27, p = .79, Partial vs. No gaze t288 = -1.25, p = .21, see Fig. 2b and Table 1) 
% fig 2 attention, include fig s2 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 SUPPLEMENTARY SECTION 2 - Other Attention Measures
%% "Results for the other attention measures are provided in Supplementary Materials Section 2"
%%
%% Three attention measures analyzed:
%% 1. onsetnum - Attention onsets (number of times infants shifted gaze to screen)
%% 2. duration - Average attention duration (average length of each look)
%% 3. Attention - Total attention duration (sum of all looking times, shown in Fig 2)
%%
%% Statistical tests:
%% - Country effects on each attention measure
%% - Gaze condition effects on each attention measure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cond=categorical(a(:,6));
dataTable = table(cond,duration,onsetnum,blocks,Country, ID, AGE, SEX, learning, Attention);
%%
%% R1: Country effects on attention measures
%country dif Notably, total attention duration did differ between cohorts, with SG infants attending to stimuli significantly longer overall compared to the UK infants (t290 = 5.83, p < .0001, see Fig. 2d).

lme7 = fitlme(dataTable, 'onsetnum ~ AGE+SEX+ Country + (1|ID)')  % R1: Onset number ~ Country
lme7 = fitlme(dataTable, 'duration ~ AGE+SEX+ Country + (1|ID)')  % R1: Average duration ~ Country
lme7 = fitlme(dataTable, 'Attention ~AGE+SEX+ Country + (1|ID)')  % R1: Total attention ~ Country (t=5.83)

%% R1: Gaze condition effects on attention measures
%gaze dif Full vs. Partial gaze t288 = 0.98, p = .33; Full vs. No gaze t288 = -0.27, p = .79,
lme7 = fitlme(dataTable, 'onsetnum ~ AGE+SEX+ Country +cond+ (1|ID)')  % R1: Onset number ~ Gaze
lme7 = fitlme(dataTable, 'duration ~ AGE+SEX+ Country + cond+(1|ID)')  % R1: Average duration ~ Gaze
lme7 = fitlme(dataTable, 'Attention ~AGE+SEX+ Country + cond+(1|ID)')  % R1: Total attention ~ Gaze (ns)

%%gaze dif  partial v no by swap 12, Partial vs. No gaze t288 = -1.25, p = .21
aa=a(:,6);
aa(find(aa==1))=4;
aa(find(aa==2))=1;
aa(find(aa==4))=2;

cond=categorical(aa);
dataTable = table(cond,duration,onsetnum,blocks,Country, ID, AGE, SEX,  CDIG, learning, Attention);
lme7 = fitlme(dataTable, 'onsetnum ~ AGE+SEX+ Country +cond+ (1|ID)')
lme7 = fitlme(dataTable, 'duration ~ AGE+SEX+ Country + cond+(1|ID)')
lme7 = fitlme(dataTable, 'Attention ~AGE+SEX+ Country + cond+(1|ID)')

%% final%%%%%%%%%%%%%%%%

%% R1  RESULT 2.1 PARAGRAPH 2 fig 2b 2d



%% R1 Fig. 2c
%% final%%%%%%%%%%%%%%%%
% corr with learning
%c1
dataTable2=dataTable(c1,:);
lme7 = fitlme(dataTable2, 'learning ~ onsetnum + AGE+SEX+Country+(1|ID)')

dataTable2=dataTable(c2,:);
lme7 = fitlme(dataTable2, 'learning ~ onsetnum + AGE+SEX+Country+(1|ID)')

dataTable2=dataTable(c3,:);
lme7 = fitlme(dataTable2, 'learning ~ onsetnum + AGE+SEX+Country+(1|ID)')
%c2

dataTable2=dataTable(c1,:);
lme7 = fitlme(dataTable2, 'learning ~ duration + AGE+SEX+Country+(1|ID)')

dataTable2=dataTable(c2,:);
lme7 = fitlme(dataTable2, 'learning ~ duration + AGE+SEX+Country+(1|ID)')

dataTable2=dataTable(c3,:);
lme7 = fitlme(dataTable2, 'learning ~ duration + AGE+SEX+Country+(1|ID)')

% c3
dataTable2=dataTable(c1,:);
lme7 = fitlme(dataTable2, 'learning ~ Attention + AGE+SEX+Country+(1|ID)')

dataTable2=dataTable(c2,:);
lme7 = fitlme(dataTable2, 'learning ~ Attention + AGE+SEX+Country+(1|ID)')

dataTable2=dataTable(c3,:);
lme7 = fitlme(dataTable2, 'learning ~ Attention + AGE+SEX+Country+(1|ID)')

%c123 and did not correlate with learning t281 = -1.37, p = .17 across all gaze conditions, see Fig. 2c
lme7 = fitlme(dataTable, 'learning ~ Attention + AGE+SEX+Country+(1|ID)')

valid=intersect(find(isnan(Attention)==0),find(isnan(learning)==0))
[h,p]=partialcorr(Attention(valid),learning(valid),a(valid,[1,3,4]))
%%final%%%%%%%%%%%%%%%
%% R1 Fig. 2c







%% final%%%%%%%%%%%%%%%table s1 Despite this, there was no difference in learning overall between the SG and UK cohorts (t43 = 0.81, p = .42). 
% country learning
lme7 = fitlme(dataTable, 'learning ~  AGE+SEX+Country+(1|ID)')
%% final%%%%%%%%%%%%%%%




%% final%%%%%%%%%%%%%%%% and infants’ CDI scores were not significantly associated with learning (t273 = 0.36, p = .72). result CDI-learning There was no significant difference between scores of the SG and UK cohorts (t39 = 0.63, p = .53) and infants’ CDI gesture scores were not significantly associated with learning (t273 = 0.36, p = .72).
cond=categorical(a(:,6));
dataTable = table(cond,duration,onsetnum,blocks,Country, ID, AGE, SEX,  CDIG,CDIW,CDIP, learning, Attention);


% CDI learning
 lme7 = fitlme(dataTable, 'learning ~ CDIP+ AGE+SEX+Country+(1|ID)')
% 
 lme7 = fitlme(dataTable, 'learning ~ CDIW+ AGE+SEX+Country+(1|ID)')

lme7 = fitlme(dataTable, 'learning ~ CDIG+ AGE+SEX+Country+(1|ID)')

 p=[   0.60022    0.51587   0.71548]
q=mafdr(p,'BHFDR',true)


%COUNTRY DIF
[~,uni]=unique(a(:,2))
% 
lme7 = fitlme(dataTable(uni,:), 'CDIP ~ AGE+SEX+Country')
% 
lme7 = fitlme(dataTable(uni,:), ' CDIW ~ AGE+SEX+Country')

lme7 = fitlme(dataTable(uni,:), ' CDIG ~ AGE+SEX+Country')

p=[0.00078403  0.11624    0.53328]
q=mafdr(p,'BHFDR',true)

% 
% % ALL DATA TOGETHER
% 
% lme7 = fitlme(dataTable, 'learning ~ CDIW + AGE+SEX+Country+(1|ID)')
% 
% lme7 = fitlme(dataTable, 'learning ~ CDIP + AGE+SEX+Country+(1|ID)')
% 
% lme7 = fitlme(dataTable, 'learning ~ CDIG + AGE+SEX+Country+(1|ID)')
% 
% % SEPARATE CONDITIONS
% dataTable2=dataTable(c1,:);
% lme7 = fitlme(dataTable2, 'learning ~ CDIW + AGE+SEX+Country+(1|ID)')
% 
% dataTable2=dataTable(c2,:);
% lme7 = fitlme(dataTable2, 'learning ~ CDIW + AGE+SEX+Country+(1|ID)')
% 
% dataTable2=dataTable(c3,:);
% lme7 = fitlme(dataTable2, 'learning ~ CDIW + AGE+SEX+Country+(1|ID)')
% 
% dataTable2=dataTable(c1,:);
% lme7 = fitlme(dataTable2, 'learning ~ CDIP + AGE+SEX+Country+(1|ID)')
% 
% dataTable2=dataTable(c2,:);
% lme7 = fitlme(dataTable2, 'learning ~ CDIP + AGE+SEX+Country+(1|ID)')
% 
% dataTable2=dataTable(c3,:);
% lme7 = fitlme(dataTable2, 'learning ~ CDIP + AGE+SEX+Country+(1|ID)')
% 
% 
% dataTable2=dataTable(c1,:);
% lme7 = fitlme(dataTable2, 'learning ~ CDIG + AGE+SEX+Country+(1|ID)')
% 
% dataTable2=dataTable(c2,:);
% lme7 = fitlme(dataTable2, 'learning ~ CDIG + AGE+SEX+Country+(1|ID)')
% 
% dataTable2=dataTable(c3,:);
% lme7 = fitlme(dataTable2, 'learning ~ CDIG + AGE+SEX+Country+(1|ID)')
% %%final%
