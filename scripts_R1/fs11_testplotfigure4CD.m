%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% R1 FIGURE 4D - Scalp Topographic Maps
%% Shows spatial distribution of PLS component loadings on scalp
%%
%% Creates 4 topoplot maps:
%% - AI: Infant Receiver channels (adult→infant connections averaged over senders)
%% - AI: Adult Sender channels (adult→infant connections averaged over receivers)
%% - II: Infant Sender channels (infant→infant connections averaged over receivers)
%% - II: Infant Receiver channels (infant→infant connections averaged over senders)
%%
%% Uses EEGLAB topoplot function with 9-channel layout
%% Color: Loading strength (pink = high contribution to component)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load scalp FIG 4CD
path='C:\Users\Admin\OneDrive - Nanyang Technological University\infanteeg\CAM BABBLE EEG DATA\2024\code\final2_R1\'
path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/infanteeg/CAM BABBLE EEG DATA/2024/code/final2';
EEG = pop_loadset('filename',{'S0010_Filters_processed_trials.set'},'filepath',path);  % R1: Load channel locations
mychanloc=EEG.chanlocs;
mychanloc=mychanloc([1,15,2,3,16,4,5,17,6]);  % R1: Select 9 channels in order: F3,Fz,F4,C3,Cz,C4,P3,Pz,P4

%define color map



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
% custom_colormap = [neg_colors; pos_colors];
custom_colormap=pos_colors;
%% 





%% R1: Load PLS component loadings and create 9×9 matrices
%load loadings
iiloading=[];
load("iicdiloading.mat")  % R1: II GPDC loadings from bootstrap (fs9_f4_newest.m Line 1129)
iiloading=temp(:,1);
load("stronglistfdr5_gpdc_II.mat")  % R1: Significant II connection indices
validiiconnection=s4;
ii=zeros(9,9);
ii(validiiconnection)=iiloading;  % R1: Fill 9×9 matrix with loadings
ii_receiver_average=mean(ii,2);  % R1: Average over senders (columns) → receiver strength
ii_sender_average=mean(ii,1);    % R1: Average over receivers (rows) → sender strength

ailoading=[];
load("loadingai.mat")  % R1: AI GPDC loadings from bootstrap (fs9_f4_newest.m Line 1263)
ailoading=temp(:,1);
load("stronglistfdr5_gpdc_AI.mat")  % R1: Significant AI connection indices
validaiconnection=s4;
ai=zeros(9,9);
ai(validaiconnection)=ailoading;  % R1: Fill 9×9 matrix with loadings
ai_receiver_average=mean(ai,2);  % R1: Average over senders (adult) → infant receiver strength
ai_sender_average=mean(ai,1);    % R1: Average over receivers (infant) → adult sender strength


%% R1 fig 4c
%fig 5a
%% R1: AI - Infant Receiver (which infant channels receive most from adult)
  topoplot(ai_receiver_average, mychanloc, ...
        'chaninfo', EEG.chaninfo, 'electrodes','on','maplimits',[0.3,1]); axis square;
    title(['Infant Receiver Channels'], 'fontsize', 14, 'FontWeight', 'Normal');% 创建一个新的图形窗口
colormap(custom_colormap); % 设置 colormap 为 jet

%% R1: AI - Adult Sender (which adult channels send most to infant)
  topoplot(ai_sender_average, mychanloc, ...
        'chaninfo', EEG.chaninfo, 'electrodes','on','maplimits',[0.3,1]); axis square;
    title(['Adult Sender Channels'], 'fontsize', 14, 'FontWeight', 'Normal');% 创建一个新的图形窗口
%colormap(custom_colormap); % 设置 colormap 为 jet
colorbar; % 添加颜色条
hold off; % 不再在当前窗口中添加新的图形
%% R1 fig 4c


%% R1 fig 4d
%% R1: II - Infant Sender (which infant channels send within infant brain)
  topoplot(ii_sender_average, mychanloc, ...
        'chaninfo', EEG.chaninfo, 'electrodes','on','maplimits',[0.3,1]); axis square;
    title(['Infant Sender Channels'], 'fontsize', 14, 'FontWeight', 'Normal');% 创建一个新的图形窗口
colormap(custom_colormap); % 设置 colormap 为 jet
colorbar; % 添加颜色条

%% R1: II - Infant Receiver (which infant channels receive within infant brain)
  topoplot(ii_receiver_average, mychanloc, ...
        'chaninfo', EEG.chaninfo, 'electrodes','on','maplimits',[0.3,1]); axis square;
    title(['Infant Receiver Channels'], 'fontsize', 14, 'FontWeight', 'Normal');% 创建一个新的图形窗口
colormap(custom_colormap); % 设置 colormap 为 jet
colorbar; % 添加颜色条
hold off; % 不再在当前窗口中添加新的图形

% print('-dtiff', '-r300', ['f:/DSO/figs/f3/',num2str(u),'_to.tif']);
%% R1 fig 4d