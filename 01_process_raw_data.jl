using Glob, DataFrames, CSV

include("functions/data_extract_utils.jl")
include("user_vars.jl")

ID_regex = r"(?<=\s)[0-9]{1,2}(?=_)"

driver_cols =  ["Elapsed_time_s", "Dist_travelled_ft", "Longit_velocity_mph",
"Longit_velocity_fps", "Lat_velocity_fps", "Lane_position_ft",
"Steering_raw_counts", "Throttle_raw_counts", "Brake_raw_counts",
"Traffic_light_settings", "Collisions"]

other_vehicle_cols = ["Row_number", "Elapsed_time_s", "Vehicle_ID", "Speed_diff_fps",
"Longit_pos_from_driver", "Lat_pos_from_Driver"]

driver_data_cols = 1:11; 
other_data_start = maximum(driver_data_cols) + 1

files = glob("*.txt", directories["raw_data"])

for filepath in files

    filename = basename(filepath)
    participant_id = match(ID_regex, filename).match

    driver_path = gen_output_path("extracted_driver", participant_id)
    otherveh_path = gen_output_path("extracted_other", participant_id)

    raw_data = read_ds_data(filepath);

    if !isfile(driver_path)
        driver_only_data = raw_data[2:end-1, driver_data_cols]
        driver_only_df = DataFrame(driver_only_data, Symbol.(driver_cols))
        CSV.write(driver_path, driver_only_df)
    end

    if !isfile(otherveh_path)
        other_vehicle_raw = raw_data[2:end-1, other_data_start:end]
        other_vehicle_data = extract_othervehicles_data(other_vehicle_raw)
        other_vehicle_df = DataFrame(other_vehicle_data, Symbol.(other_vehicle_cols))
        CSV.write(otherveh_path, other_vehicle_df)
    end

end