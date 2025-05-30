param (
    [string]$SourceUser,
    [string]$SourceHost,
    [string]$DestinationUser,
    [string]$DestinationHost,
    [string]$CsvFilePath,
    [string]$TargetPath
)

function Run-Command {
    param (
        [string]$Command,
        [string]$Description
    )

    Write-Host "`n$Description" -ForegroundColor Cyan
    try {
        # Use cmd to make sure Unix-style syntax is preserved in Windows
        $output = & cmd.exe /c $Command 2>&1
        Write-Output $output
    }
    catch {
        Write-Host "❌ Error executing: $Command" -ForegroundColor Red
        Write-Error $_.Exception.Message
    }
}

# Step 1: List currently logged-in users on the source host
$logUsersCommand = "ssh -o StrictHostKeyChecking=no $SourceUser@$SourceHost who"
Run-Command -Command $logUsersCommand -Description "📋 Logging into source VM to list current users..."

# Step 2: Compose the SCP command to copy the CSV file from the source VM to the destination VM
$scpCommand = "scp -o StrictHostKeyChecking=no $CsvFilePath ${DestinationUser}@${DestinationHost}:$TargetPath"

# Step 3: Wrap the SCP command inside SSH so that it's run remotely on the source VM
$sshSCPCommand = "ssh -o StrictHostKeyChecking=no ${SourceUser}@${SourceHost} `"${scpCommand}`""

Run-Command -Command $sshSCPCommand -Description "🚚 Executing remote SCP via SSH from source to destination..."
