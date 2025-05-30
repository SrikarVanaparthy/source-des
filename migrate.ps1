param (
    [Parameter(Mandatory = $true)][string]$SourceUser,
    [Parameter(Mandatory = $true)][string]$SourceHost,
    [Parameter(Mandatory = $true)][string]$DestinationUser,
    [Parameter(Mandatory = $true)][string]$DestinationHost,
    [Parameter(Mandatory = $true)][string]$CsvFilePath,
    [Parameter(Mandatory = $true)][string]$TargetPath
)

function Run-Command {
    param (
        [string]$Command,
        [string]$Description
    )

    Write-Host "`n$Description" -ForegroundColor Cyan
    try {
        $output = Invoke-Expression $Command
        Write-Output $output
    }
    catch {
        Write-Host "❌ Error executing: $Command" -ForegroundColor Red
        Write-Error $_.Exception.Message
        exit 1
    }
}

# Step 1: List users on source host
$logUsersCommand = "ssh -o StrictHostKeyChecking=no $SourceUser@$SourceHost who"
Run-Command -Command $logUsersCommand -Description "📋 Logging into source VM to list current users..."

# Step 2: SCP command
$scpCommand = "scp -o StrictHostKeyChecking=no $CsvFilePath ${DestinationUser}@${DestinationHost}:$TargetPath"

# Step 3: Run SCP remotely via SSH
$sshSCPCommand = "ssh -o StrictHostKeyChecking=no ${SourceUser}@${SourceHost} '$scpCommand'"
Run-Command -Command $sshSCPCommand -Description "🚚 Executing remote SCP via SSH from source to destination..."
