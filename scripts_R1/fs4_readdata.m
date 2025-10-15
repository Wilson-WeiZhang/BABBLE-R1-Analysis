clc
clear all
data=[];
path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'

[a, b] = xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/table/behaviour2.5sd.xlsx']);
% cut non learning samples
a(find(sum(isnan(a(:,7)),2)>0),:)=[];
load([path,'infanteeg/CAM BABBLE EEG DATA/2024/code/final/surr/windowlist.mat'],'non_empty_positionslist')
type='GPDC'
list42=[ 1101
        1102
        1103
        1104
        1105
        1106
        1107
        1108
        1109
        1111
       
        1114
       
        1117
        1118
        1119
        1121
        1122
        1123
        1124
        1125
        1126
        1127
        1128
        1129
        1131
        1132
        1133
        1135
        2101
        2104
        2106
        2107
        2108
        2110
     
        2114
        2115
        2116
        2117
        
        2120
        2121
        2122
        2123
        2127];

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

% 9    24    28    33    57    83    92    99   105   208
count=0;s=[];
for i = 1:size(a, 1)
    if ~isnan(a(i, 7)) 
        num=a(i,2);
        if ismember(num,[1113,1136,1112,1116,2112,2118,2119])==0
        num = num2str(a(i, 2));
        num = num(2:4);
        if a(i, 1) == 1
            % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/olderlearning/data_matfile/PDC/UK_', num, '_PDC.mat']);
% load(['f:/infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/DC3_norpdc_nonorpower/UK_', num, '_PDC.mat']);
load( [path,'infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/',type,'3_nonorpdc_nonorpower/UK_', num, '_PDC.mat']);
% load(['f:/infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/',type,'3_nonorpdc_nonorpower_phrase1only/UK_', num, '_PDC.mat']);
% load(['f:/infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/PDC3/UK_', num, '_PDC.mat']);
  % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/PDC3_nonormal//UK_', num, '_PDC.mat']);
      
            %      load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/DTF/UK_', num, '_II.mat']);
            %             load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/DTF/UK_', num, '_AI.mat']);
            % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surr_PDC10/UK_', num, '_II.mat']);
            % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surr_PDC10/UK_', num, '_AI.mat']);
            %             load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/PDC2/UK_', num, '_AA.mat']);
        else
            % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/olderlearning/data_matfile/PDC/SG_', num, '_PDC.mat']);
% load(['f:/infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/DC3_norpdc_nonorpower/SG_', num, '_PDC.mat']);
load([path,'infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/',type,'3_nonorpdc_nonorpower/SG_', num, '_PDC.mat']);
% load(['f:/infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/',type,'3_nonorpdc_nonorpower_phrase1only/SG_', num, '_PDC.mat']);
     % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/PDC3_nonormal//SG_', num, '_PDC.mat']);
      % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/PDC3/SG_', num, '_PDC.mat'])
      % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/PDC3_nonorpdc_nonorpower/SG_', num, '_PDC.mat']);
            %               load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/DTF/SG_', num, '_II.mat']);
            %             load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/DTF/SG_', num, '_AI.mat']);
            % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surr_PDC10/SG_', num, '_II.mat']);
            % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surr_PDC10/SG_', num, '_AI.mat']);
            %             load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/PDC2/SG_', num, '_AA.mat']);
        end
