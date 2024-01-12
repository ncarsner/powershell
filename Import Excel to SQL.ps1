<##### IMPORT MODULES #####>

# Import the Excel module
Import-Module ImportExcel

# Import the SqlServer module
Import-Module SqlServer



<##### DEFINE SOURCE FILE #####>

# Define the path to the Excel file and the name of the worksheet
$excelPath = "C:\excelFile.xlsx"
$worksheetName = "Sheet1"

# Extract the directory from the Excel file path
$excelDirectory = [System.IO.Path]::GetDirectoryName($excelPath)

# Check the number of sheets in the workbook
$sheets = Import-Excel -Path $excelPath -ListSheets

# If there's only one sheet, import data from that sheet
if ($sheets.Count -eq 1) {
    $data = Import-Excel -Path $excelPath
} else {
    Write-Host "More than one worksheet found. Please specify the worksheet name."
    # Optionally, specify a default sheet name or handle this scenario as needed.
    # $worksheetName = "YourDefaultSheetName"
    $data = Import-Excel -Path $excelPath -WorksheetName $worksheetName
}



<##### DEFINE LOG FILE #####>

# Define log file path to be in the same directory as the Excel file
$logFile = Join-Path $excelDirectory "log.txt"



<##### DEFINE CONFIGURATION AND ENVIRONMENT VARIABLES  #####>

# Define path to the connection credentials file
$credentialFilePath = "C:\config.txt"

# Read credentials from the file
$credentials = @{}
Get-Content $credentialFilePath | ForEach-Object {
    $split = $_ -split '='
    if ($split.Count -eq 2) {
        $credentials[$split[0].Trim()] = $split[1].Trim()
    }
}

# Define SQL Server connection details
$serverName = $credentials["ServerName"]
$databaseName = $credentials["DatabaseName"]
$tableName = "YourTableName"
$username = $credentials["Username"]
$password = $credentials["Password"]

# Build the connection string
$connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=True;"
#$connectionString = "Server=$serverName;Database=$databaseName;User Id=$username;Password=$password;"

# Define the structure of the table - Column names and data types
$tableStructure = @{
    "Column1" = "nvarchar(50)"
    "Column2" = "int"
    "Column3" = "datetime"
    "Column4" = "numeric (18,2)"
    # Add more columns as needed
}



<##### DEFINE FUNCTIONS #####>

# Function to log messages
function Write-Log {
    param ([string]$message)

    Add-Content -Path $logFile -Value "$(Get-Date) - $message"
}


# Function to create table if it does not exist
function Create-SqlTable {
    param (
        [string]$tableName,
        [hashtable]$columns,
        [string]$connectionString
    )
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = $connectionString
        $connection.Open()

        $command = $connection.CreateCommand()
        $command.CommandText = "IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$tableName') " +
                               "BEGIN " +
                               "CREATE TABLE $tableName ("

        $columnDefinitions = $columns.GetEnumerator() | ForEach-Object { "$($_.Key) $($_.Value)" }
        $command.CommandText += ($columnDefinitions -join ", ") + ") END"

        $command.ExecuteNonQuery()
        Write-Host "Table '$tableName' created or already exists."
        Write-Log "Table '$tableName' created or already exists."
    } catch {
        Write-Host "Error in Create-SqlTable: $_"
        Write-Log "Error in Create-SqlTable: $_"
        throw
    } finally {
        $connection.Close()
    }
}

# Function to write data to SQL Server with retry logic
function Write-ToSql {
    param (
        [Parameter(Mandatory = $true)]
        [psobject]$data,

        [Parameter(Mandatory = $true)]
        [string]$tableName,

        [Parameter(Mandatory = $true)]
        [string]$connectionString
    )

    $retryCount = 0
    $maxRetries = 5
    $retryInterval = 10

    while ($retryCount -lt $maxRetries) {
        try {
            # Bulk insert logic here...

            Write-Host "Data written to table '$tableName'."
            Write-Log "Data written to table '$tableName'."
            break
        } catch {
            Write-Host "Write-ToSql attempt $retryCount failed: $_"
            Write-Log "Write-ToSql attempt $retryCount failed: $_"
            $retryCount++
            if ($retryCount -eq $maxRetries) {
                Write-Host "Max retry attempts reached. Aborting."
                Write-Log "Max retry attempts reached. Aborting."
                throw
            } else {
                Write-Host "Retrying in $retryInterval seconds..."
                Write-Log "Retrying in $retryInterval seconds..."
                Start-Sleep -Seconds $retryInterval
            }
        }
    }
}


<##### MAIN SCRIPT EXECUTION #####>

try {
    # Create table if not exists
    Create-SqlTable -tableName $tableName -columns $tableStructure -connectionString $connectionString

    # Write data to SQL Server
    Write-ToSql -data $data -tableName $tableName -connectionString $connectionString
} catch {
    Write-Host "Error in main execution: $_"
    Write-Log "Error in main execution: $_"
}
