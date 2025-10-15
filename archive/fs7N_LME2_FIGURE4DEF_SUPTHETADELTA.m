clc
clear all
% load('data_read_surr5.mat','data')
load('data_read_surr_gpdc2.mat','data')

a=data;
g1=find(a(:,6)==1);
g2=find(a(:,6)==2);
g3=find(a(:,6)==3);
g4=find(a(:,6)<=2);
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
% listi=[ai1,ai2,ai3];
% listi=[ii1,ii2,ii3];
listi=[ii2];
data=sqrt(data(:,listi));
titles=titles(listi);
%% LME

load('stronglistfdr5_gpdc_IItheta.mat');
% stronglist=stronglistthetaalpha;
% stronglist=1:length(listi);
% load('stronglist0055.mat')
% stronglist=[112,119,128,137,148]
% stronglist=stronglist(1:33)
stronglist=s4;
% load('stronglist0053.mat');
tValueLearning=zeros(length(stronglist),1);
pValueLearning=ones(length(stronglist),1);
tValueAtten=zeros(length(stronglist),1);
pValueAtten=ones(length(stronglist),1);

for i = 1:length(stronglist)
    % i
    % titles{stronglist(i)}
    Y = data(:, stronglist(i)); % Set the dependent variable
    % threshould1 = mean(Y)+3*std(Y);
    % threshould2 = mean(Y)-3*std(Y);
    % label=union(find(Y>threshould1),find(Y<threshould2));
    % length(label)
    % Creating a table for fitlme with filtered data
    tbl = table(ID, zscore(learning),zscore(atten), zscore(AGE), SEX, COUNTRY, zscore(Y), blocks, CONDGROUP, 'VariableNames',...
        {'ID', 'learning','atten', 'AGE', 'SEX', 'COUNTRY', 'Y', 'block', 'CONDGROUP'});
    % tbl(label,:)=[];
    % tbl=tbl([g1],:);
    % Linear Mixed-Effects Model
    lme = fitlme(tbl, 'Y ~ AGE + SEX +CONDGROUP+COUNTRY  + (1|ID)');
    % lme = fitlme(tbl, 'learning ~ AGE + SEX +Y+COUNTRY +(1|ID)')
    % 修改后的模型，移除了 CONDGROUP 的主效应，但保留交互项
    % lme = fitlme(tbl, 'learning ~ AGE + SEX + Y * CONDGROUP + COUNTRY  + (1|ID)');
    coeffIdx = strcmp(lme.Coefficients.Name, 'CONDGROUP_2');
    tValueLearning(i) = lme.Coefficients.tStat(coeffIdx);
    pValueLearning(i) = lme.Coefficients.pValue(coeffIdx);
    % [h(i),p(i)]= partialcorr(data(:, stronglist(i)), learning(:), a(:, [1, 3, 4]));
end
pValueLearning(find(pValueLearning<0.05))
tValueLearning(find(pValueLearning<0.05))
q=mafdr(pValueLearning,'BHFDR',true)
titles(stronglist(find(pValueLearning<0.05)))'
titles(stronglist(find(q<0.05)))'
% q=0.0476;


%% T VALUE AND THRESHOULD
df = 221;  % Degrees of freedom
p = 0.05/length(s4);  % Bonferroni corrected p-value

% Calculate the t-value
t_value = tinv(1 - p/2, df);

% Display the result
fprintf('For df = %d and p = %f (Bonferroni corrected):\n', df, p);
fprintf('The two-tailed t-value is approximately %.6f\n', t_value);
(sort(-tValueLearning))'

%%%%%%%%%%%%%%%%%%%% figure4c %%%%%%%%%%%%%%%%%%%%
data(g1,12)
data(g2,12)
data(g3,12)
%%%%%%%%%%%%%%%%%%%% figure4c %%%%%%%%%%%%%%%%%%%%


%% 
  Y = data(:, 12); % Set the dependent variable
    % threshould1 = mean(Y)+3*std(Y);
    % threshould2 = mean(Y)-3*std(Y);
    % label=union(find(Y>threshould1),find(Y<threshould2));
    % length(label)
    % Creating a table for fitlme with filtered data
    tbl = table(ID, zscore(learning),zscore(atten), zscore(AGE), SEX, COUNTRY, zscore(Y), blocks, CONDGROUP, 'VariableNames',...
        {'ID', 'learning','atten', 'AGE', 'SEX', 'COUNTRY', 'Y', 'block', 'CONDGROUP'});
    % tbl(label,:)=[];
    % tbl=tbl([g1],:);
    % Linear Mixed-Effects Model
    lme = fitlme(tbl, 'Y ~ AGE + SEX +CONDGROUP+COUNTRY  + (1|ID)')







