% A script to generate rasters from spike trains, given a condition list
% clear all; close all; clc
addpath('functions')

%%
% Load settings and parameters
[settings, ~] = load_settings_params(settings);

% Choose which conditions to compare
[trials_info, settings] = get_condition_numbers(settings);

% Get time points for all tokens of each condition for the paradigm log
trials_info = get_condition_times(trials_info, settings);

% Create Epochs and Events objects
custom_events = create_epochs_and_events(trials_info, settings);