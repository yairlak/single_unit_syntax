function figure_names = generate_raster_figures(rasters, settings)
comparison_name = settings.comparison_name;

before_stim = settings.duration_before_stimulus_onset;
after_stim = settings.duration_after_stimulus_onset;
around_stim = before_stim + after_stim;

all_units = fieldnames(rasters);
all_conditions = fieldnames(rasters.(all_units{1}));
all_conditions = setdiff(all_conditions, 'button_press');

if all(cellfun(@(x) length(x)>=5, all_conditions))
    if all(cellfun(@(x) strcmp(x(1:5), 'value'), all_conditions))
            for val = 1:length(all_conditions)
                all_conditions_cell{val} = all_conditions(val);
            end
    else
            all_conditions_cell{1} = all_conditions;
    end
else
    all_conditions_cell{1} = all_conditions;
end

for u = 1:length(all_units)
    unit_name = all_units{u};
    if settings.generate_condition_rasters
            for val = 1:length(all_conditions_cell)
                all_conditions = all_conditions_cell{val};
                num_conditions = length(all_conditions);
                f = figure('color', [1 1 1], 'visible', 'off');
                for cnd = 1:num_conditions
                    % Load raster data
                   curr_cnd = all_conditions{cnd};
                   curr_raster_matrix = rasters.(unit_name).(curr_cnd).matrix;
                   curr_spike_times = rasters.(unit_name).(curr_cnd).spike_times;

                   % Position and plot the RASTER
                   spacing = 0.1;
                    plot_width = (1-spacing*(num_conditions+1))/num_conditions;
                    pos_vec(1) = spacing + (spacing + plot_width)*(cnd-1);
                    pos_vec(2) = 0.32;
                    pos_vec(3) = plot_width;
                    pos_vec(4) = 0.57;
                    f_s = subplot('position', pos_vec);
                    raster_generator(curr_spike_times, settings.line_size)
                    line([0 0], [0 size(curr_raster_matrix, 1)+1], 'color', 'r', 'LineWidth', 2, 'LineStyle', '--')
                    if strcmp(settings.patient, 'ArM01') &&  ~isempty(strfind(settings.block_name, 'sentences'))
                        line([settings.SOA settings.SOA], [0 size(curr_raster_matrix, 1)+1], 'color', 'c', 'LineWidth', 2, 'LineStyle', '--')
                    end
                    xlim([-before_stim after_stim])
                    ylim([0.5 size(curr_raster_matrix, 1)+0.5])
                    set(gcf, 'visible', 'off')
                    set(gcf, 'color', [1 1 1])
                    set(gca, 'xtick', -before_stim:settings.step_gca:after_stim, 'xticklabel', -before_stim:settings.step_gca:after_stim)
                    set(gca, 'FontSize', 8)
                    if cnd == 1 
                        ylabel('#Trial', 'fontsize', 10)
                    end
                    title(sprintf('%s', curr_cnd), 'fontsize', 10)

                    % Position and plot the PSTH
                    curr_PSTH = calc_PSTH(curr_raster_matrix, settings.PSTH_bin_size);
                    pos_vec = get(f_s, 'position');
                    pos_vec(2) = 0.08;
                    pos_vec(4) = 0.15;
                    subplot('Position', pos_vec)
                    h = bar(curr_PSTH, 1);
                    xlim([0.5 length(curr_PSTH)-0.5])
                    ylim([0 settings.PSTH_ylim]);
                    line([before_stim/settings.PSTH_bin_size + 0.5 before_stim/settings.PSTH_bin_size + 0.5], [0 settings.PSTH_ylim], 'color', 'r', 'LineWidth', 2, 'LineStyle', '--')
                    if strcmp(settings.patient, 'ArM01') &&  ~isempty(strfind(settings.block_name, 'sentences'))
                        line([(before_stim+settings.SOA)/settings.PSTH_bin_size + 0.5 (before_stim+settings.SOA)/settings.PSTH_bin_size + 0.5], [0 settings.PSTH_ylim], 'color', 'c', 'LineWidth', 2, 'LineStyle', '--')
                    end
                    set(gca, 'xtick', 1:length(curr_PSTH), 'xticklabel', [])
                    str = sprintf('Time [ms], bin-size %ims', settings.PSTH_bin_size); %ms);
                    xlabel(str, 'fontsize', 10)
                    if cnd == 1 
                        ylabel('Mean rate [Hz]', 'fontsize', 10)
                    end
                    set(gca, 'FontSize', 8)
                    box off 
                end
            
                % Generate figure name and save to drive
                settings.unit_name = unit_name;
                if length(all_conditions_cell) > 1
                    settings.comparison_name = [comparison_name '_' curr_cnd];
                else
                    settings.comparison_name = comparison_name;
                end
                
                if strcmp(settings.block_name, 'sentences')
                    settings_fields = {'patient', 'unit_name', 'comparison_name', 'block_name', 'lock_to_word'};
                else
                    settings_fields = {'patient', 'unit_name', 'comparison_name', 'block_name'};
                end
                params = []; params_fields = [];
                file_name = get_file_name_curr_run(settings, params, settings_fields, params_fields);
                file_name = ['raster_' file_name];
                figure_names{u} =  [file_name '.png'];
                saveas(f, fullfile('../../Figures//Rasters', [file_name '.png']), 'png')
                close(f)
            end
    end
    
    %% Button press
    if settings.generate_key_press_rasters
        f = figure('color', [1 1 1], 'visible', 'off');
        curr_raster_matrix = rasters.(unit_name).button_press.matrix;
        curr_spike_times = rasters.(unit_name).button_press.spike_times;
        spacing = 0.1;
        plot_width = (1-spacing*2);
        pos_vec(1) = spacing;
        pos_vec(2) = 0.32;
        pos_vec(3) = plot_width;
        pos_vec(4) = 0.57;
        f_s = subplot('position', pos_vec);
        raster_generator(curr_spike_times, settings.line_size)
        line([0 0], [0 size(curr_raster_matrix, 1)+1], 'color', 'r', 'LineWidth', 2, 'LineStyle', '--')
        xlim([-before_stim after_stim])
        ylim([0.5 size(curr_raster_matrix, 1)+0.5])
        set(gcf, 'visible', 'off')
        set(gcf, 'color', [1 1 1])
        set(gca, 'xtick', -before_stim:settings.step_gca:after_stim, 'xticklabel', -before_stim:settings.step_gca:after_stim)
        set(gca, 'FontSize', 8)
        ylabel('#Trial', 'fontsize', 10)
        title('Key press', 'fontsize', 10)
        
        % Add PSTH
        curr_PSTH = calc_PSTH(curr_raster_matrix, settings.PSTH_bin_size);
        pos_vec = get(f_s, 'position');
        pos_vec(2) = 0.08;
        pos_vec(4) = 0.15;
        subplot('Position', pos_vec)
        h = bar(curr_PSTH, 1);
        xlim([0.5 length(curr_PSTH)-0.5])
        ylim([0 settings.PSTH_ylim]);
        line([before_stim/settings.PSTH_bin_size + 0.5 before_stim/settings.PSTH_bin_size + 0.5], [0 settings.PSTH_ylim], 'color', 'r', 'LineWidth', 2, 'LineStyle', '--')
        set(gca, 'xtick', 1:length(curr_PSTH), 'xticklabel', [])
        str = sprintf('Time [ms], bin-size %ims', settings.PSTH_bin_size); %ms);
        xlabel(str, 'fontsize', 10)
        ylabel('Mean rate [Hz]', 'fontsize', 10)
        set(gca, 'FontSize', 8)
        box off 
        
        %% Generate figure name and save to drive
        settings.unit_name = unit_name;
        settings_fields = {'patient', 'unit_name', 'block_name'};
        params = []; params_fields = [];
        file_name = get_file_name_curr_run(settings, params, settings_fields, params_fields);
        file_name = ['raster_button_press_' file_name];
        figure_names{u} =  [file_name '.png'];
        saveas(f, fullfile('../../Figures/Rasters', [file_name '.png']), 'png')
        close(f)  
    end
end



