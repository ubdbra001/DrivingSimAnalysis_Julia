using Downloads, ZipFile

retain_zip = true

# URL for data from OSF
url = "https://files.de-1.osf.io/v1/resources/frv29/providers/osfstorage/5fd8d12c0694b703e2f36c69/?zip="
temp_path = "data/Download.zip"
out_path = "data/raw_data2/"

# Open IOStream and stream download into file
open(temp_path, "w") do f
    Downloads.download(url, f)
end

# Once downloaded extract to raw_data dir using zipfile package 

# Read contents of the zip file
zarchive = ZipFile.Reader(temp_path)

# Run through each zipped file and write to raw_data dir
for file in zarchive.files
    fullFilePath = joinpath(out_path,file.name)
    write(fullFilePath, read(file))
end

# Close the zip file
close(zarchive)

# Only delete the zip file if retain_zip is false
if !retain_zip
    rm(temp_path)
end