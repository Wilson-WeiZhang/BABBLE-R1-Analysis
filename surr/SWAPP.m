path='F:\infanteeg\CAM BABBLE EEG DATA\2024\data_matfile\surrGPDCSET5\'

d=dir([path,'\*\*PDC.mat']);
for i=1:length(d)
    i/42000
    load([d(i).folder,'\',d(i).name]);
    TMP=AI;
    AI=IA;
    IA=TMP;
    save([d(i).folder,'\',d(i).name],'AA','AI','IA','II');
end

path='F:\infanteeg\CAM BABBLE EEG DATA\2024\data_matfile\DTF3_nonorpdc_nonorpower\'

d=dir([path,'\*PDC.mat']);
for i=1:length(d)
    i/length(d)
    load([d(i).folder,'\',d(i).name]);
    TMP=AI;
    AI=IA;
    IA=TMP;
    save([d(i).folder,'\',d(i).name],'AA','AI','IA','II');
end

