%% Test script to verify CONDGROUP reversal
clc
clear

% Load data
load('data_read_surr_gpdc2.mat','data')
load("CDI2.mat")

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

% Load connection data
ii1=[10:9+81];
ii2=[10+81*1:9+81*2];
ii3=[10+81*2:9+81*3];
aa1=[10+81*3:9+81*4];
aa2=[10+81*4:9+81*5];
aa3=[10+81*5:9+81*6];
ai1=[10+81*6:9+81*7];
ai2=[10+81*7:9+81*8];
ai3=[10+81*8:9+81*9];
ia1=[10+81*9:9+81*10];
ia2=[10+81*10:9+81*11];
ia3=[10+81*11:9+81*12];
listi=[ai3];
data=sqrt(data(:,listi));

Y = data(:, 12); % AI_Alpha_Fz_to_F4 connection

fprintf('\n===== TESTING CONDGROUP REVERSAL =====\n\n');

% Show original CONDGROUP encoding
fprintf('Original CONDGROUP encoding:\n');
fprintf('  CONDGROUP = 1: Full gaze\n');
fprintf('  CONDGROUP = 2: Partial/No gaze (merged)\n\n');

% Create reversed CONDGROUP
fprintf('Creating reversed CONDGROUP...\n');
CONDGROUP_reversed = reordercats(CONDGROUP, {'2', '1'});

fprintf('  Categories before reversal: %s\n', strjoin(categories(CONDGROUP), ', '));
fprintf('  Categories after reversal:  %s\n\n', strjoin(categories(CONDGROUP_reversed), ', '));

% Test model with ORIGINAL CONDGROUP
fprintf('===== TEST 1: Using ORIGINAL CONDGROUP =====\n');
tbl_orig = table(ID, zscore(learning), zscore(Y), 'VariableNames', {'ID', 'learning', 'AI_conn'});
tbl_orig.CONDGROUP = CONDGROUP;

lme_orig = fitlme(tbl_orig, 'AI_conn ~ CONDGROUP + (1|ID)');
coeff_orig = lme_orig.Coefficients.Estimate(strcmp(lme_orig.Coefficients.Name, 'CONDGROUP_2'));
fprintf('Path a with ORIGINAL CONDGROUP:\n');
fprintf('  CONDGROUP_2 coefficient = %.4f\n', coeff_orig);
fprintf('  Interpretation: Condition 2 (Others) vs Condition 1 (Full)\n');
fprintf('  Negative value means: Full gaze has HIGHER AI connection ✓\n\n');

% Test model with REVERSED CONDGROUP
fprintf('===== TEST 2: Using REVERSED CONDGROUP =====\n');
tbl_rev = table(ID, zscore(learning), zscore(Y), 'VariableNames', {'ID', 'learning', 'AI_conn'});
tbl_rev.CONDGROUP = CONDGROUP_reversed;

lme_rev = fitlme(tbl_rev, 'AI_conn ~ CONDGROUP + (1|ID)');

% After reordering, the coefficient name changes from CONDGROUP_2 to CONDGROUP_1
% because the reference is now category '2' and comparison is category '1'
fprintf('Available coefficient names:\n');
disp(lme_rev.Coefficients.Name);

coeff_rev = lme_rev.Coefficients.Estimate(strcmp(lme_rev.Coefficients.Name, 'CONDGROUP_1'));
fprintf('\nPath a with REVERSED CONDGROUP:\n');
fprintf('  CONDGROUP_1 coefficient = %.4f\n', coeff_rev);
fprintf('  Interpretation: Condition 1 (Full) vs Condition 2 (Others) [reference]\n');

if coeff_rev > 0
    fprintf('  Positive value means: Full gaze has HIGHER AI connection ✓✓✓\n');
    fprintf('  SUCCESS: Sign reversal worked!\n\n');
else
    fprintf('  Still negative! Sign reversal FAILED!\n\n');
end

fprintf('===== VERIFICATION =====\n');
fprintf('Expected result: coeff_rev = -coeff_orig\n');
fprintf('Actual: coeff_rev (%.4f) vs -coeff_orig (%.4f)\n', coeff_rev, -coeff_orig);
fprintf('Match: %s\n\n', mat2str(abs(coeff_rev - (-coeff_orig)) < 0.0001));
