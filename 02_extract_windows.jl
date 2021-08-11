# Extract data around crossover point for each window of interest

using Glob, CSV, DataFrames #ImageFiltering

include("user_vars.jl")

ID_regex = r"(?<=p)[0-9]{3}(?=_)"

driver_files = glob("*.csv", directories["extracted_driver"])

# Start with simple example of car chicane
vehicle_n = 11

out_filename = "Vehicle11_10sB_1sA.csv"
output_dir = "data/windowed_data/"
output_path = joinpath(output_dir, out_filename)


# Still need to work out how crossover is determined
#   If Vehicle then use the other vehicle data
#   Otherwise calculate from information available
# First of these two is likely more reliable
# How to determine this? Add more details to user_vars file perhaps?

# Start off with empty dataframe
output_df = DataFrame(Matrix{Float64}(undef, 0, length(driver_cols)), Symbol.(driver_cols))
output_df.Rel_time_s = Vector{Float64}()
output_df.Participant_ID = Vector{Int64}()

for filepath in driver_files
    filename = basename(filepath)
    participantID = match(ID_regex, filename).match
    participantInt = parse(Int64, participantID)
    
    # Load driver_data
    driver_df = CSV.read(filepath, DataFrame)
    
    # For now just go for using other vehicle data
    other_vehicle_path = gen_output_path("extracted_other", participantID)
    other_df = CSV.read(other_vehicle_path, DataFrame)
    
    # Filter by vehicle ID
    filtered_other_df = other_df[other_df.Vehicle_ID .== vehicle_n, :]

    # Find first point where long_dist from driver < 0
    # (Sign of operator may have to switch depending on event: Some start behind, others start in-front)
    crossover_idx = findfirst(filtered_other_df.Longit_pos_from_driver .< 0)

    # Find time of crossover
    crossover_time = filtered_other_df.Elapsed_time_s[crossover_idx]

    # Once crossover point is found then pull out the data for the window around the point
    window_start, window_end = window_properties["time_range_s"] .+ crossover_time
    window_idx = (window_start .<= driver_df.Elapsed_time_s .<= window_end)
    windowed_df = driver_df[window_idx, :]

    # Add participant ID and Relative times to dataframe
    windowed_df.Rel_time_s = windowed_df.Elapsed_time_s .- crossover_time 
    insertcols!(windowed_df, :Participant_ID => participantInt)

    # Append for output
    append!(output_df, windowed_df)
end

# Save the data into appropriate directory
CSV.write(output_path, output_df)