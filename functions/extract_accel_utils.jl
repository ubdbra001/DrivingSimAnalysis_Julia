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