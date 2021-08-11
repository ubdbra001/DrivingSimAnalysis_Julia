using DelimitedFiles: readdlm

function occursin_vec(text_in::String, text_to_search::Vector{String})

    for (i, line) in enumerate(text_to_search)
        if occursin(text_in, line)
            return(i)
        end
    end

    return(false)
end

function extract_data(text_vector, begin_text = "Block #1", end_text = "Time to collision results")

    begin_ind = occursin_vec(begin_text, text_vector);
    end_ind = occursin_vec(end_text, text_vector);

    data_text = text_vector[begin_ind+2:end_ind-2];

    return(data_text)
end


function convert_text_to_vector(text_vector)

    numeric_vector = Vector{Vector}(undef, length(text_vector));

    split_text = split.(text_vector);

    for (i, line) in enumerate(split_text)
        numeric_vector[i] = tryparse.(Float64, line)
    end

    return(numeric_vector)

end

function numeric_vec_to_matrix(numeric_vector)

    nv_max_len = maximum(length.(numeric_vector))

    output_mat = Matrix{Union{Missing, Number}}(missing, length(numeric_vector), nv_max_len)
    
    for (i, line) in enumerate(numeric_vector)
        output_mat[i,1:length(line)] .= line
    end
    
    return(output_mat)

end

function read_ds_data(filename)

    file_text = readlines(filename);

    data_text = extract_data(file_text);

    data_numeric_vec = convert_text_to_vector(data_text);

    data_matrix = numeric_vec_to_matrix(data_numeric_vec)

    return(data_matrix)

end

function extract_othervehicles_data(data_in)

    n_other_vehicles = maximum(Int.(skipmissing(data_in[:,1])))

    v_0 = Array{Number}(undef, 0, 6)

    for vehicle_ID in 1:n_other_vehicles
        v_temp = extract_vehic_data(data_in, vehicle_ID)
        v_0 = cat(v_0, v_temp, dims = 1) 
    end

    return(v_0)

end


function extract_vehic_data(other_vehicle_data, ID_to_find)

    # Replace missing vales with 0s (Do we still need this?)
    replace!(other_vehicle_data, missing => 0.0)

    # Convert vehicle IDs to integers
    other_vehicle_data[:,1:4:end] = Int.(other_vehicle_data[:,1:4:end])

    # Find all instances of specific ID
    data_rows = findall(other_vehicle_data .=== ID_to_find)

    # Generate coordinates for data points for the  data assciated with the ID
    data_ind = (data_rows .+ CartesianIndices((1,1:4))) .- CartesianIndices((1,1))

    # Get inidivdual row numbers for sorting later
    row_number = [coords[1] for coords in data_rows]

    # Get time data for the section of interest
    time_win = driver_only_data[row_number, 1]

    # Pull out the data for the vehicle ID
    vehicle_data = other_vehicle_data[data_ind]

    # Join row_number, time_win and the data for the vehile ID
    vehicle_data_unsorted = cat(row_number, time_win, vehicle_data, dims = 2)

    # Sort data according to row number
    vehicle_data_sorted = sortslices(vehicle_data_unsorted, dims = 1)

    return(vehicle_data_sorted)
end


function gen_output_path(output_type, P_ID)

    padded_ID = lpad(P_ID, 3, "0")
    out_filename = replace(filenames[output_type], "(placeholder)" => padded_ID)
    out_path = joinpath(directories[output_type], out_filename)

    return(out_path)

end