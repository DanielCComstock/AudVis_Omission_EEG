% Epoching Visual Data, Stim Locked 
Ns = 18; Nc = 4; % Ns - number of subjects; Nc - Number of conditions;'
ep = ['5';'2';'6';'4'] % array of condition names
epoch = cellstr(ep) % converts string to cell for indexing
loadpath = 'H:\Data\AVOmit\EEGPC\05_CleanICsByStudy\'; % Path for loading sets
savepath = 'C:\NewData\AV_Omit_Revisions\06d_Epoch\'; % Path for saving epochs
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[]; % clears the dataset
for S = 1:Ns  % For each of the subjects
        loadname = ['AV_Omit_' int2str(S) '_PreProc2_selectICsByCluster.set']; % name used to load PreEpoch dataset
        epochname = ['AV_Omit_' int2str(S) '_ICA_Epoch_']; % name used to save epoched dataset
        
        for E = 1:Nc
            epochRejName = [epochname char(epoch(E)) '_Rej']; % name for epoch_rej dataset
            EEG = pop_loadset('filename',loadname,'filepath',loadpath); % Load PreEpoch dateset
            EEG = eeg_checkset( EEG );
            eeglab redraw;
            EEG = pop_epoch( EEG, {  char(epoch(E))  }, [-3  3], 'newname',[epochname char(epoch(E))], 'epochinfo', 'yes'); % epoch dataset and name
            EEG = eeg_checkset( EEG );
            eeglab redraw;

            EEG = pop_eegthresh(EEG,1,[1:ALLEEG.nbchan] ,-500,500,-01,1.9961,0,0); % reject any epoch beyond +/-500uv
            EEG = eeg_checkset( EEG );
            EEG = pop_jointprob(EEG,1,[1:ALLEEG.nbchan] ,6,2,1,0); % reject any epoch > 6 st.dev and any channel > 2 st.dev
            EEG = eeg_checkset( EEG );
            eeglab redraw;
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',[savepath epochname char(epoch(E)) '.set'] ,'overwrite','on','gui','off'); % save epoched dataset
            STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[]; % clears the dataset
        end
end 
eeglab redraw;