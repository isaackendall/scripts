# This script processes PDF files in a specified input folder, creating OCR (Optical Character Recognition) versions 
# in an output folder. It uses ocrmypdf to add a searchable text layer to PDFs, skipping any files that have 
# already been processed or are larger than 10 megapixels. The script maintains the original filename with '_OCR' appended.

#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -i <input_folder> -o <output_folder> [-m <max_megapixels>]"
    echo "  -i: Input folder containing PDF files"
    echo "  -o: Output folder for OCR'd PDFs"
    echo "  -m: Maximum megapixels (default: 10)"
    echo "  -h: Display this help message"
    exit 1
}

# Default values
max_megapixels=10

# Parse command line arguments
while getopts "i:o:m:h" opt; do
    case $opt in
        i) input_folder="$OPTARG";;
        o) output_folder="$OPTARG";;
        m) max_megapixels="$OPTARG";;
        h) usage;;
        \?) usage;;
    esac
done

# Check if required arguments are provided
if [ -z "$input_folder" ] || [ -z "$output_folder" ]; then
    echo "Error: Input and output folders are required"
    usage
fi

# Validate input folder exists and contains PDFs
if [ ! -d "$input_folder" ]; then
    echo "Error: Input folder '$input_folder' does not exist"
    exit 1
fi

if ! ls "$input_folder"/*.pdf 1> /dev/null 2>&1; then
    echo "Error: No PDF files found in input folder '$input_folder'"
    exit 1
fi

# Create the output folder if it doesn't exist
if ! mkdir -p "$output_folder"; then
    echo "Error: Failed to create output folder '$output_folder'"
    exit 1
fi

# Counter for processed files
processed=0
skipped=0
failed=0

# Loop through all PDF files in the input folder
for file in "$input_folder"/*.pdf; do
    # Extract the base name of the file (without extension)
    base_name=$(basename "$file" .pdf)
    # Define the output file path
    output_file="$output_folder/${base_name}_OCR.pdf"
    
    # Check if the output file already exists
    if [ -f "$output_file" ]; then
        echo "Skipping: $output_file already exists."
        ((skipped++))
        continue
    fi
    
    echo "Processing: $file"
    
    # Run ocrmypdf on the file with force-ocr flag and skip files larger than specified megapixels
    if ocrmypdf --force-ocr --skip-big "$max_megapixels" "$file" "$output_file"; then
        echo "Successfully processed: $file -> $output_file"
        ((processed++))
    else
        echo "Error: Failed to process $file"
        ((failed++))
    fi
done

# Print summary
echo
echo "Processing complete:"
echo "  Successfully processed: $processed files"
echo "  Skipped (already exists): $skipped files"
echo "  Failed: $failed files"
