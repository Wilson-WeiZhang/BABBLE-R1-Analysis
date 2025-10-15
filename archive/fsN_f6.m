% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

%% Load entrainment real and surr
clc
clear all
load('ENTRIANSURR.mat')
load("dataGPDC.mat");
% Read the CSV file
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

ai_surr=cell(1000,1);
ii_surr=cell(1000,1);
for i=1:1000
    i
    tmp=data_surr{i};
    ai_surr{i}=sqrt(tmp(:,listai));
    ii_surr{i}=sqrt(tmp(:,listii));
end

%% 
%% mediation model


%% medation
group=g1;
entrain=data2(:,21);
valid=find(isnan(data2(:,4))==0);
entrain(valid)=(entrain(valid)-mean(entrain(valid)))./std(entrain(valid));

valid=intersect(valid,group);
y=data(:,6);
% y(find(y==3))=2;
Y_dummy = dummyvar(y);
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai,Y_dummy, 1)
XS1 = -XS1;
XL1 = -XL1;
% [XL2,YL2,XS2,YS2,beta1,PCTVAR1,MSE1,stats1] = plsregress(ii,Y_dummy, 1)
[XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii(valid,:), learning(valid), 1)
% [XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii, learning, 1)
% [XL4,YL4,XS4,YS4,beta2,PCTVAR2,MSE2,stats2] = plsregress(ai(valid,:), learning(valid), 1)
% [XL4,YL4,XS4,YS4,beta2,PCTVAR2,MSE2,stats2] = plsregress(ai, learning, 1)

