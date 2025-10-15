%%%%%%%%%%%%%%%%%%%% figure4C %%%%%%%%%%%%%%%%%%%%
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

data=sqrt(data(:,listi));
titles=titles(listi);
%% LME

load('stronglistfdr5_gpdc_II.mat');
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
%  0.9070
% stronglist=1:162
% 15 c2
for i = 1:length(stronglist)

    % i
    % titles{stronglist(i)}
    Y = data(:, stronglist(i)); % Set the dependent variable
    Y=sqrt(Y);
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
    lme = fitlme(tbl, 'atten ~ AGE + SEX +Y*CONDGROUP+COUNTRY  + (1|ID)');
% lme = fitlme(tbl, 'learning ~ AGE + SEX +Y+COUNTRY +(1|ID)')
    
% 修改后的模型，移除了 CONDGROUP 的主效应，但保留交互项
% lme = fitlme(tbl, 'learning ~ AGE + SEX + Y * CONDGROUP + COUNTRY - CONDGROUP + (1|ID)')
    coeffIdx = strcmp(lme.Coefficients.Name, 'Y:CONDGROUP_2');

        tValueLearning(i) = lme.Coefficients.tStat(coeffIdx);
    pValueLearning(i) = lme.Coefficients.pValue(coeffIdx);   
    
    % coeffIdx = strcmp(lme.Coefficients.Name, 'Y');
    % tValueLearning(i) = lme.Coefficients.tStat(coeffIdx);
    % pValueLearning(i) = lme.Coefficients.pValue(coeffIdx);
end
% {'II_Alpha_F4_to_Cz'} IN C1 BEHAVIOUR 2 +
% {'II_Alpha_F4_to_Cz'} IN C2 BEHAVIOUR 2 -
%  NO IN C3

pValueLearning(find(pValueLearning<0.05))
tValueLearning(find(pValueLearning<0.05))
q=mafdr(pValueLearning,'BHFDR',true)
titles(stronglist(find(pValueLearning<0.05)))'
titles(stronglist(find(q<0.05)))'
stronglist(find(pValueLearning<0.05))
q(find(q<0.05))
%% 
 Y = data(:, 23); % Set the dependent variable

 tbl = table(ID, zscore(learning),zscore(atten), zscore(AGE), SEX, COUNTRY, zscore(Y), blocks, CONDGROUP, 'VariableNames',...
{'ID', 'learning','atten', 'AGE', 'SEX', 'COUNTRY', 'Y', 'block', 'CONDGROUP'});

lme = fitlme(tbl, 'learning ~ AGE + SEX +Y*CONDGROUP+COUNTRY  + (1|ID)')



%%  FWE threhold


df = 217;  % Degrees of freedom
p = 0.05/length(s4);  % Bonferroni corrected p-value

% Calculate the t-value
t_value = tinv(1 - p/2, df);

% Display the result
fprintf('For df = %d and p = %f (Bonferroni corrected):\n', df, p);
fprintf('The two-tailed t-value is approximately %.6f\n', t_value);

(sort(tValueLearning))'


%% 
% qplace=find(q<0.05)
% pValueLearning(qplace)
% pValueLearning2=pValueLearning;
% k=[];count=0
% for i=0:0.0001:0.01
%     pValueLearning2(qplace)=i;
%     count=count+1;
%     q2=mafdr(pValueLearning2,'BHFDR',true);
%     k(count)=q2(qplace);
% end

% ii
% 0.0001*7
df = 217;  % Degrees of freedom
p = 0.0001*7;  % Bonferroni corrected p-value
% Calculate the t-value
t_value = tinv(1 - p/2, df);
% Display the result
fprintf('For df = %d and p = %f (Bonferroni corrected):\n', df, p);
fprintf('The two-tailed t-value is approximately %.6f\n', t_value);

%%%%%%%%%%%%%%%%%%%% figure4C %%%%%%%%%%%%%%%%%%%%









%%%%%%%%%%%%%%%%%%%% figure4D %%%%%%%%%%%%%%%%%%%%

%% corr paper z
 k=23

% Calculate partial correlations and p-values for each group
[r1, P1] = partialcorr(data(g1, k), learning(g1), a(g1, [1, 3, 4]));
[r2, P2] = partialcorr(data(g2, k), learning(g2), a(g2, [1, 3, 4]));
[r3, P3] = partialcorr(data(g3, k), learning(g3), a(g3, [1, 3, 4]));
[r4, P4] = partialcorr(data(g4, k), learning(g4), a(g4, [1, 3, 4]));

% Convert partial correlation coefficients to Fisher's Z values
z1 = 0.5 * log((1 + r1) / (1 - r1));
z2 = 0.5 * log((1 + r2) / (1 - r2));
z3 = 0.5 * log((1 + r3) / (1 - r3));
z4= 0.5 * log((1 + r4) / (1 - r4));
% Sample sizes for each group
n1 = length(g1);
n2 = length(g2);
n3 = length(g3);
n4=length(g3);
% Compute standard errors for the Fisher's Z values
se1 = sqrt(1 / (n1 - 3));
se2 = sqrt(1 / (n2 - 3));
se3 = sqrt(1 / (n3 - 3));
se4 = sqrt(1 / (n4 - 3));
% Calculate Z statistics for pairwise comparisons
z_diff_12 = (z1 - z2) / sqrt(se1^2 + se2^2);
z_diff_13 = (z1 - z3) / sqrt(se1^2 + se3^2);
z_diff_23 = (z2 - z3) / sqrt(se2^2 + se3^2);
z_diff_43 = (z4 - z3) / sqrt(se4^2 + se3^2);

% Calculate p-values for the Z statistics
p_value_12 = 2 * (1 - normcdf(abs(z_diff_12)));
p_value_13 = 2 * (1 - normcdf(abs(z_diff_13)));
p_value_23 = 2 * (1 - normcdf(abs(z_diff_23)));
p_value_43 = 2 * (1 - normcdf(abs(z_diff_43)));

mean(data(g1,k))
mean(data(g2,k))
mean(data(g3,k))

[h,p]=ttest2(data(g3,k),data(g1,k))
[h,p]=ttest2(data(g2,k),data(g1,k))
[h,p]=ttest2(data(g3,k),data(g2,k))


%%%%%%%%%%%%%%%%%%%% figure4D %%%%%%%%%%%%%%%%%%%%
%% END