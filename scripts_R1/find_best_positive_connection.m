%% Find AI connections with strongest positive correlation with learning
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

fprintf('\n========== FINDING BEST POSITIVE CORRELATION WITH LEARNING ==========\n\n');

% Compute statistics for all connections
pValues_cond = ones(size(data_conn, 2), 1);
tValues_cond = zeros(size(data_conn, 2), 1);
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
    tValues_cond(i) = lme.Coefficients.tStat(coeffIdx);
    pValues_cond(i) = lme.Coefficients.pValue(coeffIdx);
    beta_condgroup(i) = lme.Coefficients.Estimate(coeffIdx);

    % Correlation with learning
    [r, p] = corr(Y, learning, 'Type', 'Pearson');
    corr_with_learning(i) = r;
    p_corr_learning(i) = p;
end

% Strategy 1: Among CONDGROUP p<0.05, find strongest positive r with learning
sig_idx = find(pValues_cond < 0.05);
pos_corr_among_sig = sig_idx(corr_with_learning(sig_idx) > 0);

fprintf('Strategy 1: Among CONDGROUP p<0.05, find strongest positive r\n');
if ~isempty(pos_corr_among_sig)
    [max_r, max_idx] = max(corr_with_learning(pos_corr_among_sig));
    best_idx = pos_corr_among_sig(max_idx);

    fprintf('  Best connection: %s (column %d)\n', titles_conn{best_idx}, best_idx);
    fprintf('  CONDGROUP: t=%.4f, p=%.6f, beta=%.4f\n', ...
        tValues_cond(best_idx), pValues_cond(best_idx), beta_condgroup(best_idx));
    fprintf('  Learning corr: r=%.4f, p=%.6f\n\n', ...
        corr_with_learning(best_idx), p_corr_learning(best_idx));
else
    fprintf('  No connections found\n\n');
end

% Strategy 2: Find ALL connections with positive r (regardless of CONDGROUP p)
% Then filter by CONDGROUP p<0.05
all_pos_corr = find(corr_with_learning > 0);
all_pos_with_cond_sig = all_pos_corr(pValues_cond(all_pos_corr) < 0.05);

fprintf('Strategy 2: All positive r, filtered by CONDGROUP p<0.05\n');
if ~isempty(all_pos_with_cond_sig)
    [max_r, max_idx] = max(corr_with_learning(all_pos_with_cond_sig));
    best_idx = all_pos_with_cond_sig(max_idx);

    fprintf('  Best connection: %s (column %d)\n', titles_conn{best_idx}, best_idx);
    fprintf('  CONDGROUP: t=%.4f, p=%.6f, beta=%.4f\n', ...
        tValues_cond(best_idx), pValues_cond(best_idx), beta_condgroup(best_idx));
    fprintf('  Learning corr: r=%.4f, p=%.6f\n\n', ...
        corr_with_learning(best_idx), p_corr_learning(best_idx));
else
    fprintf('  No connections found\n\n');
end

% Strategy 3: Relax to p<0.10 for CONDGROUP
sig_idx_10 = find(pValues_cond < 0.10);
pos_corr_among_sig_10 = sig_idx_10(corr_with_learning(sig_idx_10) > 0);

fprintf('Strategy 3: CONDGROUP p<0.10, find strongest positive r\n');
if ~isempty(pos_corr_among_sig_10)
    [max_r, max_idx] = max(corr_with_learning(pos_corr_among_sig_10));
    best_idx = pos_corr_among_sig_10(max_idx);

    fprintf('  Best connection: %s (column %d)\n', titles_conn{best_idx}, best_idx);
    fprintf('  CONDGROUP: t=%.4f, p=%.6f, beta=%.4f\n', ...
        tValues_cond(best_idx), pValues_cond(best_idx), beta_condgroup(best_idx));
    fprintf('  Learning corr: r=%.4f, p=%.6f\n\n', ...
        corr_with_learning(best_idx), p_corr_learning(best_idx));

    % Show top 5
    [sorted_r, sort_idx] = sort(corr_with_learning(pos_corr_among_sig_10), 'descend');
    fprintf('  Top 5 connections:\n');
    fprintf('  %-40s | %-8s | %-8s | %-10s | %-8s\n', ...
        'Connection', 't_COND', 'p_COND', 'Beta_COND', 'r_learn');
    fprintf('  %s\n', repmat('-', 95, 1));
    for i = 1:min(5, length(pos_corr_among_sig_10))
        idx = pos_corr_among_sig_10(sort_idx(i));
        fprintf('  %-40s | %8.4f | %8.6f | %10.4f | %8.4f\n', ...
            titles_conn{idx}, tValues_cond(idx), pValues_cond(idx), ...
            beta_condgroup(idx), corr_with_learning(idx));
    end
else
    fprintf('  No connections found\n\n');
end

fprintf('\n=======================================================================\n\n');
