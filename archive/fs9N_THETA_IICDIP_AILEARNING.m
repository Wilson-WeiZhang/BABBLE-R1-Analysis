%% Load entrainment real and surr
clc
clear all
load('ENTRIANSURR.mat');
load("dataGPDC.mat");
% Read the CSV file
path='/Users/zw/Library/CloudStorage/OneDrive-NanyangTechnologicalUniversity/'

[a, b] = xlsread([path,'infanteeg/CAM BABBLE EEG DATA/2024/entrain/TABLE.xlsx']);

tableorder=[];

data2=zeros(226,54);

for i=1:length(a)
    id=b{i+1,1};
    if isequal(id(6),'C')==1
        country=1;
    else
        country=2;
    end
   id2=str2num(id(3:5));
   bl=a(i,1);
   c=a(i,2);
   p=a(i,3);
   if p==1
       for j=1:size(data,1)
           if data(j,1)==country&&data(j,2)-data(j,1)*1000==id2&&data(j,5)==bl&& data(j,6)==c
               % only phrase 1 's entrainment versus average GPDC
               data2(j,:)=nanmean(a(i:i,4:57),1);
                   tableorder(j)=i;
               break
           end
       end
   end
end

for i=1:size(data2,1)
    if sum(data2(i,:))==0
        data2(i,:)=nan;
    end
end

alphac3=data2(:,4);
alphapz=data2(:,8);
thetaf4=data2(:,21);
deltaf4=data2(:,39);
learning=data(:,7);
learning2=data(:,8);
atten=data(:,9);

data2_surr=cell(1000,1);
for i=1:1000
    i
    tmp=permutable{i};
    tmp2=zeros(226,54);
    for j=1:226
        if tableorder(j)~=0
            tmp2(j,:)=table2array(tmp(tableorder(j),5:end));
        else
             tmp2(j,:)=nan;
        end
    end
    data2_surr{i}=tmp2;
end


%% load surr gpdc
load('data_read_surr_gpdc2.mat')
a=data;
g1=find(a(:,6)==1);
g2=find(a(:,6)==2);
g3=find(a(:,6)==3);
g4=find(a(:,6)<=2);

b1=find(a(:,5)==1);
b2=find(a(:,5)==2);
b3=find(a(:,5)==3);
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
nww=a(:,8);
atten=a(:,9);
ID=a(:,2);
ID=categorical(ID);

% % Generate titles
countryTitles = 'Country';
sexTitles = 'Sex';
blockTitles = 'Block';
ageTitle = {'Age'};
learningTitle = {'Learning'};
attenTitle = {'atten'};
% Generate titles for the connections
nodes = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
frequencyBands = {'Delta', 'Theta', 'Alpha'};
connectionTypes = {'II', 'AA', 'AI', 'IA'};

connectionTitles = {};
for conn = 1:length(connectionTypes)
    for freq = 1:length(frequencyBands)

        for src = 1:length(nodes)
            for dest = 1:length(nodes)
                    connectionTitles{end+1} = sprintf('%s_%s_%s_to_%s', connectionTypes{conn}, frequencyBands{freq}, nodes{src},nodes{dest});
            end
        end
    end
end

% Combine all titles
titles = [countryTitles, 'ID',ageTitle, sexTitles, blockTitles,'cond', learningTitle,'LEARN',attenTitle, connectionTitles];

% within channel PDC should be nan
block_size = 81;
num_blocks = 12;
initial_cols = 10;
diag_indices = [1, 11, 21, 31, 41, 51, 61, 71, 81];
column_indices = [];
for j = 1:num_blocks
    for d = diag_indices
        col_index = initial_cols + (j-1) * block_size + d;
        column_indices = [column_indices, col_index];
    end
end

% load("data_read_surr2.mat")
% 
% listi = [11:10+243,11+243*2:10+243*3];
% listi=setdiff(listi,column_indices);
% listi = [172:252,658:738];
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

