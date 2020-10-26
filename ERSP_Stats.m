%% Convert data ERSP & ITC data to useable form for plots

% Loads in all matsave files in TF_Data format and converts to useable
% format, and performs permutaion statistics. This new format will be used for imagesc plots as
% well as the freq band plots
 


%% 

clear
eeglab

for i =4:4
    
    loadpathstart = '/Users/dcc/EEG_Data/AV_Omit/Revision_Files/TF_Figure_Data/08e_TF_data_NoCommonBaseline/';
    if i==1
        loadkey = 'Channel_TF_Data/';
    elseif i==2
        loadkey = 'Channel_TF_Data_Theta/';
    elseif i==3
        loadkey = 'Cluster_TF_Data/';
    else 
        loadkey = 'Cluster_TF_Data_Theta/';
    end
    
    loadpath = [loadpathstart loadkey];
    savepath = [loadpath(1:end-1) '_Stats/'];

    allFiles = dir([loadpath,'*.mat']);
    for j = 1:length(allFiles)

        loadFile = allFiles(j).name;
        savename = loadFile(1:end-4);
        fullsave = [savepath savename];

        % Load data
        loadname = [loadpath loadFile];
        load(loadname);
        
        if exist('TF_dataTheta') == 1
            TF_data = TF_dataTheta;
        end

        % get number of TF sets
        nsets = size(TF_data,2);

        % get freqs & times
        freqs = TF_data(1).freqs;
        times = TF_data(1).times; 

        % concatenate ersp
        for k = 1:nsets
            ersp(:,:,k)=TF_data(k).ersp;
            itc(:,:,k)=TF_data(k).itc;
        end


        % average ERSP accross components/subjects
        avgersp = mean(ersp,3); 

        % Compute absolute highest ERSP values in the Average ERSP for symetrical scalling
        erspmax = [max(max(abs(avgersp)))];

        % convert absolute highest ERSP values for symetrical scale
        erspminmax = [-erspmax erspmax]; 
        
                %% Permutation Stats with FDR correction %%

        % permutation statistics with FDR correction
        pvals = std_stat({ ersp zeros(size(ersp)) }', 'method', 'permutation', 'condstats', 'on', 'correctm', 'fdr'); 

        % save values for stat contouring
        tmpersp05 = avgersp;
        tmpersp01 = avgersp;

        % Mask any ERSP values with less than p.05 sig
        tmpersp05(pvals{1} > 0.05) = 1;

        % Mask any ERSP values with less than p.01 sig
        tmpersp01(pvals{1} > 0.01) = 1;

        % Make all significant values = 2, for only single contour line
        tmpersp05(tmpersp05 ~= 1) = 2; 
        tmpersp01(tmpersp01 ~= 1) = 2; 
        
        
        %% Save & clear variables
        save(fullsave, 'freqs','times','ersp','itc','avgersp','erspmax','erspminmax');
%         save(fullsave, 'freqs','times','ersp','itc','avgersp','erspmax','erspminmax',...
%             'pvals','tmpersp05','tmpersp01');
        
        clear nsets freqs times ersp itc avgersp erspmax erspminmax pvals tmpersp05 tmpersp01 TF_data TF_dataTheta;
        
    end
end
