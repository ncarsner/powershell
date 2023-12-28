# Log n oldest files and n oldest subfolders in a directory
# based on last modified time (for files) or last modified date (for folders)

# Specify the directory path
$directoryPath = "C:\Directory"

# Quantify the number of oldest files and folders
$n_items = 20


# Get logfile date
$runTime = (Get-Date -Format "yyyyMMdd_HHmmss")

# Create the log file path in the same directory
$logFileName = "aged_files_log$writeDate.txt"
$logFilePath = Join-Path -Path $directoryPath -ChildPath $logFileName

# Create log files in a specific directory
$logFileLocalPath = "C:\Users\User\Documents"
$logFilePath = Join-Path -Path $logFileLocalPath -ChildPath $logFileName



# Function to get the most recent 'last modified' date (excluding time) in a folder
function Get-LastModifiedDate {
    param ($folderPath)
    $mostRecentFile = Get-ChildItem -Path $folderPath -Recurse -File |
                      Sort-Object { $_.LastWriteTime.Date } -Descending |
                      Select-Object -First 1
    if ($mostRecentFile -ne $null) {
        return $mostRecentFile.LastWriteTime.Date
    } else {
        return $null
    }
}

Add-Content -Path $logFilePath -Value "Oldest $n_items files:`n"

# Log the n oldest files with specific datetime timestamp
Get-ChildItem -Path $directoryPath -Recurse -File |
    Sort-Object LastWriteTime |
    Select-Object -First $n_items |
    ForEach-Object {
        $relativePath = $_.FullName.Substring($directoryPath.Length + 1)
        #$fileInfo = "File: $relativePath - Last Modified: $($_.LastWriteTime)" # item name - modified date
        $fileInfo = "Last Modified: $($_.LastWriteTime) - File: $relativePath" # modified date - item name
        Add-Content -Path $logFilePath -Value $fileInfo
    }


Add-Content -Path $logFilePath -Value "`nOldest $n_items folders:`n"

# Log the n oldest subfolders with only the date
Get-ChildItem -Path $directoryPath -Directory |
    Select-Object @{Name='RelativePath';
        Expression={$_.FullName.Substring($directoryPath.Length + 1)}},
            @{Name='LastModified';
        Expression={Get-LastModifiedDate $_.FullName}} |
    Where-Object { $_.LastModified -ne $null } |
    Sort-Object LastModified |
    Select-Object -First $n_items |
    ForEach-Object {
        #$folderInfo = "Folder: $($_.RelativePath) - Last Modified: $($_.LastModified.ToString('yyyy-MM-dd'))" # item name - modified date
        $folderInfo = "Last Modified: $($_.LastModified.ToString('yyyy-MM-dd')) - Folder: $($_.RelativePath)" # modified date - item name
        Add-Content -Path $logFilePath -Value $folderInfo
    }

# Output to console
Write-Host "The $n_items oldest files and folders (by last modified date)`nfrom '$directoryPath'`nlogged to '$logFilePath'."
Add-Content -Path $logFilePath -Value "`nThe $n_items oldest files and folders (by last modified date)`nfrom '$directoryPath'`nlogged to '$logFilePath'`n"