function defaults = sbha_binned_position_frequency_timecourse_defaults()

defaults = sbha.get_common_make_defaults();
defaults.time_window_size = 10;
defaults.position_window_size = 0.01;
defaults.position_padding = 0;
defaults.event_name = 'cue_onset';
defaults.use_trial_selection_criterion = false;
defaults.normalize_to = 'screen';
defaults.lr_normalization_time_window = [];

end