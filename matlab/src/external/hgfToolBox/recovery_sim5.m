
% Parameter Recovery 
% Erin Reed, updated 3-Nov-2019 

% This function performs parameter estimation from simulated choices 
% and the corresponding actual outcome data for each subject. 

% The workspace 'Test_Sims.mat' contains the cell array 'Sims'. 
% Each row corresponds to a subject. The 3rd column contains matrices
% with the simulated choice data of each subject (first half of the task). 
% There are 10 simulations of 80 trials each per subject (i.e., 80 rows and 10 columns
% in each subject's matrix)

% The function is designed to estimate parameters from one of the 10 simulations.
% To select a given simulation, I adjust line 89 (i.e., I designate the
% column number in the simulation matrix). For this paricular script, the 
% fifth simulation is analyzed. I also include variables for the second
% half of the task (e.g., sim 2, current_simchoices_2,current_outcomes_2), 
% but I've been ignoring these and focusing exclusively on the first half. 

% The output of this function is included in the zip folder as the
% workspace 'Sim5_RecoveredParameters.mat'

% This function utilizes a 'find_in_cellstr.m' script written by
% Al Powers, which is included in zip folder. 
% The simulated data ('Test_Sims.mat') and actual data ('Test_Data.mat')
% will also need to be added to the path.

% To run the script, just enter the command 'recovery_sim5'


function [param_recovery] = recovery_sim5

% Load data set 'Test_Data.mat'. 
load('/Users/erinjfeeney/Documents/MATLAB/hgfToolBox_v5.3.1 copy 11Nov2019/Test_Data.mat');

%  Data set has 'ans' in it.  Remove.
clearvars ans;

%  Get list of all variables in workspace.
test = whos;

%  Turn names into cell array.
for i = 1:size(test,1) 
    names{i,1} = test(i).name;
    sub_names{i,1} = names{i,1}(1,1:5);
end
%  Create list of all unique subject names.
unique_sub_names = unique(sub_names);

%  Create param_recovery oput cell array.

param_recovery{1,1} = 'Subject Number';
param_recovery{1,2} = 'Version';
param_recovery{1,3} = 'Sim 1';
param_recovery{1,4} = 'Sim 2';
param_recovery{1,5} = 'Est1e'; 
param_recovery{1,6} = 'mu02_1e';
param_recovery{1,7} = 'mu03_1e';
param_recovery{1,8} = 'kappa_1e';
param_recovery{1,9} = 'omega2_1e';
param_recovery{1,10} = 'omega3_1e';



% Load simulation output from sim_hgf_softmax_mu3.
load('/Users/erinjfeeney/Documents/MATLAB/hgfToolBox_v5.3.1 copy 11Nov2019/Test_Sims.mat');

%  Loop through all subjects to make list of subject names.
for sub = 1:size(unique_sub_names,1)
    
    %  Current subject number is...
    current_sub = unique_sub_names{sub,1};
    
    %  Save in param_recoverycome variable.
    param_recovery{sub+1,1} = current_sub;
    
    %  Give me all variables corresponding to the current subject.
    sub_vars = find_in_cellstr(names,current_sub);
    
    %  Give us names of choices_1, choices_2, outcomes_1, and outcomes_2
    %  variables for this subject.
    current_sim_row = find(strcmp(current_sub, Sims));
    current_outcomes_1_name = find_in_cellstr(sub_vars,'outcomes_1');
    current_outcomes_2_name = find_in_cellstr(sub_vars,'outcomes_2');
    
    % current outcomes
    current_outcomes_1 = eval(current_outcomes_1_name{1,1});
    current_outcomes_2 = eval(current_outcomes_2_name{1,1});
    
    % current simulated choices - select column 5 of simulated data for
    % the fifth simulation. I change the column number to perform parameter
    % estimation on the simulation of interest (1-10)
    current_simchoices_1 = Sims{current_sim_row,3}(:,5);
    current_simchoices_2 = Sims{current_sim_row,4}(:,5);
    
    % current sim
    current_sim1 = Sims{current_sim_row,3};
    current_sim2 = Sims{current_sim_row,4};
    
    % current_est_recovered1
    current_est_recovered1 = tapas_fitModel(current_simchoices_1, eval(current_outcomes_1_name{1,1}), 'tapas_hgf_ar1_binary_mab_config_1', 'tapas_softmax_mu3_config');
  
    
    %  Save as est_1 in outcome variable.
    param_recovery{sub+1,5} = current_est_recovered1;
   
    
    %  Assign values to out variable.
     
    % Sim1
    param_recovery{sub+1,3} = current_sim1;
    
    % Sim2
    param_recovery{sub+1,4} = current_sim2;
    
    % Mu at 2nd level:
    param_recovery{sub+1,6} = current_est_recovered1.p_prc.mu_0(2);
    mu02 = current_est_recovered1.p_prc.mu_0(2);
    
    % Mu at 3rd level:
    param_recovery{sub+1,7} = current_est_recovered1.p_prc.mu_0(3);
    mu03 = current_est_recovered1.p_prc.mu_0(3);
    
    % Kappa at 2nd level:
    param_recovery{sub+1,8} = current_est_recovered1.p_prc.ka(2);
    
    % Omega at 2nd level:
    param_recovery{sub+1,9} = current_est_recovered1.p_prc.om(2);
    
    % Omega at 3rd level:
    param_recovery{sub+1,10} = current_est_recovered1.p_prc.om(3);
    
  
   end
    
   