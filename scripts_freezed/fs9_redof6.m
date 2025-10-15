%% Figure 6 MEDIATION
%% Load entrainment real and surr
clc
clear all
load('ENTRIANSURR.mat');
load("dataGPDC.mat");
% Read the CSV file
 path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'
%path='C:\Users\Admin\OneDrive - Nanyang Technological University/'

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

learning=data(:,7);
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

listi=[ii3];
load('stronglistfdr5_gpdc_II.mat')
listii=listi(s4);
ii=sqrt(data(:,listii));

listi=[ai3];
load('stronglistfdr5_gpdc_AI.mat')
listai=listi(s4);
ai=sqrt(data(:,listai));

listi=[aa3];
load('stronglistfdr5_gpdc_AA.mat')
listaa=listi(s4);
aa=sqrt(data(:,listaa));


aa_surr=cell(1000,1);
ai_surr=cell(1000,1);
ii_surr=cell(1000,1);
for i=1:1000
    i
    tmp=data_surr{i};
    aa_surr{i}=sqrt(tmp(:,listaa));
    ai_surr{i}=sqrt(tmp(:,listai));
    ii_surr{i}=sqrt(tmp(:,listii));
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 FIGURE 6 - Mediation Analysis
%% Load 5 NSE features that were significant in Full gaze (from Section 2.3)
%% These features will be tested as mediators in the gaze-learning relationship
%%
%% Feature mapping (from data2 columns):
%% Column 1: Alpha C3 (data2 column 4)
%% Column 2: Alpha Cz (data2 column 5)
%% Column 3: Theta F4 (data2 column 21)
%% Column 4: Theta Pz (data2 column 26)
%% Column 5: Delta C3 (data2 column 40)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
entrain=data2(:,[4,5,21,26,40]);
meanentrain=mean(entrain(:,:),2);

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
% CONDGROUP(find(CONDGROUP==3))=2;
CONDGROUP=categorical(CONDGROUP);
CONDGROUP2=a(:,6);
CONDGROUP2(find(CONDGROUP2==3))=2;
CONDGROUP2=categorical(CONDGROUP2);
CONDGROUP3=a(:,6);
CONDGROUP3(find(CONDGROUP3==2))=1;
CONDGROUP3=categorical(CONDGROUP3);
learning= a(:, 7);
atten=a(:,9);
ID=a(:,2);
ID=categorical(ID);
 [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ai,data(:,[1,3,4])]), zscore(learning), 2);
