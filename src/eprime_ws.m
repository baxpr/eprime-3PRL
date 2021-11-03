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

% Drop non-response trials
keeps = E.NoResponse==0;
E.TrialType(~keeps) = {'NoResponse'};

origE = E;
E = E(keeps,:);


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


% Restore non-response trials
E = [E; origE(~keeps,:)];
E = sortrows(E,'Trial');

% FMRI sections
E.Run(E.Play_Sample>=  1 & E.Play_Sample<= 40) = 1;
E.Run(E.Play_Sample>= 41 & E.Play_Sample<= 80) = 2;
E.Run(E.Play_Sample>= 81 & E.Play_Sample<=120) = 3;
E.Run(E.Play_Sample>=121 & E.Play_Sample<=160) = 4;


% report
% 	
report = E(:,{'Run','Trial','Play_Sample','TrialType', ...
	'Switch', ...
	'WinSwitch','WinStay','LoseSwitch','LoseStay',...
	'ChosenColor', ...
	'WinningDeck','Outcome', ...
	'T1_TrialStart','T5_TrialEnd'})
writetable(report,'../OUTPUTS/report.csv')


E(1:5,{
	'GameScreen_OnsetTime'
	'Slide0_OnsetTime'
	'T2b_CardFlipOnset'
	'ShowResult_OnsetTime'
	'Fixation1_OnsetTime'
	'T5_TrialEnd'
	})

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