% % alpha 
% listi=[ii3];
% load('stronglistfdr5_gpdc_II.mat')
% listii=listi(s4);
% ii=sqrt(data(:,listii));
% 
% listi=[ai3];
% load('stronglistfdr5_gpdc_AI.mat')
% listai=listi(s4);
% ai=sqrt(data(:,listai));
% 
% listi=[aa3];
% load('stronglistfdr5_gpdc_AA.mat')
% listaa=listi(s4);
% aa=sqrt(data(:,listaa));
% 
% 
% % theta 
% listi=[ii2];
% load('stronglistfdr5_gpdc_IItheta.mat')
% listii=listi(s4);
% ii=sqrt(data(:,listii));
% 
% listi=[ai2];
% load('stronglistfdr5_gpdc_AItheta.mat')
% listai=listi(s4);
% ai=sqrt(data(:,listai));

% delta 
listi=[ii1];
load('stronglistfdr5_gpdc_IIdelta.mat')
listii=listi(s4);
ii=sqrt(data(:,listii));

listi=[ai1];
load('stronglistfdr5_gpdc_AIdelta.mat')
listai=listi(s4);
ai=sqrt(data(:,listai));




aa_surr=cell(1000,1);
ai_surr=cell(1000,1);
ii_surr=cell(1000,1);
for i=1:1000
    i
    tmp=data_surr{i};
    aa_surr{i}=sqrt(tmp(:,listaa));
    ai_surr{i}=sqrt(tmp(:,listai));
    ii_surr{i}=sqrt(tmp(:,listii));
end
load('CDI.mat')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% predict
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% attention failed
%% AI atten

colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);valid=find(isnan(CDIG)==0);
for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ai, data(:, [1, 3, 4])]), zscore(nww), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        ais = ai_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ais, data(:, [1, 3, 4])]), zscore(nww), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color',[ 75/255, 116/255, 178/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 14;             % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Attention variance explained', 'FontSize', 16, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.7])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages
legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real AI GPDC'}, 'Location', 'southeast', 'FontSize', 12);
title('Attention proportion by AI GPDC', 'FontSize', 16, 'FontWeight', 'bold')
hold off;

%% atten II
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% % II ~learning
colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);valid=find(isnan(CDIG)==0);
for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ii, data(:, [1, 3, 4])]), zscore(atten), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        iis = ii_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([iis, data(:, [1, 3, 4])]), zscore(atten), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color',[252/255, 140/255, 90/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 14;             % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Attention variance explained', 'FontSize', 16, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.7])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages
legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real II GPDC'}, 'Location', 'southeast', 'FontSize', 12);
title('Attention proportion by II GPDC', 'FontSize', 16, 'FontWeight', 'bold')
hold off;


%%  AA atten
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% AA II AI IA COLOR
colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);valid=find(isnan(CDIG)==0);
for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([aa, data(:, [1, 3, 4])]), zscore(nww), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        aas = aa_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([aas, data(:, [1, 3, 4])]), zscore(nww), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color',    [226/255, 90/255, 80/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 14;             % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Attention variance explained', 'FontSize', 16, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.7])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages
legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real AA GPDC'}, 'Location', 'southeast', 'FontSize', 12);
title('Attention proportion by AA GPDC', 'FontSize', 16, 'FontWeight', 'bold')
hold off;


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% entrain atten

% Define labels
peaklabel = [4:12, 22:30, 40:48];

colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};
% entrain=data2(:,[4,5,21,26,40]);
entrain=data2(:,peaklabel);

