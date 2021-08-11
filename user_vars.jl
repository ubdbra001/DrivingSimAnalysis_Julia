nonvehicle_target = Dict(
    "name" => "roadworks1",
    "created_point" => 3500,
    "dist_from_driver" => 3000,
    "end_point" => 4000,
    "velocity_fps" => 0,
    "sample_rate" => 30,
 )

 window_properties = Dict(
    "time_range_s" => [1,1],
    "distance_range_ft" => [],
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

 