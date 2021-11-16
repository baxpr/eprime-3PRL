function [ out ] = find_in_cellstr(cellstr_array, expression, varargin)

% Find string (expression) in a cell array of strings (cellstr_array). Two
% flags may also be included.  The first corresponds to returning a logical
% array of those items you're searching for within the original cell array.
% The second corresponds to whether or not you wish to find an exact match.

% Developed by Al Powers, 2012

if size(varargin,2)>0  % Flag for returning just the indices corresponding to the searched-for string.
    out = ~cellfun('isempty', cellfun(@(x) x==1, regexp(cellstr_array, expression), 'UniformOutput', false));
else
    out = cellstr_array(~cellfun('isempty', cellfun(@(x) x==1, regexp(cellstr_array, expression), 'UniformOutput', false)));
end

% Use a second flag if you only want exact matches.
if size(varargin,2)>1
    
    if varargin{1,1}==0  % Just give expressions back in a list if first argument is 0.
        
         out = ~cellfun('isempty', cellfun(@(x) x==1, regexp(cellstr_array, ['^' expression '$']), 'UniformOutput', false));
        
    else
        
        out = cellstr_array(~cellfun('isempty', cellfun(@(x) x==1, regexp(cellstr_array, ['^' expression '$']), 'UniformOutput', false)));  %  Give logical array of exact match.

    end
    
end

