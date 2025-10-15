%% ========================================================================
%  fs_R1_GPDC_cond1_surr.m
%  ========================================================================
%
%  PURPOSE:
%  Generate surrogate GPDC data for condition 1 only using parallel computing
%
%  OPTIMIZATION:
%  - Pre-build windowlist for all participants ONCE before surrogate loop
%  - In surrogate loop, only shuffle windowlist and compute GPDC
%  - Much faster than rebuilding windowlist for each surrogate iteration
%
%  OUTPUT:
%  - Surrogate GPDC matrices saved to surrGPDC_cond1_SET/GPDC{n}/ folders
%
%  ========================================================================

clc
clear all

fprintf('==========================================================\n');
fprintf('STEP 3: Generating surrogate data for cond=1 only\n');
fprintf('==========================================================\n\n');

%% Configuration
basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';

% User configuration
num_surrogates = 1000;  % Total number of surrogates to generate
fprintf('Target: %d total surrogate datasets\n', num_surrogates);

% Auto-detect existing surrogate folders
surr_base_path = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDC_cond1_SET/'];
existing_surr = [];
for i = 1:num_surrogates
    if exist([surr_base_path, 'GPDC', num2str(i)], 'dir')
        existing_surr = [existing_surr, i];
    end
end

% Find missing surrogates
all_surr = 1:num_surrogates;
missing_surr = setdiff(all_surr, existing_surr);

fprintf('Existing surrogates: %d\n', length(existing_surr));
fprintf('Missing surrogates: %d\n', length(missing_surr));
fprintf('Using parfor for parallel computation\n\n');

% Analysis type
type = 'GPDC';

% Channel configuration
Montage = 'GRID';
include = [4:6, 15:17, 26:28]';
chLabel = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};

% Model Parameters
MO = 7;
idMode = 7;
NSamp = 200;
len = 1.5;
shift = 0.5 * len * NSamp;
wlen = len * NSamp;
nfft = 256;

% Frequency bands
bands = {[4:8], [9:16], [17:24]};

%% Load all data ONCE
fprintf('Loading EEG data...\n');

% Singapore data
Loc = 'S';
filepath_sg = [basepath, 'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_sg/'];
PNo_sg = {'101', '104', '106', '107', '108', '110', '114', '115', '116', '117', '120', '121', '122', '123', '127'};
datasg = struct();
for p = 1:length(PNo_sg)
    filename = strcat(filepath_sg, '/P', PNo_sg{p}, Loc, '/', 'P', PNo_sg{p}, Loc, '_BABBLE_AR.mat');
    loadedData = load(filename, 'FamEEGart', 'StimEEGart');
    datasg(p).FamEEGart = loadedData.FamEEGart;
    datasg(p).StimEEGart = loadedData.StimEEGart;
end

% Cambridge data
Loc = 'C';
filepath_uk = [basepath, 'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_camb/'];
PNo_uk = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '111', '114', '117', '118', '119', '121', '122', '123', '124', '125', '126', '127', '128', '129', '131', '132', '133', '135'};
datauk = struct();
for p = 1:length(PNo_uk)
    filename = strcat(filepath_uk, '/P', PNo_uk{p}, Loc, '/', 'P', PNo_uk{p}, Loc, '_BABBLE_AR.mat');
    loadedData = load(filename, 'FamEEGart', 'StimEEGart');
    datauk(p).FamEEGart = loadedData.FamEEGart;
    datauk(p).StimEEGart = loadedData.StimEEGart;
end

fprintf('Data loading completed!\n\n');

%% Pre-build windowlists for all participants (COND=1 ONLY)
fprintf('Building windowlists for all participants (cond=1 only)...\n');

windowlist_all_uk = cell(length(PNo_uk), 1);
FamEEGart_sizes_uk = cell(length(PNo_uk), 1);

