%% ========================================================================
%  STEP 0: EEG Data Quality Control - Calculate Rejection Ratios
%  ========================================================================
%
%  PURPOSE:
%  Calculate EEG data retention and rejection ratios for quality control
%  analysis. This script quantifies how much EEG data was retained after
%  different preprocessing steps.
%
%  CORRESPONDS TO MANUSCRIPT:
%  - Methods Section 4.3.1 (EEG acquisition and preprocessing)
%  - Supplementary Materials Section 12 (EEG data retention)
%  - Supplementary Table S7 (breakdown of EEG data retention)
%
%  KEY OUTPUTS:
%  - Mean attended data: 36.4% (SD = 17.1%) across all participants
%  - Mean retained after artifact rejection: 32.9% (SD = 15.6%)
%  - UK dataset: 28.2% attended (SD = 13.8%)
%  - SG dataset: 51.3% attended (SD = 11.8%), t(40) = -5.5, p < .0001
%  - Automated rejection: 8.3% of attended epochs rejected
%  - No significant difference in rejection ratios across gaze conditions
%
%  DATA CODING:
%  777 = unattended segments (infant looking away from screen)
%  999 = automatic artifact rejection (±150 μV threshold)
%  888 = manual artifact rejection (visual inspection)
%
%  ANALYSIS STEPS:
%  1. Load preprocessed EEG data from UK (Cambridge) and SG (Singapore)
%  2. Count valid vs rejected time points across conditions
%  3. Calculate retention ratios at each preprocessing stage
%  4. Compare rejection ratios across gaze conditions (ANOVA)
%  5. Generate statistics for Supplementary Table S7
%
%  ========================================================================

%% calculate eeg rejection ratio, 777 = unattend, 999= auto rej 888=manual rej

