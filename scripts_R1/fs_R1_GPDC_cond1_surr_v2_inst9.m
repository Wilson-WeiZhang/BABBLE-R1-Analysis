%% ========================================================================
%  fs_R1_GPDC_cond1_surr_v2.m - Refactored Version
%  ========================================================================
%
%  PURPOSE:
%  Generate surrogate GPDC data for condition 1 ONLY
%  Structure follows fs3_makesurr3_nonor.m
%
%  LOOP STRUCTURE (Same as original fs3):
%  1. Pre-load all participant data (datauk, datasg)
%  2. for epoc = missing_surrogate_ids (parfor)
%       clearvars -except datauk datasg epoc basepath ...
%       for location = [UK, SG]
%           for participant
%               Extract data from pre-loaded datauk/datasg
%               Build windowlist FOR COND=1 ONLY
%               Shuffle windowlist
%               Compute GPDC
%               Save
%           end
%       end
%     end
%
%  DIFFERENCES FROM ORIGINAL fs3:
%  - Only processes cond=1 data
%  - Uses parfor for parallel computation
%  - Auto-detects existing surrogates
%  - Target: 1000 surrogates
%
%  ========================================================================

clc
clear all

fprintf('==========================================================\n');
fprintf('fs_R1_GPDC_cond1_surr_v2: Refactored Structure\n');
fprintf('==========================================================\n\n');

%% Configuration
basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';

% Target number of surrogates
num_surrogates = 1000;
fprintf('Target: %d total surrogate datasets\n', num_surrogates);

% Auto-detect existing surrogate folders
surr_base_path = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDC_cond1_SET/'];
existing_surr = [];
fprintf('Detecting existing surrogates...\n');
for i = 1:num_surrogates
    if exist([surr_base_path, 'GPDC', num2str(i)], 'dir')
        files = dir(fullfile([surr_base_path, 'GPDC', num2str(i)], '*.mat'));
        if length(files) >= 42  % Should have 42 participants
            existing_surr = [existing_surr, i];
        end
    end
end

% Find missing surrogates
all_surr = 1:num_surrogates;
missing_surr = setdiff(all_surr, existing_surr);

% RANGE FILTER FOR PARALLEL INSTANCES (modify these for each instance)
RANGE_START = 802;   % Change this
RANGE_END = 901;   % Change this
missing_surr = missing_surr(missing_surr >= RANGE_START & missing_surr <= RANGE_END);

fprintf('Existing surrogates: %d\n', length(existing_surr));
fprintf('Range filter: %d-%d\n', RANGE_START, RANGE_END);
fprintf('Missing surrogates in range: %d\n', length(missing_surr));
fprintf('Using regular for loop\n\n');

if isempty(missing_surr)
    fprintf('All %d surrogates already exist! Exiting.\n', num_surrogates);
    return;
end

%% PRE-LOAD ALL DATA (ONCE)
fprintf('========== PRE-LOADING ALL PARTICIPANT DATA ==========\n');
fprintf('This is done ONCE before surrogate loop\n\n');

% Load Singapore data
fprintf('Loading Singapore data...\n');
Loc = 'S';
filepath_sg = [basepath, 'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_sg/'];
PNo_sg = {'101','104','106','107','108','110','114','115','116','117','120','121','122','123','127'};
datasg = struct();
for p = 1:length(PNo_sg)
    filename = strcat(filepath_sg, '/P', PNo_sg{p}, Loc, '/', 'P', PNo_sg{p}, Loc, '_BABBLE_AR.mat');
    loadedData = load(filename, 'FamEEGart', 'StimEEGart');
    datasg(p).FamEEGart = loadedData.FamEEGart;
    datasg(p).StimEEGart = loadedData.StimEEGart;
    fprintf('  SG %s loaded\n', PNo_sg{p});
end

