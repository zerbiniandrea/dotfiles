function loadenv --description 'Load .env files safely (handles special chars like & in values)'
    set -l file $argv[1]
    if test -z "$file"
        set file .env
    end
    if not test -f "$file"
        echo "File not found: $file" >&2
        return 1
    end
    while read -l line
        # Strip comments and trailing whitespace
        set line (string replace -r '#.*' '' -- $line | string trim)
        # Skip empty lines and lines without =
        test -z "$line" && continue
        string match -q '*=*' -- $line || continue
        set -l key (string split -m 1 '=' -- $line)[1]
        set -l val (string split -m 1 '=' -- $line)[2]
        set -gx $key $val
    end < "$file"
end
