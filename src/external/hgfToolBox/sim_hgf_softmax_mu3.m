% Simulation function
% Updated annotations 10-November-2019

function [sims] = sim_hgf_softmax_mu3

% Load data set of subject choices and outcomes
load('C:/Users/ps967/Desktop/hgfToolBox_v5.3.1 copy 11Nov2019/socialPRL.mat');

%  Data set has 'ans' in it.  Remove.
clearvars ans;

%  Get list of all variables in workspace.
test = whos;

%  Turn names into cell array.
for i = 1:size(test,1) 
    names{i,1} = test(i).name;
    sub_names{i,1} = names{i,1}(1,1:5);
end

% Number of iterations
n=10;

%  Create list of all unique subject names.
unique_sub_names = unique(sub_names);

%  Create output cell array.

sims{1,1} = 'Subject Number';
sims{1,2} = 'Test1';
sims{1,3} = 'simulations1'; %structure with iterations of simulations for first half of data
sims{1,4} = 'simulations2'; %structure with iterations of simulations for second half of data


% Load output array from hgf_softmax_mu3 parameter estimation
load('C:/Users/ps967/Desktop/hgfToolBox_v5.3.1 copy 11Nov2019/Test_Est.mat');


%  Loop through all subjects to make list of subject names.
    for sub = 1:size(unique_sub_names,1)
    
     %  Current subject number is...
        current_sub = unique_sub_names{sub,1};
    
     %  Save in outcome variable.
     sims{sub+1,1} = current_sub;
    
     %  Give me all variables corresponding to the current subject.
     sub_vars = find_in_cellstr(names,current_sub);
    
     %  Give us names of choices_1, choices_2, outcomes_1, and outcomes_2
     %  variables for this subject.
     current_choices_1_name = find_in_cellstr(sub_vars,'choices_1');
     current_choices_2_name = find_in_cellstr(sub_vars,'choices_2');
     current_outcomes_1_name = find_in_cellstr(sub_vars,'outcomes_1');
     current_outcomes_2_name = find_in_cellstr(sub_vars,'outcomes_2');
    
    %current est
    %current_est_1=test_old{sub+1,3};
    %current_est_2=test_old{sub+1,4};
    
    current_est_1=Est{sub+1,3};
    current_est_2=Est{sub+1,4};
    
    % current outcomes
    current_outcomes_1 = eval(current_outcomes_1_name{1,1});
    current_outcomes_2 = eval(current_outcomes_2_name{1,1});
    
  % Simulation iterations
    for col=1:n
      
      sim1 = tapas_simModel([eval(current_outcomes_1_name{1,1}),eval(current_choices_1_name{1,1})], 'tapas_hgf_ar1_binary_mab', current_est_1.p_prc.p, 'tapas_softmax_mu3', []);
      sim2 = tapas_simModel([eval(current_outcomes_2_name{1,1}),eval(current_choices_2_name{1,1})], 'tapas_hgf_ar1_binary_mab', current_est_2.p_prc.p, 'tapas_softmax_mu3', []);

      % Each simulation iteration adds a new column     
      current_sim1(:,col) = sim1.y;
      current_sim2(:,col) = sim2.y;
      
     
  % Report simulation matrices for each half
      sims{sub+1,3} = current_sim1;
      sims{sub+1,4} = current_sim2;       
     
  
     end  
    
     end 
      
    
end

