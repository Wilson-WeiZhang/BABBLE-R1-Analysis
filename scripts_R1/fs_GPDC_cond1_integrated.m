%% ========================================================================
%  INTEGRATED GPDC ANALYSIS - CONDITION 1 ONLY
%  ========================================================================
%
%  PURPOSE:
%  This integrated script combines 4 analysis steps into a single workflow
%  specifically for condition 1 (cond=1) only:
%
%  Step 1: Load and prepare EEG data
%  Step 2: Calculate real GPDC connectivity (cond=1 only)
%  Step 3: Generate surrogate data and calculate GPDC (cond=1 only)
%  Step 4: Read and organize data into final table (cond=1 only)
%
%  BASED ON:
%  - fs3_pdc_nosurr_v2.m (real GPDC calculation)
%  - fs3_makesurr3_nonor.m (surrogate generation)
%  - fs4_readdata.m (data reading and organization)
%
%  KEY MODIFICATION:
%  All analyses restricted to cond==1 data only
%
%  ========================================================================

clc
clear all

%% ========================================================================
%  STEP 1: CONFIGURATION AND DATA LOADING
%  ========================================================================

fprintf('==========================================================\n');
fprintf('STEP 1: Loading EEG data and setting parameters\n');
fprintf('==========================================================\n\n');

% Set path
path = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';

% Analysis type (can be changed to 'DC', 'DTF', 'PDC', 'COH', 'PCOH')
type = 'GPDC';

% Set locations
loclist = {'C', 'S'};  % Cambridge and Singapore

% Create output directories
output_real = [path, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/', type, '3_cond1_only/'];
if ~exist(output_real, 'dir')
    mkdir(output_real);
end

% Montage and frequency settings
Montage = 'GRID';
freqs = [9, 17, 24, 32]; % Frequency indices

% Channel configuration
if strcmp(Montage, 'GRID') == 1
    include = [4:6, 15:17, 26:28]'; % 9-channel grid FA3, CM3, PR3
    chLabel = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
end

% Model Parameters
MO = 7; % Model Order for 1.5s epoch
idMode = 7; % Nuttall-Strand unbiased partial correlation
NSamp = 200; % Sampling rate
len = 1.5; % Window length in seconds
shift = 0.5 * len * NSamp; % 50% overlap
wlen = len * NSamp;
nfft = 256; % FFT points

% Frequency bands (indices for nfft=256)
% Delta 1-3 Hz [4:8]
% Theta 3-6 Hz [9:16]
% Alpha 6-9 Hz [17:24]
bands = {[4:8], [9:16], [17:24]};

fprintf('Loading Singapore data...\n');
Loc = 'S';
filepath_sg = [path, 'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_sg/'];
PNo_sg = {'101', '104', '106', '107', '108', '110', '114', '115', '116', '117', '120', '121', '122', '123', '127'};
datasg = struct();
for p = 1:length(PNo_sg)
    filename = strcat(filepath_sg, '/P', PNo_sg{p}, Loc, '/', 'P', PNo_sg{p}, Loc, '_BABBLE_AR.mat');
    loadedData = load(filename, 'FamEEGart', 'StimEEGart');
    datasg(p).FamEEGart = loadedData.FamEEGart;
    datasg(p).StimEEGart = loadedData.StimEEGart;
end

fprintf('Loading Cambridge data...\n');
Loc = 'C';
filepath_uk = [path, 'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_camb/'];
PNo_uk = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '111', '114', '117', '118', '119', '121', '122', '123', '124', '125', '126', '127', '128', '129', '131', '132', '133', '135'};
datauk = struct();
for p = 1:length(PNo_uk)
    filename = strcat(filepath_uk, '/P', PNo_uk{p}, Loc, '/', 'P', PNo_uk{p}, Loc, '_BABBLE_AR.mat');
    loadedData = load(filename, 'FamEEGart', 'StimEEGart');
    datauk(p).FamEEGart = loadedData.FamEEGart;
    datauk(p).StimEEGart = loadedData.StimEEGart;
