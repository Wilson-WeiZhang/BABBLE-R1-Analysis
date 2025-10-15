%% Check AI-Learning correlations by condition
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

% Connection indices
ai3=[10+81*8:9+81*9];
data_conn=sqrt(data(:,ai3));

% AI_Alpha_Fz_to_F4 is column 12
Y = data_conn(:, 12);

% Find condition groups
g1=find(a(:,6)==1);  % Full gaze
g2=find(a(:,6)==2);  % Partial gaze
g3=find(a(:,6)==3);  % No gaze
g23=[g2;g3];         % Combined partial/no gaze

fprintf('\n========== AI-LEARNING CORRELATION ANALYSIS ==========\n\n');

% Overall correlation
[r_all, p_all] = corr(Y, learning, 'Type', 'Pearson');
fprintf('Overall correlation (all conditions):\n');
fprintf('  r = %.4f, p = %.4f\n\n', r_all, p_all);

% By condition
fprintf('By gaze condition:\n');

[r1, p1] = corr(Y(g1), learning(g1), 'Type', 'Pearson');
fprintf('  Full gaze (n=%d):       r = %.4f, p = %.4f\n', length(g1), r1, p1);

[r2, p2] = corr(Y(g2), learning(g2), 'Type', 'Pearson');
fprintf('  Partial gaze (n=%d):    r = %.4f, p = %.4f\n', length(g2), r2, p2);

[r3, p3] = corr(Y(g3), learning(g3), 'Type', 'Pearson');
fprintf('  No gaze (n=%d):         r = %.4f, p = %.4f\n', length(g3), r3, p3);

[r23, p23] = corr(Y(g23), learning(g23), 'Type', 'Pearson');
fprintf('  Partial+No gaze (n=%d): r = %.4f, p = %.4f\n\n', length(g23), r23, p23);

% Means by condition
fprintf('AI connection strength by condition:\n');
fprintf('  Full gaze:       mean = %.4f, SD = %.4f\n', mean(Y(g1)), std(Y(g1)));
fprintf('  Partial gaze:    mean = %.4f, SD = %.4f\n', mean(Y(g2)), std(Y(g2)));
fprintf('  No gaze:         mean = %.4f, SD = %.4f\n', mean(Y(g3)), std(Y(g3)));
fprintf('  Partial+No gaze: mean = %.4f, SD = %.4f\n\n', mean(Y(g23)), std(Y(g23)));

fprintf('Learning by condition:\n');
fprintf('  Full gaze:       mean = %.4f, SD = %.4f\n', mean(learning(g1)), std(learning(g1)));
fprintf('  Partial gaze:    mean = %.4f, SD = %.4f\n', mean(learning(g2)), std(learning(g2)));
fprintf('  No gaze:         mean = %.4f, SD = %.4f\n', mean(learning(g3)), std(learning(g3)));
fprintf('  Partial+No gaze: mean = %.4f, SD = %.4f\n\n', mean(learning(g23)), std(learning(g23)));

% Test condition differences
[h,p] = ttest2(Y(g1), Y(g23));
fprintf('AI connection: Full vs. Others t-test: p = %.4f\n', p);

[h,p] = ttest2(learning(g1), learning(g23));
fprintf('Learning: Full vs. Others t-test: p = %.4f\n\n', p);

fprintf('=======================================================\n\n');
