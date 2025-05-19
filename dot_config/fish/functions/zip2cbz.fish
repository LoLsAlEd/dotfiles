function zip2cbz --description "Convert .zip files to .cbz in the current directory"
    # Find all .zip files in the current directory
    set -l zip_files *.zip
    
    # Check if any .zip files exist
    if test (count $zip_files) -eq 0; or test "$zip_files" = "*.zip"
        echo "No .zip files found in the current directory."
        return 1
    end
    
    echo "The following files will be converted from .zip to .cbz:"
    for file in $zip_files
        echo "  • $file → "(string replace -r '\.zip$' '.cbz' $file)
    end
    
    # Check for potential overwrites
    set -l overwrite_files
    for file in $zip_files
        set -l cbz_file (string replace -r '\.zip$' '.cbz' $file)
        if test -e $cbz_file
            set -a overwrite_files $cbz_file
        end
    end
    
    # Warn about overwrites if necessary
    if test (count $overwrite_files) -gt 0
        echo ""
        echo "Warning: The following .cbz files already exist and will be overwritten:"
        for file in $overwrite_files
            echo "  • $file"
        end
    end
    
    # Ask for confirmation
    echo ""
    read -l -P "Do you want to proceed with the conversion? (y/n) " confirm
    
    switch $confirm
        case y Y yes Yes YES
            # Perform the renaming
            for file in $zip_files
                set -l cbz_file (string replace -r '\.zip$' '.cbz' $file)
                mv $file $cbz_file
                echo "Converted: $file → $cbz_file"
            end
            echo "Conversion complete."
        case '*'
            echo "Conversion cancelled."
            return 0
    end
end