end

fprintf('Data loading completed!\n\n');

%% ========================================================================
%  STEP 2: CALCULATE REAL GPDC (COND=1 ONLY)
%  ========================================================================

fprintf('==========================================================\n');
fprintf('STEP 2: Calculating real GPDC for cond=1 only\n');
fprintf('==========================================================\n\n');

for loci = 1:2
    Loc = loclist{loci};

    if strcmp(Loc, 'S') == 1
        PNo = PNo_sg;
        data_struct = datasg;
    else
        PNo = PNo_uk;
        data_struct = datauk;
    end

    fprintf('Processing %s data (%d participants)...\n', Loc, length(PNo));

    for p = 1:length(PNo)
        fprintf('  Participant %s%s (%d/%d)...\n', Loc, PNo{p}, p, length(PNo));

        FamEEGart = data_struct(p).FamEEGart;
        StimEEGart = data_struct(p).StimEEGart;

        % Replace bad sections with 1000 and merge infant and adult matrices
        for block = 1:size(FamEEGart, 1)
            if isempty(FamEEGart{block}) == 0
                % ONLY PROCESS COND=1
                cond = 1;
                for phrase = 1:size(FamEEGart{block}, 2)
                    if isempty(FamEEGart{block}{cond, phrase}) == 0 && size(FamEEGart{block}{cond, phrase}, 1) > 1
                        for chan = 1:length(include)
                            iEEG{block}{cond, phrase}(:, chan) = FamEEGart{block}{cond, phrase}(:, include(chan));
                            aEEG{block}{cond, phrase}(:, chan) = StimEEGart{block}{cond, phrase}(:, include(chan));

                            ind = find(FamEEGart{block}{cond, phrase}(:, chan) == 777 | ...
                                      FamEEGart{block}{cond, phrase}(:, chan) == 888 | ...
                                      FamEEGart{block}{cond, phrase}(:, chan) == 999);
                            if length(ind) > 0
                                iEEG{block}{cond, phrase}(ind, chan) = 1000;
                                aEEG{block}{cond, phrase}(ind, chan) = 1000;
                            end
                            clear ind
                        end
                    end
                end
            else
                iEEG{block} = [];
                aEEG{block} = [];
            end
        end

        % Concatenate adult and infant EEG (COND=1 ONLY)
        for block = 1:size(FamEEGart, 1)
            cond = 1;
            for phrase = 1:size(FamEEGart{block}, 2)
                if isempty(aEEG{block}) == 0 && ~isempty(aEEG{block}{cond, phrase})
                    EEG{block, 1}{cond, phrase} = horzcat(aEEG{block}{cond, phrase}, iEEG{block}{cond, phrase});
                end
            end
        end

        % Compute Windowed GPDC (COND=1 ONLY)
        for block = 1:size(EEG, 1)
            if isempty(EEG{block}) == 0
                cond = 1;
                for phrase = 1:size(EEG{block}, 2)
                    if isempty(EEG{block}{cond, phrase}) == 0 && size(EEG{block}{cond, phrase}, 1) > 1
                        nwin{block}(cond, phrase) = floor((size(EEG{block}{cond, phrase}, 1) - wlen) / shift) + 1;
                        for w = 1:nwin{block}(cond, phrase)
                            tmp = EEG{block}{cond, phrase}((w-1)*shift+1:(w-1)*shift+wlen, :);
                            if length(find(tmp == 1000)) == 0 && length(find(isnan(tmp) == 1)) == 0

                                % Calculate GPDC
                                mytmp1 = tmp';
                                [eAm, eSu, Yp, Up] = idMVAR(mytmp1, MO, idMode);
                                [~, ~, ~, GPDC{block}{cond, phrase}(:, :, :, w), ~, ~, ~, h, s, pp, f] = fdMVAR(eAm, eSu, nfft, NSamp);

                                clear tmp mytmp1 h s pp
                            else
                                GPDC{block}{cond, phrase}(:, :, :, w) = NaN(length(include)*2, length(include)*2, nfft);
                                nwin_include{block}{cond, phrase}(w, 1) = NaN;
                            end
                        end
                    else
                        GPDC{block}{cond, phrase} = [];
                    end
                end
            else
                GPDC{block} = [];
            end
        end

        % Average GPDC over windows (COND=1 ONLY)
        for block = 1:size(GPDC, 2)
            cond = 1;
            for phrase = 1:size(GPDC{block}, 2)
                if isempty(GPDC{block}{cond, phrase}) == 0 && length(GPDC{block}{cond, phrase}) > 1
                    for i = 1:2*length(include)
                        for j = 1:2*length(include)
                            tmp2(i, j, :) = nanmean(abs(GPDC{block}{cond, phrase}(i, j, :, :)).^2, 4);
                        end
                    end
                    avGPDC{p, 1}{block, cond, phrase} = tmp2;
                    clear tmp2
                else
                    avGPDC{p, 1}{block, cond, phrase} = NaN;
                end
            end
        end

        clear FamEEGart StimEEGart iEEG aEEG EEG GPDC nwin nwinclude

    end

    % Process and save GPDC for each participant (COND=1 ONLY)
    for p = 1:length(PNo)
        II = {}; AA = {}; AI = {}; IA = {};

        for block = 1:size(avGPDC{p}, 1)
            cond = 1;
            for phase = 1:size(avGPDC{p}, 3)
                if isempty(avGPDC{p}{block, cond, phase}) == 0 && nansum(nansum(nansum(avGPDC{p}{block, cond, phase}))) ~= 0
                    tmp = avGPDC{p}{block, cond, phase};
                    GPDC_AA{block, cond, phase} = tmp(1:length(include), 1:length(include), :); % AA
                    GPDC_IA{block, cond, phase} = tmp(1:length(include), length(include)+1:length(include)*2, :); % IA
                    GPDC_AI{block, cond, phase} = tmp(length(include)+1:length(include)*2, 1:length(include), :); % AI
                    GPDC_II{block, cond, phase} = tmp(length(include)+1:length(include)*2, length(include)+1:length(include)*2, :); % II
                else
                    GPDC_AA{block, cond, phase} = nan;
                    GPDC_IA{block, cond, phase} = nan;
                    GPDC_AI{block, cond, phase} = nan;
                    GPDC_II{block, cond, phase} = nan;
                end
            end
        end

        % Calculate GPDC averaging across frequency bands (COND=1 ONLY)
        for block = 1:size(avGPDC{p}, 1)
            cond = 1;
            tmp1All = [];
            tmp2All = [];
            tmp3All = [];
            tmp4All = [];
            count = 0;

            for phase = 1:size(avGPDC{p}, 3)
                if ~isempty(avGPDC{p}{block, cond, phase}) && nansum(nansum(nansum(avGPDC{p}{block, cond, phase}))) ~= 0
                    for fplot = 1:length(bands)
                        tmp1g = squeeze(nanmean(GPDC_II{block, cond, phase}(:, :, bands{fplot}), 3));
                        tmp2g = squeeze(nanmean(GPDC_AA{block, cond, phase}(:, :, bands{fplot}), 3));
                        tmp3g = squeeze(nanmean(GPDC_AI{block, cond, phase}(:, :, bands{fplot}), 3));
                        tmp4g = squeeze(nanmean(GPDC_IA{block, cond, phase}(:, :, bands{fplot}), 3));

                        if isempty(tmp1All)
                            tmp1All = zeros([size(tmp1g), length(bands)]);
                            tmp2All = zeros([size(tmp2g), length(bands)]);
                            tmp3All = zeros([size(tmp3g), length(bands)]);
                            tmp4All = zeros([size(tmp4g), length(bands)]);
                        end
                        tmp1All(:, :, fplot) = tmp1All(:, :, fplot) + tmp1g;
                        tmp2All(:, :, fplot) = tmp2All(:, :, fplot) + tmp2g;
                        tmp3All(:, :, fplot) = tmp3All(:, :, fplot) + tmp3g;
                        tmp4All(:, :, fplot) = tmp4All(:, :, fplot) + tmp4g;
                    end
                    count = count + 1;
                end
            end

            if count > 0
                for fplot = 1:length(bands)
                    II{block, cond, fplot} = tmp1All(:, :, fplot) / count;
                    AA{block, cond, fplot} = tmp2All(:, :, fplot) / count;
                    AI{block, cond, fplot} = tmp3All(:, :, fplot) / count;
                    IA{block, cond, fplot} = tmp4All(:, :, fplot) / count;
                end
            end
        end

        clear GPDC_II GPDC_AA GPDC_AI GPDC_IA

        % Save GPDC data
        cd(output_real);
        if loci == 1
            save(sprintf('UK_%s_PDC.mat', PNo{p}), 'II', 'AI', 'AA', 'IA');
        else
            save(sprintf('SG_%s_PDC.mat', PNo{p}), 'II', 'AI', 'AA', 'IA');
        end
    end

    fprintf('%s location completed!\n\n', Loc);
