include("functions/readDSData.jl")

filename = "data/raw_data/Participant 1_Drive1.txt";

# Extract data from raw data files
data = read_ds_data(filename);

# Write data to csv file to reduce the need to extract again
# Add a check to see if extracted data exists, and then extract if not.

# Only analyse columns associated with drivers data
driver_data_cols = 1:11;
driver_only_data = data[2:end-1, driver_data_cols];

