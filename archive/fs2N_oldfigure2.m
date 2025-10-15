%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure 2a %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% word nonword learning calculation figure 2a
[a,b]=xlsread('f:\infanteeg\CAM BABBLE EEG DATA\2024\table\behaviour2.5sd.xlsx');

c1=find(a(:,6)==1);
c2=find(a(:,6)==2);
c3=find(a(:,6)==3);
% a(:,8) = (nw+w)/2
% a(:,7) = nw-w

w=(a(:,8)*2-a(:,7))./2;
nw=(a(:,8)*2+a(:,7))./2;

valid=intersect(find(isnan(a(:,7))==0),c1);
[h,p1,s,t]=ttest(nw(valid)-w(valid))

[nanmean(nw(valid)),nanstd(nw(valid)),length(valid)]
[nanmean(w(valid)),nanstd(w(valid)),length(valid)]

valid=intersect(find(isnan(a(:,7))==0),c2);
[h,p2,s,t]=ttest(nw(valid)-w(valid))

[nanmean(nw(valid)),nanstd(nw(valid)),length(valid)]
[nanmean(w(valid)),nanstd(w(valid)),length(valid)]


valid=intersect(find(isnan(a(:,7))==0),c3);
[h,p3,s,t]=ttest(nw(valid)-w(valid))

[nanmean(nw(valid)),nanstd(nw(valid)),length(valid)]
[nanmean(w(valid)),nanstd(w(valid)),length(valid)]

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure 2a %%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure 2b %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Behavior analyses
clc
clear all
try
[a,b]=xlsread('f:\infanteeg\CAM BABBLE EEG DATA\2024\table\behaviour2.5sd.xlsx'); 
catch
   [a,b]=xlsread('d:\infanteeg\CAM BABBLE EEG DATA\2024\table\behaviour2.5sd.xlsx');  
end

%% age sex
[aa,bb]=unique(a(:,2))
age=a(bb,3);
mean(age)
std(age)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure 2b %%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure 2b %%%%%%%%%%%%%%%%%%%%%%%%%%%%








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







%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure 2c %%%%%%%%%%%%%%%%%%%%%%%%%%%%

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



%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure 2c %%%%%%%%%%%%%%%%%%%%%%%%%%%%










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
