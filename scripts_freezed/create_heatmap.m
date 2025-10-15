function create_heatmap(group_data, mdl, group_name)
    % 创建网格
    [k2_grid, k3_grid] = meshgrid(linspace(min(group_data.k2), max(group_data.k2), 100), ...
                                  linspace(min(group_data.k3), max(group_data.k3), 100));
    
    % 准备预测数据
    new_data = group_data(1:size(k2_grid(:), 1), :);
    new_data.k2 = k2_grid(:);
    new_data.k3 = k3_grid(:);
    
    % 预测学习值
    predicted_learning = predict(mdl, new_data);
    predicted_learning = reshape(predicted_learning, size(k2_grid));
    
    % 创建实际学习值的插值
    real_learning = griddata(group_data.k2, group_data.k3, group_data.learning, k2_grid, k3_grid, 'cubic');
    
    % 绘制热图
    figure;
    
    % 实际学习值
    subplot(1, 2, 1);
    contourf(k2_grid, k3_grid, real_learning, 20);
    colorbar;
    title(['Real Learning - ' group_name]);
    xlabel('k2 (II GPDC)');
    ylabel('k3 (AI * II GPDC)');
    
    % 预测学习值
    subplot(1, 2, 2);
    contourf(k2_grid, k3_grid, predicted_learning, 20);
    colorbar;
    title(['Predicted Learning - ' group_name]);
    xlabel('k2 (II GPDC)');
    ylabel('k3 (AI * II GPDC)');
    
    sgtitle(['Learning Heatmap for ' group_name]);
end
