# This script processes PDF files in a specified input folder, creating OCR (Optical Character Recognition) versions 
# in an output folder. It uses ocrmypdf to add a searchable text layer to PDFs, skipping any files that have 
# already been processed or are larger than 10 megapixels. The script maintains the original filename with '_OCR' appended.

#!/bin/bash

# Define the input and output folder paths
input_folder='some_file_path'
output_folder='some_file_path'

# Create the output folder if it doesn't exist
mkdir -p "$output_folder"

# Loop through all PDF files in the input folder
for file in "$input_folder"/*.pdf; do
    # Extract the base name of the file (without extension)
    base_name=$(basename "$file" .pdf)
    # Define the output file path
    output_file="$output_folder/${base_name}_OCR.pdf"
    
    # Check if the output file already exists
    if [ -f "$output_file" ]; then
        echo "Skipping: $output_file already exists."
        continue
    fi
    
    # Run ocrmypdf on the file with force-ocr flag and skip files larger than 250 megapixels
    ocrmypdf --force-ocr --skip-big 10 "$file" "$output_file"
    echo "Processed: $file -> $output_file"
done
