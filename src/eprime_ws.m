%% Win/switch oriented eprime parsing

% For timing vs scanner, looks like we reference
%  Procedure 'MainTask'
%  PreRunFixation.OnsetTime
%  PreRunFixation.OffsetTime

% Load edat
Eo = readtable(eprime_csv);

% MainTask trials only
E = Eo(strcmp(Eo.Procedure,'Bet'),:);

% Sort by Fixation1_OnsetTime
[~,ind] = sort(E.Fixation1_OnsetTime);
E = E(ind,:);

% Initialize
E.Trial = (1:height(E))';
E.Run = nan(height(E),1);
E.TrialType(:) = {' '};
E.NoResponse = 1 * cellfun(@isempty,E.ChosenColor);
E.Switch(:) = {' '};
E.WinSwitch(:) = {' '};
E.WinStay(:) = {' '};
E.LoseSwitch(:) = {' '};
E.LoseStay(:) = {' '};

% FMRI sections
E.Run(E.Play_Sample>=  1 & E.Play_Sample<= 40) = 1;
E.Run(E.Play_Sample>= 41 & E.Play_Sample<= 80) = 2;
E.Run(E.Play_Sample>= 81 & E.Play_Sample<=120) = 3;
E.Run(E.Play_Sample>=121 & E.Play_Sample<=160) = 4;

% Drop non-response trials
keeps = E.NoResponse==0;
E.TrialType(~keeps) = {'NoResponse'};
origE = E;
E = E(keeps,:);


% Trial timing
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
%



%% Switch/stay
% The trial AFTER the win where they gave the switched response is the
% win-switch trial.
for h = 2:height(E)
	if strcmp(E.ChosenColor{h},E.ChosenColor{h-1})
		E.Switch{h} = 'Stay';
	else
		E.Switch{h} = 'Switch';
	end
end

for h = 2:height(E)
	if strcmp(E.Outcome{h-1},'Win') & strcmp(E.Switch{h},'Switch')
		E.WinSwitch{h} = 'WinSwitch';
		E.TrialType{h} = 'WinSwitch';
	end
	if strcmp(E.Outcome{h-1},'Win') & strcmp(E.Switch{h},'Stay')
		E.WinStay{h} = 'WinStay';
		E.TrialType{h} = 'WinStay';
	end
	if strcmp(E.Outcome{h-1},'Lose') & strcmp(E.Switch{h},'Switch')
		E.LoseSwitch{h} = 'LoseSwitch';
		E.TrialType{h} = 'LoseSwitch';
	end
	if strcmp(E.Outcome{h-1},'Lose') & strcmp(E.Switch{h},'Stay')
		E.LoseStay{h} = 'LoseStay';
		E.TrialType{h} = 'LoseStay';
	end
	
end

%% Compute summaries per run, ignoring non-response trials
summary = table();
for r = [1 2 3 4]
	inds = E.Run==r;
	
	summary.(['Run' num2str(r) '_AvgRT']) = ...
		mean(E.GameScreen_RT(inds));
	
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
		sum(strcmp(E.Outcome(inds),'Lose') & ...
		ismember(E.ChosenProb(inds),{'Deck80','Deck90'}));
	summary.(['Run' num2str(r) '_SubOptimalDeckLoss']) = ...
		sum(strcmp(E.Outcome(inds),'Lose') & ...
		ismember(E.ChosenProb(inds),{'Deck10','Deck20','Deck40','Deck50'}));
	
	% But for counting non-response trials we have to look at the original
	% full dataset
	summary.(['Run' num2str(r) '_NonResponses']) = ...
		sum(strcmp(origE.TrialType(origE.Run==r),'NoResponse'));
	
end

writetable(summary,'../OUTPUTS/summary.csv')


%% Restore non-response trials
E = [E; origE(~keeps,:)];
E = sortrows(E,'Trial');


% report
%
report = E(:,{'Run','Trial','Play_Sample','TrialType', ...
	'Switch', ...
	'WinSwitch','WinStay','LoseSwitch','LoseStay',...
	'ChosenColor', ...
	'WinningDeck','Outcome', ...
	'T1_TrialStart','T5_TrialEnd'})
writetable(report,'../OUTPUTS/report.csv')

% Use these labels, they're easier to understand
E(1:5,{
	'T1_TrialStart'
	'T2_Response'
	'T2b_CardFlipOnset'
	'T3_FeedbackOnset'
	'T4_FeedbackOffset'
	'T5_TrialEnd'
	'GameScreen_RT'
	})

% Regressor for T3_FeedbackOnset for the model (the feedback)
% Compare vs T2_Response in terms of predicted HRF




