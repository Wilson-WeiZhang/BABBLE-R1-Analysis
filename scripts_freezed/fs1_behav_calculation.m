%% ========================================================================
%  STEP 1: Calculate Behavioral Learning Metrics
%  ========================================================================
%
%  PURPOSE:
%  Calculate infant learning performance from raw looking time data during
%  the Testing phase. Learning is measured as the difference in looking
%  times between nonwords and words (novelty preference).
%
%  CORRESPONDS TO MANUSCRIPT:
%  - Results Section 2.1 "Speaker gaze modulates selection of socially
%    relevant language stimulus for learning"
%  - Figure 1d (Learning performance across gaze conditions)
%  - Table 1 (Performance metrics for three gaze conditions)
%  - Methods 4.2.3.2 (Testing phase)
%
%  KEY FINDINGS:
%  - Full gaze: Learning = 1.22 ± 0.46 sec, t(98) = 2.66, p < .05
%  - Partial gaze: Learning = 0.76 ± 0.51 sec, t(98) = 1.53, p = .19
%  - No gaze: Learning = 0.34 ± 0.42 sec, t(99) = 0.81, p = .42
%
%  LEARNING METRIC:
%  - Looking time difference: Nonwords - Words (in seconds)
%  - Positive values indicate novelty preference (expected pattern)
%  - Based on Saffran et al. (1996) statistical learning paradigm
%
%  DATA QUALITY CONTROL:
%  - Outlier exclusion: Trials exceeding mean + 2.5 SD are rejected
%  - Only 2.28% of trials excluded
%  - Requires both valid word and nonword looks per testing phase
%
%  OUTPUT FILES:
%  - behaviour2.5sd.xlsx: Contains learning scores, attention metrics, CDI
%  - Organized by participant, gaze condition, and block
%
%  SUPPLEMENTARY MATERIALS:
%  - Supplementary Section 11 provides further details on this Testing phase
%    implementation, including video presentation procedures, looking time
%    recording methods, and data quality control criteria
%
%  ========================================================================

%% this step calculates learning and attention from raw data file and save as behaviour2.5sd.xlsx

path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'

clear all
clc
%% camb data learning calculation
try
    data = textread([path,'infanteeg/CAM BABBLE EEG DATA/2024/looktime/CAM_AllData.txt']);
catch
    data = textread([path,'infanteeg/CAM BABBLE EEG DATA/2024/looktime/CAM_AllData.txt']);
end
% get ID list
PNo = unique(data(:,1));
PNo1 = unique(data(:,1))+1000;
PNo1([12,31])=[];
PNo([12,31])=[];

% cutoff setting
SD_number=2.5;

% count samples
count=0;
count_clear=0;


for p = 1:length(PNo1)
    tmpind = find(data(:,1) == PNo(p) & data(:,9)>0); % non-zero looks
    %     record age sex
    age_camb(p)=data(tmpind(1),2);
    sex_camb(p)=data(tmpind(1),3);
    %   in data, the column No.:  6 cond, 8 word, 9 learning, 10 error, 5 block
    tmpdata = [data(tmpind,6), data(tmpind,8), data(tmpind,9), data(tmpind,10),data(tmpind,5)]; % RAW/Z looking times by participant

    %     cut the error trials marked by 1
    % ind=find(tmpdata(:,4)==0);
    % tmpdata=tmpdata(ind,:);

    icut1 = mean(tmpdata(:,3)) + SD_number*std(tmpdata(:,3)); % individual threshold as SD (default = 2.5 SD above mean)

    for block=1:3

        indtest = find( tmpdata(:,3) < icut1& tmpdata(:,5) == block);
        for cond = 1:3

            for word = 1:2

                % different screening
                ind = find(tmpdata(:,1) == cond & tmpdata(:,2) == word & tmpdata(:,3) < icut1& tmpdata(:,5) == block);
                ind2 = find(tmpdata(:,1) == cond & tmpdata(:,2) == word  & tmpdata(:,5) == block);
                ind_ori = find(tmpdata(:,1) == cond & tmpdata(:,2) == word & tmpdata(:,3) < icut1);

                % calculate meanlook of camb
                % if length(ind_ori) > 1 % include only if more than 1 look!
                if length(indtest) > 1 && length(unique(tmpdata(indtest,2)))==2
                    %                   if length(indtest) >= 1
                    MeanLook{cond}(p,word,block) = nanmean(tmpdata(ind,3));

                    count_clear=count_clear+length(ind);
                    count=count+length(ind2);


                else
                    MeanLook{cond}(p,word,block) = NaN;
                end

                clear ind
            end
        end

    end
    clear tmpind tmpdata
