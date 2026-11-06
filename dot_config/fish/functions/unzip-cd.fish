function unzip-cd --argument zipfile
    if test (count $argv) -ne 1; or not string match --quiet '*.zip' -- "$zipfile"
        echo (status function)': argument must be a zipfile' >&2
        return 1
    end
    set --local target (is-clean-zip "$zipfile")
    set --local layout_status $status
    switch $layout_status
        case 1
            set target (string replace --regex '\.zip$' '' -- (command basename "$zipfile"))
        case 0
        case '*'
            return $layout_status
    end
    clean-unzip "$zipfile"
    and cd -- "$target"
end
