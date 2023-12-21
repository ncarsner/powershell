# Define the directory path as a parameter
param (
    [string]$directoryPath = "C:\Directory"
)

# Define the log file path within the directory path
$logFilePath = Join-Path $directoryPath "RemoveEmptyFoldersLog.txt"

function Write-Log {
    param (
        [string]$message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$($timestamp): $message" | Out-File -FilePath $logFilePath -Append
}


function Remove-EmptyFolders {
    param (
        [string]$path
    )

    # Recursively get all directories from the specified path
    $directories = Get-ChildItem -Path $path -Recurse -Directory | Sort-Object FullName -Descending

    foreach ($directory in $directories) {
        Remove-EmptyDirectory -path $directory.FullName
    }

    # Re-evaluate the root path
    Remove-EmptyDirectory -path $path
}

function Remove-EmptyDirectory {
    param (
        [string]$path
    )

    if (Test-Path $path) {
        $files = Get-ChildItem $path -File -ErrorAction SilentlyContinue
        $subDirs = Get-ChildItem $path -Directory -ErrorAction SilentlyContinue

        if ($files.Count -eq 0 -and $subDirs.Count -eq 0) {
            Remove-Item $path -Force
            Write-Host "Removing empty folder: $path"
            Write-Log "Removing empty folder: $path"
        }
    }
}

# Start of the script
Write-Log "Script started for directory: $directoryPath"

# Call the function with the specified directory
Remove-EmptyFolders -path $directoryPath

# End of the script
Write-Log "Script completed for directory: $directoryPath"