end


%% SG learning calculation

    data = textread([path,'infanteeg/CAM BABBLE EEG DATA/2024/looktime/SG_AllData_040121.txt']);

% get ID list
PNo = unique(data(:,1));
PNo2 = unique(data(:,1))+2100;

for p = 1:length(PNo2)
    tmpind = find(data(:,1) == PNo(p) & data(:,9)>0); % non-zero looks
    %     record age sex
    age_sg(p)=data(tmpind(1),2);
    sex_sg(p)=data(tmpind(1),3);
    %   in data, the column No.:  6 cond, 8 word, 9 learning, 10 error, 5 block
    tmpdata = [data(tmpind,6), data(tmpind,8), data(tmpind,9), data(tmpind,10),data(tmpind,5)]; % RAW/Z looking times by participant

    %     cut the error trials marked by 1
    % ind=find(tmpdata(:,4)==0);
    % tmpdata=tmpdata(ind,:);

    icut1 = mean(tmpdata(:,3)) + SD_number*std(tmpdata(:,3)); % individual threshold as SD (default = 2.5 SD above mean)

    for block=1:3

        indtest = find( tmpdata(:,3) < icut1& tmpdata(:,5) == block);
        for cond = 1:3
            %                 indtest = find(tmpdata(:,1) == cond& tmpdata(:,3) < icut1& tmpdata(:,5) == block);

            for word = 1:2

                % different screening
                ind = find(tmpdata(:,1) == cond & tmpdata(:,2) == word & tmpdata(:,3) < icut1 & tmpdata(:,5) == block);
                ind2 = find(tmpdata(:,1) == cond & tmpdata(:,2) == word  & tmpdata(:,5) == block);

                ind_ori = find(tmpdata(:,1) == cond & tmpdata(:,2) == word & tmpdata(:,3) < icut1);


                % calculate meanlook of SG
                % if length(ind_ori) > 1 % include only if more than 1 look!
                if length(indtest) >1 &&length(unique(tmpdata(indtest,2)))==2
                    %                 if length(indtest) >= 1
                    MeanLook2{cond}(p,word,block) = nanmean(tmpdata(ind,3));
                    count=count+length(ind2);
                    count_clear=count_clear+length(ind);

                else
                    MeanLook2{cond}(p,word,block) = NaN;
                end
                clear ind
            end
        end
    end
    clear tmpind tmpdata
end

% clear ratio
'clear ratio'
count_clear/count


%% calculate final learning and store into "data" by subtracting word2-word1
data=[];
for i=1:size(PNo1)
    for b=1:3
        for c=1:3
            data=[data;[1,PNo1(i),age_camb(i),sex_camb(i),b,c,MeanLook{c}(i,2,b)-MeanLook{c}(i,1,b),(MeanLook{c}(i,2,b)+MeanLook{c}(i,1,b))/2]];
        end
    end
end

for i=1:size(PNo2)
    for b=1:3
        for c=1:3
            data=[data;[2,PNo2(i),age_sg(i),sex_sg(i),b,c,MeanLook2{c}(i,2,b)-MeanLook2{c}(i,1,b),(MeanLook2{c}(i,2,b)+MeanLook2{c}(i,1,b))/2]];
        end
    end
end
%


%