for p = 1:length(PNo_uk)
    fprintf('  UK participant %d/%d...\n', p, length(PNo_uk));

    FamEEGart = datauk(p).FamEEGart;
    StimEEGart = datauk(p).StimEEGart;
    FamEEGart_sizes_uk{p} = size(FamEEGart, 1);

    % Extract and clean data (COND=1 ONLY)
    iEEG = cell(size(FamEEGart, 1), 1);
    aEEG = cell(size(FamEEGart, 1), 1);

    for block = 1:size(FamEEGart, 1)
        if ~isempty(FamEEGart{block})
            iEEG{block} = cell(1, size(FamEEGart{block}, 2));
            aEEG{block} = cell(1, size(FamEEGart{block}, 2));

            cond = 1;  % ONLY COND=1
            for phrase = 1:size(FamEEGart{block}, 2)
                if ~isempty(FamEEGart{block}{cond, phrase}) && size(FamEEGart{block}{cond, phrase}, 1) > 1
                    for chan = 1:length(include)
                        iEEG{block}{cond, phrase}(:, chan) = FamEEGart{block}{cond, phrase}(:, include(chan));
                        aEEG{block}{cond, phrase}(:, chan) = StimEEGart{block}{cond, phrase}(:, include(chan));

                        ind = find(FamEEGart{block}{cond, phrase}(:, chan) == 777 | ...
                                  FamEEGart{block}{cond, phrase}(:, chan) == 888 | ...
                                  FamEEGart{block}{cond, phrase}(:, chan) == 999);
                        if ~isempty(ind)
                            iEEG{block}{cond, phrase}(ind, chan) = 1000;
                            aEEG{block}{cond, phrase}(ind, chan) = 1000;
                        end
                    end
                end
            end
        end
    end

    % Concatenate adult and infant EEG
    EEG = cell(size(FamEEGart, 1), 1);
    for block = 1:size(FamEEGart, 1)
        if ~isempty(aEEG{block})
            EEG{block} = cell(1, size(FamEEGart{block}, 2));
            cond = 1;
            for phrase = 1:size(FamEEGart{block}, 2)
                if ~isempty(aEEG{block}{cond, phrase})
                    EEG{block}{cond, phrase} = horzcat(aEEG{block}{cond, phrase}, iEEG{block}{cond, phrase});
                end
            end
        end
    end

    % Collect windows
    windowlist = cell(3, 3, 3, 100);
    for block = 1:size(EEG, 1)
        if ~isempty(EEG{block})
            cond = 1;
            for phrase = 1:size(EEG{block}, 2)
                if ~isempty(EEG{block}{cond, phrase}) && size(EEG{block}{cond, phrase}, 1) > 1
                    nwin_count = floor((size(EEG{block}{cond, phrase}, 1) - wlen) / shift) + 1;

                    for w = 1:nwin_count
                        tmp = EEG{block}{cond, phrase}((w-1)*shift+1:(w-1)*shift+wlen, :);
                        if ~any(tmp(:) == 1000) && ~any(isnan(tmp(:)))
                            windowlist{block, cond, phrase, w} = tmp;
                        end
                    end
                end
            end
        end
    end

    windowlist_all_uk{p} = windowlist;
end

% Build windowlists for Singapore participants
windowlist_all_sg = cell(length(PNo_sg), 1);
FamEEGart_sizes_sg = cell(length(PNo_sg), 1);

