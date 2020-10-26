%% Calculate slopes and t-tests for beta freq band.

% Calculates slope as a fitted line in beta activity in between
% omission, control, and jumbled conditions. 

%% Load beta band stats file

clear

% ranges to work within
minlo0 = -1000;
minhi0 = -800;
maxlo0 = -700;
maxhi0 = -500;
zeropoint0 = -600;

minlo1 = minlo0+600;
minhi1 = minhi0+600;
maxlo1 = maxlo0+600;
maxhi1 = maxhi0+600;
zeropoint1 = 0;

zeropoint2 = 600;

for type =1:2
    
    loadpathstart = '/Users/dcc/EEG_Data/AV_Omit/Revision_Files/TF_Figure_Data/08e_TF_data_NoCommonBaseline/';
    if type==1
        loadkey = 'Channel_Freq_Band_Stats/';
        
    else 
        loadkey = 'Cluster_Freq_Band_Stats/';
        
    end
    
    loadpath = [loadpathstart loadkey];
    savepath = [loadpath(1:end-6) 'TStats/'];

    allFiles = dir([loadpath,'*.mat']);
    for j = 1:length(allFiles)

        loadFile1 = allFiles(j).name;
        % only run once per stim type. If Omit condition is loaded, skip to
        % next file.
        if loadFile1(end-26:end-23) == 'Cont'
            loadFile2 = [loadFile1(1:end-27) 'Omit' loadFile1(end-22:end)];
            loadname1 = [loadpath loadFile1];
            loadname2 = [loadpath loadFile2];
            savename = ['Cond_Stats' loadFile1(1:end-27)];
            for cond = 1:2
            % Load data
            
                if cond == 1
                    load(loadname1)
                else load(loadname2)
                end


                %% calculate slopes

                % find times for min and max power within ranges

                % get indices of ranges to work with by finding points closest to the min &
                % max lo & hi values @ t-1
                [v,ind] = min(abs(btimes-minlo0));
                minri0(1) = ind;
                [v,ind] = min(abs(btimes-minhi0));
                minri0(2) = ind;
                [v,ind] = min(abs(btimes-maxlo0));
                maxri0(1) = ind;
                [v,ind] = min(abs(btimes-maxhi0));
                maxri0(2) = ind;
                [v,ind] = min(abs(btimes-zeropoint0));
                zpti0 = ind;

                % get indices of ranges to work with by finding points closest to the min &
                % max lo & hi values @ t 
                [v,ind] = min(abs(btimes-minlo1));
                minri1(1) = ind;
                [v,ind] = min(abs(btimes-minhi1));
                minri1(2) = ind;
                [v,ind] = min(abs(btimes-maxlo1));
                maxri1(1) = ind;
                [v,ind] = min(abs(btimes-maxhi1));
                maxri1(2) = ind;
                [v,ind] = min(abs(btimes-zeropoint1));
                zpti1 = ind;

                % get zeropoint indices for t+1
                [v,ind] = min(abs(btimes-zeropoint2));
                zpti2 = ind;

                clear v ind

                % get indices of minimum and maximum beta within respective ranges for each
                % subject/component
                for i = 1:size(allBetaPower,2)
                    % @ t-1
                    [v,ind] = min(allBetaPower(minri0(1):minri0(2),i));
                    minInd0 = ind + minri0(1);
                    [v,ind] = max(allBetaPower(maxri0(1):maxri0(2),i));
                    maxInd0 = ind + maxri0(1);
                    % @ t
                    [v,ind] = min(allBetaPower(minri1(1):minri1(2),i));
                    minInd1 = ind + minri1(1);
                    [v,ind] = max(allBetaPower(maxri1(1):maxri1(2),i));
                    maxInd1 = ind + maxri1(1);
                    % get indices for t+1 using indices from t
                    tmintime = btimes(minInd1)+600;
                    tmaxtime = btimes(maxInd1)+600;
                    [v,ind] = min(abs(btimes-tmintime));
                    minInd2 = ind;
                    [v,ind] = min(abs(btimes-tmaxtime));
                    maxInd2 = ind;

                    clear v ind

                    % get slope for stim @ t-1
                    xvec=btimes(minInd0:maxInd0);
                    yvec=allBetaPower(minInd0:maxInd0,i);
                    xvec=xvec.';
                    fit=polyfit(xvec,yvec,1);
                    bslope0(i) = fit(1);

                    % get slope for stim @ t-1 using 0 point as max
                    xvec=btimes(minInd0:zpti0);
                    yvec=allBetaPower(minInd0:zpti0,i);
                    xvec=xvec.';
                    fit=polyfit(xvec,yvec,1);
                    bslope0zp(i) = fit(1);

                    % get slope for stim @ t
                    xvec=btimes(minInd1:maxInd1);
                    yvec=allBetaPower(minInd1:maxInd1,i);
                    xvec=xvec.';
                    fit=polyfit(xvec,yvec,1);
                    bslope1(i) = fit(1);

                    % get slope for t using the 0 point as max
                    xvec=btimes(minInd1:zpti1);
                    yvec=allBetaPower(minInd1:zpti1,i);
                    xvec=xvec.';
                    fit=polyfit(xvec,yvec,1);
                    bslope1zp(i) = fit(1);

                    % get slope for stim @ t+1
                    xvec=btimes(minInd2:maxInd2);
                    yvec=allBetaPower(minInd2:maxInd2,i);
                    xvec=xvec.';
                    fit=polyfit(xvec,yvec,1);
                    bslope2(i) = fit(1);

                    % get slope for t+1 using the 0 point as max
                    xvec=btimes(minInd2:zpti2);
                    yvec=allBetaPower(minInd2:zpti2,i);
                    xvec=xvec.';
                    fit=polyfit(xvec,yvec,1);
                    bslope2zp(i) = fit(1);

                    clear xvex yvec fit

                    % save slopes to work with
                    if cond == 1
                        
                        betadata.Contslope0 = bslope0;
                        betadata.Contslope1 = bslope1;
                        betadata.Contslope2 = bslope2;
                        betadata.Contslope0zp = bslope0zp;
                        betadata.Contslope1zp = bslope1zp;
                        betadata.Contslope2zp = bslope2zp;
                    else
                        betadata.Omitslope0 = bslope0;
                        betadata.Omitslope1 = bslope1;
                        betadata.Omitslope2 = bslope2;
                        betadata.Omitslope0zp = bslope0zp;
                        betadata.Omitslope1zp = bslope1zp;
                        betadata.Omitslope2zp = bslope2zp;
                    end
                    
                end
                
                clear bslope0 bslope0zp bslope1 beslope1zp bslope2 bslope2zp
                
            end
                
            %% calculate paired t-tests

            % calculate and save t-test results for t-1
            [h,p,ci,stats] = ttest(betadata.Contslope0,betadata.Omitslope0);
            betadata.ttest0.h = h;
            betadata.ttest0.p = p;
            betadata.ttest0.ci = ci;
            betadata.ttest0.stats = stats;

            % calculate and save t-test results for t-1 zeropoint
            [h,p,ci,stats] = ttest(betadata.Contslope0zp,betadata.Omitslope0zp);
            betadata.ttest0zp.h = h;
            betadata.ttest0zp.p = p;
            betadata.ttest0zp.ci = ci;
            betadata.ttest0zp.stats = stats;

            % calculate and save t-test results for t
            [h,p,ci,stats] = ttest(betadata.Contslope1,betadata.Omitslope1);
            betadata.ttest1.h = h;
            betadata.ttest1.p = p;
            betadata.ttest1.ci = ci;
            betadata.ttest1.stats = stats;

            % calculate and save t-test results for t zeropoint
            [h,p,ci,stats] = ttest(betadata.Contslope1zp,betadata.Omitslope1zp);
            betadata.ttest1zp.h = h;
            betadata.ttest1zp.p = p;
            betadata.ttest1zp.ci = ci;
            betadata.ttest1zp.stats = stats;

            % calculate and save t-test results for t+1
            [h,p,ci,stats] = ttest(betadata.Contslope2,betadata.Omitslope2);
            betadata.ttest2.h = h;
            betadata.ttest2.p = p;
            betadata.ttest2.ci = ci;
            betadata.ttest2.stats = stats;

            % calculate and save t-test results for t+1 zeropoint
            [h,p,ci,stats] = ttest(betadata.Contslope2zp,betadata.Omitslope2zp);
            betadata.ttest2zp.h = h;
            betadata.ttest2zp.p = p;
            betadata.ttest2zp.ci = ci;
            betadata.ttest2zp.stats = stats;

            % save p values for more convenient reading
            betadata.pvals.pval0 = betadata.ttest0.p;
            betadata.pvals.pval0zp = betadata.ttest0zp.p;
            betadata.pvals.pval1 = betadata.ttest1.p;
            betadata.pvals.pval1zp = betadata.ttest1zp.p;
            betadata.pvals.pval2 = betadata.ttest2.p;
            betadata.pvals.pval2zp = betadata.ttest2zp.p;

            clear h p ci stats

            %% Save data for stats
            fullsave = [savepath savename]; 
            save(fullsave, 'betadata')

            clear betadata
         
        else
        end
        
    end
    
end

clear

            
    

