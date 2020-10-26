%% shuffle T/F data along time dimension for each subject/component

clear


% load data
for i =1:4
    
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
    savepath = [loadpath(1:end-1) '_Shuffled/'];

    allFiles = dir([loadpath,'*.mat']);
    for j = 1:length(allFiles)
        tic
        loadFile = allFiles(j).name;
        savename = loadFile(1:end-4);
        fullsave = [savepath savename];

        % Load data
        loadname = [loadpath loadFile];
        load(loadname);
        
        if exist('TF_dataTheta') == 1
            TF_data = TF_dataTheta;
            tfdt = 1;
        else
            tfdt = 0;
        end

        % get number of TF sets
        nsets = size(TF_data,2);
        
 
        % concatenate ersp & itc
        for k = 1:nsets
            ersp(:,:,k)=TF_data(k).ersp;
            itc(:,:,k)=TF_data(k).itc;
        end
        
        ntimes = size(ersp,2);
        nfreqs = size(ersp,1);
        % Shuffle T/F along time axis 1000 x per subject per
        % component/channel at each frequency
        clear k
        for k = 1:nsets
            for l = 1:nfreqs
                for m = 1:1000
                    idx = randperm(ntimes);
                    ersp(l,idx,k) = ersp(l,:,k);
                    
                end
            end
            TF_data(k).ersp = ersp(:,:,k);
            
        end
        
        
        %save and clear variables
        if tfdt == 0
            save(fullsave, 'TF_data');
        else
            TF_dataTheta = TF_data;
            save(fullsave, 'TF_dataTheta');
        end
        etime = num2str(toc);
        readout= [savename '  #' num2str(j) ' of ' num2str(length(allFiles)) ' files in ' etime ' seconds'];
        disp(readout)
        
        clear TF_data TF_dataTheta nfreqs ntimes nsets ersp 
    end
end

clear
            
        
        
        
        
        
        