# This is all acceleration proccessing stuff 
a = round.(diff(windowed_df.Longit_velocity_fps) ./ diff(windowed_df.Elapsed_time_s), digits = 3)
gauss_ker = ImageFiltering.Kernel.gaussian((2,))
filt_a = imfilter(a, gauss_ker)

b = round.(windowed_df.Elapsed_time_s[2:end] .- crossover_time; digits = 3) 

plot(b,filt_a, label = missing, xticks = -10:1:1)