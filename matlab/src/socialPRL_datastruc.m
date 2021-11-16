% Create data structure composed socialPRL data

% looping through excel and creating data structure
nsubj = 1;
for ii = 1:nsubj
    % load data attributes
    [status,sheet] = xlsfinfo('subject-data.xlsx');
    [num,txt,raw] = xlsread('subject-data.xlsx',ii);
    z = strcat(sheet{ii},'_V3_',strtrim(txt));
    PRL.(z{1,1}) = num(:,1);
    PRL.(z{1,3}) = num(:,3);
    PRL.(z{1,2}) = num(:,2);
    PRL.(z{1,4}) = num(:,4);
end

% run data structure
PRL

% saving data
save('PRL.mat', '-struct', 'PRL')


