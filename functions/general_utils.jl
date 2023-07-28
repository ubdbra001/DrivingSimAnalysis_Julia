
function check_and_create_dir(path_in::String)
    if !isdir(path_in)
        mkpath(path_in)
    end
end