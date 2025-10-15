
% %% real data
% % the result is that condition 2 contains all signficant links, so no
% links should be cleared because of stregnth.
clc
clear all
load('data_read_surr_gpdc2.mat','data_surr','data')

cutlist=[];
a=data(:,:);
a(cutlist,:)=[];
data(cutlist,:)=[];


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
connectionTypes = {'II', 'AA','AI' ,'IA' };

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

% listi = [91:171,172:252,577:657,658:738];
% listi = [10:90,91:171,172:252,496:576,577:657,658:738];

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

% II ALPHA
%   listi = [172:252];
% AI ALPHA
% listi = [ 658:738];
% IA ALPHA
% listi=[981-80:981];
% AA ALPHA
% listi=[91+81*4:171+81*4];
% change the band and direction here
% ii1 = delta ii , ii2 = theta ii, ii3 =alpha ii
listi=[ai3];

data=sqrt(data(:,listi));

titles=titles(listi);

%% by cond
significant_titles = {};


% 获取每个组别的索引
group1_idx = find(a(:, 6) == 1);
group2_idx = find(a(:, 6) == 2);
group3_idx = find(a(:, 6) == 3);
group4_idx=1:size(a,1);

p_group1=zeros(size(data,2),1);
p_group2=zeros(size(data,2),1);
p_group3=zeros(size(data,2),1);
p_group4=zeros(size(data,2),1);
% 计算每个组别的均值和显著性 p 值
mean_data_group1=zeros(1,size(data,2));
mean_data_group2=zeros(1,size(data,2));
mean_data_group3=zeros(1,size(data,2));
mean_data_group4=zeros(1,size(data,2));

for j = 1:size(data,2)
    % 计算data中每个组别的均值
    mean_data_group1(j) = nanmean(data(group1_idx, j));
    mean_data_group2(j) = nanmean(data(group2_idx, j));
    mean_data_group3(j) = nanmean(data(group3_idx, j));
    mean_data_group4(j) = nanmean(data(group4_idx, j));
end

% 初始化 data_surr 中每个组别的均值
mean_surr_group1 = zeros(length(data_surr),size(data,2));
mean_surr_group2 = zeros( length(data_surr),size(data,2));
mean_surr_group3 = zeros( length(data_surr),size(data,2));
mean_surr_group4 = zeros( length(data_surr),size(data,2));
% 计算每个置换数据中的均值
for count = 1:length(data_surr)
    count
    for j = 1:size(data,2)
        surr = data_surr{count};
        surr2=sqrt(surr(:,listi));

        surr2(cutlist,:)=[];

        mean_surr_group1(count,j) = nanmean(surr2(group1_idx, j));
        mean_surr_group2(count,j) = nanmean(surr2(group2_idx, j));
        mean_surr_group3(count,j) = nanmean(surr2(group3_idx, j));
        mean_surr_group4(count,j) = nanmean(surr2(group4_idx, j));
    end
end

% % 计算 p 值
for j = 1:size(data,2)
    p_group1(j) = (length(find((mean_surr_group1(:,j) > mean_data_group1(j))))+1) / (size(mean_surr_group1,1)+1);
    p_group2(j) =(length(find((mean_surr_group2(:,j) > mean_data_group2(j))))+1) / (size(mean_surr_group1,1)+1);
    p_group3(j) = (length(find((mean_surr_group3(:,j) > mean_data_group3(j))))+1) / (size(mean_surr_group1,1)+1);
    p_group4(j) = (length(find((mean_surr_group4(:,j) > mean_data_group4(j)))) +1)/ (size(mean_surr_group4,1)+1);
end

p_group1c=mafdr(p_group1,'BHFDR',true)
p_group2c=mafdr(p_group2,'BHFDR',true)
p_group3c=mafdr(p_group3,'BHFDR',true)
p_group4c=mafdr(p_group4,'BHFDR',true)
% p_group1c=p_group1*length(p_group1);
% p_group2c=p_group2*length(p_group2);
% p_group3c=p_group3*length(p_group3);
% p_group4c=p_group4*length(p_group4);


s1=find(p_group1c<0.05);
s2=find(p_group2c<0.05);
s3=find(p_group3c<0.05);
s4=find(p_group4c<0.05);
stronglist=union(s1,s2);
stronglist=union(stronglist,s3);
%% comment by R1 - Commented out to prevent overwriting existing data files
% save('stronglistfdr5_pdc_IAalpha.mat','stronglist','s1','s2','s3','s4')
