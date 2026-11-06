function is-clean-zip --argument zipfile --description 'Print the enclosing directory when a ZIP has a single directory root'
    if test (count $argv) -ne 1
        return 2
    end

    set --local archive "$zipfile"
    if not string match --quiet '/*' -- "$archive"
        set archive "./$archive"
    end
    set --local entries (command unzip -Z -1 "$archive")
    or return 2
    if not set --query entries[1]
        return 2
    end

    set --local root
    for entry in $entries
        set entry (string replace --regex '^(\./)+' '' -- "$entry")
        set --local parts (string split --max 1 / -- "$entry")
        if test (count $parts) -ne 2
            return 1
        end
        if not set --query root[1]
            set root "$parts[1]"
        end
        if test -z "$root"; or test "$root" = .; or test "$root" = ..; or test "$parts[1]" != "$root"
            return 1
        end
    end

    printf '%s\n' "$root"
end