% Load Cambridge data
fprintf('Loading Cambridge data...\n');
Loc = 'C';
filepath_uk = [basepath, 'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_camb/'];
PNo_uk = {'101','102','103','104','105','106','107','108','109','111','114','117','118','119','121','122','123','124','125','126','127','128','129','131','132','133','135'};
datauk = struct();
for p = 1:length(PNo_uk)
    filename = strcat(filepath_uk, '/P', PNo_uk{p}, Loc, '/', 'P', PNo_uk{p}, Loc, '_BABBLE_AR.mat');
    loadedData = load(filename, 'FamEEGart', 'StimEEGart');
    datauk(p).FamEEGart = loadedData.FamEEGart;
    datauk(p).StimEEGart = loadedData.StimEEGart;
    fprintf('  UK %s loaded\n', PNo_uk{p});
end

fprintf('\nData loading completed!\n');
fprintf('  UK participants: %d\n', length(PNo_uk));
fprintf('  SG participants: %d\n', length(PNo_sg));
fprintf('==========================================================\n\n');

%% MAIN SURROGATE LOOP
fprintf('========== STARTING SURROGATE GENERATION ==========\n');
fprintf('Using regular for loop (testing version)\n');
fprintf('Missing surrogates to generate: %d\n\n', length(missing_surr));

