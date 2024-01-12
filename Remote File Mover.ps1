# Log function
function Write-Log {
    param([string]$message)
    Add-Content -Path $logFile -Value "$(Get-Date) - $message"
}

# Function to handle output based on the preference
function consolePreference {
    param([string]$message)
    switch ($loggingPreference) {
        'Host' {
            Write-Host $message
        }
        'Log' {
            Write-Log $message
        }
        'Both' {
            Write-Host $message
            Write-Log $message
        }
    }
}

# Load configuration variables from config.txt
$config = Get-Content "C:\config.txt" | ConvertFrom-StringData


<################### config.txt #########################
SftpServer=example_sftp_server.com
Username=myusername
Password=mypassword
SftpFilePath=/path/to/sftp/file.txt
RemoteServerPath=\\remote_server\path\to\source
AnotherServerPath=\\another_server\path\to\destination
########################################################>


# Function to send email notification on Failure
function Send-FailureEmail {
    param (
        [string]$errorMessage
    )
    # Implement email sending logic here
}

# Function to send email notification on Success
function Send-SuccessEmail {
    param (
        [string]$successMessage
    )
    # Implement email sending logic here
}

# Function to connect to SFTP
function Connect-SFTP {
    param (
        [string]$SftpServer,
        [string]$Username,
        [string]$Password
    )

    $retryCount = 0
    $maxRetries = 3
    $sleepTime = 5
    while ($retryCount -le $maxRetries ) {
        try {
            # Implement your SFTP connection logic here
            # If connection is successful, break the loop
            break
        } catch {
            $retryCount++
            if ($retryCount -eq 3) {
                Send-FailureEmail -ErrorMessage "Failed to connect to SFTP server after $maxRetries retries"
                throw "Connection to SFTP server failed"
            } else {
                Start-Sleep -Seconds $sleepTime
            }
        }
    }
}

# Function to transfer file from SFTP to remote server
function Transfer-File {
    param (
        [string]$SourcePath,
        [string]$DestinationPath
    )
    try {
        # Implement file transfer logic here
    } catch {
        Send-FailureEmail -ErrorMessage "Failed to transfer file from SFTP to remote server"
        throw "File transfer failed"
    }
}

# Function to copy file from one server to another
function Copy-FileToServer {
    param (
        [string]$SourcePath,
        [string]$DestinationPath
    )
    try {
        # Check if the file exists
        if (Test-Path $SourcePath) {
            # Implement file copy logic here
        } else {
            throw "Source file does not exist"
        }
    } catch {
        Send-FailureEmail -ErrorMessage "Failed to copy file from server to server"
        throw "File copying failed"
    }
}

# Main script execution
try {
    Connect-SFTP -SftpServer $config.SftpServer -Username $config.Username -Password $config.Password
    Transfer-File -SourcePath $config.SftpFilePath -DestinationPath $config.RemoteServerPath
    Copy-FileToServer -SourcePath $config.RemoteServerPath -DestinationPath $config.AnotherServerPath
} catch {
    consolePreference "An error occurred: $_"
}
