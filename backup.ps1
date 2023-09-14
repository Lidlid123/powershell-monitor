# Define the source and target directories
$sourceDir = "C:\\path\\to\\your\\source\\directory"
$targetDir = "C:\\path\\to\\your\\target\\directory"

# Get the current date and time
$date = Get-Date -Format "yyyyMMdd-HHmmss"

# Define the backup file with timestamp
$backupFile = "$targetDir\\backup-$date.zip"

# Create a backup by copying all files from source to target
Copy-Item -Path $sourceDir -Destination $targetDir -Recurse -Force

# Compress the backup directory
Compress-Archive -Path $targetDir -DestinationPath $backupFile

# Define the FTP parameters
$ftpServer = "your-ftp-server"
$ftpUser = "your-ftp-username"
$ftpPassword = "your-ftp-password"
$ftpURL = "ftp://$ftpUser:$ftpPassword@$ftpServer"

# Create a temporary file with the FTP commands
$ftpCommands = @"
open $ftpServer
user $ftpUser $ftpPassword
binary
put $backupFile
quit
"@
$ftpCommands | Out-File -FilePath "C:\\path\\to\\your\\ftp\\commands.txt"

# Upload the backup to the FTP server
ftp -s:"C:\\path\\to\\your\\ftp\\commands.txt"

# Delete the temporary file
Remove-Item -Path "C:\\path\\to\\your\\ftp\\commands.txt"
