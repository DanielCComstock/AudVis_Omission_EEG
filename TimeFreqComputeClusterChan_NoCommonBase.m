%%computing t/f for AV_Omit project %%

% code will need to get dateset info from the study structure for
% each dataset in each cluster. t/f will be computed with a common baseline
% between 2 conditions. Output of each t/f will be saved into a mat file
% for latter processing and ploting using the imagesc and std_stat
% functions.



%% Load study information

% first load study in EEGLAB to extract the study information. The study
% is cleared after study information is extracted

% Set memory option for only loading 1 dataset into memory at a time
pop_editoptions( 'option_storedisk', 1);

% load study
[STUDY ALLEEG] = pop_loadstudy('filename', 'AV_Omit_Revis_Wide_Source.study', 'filepath', 'C:\NewData\AV_Omit_Revisions\07_Studies');
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];

% Save study info and clear stuyd
studyinfo = STUDY;
fullsaveStudy = 'C:\NewData\AV_Omit_Revisions\07_Studies\AV_Omit_Cluster_Study_Info';
save(fullsaveStudy, 'studyinfo');
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];  


%% t/f functions (cluster)

% Set memory option to allow for loading of multiple datasets into memory
pop_editoptions( 'option_storedisk', 0);

% For loop for each cluster. Starts with 3rd cluster (cluster 1 is parent
% cluster
%   i = clutser #
%   j = control or omit indicator
%   k = dataset and component indicator
for i = 2: length(studyinfo.cluster)
    
    % for loop for number of conditions. In this case there are 4
    % conditions 
    for j = 1:4
        
        if j==1
            condition = 'Aud_Cont';
        elseif j==2
            condition = 'Vis_Cont';
        elseif j==3
            condition = 'Aud_Omit';
        else 
            condition = 'Vis_Omit';
        end
        % for loop that determines number of components in each cluster
        for k = 1:size(studyinfo.cluster(i).sets,2) 
            
            % find indices of datsets needed for each t/f analysis.
            % sets key:
            %   sets(1,x) = aud cont
            %   sets(2,x) = vis cont
            %   sets(3,x) = aud omit
            %   sets(4,x) = vis omit 
            %   sCont & sOmit = aud if j = 1 & = vis if j = 2
            datasetInd = studyinfo.cluster(i).sets(j,k);
                       
            % get component number.
            compNum = studyinfo.cluster(i).comps(k);
           
            % load datafiles
            EEG = pop_loadset('filename',studyinfo.datasetinfo(datasetInd).filename,...
                'filepath',studyinfo.datasetinfo(datasetInd).filepath);
            EEG = eeg_checkset( EEG );
            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG );
                      
            % perform t/f with common baseline from 3 to 35 Hz 
            % ALLEEG 1 = cont, ALLEEG 2 = omit
            [ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef(ALLEEG(1).icaact(compNum,:,:),...
            ALLEEG(1).pnts,[ALLEEG(1).xmin ALLEEG(1).xmax]*1000, ALLEEG(1).srate,'cycles', [3 0.6],... 
             'nfreqs', 96, 'ntimesout', 400, 'baseline', [-3000 2998],'freqs', [3 35],...
            'freqscale', 'linear','plotphasesign','off', 'plotersp','off', 'plotitc','off');
        
            % Read out information from above parameters:
                % Each trial contains samples from -3000 ms before to
                % 2998 ms after the timelocking event.
                % Image frequency direction: normal
                % Using 3 cycles at lowest frequency to 14 at highest.
                % Generating 400 time points (-2442.4 to 2440.4 ms)
                % Finding closest points for time variable
                % Time values for time/freq decomposition is not perfectly uniformly distributed
                % The window size used is 571 samples (1115.23 ms) wide.
                % Estimating 96 linear-spaced frequencies from 3.0 Hz to 35.0 Hz.
          
            % Load data into dataC for control and dataO for omit
            TF_data(k).ersp = ersp;
            TF_data(k).itc = itc;
            TF_data(k).powbase = powbase; 
            TF_data(k).times = times;
            TF_data(k).freqs = freqs;
            TF_data(k).filename = studyinfo.datasetinfo(datasetInd).filename;
            TF_data(k).component = num2str(compNum);

            % perform t/f with common baseline from 3 to 8 Hz with lower
            % cycle count for better temporal resolution
            % ALLEEG 1 = cont, ALLEEG 2 = omit
            [ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef(ALLEEG(1).icaact(compNum,:,:),...
            ALLEEG(1).pnts,[ALLEEG(1).xmin ALLEEG(1).xmax]*1000, ALLEEG(1).srate,'cycles', [1 0.1],... 
             'nfreqs', 15, 'ntimesout', 400, 'baseline', [-3000 2998],'freqs', [3 8],...
            'freqscale', 'linear','plotphasesign','off', 'plotersp','off', 'plotitc','off');
        
            % Read out information from above parameters:
                % Each trial contains samples from -3000 ms before to
                % 2998 ms after the timelocking event.
                % Image frequency direction: normal
                % Using 1 cycles at lowest frequency to 2.4 at highest.
                % Generating 400 time points (-2813.5 to 2811.5 ms)
                % Finding closest points for time variable
                % Time values for time/freq decomposition is not perfectly uniformly distributed
                % The window size used is 191 samples (373.047 ms) wide.
                % Estimating 15 linear-spaced frequencies from 3.0 Hz to 8.0 Hz.
  
            % Load theta data into dataThetaC for control and dataThetaO for omit
            TF_dataTheta(k).ersp = ersp;
            TF_dataTheta(k).itc = itc;
            TF_dataTheta(k).powbase = powbase; 
            TF_dataTheta(k).times = times;
            TF_dataTheta(k).freqs = freqs;
            TF_dataTheta(k).filename = studyinfo.datasetinfo(datasetInd).filename;
            TF_dataTheta(k).component = num2str(compNum);

            STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[]; 
            
        end
  
        % Save output files for later plotting

        % create savepath and savename
        savepath = 'C:\NewData\AV_Omit_Revisions\08e_TF_data_NoCommonBaseline\Cluster_TF_Data\';
        savepathTheta = 'C:\NewData\AV_Omit_Revisions\08e_TF_data_NoCommonBaseline\Cluster_TF_Data_Theta\';
        savename = ['Clust_' num2str(i) '_' condition];
        savenameTheta = ['Clust_' num2str(i) '_' condition '_Theta'];
        savenameStudy = 'AV_Omit_Cluster_Study_Info';
        fullsavedata = [savepath savename];
        fullsaveTheta = [savepathTheta savenameTheta];
        % Save data files
        save(fullsavedata, 'TF_data');
        save(fullsaveTheta, 'TF_dataTheta');
        % Clear dataC & data 
        clear TF_data TF_dataTheta;
    end
end

% Reset memory option for keeping only dataset loaded at a time
pop_editoptions( 'option_storedisk', 1);


%% Channel T/F Processing Start

% first load study in EEGLAB to extract the study information. The study
% is cleared after study information is extracted

% Set memory option for only loading 1 dataset into memory at a time
pop_editoptions( 'option_storedisk', 1);

% load study
[STUDY ALLEEG] = pop_loadstudy('filename', 'AV_Omit_Revis_Wide_Channel.study', 'filepath', 'C:\NewData\AV_Omit_Revisions\07_Studies');
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];

% Save study info and clear stuyd
studyinfo = STUDY;
fullsaveStudy = 'C:\NewData\AV_Omit_Revisions\07_Studies\AV_Omit_Channel_Study_Info';
save(fullsaveStudy, 'studyinfo');
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];  

