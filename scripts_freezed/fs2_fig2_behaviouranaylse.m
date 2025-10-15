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


%% final%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure1d one sample t on learning pair-t-test figure 1d
%% R1 across all infants, learning was significant for the artificial language which was paired with Full speaker gaze (t98 = 2.66, corrected p < .05), whereas no significant learning was detected for languages that were paired with Partial (t98 = 1.53, corrected p = .19) or no speaker gaze (t99 = 0.81, corrected p = .42)






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
