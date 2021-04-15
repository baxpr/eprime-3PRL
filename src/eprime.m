% Load edat
E = readtable('eprime.csv');

% MainTask trials only
E = E(strcmp(E.Procedure_Block_,'MainTask'),:);

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

% Rule change
E.RuleChange;


%% Trial categories, https://www.jneurosci.org/content/22/11/4563

% (1) correct responses, co-occurring with positive feedback, as a
% baseline.
%   ChosenColor == Deck_Win
%   Outcome == 'Win'
E.CorrectResponse = 1 * (strcmp(E.ChosenColor,E.Deck_Win) & strcmp(E.Outcome,'Win'));

% (2) probabilistic errors, on which negative feedback was given to correct
% responses
%   ChosenColor == Deck_Win
%   E.Outcome == 'Lose'
E.ProbabilisticError = 1 * (strcmp(E.ChosenColor,E.Deck_Win) & strcmp(E.Outcome,'Lose'));

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
errorflag = false;
for h = 2:height(E)
	E.FinalReversalError(h) = 0;
	if strcmp(E.Outcome{h},'Lose') & E.RuleChange(h-1)==1
		E.ReversalError(h) = 1;
		errorflag = true;
	elseif strcmp(E.Outcome{h},'Lose') & errorflag
		E.ReversalError(h) = 1;
	elseif strcmp(E.Outcome{h},'Win') & errorflag
		E.FinalReversalError(h-1) = 1;
		errorflag = false;
	end
end

% (5) A "win" is still a reversal error if it was an error v.v. the correct
% deck, even if it was a probabilistic "win". Until both choice and windeck
% match AND it's a win, we should count trial as a reversal error.

% Have a column for missed response "?"

% Don't include the ? when looking forward to identify final reversal
% errors? We have an example of this


E.NoResponse = 1 * cellfun(@isempty,E.ChosenColor);

E.SomethingElse = 1 - (E.NoResponse | E.CorrectResponse | E.ProbabilisticError | E.ReversalError);

E(:,{'RuleChange','ChosenColor','Deck_Win','Outcome','NoResponse','CorrectResponse', ...
	'ProbabilisticError','ReversalError','FinalReversalError','SomethingElse'})


E(1:5,{
	'GameScreen_OnsetTime'
	'Slide0_OnsetTime'
	'T2b_CardFlipOnset'
	'ShowResult_OnsetTime'
	'Fixation1_OnsetTime'
	'T5_TrialEnd'
	})

% Use these labels, they're easier to understand
E(1:5,{'T1_TrialStart'
	'T2_Response'
	'T2b_CardFlipOnset'
	'T3_FeedbackOnset'
	'T4_FeedbackOffset'
	'T5_TrialEnd'
	'GameScreen_RT'
	})

% Regressor for T3_FeedbackOnset for the model (the feedback)
% Compare vs T2_Response in terms of predicted HRF




