%% Find all AI connections with p<0.05 (no BHFDR correction)
clc
clear

load('data_read_surr_gpdc2.mat','data')

a=data;
AGE=a(:,3);
SEX=a(:,4);
SEX=categorical(SEX);
COUNTRY=a(:,1);
COUNTRY=categorical(COUNTRY);
blocks=a(:,5);
blocks=categorical(blocks);
CONDGROUP=a(:,6);
CONDGROUP(find(CONDGROUP==3))=2;
CONDGROUP=categorical(CONDGROUP);
learning= a(:, 7);
atten=a(:,9);
ID=a(:,2);
ID=categorical(ID);

% Generate titles for connections
nodes = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
frequencyBands = {'Delta', 'Theta', 'Alpha'};
connectionTypes = {'II', 'AA', 'AI', 'IA'};

connectionTitles = {};
for conn = 1:length(connectionTypes)
    for freq = 1:length(frequencyBands)
        for src = 1:length(nodes)
            for dest = 1:length(nodes)
                connectionTitles{end+1} = sprintf('%s_%s_%s_to_%s', ...
                    connectionTypes{conn}, frequencyBands{freq}, nodes{src}, nodes{dest});
            end
        end
    end
end

% Extract AI alpha connections (ai3)
ai3=[10+81*8:9+81*9];
data_conn=sqrt(data(:,ai3));
titles_conn = connectionTitles(ai3);

fprintf('\n========== SCREENING AI ALPHA CONNECTIONS (p<0.05, no correction) ==========\n\n');

% Test each connection for CONDGROUP effect
pValues = ones(size(data_conn, 2), 1);
tValues = zeros(size(data_conn, 2), 1);
beta_condgroup = zeros(size(data_conn, 2), 1);
corr_with_learning = zeros(size(data_conn, 2), 1);
p_corr_learning = ones(size(data_conn, 2), 1);

for i = 1:size(data_conn, 2)
    Y = data_conn(:, i);

    % LME: Connection ~ CONDGROUP + covariates + (1|ID)
    tbl = table(ID, zscore(learning), zscore(atten), zscore(AGE), SEX, COUNTRY, ...
        zscore(Y), blocks, CONDGROUP, 'VariableNames',...
        {'ID', 'learning', 'atten', 'AGE', 'SEX', 'COUNTRY', 'Y', 'block', 'CONDGROUP'});

    lme = fitlme(tbl, 'Y ~ AGE + SEX + CONDGROUP + COUNTRY + (1|ID)');

    coeffIdx = strcmp(lme.Coefficients.Name, 'CONDGROUP_2');
    tValues(i) = lme.Coefficients.tStat(coeffIdx);
    pValues(i) = lme.Coefficients.pValue(coeffIdx);
    beta_condgroup(i) = lme.Coefficients.Estimate(coeffIdx);

    % Correlation with learning
    [r, p] = corr(Y, learning, 'Type', 'Pearson');
    corr_with_learning(i) = r;
    p_corr_learning(i) = p;
end

% Find connections with p<0.05
sig_idx = find(pValues < 0.05);

fprintf('Found %d connections with p<0.05 (uncorrected)\n\n', length(sig_idx));

% Sort by t-value (most negative = strongest Full gaze effect)
[~, sort_idx] = sort(tValues(sig_idx));
sig_idx_sorted = sig_idx(sort_idx);

fprintf('%-40s | %-8s | %-8s | %-10s | %-8s | %-8s\n', ...
    'Connection', 't-value', 'p-value', 'Beta_COND', 'r_learn', 'p_learn');
fprintf('%s\n', repmat('-', 110, 1));

for i = 1:length(sig_idx_sorted)
    idx = sig_idx_sorted(i);
    fprintf('%-40s | %8.4f | %8.6f | %10.4f | %8.4f | %8.6f\n', ...
        titles_conn{idx}, tValues(idx), pValues(idx), ...
        beta_condgroup(idx), corr_with_learning(idx), p_corr_learning(idx));
end

fprintf('\n');

% Find connections with POSITIVE correlation with learning
pos_corr_idx = sig_idx(corr_with_learning(sig_idx) > 0);

fprintf('\n========== CONNECTIONS WITH p<0.05 AND POSITIVE r WITH LEARNING ==========\n\n');

if isempty(pos_corr_idx)
    fprintf('No connections found with both p<0.05 for CONDGROUP and positive correlation with learning.\n');
else
    fprintf('Found %d connections:\n\n', length(pos_corr_idx));

    fprintf('%-40s | %-8s | %-8s | %-10s | %-8s | %-8s\n', ...
        'Connection', 't-value', 'p-value', 'Beta_COND', 'r_learn', 'p_learn');
    fprintf('%s\n', repmat('-', 110, 1));

    for i = 1:length(pos_corr_idx)
        idx = pos_corr_idx(i);
        fprintf('%-40s | %8.4f | %8.6f | %10.4f | %8.4f | %8.6f\n', ...
            titles_conn{idx}, tValues(idx), pValues(idx), ...
            beta_condgroup(idx), corr_with_learning(idx), p_corr_learning(idx));
    end
end

fprintf('\n');
fprintf('Column 12 (AI_Alpha_Fz_to_F4):\n');
fprintf('  t-value = %.4f, p = %.6f, Beta_COND = %.4f\n', ...
    tValues(12), pValues(12), beta_condgroup(12));
fprintf('  r_with_learning = %.4f, p = %.6f\n\n', ...
    corr_with_learning(12), p_corr_learning(12));

fprintf('=======================================================================\n\n');

% Save results
save('p005_connections_results.mat', 'sig_idx', 'tValues', 'pValues', ...
    'beta_condgroup', 'corr_with_learning', 'p_corr_learning', 'titles_conn');
