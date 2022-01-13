function [result12,result34] = hgf_fit(eprime_report,eprime_summary,out_dir)
% Fit the behavioral model to eprime trial data

% Load our eprime trials report
info = readtable(eprime_report);

% Load summary data
summary = readtable(eprime_summary);

% Split by "easy" and "hard" based on fmri run. We will assume the 10/50/90
% decks in inds1 and the 20/40/80 decks in inds2.
inds12 = ismember(info.Run,[1 2]);
inds34 = ismember(info.Run,[3 4]);

% Coding and fit for "easy". Default to NaN so fitModel will ignore
% responses or trials with missing info.
responses1 = nan(sum(inds12),1);
responses1(strcmp(info.ChosenProb(inds12),'Deck10')) = 1;
responses1(strcmp(info.ChosenProb(inds12),'Deck50')) = 2;
responses1(strcmp(info.ChosenProb(inds12),'Deck90')) = 3;

outcomes1 = nan(sum(inds12),1);
outcomes1(strcmp(info.Outcome(inds12),'Lose')) = 0;
outcomes1(strcmp(info.Outcome(inds12),'Win')) = 1;

result12 = tapas_fitModel( ...
	responses1, ...
	outcomes1, ...
	'tapas_hgf_ar1_binary_mab_config_custom(0,1)', ...
	'tapas_softmax_mu3_config' ...
	);

% Coding and fit for "hard". Replace mu_0(2) and mu_0(3) with previous
% half's est parameters
responses2 = nan(sum(inds34),1);
responses2(strcmp(info.ChosenProb(inds34),'Deck20')) = 1;
responses2(strcmp(info.ChosenProb(inds34),'Deck40')) = 2;
responses2(strcmp(info.ChosenProb(inds34),'Deck80')) = 3;

outcomes2 = nan(sum(inds34),1);
outcomes2(strcmp(info.Outcome(inds34),'Lose')) = 0;
outcomes2(strcmp(info.Outcome(inds34),'Win')) = 1;

result34 = tapas_fitModel( ...
	responses2, ...
	outcomes2, ...
	sprintf('tapas_hgf_ar1_binary_mab_config_custom(%0.8f,%0.8f)',result12.p_prc.mu_0(2),result12.p_prc.mu_0(3)), ...
	'tapas_softmax_mu3_config' ...
	);

% Save complete outputs in .mat format
save(fullfile(out_dir,'results.mat'),'result12','result34')

% Store parameter estimates in the summary report
summary.run12_mu_0_2 = result12.p_prc.mu_0(2);
summary.run12_mu_0_3 = result12.p_prc.mu_0(3);
summary.run12_kappa_2 = result12.p_prc.ka(2);
summary.run12_omega_2 = result12.p_prc.om(2);
summary.run12_omega_3 = result12.p_prc.om(3);

summary.run34_mu_0_2 = result34.p_prc.mu_0(2);
summary.run34_mu_0_3 = result34.p_prc.mu_0(3);
summary.run34_kappa_2 = result34.p_prc.ka(2);
summary.run34_omega_2 = result34.p_prc.om(2);
summary.run34_omega_3 = result34.p_prc.om(3);

% Store model trajectory outputs in the trial-by-trial report
for var = {'mu','sa','muhat','sahat','ud'}
	for i1 = 1:3
		for i2 = 1:3
			varname = ['traj_' var{1} '_' num2str(i1) num2str(i2)];
			info.(varname)(inds12) = result12.traj.(var{1})(:,i1,i2);
			info.(varname)(inds34) = result34.traj.(var{1})(:,i1,i2);
		end
	end
end
for var = {'v','da','psi','epsi','wt'}
	for i1 = 1:3
		varname = ['traj_' var{1} '_' num2str(i1)];
		info.(varname)(inds12) = result12.traj.(var{1})(:,i1);
		info.(varname)(inds34) = result34.traj.(var{1})(:,i1);
	end
end
for var = {'w'}
	for i1 = 1:2
		varname = ['traj_' var{1} '_' num2str(i1)];
		info.(varname)(inds12) = result12.traj.(var{1})(:,i1);
		info.(varname)(inds34) = result34.traj.(var{1})(:,i1);
	end
end


%% Save updated reports
writetable(info,fullfile(out_dir,'trial_report.csv'));
writetable(summary,fullfile(out_dir,'full_summary.csv'));


% Generate plots? Which traj?

