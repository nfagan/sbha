function [x, y, t] = extract_edf_trials_samples(edf_trials_file, t_window)

x = edf_trials_file.aligned(:, :, edf_trials_file.key('x'));
y = edf_trials_file.aligned(:, :, edf_trials_file.key('y'));
t = edf_trials_file.t;

t_ind = t >= t_window(1) & t <= t_window(2);
t = t(t_ind);
x = x(:, t_ind);
y = y(:, t_ind);

end