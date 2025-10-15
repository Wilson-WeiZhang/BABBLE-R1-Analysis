%% ========================================================================
%  STEP 0: Calculate Visual Attention Metrics
%  ========================================================================
%
%  PURPOSE:
%  Calculate infant visual attention onset times and durations from EEG
%  segments to quantify attention patterns during familiarization phase.
%
%  CORRESPONDS TO MANUSCRIPT:
%  - Results Section 2.1 (Visual attention measures)
%  - Figure 2a (Three measures of infant visual attention)
%  - Supplementary Section 2 (Additional attention measures)
%
%  KEY METRICS CALCULATED:
%  1. Attention onsets: Number of times infant shifted gaze to screen
%  2. Average attention duration: Average length of each look
%  3. Total attention duration: Sum of all looking times
%
%  KEY FINDINGS:
%  - No significant difference in attention across gaze conditions
%    (Full vs Partial: t288=0.98, p=.33; Full vs No: t288=-0.27, p=.79)
%  - SG infants attended longer than UK infants (t282=5.21, p<.0001)
%  - No correlation between attention and learning (p>.09 for all)
%
%  OUTPUT FILES:
%  - gazesg.mat: Singapore infant attention data
%  - gazeuk.mat: UK infant attention data
%  - Contains: onset_startpoint, onset_endpoint, onset_number, onset_duration
%
%  ANALYSIS APPROACH:
%  - Uses BABBLE_attend.mat and BABBLE_PP.mat files
%  - Identifies continuous attended segments (non-NaN values)
%  - Calculates segment boundaries and durations
%  - Validates against raw EEG data integrity
%
%  ========================================================================

%% calculate attend onset and duration based on the segments in BABBLE EEG and save to mat file
clear all
path =  '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'

Loc = 'C'; % C for Cambridge, S for Singapore
Montage = 'GRID';
freqs = [9,17,24,32]; % 3, 6.25, 9, 12.1 Hz for nfft = 256

