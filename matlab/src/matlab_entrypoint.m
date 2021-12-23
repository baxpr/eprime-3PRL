function matlab_entrypoint(varargin)

% This function serves as the entrypoint to the matlab part of the
% pipeline. Its purpose is to parse the command line arguments, then call
% the main functions that actually do the work.

%% Just quit, if requested - needed for Singularity build
if numel(varargin)==1 && strcmp(varargin{1},'quit') && isdeployed
	disp('Exiting as requested')
	exit
end


%% Parse the inputs and parameters

P = inputParser;

% Eprime log converted from Eprime's .txt output file via
% ../../src/eprime_to_csv.py
addOptional(P,'eprime_csv','')

% We also want a DICOM from the fMRI - used only to compare timestamps.
addOptional(P,'fmri_dcm','')

% We also take a numerical parameter than can be used to override the
% errors generated when eprime timestamps don't match the fmri. Note that
% when arguments are passed to compiled Matlab via command line, they all
% come as strings; so we will need to convert this to a numeric format
% later.
addOptional(P,'timeoverride','0');

% When processing runs on XNAT, we generally have the project, subject,
% session, and scan labels from XNAT available in case we want them. Often
% the only need for these is to label the QA PDF.
addOptional(P,'label_info','UNKNOWN SCAN');

% Finally, we need to know where to store the outputs.
addOptional(P,'out_dir','/OUTPUTS');

% Parse
parse(P,varargin{:});

% Display the command line parameters - very helpful for running on XNAT,
% as this will show up in the outlog.
disp(P.Results)


%% Run the actual pipeline
[report_csv,summary_csv] = analyze_eprime( ...
	P.Results.eprime_csv, ...
	P.Results.fmri_dcm, ...
	P.Results.out_dir, ...
	P.Results.timeoverride ...
	);
hgf_fit(report_csv,P.Results.out_dir);


%% Exit
% But only if we're running the compiled executable.
if isdeployed
	exit
end

