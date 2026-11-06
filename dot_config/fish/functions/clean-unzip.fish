function clean-unzip --argument zipfile
    if test (count $argv) -ne 1; or not string match --quiet '*.zip' -- "$zipfile"
        echo (status function)': argument must be a zipfile' >&2
        return 1
    end

    set --local enclosing_directory (is-clean-zip "$zipfile")
    set --local layout_status $status
    set --local archive "$zipfile"
    if not string match --quiet '/*' -- "$archive"
        set archive "./$archive"
    end
    switch $layout_status
        case 0
            command unzip "$archive"
        case 1
            set --local target (string replace --regex '\.zip$' '' -- (command basename "$zipfile"))
            command mkdir -- "$target"
            or return $status
            command unzip "$archive" -d "$target"
        case '*'
            return $layout_status
    end
end