path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'
%path='C:\Users\Admin\OneDrive - Nanyang Technological University\'
Loc='S';
filepath = [path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_sg/'];
% PNo = {'101','104','106','107','108','110','112','114','115','116','117','118','119','120','121','122','123','127'}; % Singapore (excl 218 and 221 (all/most artifact),127)
PNo = {'101','104','106','107','108','110','114','115','116','117','120','121','122','123','127'}; % Singapore (excl 218 and 221 (all/most artifact),127)
% PNo = {'116'};
datasg = struct();
for p = 1:length(PNo)
    filename = strcat(filepath, '/P', PNo{p}, Loc, '/', 'P', PNo{p}, Loc, '_BABBLE_AR.mat');
    loadedData = load(filename, 'FamEEGart', 'StimEEGart');
    datasg(p).FamEEGart = loadedData.FamEEGart;
    datasg(p).StimEEGart = loadedData.StimEEGart;

end

Loc='C';
filepath = [path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_camb/'];
% PNo = {'101','102','103','104','105','106','107','108','109','111','112','114','116','117','118','119','121','122','123','124','125','126','127','128','129','131','132','133','135'};
% PNo = {'101','102','104','105','106','107','109','111','114','116','117','118','119','122','123','124','125','126','127','128','132','133'};
PNo = {'101','102','103','104','105','106','107','108','109','111','114','117','118','119','121','122','123','124','125','126','127','128','129','131','132','133','135'};
% PNo = {'103','108','128','129','131','135'};

datauk = struct();
for p = 1:length(PNo)
    filename = strcat(filepath, '/P', PNo{p}, Loc, '/', 'P', PNo{p}, Loc, '_BABBLE_AR.mat');
    loadedData = load(filename, 'FamEEGart', 'StimEEGart');
    datauk(p).FamEEGart = loadedData.FamEEGart;
    datauk(p).StimEEGart = loadedData.StimEEGart;
end


typelist={'DC','DTF','PDC','GPDC','COH','PCOH'}
loclist={'C','S'}
for loci=1:2
    eegcount=[];
    for type=4:4

        clearvars -except loci type typelist loclist epoc datauk datasg resultuk totaluk eegcount_uk
        Loc = loclist{loci}; % C for Cambridge, S for Singapore
        Montage = 'GRID';
        freqs = [9,17,24,32]; % 3, 6.25, 9, 12.1 Hz for nfft = 256

        % Wilson: specify filepath
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
        elseif strcmp(Montage,'all')==1
            include = [4:6,10,11,15:17,20:23,26:28]'; % included 9-channel grid FA3, CM3, PR3
            chLabel = {'F3','Fz','F4','FC1','FC2','C3','Cz','C4','CP5','CP1','CP2','CP6','P3','Pz','P4'};
        end

        % Model Parameters
        % 7 for 300 for beta Alpha
        MO = 7; % Use Model Order = 5 or 8 for 200 samples, max order is number of data points in window. Default = 9 for 3s epoc, 7 for 1.5s epoc, 5 for 1s epoc
        idMode = 7; % MVAR method. Default use 0 = least squares or 7 = Nuttall-Strand unbiased partial correlation
        NSamp = 200;
        len = [1.5]; % 1s, 1.5s or 3s (default 1.5s)
        shift = 0.5*len*NSamp; % overlap between windows (default 0.5)
        wlen = len*NSamp;
        nfft = 256; % 2^(nextpow2(wlen)-1);
        nshuff = 0;

        % Load data, filter and compute GPDC
        if strcmp(Loc,'S')==1
            %     PNo = {'101','104','106','107','108','110','112','114','115','215','116','117','118','119','120','121','122','123','127'}; % Singapore (excl 218 and 221 (all/most artifact),127)
            PNo = {'101','104','106','107','108','110','114','115','116','117','120','121','122','123','127'}; % Singapore (excl 218 and 221 (all/most artifact),127)
            % PNo = {'116'};
        elseif strcmp(Loc,'C')==1
            PNo = {'101','102','103','104','105','106','107','108','109','111','114','117','118','119','121','122','123','124','125','126','127','128','129','131','132','133','135'};
        end


        for p = 1:length(PNo)
            if loci==1
                % filename = strcat(filepath,'/P',PNo{p},Loc,'/','P',PNo{p},Loc,'_BABBLE_AR.mat');
                FamEEGart=datauk(p).FamEEGart;
                StimEEGart=datauk(p).StimEEGart;
            else
                FamEEGart=datasg(p).FamEEGart;
                StimEEGart=datasg(p).StimEEGart;
            end
            % Replace bad sections with 1000 and merge infant and adult matrices
            for block = 1:size(FamEEGart,1)
                if isempty(FamEEGart{block})==0
                    for cond = 1:size(FamEEGart{block},1)
                        for phrase = 1:size(FamEEGart{block},2)
                            if isempty(FamEEGart{block}{cond,phrase})==0 && size(FamEEGart{block}{cond,phrase},1)>1
                                for chan = 1:length(include)
                                    iEEG{block}{cond,phrase}(:,chan) = FamEEGart{block}{cond,phrase}(:,include(chan));
                                    aEEG{block}{cond,phrase}(:,chan) = StimEEGart{block}{cond,phrase}(:,include(chan));
                                    %                     Wilson: can surrogate data here from the begining.
                                    % iEEG{block}{cond,phrase}(:,chan) = randn(size(FamEEGart{block}{cond,phrase}(:,include(chan))));
                                    % aEEG{block}{cond,phrase}(:,chan) = randn(size(StimEEGart{block}{cond,phrase}(:,include(chan))));
                                    %ind = find(FamEEGart{block}{cond,phrase}(:,chan) == 777 | FamEEGart{block}{cond,phrase}(:,chan) == 888 | FamEEGart{block}{cond,phrase}(:,chan) == 999);
                                    % if length(ind)>0
                                    %     iEEG{block}{cond,phrase}(ind,chan) = 1000;
                                    %     aEEG{block}{cond,phrase}(ind,chan) = 1000;
                                    % end
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

            for block = 1:size(FamEEGart,1)
                for cond = 1:size(FamEEGart{block},1)
                    for phrase = 1:size(FamEEGart{block},2)
                        temp =iEEG{block}{cond,phrase};
                        eegcount(p,block,cond,phrase,1)=length(find(abs(temp)<700));
                        eegcount(p,block,cond,phrase,2)=length(find(temp==777));
                        eegcount(p,block,cond,phrase,3)=length(find(temp==999));
                        eegcount(p,block,cond,phrase,4)=length(find(temp==888));
                        eegcount(p,block,cond,phrase,5)=length(find(isnan(temp)==1));
                    end
                end
            end
            clear FamEEGart StimEEGart iEEG aEEG EEG GPDC nwin nwinclude
        end


        if loci ==1
            eegcount_uk=eegcount;
            resultuk = zeros(p, 5);

            % Sum across dimensions 2, 3, and 4
            for i = 1:p
                for j = 1:5
                    resultuk(i,j) = sum(sum(sum(eegcount(i,:,:,:,j))));
                end
            end


       % For resultuk
resultuk = resultuk/200;
totaluk = sum(resultuk(:,:), 2);
[mean(totaluk), std(totaluk)]
[mean(totaluk-resultuk(:,2)), std(totaluk-resultuk(:,2))]
[mean(totaluk-resultuk(:,3)-resultuk(:,2)), std(totaluk-resultuk(:,3)-resultuk(:,2))]
[mean(totaluk-resultuk(:,4)-resultuk(:,3)-resultuk(:,2)), std(totaluk-resultuk(:,4)-resultuk(:,3)-resultuk(:,2))]

        else
            resultsg = zeros(p, 5);
eegcount_sg=eegcount;
            % Sum across dimensions 2, 3, and 4
            for i = 1:p
                for j = 1:5
                    resultsg(i,j) = sum(sum(sum(eegcount(i,:,:,:,j))));
                end
            end


resultsg = resultsg/200;
totalsg = sum(resultsg(:,:), 2);
[mean(totalsg), std(totalsg)]
[mean(totalsg-resultsg(:,2)), std(totalsg-resultsg(:,2))]
[mean(totalsg-resultsg(:,3)-resultsg(:,2)), std(totalsg-resultsg(:,3)-resultsg(:,2))]
[mean(totalsg-resultsg(:,4)-resultsg(:,3)-resultsg(:,2)), std(totalsg-resultsg(:,4)-resultsg(:,3)-resultsg(:,2))]
        end

    end
end

% Combine resultuk and resultsg into resultall
resultall = [resultuk; resultsg];

% Calculate total sum for each row
totalall = sum(resultall(:,:), 2);

% Calculate statistics
[mean(totalall), std(totalall)]
[mean(totalall-resultall(:,2)), std(totalall-resultall(:,2))]
[mean(totalall-resultall(:,3)-resultall(:,2)), std(totalall-resultall(:,3)-resultall(:,2))]
[mean(totalall-resultall(:,4)-resultall(:,3)-resultall(:,2)), std(totalall-resultall(:,4)-resultall(:,3)-resultall(:,2))]

%The average percentage of unattended data per infant across all familiarisation phases was 
[mean(resultall(:,2)./totalall),std(resultall(:,2)./totalall)]

%The mean percentage of unattended familiarisation was higher in the UK dataset
[mean(resultuk(:,2)./totaluk),std(resultuk(:,2)./totaluk)]

%The mean percentage of unattended familiarisation was higher in the SG dataset
[mean(resultsg(:,2)./totalsg),std(resultsg(:,2)./totalsg)]

[h,p,s,f]=ttest2(resultuk(:,2)./totaluk,resultsg(:,2)./totalsg)

%%The automated noise rejection (followed by visual inspection) resulted in rejecting an average 
% Calculate the ratio for combined data (all)
[mean(resultall(:,3)./(totalall-resultall(:,2))), std(resultall(:,3)./(totalall-resultall(:,2)))]

% Calculate the ratio for UK data
[mean(resultuk(:,3)./(totaluk-resultuk(:,2))), std(resultuk(:,3)./(totaluk-resultuk(:,2)))]

% Calculate the ratio for SG data
[mean(resultsg(:,3)./(totalsg-resultsg(:,2))), std(resultsg(:,3)./(totalsg-resultsg(:,2)))]

[h,p,s,f]=ttest2(resultuk(:,3)./(totaluk-resultuk(:,2)),resultsg(:,3)./(totalsg-resultsg(:,2)))

%%An average of 37.27% of the data were retained per infant after this first stage of manual rejection. 
[mean((totalall-resultall(:,2))./totalall),std((totalall-resultall(:,2))./totalall)]

%%In totality, this resulted in an average of 32.20% X% of data retained for analysis, see also 
[mean((totalall-resultall(:,4)-resultall(:,2)-resultall(:,3))./totalall),std((totalall-resultall(:,4)-resultall(:,2)-resultall(:,3))./totalall)]






%% table s4
%% row2
[mean((totaluk-resultuk(:,2))./totaluk),std((totaluk-resultuk(:,2))./totaluk)]
[mean((totalsg-resultsg(:,2))./totalsg),std((totalsg-resultsg(:,2))./totalsg)]
[mean((totalall-resultall(:,2))./totalall),std((totalall-resultall(:,2))./totalall)]

%row3
[mean((totaluk-resultuk(:,2)-resultuk(:,3))./totaluk),std((totaluk-resultuk(:,2)-resultuk(:,3))./totaluk)]
[mean((totalsg-resultsg(:,2)-resultsg(:,3))./totalsg),std((totalsg-resultsg(:,2)-resultsg(:,3))./totalsg)]
[mean((totalall-resultall(:,2)-resultall(:,3))./totalall),std((totalall-resultall(:,2)-resultall(:,3))./totalall)]


%row4
[mean((totaluk-resultuk(:,2)-resultuk(:,3)-resultuk(:,4))./totaluk),std((totaluk-resultuk(:,2)-resultuk(:,3)-resultuk(:,4))./totaluk)]
[mean((totalsg-resultsg(:,2)-resultsg(:,3)-resultsg(:,4))./totalsg),std((totalsg-resultsg(:,2)-resultsg(:,3)-resultsg(:,4))./totalsg)]
[mean((totalall-resultall(:,2)-resultall(:,3)-resultall(:,4))./totalall),std((totalall-resultall(:,2)-resultall(:,3)-resultall(:,4))./totalall)]

%%In totality, this resulted in an average of 32.20% X% of data retained for analysis, see also 
[mean((totalall-resultall(:,4)-resultall(:,2)-resultall(:,3))./totalall),std((totalall-resultall(:,4)-resultall(:,2)-resultall(:,3))./totalall)]




%% gaze cond compare
%% EEG Rejection Ratio ANOVA Analysis
% This script calculates the proportion of rejected time in EEG data
% across different experimental conditions and performs ANOVA testing

% Assuming eegcount_uk is an existing matrix with dimensions:
% [participants × blocks × conditions × phrases × time categories]
% Where time categories 1-5 represent:
%   1 = valid time
%   2,3,4 = different categories of rejected time
%   5 = other time
%   sum(1:5) = total time


data=eegcount_uk;
% Extract data for conditions 1, 2, and 3
conditions = [1, 2, 3];
num_conditions = length(conditions);

% Initialize arrays to store rejection ratios
% Get matrix dimensions (assuming p = participants)
[num_participants, num_blocks, ~, num_phrases, ~] = size(data);

% Initialize array to store rejection ratios for each participant and condition
rejection_ratios = zeros(num_participants, num_conditions);

% Calculate rejection ratios for each condition (aggregated across blocks and phrases)
for c_idx = 1:num_conditions
    cond = conditions(c_idx);
    
    for p_idx = 1:num_participants
        total_time = 0;
        rejected_time = 0;
        
        % Sum across all blocks and phrases
        for b = 1:num_blocks
            for ph = 1:num_phrases
                % Total time is sum of categories 1-5
                current_total = sum(data(p_idx, b, cond, ph, 1:5));
                total_time = total_time + current_total;
                
                % Rejected time is sum of categories 2-4
                current_rejected = sum(data(p_idx, b, cond, ph, 2:4));
                rejected_time = rejected_time + current_rejected;
            end
        end
        
        % Calculate rejection ratio (proportion of time rejected)
        if total_time > 0
            rejection_ratios(p_idx, c_idx) = rejected_time / total_time;
        else
            rejection_ratios(p_idx, c_idx) = NaN; % Handle division by zero
        end
    end
end

% Prepare data for ANOVA
% Reshape to a format suitable for anova1
[p, ~] = size(rejection_ratios);
anova_data = reshape(rejection_ratios, [], 1);
group_labels = repmat(1:num_conditions, p, 1);
group_labels = reshape(group_labels, [], 1);

% Remove NaN values if any
valid_idx = ~isnan(anova_data);
anova_data = anova_data(valid_idx);
group_labels = group_labels(valid_idx);

% Convert group labels to categorical variable with meaningful names
group_categories = categorical(group_labels, 1:num_conditions, {'Condition 1', 'Condition 2', 'Condition 3'});

% Perform one-way ANOVA
[p_value, tbl, stats] = anova1(anova_data, group_categories, 'off');

% Display the ANOVA table
disp('One-way ANOVA results for rejection ratios across conditions:');
disp(tbl);

% Display p-value with interpretation
fprintf('\nANOVA p-value: %.4f\n', p_value);
if p_value < 0.05
    fprintf('The proportion of rejected time differs significantly across conditions (p < 0.05).\n');
else
    fprintf('No significant difference in the proportion of rejected time across conditions (p ≥ 0.05).\n');
end

% Calculate descriptive statistics for each condition
condition_means = zeros(1, num_conditions);
condition_stds = zeros(1, num_conditions);

for c = 1:num_conditions
    condition_data = rejection_ratios(:, c);
    condition_means(c) = mean(condition_data, 'omitnan');
    condition_stds(c) = std(condition_data, 'omitnan');
end

% Display descriptive statistics
fprintf('\nDescriptive statistics for rejection ratios:\n');
fprintf('Condition 1: Mean = %.4f, SD = %.4f\n', condition_means(1), condition_stds(1));
fprintf('Condition 2: Mean = %.4f, SD = %.4f\n', condition_means(2), condition_stds(2));
fprintf('Condition 3: Mean = %.4f, SD = %.4f\n', condition_means(3), condition_stds(3));
