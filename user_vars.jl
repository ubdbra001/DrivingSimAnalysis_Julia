nonvehicle_target = Dict(
    "name" => "roadworks1",
    "created_point" => 3500,
    "dist_from_driver" => 3000,
    "end_point" => 4000,
    "velocity_fps" => 0,
    "sample_rate" => 30,
 )

 directories = Dict(
     "raw_data" => "data/raw_data/",
     "extracted_driver" => "data/extracted_data/driver_data/",
     "extracted_other" => "data/extracted_data/other_vehicle_data/"
 )

 filenames = Dict(
     "extracted_driver" => "p(placeholder)_driverdata.csv",
     "extracted_other" => "p(placeholder)_othervehicledata.csv"
 )

 driver_cols =  ["Elapsed_time_s", "Dist_travelled_ft", "Longit_velocity_mph",
                "Longit_velocity_fps", "Lat_velocity_fps", "Lane_position_ft",
                "Steering_raw_counts", "Throttle_raw_counts", "Brake_raw_counts",
                "Traffic_light_settings", "Collisions"]

other_vehicle_cols = ["Row_number", "Elapsed_time_s", "Vehicle_ID", "Speed_diff_fps",
                      "Longit_pos_from_driver", "Lat_pos_from_Driver"]