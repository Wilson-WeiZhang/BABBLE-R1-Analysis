%% 
[a1,b]=xlsread('d:\infanteeg\CAM BABBLE EEG DATA\2024\table\behaviour2.5sd_word.xlsx');
[a2,b]=xlsread('d:\infanteeg\CAM BABBLE EEG DATA\2024\table\behaviour2.5sd_nonword.xlsx');
%% put into tables
c1=find(a(:,6)==1);
c2=find(a(:,6)==2);
c3=find(a(:,6)==3);
valid=intersect(find(isnan(a(:,7))==0),c1);
[h,p]=ttest(a1(valid,7)-a2(valid,7))
[mean(a1(valid,7)),std(a1(valid,7)),length(valid)]
[mean(a2(valid,7)),std(a2(valid,7)),length(valid)]

valid=intersect(find(isnan(a(:,7))==0),c2);
[h,p]=ttest(a1(valid,7)-a2(valid,7))
[mean(a1(valid,7)),std(a1(valid,7)),length(valid)]
[mean(a2(valid,7)),std(a2(valid,7)),length(valid)]

valid=intersect(find(isnan(a(:,7))==0),c3);
[h,p]=ttest(a1(valid,7)-a2(valid,7))
[mean(a1(valid,7)),std(a1(valid,7)),length(valid)]
[mean(a2(valid,7)),std(a2(valid,7)),length(valid)]



%% Behavior analyses
clc
clear all
try
[a,b]=xlsread('d:\infanteeg\CAM BABBLE EEG DATA\2024\table\behaviour2.5sd.xlsx'); 
catch
   [a,b]=xlsread('D:\infanteeg\CAM BABBLE EEG DATA\2024\table\behaviour2.5sd.xlsx');  
end

%% age sex
[aa,bb]=unique(a(:,2))
age=a(bb,3);
mean(age)/30
std(age)/30
sex=a(bb,4);
tabulate(sex)
%% age sex uk
[aa,bb]=unique(a(:,2))
bb=intersect(bb,find(a(:,1)==1))
age=a(bb,3);
mean(age)/30
std(age)/30
sex=a(bb,4);
tabulate(sex)
%% age sex sg
[aa,bb]=unique(a(:,2))
bb=intersect(bb,find(a(:,1)==2))
age=a(bb,3);
mean(age)/30
std(age)/30
sex=a(bb,4);
tabulate(sex)

% age dif between country
[aa,bb]=unique(a(:,2));
bb=intersect(bb,find(a(:,1)==1))
age1=a(bb,3);
[aa,bb]=unique(a(:,2));
bb=intersect(bb,find(a(:,1)==2))
age2=a(bb,3);
[h,p]=ttest2(age1,age2)



%% put into tables
c1=find(a(:,6)==1);
c2=find(a(:,6)==2);
c3=find(a(:,6)==3);
b1=find(a(:,5)==1);
b2=find(a(:,5)==2);
b3=find(a(:,5)==3);
uk=find(a(:,1)==1);
sg=find(a(:,1)==2);

a(c1,9)
a(c2,9)
a(c3,9)

a(c1,7)
a(c2,7)
a(c3,7)

%% one sample t on learning
[h,p1,CI,STATS]=ttest(a(c1,7))
[h,p2,CI,STATS]=ttest(a(c2,7))
[h,p3,CI,STATS]=ttest(a(c3,7))
q=mafdr([p1,p2,p3],'BHFDR',true)

% one sample t with covaries
% c1
X1 = [ones(size(a(c1,1))) a(c1,1:3)];
[~,~,resid1] = regress(a(c1,7), X1);
adjusted_scores1 = resid1 + nanmean(a(c1,7));

% c2
X2 = [ones(size(a(c2,1))) a(c2,1:3)];
[~,~,resid2] = regress(a(c2,7), X2);
adjusted_scores2 = resid2 + nanmean(a(c2,7));

% c3
X3 = [ones(size(a(c3,1))) a(c3,1:3)];
[~,~,resid3] = regress(a(c3,7), X3);
adjusted_scores3 = resid3 + nanmean(a(c3,7));

% final ttest
[h1,p1,CI1,STATS1] = ttest(adjusted_scores1);
[h2,p2,CI2,STATS2] = ttest(adjusted_scores2);
[h3,p3,CI3,STATS3] = ttest(adjusted_scores3);

% FDR
q = mafdr([p1,p2,p3],'BHFDR',true)


%%  atten ANOCOVA
group = a(:,6); 
covariate1 = a(:,1); 
covariate2 = a(:,3); 
covariate3 = a(:,4); 
response = a(:,9); 
% 
X = {group, covariate1, covariate2, covariate3};

% 
varnames = {'Group', 'Covariate1', 'Covariate2', 'Covariate3'};

% 
model = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1]; % 主效应模型

% ANCOVA
[p, table, stats, terms] = anovan(response, X, 'model', model, 'varnames', varnames, 'continuous', [2 3 4]);

% ANOVA TABLE
disp(table)