% Initialize table for results
valid=find(isnan(data2(:,4))==0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 SUPPLEMENTARY TABLE S3 - Demographic Effects Verification
%% Tests whether NSE (Delta C3) and AI GPDC are affected by demographic factors
%% Row 1 (attention) is in fs2_fig2_behaviouranaylse.m
%% Row 2 (NSE): entrain ~ AGE+SEX+COUNTRY
%% Row 3 (AI GPDC): ai ~ AGE+SEX+COUNTRY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  valid=find(isnan(data2(:,4))==0);
tbl = table(ID, atten,entrain(:,5), zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP,CONDGROUP2,CONDGROUP3,XS(:,1), ...
    'VariableNames',{ 'ID', 'atten', 'entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','CONDGROUP2','CONDGROUP3', 'ai'});
tbl.entrain(valid)=zscore(tbl.entrain(valid));

m=fitlme(tbl,'entrain ~  AGE+SEX+COUNTRY+(1|ID)')
m=fitlme(tbl,'ai ~  AGE+SEX+COUNTRY+(1|ID)')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 SUPPLEMENTARY SECTION 6 - Country Effects Verification
%% "No significant effects of country were detected on the key measures of
%% interest in this analysis (see Supplementary Materials Section 6)."
%%
%% Tests country (UK vs SG) effects on:
%% - Learning outcome
%% - NSE (Delta C3)
%% - AI GPDC connectivity
%%
%% Result: All ns (no significant country effects)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tbl = table(ID, atten,entrain(:,5),meanentrain, zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP,CONDGROUP2,CONDGROUP3,zscore(XS(:,1)),zscore(XS(:,2)), ...
    'VariableNames',{ 'ID', 'atten', 'entrain','meanentrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','CONDGROUP2','CONDGROUP3', 'ai','ai2'});
% tbl.entrain(valid)=(tbl.entrain(valid)-min(tbl.entrain(valid)))./std(tbl.entrain(valid));
% [h,p]=partialcorr(meanentrain(valid),learning(valid),data(valid,[1,3,4]))
% m=fitlme(tbl,'atten ~  AGE+SEX+COUNTRY+(1|ID)')
m=fitlme(tbl,'learning ~  AGE+SEX+COUNTRY+(1|ID)')  % R1: ns (country effect on learning)
% m=fitlme(tbl,'meanentrain ~  AGE+SEX+COUNTRY+(1|ID)')
m=fitlme(tbl,'entrain ~  AGE+SEX+COUNTRY+(1|ID)')  % R1: ns (country effect on NSE)
m=fitlme(tbl,'ai ~  AGE+SEX+COUNTRY+(1|ID)')  % R1: ns (country effect on AI GPDC)
% m=fitlme(tbl,'ai2 ~  AGE+SEX+COUNTRY+(1|ID)')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 SUPPLEMENTARY SECTION 5 (Part 1) - Gaze Condition Effects on All 5 NSE Features
%% "Similar analyses of other NSE features did not yield significant results,
%% as detailed in Supplementary Materials Section 5."
%%
%% Tests whether gaze condition (Full vs Partial/No) affects each NSE feature
%% Loop through all 5 features:
%% i=1: Alpha C3
%% i=2: Alpha Cz
%% i=3: Theta F4
%% i=4: Theta Pz
%% i=5: Delta C3 (main text result)
%%
%% Result: Only Delta C3 (i=5) shows gaze condition effect
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:5
    valid=find(isnan(data2(:,4))==0);
tbl = table(ID, atten,entrain(:,i), zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP,CONDGROUP2,CONDGROUP3,XS(:,1), ...
    'VariableNames',{ 'ID', 'atten', 'entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','CONDGROUP2','CONDGROUP3', 'ai'});
tbl.entrain(valid)=zscore(tbl.entrain(valid));
% m=fitlme(tbl,'entrain ~  CONDGROUP+AGE+SEX+COUNTRY+(1|ID)')
m=fitlme(tbl,'entrain ~  CONDGROUP2+AGE+SEX+COUNTRY+(1|ID)')  % R1: Test gaze effect (Full vs Partial/No)
% m=fitlme(tbl,'entrain ~  CONDGROUP3+AGE+SEX+COUNTRY+(1|ID)')
end


%% 
%% R1 6a and 6e together + Specifically, increased delta C3 NSE was associated with stronger AI connectivity, but only in the No gaze condition (β = 0.34, t111 = 2.02, p < .05). 
valid=find(isnan(data2(:,4))==0);
 [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ai,data(:,[1,3,4])]), zscore(learning), 2);
% Initialize table for results
tbl = table(ID, atten,entrain(:,5), zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP,CONDGROUP2,CONDGROUP3,zscore(XS(:,1)), ...
    'VariableNames',{ 'ID', 'atten', 'entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','CONDGROUP2','CONDGROUP3', 'ai'});
%tbl.ai(valid)=(tbl.ai(valid)-min(tbl.entrain(valid)))./std(tbl.entrain(valid));
tbl.entrain(valid)=(tbl.entrain(valid)-min(tbl.entrain(valid)))./std(tbl.entrain(valid));
%tbl.AGE(valid)=zscore(tbl.AGE(valid));
m=fitlme(tbl,'ai ~  entrain*CONDGROUP+(1|ID)')
%% R1 6a and 6e together + Specifically, increased delta C3 NSE was associated with stronger AI connectivity, but only in the No gaze condition (β = 0.34, t111 = 2.02, p < .05). 



%% II SUP
valid=find(isnan(data2(:,4))==0);
 [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ii,data(:,[1,3,4])]), zscore(learning), 2);
% Initialize table for results
tbl = table(ID, atten,entrain(:,5), zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP,CONDGROUP2,CONDGROUP3,zscore(XS(:,1)), ...
    'VariableNames',{ 'ID', 'atten', 'entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','CONDGROUP2','CONDGROUP3', 'ai'});
% tbl.ai(valid)=(tbl.entrain(valid)-min(tbl.entrain(valid)))./std(tbl.entrain(valid));
tbl.entrain(valid)=(tbl.entrain(valid)-min(tbl.entrain(valid)))./std(tbl.entrain(valid));
% tbl.AGE(valid)=zscore(tbl.AGE(valid));
% m=fitlme(tbl,'ai ~  CONDGROUP+(1|ID)')
m=fitlme(tbl,'ai ~  entrain*CONDGROUP+(1|ID)')




%% R1 6b
tbl = table(ID, atten,entrain(:,5), zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP,CONDGROUP2,CONDGROUP3,zscore(XS(:,1)), ...
    'VariableNames',{ 'ID', 'atten', 'entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','CONDGROUP2','CONDGROUP3', 'ai'});
