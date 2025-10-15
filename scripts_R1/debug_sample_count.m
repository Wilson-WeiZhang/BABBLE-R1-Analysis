%% Debug Sample Count Mismatch
clc; clear all;

basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';

fprintf('==========================================================\n');
fprintf('Debugging Sample Count: Real vs Surrogate\n');
fprintf('==========================================================\n\n');

%% Load behavioral data
[a, b] = xlsread([basepath,'infanteeg/CAM BABBLE EEG DATA/2024/table/behaviour2.5sd.xlsx']);
a(find(sum(isnan(a(:,7)),2)>0),:)=[];

fprintf('Total samples in behavioral data: %d\n', size(a,1));

% Count cond=1 samples
cond1_samples = sum(a(:,6) == 1);
fprintf('Cond=1 samples: %d\n\n', cond1_samples);

%% Check each participant
fprintf('Checking each participant for cond=1...\n');

real_count = 0;
surr_count = 0;

for i = 1:size(a, 1)
    if a(i, 6) == 1  % cond=1 only
        num = a(i, 2);
        if ismember(num, [1113, 1136, 1112, 1116, 2112, 2118, 2119]) == 0
            num_str = num2str(a(i, 2));
            num_str = num_str(2:4);

            block = a(i, 5);
            cond = a(i, 6);

            % Check real file
            if a(i, 1) == 1
                real_file = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/GPDC3_cond1_only/UK_', num_str, '_GPDC.mat'];
                surr_file = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDC_cond1_SET/GPDC1/UK_', num_str, '_GPDC.mat'];
            else
                real_file = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/GPDC3_cond1_only/SG_', num_str, '_GPDC.mat'];
                surr_file = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDC_cond1_SET/GPDC1/SG_', num_str, '_GPDC.mat'];
            end

            % Check if ii3 is not empty in real file
            if exist(real_file, 'file')
                load(real_file, 'II');
                if cond == 1 && ~isempty(II) && size(II, 1) >= block && size(II, 2) >= cond && size(II, 3) >= 3
                    if ~isempty(II{block, cond, 3})
                        real_count = real_count + 1;
                        has_real = true;
                    else
                        has_real = false;
                    end
                else
                    has_real = false;
                end
            else
                has_real = false;
            end

            % Check if ii3 is not empty in surr file
            if exist(surr_file, 'file')
                load(surr_file, 'II');
                if cond == 1 && ~isempty(II) && size(II, 1) >= block && size(II, 2) >= cond && size(II, 3) >= 3
                    if ~isempty(II{block, cond, 3})
                        surr_count = surr_count + 1;
                        has_surr = true;
                    else
                        has_surr = false;
                    end
                else
                    has_surr = false;
                end
            else
                has_surr = false;
            end

            % Report mismatch
            if has_real ~= has_surr
                if a(i, 1) == 1
                    prefix = 'UK';
                else
                    prefix = 'SG';
                end
                fprintf('  MISMATCH: %s_%s, Block %d, Cond %d - Real:%d, Surr:%d\n', ...
                    prefix, num_str, block, cond, has_real, has_surr);
            end
        end
    end
end

fprintf('\n==========================================================\n');
fprintf('Summary:\n');
fprintf('  Real samples: %d\n', real_count);
fprintf('  Surr samples: %d\n', surr_count);
fprintf('  Difference: %d\n', real_count - surr_count);
fprintf('==========================================================\n\n');