%% NW-W GAZE INTERACTION， failed
nw=(a(:,7)+a(:,8))/2;
w=-a(:,7)+nw;

group1 = repmat(a(:,6),2,1);  % 
group2=[ones(423,1);zeros(423,1)];
covariate1 =repmat(a(:,1),2,1);  % 
covariate2 = repmat(a(:,3),2,1);  % 
covariate3 = repmat(a(:,4),2,1);  % 
response = [nw;w]; 

% 
X = {group1, group2, covariate1, covariate2, covariate3};

% 
varnames = {'Group1', 'Group2', 'Covariate1', 'Covariate2', 'Covariate3'};

% 
model = [1 0 0 0 0;   % 主效应：Group1
         0 1 0 0 0;   % 主效应：Group2
         0 0 1 0 0;   % 主效应：Covariate1
         0 0 0 1 0;   % 主效应：Covariate2
         0 0 0 0 1;   % 主效应：Covariate3
         1 1 0 0 0];  % 交互效应：Group1*Group2

% ANCOVA
[p, table, stats, terms] = anovan(response, X, 'model', model, 'varnames', varnames, 'continuous', [3 4 5]);

% ANOVA TABLE
disp(table)

% 计算 nw 和 w
nw = (a(:,7) + a(:,8)) / 2;
w = -a(:,7) + nw;

% 定义分组变量和协变量
group1 = repmat(a(:,6), 2, 1);  % 重复 group1
group2 = [ones(423, 1); zeros(423, 1)];  % 二分类变量 group2
covariate1 = repmat(a(:,1), 2, 1);  % 协变量1
covariate2 = repmat(a(:,3), 2, 1);  % 协变量2
covariate3 = repmat(a(:,4), 2, 1);  % 协变量3
response = [nw; w];  % 因变量

% 将所有变量整合成表格
dataTable = table(response, group1, group2, covariate1, covariate2, covariate3, ...
    'VariableNames', {'Response', 'Group1', 'Group2', 'Covariate1', 'Covariate2', 'Covariate3'});

% 转换 group1 和 group2 为分类变量
dataTable.Group1 = categorical(dataTable.Group1);
dataTable.Group2 = categorical(dataTable.Group2);
dataTable.Covariate1 = categorical(dataTable.Covariate1);
% 定义 LME 模型公式，包含主效应和交互效应
modelFormula = 'Response ~ Group1 * Group2 + Covariate1 + Covariate2 + Covariate3';

% 拟合 LME 模型
lme = fitlme(dataTable, modelFormula);

% 显示模型结果
disp(lme);