compall=10;
plotk = zeros(compall, 4);valid=find(isnan(CDIG)==0);
for comp = 1:compall  
    valid=find(isnan(data2(:,4))==0);
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([entrain(valid,:), data(valid, [1, 3, 4])]), zscore(nww(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        entrains = data2_surr{i};
     

        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([entrains(valid,peaklabel-3), data(valid, [1, 3, 4])]), zscore(nww(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
   
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color', [128/255, 0/255, 128/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 14;             % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Attention variance explained', 'FontSize', 16, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.7])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages
legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real NSE'}, 'Location', 'southeast', 'FontSize', 12);
title('Attention proportion by NSE', 'FontSize', 16, 'FontWeight', 'bold')
hold off;

%predict   attention failed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%  II to CDI-G SUP, OTHER CDI NOT VALID other feature cannot preid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% predict
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CDIG 

colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);valid=find(isnan(CDIG)==0);
for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ai(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        ais = ai_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ais(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color',[ 75/255, 116/255, 178/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 14;             % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('CDI-G variance explained', 'FontSize', 16, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.6])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages
legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real AI GPDC'}, 'Location', 'southeast', 'FontSize', 12);
title('CDI-G prediction performance by AI GPDC', 'FontSize', 16, 'FontWeight', 'bold')
hold off;


%%  AI to CDI-W 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% predict
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CDIG 

colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);valid=find(isnan(CDIG)==0);
for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ai(valid,:), data(valid, [1, 3, 4])]), zscore(CDIP(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        ais = ai_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ais(valid,:), data(valid, [1, 3, 4])]), zscore(CDIP(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color',[ 75/255, 116/255, 178/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 14;             % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('CDI-P variance explained', 'FontSize', 16, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.7])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages
legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real AI GPDC'}, 'Location', 'southeast', 'FontSize', 12);
title('CDI-P prediction performance by AI GPDC', 'FontSize', 16, 'FontWeight', 'bold')
hold off;

%% sup Figure  II - CDIG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% % II ~learning
colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);valid=find(isnan(CDIG)==0);
for comp = 1:compall  
     [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ii(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        iis = ii_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([iis(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color', [252/255, 140/255, 90/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 14;             % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('CDI-G variance explained', 'FontSize', 16, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.5])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages

legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real II GPDC'}, 'Location', 'southeast', 'FontSize', 12);
title('CDI-G prediction performance by II GPDC', 'FontSize', 16, 'FontWeight', 'bold')
hold off;


%% sup Figure  II - CDIW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% % II ~learning
colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);valid=find(isnan(CDIG)==0);
for comp = 1:compall  
     [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([ii(valid,:), data(valid, [1, 3, 4])]), zscore(CDIP(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        iis = ii_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([iis(valid,:), data(valid, [1, 3, 4])]), zscore(CDIP(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color', [252/255, 140/255, 90/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 14;             % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('CDI-P variance explained', 'FontSize', 16, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.7])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages

legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real II GPDC'}, 'Location', 'southeast', 'FontSize', 12);
title('CDI-P prediction performance by II GPDC', 'FontSize', 16, 'FontWeight', 'bold')
hold off;

%% sup Figure  AA - CDIG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% AA II AI IA COLOR
colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};%% LEARNING ~ AI SURR
compall=10;
plotk = zeros(compall, 4);valid=find(isnan(CDIG)==0);
for comp = 1:compall  
      [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([aa(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        aas = aa_surr{i};
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([aas(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color', [226/255, 90/255, 80/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 14;             % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('CDI-G variance explained', 'FontSize', 16, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.5])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages

legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real AA GPDC'}, 'Location', 'southeast', 'FontSize', 12);
title('CDI-G prediction performance by AA GPDC', 'FontSize', 16, 'FontWeight', 'bold')
hold off;

%%  sup Figure  ENTRAIN - CDIG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% entrain 

% Define labels
peaklabel = [4:12, 22:30, 40:48];

colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};
% entrain=data2(:,[4,5,21,26,40]);
entrain=data2(:,peaklabel);

compall=10;
plotk = zeros(compall, 4);
valid=intersect(find(isnan(CDIG)==0),find(isnan(data2(:,4))==0));
for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([entrain(valid,:), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        entrains = data2_surr{i};
     

        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([entrains(valid,peaklabel-3), data(valid, [1, 3, 4])]), zscore(CDIG(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
   
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color', [128/255, 0/255, 128/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 14;             % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('CDI-G variance explained', 'FontSize', 16, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.5])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages

legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real NSE'}, 'Location', 'southeast', 'FontSize', 12);
title('CDI-G prediction performance by NSE', 'FontSize', 16, 'FontWeight', 'bold')
hold off;


% ENTRAIN CDIW


%%  sup Figure  ENTRAIN - CDIG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% entrain 

% Define labels
peaklabel = [4:12, 22:30, 40:48];

colorlist={  [252/255, 140/255, 90/255],...
    [226/255, 90/255, 80/255],...
    [ 75/255, 116/255, 178/255],...
    [144/255, 190/255, 224/255]};
% entrain=data2(:,[4,5,21,26,40]);
entrain=data2(:,peaklabel);

compall=10;
plotk = zeros(compall, 4);
valid=intersect(find(isnan(CDIG)==0),find(isnan(data2(:,4))==0));
for comp = 1:compall  
    [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([entrain(valid,:), data(valid, [1, 3, 4])]), zscore(CDIP(valid)), comp);
    PCTVAR_real2 = sum(PCTVAR(2, :));
    plotk(comp, 1) = PCTVAR_real2;

    PCTVAR_su2 = zeros(1000, 1);
    for i = 1:1000
        entrains = data2_surr{i};
     

        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(zscore([entrains(valid,peaklabel-3), data(valid, [1, 3, 4])]), zscore(CDIP(valid)), comp);
        PCTVAR_su2(i) = sum(PCTVAR(2, :));
   
    end

    plotk(comp, 2) = prctile(PCTVAR_su2, 95);
    plotk(comp, 3) = mean(PCTVAR_su2);
    plotk(comp, 4) = prctile(PCTVAR_su2, 0); 
end

% Plot settings
figure;
hold on;

% Shaded 0-95% CI in gray
fill([1:compall, fliplr(1:compall)], [plotk(:, 2)', fliplr(plotk(:, 4)')], [200/255, 200/255, 200/255], 'EdgeColor', 'none');

% Mean of surrogates in black
plot(1:compall, plotk(:, 3), 'k', 'LineWidth', 3);

% Real mean in custom color [252, 140, 90]
plot(1:compall, plotk(:, 1), 'Color', [128/255, 0/255, 128/255], 'LineWidth', 3);

% Customize the axes
ax = gca;
ax.Box = 'on';               % Show borders for all sides
ax.XColor = 'k';              % Set color of x-axis to black
ax.YColor = 'k';              % Set color of y-axis to black
ax.LineWidth = 2;           % Set axis line width
ax.FontName = 'Arial';        % Set font to Arial
ax.FontSize = 14;             % Set font size
ax.FontWeight = 'bold';       % Set font to bold
ax.TickDir = 'in';            % Set ticks to point inward
ax.Layer = 'top';             % Ensure axes lines are on top

xlabel('Component number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('CDI-P variance explained', 'FontSize', 16, 'FontWeight', 'bold');
xlim([1, compall]);
ylim([0,0.6])
% Set y-axis labels as percentages
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = strcat(string(yticks * 100), '%');  % Convert to percentages

legend({'0-95% CI of surrogates', 'Mean of surrogates', 'Real NSE'}, 'Location', 'southeast', 'FontSize', 12);
title('CDI-P prediction performance by NSE', 'FontSize', 16, 'FontWeight', 'bold')
hold off;
%predict   attention failed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cv for iigpdc - cdig

%%%%%%%%%%%%%%%%%%%%%%%
%% AI,II,AA-CDI SUP FIG
%% 1000次boot
% rng(28);  % For reproducibility
SEX=double(SEX);
COUNTRY=double(COUNTRY);
% entrain=data2(:,[4,5,21,26,40]);
% valid=find(isnan(data2(:,4))==0);
load('CDI.mat');
peaklabel=[1:9,19:27,37:45];
tbl = table(ID, atten, zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, ii, ...
    'VariableNames', {'ID','atten', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP', 'ai'});
% for entrain
% tbl=tbl(valid,:);
tbl.ai=zscore(tbl.ai);
for i=1:size(tbl,1)
    id=a(i,2);
    for j=1:47
        if a2(j,1)==id
            tbl.CDIP(i)=a2(j,2);
            tbl.CDIW(i)=a2(j,3);
            tbl.CDIG(i)=a2(j,4);
        end
    end
end
n_folds = 10;  % Number of cross-validation folds
n_bootstrap = 1000;  % Number of bootstrap iterations
mean_variance_explained_bootstrap = zeros(n_bootstrap, 1);  % Store mean variance explained per bootstrap

for boot = 1:n_bootstrap
    % Bootstrap sample of the entire dataset
    bootstrap_idx = datasample(1:height(tbl), height(tbl), 'Replace', true);
    tbl_bootstrap = tbl(bootstrap_idx, :);

    variance_explained = zeros(n_folds, 1);  % Store variance explained per fold for each bootstrap
valid=find(isnan(tbl_bootstrap.CDIG)==0);
tbl_bootstrap=tbl_bootstrap(valid,:);
    % Create cross-validation partition on the bootstrap sample
    cv = cvpartition(height(tbl_bootstrap), 'KFold', n_folds);

    for fold = 1:n_folds
        % Training and test indices based on current fold
        train_idx = training(cv, fold);
        test_idx = test(cv, fold);

        % Prepare predictors (X) and response (Y) for training
        X_train = [tbl_bootstrap.ai(train_idx,:), tbl_bootstrap.AGE(train_idx), tbl_bootstrap.SEX(train_idx), tbl_bootstrap.COUNTRY(train_idx)];
        Y_train = tbl_bootstrap.CDIG(train_idx);

        % Train PLS model
        n_components = 2;  % Number of components
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(X_train, Y_train, n_components);

        % Prepare test data
        X_test = [tbl_bootstrap.ai(test_idx,:), tbl_bootstrap.AGE(test_idx), tbl_bootstrap.SEX(test_idx), tbl_bootstrap.COUNTRY(test_idx)];
        Y_test = tbl_bootstrap.CDIG(test_idx);

        % Calculate test scores using trained model weights
        scores_test = X_test * stats.W;

        % Compute variance explained (R^2) in the test set for this fold
%         variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
%                                         corr(Y_test, scores_test(:, 2))^2, ...
%                                         corr(Y_test, scores_test(:, 3))^2, ...
%                                         corr(Y_test, scores_test(:, 4))^2, ...
%                                         corr(Y_test, scores_test(:, 5))^2]);
        variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
                                        corr(Y_test, scores_test(:, 2))^2]);
    end

    % Mean variance explained for this bootstrap iteration
    mean_variance_explained_bootstrap(boot) = mean(variance_explained);
    boot
end

% Final results
mean_variance_explained = mean(mean_variance_explained_bootstrap);
std_variance_explained = std(mean_variance_explained_bootstrap);

% Display results
fprintf('\nBootstrap Results (1000 iterations) of Mean variance explained with 10-Fold CV:\n');
fprintf('Mean of Mean variance explained = %f, Std of Mean variance explained = %f\n', mean_variance_explained, std_variance_explained);
fprintf('Range of Mean variance explained = [%f, %f]\n', min(mean_variance_explained_bootstrap), max(mean_variance_explained_bootstrap));


%% entrain-CDI SUP FIG
%% 1000次boot,比较AI,II,AA,ENTRAIN的表现。 
% rng(28);  % For reproducibility
SEX=double(SEX);
COUNTRY=double(COUNTRY);
entrain=data2(:,[4,5,21,26,40]);
valid=find(isnan(data2(:,4))==0);
load('CDI.mat');
peaklabel=[1:9,19:27,37:45];
% tbl = table(ID, atten, zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, data2(:,peaklabel), ...
%     'VariableNames', {'ID','atten', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP', 'ai'});
% or
tbl = table(ID, atten, zscore(learning), zscore(AGE), SEX, COUNTRY, blocks, CONDGROUP, entrain, ...
    'VariableNames', {'ID','atten', 'learning', 'AGE', 'SEX', 'COUNTRY', 'block', 'CONDGROUP', 'ai'});
% for entrain
tbl=tbl(valid,:);
tbl.ai=zscore(tbl.ai);
for i=1:size(tbl,1)
    id=a(i,2);
    for j=1:47
        if a2(j,1)==id
            tbl.CDIP(i)=a2(j,2);
            tbl.CDIW(i)=a2(j,3);
            tbl.CDIG(i)=a2(j,4);
        end
    end
end
valid=find(isnan(tbl.CDIG)==0);
tbl=tbl(valid,:);
% entrainment should use 5 fold because of less sample size valid.
n_folds = 5;  % Number of cross-validation folds
n_bootstrap = 1000;  % Number of bootstrap iterations
mean_variance_explained_bootstrap = zeros(n_bootstrap, 1);  % Store mean variance explained per bootstrap

for boot = 1:n_bootstrap
    % Bootstrap sample of the entire dataset
    bootstrap_idx = datasample(1:height(tbl), height(tbl), 'Replace', true);
    tbl_bootstrap = tbl(bootstrap_idx, :);

    variance_explained = zeros(n_folds, 1);  % Store variance explained per fold for each bootstrap

    % Create cross-validation partition on the bootstrap sample
    cv = cvpartition(height(tbl_bootstrap), 'KFold', n_folds);

    for fold = 1:n_folds
        % Training and test indices based on current fold
        train_idx = training(cv, fold);
        test_idx = test(cv, fold);

        % Prepare predictors (X) and response (Y) for training
        X_train = [tbl_bootstrap.ai(train_idx,:), tbl_bootstrap.AGE(train_idx), tbl_bootstrap.SEX(train_idx), tbl_bootstrap.COUNTRY(train_idx)];
        Y_train = tbl_bootstrap.CDIG(train_idx);

        % Train PLS model
        n_components = 2;  % Number of components
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(X_train, Y_train, n_components);

        % Prepare test data
        X_test = [tbl_bootstrap.ai(test_idx,:), tbl_bootstrap.AGE(test_idx), tbl_bootstrap.SEX(test_idx), tbl_bootstrap.COUNTRY(test_idx)];
        Y_test = tbl_bootstrap.CDIG(test_idx);

        % Calculate test scores using trained model weights
        scores_test = X_test * stats.W;

        % Compute variance explained (R^2) in the test set for this fold
%         variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
%                                         corr(Y_test, scores_test(:, 2))^2, ...
%                                         corr(Y_test, scores_test(:, 3))^2, ...
%                                         corr(Y_test, scores_test(:, 4))^2, ...
%                                         corr(Y_test, scores_test(:, 5))^2]);
        variance_explained(fold) = sum([corr(Y_test, scores_test(:, 1))^2, ...
                                        corr(Y_test, scores_test(:, 2))^2]);
    end

    % Mean variance explained for this bootstrap iteration
    mean_variance_explained_bootstrap(boot) = mean(variance_explained);
    boot
end

% Final results
mean_variance_explained = mean(mean_variance_explained_bootstrap);
std_variance_explained = std(mean_variance_explained_bootstrap);

% Display results
fprintf('\nBootstrap Results (1000 iterations) of Mean variance explained with 10-Fold CV:\n');
fprintf('Mean of Mean variance explained = %f, Std of Mean variance explained = %f\n', mean_variance_explained, std_variance_explained);
fprintf('Range of Mean variance explained = [%f, %f]\n', min(mean_variance_explained_bootstrap), max(mean_variance_explained_bootstrap));












%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bootstrap iI cdig loadings and plot fig 5 at fs11
n_nodes = 64;               % Number of nodes in MSNs
n_components = 2;            % Number of PLS components (adjust as necessary)
n_iterations = 1000;         % Number of bootstrap iterations
valid=find(isnan(CDIG)==0);
% Initialize storage for bootstrap weights on each component
bootstrap_weights = zeros(n_nodes, n_components, n_iterations);
X_train=zscore([ii(valid,:), data(valid, [1, 3, 4])]);
Y_train=zscore(CDIG(valid));
for iter = 1:n_iterations
    % Perform bootstrap sampling of data
    sample_idx = randi(size(X_train, 1), size(X_train, 1), 1); % Bootstrap sample indices
    X_bootstrap = X_train(sample_idx, :);
    Y_bootstrap = Y_train(sample_idx);

    % Fit PLS model on bootstrap sample
    [XL, ~, ~, ~, ~, ~, ~, ~] = plsregress(X_bootstrap, Y_bootstrap, n_components);

    % Store the weights for each component
    bootstrap_weights(:, :, iter) = XL(1:n_nodes,:); % Assuming XL contains weights for nodes
end

% Calculate mean and standard deviation of weights across bootstraps
mean_bootstrap_weights = mean(bootstrap_weights, 3);
std_bootstrap_weights = std(bootstrap_weights, [], 3);

% Calculate standardized weights (z-scores) for each node on each component
z_scores = mean_bootstrap_weights ./ std_bootstrap_weights;

% Rank the nodes based on their standardized weights on each component
[strength, rankings] = sort(abs(z_scores), 'descend');

% Display the rankings for each component
for comp = 1:n_components
    fprintf('Top 10 Nodes for Component %d:\n', comp);
    disp(rankings(1:10, comp)); % Display top 10 nodes for each component
end
temp=abs(z_scores);
save('iicdiloading.mat','temp')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% figure 5c
%% loading plot

load('dataGPDC.mat','data')
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

listi=[ii3];
load('stronglistfdr5_gpdc_II.mat')
listii=listi(s4);
ii=sqrt(data(:,listii));
n = length(s4);
full_matrix = NaN(9, 9);  % 创建一个9x9的NaN矩阵
% Step 2: 将s4的数填充到full_matrix中
full_matrix_ii(s4) = 1;  % 按列优先顺序填充

listi=[ai3];
load('stronglistfdr5_gpdc_AI.mat')
listai=listi(s4);
ai=sqrt(data(:,listai));
n = length(s4);
full_matrix = NaN(9, 9);  % 创建一个9x9的NaN矩阵
% Step 2: 将s4的数填充到full_matrix中
full_matrix_ai(s4) = 1;  % 按列优先顺序填充

num_colors = 256;  % 定义颜色的级别数
blue = [0.2 0.2 1];  % 浅蓝色 (负值)
white = [1 1 1];  % 白色 (0值)
pink = [1 0.2 0.2];  % 浅粉色 (正值)

% 创建负到零的颜色过渡 (浅蓝色到白色)
neg_colors = [linspace(blue(1), white(1), num_colors/2)', ...
              linspace(blue(2), white(2), num_colors/2)', ...
              linspace(blue(3), white(3), num_colors/2)'];

% 创建零到正的颜色过渡 (白色到浅粉色)
pos_colors = [linspace(white(1), pink(1), num_colors/2)', ...
              linspace(white(2), pink(2), num_colors/2)', ...
              linspace(white(3), pink(3), num_colors/2)'];

% 合并负值和正值的颜色映射
% custom_colormap = [neg_colors; pos_colors];
custom_colormap=pos_colors;
%% 

% 定义标签
labels = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};

n = zeros(9,9);
n(find(full_matrix_ii == 1)) = temp(1:n_nodes,1);  % 将XL1的数据填充到n中
figure;  % 打开一个新的图形窗口
imagesc(n);  % 显示矩阵数据

% 为 X 和 Y 轴设置标签
set(gca, 'XTick', 1:9, 'XTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 14);  % 设置 X 轴标签并加粗
set(gca, 'YTick', 1:9, 'YTickLabel', labels, 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 14);  % 设置 Y 轴标签并加粗

% 设置标题和轴标签
xlabel('Sender channels', 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial');
ylabel('Receiver channels', 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial');
title('Component No.1 absolute loadings for II GPDC', 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial')
colormap(custom_colormap);  % 应用自定义 colormap
colorbar;  % 显示 colorbar
% Step 3: 设置颜色范围 [-0.5, 0.5]
caxis([0, 2]);  % 设置颜色映射范围
% 添加 colorbar，并调整颜色条的属性
h = colorbar;
set(h, 'FontSize', 14, 'FontName', 'Arial','FontWeight', 'bold');  % 设置颜色条的字体和大小
% 加粗轴线
set(gca, 'LineWidth', 2);
h = colorbar;  % 创建 colorbar
set(h, 'LineWidth', 2);  % 设置 colorbar 的边框线宽为 2 磅
hold off;
