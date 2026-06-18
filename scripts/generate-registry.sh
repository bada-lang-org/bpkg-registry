#!/bin/bash
set -e

OUTPUT="registry.json"
LIB_DIR="libraries"

echo "Generating ${OUTPUT} from ${LIB_DIR}/*/info.json ..."

echo '{' > "${OUTPUT}"
echo '  "registry_version": "1.0.0",' >> "${OUTPUT}"
echo '  "libraries": {' >> "${OUTPUT}"

first=true
for dir in "${LIB_DIR}"/*/; do
    [ -d "$dir" ] || continue
    info_file="${dir}info.json"
    [ -f "$info_file" ] || continue

    name=$(jq -r '.name' "$info_file")
    url=$(jq -r '.url' "$info_file")
    version=$(jq -r '.version' "$info_file")
    description=$(jq -r '.description' "$info_file")

    if [ "$first" = true ]; then
        first=false
    else
        echo ',' >> "${OUTPUT}"
    fi

    {
        echo -n "    \"${name}\": {"
        echo -n "\"url\": \"${url}\", "
        echo -n "\"version\": \"${version}\", "
        echo -n "\"description\": \"${description}\""
        echo -n "}"
    } >> "${OUTPUT}"
done

echo '' >> "${OUTPUT}"
echo '  }' >> "${OUTPUT}"
echo '}' >> "${OUTPUT}"

# Pretty print with jq
jq '.' "${OUTPUT}" > "${OUTPUT}.tmp" && mv "${OUTPUT}.tmp" "${OUTPUT}"

echo "✓ ${OUTPUT} generated."
