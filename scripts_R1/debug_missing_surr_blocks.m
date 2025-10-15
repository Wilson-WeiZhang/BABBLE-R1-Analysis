%% Debug Why Certain Blocks are Missing in Surrogate
clc; clear all;

basepath = '/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/';

fprintf('==========================================================\n');
fprintf('Debugging Missing Blocks in Surrogate\n');
fprintf('==========================================================\n\n');

% Check one specific case: UK_101, Block 2, Cond 1
fprintf('Case 1: UK_101, Block 2, Cond 1\n');

% Load real data
real_file = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/GPDC3_cond1_only/UK_101_GPDC.mat'];
load(real_file, 'II', 'AA', 'AI', 'IA');

fprintf('Real data:\n');
fprintf('  II size: [%d, %d, %d]\n', size(II,1), size(II,2), size(II,3));
fprintf('  Block 2, Cond 1 exists: %d\n', ~isempty(II{2,1,3}));
if ~isempty(II{2,1,3})
    fprintf('  Block 2, Cond 1, Band 3 size: %dx%d\n', size(II{2,1,3},1), size(II{2,1,3},2));
    fprintf('  Block 2, Cond 1, Band 3 mean: %.6f\n', nanmean(II{2,1,3}(:)));
end

% Load surrogate data
surr_file = [basepath, 'infanteeg/CAM BABBLE EEG DATA/2024/data_matfile/surrGPDC_cond1_SET/GPDC1/UK_101_GPDC.mat'];
load(surr_file, 'II', 'AA', 'AI', 'IA');

fprintf('\nSurrogate data:\n');
fprintf('  II size: [%d, %d, %d]\n', size(II,1), size(II,2), size(II,3));
if size(II,1) >= 2 && size(II,2) >= 1
    fprintf('  Block 2, Cond 1 exists: %d\n', ~isempty(II{2,1,3}));
    if ~isempty(II{2,1,3})
        fprintf('  Block 2, Cond 1, Band 3 size: %dx%d\n', size(II{2,1,3},1), size(II{2,1,3},2));
        fprintf('  Block 2, Cond 1, Band 3 mean: %.6f\n', nanmean(II{2,1,3}(:)));
    else
        fprintf('  Block 2, Cond 1, Band 3 is EMPTY\n');
    end
else
    fprintf('  Block 2 dimension does not exist!\n');
end

fprintf('\n==========================================================\n');
fprintf('Checking windowlist structure issue\n');
fprintf('==========================================================\n\n');

% The problem might be in how avGPDC_s is structured vs how we try to access it
% Let's check if the issue is dimension mismatch

% In surrogate generation, we have:
% avGPDC_s{block} not avGPDC_s{block,1}
% This might cause indexing issues

fprintf('The issue is likely:\n');
fprintf('1. avGPDC_s is structured as avGPDC_s{block}{cond,phrase}\n');
fprintf('2. But when partitioning, we iterate: for block = 1:size(avGPDC_s,1)\n');
fprintf('3. If some blocks have no valid data, they might be empty cells\n');
fprintf('4. This causes subsequent averaging to skip those blocks\n\n');

fprintf('Solution: Ensure all blocks that exist in real data also\n');
fprintf('get processed in surrogate, even if some phrases are empty.\n');
fprintf('==========================================================\n\n');
