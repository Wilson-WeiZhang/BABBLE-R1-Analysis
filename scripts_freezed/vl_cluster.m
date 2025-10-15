% % calculation learning correct
% [a,b]=xlsread('/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/Shared BABBLE Drafts/tables/behavioural table.xlsx');
% b1=[];
% l=[];
% a1=unique(a(:,2));
% for i=1:47
%     for j=1:3
%         b1=a(intersect(find(a(:,2)==a1(i)),find(a(:,6)==j)),7);
%         l(i,j)=nanmean(b1);
%     end
% end
k=[0.603333333	-2.715	-0.613333333
3.673333333	3.378333333	-2
5.945	1.115	1.345
5.493333333	0.698333333	0.0125
0.37	1.696666667	1.9
-2.733333333	4.593333333	0.173333333
0.31	1.33	-2.155
-6.77	11.48	-5.365
4.1225	0.885	3.7675
2.423333333	0.673333333	1.468333333
3.535	2.375	-1.53
8.845	-2.975	1.8775
0.815	-2.345	7.0775
-1.528333333	-13.67333333	0.855
-0.4525	-3.235	-5.97
-4.275	2.7525	0.9275
5.83	2.6325	-3.5425
0.08	1.035	-4.26
0.378333333	3.155	-1.206666667
-1.436666667	1.568333333	0.273333333
3.75	-0.3975	3.1875
1.19	-0.72	11.305
1.211666667	-1.78	0.105
6.34	0.878333333	0.05
1.83	-1.41	3.94
-14.07	7.95	-7.49
-4.545	4.6125	1.5975
-0.0875	0.34	2.695
2.315	-4.8	-0.91
4.181666667	3.338333333	-3.721666667
8.235	0.7425	-1.56
-4.8525	-1.24	4.7275
3.2	0.380555556	-1.043611111
-0.206666667	-1.026666667	-0.665
3.16	7.063333333	2.406666667
0.754166667	3.466666667	0.973333333
0.1325	1.4575	-2.91
0.18	-0.275	3.063333333
2.11	1.79	4.88
-2.185	-1.84	-0.4525
1.776666667	1.733333333	-0.585
-1.7	7.7	2
-1.36	3.066666667	-0.133333333
2.87	-4.91	5.6
4.6825	4.57	-3.2075
1.033333333	-0.466666667	2.706666667
1.38	2.77	-4.16];
%

% Assuming your data matrix is named 'k' with samples as rows and 3 features as columns

% 1. Basic k-means
k_clusters = 3;  % Choose number of clusters
[idx1, centroids1] = kmeans(k, k_clusters, 'Distance', 'sqeuclidean', ...
    'Replicates', 10);

% Visualize basic k-means results (if your data is 3D)
figure;
scatter3(k(:,1), k(:,2), k(:,3), 50, idx1, 'filled');
hold on;
scatter3(centroids1(:,1), centroids1(:,2), centroids1(:,3), 200, 'k', 'filled');
title('Basic K-means Clustering');
xlabel('Feature 1'); ylabel('Feature 2'); zlabel('Feature 3');

% 2. K-means with interval sampling
interval = 1 or 2;  % Sample every 1-5th point
sampled_data = k(1:interval:end, :);
[idx2, centroids2] = kmeans(sampled_data, k_clusters, 'Distance', 'sqeuclidean');

% Assign remaining points to nearest centroid
distances = pdist2(k, centroids2);
[~, full_idx2] = min(distances, [], 2);


full_idx2(find(full_idx2==3))=6;
full_idx2(find(full_idx2==2))=5;
full_idx2(find(full_idx2==1))=4;
full_idx2(find(full_idx2==6))=1;
full_idx2(find(full_idx2==5))=2;
full_idx2(find(full_idx2==4))=3;