end

fprintf('STEP 2 completed: Real GPDC calculation finished!\n\n');

%% ========================================================================
%  STEP 3: GENERATE SURROGATE DATA AND CALCULATE GPDC (COND=1 ONLY)
%  ========================================================================
clear all
clc
fprintf('==========================================================\n');
fprintf('STEP 3: Generating surrogate data for cond=1 only\n');
fprintf('==========================================================\n\n');

% User configuration: number of surrogate iterations
num_surrogates = 1; % Change this to generate more/fewer surrogates
fprintf('Number of surrogate iterations: %d\n\n', num_surrogates);

for epoc = 1:num_surrogates

    output_surr = [path1, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrPDC_cond1_SET/PDC', num2str(epoc), '/'];
    if ~exist(output_surr, 'dir')
        mkdir(output_surr);
    end

    fprintf('Surrogate iteration %d/%d...\n', epoc, num_surrogates);

    for loci = 1:2
        Loc = loclist{loci};

        if strcmp(Loc, 'S') == 1
            PNo = PNo_sg;
            data_struct = datasg;
        else
            PNo = PNo_uk;
            data_struct = datauk;
        end

        for p = 1:length(PNo)

            FamEEGart = data_struct(p).FamEEGart;
            StimEEGart = data_struct(p).StimEEGart;
            windowlist = cell(3, 3, 3, 1);

            % Replace bad sections with 1000 and merge infant and adult matrices
            for block = 1:size(FamEEGart, 1)
                if isempty(FamEEGart{block}) == 0
                    % ONLY PROCESS COND=1
                    cond = 1;
                    for phrase = 1:size(FamEEGart{block}, 2)
                        if isempty(FamEEGart{block}{cond, phrase}) == 0 && size(FamEEGart{block}{cond, phrase}, 1) > 1
                            for chan = 1:length(include)
                                iEEG{block}{cond, phrase}(:, chan) = FamEEGart{block}{cond, phrase}(:, include(chan));
                                aEEG{block}{cond, phrase}(:, chan) = StimEEGart{block}{cond, phrase}(:, include(chan));

                                ind = find(FamEEGart{block}{cond, phrase}(:, chan) == 777 | ...
                                          FamEEGart{block}{cond, phrase}(:, chan) == 888 | ...
                                          FamEEGart{block}{cond, phrase}(:, chan) == 999);
                                if length(ind) > 0
                                    iEEG{block}{cond, phrase}(ind, chan) = 1000;
                                    aEEG{block}{cond, phrase}(ind, chan) = 1000;
                                end
                                clear ind
                            end
                        end
                    end
                else
                    iEEG{block} = [];
                    aEEG{block} = [];
                end
            end

            % Concatenate adult and infant EEG (COND=1 ONLY)
            for block = 1:size(FamEEGart, 1)
                cond = 1;
                for phrase = 1:size(FamEEGart{block}, 2)
                    if ~isempty(aEEG{block}) && ~isempty(aEEG{block}{cond, phrase})
                        EEG{block, 1}{cond, phrase} = horzcat(aEEG{block}{cond, phrase}, iEEG{block}{cond, phrase});
                    end
                end
            end

            % Collect windowed data (COND=1 ONLY)
            for block = 1:size(EEG, 1)
                if isempty(EEG{block}) == 0
                    cond = 1;
                    for phrase = 1:size(EEG{block}, 2)
                        if isempty(EEG{block}{cond, phrase}) == 0 && size(EEG{block}{cond, phrase}, 1) > 1
                            nwin{block}(cond, phrase) = floor((size(EEG{block}{cond, phrase}, 1) - wlen) / shift) + 1;
                            for w = 1:nwin{block}(cond, phrase)
                                tmp = EEG{block}{cond, phrase}((w-1)*shift+1:(w-1)*shift+wlen, :);
                                if length(find(tmp == 1000)) == 0 && length(find(isnan(tmp) == 1)) == 0
                                    windowlist{block, cond, phrase, w} = tmp;
                                else
                                    windowlist{block, cond, phrase, w} = [];
                                end
                            end
                        end
                    end
                end
            end

            % Surrogate window pairs by shuffling (COND=1 ONLY)
            [dim1, dim2, dim3, dim4] = size(windowlist);
            non_empty_positions = [];

            % Find all non-empty positions for cond=1
            for i = 1:dim1
                j = 1; % cond = 1
                for k = 1:dim3
                    for l = 1:dim4
                        if ~isempty(windowlist{i, j, k, l}) && isequal(size(windowlist{i, j, k, l}), [300, 18])
                            non_empty_positions = [non_empty_positions; [i, j, k, l]];
                        end
                    end
                end
            end

            num_non_empty_positions = size(non_empty_positions, 1);
            num_iterations = 18; % Number of channels

            % Generate random orders for each channel
            random_orders = cell(1, num_iterations);
            for i = 1:num_iterations
                random_orders{i} = randperm(num_non_empty_positions);
            end

            % Create shuffled windowlist
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

            % Compute GPDC on surrogate data (COND=1 ONLY)
            for block = 1:size(windowlist, 1)
                cond = 1;
                for phrase = 1:size(windowlist, 3)
                    for w = 1:size(windowlist, 4)
                        if isempty(windowlist{block, cond, phrase, w}) == 0
                            tmp = windowlist{block, cond, phrase, w};

                            % Calculate GPDC
                            mytmp1 = tmp';
                            [eAm, eSu, Yp, Up] = idMVAR(mytmp1, MO, idMode);
                            try
                                [~, ~, ~, GPDC{block}{cond, phrase}(:, :, :, w), ~, ~, ~, h, s, pp, f] = fdMVAR(eAm, eSu, nfft, NSamp);
                            catch
                                GPDC{block}{cond, phrase}(:, :, :, w) = NaN(length(include)*2, length(include)*2, nfft);
                            end
                            clear tmp mytmp1 h s pp
                        else
                            GPDC{block}{cond, phrase}(:, :, :, w) = NaN(length(include)*2, length(include)*2, nfft);
                        end
                    end
                end
            end

            % Average GPDC over windows (COND=1 ONLY)
            for block = 1:size(GPDC, 2)
                cond = 1;
                for phrase = 1:size(GPDC{block}, 2)
                    if isempty(GPDC{block}{cond, phrase}) == 0 && length(GPDC{block}{cond, phrase}) > 1
                        for i = 1:2*length(include)
                            for j = 1:2*length(include)
                                tmp2(i, j, :) = nanmean(abs(GPDC{block}{cond, phrase}(i, j, :, :)).^2, 4);
                            end
                        end
                        avGPDC{p, 1}{block, cond, phrase} = tmp2;
                        clear tmp2
                    else
                        avGPDC{p, 1}{block, cond, phrase} = NaN;
                    end
                end
            end

            clear FamEEGart StimEEGart iEEG aEEG EEG GPDC nwin nwinclude windowlist
        end

        % Process and save surrogate GPDC for each participant
        for p = 1:length(PNo)
            II = {}; AA = {}; AI = {}; IA = {};

            for block = 1:size(avGPDC{p}, 1)
                cond = 1;
                for phase = 1:size(avGPDC{p}, 3)
                    if isempty(avGPDC{p}{block, cond, phase}) == 0 && nansum(nansum(nansum(avGPDC{p}{block, cond, phase}))) ~= 0
                        tmp = avGPDC{p}{block, cond, phase};
                        GPDC_AA{block, cond, phase} = tmp(1:length(include), 1:length(include), :);
                        GPDC_IA{block, cond, phase} = tmp(1:length(include), length(include)+1:length(include)*2, :);
                        GPDC_AI{block, cond, phase} = tmp(length(include)+1:length(include)*2, 1:length(include), :);
                        GPDC_II{block, cond, phase} = tmp(length(include)+1:length(include)*2, length(include)+1:length(include)*2, :);
                    else
                        GPDC_AA{block, cond, phase} = nan;
                        GPDC_AI{block, cond, phase} = nan;
                        GPDC_IA{block, cond, phase} = nan;
                        GPDC_II{block, cond, phase} = nan;
                    end
                end
            end

            % Calculate GPDC averaging across frequency bands (COND=1 ONLY)
            for block = 1:size(avGPDC{p}, 1)
                cond = 1;
                tmp1All = [];
                tmp2All = [];
                tmp3All = [];
                tmp4All = [];
                count = 0;

                for phase = 1:size(avGPDC{p}, 3)
                    if ~isempty(avGPDC{p}{block, cond, phase}) && nansum(nansum(nansum(avGPDC{p}{block, cond, phase}))) ~= 0
                        for fplot = 1:length(bands)
                            tmp1g = squeeze(nanmean(GPDC_II{block, cond, phase}(:, :, bands{fplot}), 3));
                            tmp2g = squeeze(nanmean(GPDC_AA{block, cond, phase}(:, :, bands{fplot}), 3));
                            tmp3g = squeeze(nanmean(GPDC_AI{block, cond, phase}(:, :, bands{fplot}), 3));
                            tmp4g = squeeze(nanmean(GPDC_IA{block, cond, phase}(:, :, bands{fplot}), 3));

                            if isempty(tmp1All)
                                tmp1All = zeros([size(tmp1g), length(bands)]);
                                tmp2All = zeros([size(tmp2g), length(bands)]);
                                tmp3All = zeros([size(tmp3g), length(bands)]);
                                tmp4All = zeros([size(tmp4g), length(bands)]);
                            end
                            tmp1All(:, :, fplot) = tmp1All(:, :, fplot) + tmp1g;
                            tmp2All(:, :, fplot) = tmp2All(:, :, fplot) + tmp2g;
                            tmp3All(:, :, fplot) = tmp3All(:, :, fplot) + tmp3g;
                            tmp4All(:, :, fplot) = tmp4All(:, :, fplot) + tmp4g;
                        end
                        count = count + 1;
                    end
                end

                if count > 0
                    for fplot = 1:length(bands)
                        II{block, cond, fplot} = tmp1All(:, :, fplot) / count;
                        AA{block, cond, fplot} = tmp2All(:, :, fplot) / count;
                        AI{block, cond, fplot} = tmp3All(:, :, fplot) / count;
                        IA{block, cond, fplot} = tmp4All(:, :, fplot) / count;
                    end
                end
            end

            clear GPDC_II GPDC_AA GPDC_AI GPDC_IA

            % Save surrogate GPDC data
            cd(output_surr);
            if loci == 1
                save(sprintf('UK_%s_PDC.mat', PNo{p}), 'II', 'AI', 'AA', 'IA');
            else
                save(sprintf('SG_%s_PDC.mat', PNo{p}), 'II', 'AI', 'AA', 'IA');
            end
        end
    end
end

fprintf('STEP 3 completed: Surrogate data generation finished!\n\n');

%% ========================================================================
%  STEP 4: READ AND ORGANIZE DATA (COND=1 ONLY)
%  ========================================================================

fprintf('==========================================================\n');
fprintf('STEP 4: Reading and organizing data for cond=1 only\n');
fprintf('==========================================================\n\n');

% Load behavioral data
[a, b] = xlsread([path, 'infanteeg/CAM BABBLE EEG DATA/2024/table/behaviour2.5sd.xlsx']);

% Remove samples with NaN in learning column
a(find(sum(isnan(a(:, 7)), 2) > 0), :) = [];

% Extract behavioral variables
AGE = a(:, 3);
SEX = a(:, 4);
SEX = categorical(SEX);
COUNTRY = a(:, 1);
COUNTRY = categorical(COUNTRY);
blocks = a(:, 5);
blocks = categorical(blocks);
CONDGROUP = a(:, 6);
CONDGROUP = categorical(CONDGROUP);
learning = a(:, 7);
atten = a(:, 9);
ID = a(:, 2);
ID = categorical(ID);

% Initialize data array
data = [];
count = 0;
s = [];

fprintf('Reading real GPDC data for cond=1...\n');

for i = 1:size(a, 1)
    if ~isnan(a(i, 7))
        num = a(i, 2);
        if ismember(num, [1113, 1136, 1112, 1116, 2112, 2118, 2119]) == 0
            num = num2str(a(i, 2));
            num = num(2:4);

            % Load GPDC data
            if a(i, 1) == 1
                load([path, 'infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/', type, '3_cond1_only/UK_', num, '_PDC.mat']);
            else
                load([path, 'infanteeg/CAM BABBLE EEG DATA/2024//data_matfile/', type, '3_cond1_only/SG_', num, '_PDC.mat']);
            end

            try
                block = a(i, 5);
                cond = a(i, 6);

                % ONLY PROCESS IF cond==1
                if cond == 1
                    % Extract GPDC matrices for 3 frequency bands
                    ii1 = II{block, cond, 1}; ii1 = ii1(:);
                    ii2 = II{block, cond, 2}; ii2 = ii2(:);
                    ii3 = II{block, cond, 3}; ii3 = ii3(:);

                    aa1 = AA{block, cond, 1}; aa1 = aa1(:);
                    aa2 = AA{block, cond, 2}; aa2 = aa2(:);
                    aa3 = AA{block, cond, 3}; aa3 = aa3(:);

                    ai1 = AI{block, cond, 1}; ai1 = ai1(:);
                    ai2 = AI{block, cond, 2}; ai2 = ai2(:);
                    ai3 = AI{block, cond, 3}; ai3 = ai3(:);

                    ia1 = IA{block, cond, 1}; ia1 = ia1(:);
                    ia2 = IA{block, cond, 2}; ia2 = ia2(:);
                    ia3 = IA{block, cond, 3}; ia3 = ia3(:);

                    if isempty(ii3) == 0
                        data = [data; [a(i, 1:9), ii1', ii2', ii3', aa1', aa2', aa3', ai1', ai2', ai3', ia1', ia2', ia3']];
                        count = count + 1;
                        s(count) = std([ii1', ii2', ii3', aa1', aa2', aa3', ai1', ai2', ai3', ia1', ia2', ia3']);
                    end
                end
            end
        end
    end
end

fprintf('Reading surrogate GPDC data for cond=1...\n');

% Load surrogate data
surrPathPrefix = [path, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrPDC_cond1_SET/PDC'];
data_surr = cell(num_surrogates, 1);
count = 0;
z = zeros(num_surrogates, 1);

for surrIdx = 1:num_surrogates
    fprintf('  Loading surrogate %d/%d...\n', surrIdx, num_surrogates);
    surrPath = [surrPathPrefix, num2str(surrIdx)];

    % Check if files exist
    files = dir(fullfile(surrPath, '/*.mat'));
    if length(files) >= 42
        temp = zeros(size(data));
        count = count + 1;
        z(surrIdx) = 1;
        count1 = 0;

        for i = 1:size(a, 1)
            if ~isnan(a(i, 7))
                num = a(i, 2);
                if ismember(num, [1112, 1116, 2112, 2118, 2119]) == 0
                    num = num2str(a(i, 2));
                    num = num(2:4);

                    if a(i, 1) == 1
                        load([path, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrPDC_cond1_SET/PDC', num2str(surrIdx), '/UK_', num, '_PDC.mat']);
                    else
                        load([path, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrPDC_cond1_SET/PDC', num2str(surrIdx), '/SG_', num, '_PDC.mat']);
                    end

                    try
                        block = a(i, 5);
                        cond = a(i, 6);

                        % ONLY PROCESS IF cond==1
                        if cond == 1
                            ii1 = II{block, cond, 1}; ii1 = ii1(:);
                            ii2 = II{block, cond, 2}; ii2 = ii2(:);
                            ii3 = II{block, cond, 3}; ii3 = ii3(:);

                            aa1 = AA{block, cond, 1}; aa1 = aa1(:);
                            aa2 = AA{block, cond, 2}; aa2 = aa2(:);
                            aa3 = AA{block, cond, 3}; aa3 = aa3(:);

                            ai1 = AI{block, cond, 1}; ai1 = ai1(:);
                            ai2 = AI{block, cond, 2}; ai2 = ai2(:);
                            ai3 = AI{block, cond, 3}; ai3 = ai3(:);

                            ia1 = IA{block, cond, 1}; ia1 = ia1(:);
                            ia2 = IA{block, cond, 2}; ia2 = ia2(:);
                            ia3 = IA{block, cond, 3}; ia3 = ia3(:);

                            if isempty(ii1) == 0
                                count1 = count1 + 1;
                                temp(count1, :) = [a(i, 1:9), ii1', ii2', ii3', aa1', aa2', aa3', ai1', ai2', ai3', ia1', ia2', ia3'];
                            end
                        end
                    end
                end
            end
        end
        data_surr{count} = temp;
    end
end

% Remove empty cells
list = zeros(length(data_surr), 1);
for i = 1:length(list)
    if isempty(data_surr{i}) == 1
        list(i) = 1;
    end
end
data_surr(find(list == 1)) = [];

% Generate titles for data columns
nodes = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
frequencyBands = {'Delta', 'Theta', 'Alpha'};
connectionTypes = {'II', 'AA', 'AI', 'IA'};

connectionTitles = {};
for conn = 1:length(connectionTypes)
    for freq = 1:length(frequencyBands)
        for src = 1:length(nodes)
            for dest = 1:length(nodes)
                connectionTitles{end+1} = sprintf('%s_%s_%s_to_%s', connectionTypes{conn}, frequencyBands{freq}, nodes{dest}, nodes{src});
            end
        end
    end
end

titles = ['Country', 'ID', 'Age', 'Sex', 'Block', 'Cond', 'Learning', 'LEARN', 'Atten', connectionTitles];

% Save final data
cd([path, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/']);
save(['data_', type, '_cond1_only.mat'], 'data', 'data_surr', 'titles');

fprintf('STEP 4 completed: Data organization finished!\n\n');

fprintf('==========================================================\n');
fprintf('ALL STEPS COMPLETED SUCCESSFULLY!\n');
fprintf('==========================================================\n\n');
fprintf('Output files saved to:\n');
fprintf('  Real GPDC: %s\n', output_real);
fprintf('  Surrogate GPDC: %ssurrPDC_cond1_SET/\n', [path, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/']);
fprintf('  Final data: %sdata_%s_cond1_only.mat\n', [path, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/'], type);
fprintf('\n');
