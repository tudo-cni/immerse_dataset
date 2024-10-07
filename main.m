%%%
%main.m: Test script for parsing and plotting measurement traces.
%
%author: Marcus Haferkamp, Simon Häger, Stefan Böcker, and Christian Wietfeld
%license: CC-BY-SA-4.0
%version: v0.1
%maintainer: Marcus Haferkamp, Simon Haeger
%email: {marcus.haferkamp, simon.haeger}@tu-dortmund.de
%%%

clear all
close all
clc

assert(ispc, 'This OS is not supported.')

%% Filter Options - Otherwise: loads all files
% Note: Script load all files if no filtering occurs. This takes some time.

% Optional: filter for modems
% TARGET_MODEMS = [];                    % no filtering by specific modem
% TARGET_MODEMS = ["UE_A", "UE_B", "UE_C"];
TARGET_MODEMS = ["UE_A"];               % filtering for Modem "A"

% Optional: filter for channel metric
% TARGET_METRICS = [];                  % no filtering by specific metric
% TARGET_METRICS = ["5G_drx_rsrp", "5G_prx_rsrp", "4G_prx_rsrp"];
TARGET_METRICS = ["5G_drx_rsrp"];       % filtering for RSRP of "5G_drx"

% Optional: filter for mode
% TARGET_MODES = [];                    % no filtering by specific vehicle
% TARGET_MODES = ["agv", "pedestrian", "los"];
TARGET_MODES = ["agv"];                 % filtering for vehicle "agv"

% Optional: filter tracks
% TARGET_TRACKS = [];                   % no filtering by specific track
% TARGET_TRACKS = ["track1", "track2"];
TARGET_TRACKS = ["track2"];             % filtering for track "2"

%% Load data
data_path = 'csv\';
file_format = '.csv';
% get full list of files
files_overview = get_files_overview(data_path, file_format);
% filter the files
files_overview = filter_modems(files_overview, TARGET_MODEMS);
files_overview = filter_metrics(files_overview, TARGET_METRICS);
files_overview = filter_modes_and_tracks(files_overview, TARGET_MODES, TARGET_TRACKS);
% load data
files_overview = load_specified_files(files_overview, data_path, file_format);

%% Plot Nth entry of Specified Dataset
N = 1;
assert(N>=1 && N<=length(files_overview) && mod(N,1)==0, 'Specify valid file index.')
figure()
plot(1:length(files_overview(N).data), files_overview(N).data)
grid on
xlabel('CSI Sample Index')
ylabel('RSRP [dBm]')


%% FILTERING AND I/O FUNCTIONS
function files_overview = get_files_overview(data_path, file_format)
    files_overview = dir([fullfile(data_path, ['**\*',file_format])]);
    files_overview = rmfield(files_overview, {'date', 'bytes', 'isdir', 'datenum'});
    parfor n = 1:length(files_overview)
        raw_string = files_overview(n).folder;
        k = strfind(raw_string, data_path);
        files_overview(n).folder = raw_string(k+length(data_path):end);
        raw_string = files_overview(n).name;
        k = strfind(raw_string, file_format);
        files_overview(n).name = raw_string(1:k-1);
    end
    clearvars n k raw_string
end

function files_overview = filter_modems(files_overview, TARGET_MODEMS)
    if ~isempty(TARGET_MODEMS)
        folder_list = {files_overview(:).folder};
        N = length(TARGET_MODEMS);
        boolean_selector_mat = zeros(N, length(folder_list));
        for n = 1:N
            boolean_selector_mat(n,:) = contains(folder_list, TARGET_MODEMS(n));
        end
        if N > 1
            boolean_selector_mat = sum(boolean_selector_mat) >=1;
        else
            boolean_selector_mat = logical(boolean_selector_mat);
        end
        files_overview = files_overview(find(boolean_selector_mat==1));
        clearvars boolean_selector_mat folder_list N n
    end
end