try
        block = a(i, 5);
        cond = a(i, 6);
        y=find(list42==a(i, 1)*1000+str2num(num));
        tmp=non_empty_positionslist{y};
        list=intersect(find(tmp(:,1)==block),find(tmp(:,2)==cond));
        sumwindow=sum(tmp(list,4));
        if sumwindow>0
            
              ii1 = II{block, cond, 1};
    
        ii1 = ii1(:);

        ii2 = II{block, cond, 2};

        ii2 = ii2(:);

        ii3 = II{block, cond, 3};

        ii3 = ii3(:);

        aa1 = AA{block, cond, 1};

        aa1 = aa1(:);

        aa2 = AA{block, cond, 2};

        aa2 = aa2(:);

        aa3 = AA{block, cond, 3};

        aa3 = aa3(:);

        ai1 = AI{block, cond, 1};
        ai1 = ai1(:);

        ai2 = AI{block, cond, 2};
        ai2 = ai2(:);

        ai3 = AI{block, cond, 3};
        ai3 = ai3(:);


        ia1 = IA{block, cond, 1};
        ia1 = ia1(:);

        ia2 = IA{block, cond, 2};
        ia2 = ia2(:);

        ia3 = IA{block, cond, 3};
        ia3 = ia3(:);

      if isempty(ii3)==0
        % data = [data; [a(i, 1:9), ii1'-ia1', ii2'-ia2', ii3'-ia3',  aa1', aa2', aa3', ai1'-ia1', ai2'-ia2', ai3'-ia3',ia1', ia2', ia3']];
data = [data; [a(i, 1:9), ii1', ii2', ii3',  aa1', aa2', aa3', ai1', ai2', ai3',ia1', ia2', ia3']];
count=count+1;
s(count)=std([ii1', ii2', ii3',  aa1', aa2', aa3', ai1', ai2', ai3',ia1', ia2', ia3']);

% data = [data; [a(i, 1:9), zscore(ii1'), zscore(ii2'), zscore(ii3'),  zscore(aa1'), zscore(aa2'), zscore(aa3'), zscore(ai1'), zscore(ai2'), zscore(ai3'),zscore(ia1'), zscore(ia2'), zscore(ia3')]];
      end
    end
    end
end
    end
end

% mean value between II AA AI IA AND PLOT
segment1 = data(:,10+243*0:9+243*1);
segment2 = data(:,10+243*1:9+243*2);
segment3 = data(:,10+243*2:9+243*3);
segment4 = data(:,10+243*3:9+243*4);
segment1=segment1(:);
segment2=segment2(:);
segment3=segment3(:);
segment4=segment4(:);

result = [
    [nanmean(segment1), nanstd(segment1), 168];...
    [nanmean(segment2), nanstd(segment2), 168];...
    [nanmean(segment3), nanstd(segment3), 168];...
    [nanmean(segment4), nanstd(segment4), 168]]
[h,p]=ttest2(segment3,segment1)

% % One-Hot Encoding for categorical variables
% country = dummyvar(categorical(data(:, 1)));
% sex = dummyvar(categorical(data(:, 4)));
% block = dummyvar(categorical(data(:, 5)));
%
% % Remove last column of One-Hot encoded variables to avoid multicollinearity
% country(:, end) = [];
% sex(:, end) = [];
% block(:, end) = [];
%
% % Create the final dataset
% finalData = [country, data(:, 3), sex, block, data(:, 7), data(:, 9) , data(:, 11:end)];
%
% % Generate titles
countryTitles = 'Country';
sexTitles = 'Sex';
blockTitles = 'Block';
ageTitle = {'Age'};
learningTitle = {'Learning'};
attenTitle = {'atten'};
% Generate titles for the connections
nodes = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
% nodes ={'F3','Fz','F4','FC1','FC2','C3','Cz','C4','CP5','CP1','CP2','CP6','P3','Pz','P4'}
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

%% comment by R1 - Commented out to prevent overwriting existing data files
% save(['data',type,'.mat'],'data')

% data2=data(:,11:end);
% titles=titles(11:end);
% for i=1:148
%     sub=data(i,730:end);
%     y=prctile(sub,95)
%     q=data2(i,:);
%     q(find(q<y))=0;
%     data2(i,:)=q;
% end
% imagesc(data2)

%%  load surr.