[h,p]=partialcorr(XS(:,1),learning(:),data(:,[1,3,4]))

m=fitlme(tbl,'learning ~  ai+(1|ID)')
%% R1 6b



%% R1 6d
tbl = table(ID, atten,entrain(:,5), zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP,CONDGROUP2,CONDGROUP3,zscore(XS(:,1)), ...
    'VariableNames',{ 'ID', 'atten', 'entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','CONDGROUP2','CONDGROUP3', 'ai'});
tbl.entrain(valid)=(tbl.entrain(valid)-min(tbl.entrain(valid)))./std(tbl.entrain(valid));
[h,p]=partialcorr(entrain(valid,5),learning(valid),data(valid,[1,3,4]))
m=fitlme(tbl,'learning ~  entrain+AGE+SEX+COUNTRY+(1|ID)')
%% R1 6d

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 SUPPLEMENTARY SECTION 5 (Part 2) - NSE Features as Predictors of Learning
%% Tests whether each of the 5 NSE features predicts learning outcome
%% Loop through all 5 features:
%% i=1: Alpha C3
%% i=2: Alpha Cz
%% i=3: Theta F4
%% i=4: Theta Pz
%% i=5: Delta C3 (main text result: Fig 6d)
%%
%% Result: Only Delta C3 (i=5) significantly predicts learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:5
tbl = table(ID, atten,entrain(:,i), zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP,CONDGROUP2,CONDGROUP3,zscore(XS(:,1)), ...
    'VariableNames',{ 'ID', 'atten', 'entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','CONDGROUP2','CONDGROUP3', 'ai'});
tbl.entrain(valid)=(tbl.entrain(valid)-min(tbl.entrain(valid)))./std(tbl.entrain(valid));
[h,p]=partialcorr(meanentrain(valid),learning(valid),data(valid,[1,3,4]))
m=fitlme(tbl,'learning ~  entrain+AGE+SEX+COUNTRY+(1|ID)')  % R1: Test NSE→learning relationship
end







%% direct indirect in fig 6a
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
% CONDGROUP(find(CONDGROUP==3))=2;
CONDGROUP=categorical(CONDGROUP);
CONDGROUP2=a(:,6);
CONDGROUP2(find(CONDGROUP2==3))=2;
CONDGROUP2=categorical(CONDGROUP2);
learning= a(:, 7);
atten=a(:,9);
ID=a(:,2);
ID=categorical(ID);
valid=find(isnan(data2(:,4))==0);
entrain=data2(:,[4,5,21,26,40]);

%% 
 [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ai,data(:,[1,3,4])]), zscore(learning), 2);
% Initialize table for results
tbl = table(ID, atten,entrain(:,5), zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP,CONDGROUP2,zscore(XS(:,1)), ...
    'VariableNames',{ 'ID', 'atten', 'entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','CONDGROUP2', 'ai'});

tbl.entrain(valid)=(tbl.entrain(valid)-min(tbl.entrain(valid)))./std(tbl.entrain(valid));
% ai already contains age sex site by PLS
m1=fitlme(tbl,'learning ~  ai+(1|ID)')

m2=fitlme(tbl,'ai ~  entrain*CONDGROUP+(1|ID)')

m3=fitlme(tbl,'learning ~  ai+CONDGROUP2+(1|ID)')



%% gaze-ai-learning
% Number of bootstrap iterations
numBoot = 1000;

% Pre-allocate storage for coefficients
indirectEffects = zeros(numBoot, 1); % Stores m1.ai * m2.CONDGROUP_3 coefficients
directEffects = zeros(numBoot, 1);   % Stores m3.CONDGROUP2_2 coefficient

% Bootstrap iterations
for i = 1:numBoot
    % Resample with replacement
    bootIdx = randsample(height(tbl), height(tbl), true);
    tbl_boot = tbl(bootIdx, :);
    
    % Fit the first model m1
    m1_boot = fitlme(tbl_boot, 'learning ~ ai + (1|ID)');
    ai_coef = m1_boot.Coefficients.Estimate(strcmp(m1_boot.Coefficients.Name, 'ai'));
    
    % Fit the second model m2
    m2_boot = fitlme(tbl_boot, 'ai ~ entrain * CONDGROUP + (1|ID)');
    condgroup3_coef = m2_boot.Coefficients.Estimate(strcmp(m2_boot.Coefficients.Name, 'CONDGROUP_3'));
    
    % Calculate indirect effect and store
    indirectEffects(i) = ai_coef * condgroup3_coef;
    
    % Fit the third model m3
    m3_boot = fitlme(tbl_boot, 'learning ~ ai + CONDGROUP2 + (1|ID)');
    condgroup2_2_coef = m3_boot.Coefficients.Estimate(strcmp(m3_boot.Coefficients.Name, 'CONDGROUP2_2'));
    
    % Store direct effect
    directEffects(i) = condgroup2_2_coef;
