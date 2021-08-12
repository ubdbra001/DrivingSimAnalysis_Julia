using ImageFiltering, CSV, DataFrames, Plots
using ShiftedArrays: lag, lead

filepath = "data/windowed_data/Vehicle2_10sB_1sA.csv"

allps_windowed_df = CSV.read(filepath, DataFrame)

P_id = 54

windowed_df = allps_windowed_df[allps_windowed_df.Participant_ID .== P_id, :];

est_accel = first_order_FD(windowed_df);
est_jerk = second_order_FD(windowed_df);

# This is all acceleration proccessing stuff 
gauss_ker = ImageFiltering.Kernel.gaussian((2,));
filt_accel = [missing; imfilter(est_accel[2:end-1], gauss_ker); missing];
filt_jerk = [missing; imfilter(est_jerk[2:end-1], gauss_ker); missing];

#b = round.(windowed_df.Elapsed_time_s[2:end] .- crossover_time; digits = 3) 

plot(windowed_df.Rel_time_s, windowed_df.Longit_velocity_fps, label = missing, xticks = -10:1:1)
plot!(twinx(), windowed_df.Rel_time_s, filt_accel, colour = "red", label = missing, xticks = false)

plot(windowed_df.Rel_time_s, filt_accel, colour = "red", label = missing, xticks = -10:1:1)
plot!(twinx(), windowed_df.Rel_time_s, filt_jerk, colour = "green", label = missing, xticks = false)
# Different types of first order approximations for finite difference:
# Forwards
# Backwards
# Central

function first_order_FD(data_in)
    # This used Central approximation
    Δv = lead(data_in.Longit_velocity_fps) .- lag(data_in.Longit_velocity_fps)
    Δt = lead(data_in.Elapsed_time_s) .- lag(data_in.Elapsed_time_s)

    est_accel = Δv ./ Δt

    return(est_accel)
end

# 2nd order
function second_order_FD(data_in)
    Δv = lead(data_in.Longit_velocity_fps) .-
         (2 .* data_in.Longit_velocity_fps) .+
         lag(data_in.Longit_velocity_fps)

    Δt1 = lead(data_in.Elapsed_time_s) .- data_in.Elapsed_time_s
    Δt2 = data_in.Elapsed_time_s .- lag(data_in.Elapsed_time_s)

    Δt = Δt1 .* Δt2

    est_jerk = Δv ./ Δt

    return(est_jerk)
end