%% Load TDMS file
% Depends on https://uk.mathworks.com/matlabcentral/fileexchange/44206-converttdms-v10
% Make sure simpleConvertTDMS is in your path.
clc; clear;
[file, path] = uigetfile("*.tdms", "Pick a TDMS file");
[~, filename, ext] = fileparts(file);
data = simpleConvertTDMS(false, file);
measured_data = data.Data.MeasuredData;
names = {measured_data.Name};

%% Find the LVDTs, then sort alphabetically. 
lvdt_indices = cellfun(@(x) contains(lower(x), 'lvdt') && contains(x, '/'), names);
matching_names = names(lvdt_indices);
matching_data = {measured_data(lvdt_indices).Data};
[sorted_names, sort_index] = sort(matching_names);
sorted_data = matching_data(sort_index);
flattened_matrix = horzcat(sorted_data{:});
lvdts = array2table(flattened_matrix);
lvdts.Properties.VariableNames(:) = sorted_names;

%% Write to csv file
writetable(lvdts, strcat(path,filename,"-lvdt.csv"));