end
indirectEffects=-indirectEffects;
% Analysis of the bootstrap results
indirectEffect_CI = prctile(indirectEffects, [2.5, 97.5]);
directEffect_CI = prctile(directEffects, [2.5, 97.5]);

% Display results
fprintf('Indirect Effect (ai * CONDGROUP_3) 95%% CI: [%f, %f]\n', indirectEffect_CI(1), indirectEffect_CI(2));
fprintf('Direct Effect (CONDGROUP2_2) 95%% CI: [%f, %f]\n', directEffect_CI(1), directEffect_CI(2));

%% R1 (indirect effect: β = 0.52 ± 0.23, p < .01; Fig. 6). 
mean(indirectEffects)
std(indirectEffects)
%% R1 (indirect effect: β = 0.52 ± 0.23, p < .01; Fig. 6). 

%% R1 By contrast, there was no direct effect of speaker gaze on learning (β = 0.06 ± 0.12, p = .65). 
mean(directEffects)
std(directEffects)
%% R1 By contrast, there was no direct effect of speaker gaze on learning (β = 0.06 ± 0.12, p = .65). 

length(find(indirectEffects<0))
length(find(directEffects<0))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 SUPPLEMENTARY SECTION 7 (Part 1) - NSE Mediation Analysis
%% "Further, none of the NSE features acted either directly or indirectly
%% to mediate the effect of gaze on learning (e.g., β = -0.05 ± 0.04, p = .16;
%% β = 0.35 ± 0.20, p = .08 for delta C3)."
%%
%% Tests mediation pathway: Gaze → NSE (Delta C3) → Learning
%% Uses 1000 bootstrap iterations to estimate:
%% - Indirect effect: gaze → NSE → learning
%% - Direct effect: gaze → learning (controlling for NSE)
%%
%% Result: Non-significant mediation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% gaze-nse-learning
% Number of bootstrap iterations
numBoot = 1000;

% Pre-allocate storage for coefficients
indirectEffects = zeros(numBoot, 1); % Stores m1.ai * m2.CONDGROUP_3 coefficients
directEffects = zeros(numBoot, 1);   % Stores m3.CONDGROUP2_2 coefficient

% Bootstrap iterations
for i = 1:numBoot
    % Resample with replacement
    bootIdx = randsample(height(tbl), height(tbl), true);
    tbl_boot = tbl(bootIdx, :);
    
    % Fit the first model m1
    m1_boot = fitlme(tbl_boot, 'learning ~ entrain+AGE+SEX+COUNTRY + (1|ID)');
    ai_coef = m1_boot.Coefficients.Estimate(strcmp(m1_boot.Coefficients.Name, 'entrain'));
    
    % Fit the second model m2
    m2_boot = fitlme(tbl_boot, 'entrain ~ CONDGROUP2+AGE+SEX+COUNTRY + (1|ID)');
    condgroup3_coef = m2_boot.Coefficients.Estimate(strcmp(m2_boot.Coefficients.Name, 'CONDGROUP2_2'));
    
    % Calculate indirect effect and store
    indirectEffects(i) = ai_coef * condgroup3_coef;
    
    % Fit the third model m3
    m3_boot = fitlme(tbl_boot, 'learning ~entrain +AGE+SEX+COUNTRY+ CONDGROUP2 + (1|ID)');
    condgroup2_2_coef = m3_boot.Coefficients.Estimate(strcmp(m3_boot.Coefficients.Name, 'CONDGROUP2_2'));
    
    % Store direct effect
    directEffects(i) = condgroup2_2_coef;
end
indirectEffects=-indirectEffects;
% Analysis of the bootstrap results
indirectEffect_CI = prctile(indirectEffects, [2.5, 97.5]);
directEffect_CI = prctile(directEffects, [2.5, 97.5]);

% Display results
fprintf('Indirect Effect (ai * CONDGROUP_3) 95%% CI: [%f, %f]\n', indirectEffect_CI(1), indirectEffect_CI(2));
fprintf('Direct Effect (CONDGROUP2_2) 95%% CI: [%f, %f]\n', directEffect_CI(1), directEffect_CI(2));
%% R1  Further, none of the NSE features acted either directly or indirectly to mediate the effect of gaze on learning (e.g., β = -0.05 ± 0.04, p = .16; β = 0.35 ± 0.20, p = .08 for delta C3). 
mean(indirectEffects)
std(indirectEffects)
mean(directEffects)
std(directEffects)
length(find(indirectEffects<0))
length(find(directEffects<0))

