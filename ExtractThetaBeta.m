%% Script to extract Theta & Beta, and save output for plotting and slope measurements
 
 

%% Load data sets
clear

for i = 1:2 % 1 = channel 2 = cluster
    
    loadpathstart = '/Users/dcc/EEG_Data/AV_Omit/Revision_Files/TF_Figure_Data/08e_TF_data_NoCommonBaseline/';
    if i==1
        loadkey = 'Channel_TF_Data/';
    else
        loadkey = 'Cluster_TF_Data/';
    end
    
    loadpathbeta = [loadpathstart loadkey];
    loadpaththeta = [loadpathstart loadkey(1:end-1) '_Theta/'];
    figsavepath = [loadpathbeta(1:end-8) 'Freq_Band_Figs/'];
    statssavepath = [loadpathbeta(1:end-8) 'Freq_Band_Stats/'];

    allFiles = dir([loadpathbeta,'*.mat']);
    for j = 1:length(allFiles)
        loadFile = allFiles(j).name;
        savename = loadFile(1:end-4);
        

        % Load data
        betaloadname = [loadpathbeta loadFile];
        thetaloadname = [loadpaththeta loadFile(1:end-4) '_Theta.mat'];
        load(betaloadname);
        load(thetaloadname);
        
        titlename = loadFile(1:end-4);
        titlename = strrep(titlename, '_',' ');
        

 
     %% Transform Beta activity

        % get number of TF sets
        nsets = size(TF_data,2);

        % get freqs & times
        bfreqs = TF_data(1).freqs;
        btimes = TF_data(1).times; 

        % concatenate ersp
        for k = 1:nsets
            b_ersp(:,:,k)=TF_data(k).ersp;
        end


        % average ERSP accross components/subjects
        % avg_b_ersp = mean(b_ersp,3);

        % get beta indicies
        betaIndices = find (bfreqs <= 29 & bfreqs >= 17);

        % Get just beta power for all subjects/components. This is used for
        % plotting standard error as well as for slope data
        allBetaPower = mean(b_ersp([betaIndices],:,:));
        allBetaPower = squeeze(allBetaPower);

        % Compute average beta power accross all subjects/components
        meanBetaPower = mean(allBetaPower,2);

        % Compute standard error for beta
        betaErrorBar = std(allBetaPower.')/sqrt(size(allBetaPower,2));



    %% Transform Theta activity

        % get number of TF sets
        nsets = size(TF_dataTheta,2);

        % get freqs & times
        tfreqs = TF_dataTheta(1).freqs;
        ttimes = TF_dataTheta(1).times; 

        % concatenate ersp
        for k = 1:nsets
            t_ersp(:,:,k)=TF_dataTheta(k).ersp;
        end


        % average ERSP accross components/subjects
        % avg_t_ersp = mean(t_ersp,3);

        % get beta indicies
        thetaIndices = find (tfreqs <= 8 & tfreqs >= 3);

        % Get just theta power for all subjects/components. This is used for
        % plotting standard error as well as for slope data
        allThetaPower = mean(t_ersp([thetaIndices],:,:));
        allThetaPower = squeeze(allThetaPower);

        % Compute average theta power accross all subjects/components
        meanThetaPower = mean(allThetaPower,2);

        % Compute standard error for theta
        thetaErrorBar = std(allThetaPower.')/sqrt(size(allThetaPower,2));


        
        %% Save data for stats
        fullsave = [statssavepath savename '_ThetaBetaStatsData']; 
        save(fullsave, 'nsets','bfreqs','btimes','b_ersp','betaIndices','allBetaPower','meanBetaPower',...
        'tfreqs','ttimes','t_ersp','thetaIndices','allThetaPower','meanThetaPower');

        clear nsets bfreqs btimes b_ersp betaIndices allBetaPower meanBetaPower TF_data TF_dataTheta...
        tfreqs ttimes t_ersp thetaIndices allThetaPower meanThetaPower
    
    end
end
    
    
    