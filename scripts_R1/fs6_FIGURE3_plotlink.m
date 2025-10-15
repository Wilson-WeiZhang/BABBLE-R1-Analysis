%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 FIGURE 3B - GPDC connection strength ranking
%% "Fig. 3. Quantification of dyadic neural connectivity using generalised
%% partial directed coherence (GPDC). (b) Ranked GPDC strength for individual
%% real connections (coloured lines) as compared to their surrogate data
%% (black lines: mean; grey areas: 95% CI). Connections were deemed significant
%% if the real data exceeded the 95th percentile of the surrogate distribution,
%% with Benjamini-Hochberg False Discovery Rate (BHFDR) correction applied.
%% Across all gaze conditions, significant connections were detected in the
%% AA, II and AI directions, but not in the IA direction."
%%
%% Generates 4 subplots showing ranked connection strength:
%% - II PDC (infant-to-infant, dark blue)
%% - AA PDC (adult-to-adult, red)
%% - AI PDC (adult-to-infant, orange)
%% - IA PDC (infant-to-adult, light blue) - should show NO significant connections
%%
%% Statistical method:
%% - Compare real GPDC to surrogate distribution (1000 permutations)
%% - Grey area: 95% CI (2.5th - 97.5th percentile)
%% - Black line: Mean of surrogate
%% - Colored line: Real data (sorted by strength)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% FIGURE 3B %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
type='GPDC'
path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'

if isequal(type,'PDC')==1
load('data_read_surr_PDC2.mat');% 加载数据
else
  load('data_read_surr_GPDC2.mat');% 加载数据  
end
% 加载数据
% load('dataPDC.mat')
ori_data = sqrt(data);
cutlist=[];
% cutlist=[ 9    13    24    28    57    58   123   208]; % 》2
ori_data(cutlist,:)=[];

% 定义data_surr个数
num_surr = length(data_surr);

% 循环处理4个listi
% list_indices = {10+243*0:9+243*1, 10+243*1:9+243*2, 10+243*2:9+243*3, 10+243*3:9+243*4};
list_indices = {172:252,91+81*4:171+81*4, 658:738,981-80:981}
  % listi = [172:252];
  % AI ALPHA
 % listi = [ 658:738];
% IA ALPHA
% listi=[981-80:981];
% AA ALPHA
% listi=[91+81*4:171+81*4]
% listi = [981-81*1+1:981];
% listi=[10:981];
% % with bad data quality
% data=data(:,listi);
% titles=titles(listi);

titles = {'II PDC', 'AA PDC', 'AI PDC', 'IA PDC'};
colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]}
% [200/255, 200/255, 200/255]
% colorlist={  [243/255, 162/255, 97/255],...
%     [233/255, 196/255, 107/255],...
%     [ 42/255, 157/255, 140/255],...
%     [135/255, 175/255, 169/255]}


