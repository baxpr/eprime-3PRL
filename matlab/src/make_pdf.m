function make_pdf(trial_csv,summary_csv,out_dir)

trial = readtable(trial_csv);
summary = readtable(summary_csv);

% Figure out screen size so the figure will fit
ss = get(0,'screensize');
ssw = ss(3);
ssh = ss(4);
ratio = 8.5/11;
if ssw/ssh >= ratio
	dh = ssh;
	dw = ssh * ratio;
else
	dw = ssw;
	dh = ssw / ratio;
end

% Create figure
pdf_figure = openfig('report.fig','new');
set(pdf_figure,'Tag','hgf_report');
set(pdf_figure,'Units','pixels','Position',[0 0 dw dh]);
figH = guihandles(pdf_figure);

% Parameter estimates
pstr = sprintf( ...
	[ ...
	'run12_mu_0_2:  %8.4f     run34_mu_0_2:  %8.4f\n' ...
	'run12_mu_0_3:  %8.4f     run34_mu_0_3:  %8.4f\n' ...
	'run12_kappa_2: %8.4f     run34_kappa_2: %8.4f\n' ...
	'run12_omega_2: %8.4f     run34_omega_2: %8.4f\n' ...
	'run12_omega_3: %8.4f     run34_omega_3: %8.4f\n' ...
	], ...
	summary.run12_mu_0_2, summary.run34_mu_0_2, ...
	summary.run12_mu_0_3, summary.run34_mu_0_3, ...
	summary.run12_kappa_2, summary.run34_kappa_2, ...
	summary.run12_omega_2, summary.run34_omega_2, ...
	summary.run12_omega_3, summary.run34_omega_3 ...
	);
disp(pstr)
set(figH.params_text, 'String', pstr)

% Trajectory plots
axes(figH.ax1)
plot(trial.traj_mu_31)
ylabel('mu(3,1)')
title('Trajectories')
set(gca,'XTick',[])

axes(figH.ax2)
plot([trial.traj_epsi_2 trial.traj_epsi_3])
xlabel('Trial')
ylabel('epsilon')
legend({'epsilon(2)','epsilon(3)'})


% Print to PNG
print(gcf,'-dpng','-r300',fullfile(out_dir,'report.png'))
close(gcf);