%% LME for attention
% 
% SEX = categorical(SEX);
% COUNTRY = categorical(COUNTRY);
% ID = categorical(ID);
% % block(find(block==2))=1;
% block=a(:,5);
% block = categorical(block);
% % c1-c2c3
% CONDGROUP=a(:,6);
% % CONDGROUP(find(CONDGROUP==2))=4;
% % CONDGROUP(find(CONDGROUP==1))=2;
% % CONDGROUP(find(CONDGROUP==4))=1;
% CONDGROUP= categorical(CONDGROUP);
% tbl = table(ID, learning, AGE, SEX, COUNTRY,block,CONDGROUP,atten,'VariableNames', {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY','block','CONDGROUP','atten'});
% lme = fitlme(tbl, 'learning ~ AGE + SEX + COUNTRY + CONDGROUP + (1|ID)')
% 
% % c2-c3
% CONDGROUP=a(:,6);
% CONDGROUP(find(CONDGROUP==2))=4;
% CONDGROUP(find(CONDGROUP==1))=2;
% CONDGROUP(find(CONDGROUP==4))=1;
% CONDGROUP= categorical(CONDGROUP);
% tbl = table(ID, learning, AGE, SEX, COUNTRY,block,CONDGROUP,atten,'VariableNames', {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY','block','CONDGROUP','atten'});
% lme = fitlme(tbl, 'learning ~ AGE + SEX + COUNTRY + CONDGROUP + (1|ID)')


%% corr atten learning
aa=a;
aa(find(isnan(aa(:,7))==1),:)=[];
aa(find(isnan(aa(:,9))==1),:)=[];
[h,p]=partialcorr(aa(:,7),aa(:,9),aa(:,[1,3,4]))

index=find(aa(:,6)==1);
[h,p]=partialcorr(aa(index,7),aa(index,9),aa(index,[1,3,4]))
index=find(aa(:,6)==2);
[h,p]=partialcorr(aa(index,7),aa(index,9),aa(index,[1,3,4]))
index=find(aa(:,6)==3);
[h,p]=partialcorr(aa(index,7),aa(index,9),aa(index,[1,3,4]))




%% separate country

tbl = table(ID, learning, AGE, SEX, COUNTRY,block,CONDGROUP,atten,'VariableNames', {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY','block','CONDGROUP','atten'});
tbl(sg,:)=[];
    % Linear Mixed-Effects Model
lme = fitlme(tbl, 'learning ~ AGE + SEX  + CONDGROUP + (1|ID)');
lme

tbl = table(ID, learning, AGE, SEX, COUNTRY,block,CONDGROUP,atten,'VariableNames', {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY','block','CONDGROUP','atten'});
tbl(uk,:)=[];
    % Linear Mixed-Effects Model
lme = fitlme(tbl, 'learning ~ AGE + SEX  + CONDGROUP + (1|ID)');
lme

    % Linear Mixed-Effects Model
lme = fitlme(tbl, 'learning ~ AGE + SEX + COUNTRY*CONDGROUP + (1|ID)');
lme

lme = fitlme(tbl, 'atten ~ AGE + SEX + COUNTRY  + CONDGROUP + (1|ID)');
lme

lme = fitlme(tbl, 'atten ~ AGE + SEX + COUNTRY  *CONDGROUP + (1|ID)');
lme

ukc1=learning(intersect(c1,find(a(:,1)==1)));
[h,p]=ttest(ukc1)
ukc2=learning(intersect(c2,find(a(:,1)==1)));
[h,p]=ttest(ukc2)
ukc3=learning(intersect(c3,find(a(:,1)==1)));
[h,p]=ttest(ukc3)

sgc1=learning(intersect(c1,find(a(:,1)==2)));
[h,p]=ttest(sgc1)
sgc2=learning(intersect(c2,find(a(:,1)==2)));
[h,p]=ttest(sgc2)
sgc3=learning(intersect(c3,find(a(:,1)==2)));
[h,p]=ttest(sgc3)
% 
% 
% % for i=11:46
% %     [h,p(i-10)]=corr(a([c1;c2],i),a([c1;c2],7));
% % end
% 
% %% separete country
% try
% [a,b]=xlsread('d:\infanteeg\CAM BABBLE EEG DATA\2024\table\behaviour_cuterrorlearning_PDC4.xlsx'); 
% catch
%    [a,b]=xlsread('D:\infanteeg\CAM BABBLE EEG DATA\2024\table\behaviour_cuterrorlearning_PDC4.xlsx');  
% end
% % [a,b]=xlsread('d:\infanteeg\CAM BABBLE EEG DATA\2024\table\new3_OLD.xlsx');
% % [a,b]=xlsread('d:\infanteeg\CAM BABBLE EEG DATA\2024\table\new3_clear_atten_learning_withnan.xlsx');
% 
% cut=zeros(size(a,1),1);
% for i=1:size(a,1)
%     if sum(isnan(a(i,:)))~=0
%         cut(i)=1;
%     end
% end
% a(find(cut==1),:)=[];
% 
% cut=zeros(size(a,1),1);
% for i=1:size(a,1)
%     if a(i,1)==2
%         cut(i)=1;
%     end
% end
% a(find(cut==1),:)=[];
% % 
% cut=zeros(size(a,1),1);
% for i=1:size(a,1)
%     if a(i,6)==2
%         cut(i)=1;
%     end
% end
% a(find(cut==1),:)=[];
% 
% 
% c1=find(a(:,6)==1);
% c2=find(a(:,6)==2);
% c3=find(a(:,6)==3);
% 
% CONDGROUP=a(:,6);
% % CONDGROUP(find(CONDGROUP==2))=1;
% 
% ID = a(:, 2);
% 
% COUNTRY = a(:, 1);
% block=a(:, 5);
% 
% AGE = a(:, 3);
% SEX = a(:, 4);
% learning = a(:, 7);
% 
% atten = a(:, 9);
% models = cell(1, 24); % As there are 24 variables from a(cond,10) to a(cond,33)
% 
% 
% SEX = categorical(SEX);
% COUNTRY = categorical(COUNTRY);
% ID = categorical(ID);
% % block(find(block==2))=1;
% block=a(:,5)
% block = categorical(block);
% 
% CONDGROUP= categorical(CONDGROUP);
% % Initialize arrays to store t-values, dfs, and p-values
% tValueLearning = zeros(18, 1);
% dfLearning = zeros(18, 1);
% pValueLearning = zeros(18, 1);
% 
% tValueAtten = zeros(18, 1);
% dfAtten = zeros(18, 1);
% pValueAtten = zeros(18, 1);
% 
% 
% tbl = table(ID, learning, AGE, SEX, COUNTRY,block,CONDGROUP,atten,'VariableNames', {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY','block','CONDGROUP','atten'});
% 
%     % Linear Mixed-Effects Model
% lme = fitlme(tbl, 'learning ~ AGE + SEX   + CONDGROUP + (1|ID)');
% lme
% 
% lme = fitlme(tbl, 'atten ~ AGE + SEX   + CONDGROUP + (1|ID)');
% lme
% 
% atten(find(a(:,6)==1))
% atten(find(a(:,6)==2))
% atten(find(a(:,6)==3))
% 
% learning(find(a(:,6)==1))
% learning(find(a(:,6)==2))
% learning(find(a(:,6)==3))
% 
% 
% for i=11:46
%     [h,p(i-10)]=corr(a([c1;c2],i),a([c1;c2],7));
% end
% 
% 
