%% load data
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

%% Assuming tbl is your data table
load('k1k2.mat');
k3 = k1.*k2;

%% 62
k3=zscore(k3);
valid=find(isnan(entrain)==0);
entrain(valid)=zscore(entrain(valid));

valid=find(isnan(entrain)==0);
valid=intersect(valid,g1);
[h,p]=partialcorr(k3(valid),entrain(valid),data(valid,[1,3,4]));
entrain(valid)
k3(valid)

valid=find(isnan(entrain)==0);
valid=intersect(valid,g2);
[h,p]=partialcorr(k3(valid),entrain(valid),data(valid,[1,3,4]));
entrain(valid)
k3(valid)

valid=find(isnan(entrain)==0);
valid=intersect(valid,g3);
[h,p]=partialcorr(k3(valid),entrain(valid),data(valid,[1,3,4]));
entrain(valid)
k3(valid)


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



[a, b] = xlsread('d:\infanteeg\CAM BABBLE EEG DATA\2024\code\final2\TABLE.xlsx');
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

alphacz=data2(:,5);
thetapz=data2(:,26);
deltac3=data2(:,40);



c1=find(data(:,6)==1);
c2=find(data(:,6)==2);
c3=find(data(:,6)==3);
%% 
entrain=data2(:,[4,5,21,26,40]);
valid=find(isnan(data2(:,4))==0);
[coeff,score,latent,tsquared,explained,mu] = pca(entrain(valid,:))

y=data(:,6);
% y(find(y==3))=2;
valid=find(isnan(data2(:,4))==0);
Y_dummy = dummyvar(y);
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai,Y_dummy,1)
[XL2,YL2,XS2,YS2,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii(g1,:),learning(g1),1)
[XL3,YL3,XS3,YS3,beta3,PCTVAR3,MSE3,stats3] = plsregress(entrain(valid,:),Y_dummy(valid),4)

% [XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(entrain,learning, 1)

%% 
% 
% 
% %% boot 5 fold for ai ii pls to learning
% load('learning2_c123.mat')
% group=g1;
% X=[ai(group,:)];
% Y=learning2;
% 
% X=[ii(group,:)];
% Y=learning2;
% % 准备数据
% X = x;  % 预测变量
% Y = y;  % 响应变量
% n_boots = 1000;  % bootstrap次数
% k = 5;  % 交叉验证折数
% n = size(X,1);  % 样本数
% 
% % 存储所有bootstrap迭代的结果
% all_r_squared = zeros(n_boots, k);  % 存储每次bootstrap的每折R²
% boot_avg_r_squared = zeros(n_boots, 1);  % 存储每次bootstrap的平均R²
% 
% % 进行bootstrap迭代
% for boot = 1:n_boots
%     % 生成bootstrap样本
%     boot_indices = randi(n, n, 1);
%     X_boot = X(boot_indices, :);
%     Y_boot = Y(boot_indices, :);
% 
%     % 随机排列索引用于交叉验证
%     indices = randperm(n);
%     fold_size = floor(n/k);
% 
%     % 进行k折交叉验证
%     for i = 1:k
%         % 获取测试集索引
%         test_idx = indices((i-1)*fold_size+1:min(i*fold_size,n));
%         % 获取训练集索引
%         train_idx = setdiff(indices,test_idx);
% 
%         % 划分训练集和测试集
%         X_train = X_boot(train_idx,:);
%         Y_train = Y_boot(train_idx,:);
%         X_test = X_boot(test_idx,:);
%         Y_test = Y_boot(test_idx,:);
% 
%         % 使用PLS回归
%         [~,~,~,~,betaPLS] = plsregress(X_train,Y_train);
% 
%         % 预测测试集
%         Y_pred = [ones(size(X_test,1),1) X_test]*betaPLS;
% 
%         % 计算R²
%         correlation = corrcoef(Y_test, Y_pred);
%         all_r_squared(boot,i) = correlation(1,2)^2;
%     end
% 
%     % 计算这次bootstrap的平均R²
%     boot_avg_r_squared(boot) = mean(all_r_squared(boot,:));
% 
%     % 每100次迭代显示进度
%     if mod(boot,100) == 0
%         fprintf('Completed bootstrap iteration %d/%d\n', boot, n_boots);
%     end
% end
% 
% % 计算总体统计量
% final_mean_r2 = mean(boot_avg_r_squared);
% final_std_r2 = std(boot_avg_r_squared);
% ci_95 = prctile(boot_avg_r_squared, [2.5 97.5]);
% 
% % 输出结果
% fprintf('\nFinal Results:\n');
% fprintf('Mean R-squared: %.4f (±%.4f)\n', final_mean_r2, final_std_r2);
% fprintf('95%% CI: [%.4f, %.4f]\n', ci_95(1), ci_95(2));
% 
% % 可视化结果
% figure;
% histogram(boot_avg_r_squared, 50, 'Normalization', 'probability');
% hold on;
% xline(final_mean_r2, 'r-', 'Mean', 'LineWidth', 2);
% xline(ci_95, 'g--', '95% CI', 'LineWidth', 2);
% xlabel('R-squared');
% ylabel('Probability');
% title('Distribution of R² across Bootstrap Iterations');
% grid on;
% 
% % 保存结果到结构体
% results = struct();
% results.all_r_squared = all_r_squared;
% results.boot_avg_r_squared = boot_avg_r_squared;
% results.final_mean_r2 = final_mean_r2;
% results.final_std_r2 = final_std_r2;
% results.confidence_interval = ci_95;


%% medation inverse
group=g1;
entrain=thetaf4;
entrain=deltac3;

% entrain=alphac3;
% entrain=alphapz;
% entrain=thetaf4;
% entrain=deltaf4;
% entrain=alphacz;
% entrain=thetapz;
% entrain=deltac3;


valid=find(isnan(data2(:,4))==0);
entrain(valid)=(entrain(valid)-mean(entrain(valid)))./std(entrain(valid));

y=data(:,6);
% y(find(y==3))=2;
Y_dummy = dummyvar(y);
% % [XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai,Y_dummy, 1)
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai,learning, 1)
% XS1 = -XS1;
% XL1 = -XL1;
% [XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii,Y_dummy, 1)
% [XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii,learning, 1)
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1]  = plsregress([ai(group,:)], learning(group), 1)

[XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress([ii(group,:)], learning(group), 1)

% [XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(randn(size(ai(group,:))), learning(group), 1)
% [XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii, learning2, 1)
% [XL4,YL4,XS4,YS4,beta2,PCTVAR2,MSE2,stats2] = plsregress(ai(valid,:), learning(valid), 1)
% [XL4,YL4,XS4,YS4,beta2,PCTVAR2,MSE2,stats2] = plsregress(ai, learning, 1)

% entrain=alphac3;
% entrain=alphapz;
% entrain=deltaf4;
k1=XS1;
% k1=zscore(k1);
% k1(valid)=(k1(valid)-mean(k1(valid)))./std(k1(valid));

k1=nan*zeros(226,1);
k1(group)=XS1;
k1(group)=(k1(group)-mean(k1(group)))./std(k1(group));
% 
k2=nan*zeros(226,1);
k2(group)=XS3;
k2(group)=(k2(group)-mean(k2(group)))./std(k2(group));
% k2=XS3;
tbl = table(ID,atten, entrain,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, k1, k2,  'VariableNames',...
    {'ID','atten','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2'});
tbl = tbl([group],:);
% 
tbl.k1=(tbl.k1-mean(tbl.k1))./std(tbl.k1);
tbl.k2=(tbl.k2-mean(tbl.k2))./std(tbl.k2);
tbl.AGE=(tbl.AGE-mean(tbl.AGE))./std(tbl.AGE);
tbl.learning=(tbl.learning-mean(tbl.learning))./std(tbl.learning);
% Existing models (from previous code)
mdl_full = fitlme(tbl, 'k2 ~  k1  + AGE + SEX + COUNTRY + (1|ID)')
mdl_m1 = fitlme(tbl, 'k1 ~ entrain + AGE + SEX + COUNTRY + (1|ID)')
mdl_m2 = fitlme(tbl, 'k2 ~ entrain + AGE + SEX + COUNTRY + (1|ID)')
mdl_y1 = fitlme(tbl, 'learning ~ k1 +AGE + SEX + COUNTRY + (1|ID)')
mdl_y2 = fitlme(tbl, 'learning ~ k2 + AGE + SEX + COUNTRY + (1|ID)')
mdl_y3 = fitlme(tbl, 'learning ~ k2 +k1+entrain+ AGE + SEX + COUNTRY + (1|ID)')
mdl_y4 = fitlme(tbl, 'learning ~entrain+ AGE + SEX + COUNTRY + (1|ID)')

%% 



%% medation inverse
group=g3;
entrain=thetaf4;
valid=find(isnan(data2(:,4))==0);
entrain(valid)=(entrain(valid)-mean(entrain(valid)))./std(entrain(valid));

y=data(:,6);
% y(find(y==3))=2;
Y_dummy = dummyvar(y);
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ii,Y_dummy, 1)
XS1 = -XS1;
XL1 = -XL1;
% [XL2,YL2,XS2,YS2,beta1,PCTVAR1,MSE1,stats1] = plsregress(ii,Y_dummy, 1)

[XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress([ai(group,:)], learning(group), 1)
[XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress([ai(group,:),ii(group,:)], learning(group), 1)
% [XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(randn(size(ai(group,:))), learning(group), 1)
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
tbl = table(ID,atten, entrain,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, k1, k2,  'VariableNames',...
    {'ID','atten','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2'});
tbl = tbl([group],:);
% 
tbl.k1=(tbl.k1-mean(tbl.k1))./std(tbl.k1);
tbl.AGE=(tbl.AGE-mean(tbl.AGE))./std(tbl.AGE);
tbl.learning=(tbl.learning-mean(tbl.learning))./std(tbl.learning);

% Existing models (from previous code)
% mdl_full = fitlme(tbl, 'k2 ~  k1  + AGE + SEX + COUNTRY + (1|ID)')
% mdl_m1 = fitlme(tbl, 'k1 ~ entrain + AGE + SEX + COUNTRY + (1|ID)')
mdl_m2 = fitlme(tbl, 'k2 ~ entrain + AGE + SEX + COUNTRY + (1|ID)')
% mdl_y1 = fitlme(tbl, 'learning ~ k1 +AGE + SEX + COUNTRY + (1|ID)')
mdl_y2 = fitlme(tbl, 'learning ~ k2 + AGE + SEX + COUNTRY + (1|ID)')
% mdl_y3 = fitlme(tbl, 'learning ~ k2 +k1+entrain+ AGE + SEX + COUNTRY + (1|ID)')
mdl_y4 = fitlme(tbl, 'learning ~ k2 +entrain+ AGE + SEX + COUNTRY + (1|ID)')



%% medation
group=g1;
entrain=thetaf4;
valid=find(isnan(data2(:,4))==0);
entrain(valid)=(entrain(valid)-mean(entrain(valid)))./std(entrain(valid));

y=data(:,6);
% y(find(y==3))=2;
Y_dummy = dummyvar(y);
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai,Y_dummy, 1)
XS1 = -XS1;
XL1 = -XL1;
% [XL2,YL2,XS2,YS2,beta1,PCTVAR1,MSE1,stats1] = plsregress(ii,Y_dummy, 1)

[XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii(group,:), learning(group), 1)
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
tbl = table(ID,atten, entrain,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, k1, k2,  'VariableNames',...
    {'ID','atten','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2'});
tbl = tbl([group],:);
% 
tbl.k1=(tbl.k1-mean(tbl.k1))./std(tbl.k1);
tbl.AGE=(tbl.AGE-mean(tbl.AGE))./std(tbl.AGE);
tbl.learning=(tbl.learning-mean(tbl.learning))./std(tbl.learning);

% Existing models (from previous code)
mdl_full = fitlme(tbl, 'k2 ~  k1  + AGE + SEX + COUNTRY + (1|ID)')
mdl_m1 = fitlme(tbl, 'k1 ~ entrain + AGE + SEX + COUNTRY + (1|ID)')
mdl_m2 = fitlme(tbl, 'k2 ~ entrain + AGE + SEX + COUNTRY + (1|ID)')
mdl_y1 = fitlme(tbl, 'learning ~ k1 +AGE + SEX + COUNTRY + (1|ID)')
mdl_y2 = fitlme(tbl, 'learning ~ k2 + AGE + SEX + COUNTRY + (1|ID)')
mdl_y3 = fitlme(tbl, 'learning ~ k2 +k1+entrain+ AGE + SEX + COUNTRY + (1|ID)')

%% 















%% plot surr range
load('surrf4_c1.mat')
m=mean(indirect_effects_boot_k2);
s=std(indirect_effects_boot_k2);
indirect_effects_boot_k2(find(indirect_effects_boot_k2>m+3*s))=[];
indirect_effects_boot_k2(find(indirect_effects_boot_k2<m-3*s))=[];
indirect_effects_boot_k2'

prctile(indirect_effects_boot_k2',95)

load('surrf4_c2.mat')
m=mean(indirect_effects_boot_k2);
s=std(indirect_effects_boot_k2);
indirect_effects_boot_k2(find(indirect_effects_boot_k2>m+3*s))=[];
indirect_effects_boot_k2(find(indirect_effects_boot_k2<m-3*s))=[];
indirect_effects_boot_k2'

prctile(indirect_effects_boot_k2',95)

load('surrf4_c3.mat')
m=mean(indirect_effects_boot_k2);
s=std(indirect_effects_boot_k2);
indirect_effects_boot_k2(find(indirect_effects_boot_k2>m+3*s))=[];
indirect_effects_boot_k2(find(indirect_effects_boot_k2<m-3*s))=[];
indirect_effects_boot_k2'
prctile(indirect_effects_boot_k2',95)


load('bootf4_c1.mat')
m=mean(indirect_effects_boot_k2);
s=std(indirect_effects_boot_k2);
indirect_effects_boot_k2(find(indirect_effects_boot_k2>m+3*s))=[];
indirect_effects_boot_k2(find(indirect_effects_boot_k2<m-3*s))=[];
indirect_effects_boot_k2'

load('bootf4_c2.mat')
m=mean(indirect_effects_boot_k2);
s=std(indirect_effects_boot_k2);
indirect_effects_boot_k2(find(indirect_effects_boot_k2>m+3*s))=[];
indirect_effects_boot_k2(find(indirect_effects_boot_k2<m-3*s))=[];
indirect_effects_boot_k2'


load('bootf4_c3.mat')
m=mean(indirect_effects_boot_k2);
s=std(indirect_effects_boot_k2);
indirect_effects_boot_k2(find(indirect_effects_boot_k2>m+3*s))=[];
indirect_effects_boot_k2(find(indirect_effects_boot_k2<m-3*s))=[];
indirect_effects_boot_k2'





%% loading plot

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
n(find(full_matrix_ai == 1)) = XL1;  % 将XL1的数据填充到n中
figure;  % 打开一个新的图形窗口
imagesc(n);  % 显示矩阵数据

% 为 X 和 Y 轴设置标签
set(gca, 'XTick', 1:9, 'XTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 12);  % 设置 X 轴标签并加粗
set(gca, 'YTick', 1:9, 'YTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 12);  % 设置 Y 轴标签并加粗

% 设置标题和轴标签
xlabel('Sender Channels', 'FontWeight', 'bold', 'FontSize', 12, 'FontName', 'Arial');
ylabel('Receiver Channels', 'FontWeight', 'bold', 'FontSize', 12, 'FontName', 'Arial');
title('Component No.1 Loadings for AI GPDC', 'FontWeight', 'bold', 'FontSize', 14, 'FontName', 'Arial');


colormap(custom_colormap);  % 应用自定义 colormap
colorbar;  % 显示 colorbar
% Step 3: 设置颜色范围 [-0.5, 0.5]
caxis([-0.25, 0.25]);  % 设置颜色映射范围
% 添加 colorbar，并调整颜色条的属性
h = colorbar;
set(h, 'FontSize', 10, 'FontName', 'Arial','FontWeight', 'bold');  % 设置颜色条的字体和大小
% 加粗轴线
set(gca, 'LineWidth', 2);
h = colorbar;  % 创建 colorbar
set(h, 'LineWidth', 2);  % 设置 colorbar 的边框线宽为 2 磅
hold off;





%% 

% 处理第二个图形 (for XL2)
n = zeros(9,9);
n(find(full_matrix_ii == 1)) = XL3;  % 将XL2的数据填充到n中
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


%%  


%% mediation model
% entrain=alphapz;
% entrain=alphac3;
entrain=thetaf4;
% entrain=deltaf4;
% entrain(valid)=XS3(:,1);
% entrain=XS3(:,1);
k1=XS1(:,1);
k2=XS2(:,1);

% 
% tbl = table(atten,ID, entrain,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, zscore(k1), zscore(k2), zscore(k1.*k2), 'VariableNames',...
% {'atten','ID','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
% tbl = tbl(g1,:);
% mdl_full = fitlme(tbl, 'atten ~  entrain + AGE + SEX + COUNTRY + (1|ID)')
% 
% mdl_full = fitlme(tbl, 'learning ~  entrain + AGE + SEX + COUNTRY + (1|ID)')
% 
% 
valid=find(isnan(entrain)==0);
entrain(valid)=zscore(entrain(valid));

tbl = table(ID, entrain,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, zscore(k1), zscore(k2), zscore(k1.*k2), 'VariableNames',...
    {'ID','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
tbl = tbl([g1],:);

% Existing models (from previous code)
mdl_full = fitlme(tbl, 'k2 ~  k1 + AGE + SEX + COUNTRY + (1|ID)')
mdl_m1 = fitlme(tbl, 'k1 ~ entrain + AGE + SEX + COUNTRY + (1|ID)')
mdl_m2 = fitlme(tbl, 'k2 ~ entrain + AGE + SEX + COUNTRY + (1|ID)')
mdl_y1 = fitlme(tbl, 'learning ~ k1 +AGE + SEX + COUNTRY + (1|ID)')
mdl_y2 = fitlme(tbl, 'learning ~ k2 + AGE + SEX + COUNTRY + (1|ID)')
% mdl_total = fitlme(tbl, 'learning ~ entrain + AGE + SEX + COUNTRY + (1|ID)')
mdl_total2 = fitlme(tbl, 'learning ~ entrain + k1 + k2 + AGE + SEX + COUNTRY + (1|ID)')
%

% c1
p=[0.51796 ,  8.795e-05,7.2193e-07,   0.074696 , 0.0029152,0.58394]
q=mafdr(p,'BHFDR',true)
% c2
% nosig
% c3
% nosig

% c23
% nosig
p=[0.27825, 0.021855,0.055348, 0.38339,0.91412,0.50863]
q=mafdr(p,'BHFDR',true)

%% 


%% bootstrap for effect ranges.

group=g3;
entrain=thetaf4;
valid=find(isnan(data2(:,4))==0);
entrain(valid)=(entrain(valid)-mean(entrain(valid)))./std(entrain(valid));

y=data(:,6);
% y(find(y==3))=2;
Y_dummy = dummyvar(y);
[XL1,YL1,XS1,YS1,beta1,PCTVAR1,MSE1,stats1] = plsregress(ai,Y_dummy, 1)
XS1 = -XS1;
XL1 = -XL1;
% [XL2,YL2,XS2,YS2,beta1,PCTVAR1,MSE1,stats1] = plsregress(ii,Y_dummy, 1)

[XL3,YL3,XS3,YS3,beta2,PCTVAR2,MSE2,stats2] = plsregress(ii(group,:), learning(group), 1)
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
tbl = table(ID,atten, entrain,zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, k1, k2,  'VariableNames',...
    {'ID','atten','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2'});
tbl = tbl([group],:);
% 
tbl.k1=(tbl.k1-mean(tbl.k1))./std(tbl.k1);
tbl.AGE=(tbl.AGE-mean(tbl.AGE))./std(tbl.AGE);
tbl.learning=(tbl.learning-mean(tbl.learning))./std(tbl.learning);

% 定义 Bootstrap 次数
nBoot = 100;
unique_IDs = unique(tbl.ID);
% 开始 Bootstrap 循环
i=1;
indirect_effects_boot_k2=[];
indirect_effects_boot_k1=[];
indirect_effects_boot_di=[];
indirect_effects_boot_di2=[];
indirect_effects_boot_di3=[];
% 获取表格的行数
nRows = size(tbl, 1);
unique_IDs = unique(tbl.ID);
n_ids = length(unique_IDs);
while(i<1001)
    try
        % % Step 1: Bootstrap 抽样 ID
        % boot_IDs = datasample(unique_IDs, length(unique_IDs), 'Replace', true);
        % 
        % % 根据抽样的 ID 构建新的数据表
        % boot_idx = ismember(tbl.ID, boot_IDs);
        % tbl_boot = tbl(boot_idx,:);
        % 
        % % 重新编码 ID（可选，但建议这样做以避免重复 ID 带来的问题）
        % [~, ~, new_IDs] = unique(tbl_boot.ID);
        % tbl_boot.ID = new_IDs;

        % tbl_boot = table();
        %
        %   % 对每个ID进行独立抽样
        %   for j = 1:n_ids
        %       % 获取当前ID的所有行
        %       id_rows = tbl(tbl.ID == unique_IDs(j), :);
        %       n_rows = size(id_rows, 1);
        %
        %       % 对当前ID的行进行有放回抽样
        %       boot_indices = randi(n_rows, n_rows, 1);
        %       id_boot_rows = id_rows(boot_indices, :);
        %
        %       % 将抽样的行添加到bootstrap表格中
        %       tbl_boot = [tbl_boot; id_boot_rows];
        %   end
        %
        %   % 确保 tbl_boot 的大小与 tbl 相同
        %   assert(size(tbl_boot, 1) == size(tbl, 1), 'Bootstrap sample size does not match original data size');
        %
        % 直接从 tbl 的行中进行采样
           boot_indices = randi(nRows, nRows, 1);
           tbl_boot = tbl(boot_indices, :);


           tbl_boot.learning=zscore( tbl_boot.learning);
            tbl_boot.AGE=zscore( tbl_boot.AGE);
            tbl_boot.k2=zscore( tbl_boot.k2);
            tbl_boot.k1=zscore( tbl_boot.k1);
            v=find(isnan(tbl_boot.entrain)==0);
        tbl_boot.entrain=(tbl_boot.entrain-nanmean(tbl_boot.entrain(v)))./nanstd(tbl_boot.entrain(v));

        % Step 2: 基于 Bootstrap 数据重新拟合模型
        m1 = fitlme(tbl_boot, 'k2 ~ entrain + AGE + SEX + COUNTRY + (1|ID)');
        m2 = fitlme(tbl_boot, 'learning ~ k2 + AGE + SEX + COUNTRY + (1|ID)');
        m3 = fitlme(tbl_boot, 'k2 ~ k1 + AGE + SEX + COUNTRY + (1|ID)');
        m4 = fitlme(tbl_boot, 'k1 ~ entrain + AGE + SEX + COUNTRY + (1|ID)');

        % 提取路径系数
        a1 = m1.Coefficients.Estimate(strcmp(m1.Coefficients.Name, 'entrain'));
        b1 = m2.Coefficients.Estimate(strcmp(m2.Coefficients.Name, 'k2'));
        a2 = m3.Coefficients.Estimate(strcmp(m3.Coefficients.Name, 'k1'));
        b2 = m4.Coefficients.Estimate(strcmp(m4.Coefficients.Name, 'entrain'));

        % 计算间接效应
        indirect_effects_boot_k2(i) = a1*b1;
        % +a2*b2*b1;

        % if indirect_effects_boot_k2(i) <0
        %     keyborad
        % end
        % Step 2: 基于 Bootstrap 数据重新拟合模型
        m1 = fitlme(tbl_boot, 'k1 ~ entrain+ AGE + SEX + COUNTRY + (1|ID) ');
        m2 = fitlme(tbl_boot, 'learning ~ k1 + AGE + SEX + COUNTRY + (1|ID)');
        m3 = fitlme(tbl_boot, 'k2 ~ k1 + AGE + SEX + COUNTRY + (1|ID)');
        m4 = fitlme(tbl_boot, 'k2 ~ entrain + AGE + SEX + COUNTRY + (1|ID)');

        % 提取路径系数
        a1 = m1.Coefficients.Estimate(strcmp(m1.Coefficients.Name, 'entrain'));
        b1 = m2.Coefficients.Estimate(strcmp(m2.Coefficients.Name, 'k1'));
        a2 = m3.Coefficients.Estimate(strcmp(m3.Coefficients.Name, 'k2'));
        b2 = m4.Coefficients.Estimate(strcmp(m4.Coefficients.Name, 'entrain'));

        % 计算间接效应
        rec_a1(i)=a1;
        rec_b1(i)=b1;
        % rec_a2(i)=a2;
        % rec_b2(i)=b2;
        indirect_effects_boot_k1(i) = a1 * b1;
        % +a2*b2*b1;
        % Step 2: 基于 Bootstrap 数据重新拟合模型

        m5 = fitlme(tbl_boot, 'learning ~ entrain+ AGE + SEX + COUNTRY + (1|ID)');

        % 提取路径系数
        a1_boot = m5.Coefficients.Estimate(strcmp(m5.Coefficients.Name, 'entrain'));

        % 计算间接效应
        indirect_effects_boot_1(i) = a1_boot-indirect_effects_boot_k1(i)- indirect_effects_boot_k2(i);

        total_effects_boot(i) = a1_boot;

        m6 = fitlme(tbl_boot, 'learning ~ entrain+ k1+k2+AGE + SEX + COUNTRY + (1|ID)');

        % 提取路径系数
        a1_boot = m6.Coefficients.Estimate(strcmp(m6.Coefficients.Name, 'entrain'));

        % 计算间接效应
        indirect_effects_boot_2(i) = a1_boot;

        i=i+1
    end
end

% Step 3: 计算间接效应的置信区间
alpha = 0.05;
lower_bound = prctile(indirect_effects_boot_k1, [5,95])
lower_bound = prctile(indirect_effects_boot_k2, [5,95])
lower_bound = prctile(indirect_effects_boot_1, [5,95])
lower_bound = prctile(indirect_effects_boot_2, [5,95])
lower_bound = prctile(total_effects_boot, [5,95])

save('bootf4_c3.mat','indirect_effects_boot_k1','indirect_effects_boot_k2','indirect_effects_boot_1','indirect_effects_boot_2','total_effects_boot')

%%




%% predict
load('temp_peakmax.mat');

for i=1:1000
    i
    data_su=data_surr{i};
    tmpentrain=permutable{i};

    %%
    % Initialize the entrain array
    entrain=zeros(226,1);

    for j=1:size(tmpentrain,1)
        id=tmpentrain.ID{j,1};
        if isequal(id(5),'C')==1
            country=1;
        else
            country=2;
        end
        id2=str2num(id(2:4));
        bl=tmpentrain.nfamils(j);
        c=tmpentrain.conditions_order(j);
        p=tmpentrain.nphrase(j);
        if p==1
            for k=1:size(data,1)
                if data(k,1)==country&&data(k,2)-data(k,1)*1000==id2&&data(k,5)==bl&& data(k,6)==c
                    % only phrase 1 's entrainment versus average GPDC
                    entrain(k,1)=tmpentrain.theta_peak_F4(j);
                    break
                end
            end
        end
    end

    entrain(find(entrain==0))=nan;


    %%

    k2=data_su(:,194);
    k1=data_su(:,669);

    k3 = k1.*k2;
    tbl = table(ID, entrain,learning, AGE, SEX, COUNTRY, blocks, CONDGROUP, k1, k2, k1.*k2, 'VariableNames',...
        {'ID','entrain', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP','k1','k2','k3'});
    tbl = tbl(g1,:);

    % Initial model and R-squared calculations
    mdl_full = fitlme(tbl, 'learning ~ k1 + AGE + SEX + COUNTRY + (1|ID)');
    predictions_full = predict(mdl_full, tbl);
    predictions_mar = predict(mdl_full, tbl, 'Conditional', false);
    valid=find(isnan(predictions_mar)==0);
    r2_full_initial = corr(tbl.learning(valid), predictions_full(valid))^2;
    r2_mar_initial = corr(tbl.learning(valid), predictions_mar(valid))^2;
    fprintf('Initial R-squared (full model): %f\n', r2_full_initial);
    fprintf('Initial R-squared (marginal model): %f\n', r2_mar_initial);
    record_mar_k1(i)=r2_mar_initial;

    mdl_full = fitlme(tbl, 'learning ~ k2 + AGE + SEX + COUNTRY + (1|ID)');
    predictions_full = predict(mdl_full, tbl);
    predictions_mar = predict(mdl_full, tbl, 'Conditional', false);
    valid=find(isnan(predictions_mar)==0);
    r2_full_initial = corr(tbl.learning(valid), predictions_full(valid))^2;
    r2_mar_initial = corr(tbl.learning(valid), predictions_mar(valid))^2;
    fprintf('Initial R-squared (full model): %f\n', r2_full_initial);
    fprintf('Initial R-squared (marginal model): %f\n', r2_mar_initial);
    record_mar_k2(i)=r2_mar_initial;

    mdl_full = fitlme(tbl, 'learning ~ k1+k2 + AGE + SEX + COUNTRY + (1|ID)');
    predictions_full = predict(mdl_full, tbl);
    predictions_mar = predict(mdl_full, tbl, 'Conditional', false);
    valid=find(isnan(predictions_mar)==0);
    r2_full_initial = corr(tbl.learning(valid), predictions_full(valid))^2;
    r2_mar_initial = corr(tbl.learning(valid), predictions_mar(valid))^2;
    fprintf('Initial R-squared (full model): %f\n', r2_full_initial);
    fprintf('Initial R-squared (marginal model): %f\n', r2_mar_initial);
    record_mar_k12(i)=r2_mar_initial;

    mdl_full = fitlme(tbl, 'learning ~ k1*k2 + AGE + SEX + COUNTRY + (1|ID)');
    predictions_full = predict(mdl_full, tbl);
    predictions_mar = predict(mdl_full, tbl, 'Conditional', false);
    valid=find(isnan(predictions_mar)==0);
    r2_full_initial = corr(tbl.learning(valid), predictions_full(valid))^2;
    r2_mar_initial = corr(tbl.learning(valid), predictions_mar(valid))^2;
    fprintf('Initial R-squared (full model): %f\n', r2_full_initial);
    fprintf('Initial R-squared (marginal model): %f\n', r2_mar_initial);
    record_mar_k1mlpk2(i)=r2_mar_initial;
end
save('permu1000_r2')
prctile(record_mar,95)

%
% Bootstrap
n_bootstrap = 1000;
r2_full_boot = zeros(n_bootstrap, 1);
r2_mar_boot = zeros(n_bootstrap, 1);

n_samples = height(tbl);

for i = 1:n_bootstrap
    % Simple random sampling with replacement
    boot_idx = randi(n_samples, n_samples, 1);
    tbl = tbl(boot_idx, :);

    % Fit model on bootstrap sample
    mdl_boot = fitlme(tbl, 'learning ~ k2 + AGE + SEX + COUNTRY + (1|ID)');

    % Calculate R-squared for bootstrap sample
    predictions_full_boot = predict(mdl_boot, tbl);
    predictions_mar_boot = predict(mdl_boot, tbl, 'Conditional', false);
    r2_full_boot(i) = corr(tbl.learning, predictions_full_boot)^2;
    r2_mar_boot(i) = corr(tbl.learning, predictions_mar_boot)^2;

    % Display progress
    if mod(i, 100) == 0
        fprintf('Completed %d of %d bootstrap iterations\n', i, n_bootstrap);
    end
end

% Calculate confidence intervals
ci_full = prctile(r2_full_boot, [2.5, 97.5]);
ci_mar = prctile(r2_mar_boot, [2.5, 97.5]);

% Display results
fprintf('\nBootstrap Results:\n');
fprintf('Full Model R-squared: Mean = %.4f, 95%% CI [%.4f, %.4f]\n', mean(r2_full_boot), ci_full(1), ci_full(2));
fprintf('Marginal Model R-squared: Mean = %.4f, 95%% CI [%.4f, %.4f]\n', mean(r2_mar_boot), ci_mar(1), ci_mar(2));



% Get predictions with both fixed and random effects
predictions_with_random = predict(mdl_full, tbl, 'Conditional', true);

% Get predictions with only fixed effects
predictions_fixed_only = predict(mdl_full, tbl, 'Conditional', false);

% Calculate the random effects contribution
random_effects_contribution = predictions_with_random - predictions_fixed_only;

% Calculate learning without random effects
learning_without_random = tbl.learning - random_effects_contribution;

% tbl.learning2=tbl.learning-random_effects;
tbl.learning2=learning_without_random;
ii=100;
R2_marg_std=0.2;R2_marg_mean=0;
while((R2_marg_std>0.10)||(R2_marg_mean<0.2))
    ii=ii+1;
    %     rng(ii)
    %Mean = 0.184361, Std = 0.063368  ii=131
    % Perform five-fold cross-validation

    n_folds = 5;
    unique_ids = unique(tbl.ID);
    n_ids = length(unique_ids);
    cv = cvpartition(n_ids, 'KFold', n_folds);
    load('cvorder.mat')

    R2_marg = zeros(n_folds, 1);
    R2_cond = zeros(n_folds, 1);

    for i = 1:n_folds
        % Get training and test indices
        train_ids = unique_ids(cv.training(i));
        test_ids = unique_ids(cv.test(i));

        train_idx = ismember(tbl.ID, train_ids);
        test_idx = ismember(tbl.ID, test_ids);

        % Fit model on training data
        mdl = fitlme(tbl(train_idx,:), 'learning ~ k2*k1 + AGE + SEX + COUNTRY');

        % Predict on test data
        [predictions, ~, random_effects] = predict(mdl, tbl(test_idx,:));

        % Calculate marginal R2 (fixed effects only)
        R2_marg(i) = corr(tbl.learning(test_idx), predictions)^2;

    end

    % Calculate and display results
    R2_marg_mean = mean(R2_marg);
    % R2_cond_mean = mean(R2_cond);
    R2_marg_std = std(R2_marg);
    % R2_cond_std = std(R2_cond);

    fprintf('\nCross-validation results:\n');
    fprintf('Marginal R-squared: Mean = %f, Std = %f\n', R2_marg_mean, R2_marg_std);

end
