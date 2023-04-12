# Set the directory path where the files are located
$path = "G:\Other computers\Probook 440\Insightzclub\Ruby\3.0\Materials"

# Get the list of files in the directory
$files = Get-ChildItem $path

# Loop through each file and rename it
foreach ($file in $files) {
    # Get the current filename
    $name = $file.Name
    
    # Use regular expressions to match the number in the filename
    if ($name -match "(\d+)") {
        # Convert the captured number to an integer
        $number = [int]$Matches[1]
        
        # Check if the number is greater than 15
        if ($number > 15) {
            # Increment the number by 1
            $number++
            
            # Build the new filename
            $newName = $name -replace "\d+", $number
            
            # Rename the file
            Rename-Item -Path $file.FullName -NewName $newName
        }
    }
}