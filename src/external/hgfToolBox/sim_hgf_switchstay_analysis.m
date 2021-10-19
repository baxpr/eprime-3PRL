function [sim_analysis] = sim_hgf_switchstay_analysis

% Load workspace of subjects' choices and outcomes.
load('/Users/erinjfeeney/Documents/MATLAB/hgfToolBox_v5.3.1/MTurk_Data_deleted_sim_incompatibles_no35no88no95no144no234no246no304no93no153no169.mat');

%  Data set has 'ans' in it.  Remove.
clearvars ans;

%  Get list of all variables in workspace.
test = whos;

%  Turn names into cell array.
for i = 1:size(test,1) 
    names{i,1} = test(i).name;
    sub_names{i,1} = names{i,1}(1,1:5);
end

% Number of simulation iterations
n=10;

%  Create list of all unique subject names.
unique_sub_names = unique(sub_names);

%  Create sim_analysisput cell array.

sim_analysis{1,1} = 'Subject Number';
sim_analysis{1,2} = 'Version';
sim_analysis{1,3} = 'Sim 1';
sim_analysis{1,4} = 'Sim 2';
sim_analysis{1,5} = 'Avg WinShift1'; 
sim_analysis{1,6} = 'Avg WinShift2';
sim_analysis{1,7} = 'Avg LoseStay1';
sim_analysis{1,8} = 'Avg LoseStay2';
sim_analysis{1,9} = 'UScore1 Per Sim';
sim_analysis{1,10} = 'UScore2 Per Sim';
sim_analysis{1,11} = 'Avg UScore1';
sim_analysis{1,12} = 'Avg UScore2';


% Load simulation output from sim_hgf_softmax_mu3.
load('/Users/erinjfeeney/Documents/MATLAB/hgfToolBox_v5.3.1/Data/MTurk_sims100_15April2019_no35no88no95no144no234no246no304no93no153no169.mat');


%  Loop through all subjects to make list of subject names.
for sub = 1:size(unique_sub_names,1)
    
    iswin1 = [];
    iswin2 = [];
    isloss1 = [];
    isloss2 = [];
    winswitch1 = [];
    winswitch2 = [];
    losestay1 = [];
    losestay2 = [];
    num_chose_1_sim1 = [];
    num_chose_2_sim1 = [];
    num_chose_3_sim1 = [];
    num_chose_1_sim2 = [];
    num_chose_2_sim2 = [];
    num_chose_3_sim2 = [];
    u_sim1 = [];
    u_sim2 =[];
    
    %  Current subject number is...
    current_sub = unique_sub_names{sub,1};
    
    %  Save in sim_analysiscome variable.
    sim_analysis{sub+1,1} = current_sub;
    
    %  Give me all variables corresponding to the current subject.
    sub_vars = find_in_cellstr(names,current_sub);
    
    %  Give us names of choices_1, choices_2, outcomes_1, and outcomes_2
    %  variables for this subject.
    current_choices_1_name = find_in_cellstr(sub_vars,'choices_1');
    current_choices_2_name = find_in_cellstr(sub_vars,'choices_2');
    current_outcomes_1_name = find_in_cellstr(sub_vars,'outcomes_1');
    current_outcomes_2_name = find_in_cellstr(sub_vars,'outcomes_2');
    
    %current sim
    current_sim_1=sims{sub+1,3};
    current_sim_2=sims{sub+1,4};
    
    % current outcomes
    current_outcomes_1 = eval(current_outcomes_1_name{1,1});
    current_outcomes_2 = eval(current_outcomes_2_name{1,1});
    
  % Simulation iterations
  for col=1:n
      
      for row = 1:size(current_sim_1,1) 
          
          iswin1(row,col) = current_outcomes_1(row,1) == 1; 
          isloss1(row,col) = current_outcomes_1(row,1) == 0; 
          
          if iswin1(row,col) == 1
              
              if row < 80 
                  
                  if current_sim_1(row,col) ~= current_sim_1(row+1,col); 
                      
                      winswitch1(row,col) = 1;
                      
                  end
              end
                
           end
              
          
          if isloss1(row,col) == 1
              
            if row < 80 
                  
                  if current_sim_1(row,col) == current_sim_1(row+1,col); 
                      
                      losestay1(row,col) = 1;
                      
                  end
                  
                 end
              
                end
          
         iswin2(row,col) = current_outcomes_2(row,1) == 1;
         isloss2(row,col) = current_outcomes_2(row,1) == 0;
          
         if iswin2(row,col) == 1
              
          if row < 80 %was if row>1
                  
                  if current_sim_2(row,col) ~= current_sim_2(row + 1,col);
                      
                      winswitch2(row,col) = 1;
                      
                  end
                  
              end
  end  
          
          if isloss2(row,col) == 1
              
            if row < 80 %was if row>1
                  
                  if current_sim_2(row,col) == current_sim_2(row + 1,col);
                      
                      losestay2(row,col) = 1;
                      
                  end
                  
              end
              
          end
