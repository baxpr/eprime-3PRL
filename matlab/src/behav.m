eprime_csv = '../INPUTS_behav/eprime_test.csv';

% Read eprime .csv after conversion from original .txt with
% eprime_to_csv.py
eprime = readtable(eprime_csv);

% "choices" = ??
% "outcome" = 0 (lose) or 1 (win)

% hgf_softmax_mu3 is the main analysis code
% its input comes from socialPRL_datastruc.m
% which just renames subject-data.xlsx
% which comes from cols G-J of HGF_Input sheet of ???_template.xlsx
% which comes from
%    input_vector column D of ???_template.xlsx
%       where did that come from? Entered by hand based on Raw Data N, 
%       left = 1 / middle = 2 / right = 3 ?
%    and Raw Data P.
%
% Raw Data N = left/middle/right ChosenColor
% Raw Data P = win (1) / lose (0)

% Looks like our "input" / "choices" is probably a categorical coding of
% the ChosenProb field in the eprime data.
