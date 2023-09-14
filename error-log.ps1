# Get the most recent errors from the System log
$systemErrors = Get-WinEvent -LogName System -MaxEvents 10 | Where-Object { $_.LevelDisplayName -eq 'Error' }

# Get the most recent errors from the Application log
$appErrors = Get-WinEvent -LogName Application -MaxEvents 10 | Where-Object { $_.LevelDisplayName -eq 'Error' }

# Combine the errors and select the properties to display
$errors = $systemErrors + $appErrors | Select-Object TimeCreated, LevelDisplayName, LogName, Message

# Define a CSS style for the HTML table
$style = @"
<style>
table {
    width: 100%;
    border-collapse: collapse;
}
th {
    background-color: #4CAF50;
    color: white;
}
th, td {
    padding: 15px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}
tr:hover {background-color: #f5f5f5;}
</style>
"@

# Convert the errors to an HTML table
$html = $errors | ConvertTo-Html -Title "System and Application Errors" -Body "<h1>System and Application Errors</h1>" -Head $style

# Output the HTML to a file
$html | Out-File -FilePath errors.html