end    
      
      %    New matrix, rows are different subjects, columns are different simulations
     
      ws1_mean_per_col(col) = sum(winswitch1(:,col))/sum(iswin1(:,col));
     
      ws2_mean_per_col(col) = sum(winswitch2(:,col))/sum(iswin2(:,col));
      
      ls1_mean_per_col(col) = sum(losestay1(:,col))/sum(isloss1(:,col));
      ls2_mean_per_col(col) = sum(losestay2(:,col))/sum(isloss2(:,col));
      
%     For each row being a subject, produce proportion win/switches and
%       lose/stays per half of experiment for each iteration (column).
      sim_analysis{sub+1,3} = current_sim_1;
      sim_analysis{sub+1,4} = current_sim_2;       
      
      % U Score =(-(COUNTIF(C3:C82, 1)/80)*LOG((COUNTIF(C3:C82, 1)/80))/LOG(3))+(-(COUNTIF(C3:C82, 2)/80)*LOG((COUNTIF(C3:C82, 2)/80))/LOG(3))+(-(COUNTIF(C3:C82, 3)/80)*LOG((COUNTIF(C3:C82, 3)/80))/LOG(3))
      
      num_chose_1_sim1(col) = sum(current_sim_1(:,col)==1);
      num_chose_2_sim1(col) = sum(current_sim_1(:,col)==2);
      num_chose_3_sim1(col) = sum(current_sim_1(:,col)==3);
      
      num_trials_sim1 = size(current_sim_1,1);
      
      num_options = 3;
      
      u_sim1(col) = -(num_chose_1_sim1(col)./num_trials_sim1).*(log(num_chose_1_sim1(col)./num_trials_sim1)./log(num_options)) - (num_chose_2_sim1(col)./num_trials_sim1).*(log(num_chose_2_sim1(col)./num_trials_sim1)./log(num_options)) - (num_chose_3_sim1(col)./num_trials_sim1).*(log(num_chose_3_sim1(col)./num_trials_sim1)./log(num_options)); 
      
      
      num_chose_1_sim2(col) = sum(current_sim_2(:,col)==1);
      num_chose_2_sim2(col) = sum(current_sim_2(:,col)==2);
      num_chose_3_sim2(col) = sum(current_sim_2(:,col)==3);
      
      num_trials_sim2 = size(current_sim_2,1);
      
      num_options = 3;
      
      u_sim2 = -(num_chose_1_sim2./num_trials_sim2).*(log(num_chose_1_sim2./num_trials_sim2)./log(num_options)) - (num_chose_2_sim2./num_trials_sim2).*(log(num_chose_2_sim2./num_trials_sim2)./log(num_options)) - (num_chose_3_sim2./num_trials_sim2).*(log(num_chose_3_sim2./num_trials_sim2)./log(num_options)); 
      
      
      % U-score, 1st half:
      sim_analysis{sub+1,9} = u_sim1;
    
%      % U-score, 2nd half:
      sim_analysis{sub+1,10} = u_sim2;
      

      end
    mean_ws1(sub) = mean(ws1_mean_per_col)
    mean_ws2(sub) = mean(ws2_mean_per_col)
    mean_ls1(sub) = mean(ls1_mean_per_col)
    mean_ls2(sub) = mean(ls2_mean_per_col)
    mean_u1(sub) = mean(u_sim1)
    mean_u2(sub) = mean(u_sim2)
    
    sim_analysis{sub+1,5} = mean_ws1(sub)
    sim_analysis{sub+1,6} = mean_ws2(sub)
    sim_analysis{sub+1,7} = mean_ls1(sub)
    sim_analysis{sub+1,8} = mean_ls2(sub)
    
    sim_analysis{sub+1,11} = mean_u1(sub)
    sim_analysis{sub+1,12} = mean_u2(sub)
    
  end
 
    
    
      
    
    
end

