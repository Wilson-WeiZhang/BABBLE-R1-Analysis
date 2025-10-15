
%% do surrogation by shuffling epochs within each subject
% Section 1, calculate GPDC
clc
clear all
%%  load surr.
surrPathPrefix = 'f:\infanteeg\CAM BABBLE EEG DATA\2024\data_matfile\surrGPDCSET5\';
fil=zeros(1000,1);
% 存储读取到的shuffle数据
data_surr = cell(1000,1);
count=0;
z=zeros(1000,1);
for surrIdx = 1:1000
    surrIdx
    surrPath = [surrPathPrefix, num2str(surrIdx)];

    % 检查文件夹中是否有235个.mat文件
    files = dir(fullfile(surrPath, '*.mat'));
    fil(surrIdx)=length(files);
end

typelist={'DC','DTF','PDC','GPDC','COH','PCOH'}
loclist={'C','S'}
include = [4:6,15:17,26:28]'; % included 9-channel grid FA3, CM3, PR3
chLabel = {'F3','Fz','F4','C3','Cz','C4','P3','Pz','P4'};
MO = 7; % Use Model Order = 5 or 8 for 200 samples, max order is number of data points in window. Default = 9 for 3s epoc, 7 for 1.5s epoc, 5 for 1s epoc
idMode = 7; % MVAR method. Default use 0 = least squares or 7 = Nuttall-Strand unbiased partial correlation
NSamp = 200;
len = [1.5]; % 1s, 1.5s or 3s (default 1.5s)
shift = 0.5*len*NSamp; % overlap between windows (default 0.5)
wlen = len*NSamp;
nfft = 256; % 2^(nextpow2(wlen)-1);
nshuff = 0;
load('F:\infanteeg\CAM BABBLE EEG DATA\2024\code\final\surr\windowlist.mat');
windowlist2=windowlist;
clear windowlist


    typelist={'DC','DTF','PDC','GPDC','COH','PCOH'}

