%% ========================================================================
%  fs_R1_GPDC_cond1_real.m
%  ========================================================================
%
%  PURPOSE:
%  Calculate real GPDC connectivity for condition 1 only
%
%  CORRESPONDS TO:
%  - Step 2 of integrated analysis
%  - Computes GPDC for cond=1 across all participants and blocks
%
%  OUTPUT:
%  - Real GPDC matrices saved to GPDC3_cond1_only/ folder
%  - Separate files for each participant: UK_XXX_PDC.mat, SG_XXX_PDC.mat
%
%  ========================================================================

clc
clear all

fprintf('==========================================================\n');
fprintf('STEP 2: Calculating real GPDC for cond=1 only\n');
fprintf('==========================================================\n\n');

%% Configuration
basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';

% Analysis type
type = 'GPDC';

% Create output directory
output_real = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/', type, '3_cond1_only/'];
if ~exist(output_real, 'dir')
    mkdir(output_real);
end

% Channel configuration
Montage = 'GRID';
include = [4:6, 15:17, 26:28]'; % 9-channel grid
chLabel = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};

% Model Parameters
MO = 7; % Model Order
idMode = 7; % Nuttall-Strand method
NSamp = 200; % Sampling rate
len = 1.5; % Window length in seconds
shift = 0.5 * len * NSamp; % 50% overlap
wlen = len * NSamp;
nfft = 256; % FFT points

% Frequency bands (indices for nfft=256)
bands = {[4:8], [9:16], [17:24]}; % Delta, Theta, Alpha

%% Load data
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

