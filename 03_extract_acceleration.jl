using Dierckx, CSV, DataFrames, Plots, TOML, Statistics
using Plots.PlotMeasures: px

all_windows = open("window_details.toml") do file
    TOML.parse(file)
end
include_commparison = true;

window_name = "chicane_dist_after"

window_detail = all_windows[window_name]

file_path = joinpath("data/windowed_data/", window_detail["output_name"])

plot_path = "output/plots/$(window_name)"

plot_type = "svg"

if !isdir(plot_path)
    mkdir(plot_path)
end

allps_windowed_df = CSV.read(file_path, DataFrame);
# Add acceleration & jerk columns
insertcols!(allps_windowed_df, :Longit_accel_fps2 => 0.0, :Longit_jerk_fps3 => 0.0)

participants = unique(allps_windowed_df.Participant_ID)

base_smoothing = 0



P_id = 57

#for P_id in participants

padded_ID = lpad(P_id, 3, "0")

println("current participant: ", out_name, "\n")

windowed_df = allps_windowed_df[allps_windowed_df.Participant_ID .== P_id, :];

x_var = windowed_df.Rel_dist_ft;

        if include_commparison
no_smooth = Spline1D(windowed_df.Elapsed_time_s, windowed_df.Longit_velocity_fps, s = base_smoothing);

est_accel_ns = derivative(no_smooth, windowed_df.Elapsed_time_s, nu = 1);
est_jerk_ns = derivative(no_smooth, windowed_df.Elapsed_time_s, nu = 2);
        end

smooth = Spline1D(windowed_df.Elapsed_time_s, windowed_df.Longit_velocity_fps, s = smoothing);

est_accel_s = derivative(smooth, windowed_df.Elapsed_time_s, nu = 1);
est_jerk_s = derivative(smooth, windowed_df.Elapsed_time_s, nu = 2);
    
# Add estimated 1st and 2nd derivatives to dataframe
#allps_windowed_df.Longit_accel_fps2[allps_windowed_df.Participant_ID .== P_id] .= est_accel;
#allps_windowed_df.Longit_jerk_fps3[allps_windowed_df.Participant_ID .== P_id] .= est_jerk;
#b = round.(windowed_df.Elapsed_time_s[2:end] .- crossover_time; digits = 3) 

        if include_commparison
            p1_vars = [windowed_df.Longit_velocity_fps, no_smooth(windowed_df.Elapsed_time_s)];
            p2_vars = [est_accel_s, est_accel_ns];
            p3_vars = [est_jerk_s, est_jerk_ns];
            alpha_vals = [1 0.3];
        else
            p1_vars = windowed_df.Longit_velocity_fps;
            p2_vars = est_accel_s;
            p3_vars = est_jerk_s;
            alpha_vals = 1;
        end

p1 = plot(
    x_var,
            p1_vars,
    ylabel = "Velocity (ft/s)",
    label = missing,
    ylims = (0, 100),
            la = alpha_vals
);

p2 = plot(
    x_var,
            p2_vars,
    colour = "red", 
    ylabel = "Acceleration (ft/s²)",
    label = missing,
    ylims = (-15, 15),
            la = alpha_vals
);

p3 = plot(
    x_var,
            p3_vars, 
    colour = "green",
    ylabel = "Jerk (ft/s³)",
    label = missing,
    ylims = (-100, 100),
            la = alpha_vals
);
    
plot_out = plot(p1, p2, p3, layout = (3,1), plot_title = out_name, size = (900, 600), left_margin = 20px);
   
savefig(plot_out, outpath)
#end

    #CSV.write(file_path, allps_windowed_df)

    grouped_data = groupby(allps_windowed_df, :Participant_ID)

    summarised_data = combine(grouped_data,
        :Longit_velocity_fps => mean => :Mean_Velocity_fps,
        :Longit_velocity_fps => std => :SD_Velocity_fps,
                             :Longit_accel_fps2 => mean => :Mean_Accel_fps2,
        :Longit_accel_fps2 => median => :Median_Accel_fps2,
        :Longit_accel_fps2 => std => :SD_Accel_fps2,
        :Longit_jerk_fps3 => mean => :Mean_Jerk_fps3,
        :Longit_jerk_fps3 => (x -> maximum(abs.(x))) => :MaxAbs_Jerk_fps3,
        :Longit_jerk_fps3 => std => :SD_Jerk_fps3)
# Summarise dataframe and save original (with new cols) and summarised version

    check_and_create_dir(dirname(summ_path))

    CSV.write(summ_path, summarised_data)
