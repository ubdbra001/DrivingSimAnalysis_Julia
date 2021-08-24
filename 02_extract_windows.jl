# Extract data around crossover point for each window of interest

using Glob, CSV, DataFrames, TOML

include("user_vars.jl")
include("functions/extract_windows_utils.jl")
include("functions/data_extract_utils.jl")

all_windows = open("window_details.toml") do file
    TOML.parse(file)
end

window_detail = all_windows["sign_response"]

ID_regex = r"(?<=p)[0-9]{3}(?=_)"

driver_files = glob("*.csv", directories["extracted_driver"])

# Start with simple example of car chicane

output_dir = "data/windowed_data/"
output_path = joinpath(output_dir, window_detail["output_name"])


# Still need to work out how crossover is determined
#   If Vehicle then use the other vehicle data
#   Otherwise calculate from information available
# First of these two is likely more reliable
# How to determine this? Add more details to user_vars file perhaps?

# Start off with empty dataframe
output_df = DataFrame(Matrix{Float64}(undef, 0, length(driver_cols)), Symbol.(driver_cols))
output_df.Participant_ID = Vector{Int64}()

output_df.Rel_time_s = Vector{Float64}()
output_df.Rel_dist_ft = Vector{Float64}()

for filepath in driver_files
    filename = basename(filepath)
    participantID = match(ID_regex, filename).match
    participantInt = parse(Int64, participantID)
    
    # Load driver_data
    driver_df = CSV.read(filepath, DataFrame)
    crossover_idx = nothing

    if "vehicle_id" in keys(window_detail)
        # For now just go for using other vehicle data
        other_vehicle_path = gen_output_path("extracted_other", participantID)
        other_df = CSV.read(other_vehicle_path, DataFrame)
        
        # Filter by vehicle ID
        filtered_other_df = other_df[other_df.Vehicle_ID .== window_detail["vehicle_id"], :]
    
        # Find first point where long_dist from driver < 0
        # (Sign of operator may have to switch depending on event: Some start behind, others start in-front)
        other_cross_idx = findfirst(filtered_other_df.Longit_pos_from_driver .< 0)
        other_cross_time = filtered_other_df.Elapsed_time_s[other_cross_idx]
    
        # Find index whenre the other car crosses over in the driver_df 
        crossover_idx = findall(driver_df.Elapsed_time_s .== other_cross_time)

    elseif "event_distance" in keys(window_detail)

        # Find index of first sample where driver passed event distance 
        crossover_idx = findfirst(driver_df.Dist_travelled_ft .> window_detail["event_distance"])

    elseif "event_time" in keys(window_detail)
    
        crossover_idx = findfirst(driver_df.Dist_travelled_ft .> window_detail["event_time"])

    end
    
    # Neater but could be better
    if "time_range_s" in keys(window_detail)
        
        window_range = window_detail["time_range_s"]
        col_of_interest = driver_df.Elapsed_time_s

    elseif "dist_range_ft" in keys(window_detail)
        
        window_range = window_detail["dist_range_ft"]
        col_of_interest = driver_df.Dist_travelled_ft

    end
    
    window_idx = generate_window(crossover_idx, col_of_interest, window_range)
    windowed_df = driver_df[window_idx, :]
    
    # Add participant ID and Relative times to dataframe
    if !isnothing(crossover_idx)
        windowed_df.Rel_time_s = windowed_df.Elapsed_time_s .- driver_df.Elapsed_time_s[crossover_idx]
        windowed_df.Rel_dist_ft = windowed_df.Dist_travelled_ft .- driver_df.Dist_travelled_ft[crossover_idx]
    else
        windowed_df.Rel_time_s = windowed_df.Elapsed_time_s .- windowed_df.Elapsed_time_s[1] 
        windowed_df.Rel_dist_ft = windowed_df.Dist_travelled_ft .- windowed_df.Dist_travelled_ft[1]
    end
    insertcols!(windowed_df, :Participant_ID => participantInt)

    # Append for output
    append!(output_df, windowed_df)
end

# Save the data into appropriate directory
CSV.write(output_path, output_df)