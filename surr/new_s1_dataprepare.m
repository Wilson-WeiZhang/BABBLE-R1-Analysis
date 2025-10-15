
Loc='S'
filepath = 'f:\infanteeg\CAM BABBLE EEG DATA\Preprocessed Data_sg\';
% PNo = {'101','104','106','107','108','110','112','114','115','116','117','118','119','120','121','122','123','127'}; % Singapore (excl 218 and 221 (all/most artifact),127)
PNo = {'101','104','106','107','108','110','114','115','116','117','120','121','122','123','127'}; % Singapore (excl 218 and 221 (all/most artifact),127)
% PNo={'116'};
datasg = struct();
for p = 1:length(PNo)
    filename = strcat(filepath, '\P', PNo{p}, Loc, '\', 'P', PNo{p}, Loc, '_BABBLE_AR.mat');
    loadedData = load(filename, 'FamEEGart', 'StimEEGart');
    datasg(p).FamEEGart = loadedData.FamEEGart;
    datasg(p).StimEEGart = loadedData.StimEEGart;
end

Loc='C'

filepath = 'f:\infanteeg\CAM BABBLE EEG DATA\Preprocessed Data_camb\';
PNo = {'101','102','103','104','105','106','107','108','109','111','114','117','118','119','121','122','123','124','125','126','127','128','129','131','132','133','135'};
% PNo = {'101','102','104','105','106','107','109','111','114','116','117','118','119','122','123','124','125','126','127','128','132','133'};
% PNo={'103','108','121','129','131','135'}


datauk = struct();
for p = 1:length(PNo)
    filename = strcat(filepath, '\P', PNo{p}, Loc, '\', 'P', PNo{p}, Loc, '_BABBLE_AR.mat');
    loadedData = load(filename, 'FamEEGart', 'StimEEGart');
    datauk(p).FamEEGart = loadedData.FamEEGart;
    datauk(p).StimEEGart = loadedData.StimEEGart;
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
  windowlist=cell(3,3,3,1);



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


    for p = 1:length(PNo)
   
      
        if loci==1
            % filename = strcat(filepath,'\P',PNo{p},Loc,'\','P',PNo{p},Loc,'_BABBLE_AR.mat');
            FamEEGart=datauk(p).FamEEGart;
            StimEEGart=datauk(p).StimEEGart;
            pp=p;
        else
            FamEEGart=datasg(p).FamEEGart;
            StimEEGart=datasg(p).StimEEGart;
            pp=p+27;
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
                                    windowlist{pp,block,cond,phrase,w}=tmp;
                                else
                                    windowlist{pp,block,cond,phrase,w}=[];
                                end
                            end
                        end
                    end
                end
            end
        end
                clear FamEEGart StimEEGart iEEG aEEG EEG GPDC nwin nwinclude

                    display(strcat('p=',num2str(p)))
    end
end


      % surrogate window pairs
                    % 假设你的windowlist大小为 (3, 3, 3, n)\
                    for ii=1:42
                        windowlist2=squeeze(windowlist(ii,:,:,:,:));
                    [dim1, dim2, dim3, dim4] = size(windowlist2);
                    vector_length = 300 * 18;

                    % 初始化一个空的cell数组来存储非空的位置
                    non_empty_positions = [];

                    % 遍历所有可能的位置
                    for i = 1:dim1
                        for j = 1:dim2
                            for k = 1:dim3
                                for l = 1:dim4
                                    % 检查当前的cell是否非空且为300*18的向量
                                    if ~isempty(windowlist2{i,j,k,l}) && isequal(size(windowlist2{i,j,k,l}), [300, 18])
                                        non_empty_positions = [non_empty_positions; [i, j, k, l]];
                                    end
                                end
                            end
                        end
                    end
                    non_empty_positionslist{ii}=non_empty_positions;
                    end
                    