%% R1  Further, none of the NSE features acted either directly or indirectly to mediate the effect of gaze on learning (e.g., β = -0.05 ± 0.04, p = .16; β = 0.35 ± 0.20, p = .08 for delta C3). 












%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 SUPPLEMENTARY SECTION 7 (Part 2) - II GPDC Mediation Analysis
%% "Finally, within-infant connectivity (II GPDC) did not show significant
%% mediation effects of gaze on learning (β = 0.06 ± 0.25, p = .82), as
%% described in further detail in Supplementary Materials Section 7."
%%
%% Tests mediation pathway: Gaze → II GPDC → Learning
%% This is a comparison to the main finding (AI GPDC mediation in Fig 6a)
%% Uses same bootstrap methodology (1000 iterations)
%%
%% Result: Non-significant mediation (II does not mediate gaze-learning)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ii sup data loading
 [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ii,data(:,[1,3,4])]), zscore(learning), 2);
% Initialize table for results
tbl = table(ID, atten,entrain(:,5), zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP,CONDGROUP2,zscore(XS(:,1)), ...
    'VariableNames',{ 'ID', 'atten', 'entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','CONDGROUP2', 'ai'});

tbl.entrain(valid)=(tbl.entrain(valid)-min(tbl.entrain(valid)))./std(tbl.entrain(valid));
% ai already contains age sex site by PLS
m1=fitlme(tbl,'learning ~  ai+(1|ID)')

m2=fitlme(tbl,'ai ~  entrain*CONDGROUP+(1|ID)')

m3=fitlme(tbl,'learning ~  ai+CONDGROUP2+(1|ID)')


%% gaze-ii-learning-sup
% Number of bootstrap iterations

 [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ii,data(:,[1,3,4])]), zscore(learning), 2);
% Initialize table for results
tbl = table(ID, atten,entrain(:,5), zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP,CONDGROUP2,zscore(XS(:,1)), ...
    'VariableNames',{ 'ID', 'atten', 'entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','CONDGROUP2', 'ai'});

numBoot = 1000;

% Pre-allocate storage for coefficients
indirectEffects = zeros(numBoot, 1); % Stores m1.ai * m2.CONDGROUP_3 coefficients
directEffects = zeros(numBoot, 1);   % Stores m3.CONDGROUP2_2 coefficient

% Bootstrap iterations
for i = 1:numBoot
    % Resample with replacement
    bootIdx = randsample(height(tbl), height(tbl), true);
    tbl_boot = tbl(bootIdx, :);
    
    % Fit the first model m1
    m1_boot = fitlme(tbl_boot, 'learning ~ ai + (1|ID)');
    ai_coef = m1_boot.Coefficients.Estimate(strcmp(m1_boot.Coefficients.Name, 'ai'));
    
    % Fit the second model m2
    m2_boot = fitlme(tbl_boot, 'ai ~ entrain * CONDGROUP + (1|ID)');
    condgroup3_coef = m2_boot.Coefficients.Estimate(strcmp(m2_boot.Coefficients.Name, 'CONDGROUP_3'));
    
    % Calculate indirect effect and store
    indirectEffects(i) = ai_coef * condgroup3_coef;
    
    % Fit the third model m3
    m3_boot = fitlme(tbl_boot, 'learning ~ ai + CONDGROUP2 + (1|ID)');
    condgroup2_2_coef = m3_boot.Coefficients.Estimate(strcmp(m3_boot.Coefficients.Name, 'CONDGROUP2_2'));
    
    % Store direct effect
    directEffects(i) = condgroup2_2_coef;
end
indirectEffects=-indirectEffects;
% Analysis of the bootstrap results
indirectEffect_CI = prctile(indirectEffects, [2.5, 97.5]);
directEffect_CI = prctile(directEffects, [2.5, 97.5]);

% Display results
fprintf('Indirect Effect (ai * CONDGROUP_3) 95%% CI: [%f, %f]\n', indirectEffect_CI(1), indirectEffect_CI(2));
fprintf('Direct Effect (CONDGROUP2_2) 95%% CI: [%f, %f]\n', directEffect_CI(1), directEffect_CI(2));
mean(indirectEffects)
std(indirectEffects)
mean(directEffects)
std(directEffects)
length(find(indirectEffects<0))
length(find(directEffects<0))

%% R1 Finally, within-infant connectivity (II GPDC) did not show significant mediation effects of gaze on learning (β = 0.06 ± 0.25, p = .82), as described in further detail in Supplementary Materials Section 7.