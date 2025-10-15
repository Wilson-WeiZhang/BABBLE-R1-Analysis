%% Load entrainment real and surr
clc
clear all
load('ENTRIANSURR.mat');
load("dataGPDC.mat");
% Read the CSV file
% path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'
path='C:\Users\Admin\OneDrive - Nanyang Technological University\/'

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

% % ALPHA
% listi=[ii3];
% load('stronglistfdr5_gpdc_II.mat')
% listii=listi(s4);
% ii=sqrt(data(:,listii));
% 
% listi=[ai3];
% load('stronglistfdr5_gpdc_AI.mat')
% listai=listi(s4);
% ai=sqrt(data(:,listai));
% 
% listi=[aa3];
% load('stronglistfdr5_gpdc_AA.mat')
% listaa=listi(s4);
% aa=sqrt(data(:,listaa));

% THETA
listi=[ii2];
load('stronglistfdr5_gpdc_IItheta.mat')
listii=listi(s4);
ii=sqrt(data(:,listii));

listi=[ai2];
load('stronglistfdr5_gpdc_AItheta.mat')
listai=listi(s4);
ai=sqrt(data(:,listai));

% listi=[aa2];
% load('stronglistfdr5_gpdc_AAtheta.mat')
% listaa=listi(s4);
% aa=sqrt(data(:,listaa));

% aa_surr=cell(1000,1);
ai_surr=cell(1000,1);
ii_surr=cell(1000,1);
for i=1:1000
    i
    tmp=data_surr{i};
    % aa_surr{i}=sqrt(tmp(:,listaa));
    ai_surr{i}=sqrt(tmp(:,listai));
    ii_surr{i}=sqrt(tmp(:,listii));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%%%%%%%%%%
%% figure 5b
%% 1000 time boot,for ai ii TO LEARNING
% rng(28);  % For reproducibility
SEX=double(SEX);
COUNTRY=double(COUNTRY);
% entrain=data2(:,[4,5,21,26,40]);
% valid=find(isnan(data2(:,4))==0);
valid=find(isnan(learning)==0);
% SWAP AI II HERE
tbl = table(ID, atten, zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, ii, ...
    'VariableNames', {'ID','atten', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP', 'ai'});
% for entrain
tbl=tbl(valid,:);
tbl.ai=zscore(tbl.ai);

n_folds = 10;  % Number of cross-validation folds
n_bootstrap = 1000;  % Number of bootstrap iterations
mean_variance_explained_bootstrap = zeros(n_bootstrap, 1);  % Store mean variance explained per bootstrap

for boot = 1:n_bootstrap
    % Bootstrap sample of the entire dataset
    bootstrap_idx = datasample(1:height(tbl), height(tbl), 'Replace', true);
    tbl_bootstrap = tbl(bootstrap_idx, :);

    variance_explained = zeros(n_folds, 1);  % Store variance explained per fold for each bootstrap

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
        n_components = 2;  % Number of components
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
                variance_explained(fold) = sum(corr(Y_test, scores_test(:, 1))^2);
    end

    % Mean variance explained for this bootstrap iteration
    mean_variance_explained_bootstrap(boot) = mean(variance_explained);
    boot
end

% Final results
mean_variance_explained = mean(mean_variance_explained_bootstrap);
std_variance_explained = std(mean_variance_explained_bootstrap);

% Display results
fprintf('\nBootstrap Results (1000 iterations) of Mean Variance Explained with 10-Fold CV:\n');
fprintf('Mean of Mean Variance Explained = %f, Std of Mean Variance Explained = %f\n', mean_variance_explained, std_variance_explained);
fprintf('Range of Mean Variance Explained = [%f, %f]\n', min(mean_variance_explained_bootstrap), max(mean_variance_explained_bootstrap));

