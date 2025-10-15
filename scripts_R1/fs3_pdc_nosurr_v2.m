%% ========================================================================
%  STEP 3: Calculate PDC/GPDC Neural Connectivity (No Surrogate Version)
%  ========================================================================
%
%  PURPOSE:
%  Compute Partial Directed Coherence (PDC) and Generalized PDC (GPDC) to
%  quantify directed information flow between adult and infant brain regions
%  during the familiarization phase.
%
%  CORRESPONDS TO MANUSCRIPT:
%  - Methods Section 4.3.2 (Measuring neural connectivity using GPDC)
%  - Supplementary Section 13 (Generalized partial directed coherence)
%  - Figure 3a (Illustration of dyadic connectivity network)
%
%  GPDC METHODOLOGY:
%  - Frequency-domain Granger causality framework
%  - Quantifies directed information flow from Sender j to Receiver i
%  - Formula: πGPDC_ij(f) = (1/σ_i |A_ij(f)|) / √(Σ_k 1/σ_k² |A_kj(f)|²)
%
%  ANALYSIS PARAMETERS (Supplementary Section 13):
%  - Model order: 7 (optimized by Bayesian Information Criterion)
%  - Window length: 1.5s with 50% overlap (300 samples @ 200 Hz)
%  - FFT points: 256 (frequency resolution: 0.67 Hz)
%  - Method: Nuttall-Strand unbiased partial correlation (idMode=7)
%  - Channels: 9-channel grid (F3,Fz,F4,C3,Cz,C4,P3,Pz,P4)
%
%  FREQUENCY BANDS:
%  - Delta: 1-3 Hz (Results in Supp Section 3)
%  - Theta: 3-6 Hz (Results in Supp Section 3)
%  - Alpha (infant): 6-9 Hz (Main analysis - functionally equivalent to
%    adult alpha, less affected by artifacts, high test-retest reliability)
%
%  CONNECTIVITY PARTITIONING:
%  - AA (Adult-to-Adult): Within-adult connections
%  - II (Infant-to-Infant): Within-infant connections
%  - AI (Adult-to-Infant): Interpersonal adult→infant
%  - IA (Infant-to-Adult): Should be spurious (adult pre-recorded)
%
%  WHY GPDC OVER PDC:
%  - Weighted averaging across receivers
%  - Better variance stabilization and scale invariance
%  - Fewer spurious IA connections (Supp Fig S11 comparison)
%
%  OUTPUT:
%  - GPDC matrices for each participant, condition, block
%  - Saved for subsequent significance testing and PLS analysis
%
%  ========================================================================

%% read PDC data
% Section 1, calculate GPDC