% 定义surr_PDC文件夹路径前缀
% surrPathPrefix = 'f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrPDCSET3/surr3_PDC';
surrPathPrefix = [path,'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrPDCSET5/PDC'];
% surrPathPrefix = ['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surr',type,'SET5/'];
% 存储读取到的shuffle数据
data_surr = cell(1000,1);
count=0;
z=zeros(1000,1);
a=data;
for surrIdx = 1:1000
    surrIdx
    surrPath = [surrPathPrefix, num2str(surrIdx)];

    % 检查文件夹中是否有235个.mat文件
    files = dir(fullfile(surrPath, '/*.mat'));
    if length(files) >= 42
        temp=zeros(size(data));
        count=count+1;
        z(surrIdx)=1;
                  count1=0;
        % 提取数据和拼接，假设文件中包含II和AI数据
        for i = 1:size(a, 1)
  
            if ~isnan(a(i, 7)) 
      num=a(i,2);
        if ismember(num,[1112,1116,2112,2118,2119])==0
                num = num2str(a(i, 2));
                num = num(2:4);
                if a(i, 1) == 1
                    % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrPDCSET3/surr3_PDC', num2str(surrIdx), '/UK_', num, '_PDC.mat']);
 load([path,'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrPDCSET5/PDC', num2str(surrIdx), '/UK_', num, '_PDC.mat']);
% load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surr',type,'SET5/', num2str(surrIdx), '/UK_', num, '_PDC.mat']);

                else
                    % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrPDCSET3/surr3_PDC', num2str(surrIdx), '/SG_', num, '_PDC.mat']);
                load([path,'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrPDCSET5/PDC', num2str(surrIdx), '/SG_', num, '_PDC.mat']);
               % load(['f:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surr',type,'SET5/', num2str(surrIdx), '/SG_', num, '_PDC.mat']);

                end
try
                block = a(i, 5);
                cond = a(i, 6);

               
              ii1 = II{block, cond, 1};

        ii1 = ii1(:);

        ii2 = II{block, cond, 2};

        ii2 = ii2(:);

        ii3 = II{block, cond, 3};

        ii3 = ii3(:);

        aa1 = AA{block, cond, 1};

        aa1 = aa1(:);

        aa2 = AA{block, cond, 2};

        aa2 = aa2(:);

        aa3 = AA{block, cond, 3};

        aa3 = aa3(:);

        ai1 = AI{block, cond, 1};
        ai1 = ai1(:);

        ai2 = AI{block, cond, 2};
        ai2 = ai2(:);

        ai3 = AI{block, cond, 3};
        ai3 = ai3(:);


        ia1 = IA{block, cond, 1};
        ia1 = ia1(:);

        ia2 = IA{block, cond, 2};
        ia2 = ia2(:);

        ia3 = IA{block, cond, 3};
        ia3 = ia3(:);
         if isempty(ii1)==0
count1=count1+1;
         temp (count1,:)=[a(i, 1:9), ii1', ii2', ii3',  aa1', aa2', aa3', ai1', ai2', ai3',ia1', ia2', ia3'];
% temp (count1,:)=[a(i, 1:9), zscore(ii1'), zscore(ii2'), zscore(ii3'),  zscore(aa1'), zscore(aa2'), zscore(aa3'), zscore(ai1'), zscore(ai2'), zscore(ai3'),zscore(ia1'), zscore(ia2'), zscore(ia3')];
 
         end
        % temp (count1,:)= [a(i, 1:9), ii1'-ia1', ii2'-ia2', ii3'-ia3',  aa1', aa2', aa3', ai1'-ia1', ai2'-ia2', ai3'-ia3',ia1', ia2', ia3'];
        end
            end
        end
        data_surr{count}=temp;
    end
    end
end

list=zeros(length(data_surr),1);
for i=1:length(list)
    if isempty(data_surr{i})==1
        list(i)=1;
    end
end
data_surr(find(list==1))=[];

%% comment by R1 - Commented out to prevent overwriting existing data files
% save(['data_read_surr_',type,'2.mat'],'data_surr','data')
% save('data_read_surr5.mat','data_surr','data')




