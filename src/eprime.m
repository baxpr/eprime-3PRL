% Load edat
%E = readtable('../INPUTS/eprime.csv');
E = readtable(eprime_csv);

% MainTask trials only
%E = E(strcmp(E.Procedure_Block_,'MainTask'),:);
E = E(strcmp(E.Procedure,'Bet'),:);

% Sort by Fixation1_OnsetTime
[~,ind] = sort(E.Fixation1_OnsetTime);
E = E(ind,:);

% Outcome (Win/Lose)
E.Outcome;

% Fixation
E.Fixation1_OnsetTime; E.Fixation1_OffsetTime;

% Cue
E.GameScreen_OnsetTime; E.GameScreen_OffsetTime;

% RT
E.GameScreen_RT;

% Show result (looks like consistent 900 ms)
E.ShowResult_OnsetTime; E.ShowResult_OffsetTime;

% Rule change after this trial
E.RuleChange;



%% Trial categories, https://www.jneurosci.org/content/22/11/4563

% The following contrasts were assessed: (1) final reversal errors minus
% correct responses, (2) other preceding reversal errors minus correct
% responses, (3) probabilistic errors minus correct responses, (4) final
% reversal errors minus other preceding reversal errors, and (5) final
% reversal errors minus probabilistic errors.

% (1) correct responses, co-occurring with positive feedback, as a
% baseline.
%   ChosenColor == Deck_Win
%   Outcome == 'Win'
E.CorrectResponse = 1 * (strcmp(E.ChosenColor,E.WinningDeck) & strcmp(E.Outcome,'Win'));

% (2) probabilistic errors, on which negative feedback was given to correct
% responses
%   ChosenColor == Deck_Win
%   E.Outcome == 'Lose'
E.ProbabilisticError = 1 * ...
	(strcmp(E.ChosenColor,E.Deck_Win) & strcmp(E.Outcome,'Lose'));

% Trials on which subjects reversed after a probabilistic error were not
% included in the model - Don't understand this yet

% (3) Final reversal errors, resulting in the subject shifting their
% responding. A first reversal error is
%   Outcome == 'Lose'
%   RuleChange(prev) == 1
% A later reversal error is
%   Outcome == 'Lose'
%   Previous trial is a first or later reversal error
% A final reversal error is
%   A reversal error
%   Outcome(next) == 'Win'
%
% (4) the other preceding reversal errors, following a contingency reversal
% but preceding the final reversal errors.
%errorflag = false;
%for h = 2:height(E)
%	E.FinalReversalError(h) = 0;
%	if strcmp(E.Outcome{h},'Lose') & E.RuleChange(h-1)==1
%		E.ReversalError(h) = 1;
%		errorflag = true;
%	elseif strcmp(E.Outcome{h},'Lose') & errorflag
%		E.ReversalError(h) = 1;
%	elseif strcmp(E.Outcome{h},'Win') & errorflag
%		E.FinalReversalError(h-1) = 1;
%		errorflag = false;
%	end
%end

% Better definition of reversal error: choice matches previous windeck, but
% windeck has changed. (But what if choice was for some reason not the
% previous windeck?)
%
% First reversal error: Previous was rulechange, choice was previous
% windeck, choice doesn't match windeck
%
% Rest of reversal errors: previous was reversal error, choice doesn't
% match windeck.
%
% First correct trial post reversal: Choice matches windeck (but what if
% the outcome is a probabilistic "lose"?)


% Initialize
E.Trial = (1:height(E))';
E.RuleKnowledge(:) = {' '};
E.TrialType(:) = {' '};
E.NoResponse = 1 * cellfun(@isempty,E.ChosenColor);
E.Switch(:) = {' '};
E.WinSwitch(:) = {' '};
E.WinStay(:) = {' '};
E.PreviousWinningDeck(:) = {' '};

% How many rule changes?
E.TotalRuleChanges = cumsum(E.RuleChange);


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
	end
	if strcmp(E.Outcome{h-1},'Win') & strcmp(E.Switch{h},'Stay')
		E.WinStay{h} = 'WinStay';
	end
end	


%% Update, 5 May

% Need to find the previous section's windeck, not the previous trial's
% windeck, to correctly find final reversal errors
for h = 2:height(E)
	if E.RuleChange(h-1)==1
		E.PreviousWinningDeck{h} = E.WinningDeck{h-1};
	else
		E.PreviousWinningDeck{h} = E.PreviousWinningDeck{h-1};
	end
end

% Correct trials where they guess the correct deck and win, regardless of
% context.
E.TrialType(E.CorrectResponse==1) = {'CorrectWinBaseline'};

% Final reversal error is previous correct deck, followed by new correct
% deck on the following two trials, regardless of the win/loss report.
for h = 2:(height(E)-2)
	if E.TotalRuleChanges(h)>0 & ...
		strcmp(E.ChosenColor{h},E.PreviousWinningDeck{h}) & ...
			strcmp(E.ChosenColor{h+1},E.WinningDeck{h+1}) & ...
			strcmp(E.ChosenColor{h+2},E.WinningDeck{h+2})
		E.TrialType{h} = 'FinalReversalError';
	end
