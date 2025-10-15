% Create transition matrix
syllables = {'pe', 'tu', 'do', 'ki', 'bu', 'to', 'di', 'lo', 'ga', 'ku', 're', 'pa'};
n = length(syllables);
P = zeros(n, n);

% Set intra-word transitions (100%)
word1 = [1 2 3];     % pe-tu-do
word2 = [4 5 6];     % ki-bu-to
word3 = [7 8 9];     % di-lo-ga
word4 = [10 11 12];  % ku-re-pa

% Set 100% transitions within words
for words = {word1, word2, word3, word4}
    word = words{1};
    for i = 1:length(word)-1
        P(word(i), word(i+1)) = 1;
    end
end

% Set inter-word transitions (33.3%)
last_syllables = [3 6 9 12];  % Last syllables of each word
first_syllables = [1 4 7 10]; % First syllables of each word

for i = 1:length(last_syllables)
    for j = 1:length(first_syllables)
        if (first_syllables(j)+2)/3 ~= last_syllables(i)/3
            P(last_syllables(i), first_syllables(j)) = 1/3;
        end
    end
end

% Create figure
figure('Position', [100 100 800 600]);
imagesc(P);
colormap(hot);
colorbar;

% Add labels with explanatory text
xlabel('Next Syllable', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Previous Syllable', 'FontName', 'Arial', 'FontSize', 20);
% Set axis properties
ax = gca;
set(ax, 'XTick', 1:n);
set(ax, 'YTick', 1:n);
set(ax, 'XTickLabel', syllables);
set(ax, 'YTickLabel', syllables);
set(ax, 'FontName', 'Arial');
set(ax, 'FontSize', 20,  'FontName', 'Arial', 'FontSize', 20,'FontWeight', 'bold');

% Add grid
grid off;
set(gca, 'LineWidth', 2);

% Add title
title('Transition Probability Matrix', 'FontName', 'Arial', 'FontSize', 24);

% Adjust colorbar
h = colorbar;
set(h, 'LineWidth', 2, 'FontWeight', 'bold');
ylabel(h, 'Probability', 'FontName', 'Arial', 'FontSize', 20, 'FontWeight', 'bold');

% Make plot square
axis square;

% Add borders around cells
hold on;
for i = 0.5:1:n+0.5
    plot([i i], [0.5 n+0.5], 'k-', 'LineWidth', 2);
    plot([0.5 n+0.5], [i i], 'k-', 'LineWidth', 2);
end
hold off;