% Visualize interval sampling results
figure;
scatter3(k(:,1), k(:,2), k(:,3), 50, full_idx2, 'filled');
hold on;
scatter3(centroids2(:,1), centroids2(:,2), centroids2(:,3), 200, 'k', 'filled');
title('K-means with Interval Sampling');
xlabel('Feature 1'); ylabel('Feature 2'); zlabel('Feature 3');

% 3. K-means with random sampling
sample_size = floor(size(k, 1) * 0.3);  % Use 30% of data
rng(42);  % Set random seed for reproducibility
rand_idx = randperm(size(k, 1), sample_size);
sampled_data = k(rand_idx, :);
[idx3, centroids3] = kmeans(sampled_data, k_clusters, 'Distance', 'sqeuclidean', ...
    'Replicates', 10);

% Assign remaining points to nearest centroid
distances = pdist2(k, centroids3);
[~, full_idx3] = min(distances, [], 2);

% Visualize random sampling results
figure;
scatter3(k(:,1), k(:,2), k(:,3), 50, full_idx3, 'filled');
hold on;
scatter3(centroids3(:,1), centroids3(:,2), centroids3(:,3), 200, 'k', 'filled');
title('K-means with Random Sampling');
xlabel('Feature 1'); ylabel('Feature 2'); zlabel('Feature 3');

% 4. K-means++ initialization
[idx4, centroids4] = kmeans(k, k_clusters, 'Distance', 'sqeuclidean', ...
    'Start', 'plus', 'Replicates', 10);

% Visualize k-means++ results
figure;
scatter3(k(:,1), k(:,2), k(:,3), 50, idx4, 'filled');
hold on;
scatter3(centroids4(:,1), centroids4(:,2), centroids4(:,3), 200, 'k', 'filled');
title('K-means++ Clustering');
xlabel('Feature 1'); ylabel('Feature 2'); zlabel('Feature 3');

% 5. Mini-batch k-means implementation
function [idx, centroids] = minibatch_kmeans(data, k, batch_size, max_iter)
    % Initialize centroids using k-means++
    centroids = kmeans_plus_plus_init(data, k);
    n = size(data, 1);
    
    for iter = 1:max_iter
        % Randomly sample batch_size points
        batch_idx = randperm(n, min(batch_size, n));
        batch = data(batch_idx, :);
        
        % Find nearest centroid for each point in batch
        distances = pdist2(batch, centroids);
        [~, batch_assignments] = min(distances, [], 2);
        
        % Update centroids using batch
        for j = 1:k
            points_in_cluster = batch(batch_assignments == j, :);
            if ~isempty(points_in_cluster)
                centroids(j, :) = mean(points_in_cluster, 1);
            end
        end
    end
    
    % Assign all points to final centroids
    distances = pdist2(data, centroids);
    [~, idx] = min(distances, [], 2);
end

% Helper function for k-means++ initialization
function centroids = kmeans_plus_plus_init(data, k)
    n = size(data, 1);
    centroids = zeros(k, size(data, 2));
    
    % Choose first centroid randomly
    centroids(1, :) = data(randi(n), :);
    
    % Choose remaining centroids
    for i = 2:k
        % Compute distances to nearest existing centroid
        distances = min(pdist2(data, centroids(1:i-1, :)), [], 2);
        
        % Choose next centroid with probability proportional to distance squared
        prob = distances.^2 / sum(distances.^2);
        cumprob = cumsum(prob);
        r = rand();
        idx = find(cumprob >= r, 1);
        centroids(i, :) = data(idx, :);
    end
end

% Example usage of mini-batch k-means
batch_size = 100;
max_iter = 100;
[idx5, centroids5] = minibatch_kmeans(k, k_clusters, batch_size, max_iter);

% Visualize mini-batch k-means results
figure;
scatter3(k(:,1), k(:,2), k(:,3), 50, idx5, 'filled');
hold on;
scatter3(centroids5(:,1), centroids5(:,2), centroids5(:,3), 200, 'k', 'filled');
title('Mini-batch K-means Clustering');
xlabel('Feature 1'); ylabel('Feature 2'); zlabel('Feature 3');