%% FDR correction & Post hoc contrast test for beta slopes %%


% looks at beta sopes with post hoc test consisting of control + shuffle -
% 2 * omit slope, then tests if outcome is significatnly different from 0.


%% Load beta data

clear


for cond =1:2
    
    loadpathstart = '/Users/dcc/EEG_Data/AV_Omit/Revision_Files/TF_Figure_Data/08e_TF_data_NoCommonBaseline/';
    if cond==1
        loadkey = 'Channel_Freq_Band_Shuffled_TStats/';
        
    else 
        loadkey = 'Cluster_Freq_Band_Shuffled_TStats/';
        
    end
    
    loadpath = [loadpathstart loadkey];
    savepath = [loadpathstart 'CorrectedCombinedStats/New/'];
    allFiles = dir([loadpath,'*.mat']);
    af={allFiles.name};
    
    % get indices of modality specific files

    VisInd = strfind(af,'Vis');
    VisInd = find(~cellfun('isempty',VisInd));
    AudInd = strfind(af,'Aud');
    AudInd = find(~cellfun('isempty',AudInd));

    for j = 1:length(af)

        loadFile = af{j};
        combinedTStatsData(j).name = loadFile;

        % Load data
        loadname = [loadpath loadFile];
        load(loadname);

        % previously factored stats for FDR correcton
        combinedTStatsData(j).CtoOzpPV = betadata.pvals.pval1zp;
        combinedTStatsData(j).OtoOSzpPV = betadata.pvals.pvalOmShufzp;
        combinedTStatsData(j).CtoOzpStats = betadata.ttest1zp;
        combinedTStatsData(j).OtoOSzpStats = betadata.ttest_OmToOmShuff1zp;
        
        % slopes factored for post hoc contrast test
        contrastOmitShuf = betadata.Contslope1zp + ...
            betadata.OmitShuffslope1zp - (2*betadata.Omitslope1zp);

        % t-tests for contrast
        [h,p,ci,stats] = ttest(contrastOmitShuf);
        combinedTStatsData(j).contrastOmitShuf.h = h;
        combinedTStatsData(j).contrastOmitShuf.p = p;
        combinedTStatsData(j).contrastOmitShuf.ci = ci;
        combinedTStatsData(j).contrastOmitShuf.stats = stats;
   
        clear betadata
        
    end
    
        % load p-values in one place 
    lngth = length(combinedTStatsData);
    data = zeros(1,lngth*3);
    for i = 1:lngth
        data(i) = combinedTStatsData(i).CtoOzpPV;
        data(i+lngth) = combinedTStatsData(i).OtoOSzpPV;
        data(i+lngth*2) = combinedTStatsData(i).contrastOmitShuf.p;
    end
    
    % FDR test
    %[FDR,Q] = mafdr(data); Unreliable with smaller sets, us BHFDR flag
    [BHFDR]= mafdr(data,'BHFDR', true);

    % load corrected test back into combinedData
    for l = 1:lngth
        combinedTStatsData(l).CtoOzpFDRpv=BHFDR(l);
        combinedTStatsData(l).OtoOSzpFDRpv=BHFDR(l+lngth);
        combinedTStatsData(l).contrastOmitShufFDRpv=BHFDR(l+lngth*2);
    end
    
    % save combinedData structure
    if cond == 1
        Vissavename = 'Vis_Chan_TStats';
        Audsavename = 'Aud_Chan_TStats';
    else
        Vissavename = 'Vis_Clust_Tstats';
        Audsavename = 'Aud_Clust_Tstats';
    end
    
    tmpdata = combinedTStatsData;
    clear combinedTStatsData
    
    vistmpdata=tmpdata(VisInd);
    audtmpdata=tmpdata(AudInd);

    combinedTStatsData = vistmpdata;    
    fullsave = [savepath Vissavename]; 
    save(fullsave, 'combinedTStatsData');
    clear combinedTStatsData
    
    combinedTStatsData = audtmpdata;    
    fullsave = [savepath Audsavename]; 
    save(fullsave, 'combinedTStatsData');
    clear combinedTStatsData
        
end
        