if strcmp(Loc,'S')==1
filepath=[path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_sg/']
else
filepath=[path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_camb/']
end

if strcmp(Montage,'AP3')==1
    include = [5,16,27]'; % included electrodes Anterior-Posterior Midline
elseif strcmp(Montage,'AP4')==1
    include = [4,6,26,28]'; % included electrodes Anterior-Posterior Left-Right (square)
elseif strcmp(Montage,'CM3')==1
    include = [15:17]'; % included electrodes Central Motor Midline
elseif strcmp(Montage,'APM4')==1
    include = [15,17,5,27]'; % included electrodes Anterior-Posterior Midline (diamond)
elseif strcmp(Montage,'FA3')==1
    include = [4:6]'; % included electrodes Frontal Left-Right
elseif strcmp(Montage,'PR3')==1
    include = [26,27,28]'; % included electrodes Parietal [P3, Pz, P4]
elseif strcmp(Montage,'GRID')==1
    include = [4:6,15:17,26:28]'; % included 9-channel grid FA3, CM3, PR3
    chLabel = {'F3','Fz','F4','C3','Cz','C4','P3','Pz','P4'};
end

% Model Parameters
NSamp = 200;
len = [1.5]; % 1s, 1.5s or 3s (default 1.5s)
shift = 0.5*len*NSamp; % overlap between windows (default 0.5)
wlen = len*NSamp; 
nfft = 256; % 2^(nextpow2(wlen)-1);
nshuff = 0;

% Load data, filter
if strcmp(Loc,'S')==1
    PNo = {'101','104','106','107','108','110','112','114','115','116','117','118','119','120','121','122','123','127'}; % Singapore (excl 218 and 221 (all/most artifact),127)
elseif strcmp(Loc,'C')==1
    PNo = {'101','102','103','104','105','106','107','108','109','111','112','114','116','117','118','119','121','122','123','124','125','126','127','128','129','131','132','133','135'}; % Cambridge
end
number_of_cond=3;
number_of_block=3;
number_of_phrase=3;

onset_startpoint=cell(length(PNo),number_of_cond,number_of_block,number_of_phrase);
onset_endpoint=cell(length(PNo),number_of_cond,number_of_block,number_of_phrase);
onset_number=cell(length(PNo),number_of_cond,number_of_block,number_of_phrase);
onset_duration=cell(length(PNo),number_of_cond,number_of_block,number_of_phrase);
for p = 1:length(PNo)
    iEEG=[];
    aEEG=[];
    filename = strcat(filepath,'/P',PNo{p},Loc,'/','P',PNo{p},Loc,'_BABBLE_attend.mat');
    load(filename,'FamEEGattend','StimEEGattend')

    % Replace bad sections with 1000 and merge infant and adult matrices
    for block = 1:size(FamEEGattend,1)
        if isempty(FamEEGattend{block})==0
        for cond = 1:size(FamEEGattend{block},1)
            for phrase = 1:size(FamEEGattend{block},2)
                if isempty(FamEEGattend{block}{cond,phrase})==0 && size(FamEEGattend{block}{cond,phrase},1)>1
                for chan = 1:length(include)
                    iEEG{block}{cond,phrase}(:,chan) = FamEEGattend{block}{cond,phrase}(:,include(chan));
                    aEEG{block}{cond,phrase}(:,chan) = StimEEGattend{block}{cond,phrase}(:,include(chan));
%  iEEG{block}{cond,phrase}(:,chan)=randn(size(FamEEGart{block}{cond,phrase}(:,include(chan))));
%  aEEG{block}{cond,phrase}(:,chan)=randn(size(StimEEGart{block}{cond,phrase}(:,include(chan)))); 
                    ind = find(FamEEGattend{block}{cond,phrase}(:,chan) == 777 | FamEEGattend{block}{cond,phrase}(:,chan) == 888 | FamEEGattend{block}{cond,phrase}(:,chan) == 999);
                    if length(ind)>0
                        iEEG{block}{cond,phrase}(ind,chan) = 1000;
                        aEEG{block}{cond,phrase}(ind,chan) = 1000;
                    end
                    clear ind
                end
                end
            end
        end
        else
            iEEG{block} = [];
            aEEG{block} = [];
        end
    end

    for block = 1:size(FamEEGattend,1)
        for cond = 1:size(FamEEGattend{block},1)
            for phrase = 1:size(FamEEGattend{block},2)
                EEG{block,1}{cond,phrase} = horzcat(aEEG{block}{cond,phrase},iEEG{block}{cond,phrase});
            end
        end
    end

clear aEEG iEEG FamEEGattend StimEEGattend

    iEEG=[];
    aEEG=[];
    filename = strcat(filepath,'/P',PNo{p},Loc,'/','P',PNo{p},Loc,'_BABBLE_PP.mat');
    load(filename,'FamEEGfil','StimEEGfil')    

    % Replace bad sections with 1000 and merge infant and adult matrices
    for block = 1:size(FamEEGfil,1)
        if isempty(FamEEGfil{block})==0
        for cond = 1:size(FamEEGfil{block},1)
            for phrase = 1:size(FamEEGfil{block},2)
                if isempty(FamEEGfil{block}{cond,phrase})==0 && size(FamEEGfil{block}{cond,phrase},1)>1
                for chan = 1:length(include)
                    iEEG{block}{cond,phrase}(:,chan) = FamEEGfil{block}{cond,phrase}(:,include(chan));
                    aEEG{block}{cond,phrase}(:,chan) = StimEEGfil{block}{cond,phrase}(:,include(chan));
%  iEEG{block}{cond,phrase}(:,chan)=randn(size(FamEEGart{block}{cond,phrase}(:,include(chan))));
%  aEEG{block}{cond,phrase}(:,chan)=randn(size(StimEEGart{block}{cond,phrase}(:,include(chan)))); 
                    ind = find(FamEEGfil{block}{cond,phrase}(:,chan) == 777 | FamEEGfil{block}{cond,phrase}(:,chan) == 888 | FamEEGfil{block}{cond,phrase}(:,chan) == 999);
                    if length(ind)>0
                        iEEG{block}{cond,phrase}(ind,chan) = 1000;
                        aEEG{block}{cond,phrase}(ind,chan) = 1000;
                    end
                    clear ind
                end
                end
            end
        end
        else
            iEEG{block} = [];
            aEEG{block} = [];
        end
    end
    
    for block = 1:size(FamEEGfil,1)
        for cond = 1:size(FamEEGfil{block},1)
            for phrase = 1:size(FamEEGfil{block},2)
                EEG2{block,1}{cond,phrase} = horzcat(aEEG{block}{cond,phrase},iEEG{block}{cond,phrase});
            end
        end
    end

clear aEEG iEEG FamEEGfil FamEEGfil

   PNo(p)
    % find and save the onset of non-nan value
    for block = 1:size(EEG,1)
        if isempty(EEG{block})==0
            for cond = 1:size(EEG{block},1) 
                for phrase = 1:size(EEG{block},2)              
                    if isempty(EEG{block}{cond,phrase})==0 && size(EEG{block}{cond,phrase},1)>1
                        [a,b]=find(isnan(EEG{block}{cond,phrase})==0);
                        if isempty(b)==0
                            temp=EEG{block}{cond,phrase}(:,b(1));
                            nan_idx = isnan(temp);
                            segment_start_idx = find(diff([0; nan_idx]) == -1);
                            segment_end_idx = find(diff([nan_idx; 0]) == 1);
                            if isnan(EEG{block}{cond,phrase}(1,b(1)))==0
                                segment_start_idx=[1;segment_start_idx];
                            end
                            if isnan(EEG{block}{cond,phrase}(size(EEG{block}{cond,phrase},1),b(1)))==0
                                segment_end_idx=[segment_end_idx;size(EEG{block}{cond,phrase},1)];
                            end
                            segment_length = segment_end_idx - segment_start_idx + 1;    
                        else
                            segment_start_idx=1;
                        end

% this is just for verifying the intact of EEG_raw---------------------
                        [a,b]=find(isnan(EEG2{block}{cond,phrase})==0);
                        if isempty(b)==0
                            temp=EEG2{block}{cond,phrase}(:,b(1));
                            nan_idx = isnan(temp);
                            segment_start_idx2 = find(diff([0; nan_idx]) == -1);
                            if isnan(EEG2{block}{cond,phrase}(1,b(1)))==0
                                segment_start_idx2=[1;segment_start_idx2];
                            end

                        else
                            segment_start_idx2=1;
                        end
%---------------------------------------------------------------------- 
                        if segment_start_idx2==1
                        onset_startpoint{p,cond,block,phrase}=segment_start_idx;
                        onset_endpoint{p,cond,block,phrase}=segment_end_idx;
                        onset_number{p,cond,block,phrase}=length(segment_start_idx);
                        onset_duration{p,cond,block,phrase}=segment_length;

                        plot(EEG{block}{cond,phrase}(:,4))
                        else
                            fprintf([num2str(p),num2str(block),num2str(cond),num2str(phrase)]);
                        end
                    else
                        onset_startpoint{p,cond,block,phrase}=[];
                        onset_number{p,cond,block,phrase}=[];
                        onset_duration{p,cond,block,phrase}=[];
                    end
                end
            end
    end


    end
    clear EEG EEG2
    p
end

%% comment by R1 - Commented out to prevent overwriting existing data files
% save('gazesg.mat')
%save('gazeuk.mat')

% 
% %% need to switch between Camb and SG, and mannually copy the combined results to the excel
% if Loc=='S'
%     gaze={};
%     [a,b]=xlsread('F:/infanteeg/CAM BABBLE EEG DATA/2024/table/gaze.xlsx');
%     for i=1:length(a)
%         if a(i,4)==2 && ismember(num2str(a(i,1)),PNo)==1
%             subj_label=[];
%             for subj=1:length(PNo)
%                 if isequal(PNo{subj},num2str(a(i,1)))==1
%                     subj_label=subj;
%                     break
%                 end
%             end
%             cond_label=a(i,5)+2*a(i,6)+3*a(i,7);
%             for b=1:3
%                 for ph=1:3
%                     gaze{i,(b-1)*12+(ph-1)*4+1}=onset_number{subj_label,cond_label,b,ph};
%                     gaze{i,(b-1)*12+(ph-1)*4+2}=onset_startpoint{subj_label,cond_label,b,ph};
%                     gaze{i,(b-1)*12+(ph-1)*4+3}=onset_endpoint{subj_label,cond_label,b,ph};
%                     gaze{i,(b-1)*12+(ph-1)*4+4}=onset_duration{subj_label,cond_label,b,ph};
% 
%         end
%             end
%         end
%     end
% end
% 
% if Loc=='C'
%      [a,b]=xlsread('F:/infanteeg/CAM BABBLE EEG DATA/2024/table/gaze.xlsx');
%     for i=1:length(a)
%         if a(i,4)==1 && ismember(num2str(a(i,1)),PNo)==1
%             subj_label=[];
%             for subj=1:length(PNo)
%                 if isequal(PNo{subj},num2str(a(i,1)))==1
%                     subj_label=subj;
%                     break
%                 end
%             end
%             cond_label=a(i,5)+2*a(i,6)+3*a(i,7);
%             for b=1:3
%                 for ph=1:3
%                     gaze{i,(b-1)*12+(ph-1)*4+1}=onset_number{subj_label,cond_label,b,ph};
%                     gaze{i,(b-1)*12+(ph-1)*4+2}=onset_startpoint{subj_label,cond_label,b,ph};
%                     gaze{i,(b-1)*12+(ph-1)*4+3}=onset_endpoint{subj_label,cond_label,b,ph};
%                     gaze{i,(b-1)*12+(ph-1)*4+4}=onset_duration{subj_label,cond_label,b,ph};
%         end
%             end
%         end
%     end
% end
% 
% 
% 
% % calculate total gaze onset in this condition
% load('F:/infanteeg/CAM BABBLE EEG DATA/2024/code/gaze.mat');
% number=gaze(:,[1:4:33]);
% n=zeros(size(number,1),1);
% for i=1:size(number,1)
%     for j=1:size(number,2)
%         if isempty(number{i,j})==0
% n(i)=n(i)+number{i,j};
%     end
%     end
% end
% 
% % 	mean gaze segment duration	% Std of segment duration
% 
% number=gaze(:,[4:4:36]);
% n=cell(size(number,1),1);
% for i=1:size(number,1)
%     for j=1:size(number,2)
%         if isempty(number{i,j})==0
% n{i}=[n{i};number{i,j}];
%     end
%     end
% end
% 
% 
% 
% for i = 1:size(number, 1)
%     m(i,1) = mean(n{i});
%     s(i,1) = std(n{i});
%     med(i,1) = median(n{i}); % Calculating median value
% end
