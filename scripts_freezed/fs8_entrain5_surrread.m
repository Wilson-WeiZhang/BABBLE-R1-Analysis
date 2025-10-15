%% read the permutation results for entrainment
clc
clear all
load("dataGPDC.mat");
% load('ENTRIANSURR.mat','permutable');
permutable=cell(1000,1);

path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'
for permu = 1:1000
    permu
    % if length(dir(['F:/infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/permuentrain/permu', num2str(permu),'/*.mat']))==47 && (isempty(permutable{permu})==1||length(permutable)<i)
        for country = 1:2
            sg = country - 1;

            if sg == 1
                datadir = fullfile([path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_sg/']);
                List_ppts = dir([datadir 'P*/P1*_BABBLE_AR.mat']);
            else
                datadir = fullfile([path,'infanteeg/CAM BABBLE EEG DATA/Preprocessed Data_camb/']);
                List_ppts = dir([datadir 'P*/*_BABBLE_AR.mat']);
            end
            resultspath = [path,'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/permuentrain/permu', num2str(permu)];

            ID = {List_ppts.name}';

            if sg == 1
                order_for_current_participants = [1,1,3,1,2,1,3,2,3,1,2,3,1,2,3,1,2,3];
            else
                order_for_current_participants = [1,2,3,1,2,3,1,2,3,2,3,2,1,2,3,1,3,1,2,3,1,2,3,1,2,1,2,3,2];
            end

            alpha_peak = [];
            alpha_lag = [];
            theta_peak = [];
            theta_lag = [];
            delta_peak = [];
            delta_lag = [];

            for pt = 1:length(ID)

                Fname = ID{pt};
                if sg == 1
                    Fname = ['P0', Fname(3:5)];
                else
                    Fname = Fname(1:5);
                end
                filename = [Fname, '_permu', num2str(permu), '.mat'];
                load(fullfile(resultspath, filename), 'CondMatx');
                conditions_order = [1 2 3];

                for sessn = 1:1
                    for nfamils = 1:size(CondMatx, 2)
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
                                        alpha_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = nan(1, 9);
                                        alpha_lag(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = nan(1, 9);
                                        theta_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = nan(1, 9);
                                        theta_lag(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = nan(1, 9);
                                        delta_peak(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = nan(1, 9);
                                        delta_lag(:,conditions_order(ncond),nphrase,nfamils,sessn,pt) = nan(1, 9);
                                    end
                                end
                            end
                        end
                    end
                end
            end

            channels = {'F3', 'FZ', 'F4', 'C3', 'CZ', 'C4', 'P3', 'PZ', 'P4'};
            data = [];
            IDS = {};

            for pt = 1:length(ID)
                Fname = ID{pt};
                if sg == 1
                    Fname = ['P0', Fname(3:5)];
                else
                    Fname = Fname(1:5);
                end
                filename = [Fname, '_permu', num2str(permu), '.mat'];
                load(fullfile(resultspath, filename), 'CondMatx');

                conditions_order = [1 2 3];

                for sessn = 1:1
                    for nfamils = 1:size(CondMatx, 2)
                        for ncond = 1:3
                            for nphrase = 1:3
                                new_row = [
                                    nfamils, ncond, nphrase, ...
                                    squeeze(alpha_peak(:,ncond,nphrase,nfamils,sessn,pt))', ...
                                    squeeze(alpha_lag(:,ncond,nphrase,nfamils,sessn,pt))', ...
                                    squeeze(theta_peak(:,ncond,nphrase,nfamils,sessn,pt))', ...
                                    squeeze(theta_lag(:,ncond,nphrase,nfamils,sessn,pt))', ...
                                    squeeze(delta_peak(:,ncond,nphrase,nfamils,sessn,pt))', ...
                                    squeeze(delta_lag(:,ncond,nphrase,nfamils,sessn,pt))'
                                    ];
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

            column_names = {'nfamils', 'conditions_order', 'nphrase'};
            metrics = {'alpha_peak', 'alpha_lag', 'theta_peak', 'theta_lag', 'delta_peak', 'delta_lag'};
            for i = 1:length(metrics)
                for j = 1:length(channels)
                    column_names = [column_names, sprintf('%s_%s', metrics{i}, channels{j})];
                end
            end

            result_table = array2table(data, 'VariableNames', column_names);

            if sg == 1
                result_table_sg = result_table;
                id_sg = IDS;
            else
                result_table_ca = result_table;
                id_ca = IDS;
            end
        end

        result_table = [result_table_ca; result_table_sg];
        result_table = addvars(result_table, [id_ca; id_sg], 'Before', 'nfamils', 'NewVariableNames', {'ID'});


        head(result_table)
        permutable{permu}=result_table;

        % nanmean(result_table(:,1))
        % writetable(result_table, ['result_table_permu_', num2str(permu), '.csv']);


    % end
end
%% comment by R1 - Commented out to prevent overwriting existing data files
% save('ENTRIANSURR.mat','permutable' )

