% babbledir = 'C:/Users/BL1/OneDrive - Nanyang Technological University/Stani/BABBLE/';
% addpath(genpath(babbledir));
clc
clear all
path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'
for country=1:2

sg=country-1;
if sg ==1
    datadir = fullfile([path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_sg/']);
    List_ppts=dir([path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_sg/P*/P1*_BABBLE_AR.mat']);
else
    datadir = fullfile([path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_camb/']);
    List_ppts=dir([path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_camb/P*/*_BABBLE_AR.mat']);
end
resultspath=[path,'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/entrain'];

ID={List_ppts.name}';
% CUT 211 ETC IF SG
if sg==1;
    % sg
    order_for_current_participants = [1,1,3,1,2,1,3,2,3,1,2,3,1,2,3,1,2,3];
else
    % camb
    order_for_current_participants = [1,2,3,1,2,3,1,2,3,2,3,2,1,2,3,1,3,1,2,3,1,2,3,1,2,1,2,3,2];
end
alpha_peak=[];
alpha_lag=[];
theta_peak=[];
theta_lag=[];
delta_peak=[];
delta_lag=[];
for pt = 1:length(ID)
    filename = strcat('BABBLE_', ID{pt}, '_power_xcov_allbands_6syll_filtFULLSET_voltaverage_W9chans.mat');
    load(fullfile(resultspath,filename), 'CondMatx'); % saving Info
    % if order_for_current_participants(pt) == 1 conditions_order = [1 2 3]; elseif order_for_current_participants(pt) == 2 conditions_order = [2 1 3]; ...
    % elseif order_for_current_participants(pt) == 3 conditions_order = [3 2 1]; end
    conditions_order=[1 2 3];
    for sessn = 1:1
        for nfamils = 1:size(CondMatx,2)
            if ~isempty(CondMatx(sessn,nfamils).alpha_peak)
                for ncond = 1:size(CondMatx(sessn,nfamils).alpha_peak, 1)
                    for nphrase = 1:size(CondMatx(sessn,nfamils).alpha_peak, 2)
                        if ~isempty(CondMatx(sessn,nfamils).alpha_peak{ncond,nphrase})
                            alpha_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = CondMatx(sessn,nfamils).alpha_peak{ncond,nphrase};
                            % alpha_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = CondMatx(sessn,nfamils).xcov_alpha{ncond,nphrase}(:,(length(CondMatx(sessn,nfamils).xcov_alpha{ncond,nphrase})+1)/2);
                            
                            alpha_lag(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = CondMatx(sessn,nfamils).alpha_lag{ncond,nphrase};
                            theta_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = CondMatx(sessn,nfamils).theta_peak{ncond,nphrase};
                            % theta_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = CondMatx(sessn,nfamils).xcov_theta{ncond,nphrase}(:,(length(CondMatx(sessn,nfamils).xcov_theta{ncond,nphrase})+1)/2);
                            
                            theta_lag(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = CondMatx(sessn,nfamils).theta_lag{ncond,nphrase};
                            delta_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = CondMatx(sessn,nfamils).delta_peak{ncond,nphrase};
                            % delta_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = CondMatx(sessn,nfamils).xcov_delta{ncond,nphrase}(:,(length(CondMatx(sessn,nfamils).xcov_delta{ncond,nphrase})+1)/2);
                            
                            delta_lag(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = CondMatx(sessn,nfamils).delta_lag{ncond,nphrase};
                        else
                            alpha_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt)=nan;
                            alpha_lag(:,conditions_order(ncond),nphrase,nfamils,sessn,pt)=nan;
                            theta_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt)=nan;
                            theta_lag(:,conditions_order(ncond),nphrase,nfamils,sessn,pt)=nan;
                            delta_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt)=nan;
                            delta_lag(:,conditions_order(ncond),nphrase,nfamils,sessn,pt)=nan;
                        end

                    end
                end
            end
        end
    end
end



% 定义通道名称
channels = {'F3', 'FZ', 'F4', 'C3', 'CZ', 'C4', 'P3', 'PZ', 'P4'};

% 初始化一个数组来存储所有的行
data = [];
IDS={};
% 遍历所有维度
for pt = 1:length(ID)
    filename = strcat('BABBLE_', ID{pt}, '_power_xcov_allbands_6syll_filtFULLSET_voltaverage_W9chans.mat');
    load(fullfile(resultspath,filename), 'CondMatx'); % saving Info
    for sessn = 1:1  % 只有一个session
        for nfamils = 1:size(CondMatx, 2)
            for ncond = 1:3
                for nphrase = 1:3
                    % 创建新的行
                    new_row = [
                        nfamils, ncond, nphrase, ...
                        alpha_peak(:,ncond,nphrase,nfamils,sessn,pt)', ...
                        alpha_lag(:,ncond,nphrase,nfamils,sessn,pt)', ...
                        theta_peak(:,ncond,nphrase,nfamils,sessn,pt)', ...
                        theta_lag(:,ncond,nphrase,nfamils,sessn,pt)', ...
                        delta_peak(:,ncond,nphrase,nfamils,sessn,pt)', ...
                        delta_lag(:,ncond,nphrase,nfamils,sessn,pt)'
                        ];

                    % 将新行添加到数据中
                    if length(find(new_row==0))<5
                        data = [data; new_row];
                        IDS=[IDS;ID(pt )];
                    else
                        new_row(find(new_row==0))=nan;
                        data = [data; new_row];
                            IDS=[IDS;ID(pt )];
                    end
                end
            end
        end
    end
end

% 创建列名
column_names = {'nfamils', 'conditions_order', 'nphrase'};
metrics = {'alpha_peak', 'alpha_lag', 'theta_peak', 'theta_lag', 'delta_peak', 'delta_lag'};
for i = 1:length(metrics)
    for j = 1:length(channels)
        column_names = [column_names, sprintf('%s_%s', metrics{i}, channels{j})];
    end
end

% 将数据转换为表格
result_table = array2table(data, 'VariableNames', column_names);

% 在表格的开头插入ID列
result_table = addvars(result_table, IDS, 'Before', 'nfamils', 'NewVariableNames', {'ID'});

% 确保ID列只包含前5个字符
result_table.ID = cellfun(@(x) x(1:min(5,length(x))), result_table.ID, 'UniformOutput', false);

% 显示表格的前几行
head(result_table)

if sg==1
    result_table_sg=result_table;
else
    result_table_ca=result_table;
end
end
table_combined=[result_table_ca;result_table_sg];

% write to ENTRAINTABLE.xlsx