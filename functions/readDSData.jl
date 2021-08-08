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