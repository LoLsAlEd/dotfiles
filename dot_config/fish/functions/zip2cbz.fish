function zip2cbz --description "Convert .zip files to .cbz in the current directory"
    # Find all .zip files in the current directory (case-sensitive glob)
    set -l zip_files *.zip

    # --- Color Definitions (using fish theme variables for better adaptability) ---
    set -l c_normal (set_color normal)
    set -l c_header (set_color blue --bold) # Or use $fish_color_autosuggestion or similar
    set -l c_file_old (set_color $fish_color_param)
    set -l c_file_new (set_color $fish_color_command) # Often a distinct color for commands/targets
    set -l c_arrow (set_color $fish_color_operator)
    set -l c_warning_header (set_color $fish_color_warning --bold)
    set -l c_warning_file (set_color $fish_color_warning)
    set -l c_prompt (set_color $fish_color_autosuggestion) # A gentle color for prompts
    set -l c_success (set_color $fish_color_good --bold)
    set -l c_error (set_color $fish_color_error --bold)
    set -l c_error_msg (set_color $fish_color_error)
    set -l c_info (set_color $fish_color_comment) # For general info like "No files" or "Cancelled"

    # Check if any .zip files exist (handles case where glob doesn't match)
    if test (count $zip_files) -eq 0; or test "$zip_files" = "*.zip"
        echo $c_info"No .zip files found in the current directory."$c_normal
        return 1
    end

    echo $c_header"The following files will be converted from .zip to .cbz:"$c_normal
    for file in $zip_files
        set -l cbz_preview (string replace -ri '\.zip$' '.cbz' $file) # -i for consistent preview
        echo "  • "$c_file_old$file$c_normal" "$c_arrow"→"$c_normal" "$c_file_new$cbz_preview$c_normal
    end

    # Check for potential overwrites of existing .cbz files
    set -l overwrite_files
    for file in $zip_files
        # Use -i for case-insensitive replacement for the check, matching the final rename
        set -l cbz_file (string replace -ri '\.zip$' '.cbz' $file)
        if test -e $cbz_file
            set -a overwrite_files $cbz_file
        end
    end

    # Warn about overwrites if necessary
    if test (count $overwrite_files) -gt 0
        echo ""
        echo $c_warning_header"Warning: The following .cbz files already exist and will be overwritten:"$c_normal
        for file in $overwrite_files
            echo "  • "$c_warning_file$file$c_normal
        end
    end

    # Ask for confirmation
    echo ""
    # The -P prompt string in read is often colored by the terminal/fish itself,
    # but we can color the text part if desired.
    read -l -P $c_prompt"Do you want to proceed with the conversion? (y/n) "$c_normal confirm

    switch $confirm
        case y Y yes Yes YES
            # Perform the renaming
            for file in $zip_files
                # Calculate the target .cbz filename (case-insensitive replacement)
                set -l cbz_file (string replace -ri '\.zip$' '.cbz' $file)
                echo -n "Converting: "$c_file_old$file$c_normal" "$c_arrow"→"$c_normal" "$c_file_new$cbz_file$c_normal"..."

                if mv $file $cbz_file
                    echo $c_success" Done."$c_normal
                else
                    echo $c_error" FAILED!"$c_normal
                    echo $c_error_msg"Error converting $file (exit status: $status). Aborting."$c_normal
                    return 1
                end
            end
            echo $c_success"Conversion complete."$c_normal
        case '*'
            echo $c_info"Conversion cancelled."$c_normal
            return 0
    end
end
