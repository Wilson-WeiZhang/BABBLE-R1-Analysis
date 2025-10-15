% Hilber envelope of speech and EEG power correlation:
%      1. modified how windows are calculated to fit the complex NaN-ing of
%      BAMBY.
%      2. Changed to phase permustation instead of time permutation (within
%      window and channel).
%      3. run on HPC (Lorena)

clear all;
% warning('off','all')
% fprintf('Subject: %d is starting/n/n',subject_id);
% pt=subject_id; %just becouse pt is shorter than subject_id
% pt=3;

path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'
dbstop if error
for country=1:2
    sg=country-1;
    resultspath = fullfile([path,'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/']);
    if sg~=1
        datadir = fullfile([path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_camb/']);
    else
        datadir = fullfile([path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_sg/']);
    end
    
    wavfiledir = fullfile([path,'infanteeg/CAM BABBLE EEG DATA/2024/entrain/FromStani/audio_files']);
    syllfiledir = fullfile([path,'infanteeg/CAM BABBLE EEG DATA/2024/entrain/FromStani/']);
    babbledir=[path,'infanteeg/CAM BABBLE EEG DATA/2024/entrain/FromStani/babble_orders_for_lorena/']
    
    %% find sujbects ID and how many we have
    % ONLY INCLUDE SESSION 1 IF HAVE 2 SESSIONS
    if sg==1
        List_ppts=dir([path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_sg/P1*/P1*_BABBLE_AR.mat']);
    else
        List_ppts=dir([path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_camb/P1*/P1*_BABBLE_AR.mat']);
    end
    
    ID={List_ppts.name}';
    
    for pt = 1:length(ID) %18 FOR SG, 29 FOR UK
        
        id=ID{pt};
        Fnames=ID{contains(ID,id)}; %mum and baby file names
        Fnames=Fnames(1:5)
        fprintf('Particiapnt %d out of %d, ID %s, is starting/n/n',pt,numel(ID),id)
        
        List_files=dir(fullfile(strcat(syllfiledir, '/*',id(3:5)),'*_AR_onset.mat'));
        List_files = {List_files.name}';
        
        order_id = extractAfter(List_files, 'P'); order_id = extractBefore(order_id,'S_BABBLE_AR_onset.mat');
        if contains(List_files, 'C_BABBLE')
            order_id = extractAfter(List_files, 'P1'); order_id = extractBefore(order_id,'C_BABBLE_AR_onset.mat');
        end
        
        % Sorting out BABBLE orders mess
        fid = fopen(strcat(babbledir,'orders.txt'));
        babble_orders = textscan(fid, '%f%f', 'delimiter', '/t');
        fclose(fid);
        
        babble_ppts = babble_orders{1,1};
        babble_ppts_oders = babble_orders{1,2};
        
        problems_with_order = 0;
        if length(order_id)>1 && (babble_ppts_oders(babble_ppts==str2num(order_id{1,1})) ~= babble_ppts_oders(babble_ppts==str2num(order_id{2,1})))
            problems_with_order = 1;
        else
            current_order = strcat('order',num2str(babble_ppts_oders(babble_ppts==str2num(order_id{1,1}))));
        end
        
        % wrong wav order in this file.
        % load(strcat(babbledir, 'wavs_in_order.mat'));
        % stim_ids_all = wavs_in_order.(current_order);
        
        %% corrected for order 2 and 3
        load(strcat(babbledir, 'wavs_in_order_correctedfororder23.mat'));
        stim_ids_all = wavs_in_order.(current_order);
        
        current_order
        id
        % 28 15 29
        
        load(strcat(syllfiledir, '/babble_orders_for_lorena/downsampled_onset.mat'), 'ds_onset');
        stim_onsettimes_all = ds_onset{babble_ppts_oders(babble_ppts==str2num(order_id{1,1})),1};
        
        clear babble_orders babble_ppts babble_ppts_oders ds_onset wavs_in_order
        
        % EEG parameters
        NSamp = 200;
        winlen_dp = 400; %samples i.e. 2 secs
        slidewin_dp =400; %same as woverlap but opposite,i.e. 0 overlap is when sliding window = window length.
        woverlap=0; % samples (250==50% overlapping), such that woverlap = winlen_dp - slide
        do_surrogates = 'y';
        numsurr = 0;
        upalpha = 95;%
        fdelta = [1 3];
        ftheta=[3 6];
        falpha=[6 9];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% We have 3 levels: session (if any); n familiarisations (min=1; max=3);
        %%% condition (here a combination b/n language(1:3) A1/A2/A3 and condition
        %%% (1:3)); and phrase (1/2/3), so that is sess = 1 [or 2]; nfamils =
        %%% [1:3] and cond = [1:3] and phrase = [1:3].
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %
        for sessn = 1:length(List_files)
            
            if isequal(current_order, 'order1')==1
                gazeorderforwav = [1,2,3];
            end
            if isequal(current_order, 'order2')==1
                gazeorderforwav = [3,1,2];
            end
            if isequal(current_order, 'order3')==1
                gazeorderforwav = [2,3,1];
            end
            
            
            
            if sg==1
                Fnames=['P0',Fnames(3:5)];
                load(strcat(fullfile(syllfiledir, Fnames), '/',List_files{sessn}), 'FamEEGart');
            else
                load(strcat(fullfile(syllfiledir, Fnames), '/',List_files{sessn}), 'FamEEGart');
            end
            for nfamils = 1:length(FamEEGart)
                % this ncond is L-M-D
                for ncond = 1:size(FamEEGart{nfamils,1},1)
                    
                    for nphrase = 1:size(FamEEGart{nfamils,1},2)
                        
                        %% Load audio, take envelope and dwnsample
                        sfile = fullfile(wavfiledir, strcat(stim_ids_all{gazeorderforwav(ncond), nphrase},'.wav'));
                        [tmpAu1,auFSamp] = audioread(sfile); % Load sound, add 1s of silence at end
                        tmpAu2 = abs(hilbert(tmpAu1)); % Hilbert envelope
                        tmpAu3 = resample(tmpAu2,NSamp,auFSamp); % resample envelope to EEG sampling rate
                        
                        %% Load EEG and find the correct set and times of the
                        %% first 6 syllables (2 phrases)
                        conddata = FamEEGart{nfamils,1}{ncond, nphrase}';
                        if size(conddata,2) <200 % added this due to weird ppts with 1dp collected only, i.e. see P114C
                            conddata = [];
                        end
                        if ~isempty(conddata)
                            samples_first_six_syllables = find(conddata(33,:)==999,7); %(7) is 6 syllables = 2 words (~2.32s);  (10) is 9 syllables = 3 words (3.41s)
                            %                         EEG_first_six_syllables = conddata(4:6,samples_first_six_syllables(1):samples_first_six_syllables(7)-1); %Previously cut data before filtering (naughty naughty, now after) used to be 1:32 i.e. all channels (15:17 C3-Cz-C4, now we average centre in voltage)(4:6 F3-Fz-F4)(26:28 P3-Pz-P4)
                            %  Attempt2: 0 padding    EEG_first_six_syllables = cat(2, zeros(3, 200-samples_first_six_syllables(1)+1), conddata(26:28,1:samples_first_six_syllables(7)-1+200)); %padded
                            
                            
                            data = conddata([4:6, 15:17, 26:28],:);%mean(conddata(26:28,:), 1, 'omitnan'); %was EEG_first_six_syllables only, now is voltage mean (15:17 C3-Cz-C4, now we average centre in voltage)(4:6 F3-Fz-F4)(26:28 P3-Pz-P4)
                            
                            data(data==999)=NaN;
                            data(data==888)=NaN;
                            data(data==777)=NaN;
                            data(isnan(data))=0;
                            
                            %                         define a dummy EEG struct
                            EEGx.nbchan = size(data,1); % number of channels
                            EEGx.pnts = size(data,2);   % number of time points
                            EEGx.trials = 1;            % number of trials
                            EEGx.srate = 200;           % sampling rate
                            EEGx.event = [];
                            EEGx.data = data;           % data (chan x timepoints x trials)
                            data = data(:,samples_first_six_syllables(1):samples_first_six_syllables(7)-1); %select only first 6 syllables
                            
                            %                         calculate power using the Hilbert transform in the whole trial
                            eeghilb_alpha = Hilb_Amp_BABBLE(EEGx,falpha); %Stani renamed 31/10/23 from Hilb_Amp_PL
                            eeghilb_alpha_ampl = squeeze(abs(eeghilb_alpha(1,:,samples_first_six_syllables(1):samples_first_six_syllables(7)-1))); %select only first 6 syllables
                            eeghilb_alpha_ampl(data==0)=NaN';
                            
                            eeghilb_theta = Hilb_Amp_BABBLE(EEGx,ftheta); %Stani renamed 31/10/23 from Hilb_Amp_PL
                            eeghilb_theta_ampl =  squeeze(abs(eeghilb_theta(1,:,samples_first_six_syllables(1):samples_first_six_syllables(7)-1))); %select only first 6 syllables
                            eeghilb_theta_ampl(data==0)=NaN';
                            
                            eeghilb_delta = Hilb_Amp_BABBLE(EEGx,fdelta); %Stani renamed 31/10/23 from Hilb_Amp_PL
                            eeghilb_delta_ampl =  squeeze(abs(eeghilb_delta(1,:,samples_first_six_syllables(1):samples_first_six_syllables(7)-1))); %select only first 6 syllables
                            eeghilb_delta_ampl(data==0)=NaN';
                            
                            
                            %                         calculate a sensible number of lags as per Mike X Cohen
                            nlags_alpha = round(EEGx.srate/falpha(2));
                            nlags_theta = round(EEGx.srate/ftheta(2));
                            nlags_delta = round(EEGx.srate/fdelta(2));
                            
                            %% Crop the speech envelope to match the time window of
                            % % %% the EEG
                            % this ncond is correct
                            current_wav_onset = stim_onsettimes_all{ncond, nphrase};
                            
                            
                            Au_onset_matched = tmpAu3(find(current_wav_onset==999, 1): (samples_first_six_syllables(7)-samples_first_six_syllables(1))-1 + find(current_wav_onset==999, 1));   %:size(EEG_first_six_syllables,2) - was
                            
                            
                            clear tmpAu3 tmpAu2 tmpAu1 conddata current_wav_onset
                            
                            %% Calculate entrainment
                            % %                         note that data are first tiedrank'ed, which results in a Spearman rho
                            % %                         instead of a Pearson r.
                            % %                         From M X Cohen[corrvals,corrlags] = xcov(tiedrank(abs(convolution_result_fft1(:,trial2plot)).^2),tiedrank(abs(convolution_result_fft2(:,trial2plot)).^2),nlags,'coeff');
                            for nchan = 1:EEGx.nbchan
                                
                                %NB had to swap
                                %tiedrank(eeghilb_alpha_ampl(nchan,:)) with
                                %one dim variable due to to volt ave and
                                %squeeze
                                [CondMatx(sessn,nfamils).xcov_alpha{ncond, nphrase}(nchan,:),corrlags_alpha] = xcov(tiedrank(Au_onset_matched),tiedrank(eeghilb_alpha_ampl(nchan,:)'),nlags_alpha,'coeff'); %swapped, was xcov(EEG,Au)
                                %                                 convert correlation lags from indices to time in ms
                                corrlags_alpha = (corrlags_alpha * 1000)/EEGx.srate;
                                [CondMatx(sessn,nfamils).alpha_peak{ncond, nphrase}(nchan), alpha_lag] = max(abs(CondMatx(sessn,nfamils).xcov_alpha{ncond, nphrase}(nchan,:)));
                                if isnan(CondMatx(sessn,nfamils).alpha_peak{ncond, nphrase}(nchan)) CondMatx(sessn,nfamils).alpha_lag{ncond, nphrase}(nchan) = NaN; else %to make lags nans instead of 1s.
                                    CondMatx(sessn,nfamils).alpha_lag{ncond, nphrase}(nchan) = corrlags_alpha(alpha_lag); end
                                
                                [CondMatx(sessn,nfamils).xcov_theta{ncond, nphrase}(nchan,:),corrlags_theta] = xcov(tiedrank(Au_onset_matched),tiedrank(eeghilb_theta_ampl(nchan,:)'),nlags_theta,'coeff');
                                %                                 convert correlation lags from indices to time in ms
                                corrlags_theta = (corrlags_theta * 1000)/EEGx.srate;
                                [CondMatx(sessn,nfamils).theta_peak{ncond, nphrase}(nchan), theta_lag] = max(abs(CondMatx(sessn,nfamils).xcov_theta{ncond, nphrase}(nchan,:)));
                                if isnan(CondMatx(sessn,nfamils).theta_peak{ncond, nphrase}(nchan)) CondMatx(sessn,nfamils).theta_lag{ncond, nphrase}(nchan) = NaN; else
                                    CondMatx(sessn,nfamils).theta_lag{ncond, nphrase}(nchan) = corrlags_theta(theta_lag); end
                                
                                [CondMatx(sessn,nfamils).xcov_delta{ncond, nphrase}(nchan,:),corrlags_delta] = xcov(tiedrank(Au_onset_matched),tiedrank(eeghilb_delta_ampl(nchan,:)'),nlags_delta,'coeff');
                                %                                 convert correlation lags from indices to time in ms
                                corrlags_delta = (corrlags_delta * 1000)/EEGx.srate;
                                [CondMatx(sessn,nfamils).delta_peak{ncond, nphrase}(nchan), delta_lag] = max(abs(CondMatx(sessn,nfamils).xcov_delta{ncond, nphrase}(nchan,:)));
                                if isnan(CondMatx(sessn,nfamils).delta_peak{ncond, nphrase}(nchan)) CondMatx(sessn,nfamils).delta_lag{ncond, nphrase}(nchan) = NaN; else
                                    CondMatx(sessn,nfamils).delta_lag{ncond, nphrase}(nchan) = corrlags_delta(delta_lag); end
                                
                            end
                            
                            %% Gather the data in one place
                            CondMatx(sessn,nfamils).EEG = EEGx;
                            CondMatx(sessn,nfamils).Speech = Au_onset_matched;
                            CondMatx(sessn,nfamils).hilb_alpha = eeghilb_alpha_ampl;
                            CondMatx(sessn,nfamils).hilb_theta= eeghilb_theta_ampl;
                            CondMatx(sessn,nfamils).hilb_delta= eeghilb_delta_ampl;
                            
                            %                             figure
                            %                             plot(corrlags_alpha,CondMatx(sessn,nfamils).xcov_alpha{ncond, nphrase},'-o','markerface','w')
                            %                             hold on
                            %                             plot(corrlags_theta,CondMatx(sessn,nfamils).xcov_theta{ncond, nphrase},'-o','markerface','b')
                            %                             hold on
                            %                             plot(corrlags_delta,CondMatx(sessn,nfamils).xcov_delta{ncond, nphrase},'-o','markerface','r')
                            %                             plot([0 0],get(gca,'ylim'))
                            %                             xlabel(['Speech Amp --- Time lag in ms --- Avg of C3-Cz-C4 leads' ])
                            %                             ylabel('Correlation coefficient')
                            %                             legend('Alpha','Theta','Delta')
                            
                            %                         end
                        end
                    end
                end
            end
        end

        filename = strcat('BABBLE_', ID{pt}, '_power_xcov_allbands_6syll_filtFULLSET_voltaverage_W9chans.mat');
        %% comment by R1 - Commented out to prevent overwriting existing data files
%         save(fullfile(resultspath,filename), 'CondMatx', '-v7.3'); % saving Info
        clear CondMatx samples_first_six_syllables
    end
end