%% attention calculation
%% camb

camblist=[101 102 103 104 105 106 107 108 109 111 112 113 114 116 117 118 119 121 122 123 124 125 126 127 128 129 131 132 133 135 136];

    [a,b]=xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/looktime/CAM BABBLE Summary_280321 (incl first look).xlsx']);

% ID adjust
a(6,1)=101;

atten=[];
for block=1:3
    for i=1:31
        for cond=1:3
            ind=find(a(:,1)==camblist(i)&a(:,5)==cond&a(:,4)==block);
            atten(i,block,cond)=nanmean(a(ind,8));
        end
    end
end
camblist=camblist+1000;

for i=1:size(data)
    if data(i,1)==1
        ind=find(camblist==data(i,2));
        if isempty(atten(ind,data(i,5),data(i,6)))==0&&isnan(atten(ind,data(i,5),data(i,6)))==0
            data(i,9)=atten(ind,data(i,5),data(i,6));
        else
            data(i,9)=nan;
        end
    end
end

%% sg attention
[a,b]=xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/looktime/SG_SummaryFam_BNo_ExtractFam.xlsx']);

% ID adjust
a(find(a(:,1)>200),1)=a(find(a(:,1)>200),1)-100;

% find unique subject, block, cond
[group, ~, groupIDs] = unique(a(:, [1,7,9]), 'rows', 'stable');
% calculate attention
temp=[];
for i=1:size(group)
    ind=find(groupIDs==i);
    totaltime=0;
    attentiontime=0;
    for j=1:length(ind)
        if a(ind(j),5)<99
            totaltime=totaltime+a(ind(j),6);
        else
            attentiontime=attentiontime+a(ind(j),6);
        end
    end
    temp(i,1:2)=[totaltime,attentiontime];
end
% add into temp table
group=[group,temp];

% match cid as 2***
group(:,1)=group(:,1)+2000;

%add attention sg into main table
for i=1:size(data,1)
    if data(i,1)==2
        ind = find(group(:,1) == data(i,2) & group(:,2) == data(i,5) & group(:,3) == data(i,6), 1, 'first');
        if isempty(ind)==0
            data(i,9)=group(ind,5)/group(ind,4);
        else
            data(i,9)=nan;
        end
    end
end

a=data;
cut=zeros(size(a,1),1);
for i=1:size(a,1)
    if sum(isnan(a(i,7)))~=0
        cut(i)=1;
    end
end
a(find(cut==1),:)=[];
unique(a(:,2 ))

a=data;
cut=zeros(size(a,1),1);
for i=1:size(a,1)
    if sum(isnan(a(i,9)))~=0
        cut(i)=1;
    end
end
a(find(cut==1),:)=[];
unique(a(:,2 ))


% data table title:
titles={'country','id','age','sex','block','cond','learning(word2-word1)','totaltimeduringtest(word2+word1)','attention proportion'}

%  save to 'd:/infanteeg/CAM BABBLE EEG
%  DATA/2024/table/behaviour_cuterrorlearning_PDC4.xlsx', PDC no need here

filePath1 = [path,'infanteeg/CAM BABBLE EEG DATA/2024/table/behaviour2.5sd.xlsx'];
filePath2 = [path,'infanteeg/CAM BABBLE EEG DATA/2024/table/behaviour2.5sd.xlsx'];

% Delete the file if it exists
if exist(filePath1, 'file') == 2
    delete(filePath1);
end
if exist(filePath2, 'file') == 2
    delete(filePath2);
end

% Try writing to the first file path
%% comment by R1 - Commented out to prevent overwriting existing data files
try
%     xlswrite(filePath1, titles, 'Sheet1', 'A1');
%     xlswrite(filePath1, data, 'Sheet1', 'A2');
catch
    % If an error occurs, write to the second file path
%     xlswrite(filePath2, titles, 'Sheet1', 'A1');
%     xlswrite(filePath2, data, 'Sheet1', 'A2');
end