for epoc=1+200*4:200*5

    if fil(epoc)<=41

    for loci=1:2
        Loc = loclist{loci}; % C for Cambridge, S for Singapor
        % Load data, filter and compute GPDC
        if strcmp(Loc,'S')==1
            %     PNo = {'101','104','106','107','108','110','112','114','115','215','116','117','118','119','120','121','122','123','127'}; % Singapore (excl 218 and 221 (all/most artifact),127)
            % PNo = {'101','104','106','107','108','110','112','114','115','117','120','121','122','123','127'}; % Singapore (excl 218 and 221 (all/most artifact),127)
            PNo = {'101','104','106','107','108','110','114','115','116','117','120','121','122','123','127'}; % Singapore (excl 218 and 221 (all/most artifact),127)

        elseif strcmp(Loc,'C')==1
            % PNo = {'101','102','104','105','106','107','109','111','114','116','117','118','119','122','123','124','125','126','127','128','132','133'};
            % PNo={'103','108','121','129','131','135'}
            PNo = {'101','102','103','104','105','106','107','108','109','111','114','117','118','119','121','122','123','124','125','126','127','128','129','131','132','133','135'};

        end
        for type=4:4
    ad=['f:\infanteeg\CAM BABBLE EEG DATA\2024\data_matfile\surr',typelist{type},'SET5\',num2str(epoc),'\'];

    if exist(ad)==0
        mkdir(ad)
    end

            for p = 1:length(PNo)
                if loci==1

                    pp=p;
                else

                    pp=p+27;
                end

                windowlist=squeeze(windowlist2(pp,:,:,:,:));


                non_empty_positions=non_empty_positionslist{pp};

                % 获取非空位置的数量
                num_non_empty_positions = size(non_empty_positions, 1);

                % 创建一个随机排列的索引
                num_iterations = 18; % 需要生成的随机排列的数量

                % 预分配一个细胞数组来存储随机排列
                random_orders = cell(1, num_iterations);

                for i = 1:num_iterations
                    random_orders{i} = randperm(num_non_empty_positions);
                end

                % 用于临时存储位置数据的数组
                temp_windowlist = windowlist;

                % 随机调换 non_empty_positions 里面的元素位置
                for idx = 1:num_non_empty_positions
                    % 当前非空位置
                    current_pos = non_empty_positions(idx,:);
                    % 随机非空位置
                    temp=[];
                    for i = 1:num_iterations
                        % 根据随机排列索引 non_empty_positions
                        temporder=random_orders{i};
                        random_positions = non_empty_positions(temporder(idx), :);
                        temp2= [windowlist{random_positions(1),random_positions(2),random_positions(3),random_positions(4)}];
                        temp=[temp,temp2(:,i)];
                    end
                    temp_windowlist{current_pos(1),current_pos(2),current_pos(3),current_pos(4)}=temp;
                end

                % 更新原始的 windowlist
                windowlist = temp_windowlist;
                % %
                for block = 1:size(windowlist,1)
                    for cond = 1:size(windowlist,2)
                        for phrase = 1:size(windowlist,3)
                            for w = 1:size(windowlist,4)
                                if isempty(windowlist{block,cond,phrase,w})==0
                                    % do zscore to make pdc good
                                    tmp = windowlist{block,cond,phrase,w};

                                    mytmp1 = tmp'; % zscore segment by channel, and invert for MVAR script
                                    [eAm,eSu,Yp,Up]=idMVAR(mytmp1,MO,idMode);

                                    try
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
                                    catch
                                        GPDC{block}{cond,phrase}(:,:,:,w)=NaN(length(include)*2,length(include)*2,nfft);
                                    end
                                    clear tmp mytmp1 mytmp2 DC DTF PDC COH PCOH PCOH2 h s pp
                                else
                                    GPDC{block}{cond,phrase}(:,:,:,w)=NaN(length(include)*2,length(include)*2,nfft);
                                end
                            end
                        end
                    end
                end


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
                                avGPDC{block,cond,phrase} = tmp2; clear tmp2
                            else
                                avGPDC{block,cond,phrase} = NaN;
                            end
                        end

                    end
                end

                clear FamEEGart StimEEGart iEEG aEEG EEG GPDC nwin nwinclude

                II={};AA={};AI={};IA={};
                p
                for block = 1:size(avGPDC,1)
                    for cond = 1:size(avGPDC,2)
                        for phase = 1:size(avGPDC,3)
                            if isempty(avGPDC{block,cond,phase})==0 && nansum(nansum(nansum(avGPDC{block,cond,phase})))~=0
                                tmp=avGPDC{block,cond,phase};
                                GPDC_AA{block,cond,phase} = tmp(1:length(include),1:length(include),:); % AA
                                GPDC_IA{block,cond,phase} =  tmp(1:length(include),length(include)+1:length(include)*2,:); % IA
                                GPDC_AI{block,cond,phase} =  tmp(length(include)+1:length(include)*2,1:length(include),:); % AI
                                GPDC_II{block,cond,phase} =  tmp(length(include)+1:length(include)*2,length(include)+1:length(include)*2,:); % II
                            else
                                GPDC_AA{block,cond,phase} = nan;
                                GPDC_AI{block,cond,phase} =  nan;
                                GPDC_IA{block,cond,phase} =  nan;
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
                for block = 1:size(avGPDC,1)
                    for cond = 1:size(avGPDC,2)
                        % 初始化四个三维数组以存储各个tmp变量的累积数据
                        tmp1All = [];
                        tmp2All = [];
                        tmp3All = [];
                        tmp4All = [];
                        count = 0;  % 用于跟踪非空非零矩阵的数量

                        for phase = 1:size(avGPDC,3)
                            if ~isempty(avGPDC{block,cond,phase}) && nansum(nansum(nansum(avGPDC{block,cond,phase}))) ~= 0
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
                cd(ad)
                if loci==1
                    save(sprintf('UK_%s_PDC.mat', PNo{p}), 'II','AI','AA','IA');
                else
                    save(sprintf('SG_%s_PDC.mat', PNo{p}), 'II','AI','AA','IA');
                end

            end
        end
    end
    end
end