for p = 1:length(PNo_sg)
    fprintf('  SG participant %d/%d...\n', p, length(PNo_sg));

    FamEEGart = datasg(p).FamEEGart;
    StimEEGart = datasg(p).StimEEGart;
    FamEEGart_sizes_sg{p} = size(FamEEGart, 1);

    % Extract and clean data (COND=1 ONLY)
    iEEG = cell(size(FamEEGart, 1), 1);
    aEEG = cell(size(FamEEGart, 1), 1);

    for block = 1:size(FamEEGart, 1)
        if ~isempty(FamEEGart{block})
            iEEG{block} = cell(1, size(FamEEGart{block}, 2));
            aEEG{block} = cell(1, size(FamEEGart{block}, 2));

            cond = 1;
            for phrase = 1:size(FamEEGart{block}, 2)
                if ~isempty(FamEEGart{block}{cond, phrase}) && size(FamEEGart{block}{cond, phrase}, 1) > 1
                    for chan = 1:length(include)
                        iEEG{block}{cond, phrase}(:, chan) = FamEEGart{block}{cond, phrase}(:, include(chan));
                        aEEG{block}{cond, phrase}(:, chan) = StimEEGart{block}{cond, phrase}(:, include(chan));

                        ind = find(FamEEGart{block}{cond, phrase}(:, chan) == 777 | ...
                                  FamEEGart{block}{cond, phrase}(:, chan) == 888 | ...
                                  FamEEGart{block}{cond, phrase}(:, chan) == 999);
                        if ~isempty(ind)
                            iEEG{block}{cond, phrase}(ind, chan) = 1000;
                            aEEG{block}{cond, phrase}(ind, chan) = 1000;
                        end
                    end
                end
            end
        end
    end

    % Concatenate
    EEG = cell(size(FamEEGart, 1), 1);
    for block = 1:size(FamEEGart, 1)
        if ~isempty(aEEG{block})
            EEG{block} = cell(1, size(FamEEGart{block}, 2));
            cond = 1;
            for phrase = 1:size(FamEEGart{block}, 2)
                if ~isempty(aEEG{block}{cond, phrase})
                    EEG{block}{cond, phrase} = horzcat(aEEG{block}{cond, phrase}, iEEG{block}{cond, phrase});
                end
            end
        end
    end

    % Collect windows
    windowlist = cell(3, 3, 3, 100);
    for block = 1:size(EEG, 1)
        if ~isempty(EEG{block})
            cond = 1;
            for phrase = 1:size(EEG{block}, 2)
                if ~isempty(EEG{block}{cond, phrase}) && size(EEG{block}{cond, phrase}, 1) > 1
                    nwin_count = floor((size(EEG{block}{cond, phrase}, 1) - wlen) / shift) + 1;

                    for w = 1:nwin_count
                        tmp = EEG{block}{cond, phrase}((w-1)*shift+1:(w-1)*shift+wlen, :);
                        if ~any(tmp(:) == 1000) && ~any(isnan(tmp(:)))
                            windowlist{block, cond, phrase, w} = tmp;
                        end
                    end
                end
            end
        end
    end

    windowlist_all_sg{p} = windowlist;
end

fprintf('Windowlist building completed!\n\n');

%% Surrogate generation loop
fprintf('Starting surrogate generation...\n');