% entrain=alphac3;
% entrain=alphapz;
% entrain=deltaf4;
k1=XS1;
% k1(valid)=(k1(valid)-mean(k1(valid)))./std(k1(valid));
k2=nan*zeros(226,1);
k2(valid)=XS3;
k2(valid)=(k2(valid)-mean(k2(valid)))./std(k2(valid));
% k2=XS3;
tbl = table(ID,atten, entrain,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, k1, k2, zscore(k1.*k2), 'VariableNames',...
    {'ID','atten','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
tbl = tbl([group],:);

tbl.k1=(tbl.k1-mean(tbl.k1))./std(tbl.k1);



%% surr for mediation  
% 定义 Bootstrap 次数
group=g3;
for i=1:1000
    data2s=data2_surr{i};
    ais=ai_surr{i};
    iis=ii_surr{i};
  entrain=data2s(:,[21]);

valid=find(isnan(data2(:,4))==0);
entrain(valid)=(entrain(valid)-mean(entrain(valid)))./std(entrain(valid));

% valid=intersect(valid,group);
y=data(:,6);
% y(find(y==3))=2;
Y_dummy = dummyvar(y);
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ais,Y_dummy, 1);
XS1 = -XS1;
XL1 = -XL1;
% [XL2,YL2,XS2,YS2,beta1,PCTVAR1,MSE1,stats1] = plsregress(ii,Y_dummy, 1)
[XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(iis(group,:), learning(group), 1);
% [XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii, learning, 1)
% [XL4,YL4,XS4,YS4,beta2,PCTVAR2,MSE2,stats2] = plsregress(ai(valid,:), learning(valid), 1)
% [XL4,YL4,XS4,YS4,beta2,PCTVAR2,MSE2,stats2] = plsregress(ai, learning, 1)

% entrain=alphac3;
% entrain=alphapz;
% entrain=deltaf4;
k1=XS1;
% k1(valid)=(k1(valid)-mean(k1(valid)))./std(k1(valid));
k2=nan*zeros(226,1);
k2(group)=XS3;
k2(group)=(k2(group)-mean(k2(group)))./std(k2(group));
% k2=XS3;
tbl_sur = table(ID,atten, entrain,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, k1, k2, zscore(k1.*k2), 'VariableNames',...
    {'ID','atten','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
tbl_sur = tbl_sur([group],:);
tbl_sur.k1=(tbl_sur.k1-mean(tbl_sur.k1))./std(tbl_sur.k1);
           tbl_sur.learning=zscore( tbl_sur.learning);
            tbl_sur.AGE=zscore( tbl_sur.AGE);
            tbl_sur.k2=zscore( tbl_sur.k2);

            v=find(isnan(tbl_sur.entrain)==0);
        tbl_sur.entrain=(tbl_sur.entrain-nanmean(tbl_sur.entrain(v)))./nanstd(tbl_sur.entrain(v));


    % Step 2: 基于 Bootstrap 数据重新拟合模型
    % Step 2: 基于 Bootstrap 数据重新拟合模型
        m1 = fitlme(tbl_sur, 'k2 ~ entrain + AGE + SEX + COUNTRY + (1|ID)');
        m2 = fitlme(tbl_sur, 'learning ~ k2 + AGE + SEX + COUNTRY + (1|ID)');
        m3 = fitlme(tbl_sur, 'k2 ~ k1 + AGE + SEX + COUNTRY + (1|ID)');
        m4 = fitlme(tbl_sur, 'k1 ~ entrain + AGE + SEX + COUNTRY + (1|ID)');
        % 提取路径系数
        a1 = m1.Coefficients.Estimate(strcmp(m1.Coefficients.Name, 'entrain'));
        b1 = m2.Coefficients.Estimate(strcmp(m2.Coefficients.Name, 'k2'));
        a2 = m3.Coefficients.Estimate(strcmp(m3.Coefficients.Name, 'k1'));
        b2 = m4.Coefficients.Estimate(strcmp(m4.Coefficients.Name, 'entrain'));

        % 计算间接效应
        indirect_effects_boot_k2(i) = a2*b2 * b1;
        % +a2*b2*b1;
        i
        %
        %     % 提取路径系数
        %     a1_boot1 = mdl_m1_boot.Coefficients.Estimate(strcmp(mdl_m1_boot.Coefficients.Name, 'entrain'));
        %     b1_boot1 = mdl_y1_boot.Coefficients.Estimate(strcmp(mdl_y1_boot.Coefficients.Name, 'k2'));
        %
        %     % 计算间接效应
        %     indirect_effects_boot_k2(i) = a1_boot1 * b1_boot1;
        i

        % Step 2: 基于 Bootstrap 数据重新拟合模型
        m1 = fitlme(tbl_sur, 'k1 ~ entrain+ AGE + SEX + COUNTRY + (1|ID) ');
        m2 = fitlme(tbl_sur, 'learning ~ k1 + AGE + SEX + COUNTRY + (1|ID)');
        m3 = fitlme(tbl_sur, 'k1 ~ k2 + AGE + SEX + COUNTRY + (1|ID)');
        m4 = fitlme(tbl_sur, 'k2 ~ entrain + AGE + SEX + COUNTRY + (1|ID)');

        % 提取路径系数
        a1 = m1.Coefficients.Estimate(strcmp(m1.Coefficients.Name, 'entrain'));
        b1 = m2.Coefficients.Estimate(strcmp(m2.Coefficients.Name, 'k1'));
        a2 = m3.Coefficients.Estimate(strcmp(m3.Coefficients.Name, 'k2'));
        b2 = m4.Coefficients.Estimate(strcmp(m4.Coefficients.Name, 'entrain'));

        % 计算间接效应
        % rec_a1(i)=a1;
        % rec_b1(i)=b1;
        %  rec_a2(i)=a2;
        % rec_b2(i)=b2;
        indirect_effects_boot_k1(i) = a1 * b1;
        % +a2*b2*b1;
        i

        % Step 2: 基于 Bootstrap 数据重新拟合模型

        m5 = fitlme(tbl_sur, 'learning ~ entrain+ AGE + SEX + COUNTRY + (1|ID)');

        % 提取路径系数
        a1_boot = m5.Coefficients.Estimate(strcmp(m5.Coefficients.Name, 'entrain'));


        % 计算间接效应
        indirect_effects_boot_1(i) = a1_boot-indirect_effects_boot_k1(i)- indirect_effects_boot_k2(i);

        total_effects_boot(i) = a1_boot;


        m6 = fitlme(tbl_sur, 'learning ~ entrain+ k1+k2+AGE + SEX + COUNTRY + (1|ID)');

        % 提取路径系数
        a1_boot = m6.Coefficients.Estimate(strcmp(m6.Coefficients.Name, 'entrain'));


        % 计算间接效应
        indirect_effects_boot_2(i) = a1_boot;

end

% Step 3: 计算间接效应的置信区间
% alpha = 0.05;
lower_bound = prctile(indirect_effects_boot_k1, [2.5,97.5])
lower_bound = prctile(indirect_effects_boot_k2, [2.5,97.5])
lower_bound = prctile(indirect_effects_boot_1, [2.5,97.5])
lower_bound = prctile(indirect_effects_boot_2, [2.5,97.5])
lower_bound = prctile(total_effects_boot, [5,95])
save('surrf4_c3.mat','indirect_effects_boot_k1','indirect_effects_boot_k2','indirect_effects_boot_1','indirect_effects_boot_2','total_effects_boot')



%% ai learning 5 fold 1000boot
%% bootstrap for effect ranges.
entrain=thetaf4;
% entrain=deltaf4;
% entrain(valid)=XS3(:,1);
% entrain=XS3(:,1);
valid=find(isnan(entrain)==0);
entrain(valid)=zscore(entrain(valid));

[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai, ai(:,12), 1)
[XL2,YL2,XS2,YS2,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii, ii(:,16), 1)

k1=XS1(:,1);
k2=XS2(:,1);


% valid=intersect(find(isnan(data2(:,4))==0),find(data(:,6)==1));
% valid=find(isnan(data2(:,4))==0);
valid=find(data(:,6)==1);

% valid=1:226;
% 假设 ai 和 data 已经定义，learning 是目标变量
% 设置参数
n_bootstrap = 1000;
n_folds =5;
n_components = 1;

% [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([ai(valid,:),data(valid,[1,3,4])]),zscore(learning(valid)),n_components)

% 准备数据
X = zscore([k2(valid,:), data(valid,[1,3,4])]);
Y = zscore(learning(valid));
n_samples = size(X, 1);
% 初始化结果存储
R2_results = zeros(n_bootstrap, 1);

% Bootstrap 循环
for boot = 1:n_bootstrap
    % Bootstrap 采样
    boot_indices = randi(n_samples, n_samples, 1);
    X_boot = X(boot_indices, :);
    Y_boot = Y(boot_indices);
    
    % 准备交叉验证
    cv = cvpartition(size(X_boot, 1), 'KFold', n_folds);
    Y_pred = zeros(size(Y_boot));
    
    % 交叉验证循环
    for fold = 1:n_folds
        % 获取训练和测试索引
        train_idx = cv.training(fold);
        test_idx = cv.test(fold);
        
        % 训练 PLS 模型
        [~,~,~,~,beta] = plsregress(X_boot(train_idx,:), Y_boot(train_idx), n_components);
        
        % 预测测试集
        Y_pred(test_idx) = [ones(sum(test_idx), 1) X_boot(test_idx,:)] * beta;
    end
    
    % 计算 R^2
    R2_results(boot) = corr(Y_boot, Y_pred)^2;
    
    % 显示进度
    if mod(boot, 100) == 0
        fprintf('Completed bootstrap iteration %d of %d\n', boot, n_bootstrap);
    end
end

% 计算并显示结果
mean_R2 = mean(R2_results);
std_R2 = std(R2_results);
ci_R2 = prctile(R2_results, [2.5 97.5]);

fprintf('Mean R^2: %.4f\n', mean_R2);
fprintf('Standard Deviation of R^2: %.4f\n', std_R2);
fprintf('95%% Confidence Interval of R^2: [%.4f, %.4f]\n', ci_R2(1), ci_R2(2));

% 绘制 R^2 分布直方图
figure;
histogram(R2_results, 30);
xlabel('R^2');
ylabel('Frequency');
title('Distribution of R^2 from Bootstrap Samples');



%% plot ai comp
load('stronglistfdr5_gpdc_AI.mat')
z=zeros(9,9);

[XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([ai,data(:,[1,3,4])]),zscore(learning),2);

z(s1)=XL(1:75,2);
imagesc(z)


%% 
%% plot c1
entrain=data2(:,[21]);
valid=find(isnan(entrain)==0);
entrain(valid)=zscore(entrain(valid));
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai, ai(:,12), 1);
[XL2,YL2,XS2,YS2,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii, ii(:,16), 1);
k1=XS1(:,1);
k2=XS2(:,1);
tbl = table(ID, entrain,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, zscore(k1), zscore(k2), zscore(k1.*k2), 'VariableNames',...
            {'ID','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
 m1 = fitlme(tbl(g1,:), 'learning ~ k1+ AGE + SEX + COUNTRY + (1|ID)')
 m2 = fitlme(tbl(g1,:), 'k1 ~ entrain+ AGE + SEX + COUNTRY + (1|ID)')
 m3 = fitlme(tbl(g1,:), 'learning ~ k2+ AGE + SEX + COUNTRY + (1|ID)')
 m4 = fitlme(tbl(g1,:), 'k2 ~ entrain+ AGE + SEX + COUNTRY + (1|ID)')
 m5 = fitlme(tbl(g1,:), 'k2 ~ k1+ AGE + SEX + COUNTRY + (1|ID)')
 m6 = fitlme(tbl(g1,:), 'learning ~ k1+k2+entrain+ AGE + SEX + COUNTRY + (1|ID)')

% 提取所需的系数
b_k1_learning = m1.Coefficients.Estimate(strcmp(m1.Coefficients.Name, 'k1'));
b_entrain_k1 = m2.Coefficients.Estimate(strcmp(m2.Coefficients.Name, 'entrain'));
b_k2_learning = m3.Coefficients.Estimate(strcmp(m3.Coefficients.Name, 'k2'));
b_entrain_k2 = m4.Coefficients.Estimate(strcmp(m4.Coefficients.Name, 'entrain'));
b_k1_k2 = m5.Coefficients.Estimate(strcmp(m5.Coefficients.Name, 'k1'));
b_entrain_learning = m6.Coefficients.Estimate(strcmp(m6.Coefficients.Name, 'entrain'));

% 计算间接效应
real_ai = b_k1_learning * b_entrain_k1
real_ii = b_k2_learning * b_entrain_k2 + b_entrain_k1 * b_k2_learning * b_k1_k2
% real_direct = b_entrain_learning

load('surrf4_c1.mat');
range1=prctile(indirect_effects_boot_k1,[2.5,97.5])
range1=prctile(indirect_effects_boot_k2,[2.5,97.5])
% range1=prctile(indirect_effects_boot_1,[2.5,97.5])

load('bootf4_c1.mat');
range2=prctile(indirect_effects_boot_k1,[5,95])
range2=prctile(indirect_effects_boot_k2,[5,95])
% range1=prctile(indirect_effects_boot_1,[2.5,97.5])


%% plot c2
entrain=data2(:,[21]);
valid=find(isnan(entrain)==0);
entrain(valid)=zscore(entrain(valid));
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai, ai(:,12), 1);
[XL2,YL2,XS2,YS2,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii, ii(:,16), 1);
k1=XS1(:,1);
k2=XS2(:,1);
tbl = table(ID, entrain,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, zscore(k1), zscore(k2), zscore(k1.*k2), 'VariableNames',...
            {'ID','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
 m1 = fitlme(tbl(g2,:), 'learning ~ k1+ AGE + SEX + COUNTRY + (1|ID)')
 m2 = fitlme(tbl(g2,:), 'k1 ~ entrain+ AGE + SEX + COUNTRY + (1|ID)')
 m3 = fitlme(tbl(g2,:), 'learning ~ k2+ AGE + SEX + COUNTRY + (1|ID)')
 m4 = fitlme(tbl(g2,:), 'k2 ~ entrain+ AGE + SEX + COUNTRY + (1|ID)')
 m5 = fitlme(tbl(g2,:), 'k2 ~ k1+ AGE + SEX + COUNTRY + (1|ID)')


% 提取所需的系数
b_k1_learning = m1.Coefficients.Estimate(strcmp(m1.Coefficients.Name, 'k1'));
b_entrain_k1 = m2.Coefficients.Estimate(strcmp(m2.Coefficients.Name, 'entrain'));
b_k2_learning = m3.Coefficients.Estimate(strcmp(m3.Coefficients.Name, 'k2'));
b_entrain_k2 = m4.Coefficients.Estimate(strcmp(m4.Coefficients.Name, 'entrain'));
b_k1_k2 = m5.Coefficients.Estimate(strcmp(m5.Coefficients.Name, 'k1'));

% 计算间接效应
real_ai = b_k1_learning * b_entrain_k1
real_ii = b_k2_learning * b_entrain_k2 + b_entrain_k1 * b_k2_learning * b_k1_k2

load('surrf4_c2.mat');
range1=prctile(indirect_effects_boot_k1,[2.5,97.5])
range1=prctile(indirect_effects_boot_k2,[2.5,97.5])

load('bootf4_c2.mat');
range2=prctile(indirect_effects_boot_k1,[5,95])
range2=prctile(indirect_effects_boot_k2,[5,95])


%% plot c3
entrain=data2(:,[21]);
valid=find(isnan(entrain)==0);
entrain(valid)=zscore(entrain(valid));
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai, ai(:,12), 1);
[XL2,YL2,XS2,YS2,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii, ii(:,16), 1);
k1=XS1(:,1);
k2=XS2(:,1);
tbl = table(ID, entrain,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, zscore(k1), zscore(k2), zscore(k1.*k2), 'VariableNames',...
            {'ID','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
 m1 = fitlme(tbl(g3,:), 'learning ~ k1+ AGE + SEX + COUNTRY + (1|ID)')
 m2 = fitlme(tbl(g3,:), 'k1 ~ entrain+ AGE + SEX + COUNTRY + (1|ID)')
 m3 = fitlme(tbl(g3,:), 'learning ~ k2+ AGE + SEX + COUNTRY + (1|ID)')
 m4 = fitlme(tbl(g3,:), 'k2 ~ entrain+ AGE + SEX + COUNTRY + (1|ID)')
 m5 = fitlme(tbl(g3,:), 'k2 ~ k1+ AGE + SEX + COUNTRY + (1|ID)')


% 提取所需的系数
b_k1_learning = m1.Coefficients.Estimate(strcmp(m1.Coefficients.Name, 'k1'));
b_entrain_k1 = m2.Coefficients.Estimate(strcmp(m2.Coefficients.Name, 'entrain'));
b_k2_learning = m3.Coefficients.Estimate(strcmp(m3.Coefficients.Name, 'k2'));
b_entrain_k2 = m4.Coefficients.Estimate(strcmp(m4.Coefficients.Name, 'entrain'));
b_k1_k2 = m5.Coefficients.Estimate(strcmp(m5.Coefficients.Name, 'k1'));

% 计算间接效应
real_ai = b_k1_learning * b_entrain_k1
real_ii = b_k2_learning * b_entrain_k2 + b_entrain_k1 * b_k2_learning * b_k1_k2

load('surrf4_c3.mat');
range1=prctile(indirect_effects_boot_k1,[2.5,97.5])
range1=prctile(indirect_effects_boot_k2,[2.5,97.5])

load('bootf4_c3.mat');
range2=prctile(indirect_effects_boot_k1,[5,95])
range2=prctile(indirect_effects_boot_k2,[5,95])



%% end here

[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(x2, learning, 2)

valid=find(isnan(data2(:,4))==0);
corr(XS1(valid,:),data2(valid,[4,8,21,39]))


[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai, ai(:,12), 2)
valid=find(data(:,6)==1);
[h,p]=corr(XS1(valid,1),y)
[h,p]=corr(XS1(valid,2),y)

[h,p]=corr(XS1(valid,1),learning(valid))
[h,p]=corr(XS1(valid,2),learning(valid))

[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ii, ii(:,16), 2)

valid=intersect(find(isnan(data2(:,4))==0),find(data(:,6)==1));
[h,p]=corr(XS1(valid,1),y)
[h,p]=corr(XS1(valid,2),y)

valid=find(data(:,6)==1);
[h,p]=corr(XS1(valid,1),learning(valid))
[h,p]=corr(XS1(valid,2),learning(valid))
% y=rand(size(x1));

% 第一步：对 x1 进行 PLS 回归以预测 learning
valid=1:226
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(x1, learning(valid), 1)

% 第二步：对 x2 进行 PLS 回归以预测 learning
valid=1:226
[XL2,YL2,XS2,YS2,beta2,PCTVAR2,MSE2,stats2] = plsregress(x2, learning(valid), 1)

% 第二步：对 x2 进行 PLS 回归以预测 learning
valid=find(isnan(data2(:,4))==0)
[XL3,YL3,XS3,YS3,beta3,PCTVAR3,MSE3,stats3] = plsregress(y(valid,:), learning(valid), 1);


% 第三步：提取 x1 和 x2 的前两个 LOADING 成分
loadings1 = XL1(:, 1:2);
loadings2 = XL2(:, 1:2);
loadings3 = XL3(:, 1:2);


% 显示结果
disp('x1 的载荷 (前两个成分):');
disp(loadings1);
disp('x1 解释的 X 方差百分比:');
disp(PCTVAR1(1, :));
disp('x1 解释的 Y 方差百分比:');
disp(PCTVAR1(2, :));

disp('x2 的载荷 (前两个成分):');
disp(loadings2);
disp('x2 解释的 X 方差百分比:');
disp(PCTVAR2(1, :));
disp('x2 解释的 Y 方差百分比:');
disp(PCTVAR2(2, :));

disp('x3 的载荷 (前两个成分):');
disp(loadings3);
disp('x3 解释的 X 方差百分比:');
disp(PCTVAR3(1, :));
disp('x3 解释的 Y 方差百分比:');
disp(PCTVAR3(2, :));

% 第四步：使用 y 预测这些成分

% 对 x1 的每个成分进行多元线性回归
x1_component1_model = fitlm([y,data(valid,[1,3,4])], XS1(:,1));
x1_component2_model = fitlm([y,data(valid,[1,3,4])], XS1(:,2));

% 对 x2 的每个成分进行多元线性回归
x2_component1_model = fitlm([y,data(valid,[1,3,4])], XS2(:,1));
x2_component2_model = fitlm([y,data(valid,[1,3,4])], XS2(:,2));

% 显示结果
disp('使用 y 预测 x1 第一个成分的结果:');
disp(x1_component1_model);
disp('使用 y 预测 x1 第二个成分的结果:');
disp(x1_component2_model);

disp('使用 y 预测 x2 第一个成分的结果:');
disp(x2_component1_model);
disp('使用 y 预测 x2 第二个成分的结果:');
disp(x2_component2_model);

% 可视化
figure;
subplot(2,2,1);
plot(y * x1_component1_model.Coefficients.Estimate(2:end), scores1(:,1), '.');
title('y 预测的 x1 第一个成分 vs 实际值');
xlabel('预测值'); ylabel('实际值');

subplot(2,2,2);
plot(y * x1_component2_model.Coefficients.Estimate(2:end), scores1(:,2), '.');
title('y 预测的 x1 第二个成分 vs 实际值');
xlabel('预测值'); ylabel('实际值');

subplot(2,2,3);
plot(y * x2_component1_model.Coefficients.Estimate(2:end), scores2(:,1), '.');
title('y 预测的 x2 第一个成分 vs 实际值');
xlabel('预测值'); ylabel('实际值');

subplot(2,2,4);
plot(y * x2_component2_model.Coefficients.Estimate(2:end), scores2(:,2), '.');
title('y 预测的 x2 第二个成分 vs 实际值');
xlabel('预测值'); ylabel('实际值');


% PLS Regression with Leave-One-Out Cross-Validation

% Ensure x and y are in the correct orientation
[n_samples, n_features] = size(x);
[n_samples_y, n_targets] = size(y);

if n_samples ~= n_samples_y
    error('Number of samples in x and y must match');
end

% Number of PLS components
n_components = 4;  % You can adjust this

% Initialize prediction matrix
y_pred = zeros(size(y));

% Perform Leave-One-Out Cross-Validation
for i = 1:n_samples
    % Leave-one-out
    train_idx = [1:i-1, i+1:n_samples];
    test_idx = i;
    
    x_train = x(train_idx, :);
    y_train = y(train_idx, :);
    x_test = x(test_idx, :);
    
    % Perform PLS regression
    [~, ~, ~, ~, beta] = plsregress(x_train, y_train, n_components);
    
    % Predict
    y_pred(test_idx, :) = [1 x_test] * beta;
end

% Calculate R² using squared correlation for each target
R2 = zeros(1, n_targets);
for j = 1:n_targets
    correlation = corrcoef(y(:,j), y_pred(:,j));
    R2(j) = correlation(1,2)^2;
end

% Display results
disp('R² values for each target:');
disp(R2);

% Optional: Calculate mean R² across all targets
mean_R2 = mean(R2);
disp(['Mean R² across all targets: ', num2str(mean_R2)]);

% Optional: Plot actual vs predicted values for each target
for j = 1:n_targets
    figure;
    scatter(y(:,j), y_pred(:,j));
    title(['Target ' num2str(j) ': Actual vs Predicted (R² = ' num2str(R2(j)) ')']);
    xlabel('Actual');
    ylabel('Predicted');
end


%% ai 3c
load('learning2_c123.mat')
learning2=conditional_residuals;
% valid=find(data(:,6)==3);
valid=1:226
plotk=zeros(20,2);RECORD=[];

for comp=1:1
[XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([ai(valid,:)]),zscore(learning2(valid)),comp);
PCTVAR_real1=sum(PCTVAR(1,:));
PCTVAR_real2=sum(PCTVAR(2,:));
plotk(comp,1)=PCTVAR_real2;
XLs=zeros(80,1000);
% ai2=rand(size(ai))
% [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(ai2,learning);
% PCTVAR_real=sum(PCTVAR(1,1:2))
% PCTVAR_real=sum(PCTVAR(2,1:2))

PCTVAR_su1=zeros(1000,1);
PCTVAR_su2=zeros(1000,1);
for i=1:1000
    data2s=data2_surr{i};
    iis=ii_surr{i};
    ais=ai_surr{i};
    % valid=find(isnan(data2(:,4))==0);
    % valid=intersect(find(isnan(data2s(:,4))==0),find(data(:,6)==1));
    [XLs(:,i),YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([ais(valid,:)]),zscore(learning2(valid)),comp);
    PCTVAR_su1(i)=sum(PCTVAR(1,:));
    PCTVAR_su2(i)=sum(PCTVAR(2,:));
end
prctile(PCTVAR_su1,95)
prctile(PCTVAR_su2,95)
RECORD=[RECORD,mean(PCTVAR_su2)];
plotk(comp,2)=prctile(PCTVAR_su2,95);
comp
end

plot(plotk)

for i=1:80

    m=prctile(XLs(i,:),[2.5,97.5]);
    if XL(i)<m(1)|| XL(i)>m(2)
        i
    end
end
% i=29 41 47
c3 f4
cz c4
c4 f4


%% 
valid=intersect(find(isnan(data2(:,4))==0),find(data(:,6)==1));

valid=(find(isnan(data2(:,4))==0));
% valid
corr(XS(valid,1),data2(valid,4))
corr(XS(valid,1),data2(valid,5))
corr(XS(valid,1),data2(valid,21))
corr(XS(valid,1),data2(valid,26))
corr(XS(valid,1),data2(valid,40))




%% ai 3c
plotk=zeros(15,3);
for comp=1:15  
[XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([ai]),zscore(learning2),comp);
PCTVAR_real1=sum(PCTVAR(1,:));
PCTVAR_real2=sum(PCTVAR(2,:));
plotk(comp,1)=PCTVAR_real2;

% ai2=rand(size(ai))
% [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(ai2,learning);
% PCTVAR_real=sum(PCTVAR(1,1:2))
% PCTVAR_real=sum(PCTVAR(2,1:2))

PCTVAR_su1=zeros(1000,1);
PCTVAR_su2=zeros(1000,1);
for i=1:1000
    data2s=data2_surr{i};
    iis=ii_surr{i};
    ais=ai_surr{i};
    % valid=find(isnan(data2(:,4))==0);
    % valid=intersect(find(isnan(data2s(:,4))==0),find(data(:,6)==1));
    [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([iis,randn(226,16),data(:,[1,3,4])]),zscore(learning),comp);
    PCTVAR_su1(i)=sum(PCTVAR(1,:));
    PCTVAR_su2(i)=sum(PCTVAR(2,:));
end
prctile(PCTVAR_su1,95)
prctile(PCTVAR_su2,95)

plotk(comp,2)=prctile(PCTVAR_su2,95);
plotk(comp,3)=mean(PCTVAR_su2);
comp
end

plot(plotk)


%% loading plot

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
custom_colormap = [neg_colors; pos_colors];
%% 

% 定义标签
labels = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};

n = zeros(9,9);
n(find(full_matrix_ai == 1)) = XL(1:80,4);  % 将XL1的数据填充到n中
figure;  % 打开一个新的图形窗口
imagesc(n);  % 显示矩阵数据

% 为 X 和 Y 轴设置标签
set(gca, 'XTick', 1:9, 'XTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 12);  % 设置 X 轴标签并加粗
set(gca, 'YTick', 1:9, 'YTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 12);  % 设置 Y 轴标签并加粗

% 设置标题和轴标签
xlabel('Sender Channels', 'FontWeight', 'bold', 'FontSize', 12, 'FontName', 'Arial');
ylabel('Receiver Channels', 'FontWeight', 'bold', 'FontSize', 12, 'FontName', 'Arial');
title('Component No.1 Loadings for AI GPDC', 'FontWeight', 'bold', 'FontSize', 14, 'FontName', 'Arial')
colormap(custom_colormap);  % 应用自定义 colormap
colorbar;  % 显示 colorbar
% Step 3: 设置颜色范围 [-0.5, 0.5]
caxis([-10, 10]);  % 设置颜色映射范围
% 添加 colorbar，并调整颜色条的属性
h = colorbar;
set(h, 'FontSize', 10, 'FontName', 'Arial','FontWeight', 'bold');  % 设置颜色条的字体和大小
% 加粗轴线
set(gca, 'LineWidth', 2);
h = colorbar;  % 创建 colorbar
set(h, 'LineWidth', 2);  % 设置 colorbar 的边框线宽为 2 磅
hold off;
%% 
k=1
valid=intersect(find(isnan(data2(:,4))==0),g3);
corr(XS(valid,k),alphac3(valid))
corr(XS(valid,k),alphapz(valid))
corr(XS(valid,k),thetaf4(valid))
corr(XS(valid,k),deltaf4(valid))
corr(XS(valid,k),alphacz(valid))
corr(XS(valid,k),thetapz(valid))
corr(XS(valid,k),deltac3(valid))

% 处理第二个图形 (for XL2)
n = zeros(9,9);
n(find(full_matrix_ii == 1)) = XL(1:80,1);  % 将XL2的数据填充到n中
figure;  % 打开一个新的图形窗口
imagesc(n);  % 显示矩阵数据

% 设置标题和轴标签
xlabel('Sender Channels', 'FontWeight', 'bold', 'FontSize', 12, 'FontName', 'Arial');
ylabel('Receiver Channels', 'FontWeight', 'bold', 'FontSize', 12, 'FontName', 'Arial');
title('Component No.1 Loadings for II GPDC', 'FontWeight', 'bold', 'FontSize', 18, 'FontName', 'Arial');

% 为 X 和 Y 轴设置标签
set(gca, 'XTick', 1:9, 'XTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 12);  % 设置 X 轴标签并加粗
set(gca, 'YTick', 1:9, 'YTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 12);  % 设置 Y 轴标签并加粗

colormap(custom_colormap);  % 应用自定义 colormap
colorbar;  % 显示 colorbar
% Step 3: 设置颜色范围 [-0.5, 0.5]
caxis([-0.25, 0.25]);  % 设置颜色映射范围
% 添加 colorbar，并调整颜色条的属性
h = colorbar;
set(h, 'FontSize', 10, 'FontName', 'Arial','FontWeight', 'bold');  % 设置颜色条的字体和大小
% 加粗轴线
h = colorbar;  % 创建 colorbar
set(h, 'LineWidth', 2);  % 设置 colorbar 的边框线宽为 2 磅
set(gca, 'LineWidth', 2);
hold off;







%% ai C1
plotk=zeros(15,2);
for comp=1:15
% valid=intersect(find(isnan(data2s(:,4))==0),find(data(:,6)==2));
 valid=find(data(:,6)==3);
[XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([ai(valid,:),data(valid,[1,3,4])]),zscore(learning(valid)),comp);
PCTVAR_real1=sum(PCTVAR(1,:));
PCTVAR_real2=sum(PCTVAR(2,:));
plotk(comp,1)=PCTVAR_real2;

% ai2=rand(size(ai))
% [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(ai2,learning);
% PCTVAR_real=sum(PCTVAR(1,1:2))
% PCTVAR_real=sum(PCTVAR(2,1:2))

PCTVAR_su1=zeros(1000,1);
PCTVAR_su2=zeros(1000,1);
for i=1:1000
    data2s=data2_surr{i};
    iis=ii_surr{i};
    ais=ai_surr{i};
    % valid=find(isnan(data2(:,4))==0);
    % valid=intersect(find(isnan(data2s(:,4))==0),find(data(:,6)==2));
     % valid=find(data(:,6)==1);
    [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([ais(valid,:),data(valid,[1,3,4])]),zscore(learning(valid)),comp);
    PCTVAR_su1(i)=sum(PCTVAR(1,:));
    PCTVAR_su2(i)=sum(PCTVAR(2,:));
end
prctile(PCTVAR_su1,95)
prctile(PCTVAR_su2,95)

plotk(comp,2)=prctile(PCTVAR_su2,95);
comp
end
plot(plotk)



%% II
plotk=zeros(5,3);
for comp=1:5
[XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([ii,data(:,[1,3,4])]),zscore(learning),comp);
PCTVAR_real1=sum(PCTVAR(1,:));
PCTVAR_real2=sum(PCTVAR(2,:));
plotk(comp,1)=PCTVAR_real2;

% ai2=rand(size(ai))
% [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(ai2,learning);
% PCTVAR_real=sum(PCTVAR(1,1:2))
% PCTVAR_real=sum(PCTVAR(2,1:2))

PCTVAR_su1=zeros(1000,1);
PCTVAR_su2=zeros(1000,1);
for i=1:1000
    data2s=data2_surr{i};
    iis=ii_surr{i};
    ais=ai_surr{i};
    % valid=find(isnan(data2(:,4))==0);
    % valid=intersect(find(isnan(data2s(:,4))==0),find(data(:,6)==1));
    [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([iis,data(:,[1,3,4])]),zscore(learning),comp);
    PCTVAR_su1(i)=sum(PCTVAR(1,:));
    PCTVAR_su2(i)=sum(PCTVAR(2,:));
end
prctile(PCTVAR_su1,95)
prctile(PCTVAR_su2,95)

plotk(comp,2)=prctile(PCTVAR_su2,95);
plotk(comp,3)=mean(PCTVAR_su2);
comp
end
 plot(plotk)




%% entrain
plotk=zeros(20,3);
valid=find(isnan(data2(:,4))==0);
for comp=1:20
[XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([data2(valid,[4,5,21,26,40]),data(valid,[1,3,4])]),zscore(learning(valid)),comp);
PCTVAR_real1=sum(PCTVAR(1,:));
PCTVAR_real2=sum(PCTVAR(2,:));
plotk(comp,1)=PCTVAR_real2;

% ai2=rand(size(ai))
% [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(ai2,learning);
% PCTVAR_real=sum(PCTVAR(1,1:2))
% PCTVAR_real=sum(PCTVAR(2,1:2))

PCTVAR_su1=zeros(1000,1);
PCTVAR_su2=zeros(1000,1);
for i=1:1000
    data2s=data2_surr{i};
   
   [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([data2s(valid,[4,5,21,26,40]),data(valid,[1,3,4])]),zscore(learning(valid)),comp);
 PCTVAR_su1(i)=sum(PCTVAR(1,:));
    PCTVAR_su2(i)=sum(PCTVAR(2,:));
end
prctile(PCTVAR_su1,95)
prctile(PCTVAR_su2,95)

plotk(comp,2)=prctile(PCTVAR_su2,95);
plotk(comp,3)=mean(PCTVAR_su2);
comp
end
 plot(plotk)



%% ii C1
plotk=zeros(10,2);

for comp=1:10
valid=intersect(find(isnan(data2s(:,4))==0),find(data(:,6)==1));
 valid=find(data(:,6)==1);
[XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([ii(valid,:),data(valid,[1,3,4])]),zscore(learning(valid)),comp, 'CV', 5);
PCTVAR_real1=sum(PCTVAR(1,:));
PCTVAR_real2=sum(PCTVAR(2,:));
plotk(comp,1)=PCTVAR_real2;

% ai2=rand(size(ai))
% [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(ai2,learning);
% PCTVAR_real=sum(PCTVAR(1,1:2))
% PCTVAR_real=sum(PCTVAR(2,1:2))

PCTVAR_su1=zeros(1000,1);
PCTVAR_su2=zeros(1000,1);
for i=1:1000
    data2s=data2_surr{i};
    iis=ii_surr{i};
    ais=ai_surr{i};
    % valid=find(isnan(data2(:,4))==0);
    % valid=intersect(find(isnan(data2s(:,4))==0),find(data(:,6)==2));
     % valid=find(data(:,6)==1);
    [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([iis(valid,:),data(valid,[1,3,4])]),zscore(learning(valid)),comp, 'CV', 5);
    PCTVAR_su1(i)=sum(PCTVAR(1,:));
    PCTVAR_su2(i)=sum(PCTVAR(2,:));
end
prctile(PCTVAR_su1,95)
prctile(PCTVAR_su2,95)

plotk(comp,2)=prctile(PCTVAR_su2,95);
comp
end
plot(plotk)





%% 



valid=intersect(find(isnan(data2(:,4))==0),find(data(:,5)==1));
[XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(zscore([ii(valid,:),data(valid,[1,3,4])]),[zscore(learning(valid)),y(valid,:)],comp);

%% 



valid=find(isnan(data2(:,4))==0);
valid=intersect(find(isnan(data2(:,4))==0),find(data(:,5)==1));
[XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(data2(valid,[4,8,21,39]), ai(valid,:))
% real_PCTVAR=PCTVAR(2,1)

PCTVAR_su=zeros(1000,1);
for i=1:1000
    data2s=data2_surr{i};
    ais=ai_surr{i};
    valid=find(isnan(data2(:,4))==0);
    % valid=intersect(find(isnan(data2s(:,4))==0),find(data(:,5)==1));
    [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(data2s(valid,[4,8,21,39]), ais(valid,:));
    PCTVAR_su(i)=PCTVAR(2,1);
    i
end
prctile(PCTVAR_su,95)


% valid=find(isnan(data2(:,4))==0);
valid=intersect(find(isnan(data2(:,4))==0),find(data(:,5)==1));
[XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(data2(valid,[4,8,21,39]), learning(valid))
real_PCTVAR=PCTVAR(2,1)

PCTVAR_su=zeros(1000,1);
for i=1:1000
    data2s=data2_surr{i};
    ais=ai_surr{i};
    valid=intersect(find(isnan(data2s(:,4))==0),find(data(:,5)==1));
    [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(data2s(valid,[4,8,21,39]), learning(valid));
    PCTVAR_su(i)=PCTVAR(2,1);
    i
end
prctile(PCTVAR_su,95)
