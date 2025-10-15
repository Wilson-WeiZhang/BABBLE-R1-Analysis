clc
clear all
% load('data_read_surr5.mat','data')
load('data_read_surr_gpdc2.mat')
a=data;
g1=find(a(:,6)==1);
g2=find(a(:,6)==2);
g3=find(a(:,6)==3);
g4=find(a(:,6)<=2);
AGE=a(:,3);
SEX=zscore(a(:,4));
SEX=categorical(SEX);
COUNTRY=zscore(a(:,1));
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

listi=[ai3];
load('stronglistfdr5_gpdc_AI.mat')
listai=listi(s4);
ai=sqrt(data(:,listai));

[a, b] = xlsread('f:\infanteeg\CAM BABBLE EEG DATA\2024\entrain\TABLE.xlsx');
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

c1=find(data(:,6)==1);
c2=find(data(:,6)==2);
c3=find(data(:,6)==3);


%% calculate learning without random effect

entrain=data2(:,[21]);
valid=find(isnan(entrain)==0);
entrain(valid)=zscore(entrain(valid));
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai, ai(:,12), 1);
[XL2,YL2,XS2,YS2,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii, ii(:,16), 1);

k1=XS1(:,1);
k2=XS2(:,1);

tbl = table(ID,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, zscore(k1), zscore(k2), zscore(k1.*k2), 'VariableNames',...
            {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
% tbl=tbl(g3,:);
 % mdl_full = fitlme(tbl(g1,:), 'learning ~ k1+ AGE + SEX + COUNTRY + (1|ID)')
 % mdl_full = fitlme (tbl,'learning ~ k2+ AGE + SEX + COUNTRY + (1|ID)')

 mdl = fitlme(tbl, 'learning ~ AGE+ SEX +COUNTRY+ (1|ID)');
% Assuming tbl and mdl are already defined as in your code

% Extract conditional residuals (accounting for both fixed and random effects)
conditional_residuals = residuals(mdl, 'Conditional', true);

% Extract marginal residuals (accounting for only fixed effects)
marginal_residuals = residuals(mdl, 'Conditional', false);


tbl.learning2=conditional_residuals;
save('learning2_c123.mat','conditional_residuals')
% 
% mdl = fitlme(tbl, 'learning2 ~  k1', 'FitMethod', 'ML');
% predictions_full = predict(mdl, tbl);
% r2= corr(tbl.learning2, predictions_full)^2
% 
%     mdl2 = fitlme(tbl, 'learning2 ~  k2', 'FitMethod', 'ML')
%     predictions_full = predict(mdl2, tbl);
% r2= corr(tbl.learning2, predictions_full)^2
% 
%     mdl3 = fitlme(tbl, 'learning2 ~  k2+k1', 'FitMethod', 'ML')
%         predictions_full = predict(mdl3, tbl);
% r2= corr(tbl.learning2, predictions_full)^2
% 
%     mdl4 = fitlme(tbl, 'learning2 ~  k2*k1')
%             predictions_full = predict(mdl4, tbl);
% r2= corr(tbl.learning2, predictions_full)^2



% Initialize variables
x =ii(group,11);  % Predictors
y = learning2(group);  % Response variable
n_bootstraps = 1000;
n_folds = 5;
bootresult = zeros(n_bootstraps, 1);

% Main bootstrap loop
for boot = 1:n_bootstraps
    % Get unique IDs for cross-validation
    unique_ids = unique(tbl.ID);
    n_ids = length(unique_ids);
    cv = cvpartition(n_ids, 'KFold', n_folds);
    
    % Initialize R2 storage for each fold
    R2_marg = zeros(n_folds, 4);  % Store R2 for different components
    
    % Cross-validation loop
    for i = 1:n_folds
        % Get training and test indices
        train_ids = unique_ids(cv.training(i));
        test_ids = unique_ids(cv.test(i));
        train_idx = ismember(tbl.ID, train_ids);
        test_idx = ismember(tbl.ID, test_ids);
        
        % Split data into training and test sets
        X_train = x(train_idx,:);
        y_train = y(train_idx);
        X_test = x(test_idx,:);
        y_test = y(test_idx);
        
        % Train PLS model with different numbers of components
        for ncomp = 1:1
            % Fit PLS model
            [~,~,~,~,beta,pctvar] = plsregress(X_train, y_train, ncomp);
            
            % Make predictions on test set
            y_pred = [ones(size(X_test,1),1) X_test] * beta;
            
         
            R2_marg(i,ncomp) = corr(y_pred,y_test).^2;
        end
    end
    
    % Store the mean R2 across folds for the best number of components
    [~, best_comp] = max(mean(R2_marg));
    bootresult(boot) = mean(R2_marg(:,best_comp));
end

% Calculate and display results
mean_R2 = mean(bootresult);
std_R2 = std(bootresult);
ci_R2 = prctile(bootresult, [2.5 97.5]);

fprintf('Mean R2: %.4f\n', mean_R2);
fprintf('Standard deviation of R2: %.4f\n', std_R2);
fprintf('95%% Confidence Interval: [%.4f, %.4f]\n', ci_R2(1), ci_R2(2));

% Optional: Plot histogram of bootstrap results
figure;
histogram(bootresult, 30);
xlabel('R^2 value');
ylabel('Frequency');
title('Distribution of R^2 values across bootstrap samples');



%% ii/ai to learning 5 fold boot
load('learning2_c123.mat')
learning2=conditional_residuals;
group=g1;
entrain=thetaf4;
valid=find(isnan(data2(:,4))==0);
entrain(valid)=(entrain(valid)-mean(entrain(valid)))./std(entrain(valid));
% 
% valid=intersect(valid,group);
y=data(:,6);
% y(find(y==3))=2;
Y_dummy = dummyvar(y);
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ii,Y_dummy, 1)
XS1 = -XS1;
XL1 = -XL1;
% [XL2,YL2,XS2,YS2,beta1,PCTVAR1,MSE1,stats1] = plsregress(ii,Y_dummy, 1)
[XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(ai(group,:), learning(group), 1)
% [XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii, learning2, 1)
% [XL4,YL4,XS4,YS4,beta2,PCTVAR2,MSE2,stats2] = plsregress(ai(valid,:), learning(valid), 1)
% [XL4,YL4,XS4,YS4,beta2,PCTVAR2,MSE2,stats2] = plsregress(ai, learning, 1)

% entrain=alphac3;
% entrain=alphapz;
% entrain=deltaf4;
k1=XS1;
k1=zscore(k1);
% k1(valid)=(k1(valid)-mean(k1(valid)))./std(k1(valid));
k2=nan*zeros(226,1);
k2(group)=XS3;
k2(group)=(k2(group)-mean(k2(group)))./std(k2(group));
% k2=XS3;
load('learning2_c123.mat')
tbl = table(ID,atten, entrain,zscore(learning2), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, k1, k2, zscore(k1.*k2), 'VariableNames',...
    {'ID','atten','entrain', 'learning2', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
tbl = tbl([group],:);
% 
tbl.k1=(tbl.k1-mean(tbl.k1))./std(tbl.k1);
% tbl.k2=(tbl.k2-mean(tbl.k2))./std(tbl.k2);
% tbl.learning2=conditional_residuals;

k=zeros(1000,4);
% R2_marg_std=0.2;R2_marg_mean=0;

for bootstra=1:1000

%     rng(ii)
%Mean = 0.184361, Std = 0.063368  ii=131
% Perform five-fold cross-validation
n_folds = 5;
unique_ids = unique(tbl.ID);
n_ids = length(unique_ids);
cv = cvpartition(n_ids, 'KFold', n_folds);
% load('cvorder.mat')

R2_marg1 = zeros(n_folds, 1);
R2_marg2 = zeros(n_folds, 1);
R2_marg3 = zeros(n_folds, 1);
R2_marg4 = zeros(n_folds, 1);

for i = 1:n_folds
    % Get training and test indices
    train_ids = unique_ids(cv.training(i));
    test_ids = unique_ids(cv.test(i));
    
    train_idx = ismember(tbl.ID, train_ids);
    test_idx = ismember(tbl.ID, test_ids);
    
    % Fit model on training data
    mdl = fitlme(tbl(train_idx,:), 'learning2 ~  k1', 'FitMethod', 'ML');
    mdl2 = fitlme(tbl(train_idx,:), 'learning2 ~  k2', 'FitMethod', 'ML');
    mdl3 = fitlme(tbl(train_idx,:), 'learning2 ~  k2+k1', 'FitMethod', 'ML');
    mdl4 = fitlme(tbl(train_idx,:), 'learning2 ~  k2*k1', 'FitMethod', 'ML');

    
    % Predict on test data
    [predictions1, ~, random_effects] = predict(mdl, tbl(test_idx,:));
    [predictions2, ~, random_effects] = predict(mdl2, tbl(test_idx,:));
    [predictions3, ~, random_effects] = predict(mdl3, tbl(test_idx,:));
    [predictions4, ~, random_effects] = predict(mdl4, tbl(test_idx,:));
    % Calculate marginal R2 (fixed effects only)
    R2_marg1(i) = corr(tbl.learning2(test_idx), predictions1)^2;
    R2_marg2(i) = corr(tbl.learning2(test_idx), predictions2)^2;
    R2_marg3(i) = corr(tbl.learning2(test_idx), predictions3)^2;
    R2_marg4(i) = corr(tbl.learning2(test_idx), predictions4)^2;
    
end

% Calculate and display results
R2_marg_mean1 = mean(R2_marg1);
% R2_cond_mean = mean(R2_cond);
R2_marg_std1 = std(R2_marg1);
% R2_cond_std = std(R2_cond);

fprintf('\nCross-validation results:\n');
fprintf('k1: Mean = %f, Std = %f\n', R2_marg_mean1, R2_marg_std1);
% Calculate and display results
R2_marg_mean2 = mean(R2_marg2);
% R2_cond_mean = mean(R2_cond);
R2_marg_std2 = std(R2_marg2);
% R2_cond_std = std(R2_cond);

fprintf('\nCross-validation results:\n');
fprintf('k2: Mean = %f, Std = %f\n', R2_marg_mean2, R2_marg_std2);

% Calculate and display results
R2_marg_mean3 = mean(R2_marg3);
% R2_cond_mean = mean(R2_cond);
R2_marg_std3 = std(R2_marg3);
% R2_cond_std = std(R2_cond);

fprintf('\nCross-validation results:\n');
fprintf('k1+k2: Mean = %f, Std = %f\n', R2_marg_mean3, R2_marg_std3);

% Calculate and display results
R2_marg_mean4 = mean(R2_marg4);
% R2_cond_mean = mean(R2_cond);
R2_marg_std4 = std(R2_marg4);
% R2_cond_std = std(R2_cond);

fprintf('\nCross-validation results:\n');
fprintf('k1*k2: Mean = %f, Std = %f\n', R2_marg_mean4, R2_marg_std4);

k(bootstra,:)=[R2_marg_mean1,R2_marg_mean2,R2_marg_mean3,R2_marg_mean4];
bootstra
end

mean(k)
% save('boot_predi_c2.mat','k')

[mean(R2_marg2),std(R2_marg2)]




%% surr predi
%% Load entrainment real and surr
% clc
% clear all
% load('temp_peakmax.mat')
% load("dataGPDC.mat");
% Read the CSV file
% [a, b] = xlsread('f:\infanteeg\CAM BABBLE EEG DATA\2024\entrain\TABLE.xlsx');
% 
% tableorder=[];
% 
% data2=zeros(226,54);
% 
% for i=1:length(a)
%     id=b{i+1,1};
%     if isequal(id(6),'C')==1
%         country=1;
%     else
%         country=2;
%     end
%    id2=str2num(id(3:5));
%    bl=a(i,1);
%    c=a(i,2);
%    p=a(i,3);
%    if p==1
%        for j=1:size(data,1)
%            if data(j,1)==country&&data(j,2)-data(j,1)*1000==id2&&data(j,5)==bl&& data(j,6)==c
%                % only phrase 1 's entrainment versus average GPDC
%                data2(j,:)=nanmean(a(i:i,4:57),1);
%                    tableorder(j)=i;
%                break
% 
%            end
%        end
%    end
% end
% 
% for i=1:size(data2,1)
%     if sum(data2(i,:))==0
%         data2(i,:)=nan;
%     end
% end
% 
% alphac3=data2(:,4);
% alphapz=data2(:,8);
% thetaf4=data2(:,21);
% deltaf4=data2(:,39);
% learning=data(:,7);
% atten=data(:,9);
% 
% data2_surr=cell(1000,1);
% for i=1:1000
%     i
%     tmp=permutable{i};
%     tmp2=zeros(226,54);
%     for j=1:226
%         if tableorder(j)~=0
%             tmp2(j,:)=table2array(tmp(tableorder(j),5:end));
%         else
%              tmp2(j,:)=nan;
%         end
%     end
%     data2_surr{i}=tmp2;
% end


%% load surr gpdc
clc
clear all
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

ai_surr=cell(1000,1);
ii_surr=cell(1000,1);


for i=1:1000
    i
    tmp=data_surr{i};
    ai_surr{i}=sqrt(tmp(:,listai));
    ii_surr{i}=sqrt(tmp(:,listii));
end


%% 

R2_marg1 = zeros(1000, 1);
R2_marg2 = zeros(1000, 1);
R2_marg3 = zeros(1000, 1);
R2_marg4 = zeros(1000, 1);

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
load('learning2_c2.mat')

for i = 1:1000
i
ais=ai_surr{i};
iis=ii_surr{i};

[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ais, ais(:,12), 1);
[XL2,YL2,XS2,YS2,beta2,PCTVAR2,MSE2,stats2] = plsregress(iis, iis(:,16), 1);

k1=XS1(:,1);
k2=XS2(:,1);

  tbl = table(ID,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, zscore(k1), zscore(k2), zscore(k1.*k2), 'VariableNames',...
{'ID', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
tbl=tbl(g2,:);
    tbl.learning2=conditional_residuals;

    % Fit model on training data
    mdl = fitlme(tbl, 'learning2 ~  k1', 'FitMethod', 'ML');
    mdl2 = fitlme(tbl, 'learning2 ~  k2', 'FitMethod', 'ML');
    mdl3 = fitlme(tbl, 'learning2 ~  k2+k1', 'FitMethod', 'ML');
    mdl4 = fitlme(tbl, 'learning2 ~  k2*k1', 'FitMethod', 'ML');
    
    
    % Predict on test data
    [predictions1, ~, random_effects] = predict(mdl, tbl);
    [predictions2, ~, random_effects] = predict(mdl2,  tbl);
    [predictions3, ~, random_effects] = predict(mdl3,  tbl);
    [predictions4, ~, random_effects] = predict(mdl4,  tbl);
    % Calculate marginal R2 (fixed effects only)
    R2_marg1(i) = corr(tbl.learning, predictions1)^2;
    R2_marg2(i) = corr(tbl.learning, predictions2)^2;
    R2_marg3(i) = corr(tbl.learning, predictions3)^2;
    R2_marg4(i) = corr(tbl.learning, predictions4)^2;
    
end

% Calculate and display results
R2_marg_mean1 = mean(R2_marg1);
% R2_cond_mean = mean(R2_cond);
R2_marg_std1 = std(R2_marg1);
% R2_cond_std = std(R2_cond);

fprintf('\nCross-validation results:\n');
fprintf('k1: Mean = %f, Std = %f\n', R2_marg_mean1, R2_marg_std1);
% Calculate and display results
R2_marg_mean2 = mean(R2_marg2);
% R2_cond_mean = mean(R2_cond);
R2_marg_std2 = std(R2_marg2);
% R2_cond_std = std(R2_cond);

fprintf('\nCross-validation results:\n');
fprintf('k2: Mean = %f, Std = %f\n', R2_marg_mean2, R2_marg_std2);

% Calculate and display results
R2_marg_mean3 = mean(R2_marg3);
% R2_cond_mean = mean(R2_cond);
R2_marg_std3 = std(R2_marg3);
% R2_cond_std = std(R2_cond);

fprintf('\nCross-validation results:\n');
fprintf('k1+k2: Mean = %f, Std = %f\n', R2_marg_mean3, R2_marg_std3);

% Calculate and display results
R2_marg_mean4 = mean(R2_marg4);
% R2_cond_mean = mean(R2_cond);
R2_marg_std4 = std(R2_marg4);
% R2_cond_std = std(R2_cond);

fprintf('\nCross-validation results:\n');
fprintf('k1*k2: Mean = %f, Std = %f\n', R2_marg_mean4, R2_marg_std4);


save('sur_predi_c2.mat','R2_marg1','R2_marg2','R2_marg3','R2_marg4')

[mean(R2_marg2),std(R2_marg2)]


