# Define the source directory
$sourceDirectory = "C:\Directory"

# Initialize an array to store log messages
$logMessages = @()

# Loop through each file in the source directory
Get-ChildItem -Path $sourceDirectory | ForEach-Object {
    $file = $_
    # Check if it's a file (not a directory)
    if ($file.PSIsContainer -eq $false) {
        # Get the file name without extension
        $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        
        # Create a folder with the same name as the file (if it doesn't exist)
        $folderName = Join-Path -Path $sourceDirectory -ChildPath $fileNameWithoutExtension
        if (-not (Test-Path -Path $folderName -PathType Container)) {
            New-Item -Path $folderName -ItemType Directory
            $logMessages += "Created folder '$folderName' for file '$fileNameWithoutExtension'"
        }
        
        # Move the file into its corresponding folder
        $newPath = Join-Path -Path $folderName -ChildPath $file.Name
        Move-Item -Path $file.FullName -Destination $newPath -Force
        $logMessages += "Moved file '$file.Name' to '$newPath'"
    }
}

# Write log messages to a log file in the source directory
$logFile = Join-Path -Path $sourceDirectory -ChildPath "file_moving_log.txt"
$logMessages | Out-File -FilePath $logFile

# Output log file path
$logFile