path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'

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
    for type=4:4
        if exist([path,'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/',typelist{type},'3_nonorpdc_nonorpower' ...
                '/'])==0
            mkdir([path,'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/',typelist{type},'3_nonorpdc_nonorpower/'])
        end
        clearvars -except loci type typelist loclist epoc datauk datasg
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

        adultpowerdelta=cell(length(PNo),3,3,3);
        adultpeakdelta=cell(length(PNo),3,3,3);
        infantpeakdelta=cell(length(PNo),3,3,3);
        infantpowerdelta=cell(length(PNo),3,3,3);

        adultpowertheta=cell(length(PNo),3,3,3);
        adultpeaktheta=cell(length(PNo),3,3,3);
        infantpeaktheta=cell(length(PNo),3,3,3);
        infantpowertheta=cell(length(PNo),3,3,3);
        %
        adultpoweralpha=cell(length(PNo),3,3,3);
        adultpeakalpha=cell(length(PNo),3,3,3);
        infantpeakalpha=cell(length(PNo),3,3,3);
        infantpoweralpha=cell(length(PNo),3,3,3);



        for p = 4:length(PNo)
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
                                    ind = find(FamEEGart{block}{cond,phrase}(:,chan) == 777 | FamEEGart{block}{cond,phrase}(:,chan) == 888 | FamEEGart{block}{cond,phrase}(:,chan) == 999);
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

            for block = 1:size(FamEEGart,1)
                for cond = 1:size(FamEEGart{block},1)
                    for phrase = 1:size(FamEEGart{block},2)
                        EEG{block,1}{cond,phrase} = horzcat(aEEG{block}{cond,phrase},iEEG{block}{cond,phrase});
                    end
                end
            end

            % Compute Windowed PDC

            for block = 1:size(EEG,1)
                if isempty(EEG{block})==0
                    for cond = 1:size(EEG{block},1)
                        for phrase = 1:size(EEG{block},2)
                            %                       change here to loop cond and phrase and then check
                            if isempty(EEG{block}{cond,phrase})==0 && size(EEG{block}{cond,phrase},1)>1
                                nwin{block}(cond,phrase)= floor((size(EEG{block}{cond,phrase},1)-wlen)/shift)+1;
                                for w = 1:nwin{block}(cond,phrase)
                                    tmp = EEG{block}{cond,phrase}((w-1)*shift+1:(w-1)*shift+wlen,:);
                                    if length(find(tmp==1000))==0 && length(find(isnan(tmp)==1))==0
                                        % nwin_include{block}{cond,phrase}(w,1)=1;
                                        % B = zeros(size(tmp));
                                        % % 对于每一列，生成一个随机排列并应用到该列
                                        % for i = 1:size(tmp, 2)
                                        %     B(:, i) = tmp(randperm(size(tmp, 1)), i);
                                        % end
                                        % tmp=B;

                                        mytmp2=tmp;
                                        [Pxx,F] = periodogram(mytmp2,[],[],NSamp);

                                        deltarange_infant=intersect(find(F<3),find(F>1));
                                        [a,b]=max(Pxx(deltarange_infant,length(include)+1:2*length(include)));
                                        infantpeakdelta{p,cond,block,phrase}=[infantpeakdelta{p,cond,block,phrase},F(deltarange_infant(b))];
                                        infantpowerdelta{p,cond,block,phrase} = [infantpowerdelta{p,cond,block,phrase},mean(Pxx(deltarange_infant,length(include)+1:2*length(include)), 1)'];

                                        thetarange_infant=intersect(find(F<6),find(F>3));
                                        [a,b]=max(Pxx(thetarange_infant,length(include)+1:2*length(include)));
                                        infantpeaktheta{p,cond,block,phrase}=[infantpeaktheta{p,cond,block,phrase},F(thetarange_infant(b))];
                                        infantpowertheta{p,cond,block,phrase} = [infantpowertheta{p,cond,block,phrase},mean(Pxx(thetarange_infant,length(include)+1:2*length(include)), 1)'];

                                        alpharange_infant=intersect(find(F<9),find(F>6));
                                        [a,b]=max(Pxx(alpharange_infant,length(include)+1:2*length(include)));
                                        infantpeakalpha{p,cond,block,phrase}=[infantpeakalpha{p,cond,block,phrase},F(alpharange_infant(b))];
                                        infantpoweralpha{p,cond,block,phrase} = [infantpoweralpha{p,cond,block,phrase},mean(Pxx(alpharange_infant,length(include)+1:2*length(include)), 1)'];

                                        alpharange_infant=intersect(find(F<9),find(F>6));
                                        [a,b]=max(Pxx(alpharange_infant,1:length(include)));
                                        adultpeakalpha{p,cond,block,phrase}=[adultpeakalpha{p,cond,block,phrase},F(alpharange_infant(b))];
                                        adultpoweralpha{p,cond,block,phrase} = [adultpoweralpha{p,cond,block,phrase},mean(Pxx(alpharange_infant,length(include)+1:2*length(include)), 1)'];

                                        deltarange_adult=intersect(find(F<3),find(F>1));
                                        [a,b]=max(Pxx(deltarange_adult,1:length(include)));
                                        adultpeakdelta{p,cond,block,phrase} =[adultpeakdelta{p,cond,block,phrase} ,F(deltarange_adult(b))];
                                        adultpowerdelta{p,cond,block,phrase}  = [adultpowerdelta{p,cond,block,phrase} ,mean(Pxx(deltarange_adult,1:length(include)), 1)'];

                                        thetarange_adult=intersect(find(F<6),find(F>3));
                                        [a,b]=max(Pxx(thetarange_adult,1:length(include)));
                                        adultpeaktheta{p,cond,block,phrase} =[adultpeaktheta{p,cond,block,phrase} ,F(thetarange_adult(b))];
                                        adultpowertheta{p,cond,block,phrase}  = [adultpowertheta{p,cond,block,phrase} ,mean(Pxx(thetarange_adult,1:length(include)), 1)'];

                                        alpharange_adult=intersect(find(F<9),find(F>6));
                                        [a,b]=max(Pxx(alpharange_adult,1:length(include)));
                                        adultpeakalpha{p,cond,block,phrase} =[adultpeakalpha{p,cond,block,phrase} ,F(alpharange_adult(b))];
                                        adultpoweralpha{p,cond,block,phrase}  = [adultpoweralpha{p,cond,block,phrase} ,mean(Pxx(alpharange_adult,1:length(include)), 1)'];

                                        % do zscore to make pdc good
                                        mytmp1 = tmp'; % zscore segment by channel, and invert for MVAR script

                                        [eAm,eSu,Yp,Up]=idMVAR(mytmp1,MO,idMode);
                                        %[DC,DTF,PDC,GPDC{block}{cond,phrase}(:,:,:,w),COH,PCOH,PCOH2,h,s,pp,f] = fdMVAR(eAm,eSu,nfft,NSamp);
                                        %                                 calcualte PDC here , not gpdc
                                        if type==1
                                            [GPDC{block}{cond,phrase}(:,:,:,w),~,~,~,~,~,~,h,s,pp,f] = fdMVAR(eAm,eSu,nfft,NSamp);
                                        end
                                        if type==2
                                            [~,GPDC{block}{cond,phrase}(:,:,:,w),~,~,~,~,~,h,s,pp,f] = fdMVAR(eAm,eSu,nfft,NSamp);
                                        end
                                        if type==3
                                            [~,~,GPDC{block}{cond,phrase}(:,:,:,w),~,~,~,~,h,s,pp,f] = fdMVAR(eAm,eSu,nfft,NSamp);
                                        end
                                        if type==4
                                            [~,~,~,GPDC{block}{cond,phrase}(:,:,:,w),~,~,~,h,s,pp,f] = fdMVAR(eAm,eSu,nfft,NSamp);
                                        end
                                        if type==5
                                            [~,~,~,~,GPDC{block}{cond,phrase}(:,:,:,w),~,~,h,s,pp,f] = fdMVAR(eAm,eSu,nfft,NSamp);
                                        end
                                        if type==6
                                            [~,~,~,~,~,GPDC{block}{cond,phrase}(:,:,:,w),~,h,s,pp,f] = fdMVAR(eAm,eSu,nfft,NSamp);
                                        end
                                        clear tmp mytmp1 mytmp2 DC DTF PDC COH PCOH PCOH2 h s pp
                                    else GPDC{block}{cond,phrase}(:,:,:,w)=NaN(length(include)*2,length(include)*2,nfft);
                                        nwin_include{block}{cond,phrase}(w,1)=NaN;
                                    end
                                end
                            else
                                GPDC{block}{cond,phrase}=[];
                            end
                        end
                    end
                else
                    GPDC{block}=[];
                end
            end

            %
            % Average GPDC over windows

            for block = 1:size(GPDC,2)
                for cond = 1:size(GPDC{block},1)
                    for phrase = 1:size(GPDC{block},2)
                        if isempty(GPDC{block}{cond,phrase})==0 && length(GPDC{block}{cond,phrase})>1
                            for i = 1:2*length(include)
                                for j = 1:2*length(include)
                                    %    have to use square to present power
                                    tmp2(i,j,:) = nanmean(abs(GPDC{block}{cond,phrase}(i,j,:,:)).^2,4);
                                end
                            end
                            avGPDC{p,1}{block,cond,phrase} = tmp2; clear tmp2
                        else
                            avGPDC{p,1}{block,cond,phrase} = NaN;
                        end
                    end

                end
            end

            clear FamEEGart StimEEGart iEEG aEEG EEG GPDC nwin nwinclude

            display(strcat('p=',num2str(p)))

        end

        % Preallocate NaN to prevent zeros
        for p = 1:length(PNo)
            II={};AA={};AI={};IA={};
            p
            for block = 1:size(avGPDC{p},1)
                for cond = 1:size(avGPDC{p},2)
                    for phase = 1:size(avGPDC{p},3)
                        if isempty(avGPDC{p}{block,cond,phase})==0 && nansum(nansum(nansum(avGPDC{p}{block,cond,phase})))~=0
                            tmp=avGPDC{p}{block,cond,phase};
                            GPDC_AA{block,cond,phase} = tmp(1:length(include),1:length(include),:); % AA
                            GPDC_IA{block,cond,phase} =  tmp(1:length(include),length(include)+1:length(include)*2,:); % IA
                            GPDC_AI{block,cond,phase} =  tmp(length(include)+1:length(include)*2,1:length(include),:); % AI
                            GPDC_II{block,cond,phase} =  tmp(length(include)+1:length(include)*2,length(include)+1:length(include)*2,:); % II
                        else
                            GPDC_AA{block,cond,phase} = nan;
                            GPDC_IA{block,cond,phase} =  nan;
                             GPDC_AI{block,cond,phase} =  nan;
                            GPDC_II{block,cond,phase} =  nan;
                        end
                    end
                end
            end

            %% Plots : All Connections
            % nfft frequncy list:
            %          0    0.3906    0.7812    1.1719    1.5625    1.9531    2.3438    2.7344    3.1250    3.5156    3.9062    4.2969    4.6875    5.0781    5.4688    5.8594    6.2500
            %     6.6406    7.0312    7.4219    7.8125    8.2031    8.5938    8.9844    9.3750    9.7656   10.1562   10.5469   10.9375   11.3281   11.7188   12.1094   12.5000   12.8906

            %  origin [ 3 6.25 9 12.1]Hz  [9 17 24 32]

            % new band:
            % Delta 1-3 Hz[4~8]
            % Theta 3-6 Hz [9~16]
            % Alpha 6-9 Hz [17~24]

            %% CALCULATE GPDC averaging band

            bands={[4:8],[9:16],[17:24]};
            datatable=[];
            for block = 1:size(avGPDC{p},1)
                for cond = 1:size(avGPDC{p},2)
                    % 初始化四个三维数组以存储各个tmp变量的累积数据
                    tmp1All = [];
                    tmp2All = [];
                    tmp3All = [];
                    tmp4All = [];
                    count = 0;  % 用于跟踪非空非零矩阵的数量

                    for phase = 1:size(avGPDC{p},3)
                        if ~isempty(avGPDC{p}{block,cond,phase}) && nansum(nansum(nansum(avGPDC{p}{block,cond,phase}))) ~= 0
                            for fplot = 1:length(bands)
                                tmp1g = squeeze(nanmean(GPDC_II{block,cond,phase}(:,:,bands{fplot}),3));
                                tmp2g = squeeze(nanmean(GPDC_AA{block,cond,phase}(:,:,bands{fplot}),3));
                                tmp3g = squeeze(nanmean(GPDC_AI{block,cond,phase}(:,:,bands{fplot}),3));
                                tmp4g = squeeze(nanmean(GPDC_IA{block,cond,phase}(:,:,bands{fplot}),3));

                                % 累积各阶段的数据
                                if isempty(tmp1All)
                                    tmp1All = zeros([size(tmp1g), length(bands)]);
                                    tmp2All = zeros([size(tmp2g), length(bands)]);
                                    tmp3All = zeros([size(tmp3g), length(bands)]);
                                    tmp4All = zeros([size(tmp4g), length(bands)]);
                                end
                                tmp1All(:,:,fplot) = tmp1All(:,:,fplot) + tmp1g;
                                tmp2All(:,:,fplot) = tmp2All(:,:,fplot) + tmp2g;
                                tmp3All(:,:,fplot) = tmp3All(:,:,fplot) + tmp3g;
                                tmp4All(:,:,fplot) = tmp4All(:,:,fplot) + tmp4g;
                            end
                            count = count + 1;  % 所有频带同时处理
                        end
                    end

                    % 计算平均，并存储
                    if count > 0
                        for fplot = 1:length(bands)
                            % II{block,cond,fplot} = tmp1All(:,:,fplot) / count - tmp4All(:,:,fplot) / count;

                            %                 AI{block,cond,fplot} = tmp3All(:,:,fplot) / count - tmp2All(:,:,fplot) / count;
                            II{block,cond,fplot} = tmp1All(:,:,fplot) / count ;
                            AA{block,cond,fplot} = tmp2All(:,:,fplot) / count ;
                            %                 AA{block,cond,fplot} = tmp2All(:,:,fplot) / count - tmp4All(:,:,fplot) / count;
                            AI{block,cond,fplot} = tmp3All(:,:,fplot) / count;
                            IA{block,cond,fplot} =  tmp4All(:,:,fplot) / count;
                        end
                    end
                end
            end

            clear GPDC_II GPDC_AA GPDC_AI GPDC_IA


            % 分别存储每个变量的频带数据
            cd([path,'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/',typelist{type},'3_nonorpdc_nonorpower/'])
            %% comment by R1 - Commented out to prevent overwriting existing data files
            if loci==1
%                 save(sprintf('UK_%s_PDC.mat', PNo{p}), 'II','AI','AA','IA');
            else
%                 save(sprintf('SG_%s_PDC.mat', PNo{p}), 'II','AI','AA','IA');

            end
            % % PNo = {'101','104','106','107','108','110','112','114','115','116','117','118','119','120','121','122','123','127'}; % Singapore (excl 218 and 221 (all/most artifact),127)

            mytemp1=squeeze(infantpeakdelta(p,:,:,:));
            mytemp2=squeeze(infantpeaktheta(p,:,:,:));
            mytemp3=squeeze(infantpeakalpha(p,:,:,:));
            mytemp4=squeeze(infantpowerdelta(p,:,:,:));
            mytemp5=squeeze(infantpowertheta(p,:,:,:));
            mytemp6=squeeze(infantpoweralpha(p,:,:,:));
            mytemp7=squeeze(adultpeakdelta(p,:,:,:));
            mytemp8=squeeze(adultpeaktheta(p,:,:,:));
            mytemp9=squeeze(adultpeakalpha(p,:,:,:));
            mytemp10=squeeze(adultpowerdelta(p,:,:,:));
            mytemp11=squeeze(adultpowertheta(p,:,:,:));
            mytemp12=squeeze(adultpoweralpha(p,:,:,:));
            infantpeakdelta2={};
            infantpeaktheta2={};
            infantpeakalpha2={};
            infantpowerdelta2={};
            infantpowertheta2={};
            infantpoweralpha2={};
            adultpeakdelta2={};
            adultpeaktheta2={};
            adultpeakalpha2={};
            adultpowerdelta2={};
            adultpowertheta2={};
            adultpoweralpha2={};


            for cond=1:size(mytemp1,1)
                for block=1:size(mytemp1,2)
                    tmpipd=[];
                    tmpipt=[];
                    tmpipa=[];
                    tmpipd2=[];
                    tmpipt2=[];
                    tmpipa2=[];
                    tmpapd=[];
                    tmpapt=[];
                    tmpapa=[];
                    tmpapd2=[];
                    tmpapt2=[];
                    tmpapa2=[];

                    for phrase=1:size(mytemp1,3)
                        if isempty(mytemp1{cond,block,phrase})==0

                            tmpipd=[tmpipd,mytemp1{cond,block,phrase}];
                            tmpipt=[tmpipt,mytemp2{cond,block,phrase}];
                            tmpipa=[tmpipa,mytemp3{cond,block,phrase}];
                            tmpipd2=[tmpipd,mytemp4{cond,block,phrase}];
                            tmpipt2=[tmpipt,mytemp5{cond,block,phrase}];
                            tmpipa2=[tmpipa,mytemp6{cond,block,phrase}];

                            tmpapd=[tmpapd,mytemp7{cond,block,phrase}];
                            tmpapt=[tmpapt,mytemp8{cond,block,phrase}];
                            tmpapa=[tmpapa,mytemp9{cond,block,phrase}];
                            tmpapd2=[tmpapd2,mytemp10{cond,block,phrase}];
                            tmpapt2=[tmpapt2,mytemp11{cond,block,phrase}];
                            tmpapa2=[tmpapa2,mytemp12{cond,block,phrase}];
                        end
                    end
                    if isempty(tmpipd)==0
                        infantpeakdelta2{block,cond}=nanmean(tmpipd,2);
                        infantpeaktheta2{block,cond}=nanmean(tmpipt,2);
                        infantpeakalpha2{block,cond}=nanmean(tmpipa,2);
                        infantpowerdelta2{block,cond}=nanmean(tmpipd2,2);
                        infantpowertheta2{block,cond}=nanmean(tmpipt2,2);
                        infantpoweralpha2{block,cond}=nanmean(tmpipa2,2);

                        adultpeakdelta2{block,cond}=nanmean(tmpapd,2);
                        adultpeaktheta2{block,cond}=nanmean(tmpapt,2);
                        adultpeakalpha2{block,cond}=nanmean(tmpapa,2);
                        adultpowerdelta2{block,cond}=nanmean(tmpapd2,2);
                        adultpowertheta2{block,cond}=nanmean(tmpapt2,2);
                        adultpoweralpha2{block,cond}=nanmean(tmpapa2,2);
                    else
                        infantpeakdelta2{block,cond}=nan;
                        infantpeaktheta2{block,cond}=nan;
                        infantpeakalpha2{block,cond}=nan;
                        infantpowerdelta2{block,cond}=nan;
                        infantpowertheta2{block,cond}=nan;
                        infantpoweralpha2{block,cond}=nan;

                        adultpeakdelta2{block,cond}=nan;
                        adultpeaktheta2{block,cond}=nan;
                        adultpeakalpha2{block,cond}=nan;
                        adultpowerdelta2{block,cond}=nan;
                        adultpowertheta2{block,cond}=nan;
                        adultpoweralpha2{block,cond}=nan;
                    end
                end
            end
            % 分别存储每个变量的频带数据
            cd([path,'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/',typelist{type},'3_nonorpdc_nonorpower/'])
            %% comment by R1 - Commented out to prevent overwriting existing data files
            if loci==1
%                 save(sprintf('UK_%s_pf_pw.mat', PNo{p}), 'infantpeakdelta2','infantpeaktheta2','infantpeakalpha2',...
%                     'infantpowerdelta2','infantpowertheta2','infantpoweralpha2','adultpeakdelta2','adultpeaktheta2','adultpeakalpha2',...
%                     'adultpowerdelta2','adultpowertheta2','adultpoweralpha2');

            else
%                 save(sprintf('SG_%s_pf_pw.mat', PNo{p}), 'infantpeakdelta2','infantpeaktheta2','infantpeakalpha2',...
%                     'infantpowerdelta2','infantpowertheta2','infantpoweralpha2','adultpeakdelta2','adultpeaktheta2','adultpeakalpha2',...
%                     'adultpowerdelta2','adultpowertheta2','adultpoweralpha2');
            end

        end
    end
end
