%% Load TDMS file
% Depends on https://uk.mathworks.com/matlabcentral/fileexchange/44206-converttdms-v10
% Make sure simpleConvertTDMS is in your path.
clc; clear;
tic;
%% Load directories
folderpath = uigetdir(".", "Pick directory with TDMS files for conversion");
cd(folderpath);
files = {dir("*.tdms").name}';
[~, filename, ~] = fileparts(files);

%%

data = simpleConvertTDMS(false, files);
data_raw = {data.Data}';

%% Matlab's dogshit struct interface
properties = [
    struct('pattern', 'lvdt', 'suffix', '-lvdt');
    struct('pattern', 'state.jcs', 'suffix', '-loads_translations');
    struct('pattern', 'kinematics', 'suffix', '-kinematics');
    struct('pattern', 'kinetics', 'suffix', '-kinetics');
];

%%
parfor i = 1:length(data_raw)
    measured_data = data_raw{i}.MeasuredData;
    names = {measured_data.Name};

    % This code is ilegible. Matlab is utter horse shit.

    % find the fields that contain the pattern (lvdt, state.jcs,...) and
    % give out a logical index array
    idx_properties = cellfun(@(p) contains(lower(names), p) & contains(names, '/'), {properties.pattern}, 'UniformOutput', false);
    % create a table from the properties that match the pattern. find_properties() is
    % doing the heavy lifting
    prop_data = cellfun(@(idx) find_properties(measured_data, idx), idx_properties, 'UniformOutput', false);

    % print each property as CSV using corresponding suffix
    cellfun(@(data, suffix) print_csvs(data, folderpath, filename{i}, suffix), prop_data, {properties.suffix}, 'UniformOutput', false);

end
clear data data_raw filename files folderpath i names properties
toc;
%% Local functions

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