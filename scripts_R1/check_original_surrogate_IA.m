%% Check Original Surrogate (SET5) IA Values
clc; clear all;

basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';

fprintf('==========================================================\n');
fprintf('Checking Original Surrogate (surrPDCSET5) IA Alpha\n');
fprintf('==========================================================\n\n');

%% Check original surrogate file
surr_path = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrPDCSET5/PDC1/'];

test_file = [surr_path, 'UK_101_PDC.mat'];
if exist(test_file, 'file')
    fprintf('Loading original surrogate: %s\n', test_file);
    load(test_file, 'II', 'AA', 'AI', 'IA');

    fprintf('  Structure:\n');
    fprintf('  IA size: [%d, %d, %d]\n', size(IA,1), size(IA,2), size(IA,3));

    % Check all blocks and conditions
    fprintf('\n  IA Alpha values by block and condition:\n');
    for block = 1:size(IA,1)
        for cond = 1:size(IA,2)
            if size(IA,3) >= 3 && ~isempty(IA{block,cond,3})
                ia_val = nanmean(IA{block,cond,3}(:));
                fprintf('    Block %d, Cond %d: %.6f\n', block, cond, ia_val);
            end
        end
    end
else
    fprintf('File not found: %s\n', test_file);
end

%% Check real data for comparison
fprintf('\n==========================================================\n');
fprintf('Checking Original Real Data (GPDC3_nonorpdc_nonorpower)\n');
fprintf('==========================================================\n');

real_path = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/GPDC3_nonorpdc_nonorpower/'];
test_file_real = [real_path, 'UK_101_PDC.mat'];

if exist(test_file_real, 'file')
    fprintf('\nLoading original real: %s\n', test_file_real);
    load(test_file_real, 'II', 'AA', 'AI', 'IA');

    fprintf('  Structure:\n');
    fprintf('  IA size: [%d, %d, %d]\n', size(IA,1), size(IA,2), size(IA,3));

    % Check all blocks and conditions
    fprintf('\n  IA Alpha values by block and condition:\n');
    for block = 1:size(IA,1)
        for cond = 1:size(IA,2)
            if size(IA,3) >= 3 && ~isempty(IA{block,cond,3})
                ia_val = nanmean(IA{block,cond,3}(:));
                fprintf('    Block %d, Cond %d: %.6f\n', block, cond, ia_val);
            end
        end
    end
else
    fprintf('File not found: %s\n', test_file_real);
end

fprintf('\n==========================================================\n\n');
