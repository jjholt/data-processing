%% Load TDMS file
% Depends on https://uk.mathworks.com/matlabcentral/fileexchange/44206-converttdms-v10
% Make sure simpleConvertTDMS is in your path.
clc; clear;

%% Load directories
folderpath = uigetdir(".", "Pick directory with TDMS files for conversion");
cd(folderpath);
files = {dir("*.tdms").name}';
[~, filename, ~] = fileparts(files);

%%

data = simpleConvertTDMS(false, files);
data_raw = {data.Data}';

%% 
for i = 1:length(data_raw)
    measured_data = data_raw{i}.MeasuredData;
    names = {measured_data.Name};
    % Find the LVDTs
    lvdt_indices = cellfun(@(x) contains(lower(x), 'lvdt') && contains(x, '/'), names);
    lvdts = find_properties(measured_data, lvdt_indices);
    print_csvs(lvdts, folderpath, filename{i}, "-lvdt");

    % Find the jcs
    jcs_indices = cellfun(@(x) contains(lower(x), 'state.jcs') && contains(x, '/'), names);
    jcs = find_properties(measured_data, jcs_indices);
    print_csvs(jcs, folderpath, filename{i}, "-loads_translations");

    % Find the kinematics
    kinematics_indices = cellfun(@(x) contains(lower(x), 'kinematics') && contains(x, '/'), names);
    kinematics = find_properties(measured_data, kinematics_indices);
    print_csvs(kinematics, folderpath, filename{i}, "-kinematics");
    
    % Find the kinetics
    kinetics_indices = cellfun(@(x) contains(lower(x), 'kinetics') && contains(x, '/'), names);
    kinetics = find_properties(measured_data, kinetics_indices);
    print_csvs(kinetics, folderpath, filename{i}, "-kinetics");

end
clear data data_raw filename files folderpath i jcs_indices kinematics_indices kinetics_indices lvdt_indices names

function T = find_properties(measured_data, indices)
% Indices is a logical array of all the positions relevant to the property
% you want to print. To generate it, use something like:
% indices = cellfun(@(x) contains(lower(x), 'lvdt') && contains(x, '/'), names);
%
% suffix is the text added to the end of the csv file to identify the
% property. e.g., "-lvdt" or "-kinematics"
T = table();
if any(indices)
    names = {measured_data.Name};
    matching_names = names(indices);
    matching_data = {measured_data(indices).Data};
    [sorted_names, sort_index] = sort(matching_names);
    sorted_data = matching_data(sort_index);
    flattened_matrix = horzcat(sorted_data{:});
    T = array2table(flattened_matrix);
    trimmed_names = split(sorted_names', "/");
    T.Properties.VariableNames(:) = trimmed_names(:,2);
end
end

function print_csvs(T, folderpath, filename, suffix)
% The path is generated inside the function. provide the table, the folder path, the
% filename and the suffix.
% T = Table to be written
% folderpath = folder path, e.g. /path/to/my/dir
% filename = file name without extension, e.g. my_file
% suffix = identifier for the property you're printing, e.g. "-lvdt".
if ~isempty(T)
    new_filename = fullfile(folderpath, strcat(filename, suffix, ".csv"));
    writetable(T, new_filename);
end
end