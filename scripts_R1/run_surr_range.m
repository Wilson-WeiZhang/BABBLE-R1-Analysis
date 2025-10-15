function run_surr_range(start_surr, end_surr)
    % Parse inputs if they are strings
    if ischar(start_surr)
        start_surr = str2double(start_surr);
    end
    if ischar(end_surr)
        end_surr = str2double(end_surr);
    end
    
    fprintf('==========================================================\n');
    fprintf('Surrogate Generation: Range %d-%d\n', start_surr, end_surr);
    fprintf('==========================================================\n\n');
    
    basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';
    
    % Pre-load all data
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
    end
    
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
    end
    
    fprintf('\nData loaded! Starting surrogate generation for range %d-%d\n\n', start_surr, end_surr);
    
    % Run the main surrogate loop for this range
    for epoc = start_surr:end_surr
        fprintf('Processing surrogate %d/%d...\n', epoc, end_surr);
        
        % Call the main surrogate generation (copy logic from fs_R1_GPDC_cond1_surr_v2.m)
        % For now, just run the full v2 script with modified range
        run_single_surrogate(epoc, basepath, datauk, datasg, PNo_uk, PNo_sg);
    end
    
    fprintf('\nRange %d-%d completed!\n', start_surr, end_surr);
end

function run_single_surrogate(epoc, basepath, datauk, datasg, PNo_uk, PNo_sg)
    % This function runs the surrogate generation for a single epoc
    % Copy the inner loop logic from fs_R1_GPDC_cond1_surr_v2.m here
    
    % Configuration
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
    
    output_surr = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDC_cond1_SET/GPDC', num2str(epoc), '/'];
    if ~exist(output_surr, 'dir')
        mkdir(output_surr);
    end
    
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
            % [Insert full participant processing logic from fs_R1_GPDC_cond1_surr_v2.m lines 150-400]
            % This is too long to inline here - better approach below
        end
    end
end