function files_overview = filter_metrics(files_overview, TARGET_METRICS)
    if ~isempty(TARGET_METRICS)
        file_list = {files_overview(:).name};
        N = length(TARGET_METRICS);
        boolean_selector_mat = zeros(N, length(file_list));
        for n = 1:N
            boolean_selector_mat(n,:) = contains(file_list, TARGET_METRICS(n));
        end
        if N > 1
            boolean_selector_mat = sum(boolean_selector_mat) >=1;
        else
            boolean_selector_mat = logical(boolean_selector_mat);
        end
        files_overview = files_overview(find(boolean_selector_mat==1));
        clearvars boolean_selector_mat folder_list N n
    end
end

function files_overview = filter_modes_and_tracks(files_overview, TARGET_MODES, TARGET_TRACKS)
    %% Handle combinations of TARGET_MODES and TARGET_TRACKS 
    if isempty(TARGET_TRACKS) && ~isempty(TARGET_MODES)
        FILTER_VALUES = TARGET_MODES;
    elseif isempty(TARGET_TRACKS) && isempty(TARGET_MODES)
        FILTER_VALUES = [];
    else
        % translate TARGET_TRACKS to digits
        TARGET_TRACKS_int = zeros(size(TARGET_TRACKS));
        for n = 1:length(TARGET_TRACKS_int)
            if strcmp(TARGET_TRACKS(n), "track1")
                TARGET_TRACKS_int(n) = 1;
            elseif strcmp(TARGET_TRACKS(n), "track2")
                TARGET_TRACKS_int(n) = 2;
            end
        end
        clearvars n TARGET_TRACKS
        % cases where tracks are specified
        FILTER_VALUES =  ["los", "agv_track1", "agv_track2", "pedestrian_track1", "pedestrian_track2"];
        N = length(TARGET_TRACKS_int);
        boolean_selector_mat = zeros(N, length(FILTER_VALUES));
        for n = 1:N
            if TARGET_TRACKS_int(n) == 1
                boolean_selector_mat(n,:) = [1,1,0,1,0];
            elseif TARGET_TRACKS_int(n) == 2
                boolean_selector_mat(n,:) = [1,0,1,0,1];
            end
        end
        if N > 1
            boolean_selector_mat = sum(boolean_selector_mat) >=1;
        else
            boolean_selector_mat = logical(boolean_selector_mat);
        end
        FILTER_VALUES = FILTER_VALUES(boolean_selector_mat);
        clearvars N boolean_selector_mat n   
        if ~isempty(TARGET_MODES)
            N = length(TARGET_MODES);
            boolean_selector_mat = zeros(N, length(FILTER_VALUES));
            for n = 1:N
                boolean_selector_mat(n,:) = contains(FILTER_VALUES, TARGET_MODES(n));
            end
            if N > 1
                boolean_selector_mat = sum(boolean_selector_mat) >=1;
            else
                boolean_selector_mat = logical(boolean_selector_mat);
            end
            FILTER_VALUES = FILTER_VALUES(boolean_selector_mat);
            clearvars N boolean_selector_mat n   
        end
    end    
    %% Filtering
    if ~isempty(FILTER_VALUES)
        folder_list = {files_overview(:).folder};
        N = length(FILTER_VALUES);
        boolean_selector_mat = zeros(N, length(folder_list));
        for n = 1:N
            boolean_selector_mat(n,:) = contains(folder_list, FILTER_VALUES(n));
        end
        if N > 1
            boolean_selector_mat = sum(boolean_selector_mat) >=1;
        end
        files_overview = files_overview(find(boolean_selector_mat==1));
        clearvars boolean_selector_mat folder_list N n
    end
end

function files_overview = load_specified_files(files_overview, data_path, file_format)
    tic;
    N = length(files_overview);
    wb = waitbar(0,'Loading data...');
    parfor n = 1:N
        files_overview(n).data = load_file( data_path, ...
                                            files_overview(n).folder, ...
                                            files_overview(n).name, ...
                                            file_format);
        waitbar(1 - n/N, wb, 'Loading data...');
    end
    close(wb)
    clearvars n N wb
    toc
end

function data = load_file(data_path, path, file_name, file_format)
    data = importdata([data_path, path,'\', file_name, file_format]);
end