%% t/f functions (chan)

% Set memory option to allow for loading of multiple datasets into memory
pop_editoptions( 'option_storedisk', 0);

% For loop for each channel
%   i = channel
%   j = control or omit indicator
%   k = subject # indicator
for i = 1:32
    
    % for loop for number of conditions. In this case there are 4
    % conditions 
    for j = 1:4
        
        if j==1
            condition = 'Aud_Cont';
        elseif j==2
            condition = 'Vis_Cont';
        elseif j==3
            condition = 'Aud_Omit';
        else 
            condition = 'Vis_Omit';
        end

        % for loop for the number of subjects
        for k = 1:18  
            
            % find indices of datsets needed for each t/f analysis.
            % sets key:
            %   sets(1,x) = aud cont
            %   sets(2,x) = vis cont
            %   sets(3,x) = aud omit
            %   sets(4,x) = vis omit
            datasetInd = studyinfo.setind(j,k);
        
            % load datafiles
            EEG = pop_loadset('filename',studyinfo.datasetinfo(datasetInd).filename,...
                'filepath',studyinfo.datasetinfo(datasetInd).filepath);
            EEG = eeg_checkset( EEG );
            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG );
            
            % get channel number. will always be the same for both
            chanNum = studyinfo.changrp(i).allinds{1}(k);
            chanName = studyinfo.changrp(i).name;

            % perform t/f with common baseline from 3 to 35 Hz 
            % ALLEEG 1 = cont, ALLEEG 2 = omit
            [ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef(ALLEEG(1).data(chanNum,:,:),...
            ALLEEG(1).pnts,[ALLEEG(1).xmin ALLEEG(1).xmax]*1000, ALLEEG(1).srate,'cycles', [3 0.6],... 
             'nfreqs', 96, 'ntimesout', 400, 'baseline', [-3000 2998],'freqs', [3 35],...
            'freqscale', 'linear','plotphasesign','off', 'plotersp','off', 'plotitc','off');
        
            % Read out information from above parameters:
                % Each trial contains samples from -3000 ms before to
                % 2998 ms after the timelocking event.
                % Image frequency direction: normal
                % Using 3 cycles at lowest frequency to 14 at highest.
                % Generating 400 time points (-2442.4 to 2440.4 ms)
                % Finding closest points for time variable
                % Time values for time/freq decomposition is not perfectly uniformly distributed
                % The window size used is 571 samples (1115.23 ms) wide.
                % Estimating 96 linear-spaced frequencies from 3.0 Hz to 35.0 Hz.
     
            % Load data into TF_data (structured array)
            TF_data(k).ersp = ersp;
            TF_data(k).itc = itc;
            TF_data(k).powbase = powbase; 
            TF_data(k).times = times;
            TF_data(k).freqs = freqs;
            TF_data(k).filename = studyinfo.datasetinfo(datasetInd).filename;
            TF_data(k).channel = chanName;

            % perform t/f with common baseline from 3 to 8 Hz with lower
            % cycle count for better temporal resolution
            [ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef(ALLEEG(1).data(chanNum,:,:),...
            ALLEEG(1).pnts,[ALLEEG(1).xmin ALLEEG(1).xmax]*1000, ALLEEG(1).srate,'cycles', [1 0.1],... 
             'nfreqs', 15, 'ntimesout', 400, 'baseline', [-3000 2998],'freqs', [3 8],...
            'freqscale', 'linear','plotphasesign','off', 'plotersp','off', 'plotitc','off');
        
            % Read out information from above parameters:
                % Each trial contains samples from -3000 ms before to
                % 2998 ms after the timelocking event.
                % Image frequency direction: normal
                % Using 1 cycles at lowest frequency to 2.4 at highest.
                % Generating 400 time points (-2813.5 to 2811.5 ms)
                % Finding closest points for time variable
                % Time values for time/freq decomposition is not perfectly uniformly distributed
                % The window size used is 191 samples (373.047 ms) wide.
                % Estimating 15 linear-spaced frequencies from 3.0 Hz to 8.0 Hz.

            % Load theta data into TF_dataTheta
            TF_dataTheta(k).ersp = ersp;
            TF_dataTheta(k).itc = itc;
            TF_dataTheta(k).powbase = powbase;  
            TF_dataTheta(k).times = times;
            TF_dataTheta(k).freqs = freqs;
            TF_dataTheta(k).filename = studyinfo.datasetinfo(datasetInd).filename;
            TF_dataTheta(k).channel = chanName;

            STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[]; 
            
        end
   
        % Save output files for later plotting
        
        savepath = 'C:\NewData\AV_Omit_Revisions\08e_TF_data_NoCommonBaseline\Channel_TF_Data\';
        savepathTheta = 'C:\NewData\AV_Omit_Revisions\08e_TF_data_NoCommonBaseline\Channel_TF_Data_Theta\';
        savename = ['Chan_' chanName '_' condition];
        savenameTheta = ['Chan_' chanName '_' condition '_Theta'];
        fullsavedata = [savepath savename];
        fullsaveTheta = [savepathTheta savenameTheta];
        
        % Save data files
        save(fullsavedata, 'TF_data');
        save(fullsaveTheta, 'TF_dataTheta');
        % Clear dataC & data 
        clear TF_data TF_dataTheta;

    end
    
end

% Reset memory option for keeping only dataset loaded at a time
pop_editoptions( 'option_storedisk', 1);
            