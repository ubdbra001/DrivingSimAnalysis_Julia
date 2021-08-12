








# Find index for sample when the target object would have been created
creation_idx = findfirst(driver_only_data[:,2] .> target_object["created_point"])

# Extract data
creation_window_data = driver_only_data[creation_idx:end, :]

# Distance that the driver has travelled
driver_dist_change = cumsum(diff(creation_window_data[:,2]));

# Distance of moving object
target_dist_change = cumsum(diff(creation_window_data[:,1])*target_object["velocity_fps"]);

# Calculate overall change in distance
overall_dist_change = driver_dist_change + target_dist_change;

# Calculate where target is in relation to driver
dummy_dist = target_object["dist_from_driver"] .- [0; overall_dist_change]

data_with_target_obj = cat(creation_window_data, dummy_dist, dims = 2)

cross_point = findfirst(data_with_target_obj[:,end] .< 0 )

data_with_target_obj[cross_point-1, :]