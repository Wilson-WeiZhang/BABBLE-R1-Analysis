%% Check if GPDC1 has all 76 samples
clc; clear all;

basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';

fprintf('Checking GPDC1 surrogate sample count...\n');

[a, b] = xlsread([basepath,'infanteeg/CAM BABBLE EEG DATA/2024/table/behaviour2.5sd.xlsx']);
a(find(sum(isnan(a(:,7)),2)>0),:)=[];

count_new = 0;

for i = 1:size(a,1)
    if a(i,6)==1  % cond=1 only
        num = a(i,2);
        if ismember(num, [1113, 1136, 1112, 1116, 2112, 2118, 2119]) == 0
            num_str = num2str(num);
            num_str = num_str(2:4);
            block = a(i,5);
            cond = a(i,6);

            if a(i,1)==1
                surr_file = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDC_cond1_SET/GPDC1/UK_', num_str, '_GPDC.mat'];
            else
                surr_file = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDC_cond1_SET/GPDC1/SG_', num_str, '_GPDC.mat'];
            end

            if exist(surr_file,'file')
                load(surr_file, 'II');
                if cond==1 && ~isempty(II) && size(II,1)>=block && size(II,2)>=cond && size(II,3)>=3
                    if ~isempty(II{block,cond,3})
                        count_new = count_new + 1;
                    end
                end
            end
        end
    end
end

fprintf('GPDC1 surrogate has %d samples (expected: 76)\n', count_new);

if count_new == 76
    fprintf('✓ GPDC1 is CORRECT!\n');
else
    fprintf('✗ GPDC1 is INCOMPLETE!\n');
end
