# DCD Driving simulator analysis scripts

## Scripts

Four scripts for gathering and anlysing the data:
- `00_get_data_from_osf.jl` - Downloads and extracts the data ready for processing
- `01_process_raw_data.jl` - Converts the raw data for each participant to two files:
    1. A file containing only the data for the participant (in the `driver_data` dir)
    2. A file containng the data for all of the virtual cars in the simulation (in the `other_vehicle_data` dir`)
- `02_extract_windows.jl` - This extracts segments of the data from the full data file, as specified in the `window_details.toml` file
- `03_extract_acceleration.jl` - This takes the windowed data extracted, estimates the 1st and 2nd derivatives of velocity (acceleration and jerk respectively), and creates summary statistics for each participant 

## Usage

Created using Julia v1.6.6, it may run on later versions but has not been tested. You can use `juliaup` to manage versions of `julia`, [see here for more infomation](https://github.com/JuliaLang/juliaup).

If you'd just like to run a script then the `--project` flag will run the script in the `DrivingSimAnalysis` project with all the right dependencies. e.g.:
```
julia --project 00_get_data_from_osf.jl
```