parfor epoc = missing_surr
    fprintf('Surrogate iteration %d/%d...\n', epoc, num_surrogates);

    % Create output directory
    output_surr = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDC_cond1_SET/GPDC', num2str(epoc), '/'];
    if ~exist(output_surr, 'dir')
        mkdir(output_surr);
    end

    % Process UK participants
    for p = 1:length(PNo_uk)
        fprintf('  UK %s (%d/%d)...\n', PNo_uk{p}, p, length(PNo_uk));

        % Get pre-built windowlist
        windowlist = windowlist_all_uk{p};
        FamEEGart_size = FamEEGart_sizes_uk{p};

        % Shuffle windowlist
        [dim1, dim2, dim3, dim4] = size(windowlist);
        non_empty_positions = [];

        cond_idx = 1;
        for i = 1:dim1
            for k = 1:dim3
                for l = 1:dim4
                    if ~isempty(windowlist{i, cond_idx, k, l}) && isequal(size(windowlist{i, cond_idx, k, l}), [300, 18])
                        non_empty_positions = [non_empty_positions; [i, cond_idx, k, l]];
                    end
                end
            end
        end

        if ~isempty(non_empty_positions)
            num_non_empty_positions = size(non_empty_positions, 1);
            num_iterations = 18;

            random_orders = cell(1, num_iterations);
            for i = 1:num_iterations
                random_orders{i} = randperm(num_non_empty_positions);
            end

            temp_windowlist = windowlist;
            for idx = 1:num_non_empty_positions
                current_pos = non_empty_positions(idx, :);
                temp = [];
                for i = 1:num_iterations
                    temporder = random_orders{i};
                    random_positions = non_empty_positions(temporder(idx), :);
                    temp2 = windowlist{random_positions(1), random_positions(2), random_positions(3), random_positions(4)};
                    temp = [temp, temp2(:, i)];
                end
                temp_windowlist{current_pos(1), current_pos(2), current_pos(3), current_pos(4)} = temp;
            end

            windowlist = temp_windowlist;
        end

        % Compute GPDC on shuffled windowlist
        GPDC_s = cell(FamEEGart_size, 1);
        cond = 1;
        for block = 1:size(windowlist, 1)
            % Check if this block has any valid cond=1 data
            has_data = false;
            for phrase = 1:size(windowlist, 3)
                for w = 1:size(windowlist, 4)
                    if ~isempty(windowlist{block, cond, phrase, w})
                        has_data = true;
                        break;
                    end
                end
                if has_data, break; end
            end

            if has_data
                GPDC_s{block} = cell(1, size(windowlist, 3));
                for phrase = 1:size(windowlist, 3)
                    for w = 1:size(windowlist, 4)
                        if ~isempty(windowlist{block, cond, phrase, w})
                            tmp = windowlist{block, cond, phrase, w};

                            mytmp1 = tmp';
                            [eAm, eSu, Yp, Up] = idMVAR(mytmp1, MO, idMode);
                            try
                                [~, ~, ~, GPDC_s{block}{cond, phrase}(:, :, :, w), ~, ~, ~, h, s, pp, f] = fdMVAR(eAm, eSu, nfft, NSamp);
                            catch
                                GPDC_s{block}{cond, phrase}(:, :, :, w) = NaN(length(include)*2, length(include)*2, nfft);
                            end
                        end
                    end
                end
            end
        end

        % Average GPDC over windows
        avGPDC_s = cell(FamEEGart_size, 1);
        for block = 1:FamEEGart_size
            if ~isempty(GPDC_s{block})
                avGPDC_s{block} = cell(1, size(windowlist, 3));
                cond = 1;
                for phrase = 1:size(windowlist, 3)
                    if ~isempty(GPDC_s{block}{cond, phrase}) && length(GPDC_s{block}{cond, phrase}) > 1
                        tmp2 = zeros(2*length(include), 2*length(include), nfft);
                        for i = 1:2*length(include)
                            for j = 1:2*length(include)
                                tmp2(i, j, :) = nanmean(abs(GPDC_s{block}{cond, phrase}(i, j, :, :)).^2, 4);
                            end
                        end
                        avGPDC_s{block}{cond, phrase} = tmp2;
                    end
                end
            end
        end

        % Partition and average
        II_s = {}; AA_s = {}; AI_s = {}; IA_s = {};

        for block = 1:size(avGPDC_s, 1)
            if ~isempty(avGPDC_s{block})
                cond = 1;
                for phase = 1:size(avGPDC_s{block}, 2)
                    if ~isempty(avGPDC_s{block}{cond, phase}) && nansum(nansum(nansum(avGPDC_s{block}{cond, phase}))) ~= 0
                        tmp = avGPDC_s{block}{cond, phase};
                        GPDC_AA = tmp(1:length(include), 1:length(include), :);
                        GPDC_IA = tmp(1:length(include), length(include)+1:length(include)*2, :);
                        GPDC_AI = tmp(length(include)+1:length(include)*2, 1:length(include), :);
                        GPDC_II = tmp(length(include)+1:length(include)*2, length(include)+1:length(include)*2, :);

                        for fplot = 1:length(bands)
                            tmp1g = squeeze(nanmean(GPDC_II(:, :, bands{fplot}), 3));
                            tmp2g = squeeze(nanmean(GPDC_AA(:, :, bands{fplot}), 3));
                            tmp3g = squeeze(nanmean(GPDC_AI(:, :, bands{fplot}), 3));
                            tmp4g = squeeze(nanmean(GPDC_IA(:, :, bands{fplot}), 3));

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

        for block = 1:size(avGPDC_s, 1)
            if ~isempty(avGPDC_s{block})
                cond = 1;
                for fplot = 1:length(bands)
                    tmp1All = []; tmp2All = []; tmp3All = []; tmp4All = [];
                    count = 0;

                    for phase = 1:size(avGPDC_s{block}, 2)
                    if ~isempty(II_s) && size(II_s, 1) >= block && size(II_s, 2) >= cond && ...
                            size(II_s, 3) >= fplot && size(II_s, 4) >= phase
                        if ~isempty(II_s{block, cond, fplot, phase})
                            if isempty(tmp1All)
                                tmp1All = zeros(size(II_s{block, cond, fplot, phase}));
                                tmp2All = zeros(size(AA_s{block, cond, fplot, phase}));
                                tmp3All = zeros(size(AI_s{block, cond, fplot, phase}));
                                tmp4All = zeros(size(IA_s{block, cond, fplot, phase}));
                            end
                            tmp1All = tmp1All + II_s{block, cond, fplot, phase};
                            tmp2All = tmp2All + AA_s{block, cond, fplot, phase};
                            tmp3All = tmp3All + AI_s{block, cond, fplot, phase};
                            tmp4All = tmp4All + IA_s{block, cond, fplot, phase};
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
        save(fullfile(output_surr, sprintf('UK_%s_GPDC.mat', PNo_uk{p})), 'II', 'AI', 'AA', 'IA');
    end

    % Process SG participants
    for p = 1:length(PNo_sg)
        fprintf('  SG %s (%d/%d)...\n', PNo_sg{p}, p, length(PNo_sg));

        % Get pre-built windowlist
        windowlist = windowlist_all_sg{p};
        FamEEGart_size = FamEEGart_sizes_sg{p};

        % Shuffle windowlist
        [dim1, dim2, dim3, dim4] = size(windowlist);
        non_empty_positions = [];

        cond_idx = 1;
        for i = 1:dim1
            for k = 1:dim3
                for l = 1:dim4
                    if ~isempty(windowlist{i, cond_idx, k, l}) && isequal(size(windowlist{i, cond_idx, k, l}), [300, 18])
                        non_empty_positions = [non_empty_positions; [i, cond_idx, k, l]];
                    end
                end
            end
        end

        if ~isempty(non_empty_positions)
            num_non_empty_positions = size(non_empty_positions, 1);
            num_iterations = 18;

            random_orders = cell(1, num_iterations);
            for i = 1:num_iterations
                random_orders{i} = randperm(num_non_empty_positions);
            end

            temp_windowlist = windowlist;
            for idx = 1:num_non_empty_positions
                current_pos = non_empty_positions(idx, :);
                temp = [];
                for i = 1:num_iterations
                    temporder = random_orders{i};
                    random_positions = non_empty_positions(temporder(idx), :);
                    temp2 = windowlist{random_positions(1), random_positions(2), random_positions(3), random_positions(4)};
                    temp = [temp, temp2(:, i)];
                end
                temp_windowlist{current_pos(1), current_pos(2), current_pos(3), current_pos(4)} = temp;
            end

            windowlist = temp_windowlist;
        end

        % Compute GPDC on shuffled windowlist
        GPDC_s = cell(FamEEGart_size, 1);
        cond = 1;
        for block = 1:size(windowlist, 1)
            % Check if this block has any valid cond=1 data
            has_data = false;
            for phrase = 1:size(windowlist, 3)
                for w = 1:size(windowlist, 4)
                    if ~isempty(windowlist{block, cond, phrase, w})
                        has_data = true;
                        break;
                    end
                end
                if has_data, break; end
            end

            if has_data
                GPDC_s{block} = cell(1, size(windowlist, 3));
                for phrase = 1:size(windowlist, 3)
                    for w = 1:size(windowlist, 4)
                        if ~isempty(windowlist{block, cond, phrase, w})
                            tmp = windowlist{block, cond, phrase, w};

                            mytmp1 = tmp';
                            [eAm, eSu, Yp, Up] = idMVAR(mytmp1, MO, idMode);
                            try
                                [~, ~, ~ ,GPDC_s{block}{cond, phrase}(:, :, :, w), ~, ~, ~, h, s, pp, f] = fdMVAR(eAm, eSu, nfft, NSamp);
                            catch
                                GPDC_s{block}{cond, phrase}(:, :, :, w) = NaN(length(include)*2, length(include)*2, nfft);
                            end
                        end
                    end
                end
            end
        end

        % Average GPDC over windows
        avGPDC_s = cell(FamEEGart_size, 1);
        for block = 1:FamEEGart_size
            if ~isempty(GPDC_s{block})
                avGPDC_s{block} = cell(1, size(windowlist, 3));
                cond = 1;
                for phrase = 1:size(windowlist, 3)
                    if ~isempty(GPDC_s{block}{cond, phrase}) && length(GPDC_s{block}{cond, phrase}) > 1
                        tmp2 = zeros(2*length(include), 2*length(include), nfft);
                        for i = 1:2*length(include)
                            for j = 1:2*length(include)
                                tmp2(i, j, :) = nanmean(abs(GPDC_s{block}{cond, phrase}(i, j, :, :)).^2, 4);
                            end
                        end
                        avGPDC_s{block}{cond, phrase} = tmp2;
                    end
                end
            end
        end

        % Partition and average
        II_s = {}; AA_s = {}; AI_s = {}; IA_s = {};

        for block = 1:size(avGPDC_s, 1)
            if ~isempty(avGPDC_s{block})
                cond = 1;
                for phase = 1:size(avGPDC_s{block}, 2)
                    if ~isempty(avGPDC_s{block}{cond, phase}) && nansum(nansum(nansum(avGPDC_s{block}{cond, phase}))) ~= 0
                        tmp = avGPDC_s{block}{cond, phase};
                        GPDC_AA = tmp(1:length(include), 1:length(include), :);
                        GPDC_IA = tmp(1:length(include), length(include)+1:length(include)*2, :);
                        GPDC_AI = tmp(length(include)+1:length(include)*2, 1:length(include), :);
                        GPDC_II = tmp(length(include)+1:length(include)*2, length(include)+1:length(include)*2, :);

                        for fplot = 1:length(bands)
                            tmp1g = squeeze(nanmean(GPDC_II(:, :, bands{fplot}), 3));
                            tmp2g = squeeze(nanmean(GPDC_AA(:, :, bands{fplot}), 3));
                            tmp3g = squeeze(nanmean(GPDC_AI(:, :, bands{fplot}), 3));
                            tmp4g = squeeze(nanmean(GPDC_IA(:, :, bands{fplot}), 3));

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

        for block = 1:size(avGPDC_s, 1)
            if ~isempty(avGPDC_s{block})
                cond = 1;
                for fplot = 1:length(bands)
                    tmp1All = []; tmp2All = []; tmp3All = []; tmp4All = [];
                    count = 0;

                    for phase = 1:size(avGPDC_s{block}, 2)
                    if ~isempty(II_s) && size(II_s, 1) >= block && size(II_s, 2) >= cond && ...
                            size(II_s, 3) >= fplot && size(II_s, 4) >= phase
                        if ~isempty(II_s{block, cond, fplot, phase})
                            if isempty(tmp1All)
                                tmp1All = zeros(size(II_s{block, cond, fplot, phase}));
                                tmp2All = zeros(size(AA_s{block, cond, fplot, phase}));
                                tmp3All = zeros(size(AI_s{block, cond, fplot, phase}));
                                tmp4All = zeros(size(IA_s{block, cond, fplot, phase}));
                            end
                            tmp1All = tmp1All + II_s{block, cond, fplot, phase};
                            tmp2All = tmp2All + AA_s{block, cond, fplot, phase};
                            tmp3All = tmp3All + AI_s{block, cond, fplot, phase};
                            tmp4All = tmp4All + IA_s{block, cond, fplot, phase};
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
        save(fullfile(output_surr, sprintf('SG_%s_GPDC.mat', PNo_sg{p})), 'II', 'AI', 'AA', 'IA');
    end
end

fprintf('==========================================================\n');
fprintf('Surrogate data generation completed!\n');
fprintf('Generated %d missing surrogates (now %d/%d total)\n', length(missing_surr), num_surrogates, num_surrogates);
fprintf('Output saved to: %ssurrGPDC_cond1_SET/\n', [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/']);
fprintf('==========================================================\n\n');