%% R1 Loop through 4 connection types (II, AA, AI, IA)
for idx = 1:4
    listi = list_indices{idx};
    if idx <=2
        listi([1:10:81]) = [];  % R1: Remove diagonal elements for II and AA
    end
    % if idx ==1
    %     load('F:\infanteeg\CAM BABBLE EEG DATA\2024\code\final\stronglistfdr5_gpdc_II.mat')
    %     listi=listi(s4);
    % end
    % if idx ==2
    %     load('F:\infanteeg\CAM BABBLE EEG DATA\2024\code\final\stronglistfdr5_gpdc_AA.mat')
    %     listi=listi(s4);
    % end
    % if idx ==3
    %     load('F:\infanteeg\CAM BABBLE EEG DATA\2024\code\final\stronglistfdr5_gpdc_AI.mat')
    %     listi=listi(s4);
    % end
    % if idx ==4
    %     load('F:\infanteeg\CAM BABBLE EEG DATA\2024\code\final\stronglistfdr5_gpdc_IA.mat')
    %     listi=listi(s4);
    % end

    % 预分配存储均值
    mean_data = zeros(num_surr, length(listi));

    % 计算每个data_surr的均值
    for i = 1:num_surr
        data = sqrt(data_surr{i});
        data(cutlist,:)=[];
        mean_data(i, :) = mean(data(:, listi), 1);
    end

    %% R1: Calculate surrogate distribution statistics
    mean_all = mean(mean_data, 1);
    prct_low = prctile(mean_data, 2.5, 1);  % 2.5th percentile
    prct_high = prctile(mean_data, 97.5, 1);  % 97.5th percentile (95% CI upper bound)

    %% R1: Calculate proportion of real connections exceeding surrogate 95% CI
    % This identifies significant connections (before BHFDR correction)
    original_data_mean = mean(ori_data(:, listi), 1);
    [a, b] = sort(original_data_mean);  % R1: Sort by strength for ranking plot
    exceed_count = sum(original_data_mean > prct_high);
    total_count = length(original_data_mean);
    exceed_percentage = (exceed_count / total_count) * 100;

    %% R1: Plot Figure 3b - Ranked connection strength with surrogate comparison
    figure('units','normalized','outerposition',[0 0 1 1]); % 最大化窗口
    hold on;


    %% R1: Plot grey 95% CI band (surrogate distribution)
    fill([1:length(prct_low(b)), fliplr(1:length(prct_high(b)))], [prct_low(b), fliplr(prct_high(b))], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

    %% R1: Plot black line (mean of surrogate)
    plot(mean_all(b), 'LineWidth', 10, 'Color', [0/255, 0/255, 0/255]);

    %% R1: Plot colored line (real data, strength-ranked)
    % Colors: II=dark blue, AA=red, AI=orange, IA=light blue
    plot(original_data_mean(b), 'LineWidth', 10, 'Color', colorlist{idx});

    hold off;
    xlabel('Connections (Strength-Ranked)', 'FontSize', 40, 'FontWeight', 'bold');
    ylabel('Strength', 'FontSize', 40, 'FontWeight', 'bold');
    title(titles{idx}, 'FontSize', 80, 'FontWeight', 'bold');
    if isequal(type,'PDC')==1
    
    else
       ylim([0.18 0.26]);
    end
 xlim([0 81]);

    % 在图像中插入文本
    % text(10, 0.062, sprintf('%.2f%% (%d/%d) actual connections.', exceed_percentage, exceed_count, total_count), 'FontSize', 20, 'FontWeight', 'bold');

    % 设置x轴和y轴等长
    pbaspect([2 1 1]); % 设置轴的比例

    % 加粗轴
    ax = gca;
    ax.LineWidth = 6;
    ax.FontSize = 40;
    ax.FontWeight = 'bold';
    
% 调整图形区域位置
set(gca, 'PositionConstraint', 'innerposition');
set(gca, 'Position', [0.1 0.2 0.8 0.7]); % 调整这些值以适应您的需求

    % 保存图像
    
% if isequal(type,'PDC')==1
%     saveas(gcf, sprintf([path,'infanteeg/CAM BABBLE EEG DATA/2024/FIG/F3/PDC_%s.png'], titles{idx}));
% else
%     saveas(gcf, sprintf([path,'infanteeg/CAM BABBLE EEG DATA/2024/FIG/F3/GPDC2_%s.png'], titles{idx}));
% end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% FIGURE 4C above %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%% FIGURE 4B no use %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% amount
% load('dataGPDC.mat')
% ori_data = sqrt(data);
% cutlist=[];
% % cutlist=[ 9    13    24    28    57    58   123   208]; % 》2
% ori_data(cutlist,:)=[];
% 
% % 循环处理4个listi
% % list_indices = {10+243*1:9+243*2,10+243*0:9+243*1,  10+243*2:9+243*3, 10+243*3:9+243*4};
% list_indices = {172:252,91+81*4:171+81*4, 658:738,981-80:981}
% titles = {'AA GPDC', 'II GPDC', 'AI GPDC', 'IA GPDC'};
% 
% for idx = 1:4
% 
%     listi = list_indices{idx};
%             if idx <=2
%         listi([1:10:81]) = [];
%     end
%     original_data_mean = mean(ori_data(:, listi), 1);
%     m(idx)=mean(original_data_mean(:));
%     s(idx)=std(original_data_mean(:));
% end
% result2 = [
%     [m(1), s(1), 226],...
%     [m(2), s(2), 226],...
%     [m(3), s(3), 226],...
%     [m(4), s(4), 226]];
% 
% %% amount surr
% load('data_read_surr_gpdc2.mat')
% 
% list_indices = {172:252,91+81*4:171+81*4, 658:738,981-80:981}
% titles = {'AA GPDC', 'II GPDC', 'AI GPDC', 'IA GPDC'};
% sudata=zeros(226*1000,72);
% % sudata=zeros(226*1000,81);
% for su=1:1000
%     su
% for idx = 1:1
%     ori_data=data_surr{su};
%     listi = list_indices{idx};
%             if idx <=2
%         listi([1:10:81]) = [];
%             end
%     sudata(1+226*(su-1):226*su,:)=ori_data(:, listi);
% end
% end
% 
% result2 = [mean(sudata(:)),std(sudata(:)),226000];
% %%%%%%%%%%%%%%%%%%%%%%%%%%%% FIGURE 4B above %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%