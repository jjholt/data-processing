%% Load TDMS file
% Depends on https://uk.mathworks.com/matlabcentral/fileexchange/44206-converttdms-v10
% Make sure simpleConvertTDMS is in your path.
clc; clear;
%[file, path] = uigetfile("*.tdms", "Pick a TDMS file");
%[~, filename, ext] = fileparts(file);

%% Load directories
folderpath = uigetdir(".", "Pick directory with TDMS files for conversion");
cd(folderpath);
files = {dir("*.tdms").name}';
[~, filename, ext] = fileparts(files);

%%

data = simpleConvertTDMS(false, files);
data_raw = {data.Data}';

measured_data = cell(length(data_raw), 1);
names = cell(length(data_raw), 1);
lvdt_indices = cell(length(data_raw), 1);
%% 
for i = 1:length(data_raw)
    measured_data = data_raw{i}.MeasuredData;
    names = {measured_data.Name};
    % Find the LVDTs, then sort alphabetically.
    lvdt_indices = cellfun(@(x) contains(lower(x), 'lvdt') && contains(x, '/'), names);
    matching_names = names(lvdt_indices);
    matching_data = {measured_data(lvdt_indices).Data};
    [sorted_names, sort_index] = sort(matching_names);
    sorted_data = matching_data(sort_index);
    flattened_matrix = horzcat(sorted_data{:});
    lvdts = array2table(flattened_matrix);
    lvdts.Properties.VariableNames(:) = sorted_names;

    new_filename = strcat(folderpath,"/", filename{i},"-lvdt.csv");
    % Write to csv file
    writetable(lvdts, new_filename);
end

