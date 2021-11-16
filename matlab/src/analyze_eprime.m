function analyze_eprime(eprime_csv,out_dir)

%% Win/switch oriented eprime parsing

warning('off','MATLAB:table:ModifiedAndSavedVarnames');

% Load edat
Eo = readtable(eprime_csv);

% MainTask trials only
E = Eo(strcmp(Eo.Procedure,'Bet'),:);

% Sort by Fixation1_OnsetTime
[~,ind] = sort(E.Fixation1_OnsetTime);
E = E(ind,:);

% Initialize output data
E.RT = E.GameScreen_RT;
E.RT(E.RT==0) = nan;
E.Outcome(strcmp(E.Outcome,'?')) = {''};
E.Trial = (1:height(E))';
E.Run = nan(height(E),1);
E.TrialType(:) = {' '};
E.NoResponse = 1 * cellfun(@isempty,E.ChosenColor);
E.Switch(:) = {' '};
E.WinSwitch(:) = {' '};
E.WinStay(:) = {' '};
E.LoseSwitch(:) = {' '};
E.LoseStay(:) = {' '};
E.ProbabilisticLoss(:) = nan(height(E),1);
E.SubOptimalDeckLoss(:) = nan(height(E),1);

% FMRI sections (four runs) and verify
E.Run(E.Play_Sample>=  1 & E.Play_Sample<= 40) = 1;
E.Run(E.Play_Sample>= 41 & E.Play_Sample<= 80) = 2;
E.Run(E.Play_Sample>= 81 & E.Play_Sample<=120) = 3;
E.Run(E.Play_Sample>=121 & E.Play_Sample<=160) = 4;

if ...
		(sum(E.Run==1)~=40) || ...
		(sum(E.Run==2)~=40) || ...
		(sum(E.Run==3)~=40) || ...
		(sum(E.Run==4)~=40)
	error('Found other than 40 trials per run: %d %d %d %d', ...
		sum(E.Run==1),sum(E.Run==2),sum(E.Run==3),sum(E.Run==4) );
end


	
%% Trial timing  (Example from one run here)
% T1_TrialStart
%    + GameScreen_RT
% T2_Response
%    + ISI
% T2b_CardFlipOnset
% T3_FeedbackOnset
% T4_FeedbackOffset
%    + ITI
% T5_TrialEnd
%
%     T1_TrialStart                  0
%     T2_Response           337 - 1890  ms after T1   (1553)  *
%     T2b_CardFlipOnset    2045 - 6089                (4044)  **
%     T3_FeedbackOnset      133 -  184                (  51)
%     T4_FeedbackOffset    1016 - 1034                (  18)
%     T5_TrialEnd           900 - 8900                (8000)  **
%
% The next T1 is consistently 100ms after T5, so T5 is redundant. T2b-T3-T4
% are always together so no split there. So model T1 and T2b? That is a
% cue/response-then-feedback separation, although there is only a 4 sec
% variation in timing. See fmri-testrun/SPM.mat SPM.xX.X for example of
% what this looks like

% MainTasks:
%    WaitForScanner_OffsetTime       454819
%    Next PreRunFixation_OnsetTime   456153  (+1334 from offset)
%    Next T1_TrialStart              462170  (+7351 from offset)
%
%    WaitForScanner_OffsetTime       968890
%    Next PreRunFixation_OnsetTime   970227  (+1337 from offset)
%    Next T1_TrialStart              976244  (+7354 from offset)
%
%    WaitForScanner_OffsetTime      1412017
%    Next PreRunFixation_OnsetTime  1413351  (+1334 from offset)
%    Next T1_TrialStart             1419368  (+7351 from offset)

% Get our WaitForScanner_OffsetTime. We are missing this for Run 1 at
% present
E.T1_TrialStart_fMRI(E.Run==1) = nan;
E.T2b_CardFlipOnset_fMRI(E.Run==1) = nan;
offsets = sort(Eo.WaitForScanner_OffsetTime(strcmp(Eo.Procedure,'MainTask')));
for r = [2 3 4]
	E.T1_TrialStart_fMRIsec(E.Run==r) = ...
		(E.T1_TrialStart(E.Run==r) - offsets(r-1)) / 1000;
	E.T2b_CardFlipOnset_fMRIsec(E.Run==r) = ...
		(E.T2b_CardFlipOnset(E.Run==r) - offsets(r-1)) / 1000;
end



%% Drop non-response trials temporarily to facilitate some computations
keeps = E.NoResponse==0;
E.TrialType(~keeps) = {'NoResponse'};
origE = E;
E = E(keeps,:);