end


% Deliberation trials for the rest.


% % Rule discovered:
% %    Chosen different from previous chosen
% %    Chosen equals windeck
% %    Outcome is Win
% %
% % Rule kept:
% %    Previous is rule discovered or rule kept
% %    Chosen equals windeck
% %
% % Rule lost:
% %    Previous is rule discovered or rule kept
% %    Chosen is not windeck
% %
% % Our desired baseline trials correspond to 'Discovered' or 'Kept', but
% % with probabilistic 'Lose' errors excluded
% %
% % Our reversal errors are 'LostAfterRuleChange' and following 'Unknown'
% E.RuleKnowledge{1,1} = 'Unknown';
% for h = 2:height(E)
% 	if ~strcmp(E.ChosenColor{h},E.ChosenColor{h-1}) & ...
% 			strcmp(E.ChosenColor{h},E.WinningDeck{h}) & ...
% 			strcmp(E.Outcome{h},'Win')
% 		E.RuleKnowledge{h,1} = 'Discovered';
% 	elseif ismember(E.RuleKnowledge{h-1},{'Discovered','Kept'}) & ...
% 			strcmp(E.ChosenColor{h},E.WinningDeck{h})
% 		if strcmp(E.Outcome{h},'Win')
% 			E.RuleKnowledge{h,1} = 'Kept';
% 		elseif strcmp(E.Outcome{h},'Lose')
% 			E.RuleKnowledge{h,1} = 'KeptProbError';
% 		end
% 	elseif ismember(E.RuleKnowledge{h-1},{'Discovered','Kept','KeptProbError'}) & ...
% 			~strcmp(E.ChosenColor{h},E.WinningDeck{h})
% 		if E.RuleChange(h-1)==1
% 			E.RuleKnowledge{h,1} = 'LostAfterRuleChange';
% 		else
% 			E.RuleKnowledge{h,1} = 'Lost';
% 		end
% 	elseif E.NoResponse(h)==0
% 		E.RuleKnowledge{h,1} = 'Unknown';
% 	end
% 	
% end
% 
% %% Trial types for analysis
% 
% % (1) correct responses, co-occurring with positive feedback, as a
% % baseline.
% E.TrialType(ismember(E.RuleKnowledge,{'Discovered','Kept'})) = {'CorrectWinBaseline'};
% 
% % (2) probabilistic errors, on which negative feedback was given to correct
% % responses
% ind = find(E.ProbabilisticError==1);
% if ~all(strcmp(E.TrialType(ind),' '))
% 	error('ProbabilisticError overlap')
% end
% E.TrialType(ind) = {'ProbabilisticError'};
% 
% % (3) Final reversal errors, resulting in the subject shifting their
% % responding.
% ind = find(strcmp(E.RuleKnowledge,'Discovered')) - 1;
% if ~all(strcmp(E.TrialType(ind),' '))
% 	error('FinalReversalError overlap')
% end
% E.TrialType(ind) = {'FinalReversalError'};
% 
% % (4) the other preceding reversal errors, following a contingency reversal
% % but preceding the final reversal errors.
% windowflag = 0;
% for h = 1:height(E)
% 	if strcmp(E.RuleKnowledge{h},'Discovered')
% 		windowflag = 0;
% 	end
% 	if windowflag==1 & strcmp(E.TrialType{h},' ')
% 		E.TrialType{h} = 'ReversalError';
% 	end
% 	if strcmp(E.RuleKnowledge{h},'LostAfterRuleChange')
% 		windowflag = 1;
% 		if strcmp(E.TrialType{h},' ')
% 			E.TrialType{h} = 'ReversalError';
% 		end
% 	end
% end
% 
% 
% % All possible outcomes for the first trial after a reversal:
% %    1. Choice matches previous windeck, outcome is Lose
% %    2. Choice matches previous windeck, outcome is probabilistic Win
% %    3. Choice matches new windeck, outcome is Win
% %    4. Choice matches new windeck, outcome is probabilistic Lose
% %    5. Choice is anything else, outcome is Lose
% %    6. Choice is anything else, outcome is probabilistic Win
% 
% 
% % (5) A "win" is still a reversal error if it was an error v.v. the correct
% % deck, even if it was a probabilistic "win". Until both choice and windeck
% % match AND it's a win, we should count trial as a reversal error.
% 
% % Have a column for missed response "?"
% 
% % Don't include the ? when looking forward to identify final reversal
% % errors? We have an example of this
% 
% %E.SomethingElse = 1 - (E.NoResponse | E.CorrectResponse | E.ProbabilisticError | E.ReversalError);


% Restore non-response trials
E = [E; origE(~keeps,:)];
E = sortrows(E,'Trial');

report = E(:,{'Trial','TrialType', ...
	'RuleChange','TotalRuleChanges','Switch','WinSwitch','WinStay','ChosenColor', ...
	'WinningDeck','Outcome','PreviousWinningDeck','RuleKnowledge', ...
	'T1_TrialStart','T5_TrialEnd', ...
	'CorrectResponse','ProbabilisticError'})
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