for epoc = missing_surr
    fprintf('Surrogate iteration %d/%d...\n', epoc, num_surrogates);

    % Create output directory
    output_surr = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDC_cond1_SET/GPDC', num2str(epoc), '/'];
    if ~exist(output_surr, 'dir')
        mkdir(output_surr);
    end

    % Configuration (must be inside parfor)
    Montage = 'GRID';
    include = [4:6,15:17,26:28]';
    chLabel = {'F3','Fz','F4','C3','Cz','C4','P3','Pz','P4'};

    MO = 7;
    idMode = 7;
    NSamp = 200;
    len = 1.5;
    shift = 0.5*len*NSamp;
    wlen = len*NSamp;
    nfft = 256;

    bands = {[4:8], [9:16], [17:24]};

    % Process both locations
    for loci = 1:2
        if loci == 1
            PNo = PNo_uk;
            data_source = datauk;
            Loc = 'C';
        else
            PNo = PNo_sg;
            data_source = datasg;
            Loc = 'S';
        end

        % Process each participant
        for p = 1:length(PNo)
            % Extract pre-loaded data
            FamEEGart = data_source(p).FamEEGart;
            StimEEGart = data_source(p).StimEEGart;

            % Replace bad sections and merge infant/adult
            iEEG = cell(size(FamEEGart,1),1);
            aEEG = cell(size(FamEEGart,1),1);

            for block = 1:size(FamEEGart,1)
                if ~isempty(FamEEGart{block})
                    iEEG{block} = cell(1, size(FamEEGart{block},2));
                    aEEG{block} = cell(1, size(FamEEGart{block},2));

                    cond = 1;  % ONLY COND=1
                    for phrase = 1:size(FamEEGart{block},2)
                        if ~isempty(FamEEGart{block}{cond,phrase}) && size(FamEEGart{block}{cond,phrase},1)>1
                            for chan = 1:length(include)
                                iEEG{block}{cond,phrase}(:,chan) = FamEEGart{block}{cond,phrase}(:,include(chan));
                                aEEG{block}{cond,phrase}(:,chan) = StimEEGart{block}{cond,phrase}(:,include(chan));

                                ind = find(FamEEGart{block}{cond,phrase}(:,chan) == 777 | ...
                                           FamEEGart{block}{cond,phrase}(:,chan) == 888 | ...
                                           FamEEGart{block}{cond,phrase}(:,chan) == 999);
                                if ~isempty(ind)
                                    iEEG{block}{cond,phrase}(ind,chan) = 1000;
                                    aEEG{block}{cond,phrase}(ind,chan) = 1000;
                                end
                            end
                        end
                    end
                end
            end

            % Build windowlist FOR COND=1 ONLY
            windowlist = cell(size(FamEEGart,1), 1, size(FamEEGart{1},2), 1);

            for block = 1:size(FamEEGart,1)
                if ~isempty(FamEEGart{block})
                    cond = 1;
                    for phrase = 1:size(FamEEGart{block},2)
                        if ~isempty(iEEG{block}{cond,phrase}) && size(iEEG{block}{cond,phrase},1)>1
                            nwin = floor((size(iEEG{block}{cond,phrase},1) - wlen) / shift) + 1;

                            for w = 1:nwin
                                tmp_i = iEEG{block}{cond,phrase}((w-1)*shift+1:(w-1)*shift+wlen, :);
                                tmp_a = aEEG{block}{cond,phrase}((w-1)*shift+1:(w-1)*shift+wlen, :);

                                if sum(tmp_i(:) == 1000) == 0 && sum(isnan(tmp_i(:))) == 0
                                    windowlist{block, cond, phrase, w} = [tmp_a, tmp_i];
                                end
                            end
                        end
                    end
                end
            end

            % SHUFFLE windowlist (per-channel shuffling)
            % Collect non-empty positions
            non_empty_positions = [];
            for i = 1:size(windowlist,1)
                for k = 1:size(windowlist,3)
                    for l = 1:size(windowlist,4)
                        if ~isempty(windowlist{i,1,k,l}) && isequal(size(windowlist{i,1,k,l}), [300, 18])
                            non_empty_positions = [non_empty_positions; [i,1,k,l]];
                        end
                    end
                end
            end

            num_non_empty_positions = size(non_empty_positions, 1);

            if num_non_empty_positions > 0
                num_iterations = 18;  % 18 channels
                random_orders = cell(1, num_iterations);

                for i = 1:num_iterations
                    random_orders{i} = randperm(num_non_empty_positions);
                end

                temp_windowlist = windowlist;

                for idx = 1:num_non_empty_positions
                    current_pos = non_empty_positions(idx,:);
                    temp = [];
                    for i = 1:num_iterations
                        temporder = random_orders{i};
                        random_positions = non_empty_positions(temporder(idx), :);
                        shuffled_window = windowlist{random_positions(1),random_positions(2),random_positions(3),random_positions(4)};
                        temp = [temp, shuffled_window(:,i)];
                    end
                    temp_windowlist{current_pos(1),current_pos(2),current_pos(3),current_pos(4)} = temp;
                end

                windowlist = temp_windowlist;
            end

            % Compute GPDC on shuffled windowlist
            GPDC_s = cell(size(FamEEGart,1), 1);
            cond = 1;

            for block = 1:size(windowlist,1)
                % Check if this block has valid cond=1 data
                has_data = false;
                for phrase = 1:size(windowlist,3)
                    for w = 1:size(windowlist,4)
                        if ~isempty(windowlist{block,cond,phrase,w})
                            has_data = true;
                            break;
                        end
                    end
                    if has_data, break; end
                end

                if has_data
                    GPDC_s{block} = cell(1, size(windowlist,3));
                    for phrase = 1:size(windowlist,3)
                        for w = 1:size(windowlist,4)
                            if ~isempty(windowlist{block,cond,phrase,w})
                                tmp = windowlist{block,cond,phrase,w};
                                mytmp1 = tmp';
                                [eAm, eSu, Yp, Up] = idMVAR(mytmp1, MO, idMode);
                                try
                                    [~, ~, ~, GPDC_s{block}{cond,phrase}(:,:,:,w), ~, ~, ~, h, s, pp, f] = fdMVAR(eAm, eSu, nfft, NSamp);
                                catch
                                    GPDC_s{block}{cond,phrase}(:,:,:,w) = NaN(length(include)*2, length(include)*2, nfft);
                                end
                            end
                        end
                    end
                end
            end

            % Average GPDC over windows
            avGPDC_s = cell(size(FamEEGart,1), 1);
            for block = 1:size(GPDC_s,1)
                if ~isempty(GPDC_s{block})
                    avGPDC_s{block} = cell(1, size(windowlist,3));
                    for phrase = 1:size(windowlist,3)
                        if ~isempty(GPDC_s{block}{cond,phrase}) && length(GPDC_s{block}{cond,phrase}) > 1
                            for i = 1:2*length(include)
                                for j = 1:2*length(include)
                                    tmp2(i,j,:) = nanmean(abs(GPDC_s{block}{cond,phrase}(i,j,:,:)).^2, 4);
                                end
                            end
                            avGPDC_s{block}{cond,phrase} = tmp2;
                            clear tmp2
                        end
                    end
                end
            end

            % Partition GPDC into AA, II, AI, IA
            II_s = {}; AA_s = {}; AI_s = {}; IA_s = {};

            for block = 1:size(avGPDC_s,1)
                if ~isempty(avGPDC_s{block})
                    for phase = 1:size(avGPDC_s{block},2)
                        if ~isempty(avGPDC_s{block}{cond,phase}) && nansum(nansum(nansum(avGPDC_s{block}{cond,phase}))) ~= 0
                            tmp = avGPDC_s{block}{cond,phase};
                            GPDC_AA = tmp(1:length(include), 1:length(include), :);
                            GPDC_IA = tmp(1:length(include), length(include)+1:length(include)*2, :);
                            GPDC_AI = tmp(length(include)+1:length(include)*2, 1:length(include), :);
                            GPDC_II = tmp(length(include)+1:length(include)*2, length(include)+1:length(include)*2, :);

                            for fplot = 1:length(bands)
                                tmp1g = squeeze(nanmean(GPDC_II(:,:,bands{fplot}), 3));
                                tmp2g = squeeze(nanmean(GPDC_AA(:,:,bands{fplot}), 3));
                                tmp3g = squeeze(nanmean(GPDC_AI(:,:,bands{fplot}), 3));
                                tmp4g = squeeze(nanmean(GPDC_IA(:,:,bands{fplot}), 3));

                                II_s{block, cond, fplot, phase} = tmp1g;
                                AA_s{block, cond, fplot, phase} = tmp2g;
                                AI_s{block, cond, fplot, phase} = tmp3g;
                                IA_s{block, cond, fplot, phase} = tmp4g;
                            end
                        end
                    end
                end
            end

            % Average across phrases
            II_final_s = {}; AA_final_s = {}; AI_final_s = {}; IA_final_s = {};

            for block = 1:size(avGPDC_s,1)
                if ~isempty(avGPDC_s{block})
                    for fplot = 1:length(bands)
                        tmp1All = []; tmp2All = []; tmp3All = []; tmp4All = [];
                        count = 0;

                        for phase = 1:size(avGPDC_s{block},2)
                            if ~isempty(II_s) && size(II_s,1) >= block && size(II_s,2) >= cond && ...
                                    size(II_s,3) >= fplot && size(II_s,4) >= phase
                                if ~isempty(II_s{block,cond,fplot,phase})
                                    if isempty(tmp1All)
                                        tmp1All = zeros(size(II_s{block,cond,fplot,phase}));
                                        tmp2All = zeros(size(AA_s{block,cond,fplot,phase}));
                                        tmp3All = zeros(size(AI_s{block,cond,fplot,phase}));
                                        tmp4All = zeros(size(IA_s{block,cond,fplot,phase}));
                                    end
                                    tmp1All = tmp1All + II_s{block,cond,fplot,phase};
                                    tmp2All = tmp2All + AA_s{block,cond,fplot,phase};
                                    tmp3All = tmp3All + AI_s{block,cond,fplot,phase};
                                    tmp4All = tmp4All + IA_s{block,cond,fplot,phase};
                                    count = count + 1;
                                end
                            end
                        end

                        if count > 0
                            II_final_s{block, cond, fplot} = tmp1All / count;
                            AA_final_s{block, cond, fplot} = tmp2All / count;
                            AI_final_s{block, cond, fplot} = tmp3All / count;
                            IA_final_s{block, cond, fplot} = tmp4All / count;
                        end
                    end
                end
            end

            % Rename for saving
            II = II_final_s;
            AA = AA_final_s;
            AI = AI_final_s;
            IA = IA_final_s;

            % Save
            if loci == 1
                save(fullfile(output_surr, sprintf('UK_%s_GPDC.mat', PNo{p})), 'II', 'AI', 'AA', 'IA');
            else
                save(fullfile(output_surr, sprintf('SG_%s_GPDC.mat', PNo{p})), 'II', 'AI', 'AA', 'IA');
            end
        end
    end
end

fprintf('==========================================================\n');
fprintf('Surrogate data generation completed!\n');
fprintf('Generated %d missing surrogates\n', length(missing_surr));
fprintf('Output saved to: %ssurrGPDC_cond1_SET/\n', [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/']);
fprintf('==========================================================\n\n');
