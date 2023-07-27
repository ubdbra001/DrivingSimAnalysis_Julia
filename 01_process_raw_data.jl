using Glob, DataFrames, CSV

include("functions/data_extract_utils.jl")
include("user_vars.jl")

# Regex for finding participant ID
ID_regex = r"(?<=\s)[0-9]{1,2}(?=_)"

driver_data_cols = 1:11; 
other_data_start = maximum(driver_data_cols) + 1

# Body of script

# Find all raw data files
files = glob("*.txt", directories["raw_data"])

for filepath in files

    # Extract filename and participant ID
    filename = basename(filepath)
    participant_id = match(ID_regex, filename).match

    # Generate output paths
    driver_path = gen_output_path("extracted_driver", participant_id)
    otherveh_path = gen_output_path("extracted_other", participant_id)

    # Load data
    raw_data = read_ds_data(filepath);

    # If the driver only data hasn't been extracted and saved then do that
    if !isfile(driver_path)
        driver_only_data = raw_data[2:end-1, driver_data_cols]
        driver_only_df = DataFrame(driver_only_data, Symbol.(driver_cols))
        CSV.write(driver_path, driver_only_df)
    end

    # If the other vehicle data hasn't been extracted and saved then do that 
    if !isfile(otherveh_path)
        other_vehicle_raw = raw_data[2:end-1, other_data_start:end]
        other_vehicle_data = extract_othervehicles_data(other_vehicle_raw, driver_only_data)
        other_vehicle_df = DataFrame(other_vehicle_data, Symbol.(other_vehicle_cols))
        CSV.write(otherveh_path, other_vehicle_df)
    end

end