%% end here

for i = 1:length(stronglist)

    % i
    % titles{stronglist(i)}
    Y = data(:, stronglist(i));

load('k1k2.mat');
tbl = table(ID, zscore(learning), zscore(AGE), SEX, COUNTRY,  blocks, CONDGROUP,Y,k1, 'VariableNames',...
            {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY',  'block', 'CONDGROUP','Y','k1'});
% Fit the linear model with interaction term
lme = fitlme(tbl, 'k1 ~ AGE + SEX +CONDGROUP+COUNTRY+Y  + (1|ID)');

    coeffIdx = strcmp(lme.Coefficients.Name, 'CONDGROUP_2');

        t(i) = lme.Coefficients.tStat(coeffIdx);
    p(i) = lme.Coefficients.pValue(coeffIdx);
    % if ismember(i,[  10    11    12    14    48    67])==1
    %     lme
    % end
end
%     10    11    12    14    48    67
q=mafdr(p,'BHFDR',true)
find(q<0.05)

%% 
% k1 为AI_Fzf4 No.12
% k2 为II_F4CZ No.23
% Assuming you have data for k1, k2, and learning outcome
% Create a table with your data
load('k1k2.mat')
% 交换类别顺序
CONDGROUP = reordercats(CONDGROUP, {'2', '1'});
tbl = table(ID, zscore(learning), zscore(AGE), SEX, COUNTRY,  blocks, CONDGROUP,zscore(k1), zscore(k2), zscore(k1.*k2), 'VariableNames',...
            {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY',  'block', 'CONDGROUP','k1','k2','k3'});
% Fit the linear model with interaction term
mdl = fitlme(tbl, 'learning ~ k3*CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')

mdl = fitlme(tbl, ' k2~ CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')


k1=k1.*k2
tbl = table(ID, zscore(learning), zscore(AGE), SEX, COUNTRY,  blocks, CONDGROUP,zscore(k1), zscore(k2), 'VariableNames',...
            {'ID', 'learning', 'AGE', 'SEX', 'COUNTRY',  'block', 'CONDGROUP','k1','k2'});
mdl = fitlme(tbl, 'k1 ~ CONDGROUP+AGE+ SEX +COUNTRY  + (1|ID)')

% Get predicted values
predicted_learning = predict(mdl, tbl);

% Calculate correlation between predicted and actual learning
[r, p] = corrcoef(tbl.learning(g1), predicted_learning);
correlation = r(1,2);
p_value = p(1,2);

% Display correlation results
fprintf('Correlation between predicted and actual learning: %.4f\n', correlation);
fprintf('P-value: %.4f\n', p_value);


%% Leave-One-Out PLS
for i = 1:n
    i
    % 分离训练集和测试集
    x_train = x([1:i-1, i+1:end], :);
    y_train = y([1:i-1, i+1:end]);
    x_test = x(i, :);
        % 分割数据为训练集和验证集（例如，使用k折交叉验证）
        % 分割数据为训练集和验证集（例如，使用k折交叉验证）
%     k = 5; % 设定k折交叉验证中的k值
%     cv = cvpartition(size(x_train, 1), 'KFold', k);
% 
%     % 初始化误差存储变量
%     mseCV = zeros(min(size(x_train, 2), size(x_train, 1) - 1), 1);
% 
%     % 进行交叉验证以评估不同成分数的性能
%     for ii = 1:min(size(x_train, 2), size(x_train, 1) - 1)
%         mseFold = zeros(k, 1);
%         for j = 1:k
%             % 划分训练和验证集
%             xTrainFold = x_train(training(cv, j), :);
%             yTrainFold = y_train(training(cv, j), :);
%             xValFold = x_train(test(cv, j), :);
%             yValFold = y_train(test(cv, j), :);
% 
%             % 训练PLS模型
%             [~, ~, ~, ~, beta, ~, ~, ~] = plsregress(xTrainFold, yTrainFold, ii);
% 
%             % 使用PLS模型进行预测
%             yValPred = [ones(size(xValFold, 1), 1) xValFold] * beta;
% 
%             % 计算均方误差
%             mseFold(j) = mean((yValFold - yValPred).^2);
%         end
%          % 使用PLS模型进行预测
%         yValPred = [ones(size(xValFold, 1), 1) xValFold] * beta;
% 
%         % 计算R²
%         ssTotal = sum((yValFold - mean(yValFold)).^2);
%         ssResidual = sum((yValFold - yValPred).^2);
%         rSquaredFold(j) = 1 - ssResidual / ssTotal;
% 
%     % 计算当前成分数的平均R²
%     rSquaredCV(ii) = mean(rSquaredFold);
%     end
% 
%     % 找到具有最小均方误差的成分数
%     [~, optimalComponents] = max(rSquaredCV);
% %     
% %     % 输出最优成分数
%     fprintf('最优成分数为: %d\n', optimalComponents);

% % %     % 使用最优成分数训练最终模型
    [XL, YL, XS, YS, BETA, PCTVAR, MSE, stats] = plsregress(x_train, y_train, 1);

    
    % 使用模型进行预测
    y_pred(i,1) = [1, x_test] * BETA;
end

% 计算预测值和原始值的相关性
[correlation,p] = corr(y, y_pred);

% 输出相关性 0.35
disp(['Correlation between predicted and actual values: ', num2str(correlation)]);
 % 0.38592 NEW LEARNING



% 绘制散点图
figure;
hold on;

% 绘制 CONDGROUP = 1 的散点图
group1 = tbl(tbl.CONDGROUP == '1', :);
scatter(group1.Y, group1.learning, 'r', 'DisplayName', 'CONDGROUP = 1');

% 绘制 CONDGROUP = 2 的散点图
group2 = tbl(tbl.CONDGROUP == '2', :);
scatter(group2.Y, group2.learning, 'g', 'DisplayName', 'CONDGROUP = 2');

% 绘制 CONDGROUP = 3 的散点图
group3 = tbl(tbl.CONDGROUP == '3', :);
scatter(group3.Y, group3.learning, 'b', 'DisplayName', 'CONDGROUP = 3');


 % learning_list=[148];
% [H,P]=corr(XS(:,2),learning)
% [H,P]=corr(XS(:,1),atten)
% [H,P]=corr(XS(:,2),atten)




[coeff, score, latent, tsquared, explained]  = pca(zscore([data(:,learning_list)]))
tbl = table(ID, zscore(learning),zscore(atten), zscore(AGE), SEX, COUNTRY, zscore(score(:,1)), blocks, CONDGROUP, 'VariableNames',...
{'ID', 'learning','atten', 'AGE', 'SEX', 'COUNTRY', 'Y', 'block', 'CONDGROUP'});
 lme = fitlme(tbl, 'learning ~ AGE + SEX +Y+ COUNTRY  + (1|ID)')

% 
Y=data(:,23)
    tbl = table(ID, zscore(learning),zscore(atten), zscore(AGE), SEX, COUNTRY, zscore(Y), blocks, CONDGROUP, 'VariableNames',...
        {'ID', 'learning','atten', 'AGE', 'SEX', 'COUNTRY', 'Y', 'block', 'CONDGROUP'});

lme = fitlme(tbl, 'learning ~ AGE + SEX +Y*CONDGROUP+ COUNTRY  + (1|ID)')
predicted_y=predict(lme,tbl)
c=corr(predicted_y,learning)
fprintf('PCTVAR real: %.4f\n', c*c);
c=corr(predicted_y(g1),learning(g1))
fprintf('PCTVAR real: %.4f\n', c*c);
c=corr(predicted_y(g2),learning(g2))
fprintf('PCTVAR real: %.4f\n', c*c);
c=corr(predicted_y(g3),learning(g3))
fprintf('PCTVAR real: %.4f\n', c*c);

% 交叉验证参数
k = 5; % 5折交叉验证
indices = crossvalind('Kfold', Y, k); % 生成交叉验证的索引
load('crossindices_c123.mat')
% 初始化变量
PCTVAR_test = zeros(k, 1); % 用于存储每次折叠的PCTVAR
% 交叉验证循环
for i = 1:k
    % 划分训练集和测试集
    test_idx = (indices == i);
    train_idx = ~test_idx;
    
    % 训练集
    tbl_train = tbl(train_idx, :);
    
    % 测试集
    tbl_test = tbl(test_idx, :);
    
    % 训练LME模型
    lme_train = fitlme(tbl_train, 'learning ~ AGE + SEX + Y * CONDGROUP + COUNTRY + (1|ID)');
    
    % 使用训练的模型预测测试集
    predicted_y_test = predict(lme_train, tbl_test);
    
    % 计算测试集的PCTVAR
    y_test = tbl_test.learning;
    SST = sum((y_test - mean(y_test)).^2); % 总方差
    SSR = sum((predicted_y_test - mean(y_test)).^2); % 回归方差
    PCTVAR_test(i) = SSR / SST; % 计算PCTVAR
end
% 计算PCTVAR的均值、标准差、范围和置信区间
PCTVAR_mean = mean(PCTVAR_test);
PCTVAR_std = std(PCTVAR_test);
PCTVAR_range = [min(PCTVAR_test), max(PCTVAR_test)];
PCTVAR_2_5 = prctile(PCTVAR_test, 2.5);
PCTVAR_97_5 = prctile(PCTVAR_test, 97.5);

% 显示结果
fprintf('PCTVAR Mean: %.4f\n', PCTVAR_mean);
fprintf('PCTVAR Std: %.4f\n', PCTVAR_std);
fprintf('PCTVAR Range: [%.4f, %.4f]\n', PCTVAR_range(1), PCTVAR_range(2));
fprintf('PCTVAR 2.5th Percentile: %.4f\n', PCTVAR_2_5);
fprintf('PCTVAR 97.5th Percentile: %.4f\n', PCTVAR_97_5);



% load('crossindices_c123.mat')

% 交叉验证参数
k = 5; % 5折交叉验证

Y=data(:,23);
indices = crossvalind('Kfold', Y, k);
% 初始化变量
PCTVAR_test = zeros(k, 3); % 用于存储每次折叠的PCTVAR，3列对应三个条件
original_R2 = zeros(1, 3); % 用于存储原始R²

% 获取条件组的唯一值
condGroups = categories(tbl.CONDGROUP);
condGroupsNum = double(tbl.CONDGROUP);

% 计算原始R²
lme_orig = fitlme(tbl, 'learning ~ AGE + SEX + Y * CONDGROUP + COUNTRY + (1|ID)');
y_pred = predict(lme_orig);
y_actual = tbl.learning;

for cond = 1:3
    cond_idx = (condGroupsNum == cond);
    SST = sum((y_actual(cond_idx) - mean(y_actual(cond_idx))).^2);
    SSR = sum((y_pred(cond_idx) - mean(y_actual(cond_idx))).^2);
    original_R2(cond) = SSR / SST;
end

% 交叉验证循环
for i = 1:k
    % 划分训练集和测试集
    test_idx = (indices == i);
    train_idx = ~test_idx;
    
    % 训练集和测试集
    tbl_train = tbl(train_idx, :);
    tbl_test = tbl(test_idx, :);
    
    % 训练LME模型
    lme_train = fitlme(tbl_train, 'learning ~ AGE + SEX + Y * CONDGROUP + COUNTRY + (1|ID)');
    
    % 使用训练的模型预测测试集
    predicted_y_test = predict(lme_train, tbl_test);
    
    % 计算每个条件的测试集PCTVAR
    for cond = 1:3
        cond_idx = (double(tbl_test.CONDGROUP) == cond);
        y_test = tbl_test.learning(cond_idx);
        pred_test = predicted_y_test(cond_idx);
        PCTVAR_test(i, cond)=corr(pred_test,y_test).^2;
        % if ~isempty(y_test)
        %     SST = sum((y_test - mean(y_test)).^2); % 总方差
        %     SSR = sum((pred_test - mean(y_test)).^2); % 回归方差
        %     PCTVAR_test(i, cond) = SSR / SST; % 计算PCTVAR
        % else
        %     PCTVAR_test(i, cond) = NaN; % 如果该折叠中没有特定条件的数据，则设为NaN
        % end
    end
end

% 计算每个条件的PCTVAR统计量
for cond = 1:3
    valid_pctvar = PCTVAR_test(:, cond);
    valid_pctvar = valid_pctvar(~isnan(valid_pctvar));
    
    if ~isempty(valid_pctvar)
        PCTVAR_mean = mean(valid_pctvar);
        PCTVAR_std = std(valid_pctvar);
        PCTVAR_range = [min(valid_pctvar), max(valid_pctvar)];
        PCTVAR_2_5 = prctile(valid_pctvar, 2.5);
        PCTVAR_97_5 = prctile(valid_pctvar, 97.5);
        
        % 显示结果
        fprintf('\nCondition %s:\n', condGroups{cond});
        fprintf('Original R²: %.4f\n', original_R2(cond));
        fprintf('CV R² Mean: %.4f\n', PCTVAR_mean);
        fprintf('CV R² Std: %.4f\n', PCTVAR_std);
        fprintf('CV R² Range: [%.4f, %.4f]\n', PCTVAR_range(1), PCTVAR_range(2));
        fprintf('CV R² 2.5th Percentile: %.4f\n', PCTVAR_2_5);
        fprintf('CV R² 97.5th Percentile: %.4f\n', PCTVAR_97_5);
    else
        fprintf('\nCondition %s: Insufficient data for CV R² calculation\n', condGroups{cond});
    end
end


%% LOO 
n = height(tbl); % 样本总数
corr_values = zeros(n, 1); % 用于存储每次的相关性
predicted_learning_all = zeros(n, 1); % 用于存储所有预测值

% 开始留一法交叉验证
for i = 1:n
    % 划分训练集和测试集
    trainIdx = true(n, 1);
    trainIdx(i) = false; % 将第 i 个样本作为测试集，其余为训练集
    testIdx = ~trainIdx;
    
    % 创建训练集和测试集表格
    tbl_train = tbl(trainIdx, :);
    tbl_test = tbl(testIdx, :);
    
    % 拟合线性混合效应模型
    lme = fitlme(tbl_train, 'learning ~ AGE + SEX + Y*CONDGROUP + COUNTRY + (1|ID)');
    
    % 使用测试集进行预测
    predicted_learning = predict(lme, tbl_test);
    
    % 存储预测值
    predicted_learning_all(i) = predicted_learning;
    
    % 计算预测值和实际值之间的相关性
    % 在 LOOCV 中，只有一个测试样本，因此相关性无法直接计算
    % corr_values(i) = corr(predicted_learning, tbl_test.learning); % 这行在LOOCV中不适用
end

% 计算所有样本的预测值与实际值的相关性
overall_corr = corr(predicted_learning_all, tbl.learning);

% 输出留一法交叉验证的相关性
fprintf('留一法交叉验证的总体相关性: %.4f\n', overall_corr);



%  {'II_Alpha_F3_to_Fz'}
%     {'II_Alpha_C3_to_Cz'}
%     {'II_Alpha_F4_to_C4'}
%     {'II_Alpha_C3_to_C4'}
%     {'II_Alpha_C3_to_P3'}
%     {'II_Alpha_C3_to_Pz'}
%     {'AI_Alpha_C3_to_C3'}
%     {'AI_Alpha_Fz_to_Cz'}
%     {'AI_Alpha_Fz_to_C4'}
%     {'AI_Alpha_Fz_to_P3'}
%     {'AI_Alpha_C3_to_Pz'}
% stronglist
%  10
%     40
%     48
%     49
%     58
%     67
%    112
%    119
%    128
%    137
%    148
% 

Y=data(:,121)
   % Creating a table for fitlme with filtered data
    tbl = table(ID, learning,atten, AGE, SEX, COUNTRY, Y, blocks, CONDGROUP, 'VariableNames',...
        {'ID', 'learning','atten', 'AGE', 'SEX', 'COUNTRY', 'Y', 'block', 'CONDGROUP'});
    % tbl(g1,:)=[];
    % tbl=tbl([g2],:);
    % % Linear Mixed-Effects Model
    lme = fitlme(tbl, 'Y ~ AGE + SEX +CONDGROUP+COUNTRY  + (1|ID)')

k=26
[h,p]=ttest2(data(g3,k),data(g1,k))
[h,p]=ttest2(data(g2,k),data(g1,k))
[h,p]=ttest2(data(g3,k),data(g2,k))

mean(learning(g1))
mean(learning(g2))
mean(learning(g3))

save('data_read_LME.mat','tValueLearning','pValueLearning','tValueAtten','pValueAtten')


%% surrLME

load('data_read_surr3.mat')
load('stronglist.mat');


load('data_read_surr3.mat')

a=data;
g1=find(a(:,6)==1);
g2=find(a(:,6)==2);
g3=find(a(:,6)==3);
AGE=a(:,3);
SEX=a(:,4);
SEX=categorical(SEX);
COUNTRY=a(:,1);
COUNTRY=categorical(COUNTRY);
blocks=a(:,5);
blocks=categorical(blocks);
CONDGROUP=a(:,6);
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
                    connectionTitles{end+1} = sprintf('%s_%s_%s_to_%s', connectionTypes{conn}, frequencyBands{freq}, nodes{dest},nodes{src});
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
listi = [172:252,658:738];
% listi = [91:171,172:252,577:657,658:738];
data=data(:,listi);
titles=titles(listi);
stronglistlme=1:162
tValueLearning2=zeros(length(data_surr),length(stronglistlme));
pValueLearning2=zeros(length(data_surr),length(stronglistlme));
tValueAtten2=zeros(length(data_surr),length(stronglistlme));
pValueAtten2=zeros(length(data_surr),length(stronglistlme));


   for count=1:length(data_surr)
         data2=data_surr{count};
        data2=data2(:,listi);
        for i = 1:length(stronglistlme)

  [count,i]
      
        Y = data2(:, stronglistlme(i)); % Set the dependent variable

%         % Creating a table for fitlme with filtered data
        tbl = table(ID, learning,atten, AGE, SEX, COUNTRY, Y, blocks, CONDGROUP, 'VariableNames',...
            {'ID', 'learning','atten', 'AGE', 'SEX', 'COUNTRY', 'Y', 'block', 'CONDGROUP'});
%         % tbl=tbl([c1;c2],:);
%         % Linear Mixed-Effects Model
        lme = fitlme(tbl, 'learning ~ AGE + SEX +Y+COUNTRY  + (1|ID)');

        coeffIdx = strcmp(lme.Coefficients.Name, 'Y');
        tValueLearning2(count,i) = lme.Coefficients.tStat(coeffIdx);
        % dfLearning2(i-10) = lme.Coefficients.DF(coeffIdx);
        pValueLearning2(count,i) = lme.Coefficients.pValue(coeffIdx);

% % 
%         lme = fitlme(tbl, 'atten ~ AGE + SEX +Y+ COUNTRY  + (1|ID)');
% 
%         coeffIdx = strcmp(lme.Coefficients.Name, 'Y');
%         tValueAtten2(count,i) = lme.Coefficients.tStat(coeffIdx);
%         % dfLearning2(i-10) = lme.Coefficients.DF(coeffIdx);
%         pValueAtten2(count,i) = lme.Coefficients.pValue(coeffIdx);


        % Pearson correlation and p-value for inliers
        % [r, p] = corr(Y, learningScores, 'Type', 'Pearson');

        % Display the result if significant
        % if pValueLearning(i-10) < 0.01
        % lme
        % fprintf('Dependent Variable: %s\n', varNames{i});
        % fprintf('P-value for learning: %f\n', pValueLearning(i));
        % end
    end
   end

save('data_read_surr3_learnlme.mat','tValueLearning2','pValueLearning2')

save('data_read_surr3_attenlme.mat','tValueAtten2','pValueAtten2')


% 
% %% cut pdc by surr lme
% load('data_read_LME.mat','tValueLearning','pValueLearning','tValueAtten','pValueAtten')
% load('data_read_surr3_learnlme.mat','tValueLearning2','pValueLearning2')
% load('data_read_surr3_attenlme.mat','tValueLearning2','pValueLearning2')
% 
% 
% 

list_learning=find(pValueLearning<0.05);
% table
list_learning
titles(list_learning)'
[pValueLearning(list_learning),tValueLearning(list_learning)]


list_learning=1:162
% list_learning=[1:5]
p=zeros(length(list_learning),1);
t5=zeros(length(list_learning),1);
t95=zeros(length(list_learning),1);
for i=1:length(list_learning)
    % re=abs(tValueLearning(list_learning(i)));
    sur=zeros(size(tValueLearning2,1),1);
    for j=1:size(tValueLearning2,1)
        sur(j)=tValueLearning2(j,i);
    end
    % p(i)=length(find(sur>re))/length(sur);
    t5(i)=prctile(sur,2.5);
    t95(i)=prctile(sur,97.5);
end

[t5,t95]

% 
% 
% list_attention=find(pValueAtten<0.05);
% % table
% attention
% titles(attention)'
% [pValueAtten(list_attention),tValueAtten(list_attention)]
% 
% intersect(list_attention,stronglist_bc)
% 
% list_attention=find(pValueAtten<0.05);
% p=zeros(length(list_attention),1);
% t5=zeros(length(list_attention),1);
% t95=zeros(length(list_attention),1);
% for i=1:length(list_attention)
%     re=abs(tValueAtten(list_attention(i)));
%     sur=zeros(size(tValueAtten2,1),1);
%     for j=1:size(tValueAtten2,1)
%         sur(j)=abs(tValueAtten2(j,i));
%     end
%     p(i)=length(find(sur>re))/length(sur);
%     t5(i)=prctile(sur,5);
%     t95(i)=prctile(sur,95);
% end
% p2=p;
% [p2,t5,t95]

