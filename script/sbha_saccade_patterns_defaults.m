function defaults = sbha_saccade_patterns_defaults()

defaults = sbha.get_common_make_defaults();
defaults.event_name = 'cue_onset';
defaults.time_offsets = [];
defaults.use_end_event = false;
defaults.end_event_name = 'target_acquired';

end