%% Process both locations
loclist = {'C', 'S'};

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

        % Clear variables to avoid contamination between participants
        clear iEEG_tmp aEEG_tmp EEG_tmp GPDC_tmp nwin_tmp

        FamEEGart = data_struct(p).FamEEGart;
        StimEEGart = data_struct(p).StimEEGart;

        % Initialize fresh variables for this participant
        iEEG_tmp = cell(size(FamEEGart, 1), 1);
        aEEG_tmp = cell(size(FamEEGart, 1), 1);
        EEG_tmp = cell(size(FamEEGart, 1), 1);
        GPDC_tmp = cell(size(FamEEGart, 1), 1);
        nwin_tmp = cell(size(FamEEGart, 1), 1);

        % Replace bad sections and extract channels (COND=1 ONLY)
        for block = 1:size(FamEEGart, 1)
            if isempty(FamEEGart{block}) == 0
                iEEG_tmp{block} = cell(1, size(FamEEGart{block}, 2));
                aEEG_tmp{block} = cell(1, size(FamEEGart{block}, 2));

                cond = 1; % ONLY PROCESS COND=1
                for phrase = 1:size(FamEEGart{block}, 2)
                    if isempty(FamEEGart{block}{cond, phrase}) == 0 && size(FamEEGart{block}{cond, phrase}, 1) > 1
                        for chan = 1:length(include)
                            iEEG_tmp{block}{cond, phrase}(:, chan) = FamEEGart{block}{cond, phrase}(:, include(chan));
                            aEEG_tmp{block}{cond, phrase}(:, chan) = StimEEGart{block}{cond, phrase}(:, include(chan));

                            ind = find(FamEEGart{block}{cond, phrase}(:, chan) == 777 | ...
                                      FamEEGart{block}{cond, phrase}(:, chan) == 888 | ...
                                      FamEEGart{block}{cond, phrase}(:, chan) == 999);
                            if length(ind) > 0
                                iEEG_tmp{block}{cond, phrase}(ind, chan) = 1000;
                                aEEG_tmp{block}{cond, phrase}(ind, chan) = 1000;
                            end
                            clear ind
                        end
                    end
                end
            end
        end

        % Concatenate adult and infant EEG (COND=1 ONLY)
        for block = 1:size(FamEEGart, 1)
            if ~isempty(aEEG_tmp{block})
                EEG_tmp{block} = cell(1, size(FamEEGart{block}, 2));
                cond = 1;
                for phrase = 1:size(FamEEGart{block}, 2)
                    if ~isempty(aEEG_tmp{block}{cond, phrase})
                        EEG_tmp{block}{cond, phrase} = horzcat(aEEG_tmp{block}{cond, phrase}, iEEG_tmp{block}{cond, phrase});
                    end
                end
            end
        end

        % Compute Windowed GPDC (COND=1 ONLY)
        for block = 1:size(FamEEGart, 1)
            if ~isempty(EEG_tmp{block})
                GPDC_tmp{block} = cell(1, size(FamEEGart{block}, 2));
                nwin_tmp{block} = zeros(1, size(FamEEGart{block}, 2));

                cond = 1;
                for phrase = 1:size(FamEEGart{block}, 2)
                    if ~isempty(EEG_tmp{block}{cond, phrase}) && size(EEG_tmp{block}{cond, phrase}, 1) > 1
                        nwin_tmp{block}(cond, phrase) = floor((size(EEG_tmp{block}{cond, phrase}, 1) - wlen) / shift) + 1;

                        for w = 1:nwin_tmp{block}(cond, phrase)
                            tmp = EEG_tmp{block}{cond, phrase}((w-1)*shift+1:(w-1)*shift+wlen, :);

                            if length(find(tmp == 1000)) == 0 && length(find(isnan(tmp) == 1)) == 0
                                % Calculate GPDC
                                mytmp1 = tmp';
                                [eAm, eSu, Yp, Up] = idMVAR(mytmp1, MO, idMode);
                                [~, ~, ~, GPDC_tmp{block}{cond, phrase}(:, :, :, w), ~, ~, ~, h, s, pp, f] = fdMVAR(eAm, eSu, nfft, NSamp);

                                clear tmp mytmp1 h s pp
                            else
                                GPDC_tmp{block}{cond, phrase}(:, :, :, w) = NaN(length(include)*2, length(include)*2, nfft);
                            end
                        end
                    end
                end
            end
        end

        % Average GPDC over windows (COND=1 ONLY)
        avGPDC = cell(size(FamEEGart, 1), 1);
        for block = 1:size(FamEEGart, 1)
            if ~isempty(GPDC_tmp{block})
                avGPDC{block} = cell(1, size(FamEEGart{block}, 2));
                cond = 1;
                for phrase = 1:size(FamEEGart{block}, 2)
                    if ~isempty(GPDC_tmp{block}{cond, phrase}) && length(GPDC_tmp{block}{cond, phrase}) > 1
                        for i = 1:2*length(include)
                            for j = 1:2*length(include)
                                tmp2(i, j, :) = nanmean(abs(GPDC_tmp{block}{cond, phrase}(i, j, :, :)).^2, 4);
                            end
                        end
                        avGPDC{block}{cond, phrase} = tmp2;
                        clear tmp2
                    end
                end
            end
        end

        % Partition GPDC into AA, II, AI, IA (COND=1 ONLY)
        II = {}; AA = {}; AI = {}; IA = {};

        for block = 1:size(avGPDC, 1)
            if ~isempty(avGPDC{block})
                cond = 1;
                for phase = 1:size(avGPDC{block}, 2)
                    if ~isempty(avGPDC{block}{cond, phase}) && nansum(nansum(nansum(avGPDC{block}{cond, phase}))) ~= 0
                        tmp = avGPDC{block}{cond, phase};
                        GPDC_AA = tmp(1:length(include), 1:length(include), :);
                        GPDC_IA = tmp(1:length(include), length(include)+1:length(include)*2, :);
                        GPDC_AI = tmp(length(include)+1:length(include)*2, 1:length(include), :);
                        GPDC_II = tmp(length(include)+1:length(include)*2, length(include)+1:length(include)*2, :);

                        % Store for this block/cond/phase
                        for fplot = 1:length(bands)
                            tmp1g = squeeze(nanmean(GPDC_II(:, :, bands{fplot}), 3));
                            tmp2g = squeeze(nanmean(GPDC_AA(:, :, bands{fplot}), 3));
                            tmp3g = squeeze(nanmean(GPDC_AI(:, :, bands{fplot}), 3));
                            tmp4g = squeeze(nanmean(GPDC_IA(:, :, bands{fplot}), 3));

                            II{block, cond, fplot, phase} = tmp1g;
                            AA{block, cond, fplot, phase} = tmp2g;
                            AI{block, cond, fplot, phase} = tmp3g;
                            IA{block, cond, fplot, phase} = tmp4g;
                        end
                    end
                end
            end
        end

        % Average across phrases for each block/cond/band
        II_final = {}; AA_final = {}; AI_final = {}; IA_final = {};

        for block = 1:size(avGPDC, 1)
            cond = 1;
            for fplot = 1:length(bands)
                tmp1All = [];
                tmp2All = [];
                tmp3All = [];
                tmp4All = [];
                count = 0;

                for phase = 1:size(avGPDC{block}, 2)
                    if ~isempty(II) && size(II, 1) >= block && size(II, 2) >= cond && size(II, 3) >= fplot && size(II, 4) >= phase
                        if ~isempty(II{block, cond, fplot, phase})
                            if isempty(tmp1All)
                                tmp1All = zeros(size(II{block, cond, fplot, phase}));
                                tmp2All = zeros(size(AA{block, cond, fplot, phase}));
                                tmp3All = zeros(size(AI{block, cond, fplot, phase}));
                                tmp4All = zeros(size(IA{block, cond, fplot, phase}));
                            end
                            tmp1All = tmp1All + II{block, cond, fplot, phase};
                            tmp2All = tmp2All + AA{block, cond, fplot, phase};
                            tmp3All = tmp3All + AI{block, cond, fplot, phase};
                            tmp4All = tmp4All + IA{block, cond, fplot, phase};
                            count = count + 1;
                        end
                    end
                end

                if count > 0
                    II_final{block, cond, fplot} = tmp1All / count;
                    AA_final{block, cond, fplot} = tmp2All / count;
                    AI_final{block, cond, fplot} = tmp3All / count;
                    IA_final{block, cond, fplot} = tmp4All / count;
                end
            end
        end

        % Rename for saving
        II = II_final;
        AA = AA_final;
        AI = AI_final;
        IA = IA_final;

        % Save GPDC data
        cd(output_real);
        if loci == 1
            save(sprintf('UK_%s_GPDC.mat', PNo{p}), 'II', 'AI', 'AA', 'IA');
        else
            save(sprintf('SG_%s_GPDC.mat', PNo{p}), 'II', 'AI', 'AA', 'IA');
        end

        clear FamEEGart StimEEGart iEEG_tmp aEEG_tmp EEG_tmp GPDC_tmp nwin_tmp avGPDC II AA AI IA
    end

    fprintf('%s location completed!\n\n', Loc);
end

fprintf('==========================================================\n');
fprintf('Real GPDC calculation completed!\n');
fprintf('Output saved to: %s\n', output_real);
fprintf('==========================================================\n\n');