%% Switch/stay
% The trial AFTER the win where they gave the switched response is the
% win-switch trial.
%
% We need to account for the breaks between runs - don't count across runs
for r = [1 2 3 4]
	inds = find(E.Run==r);
	
	E.TrialType{inds(1)} = 'InitialTrial';
	
	for h = 2:length(inds)
		if strcmp(E.ChosenColor{inds(h)},E.ChosenColor{inds(h)-1})
			E.Switch{inds(h)} = 'Stay';
		else
			E.Switch{inds(h)} = 'Switch';
		end
	end
	
	for h = 2:length(inds)
		if strcmp(E.Outcome{inds(h)-1},'Win') & strcmp(E.Switch{inds(h)},'Switch')
			E.WinSwitch{inds(h)} = 'WinSwitch';
			E.TrialType{inds(h)} = 'WinSwitch';
		end
		if strcmp(E.Outcome{inds(h)-1},'Win') & strcmp(E.Switch{inds(h)},'Stay')
			E.WinStay{inds(h)} = 'WinStay';
			E.TrialType{inds(h)} = 'WinStay';
		end
		if strcmp(E.Outcome{inds(h)-1},'Lose') & strcmp(E.Switch{inds(h)},'Switch')
			E.LoseSwitch{inds(h)} = 'LoseSwitch';
			E.TrialType{inds(h)} = 'LoseSwitch';
		end
		if strcmp(E.Outcome{inds(h)-1},'Lose') & strcmp(E.Switch{inds(h)},'Stay')
			E.LoseStay{inds(h)} = 'LoseStay';
			E.TrialType{inds(h)} = 'LoseStay';
		end
		
	end
	
	E.ProbabilisticLoss = strcmp(E.Outcome,'Lose') & ...
		ismember(E.ChosenProb,{'Deck80','Deck90'});
	E.SubOptimalDeckLoss = strcmp(E.Outcome,'Lose') & ...
		ismember(E.ChosenProb,{'Deck10','Deck20','Deck40','Deck50'});

end


%% Compute summaries per run, ignoring non-response trials
summary = table();
for r = [1 2 3 4]
	inds = E.Run==r;
	
	summary.(['Run' num2str(r) '_AvgRT']) = ...
		mean(E.RT(inds));
	
	summary.(['Run' num2str(r) '_EarnedOverall']) = ...
		E.EarnedOverall(find(inds,1,'last'));
	
	summary.(['Run' num2str(r) '_Reversals']) = ...
		sum(E.RuleChange(inds));
	
	summary.(['Run' num2str(r) '_WinStay']) = ...
		sum(strcmp(E.TrialType(inds),'WinStay'));
	summary.(['Run' num2str(r) '_WinSwitch']) = ...
		sum(strcmp(E.TrialType(inds),'WinSwitch'));
	summary.(['Run' num2str(r) '_LoseStay']) = ...
		sum(strcmp(E.TrialType(inds),'LoseStay'));
	summary.(['Run' num2str(r) '_LoseSwitch']) = ...
		sum(strcmp(E.TrialType(inds),'LoseSwitch'));
	
	summary.(['Run' num2str(r) '_WinStayPct']) = ...
		100 * summary.(['Run' num2str(r) '_WinStay']) / ...
		(summary.(['Run' num2str(r) '_WinStay']) + ...
		summary.(['Run' num2str(r) '_WinSwitch']) );
	
	summary.(['Run' num2str(r) '_WinSwitchPct']) = ...
		100 * summary.(['Run' num2str(r) '_WinSwitch']) / ...
		(summary.(['Run' num2str(r) '_WinStay']) + ...
		summary.(['Run' num2str(r) '_WinSwitch']) );
	
	summary.(['Run' num2str(r) '_LoseStayPct']) = ...
		100 * summary.(['Run' num2str(r) '_LoseStay']) / ...
		(summary.(['Run' num2str(r) '_LoseStay']) + ...
		summary.(['Run' num2str(r) '_LoseSwitch']) );
	
	summary.(['Run' num2str(r) '_LoseSwitchPct']) = ...
		100 * summary.(['Run' num2str(r) '_LoseSwitch']) / ...
		(summary.(['Run' num2str(r) '_LoseStay']) + ...
		summary.(['Run' num2str(r) '_LoseSwitch']) );
	
	summary.(['Run' num2str(r) '_ProbabilisticLoss']) = ...
		sum(E.ProbabilisticLoss(inds));
	summary.(['Run' num2str(r) '_SubOptimalDeckLoss']) = ...
		sum(E.SubOptimalDeckLoss(inds));
	
	% But for counting non-response trials we have to look at the original
	% full dataset
	summary.(['Run' num2str(r) '_NonResponses']) = ...
		sum(strcmp(origE.TrialType(origE.Run==r),'NoResponse'));
	
end

writetable(summary,fullfile(out_dir,'eprime_summary.csv'));


%% Restore non-response trials
E = [E; origE(~keeps,:)];
E = sortrows(E,'Trial');


% report
%
report = E(:,{'Run','Play_Sample','TrialType', 'RT', ...
	'Switch', ...
	'WinSwitch','WinStay','LoseSwitch','LoseStay',...
	'ChosenColor','ChosenProb', ...
	'WinningDeck','Outcome','ProbabilisticLoss','SubOptimalDeckLoss', ...
	'T1_TrialStart_fMRIsec','T2b_CardFlipOnset_fMRIsec'});
writetable(report,fullfile(out_dir,'eprime_report.csv'));




