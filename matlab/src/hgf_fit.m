function [result1,result2] = hgf_fit(eprime_report,out_dir)
% Fit the behavioral model to eprime trial data

% Load our eprime trials report
info = readtable(eprime_report);

% Split by "easy" and "hard" based on fmri run. We will assume the 10/50/90
% decks in inds1 and the 20/40/80 decks in inds2.
inds1 = ismember(info.Run,[1 2]);
inds2 = ismember(info.Run,[3 4]);

% Coding and fit for "easy". Default to NaN so fitModel will ignore
% responses or trials with missing info.
responses1 = nan(sum(inds1),1);
responses1(strcmp(info.ChosenProb(inds1),'Deck10')) = 1;
responses1(strcmp(info.ChosenProb(inds1),'Deck50')) = 2;
responses1(strcmp(info.ChosenProb(inds1),'Deck90')) = 3;

outcomes1 = nan(sum(inds1),1);
outcomes1(strcmp(info.Outcome(inds1),'Lose')) = 0;
outcomes1(strcmp(info.Outcome(inds1),'Win')) = 1;

result1 = tapas_fitModel( ...
	responses1, ...
	outcomes1, ...
	'tapas_hgf_ar1_binary_mab_config_custom(0,1)', ...
	'tapas_softmax_mu3_config' ...
	);

% Coding and fit for "hard". Replace mu_0(2) and mu_0(3) with previous
% half's est parameters
responses2 = nan(sum(inds2),1);
responses2(strcmp(info.ChosenProb(inds2),'Deck20')) = 1;
responses2(strcmp(info.ChosenProb(inds2),'Deck40')) = 2;
responses2(strcmp(info.ChosenProb(inds2),'Deck80')) = 3;

outcomes2 = nan(sum(inds2),1);
outcomes2(strcmp(info.Outcome(inds2),'Lose')) = 0;
outcomes2(strcmp(info.Outcome(inds2),'Win')) = 1;

result2 = tapas_fitModel( ...
	responses2, ...
	outcomes2, ...
	sprintf('tapas_hgf_ar1_binary_mab_config_custom(%0.8f,%0.8f)',result1.p_prc.mu_0(2),result1.p_prc.mu_0(3)), ...
	'tapas_softmax_mu3_config' ...
	);

% Save outputs in .mat format
save(fullfile(out_dir,'results.mat'),'result1','result2')

% Store outputs in the trial-by-trial report
info.traj_mu_31(inds1) = result1.traj.mu(:,3,1);
info.traj_mu_31(inds2) = result2.traj.mu(:,3,1);

% Save updated report
writetable(info,fullfile(out_dir,'trial_report.csv'));


% Generate plots? Which traj?

