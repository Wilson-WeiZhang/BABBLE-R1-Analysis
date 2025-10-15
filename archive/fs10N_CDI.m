
%CODE FOR CDI CALCULATION
load('data_read_surr_gpdc2');

uniqueIDs = unique(data(:,2));
a2([11,13,36,41,42],:)=[];
% 初始化结果数组
result = zeros(length(uniqueIDs), 2);

% 对每个唯一的ID计算均值
for i = 1:length(uniqueIDs)
    currentID = uniqueIDs(i);
    
    % 找出当前ID的所有行
    rows = data(:,2) == currentID;
    

    % 存储结果
    result(rows,1) = currentID;
    result(rows,2) = a2(i,2);
end

% 显示结果
disp('ID  Mean Value');
disp(result);
CDIP=result(:,2);


% 初始化结果数组
result = zeros(length(uniqueIDs), 2);

% 对每个唯一的ID计算均值
for i = 1:length(uniqueIDs)
    currentID = uniqueIDs(i);
    
    % 找出当前ID的所有行
    rows = data(:,2) == currentID;
    

    % 存储结果
    result(rows,1) = currentID;
    result(rows,2) = a2(i,3);
end

% 显示结果
disp('ID  Mean Value');
disp(result);
CDIW=result(:,2);

% 初始化结果数组
result = zeros(length(uniqueIDs), 2);

% 对每个唯一的ID计算均值
for i = 1:length(uniqueIDs)
    currentID = uniqueIDs(i);
    
    % 找出当前ID的所有行
    rows = data(:,2) == currentID;
    

    % 存储结果
    result(rows,1) = currentID;
    result(rows,2) = a2(i,4);
end

% 显示结果
disp('ID  Mean Value');
disp(result);
CDIG=result(:,2);