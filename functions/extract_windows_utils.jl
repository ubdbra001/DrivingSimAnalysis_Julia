function generate_window(crossing_idx::Vector{Int}, col_of_interest, window_range)

    # Function for generating window indexes for relative time
    # If window_range is a single value then make a symetric window
    if length(window_range) == 1
        window_range = [-window_range, window_range]
    end

    crossing_point = col_of_interest[crossing_idx]
    window_start, window_end = window_range .+ crossing_point

    window_idx = (window_start .<= col_of_interest .<= window_end)

    return(window_idx)
end

function generate_window(crossing_idx::Nothing, col_of_interest, window_range::Vector)

    # Function for generating window indexes for absolute time
    window_start, window_end = window_range
    window_idx = (window_start .<= col_of_interest .<= window_end)

    return(window_idx)
end