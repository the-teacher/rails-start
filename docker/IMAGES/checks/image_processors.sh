# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# TEST IMAGE PROCESSORS
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Color output function
# Usage: color_log "message" "color"
# Colors: green, orange, blue, red
color_log() {
    local message="$1"
    local color="$2"

    case "$color" in
        green)  echo -e "\033[0;32m$message\033[0m" ;;
        orange) echo -e "\033[0;33m$message\033[0m" ;;
        blue)   echo -e "\033[0;34m$message\033[0m" ;;
        red)    echo -e "\033[0;31m$message\033[0m" ;;
        *)      echo "$message" ;;
    esac
}

# Print newline
newline() {
    echo ""
}

# Print section header
# Usage: section_header "title" "color"
section_header() {
    local title="$1"
    local color="$2"
    local line="=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

    newline
    color_log "$line" "$color"
    color_log "$title" "$color"
    color_log "$line" "$color"
}

# Print subsection header
# Usage: subsection_header "title" "color"
subsection_header() {
    local title="$1"
    local color="$2"
    local line="=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

    newline
    color_log "$line" "$color"
    color_log "$title" "$color"
    color_log "$line" "$color"
}

# Test counter
test_counter=0

# Print test message
# Usage: test_message "message"
test_message() {
    local message="$1"
    test_counter=$((test_counter + 1))
    color_log "$test_counter. Testing $message..." "blue"
}

# Calculate percentage
# Usage: calculate_percentage part total
calculate_percentage() {
    local part="$1"
    local total="$2"
    echo $(( (part * 100) / total ))
}

# Calculate compression percentage
# Usage: calculate_compression_percentage original_size compressed_size
calculate_compression_percentage() {
    local original="$1"
    local compressed="$2"
    local compressed_percentage=$(calculate_percentage "$compressed" "$original")
    echo $((100 - compressed_percentage))
}

# Print compression ratio
# Usage: print_compression_ratio original_size compressed_size
print_compression_ratio() {
    local original="$1"
    local compressed="$2"
    local ratio=$(calculate_compression_percentage "$original" "$compressed")
    color_log "(${ratio}%)" "red"
}

# Print test result
# Usage: test_result "message" original_size compressed_size
test_result() {
    local message="$1"
    local original="$2"
    local compressed="$3"

    echo "$message"
    if [ -n "$original" ] && [ -n "$compressed" ]; then
        print_compression_ratio "$original" "$compressed"
    fi
}

# Statistics structure
declare -A STATS=()

# Add test result to statistics
# Usage: add_stats "processor" "image" "original_size" "compressed_size"
add_stats() {
    local processor="$1"
    local image="$2"
    local original="$3"
    local compressed="$4"
    local ratio=$(calculate_compression_percentage "$original" "$compressed")
    
    STATS["${processor}_image"]="$image"
    STATS["${processor}_original"]="$original"
    STATS["${processor}_compressed"]="$compressed"
    STATS["${processor}_ratio"]="$ratio"
}

# Print statistics
# Usage: print_stats
print_stats() {
    section_header "Compression Statistics:" "orange"
    
    # JPEG Processors
    subsection_header "JPEG Processors:" "green"
    print_processor_stats "jpeg-recompress"
    print_processor_stats "jpegoptim"
    print_processor_stats "jpegtran"
    print_processor_stats "jhead"
    
    # PNG Processors
    subsection_header "PNG Processors:" "green"
    print_processor_stats "advpng"
    print_processor_stats "oxipng"
    print_processor_stats "optipng"
    print_processor_stats "pngquant"
    print_processor_stats "pngcrush"
    print_processor_stats "pngout"
    
    # GIF Processor
    subsection_header "GIF Processor:" "green"
    print_processor_stats "gifsicle"

    # WebP Processor
    subsection_header "WebP Processor:" "green"
    print_processor_stats "cwebp"

    # SVG Processor
    subsection_header "SVG Processor:" "green"
    print_processor_stats "svgo"
    
    # ImageMagick
    subsection_header "ImageMagick:" "green"
    print_processor_stats "ImageMagick convert"
}

# Print single processor statistics
# Usage: print_processor_stats "processor"
print_processor_stats() {
    local processor="$1"
    local image="${STATS[${processor}_image]}"
    local original="${STATS[${processor}_original]}"
    local compressed="${STATS[${processor}_compressed]}"
    local ratio="${STATS[${processor}_ratio]}"
    
    color_log "$processor:" "blue"
    color_log "   image: $image" "default"
    color_log "   original size: $original bytes" "default"
    color_log "   compressed size: $compressed bytes" "default"
    color_log "   compression: " "default"
    color_log "${ratio}%" "red"
    newline
}

# Test image processor
# Usage: test_processor "processor_name" "input_file" "output_file" "command"
test_processor() {
    local processor="$1"
    local input_file="$2"
    local output_file="$3"
    local command="$4"
    
    test_message "$processor"
    cp "$input_file" "$output_file"
    original_size=$(stat -c%s "$output_file")
    test_result "Original size: $original_size bytes"
    eval "$command"
    compressed_size=$(stat -c%s "$output_file")
    test_result "Compressed size: $compressed_size bytes" "$original_size" "$compressed_size"
    
    # Add to statistics
    add_stats "$processor" "$(basename "$input_file")" "$original_size" "$compressed_size"
}

# Test package version
# Usage: test_version "package_name" "version_command"
test_version() {
    local package="$1"
    local command="$2"

    color_log "Testing $package version:" "blue"
    eval "$command" | head -n 3
    newline
}

# Define script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="${SCRIPT_DIR}/img_test"

section_header "Testing Image Processors:" "orange"

# Create local directory for tests
mkdir -p "${TEST_DIR}"
cd "${TEST_DIR}"

# Download test images
color_log "Downloading test images..." "blue"
# size: 196684
wget -O test-start-kit.jpg https://raw.githubusercontent.com/the-teacher/rails-start/RAILS_7_STARTKIT/Rails7StartKit/assets/logos/Rails7.StartKit.jpg
# size: 124033
wget -O test-thinking-sphinx.png https://raw.githubusercontent.com/the-teacher/rails-start/RAILS_7_STARTKIT/Rails7StartKit/assets/images/thinking-sphinx.png
# size: 4888813
wget -O test-cat.gif https://media.tenor.com/yLjbMCoTu3UAAAAd/cat-pounce.gif
# Download Ruby SVG image
wget -O test-ruby.svg https://www.svgrepo.com/show/452095/ruby.svg

echo "Original file sizes:"
ls -lh test-*.{jpg,png,gif,svg}

# Test JPEG processors
subsection_header "Testing JPEG processors:" "green"

test_processor "jpeg-recompress" \
              "test-start-kit.jpg" \
              "start-kit.jpg" \
              "jpeg-recompress --strip start-kit.jpg start-kit.jpg"

test_processor "jpegoptim" \
              "test-start-kit.jpg" \
              "start-kit.jpg" \
              "jpegoptim --strip-all start-kit.jpg"

test_processor "jpegtran" \
              "test-start-kit.jpg" \
              "start-kit.jpg" \
              "jpegtran -verbose -optimize -outfile start-kit.jpg start-kit.jpg"

test_processor "jhead" \
              "test-start-kit.jpg" \
              "start-kit.jpg" \
              "jhead -purejpg -di -dt -dx start-kit.jpg"

# Test PNG processors
subsection_header "Testing PNG processors:" "green"

test_processor "advpng" \
              "test-thinking-sphinx.png" \
              "thinking-sphinx.png" \
              "advpng --recompress --shrink-normal thinking-sphinx.png"

test_processor "oxipng" \
              "test-thinking-sphinx.png" \
              "thinking-sphinx.png" \
              "oxipng -o 3 --strip all thinking-sphinx.png"

test_processor "optipng" \
              "test-thinking-sphinx.png" \
              "thinking-sphinx.png" \
              "optipng thinking-sphinx.png"

test_processor "pngquant" \
              "test-thinking-sphinx.png" \
              "thinking-sphinx.png" \
              "pngquant --speed 4 --verbose --force --output thinking-sphinx.png thinking-sphinx.png"

test_processor "pngcrush" \
              "test-thinking-sphinx.png" \
              "thinking-sphinx.png" \
              "pngcrush thinking-sphinx.png thinking-sphinx.png -ow"

test_processor "pngout" \
              "test-thinking-sphinx.png" \
              "thinking-sphinx.png" \
              "pngout thinking-sphinx.png thinking-sphinx.png -s2 -y"

# Test GIF processor
subsection_header "Testing GIF processor:" "green"

test_processor "gifsicle" \
              "test-cat.gif" \
              "cat.gif" \
              "gifsicle -O3 --colors 256 --lossy=30 cat.gif -o cat.gif"

# Test WebP processor
subsection_header "Testing WebP processor:" "green"

test_processor "cwebp" \
              "test-start-kit.jpg" \
              "start-kit.webp" \
              "cwebp -q 80 start-kit.jpg -o start-kit.webp"

# Test SVG processor
subsection_header "Testing SVG processor:" "green"

test_processor "svgo" \
              "test-ruby.svg" \
              "ruby.svg" \
              "svgo -i ruby.svg -o ruby.svg --multipass"

# Test ImageMagick
subsection_header "Testing ImageMagick:" "green"

test_processor "ImageMagick convert" \
              "test-start-kit.jpg" \
              "start-kit.jpg" \
              "convert start-kit.jpg -strip -quality 85 start-kit.jpg"

# Final results
section_header "Final Results:" "orange"
ls -lh "${TEST_DIR}"

# Print statistics
print_stats

# Cleanup
color_log "Cleaning up..." "blue"
rm -rf "${TEST_DIR}"/*

# Return to original directory
cd "${SCRIPT_DIR}"

echo "Testing completed. All temporary files have been removed."

# Print versions of all installed image processors
section_header "Installed Image Processors Versions:" "orange"

subsection_header "JPEG Processors:" "green"
test_version "jpeg-recompress" "jpeg-recompress --version"
test_version "jpegoptim" "jpegoptim --version"
test_version "jpegtran" "jpegtran -V 0"
test_version "jhead" "jhead -V"

subsection_header "PNG Processors:" "green"
test_version "advpng" "advpng --version"
test_version "oxipng" "oxipng --version"
test_version "optipng" "optipng --version"
test_version "pngquant" "pngquant --version"
test_version "pngcrush" "pngcrush --version"
test_version "pngout" "pngout --version"

subsection_header "GIF Processor:" "green"
test_version "gifsicle" "gifsicle --version"

subsection_header "WebP Processor:" "green"
test_version "cwebp" "cwebp -version"

subsection_header "SVG Processor:" "green"
test_version "svgo" "svgo --version"

subsection_header "ImageMagick:" "green"
test_version "ImageMagick" "magick --version"

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Compression Statistics:
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# JPEG Processors:
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# jpeg-recompress:
#    image: test-start-kit.jpg
#    original size: 196684 bytes
#    compressed size: 58910 bytes
#    compression: 71%

# jpegoptim:
#    image: test-start-kit.jpg
#    original size: 196684 bytes
#    compressed size: 180158 bytes
#    compression: 9%

# jpegtran:
#    image: test-start-kit.jpg
#    original size: 196684 bytes
#    compressed size: 180176 bytes
#    compression: 9%

# jhead:
#    image: test-start-kit.jpg
#    original size: 196684 bytes
#    compressed size: 196684 bytes
#    compression: 0%

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# PNG Processors:
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# advpng:
#    image: test-thinking-sphinx.png
#    original size: 124033 bytes
#    compressed size: 46171 bytes
#    compression: 63%

# oxipng:
#    image: test-thinking-sphinx.png
#    original size: 124033 bytes
#    compressed size: 43141 bytes
#    compression: 66%

# optipng:
#    image: test-thinking-sphinx.png
#    original size: 124033 bytes
#    compressed size: 51602 bytes
#    compression: 59%

# pngquant:
#    image: test-thinking-sphinx.png
#    original size: 124033 bytes
#    compressed size: 21670 bytes
#    compression: 83%

# pngcrush:
#    image: test-thinking-sphinx.png
#    original size: 124033 bytes
#    compressed size: 52084 bytes
#    compression: 59%

# pngout:
#    image: test-thinking-sphinx.png
#    original size: 124033 bytes
#    compressed size: 100777 bytes
#    compression: 19%

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# GIF Processor:
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# gifsicle:
#    image: test-cat.gif
#    original size: 4888813 bytes
#    compressed size: 4888813 bytes
#    compression: 22%

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# WebP Processor:
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# cwebp:
#    image: test-start-kit.jpg
#    original size: 196684 bytes
#    compressed size: 23974 bytes
#    compression: 88%

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# SVG Processor:
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# svgo:
#    image: test-ruby.svg
#    original size: 8580 bytes
#    compressed size: 6807 bytes
#    compression: 21%

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# ImageMagick:
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# ImageMagick convert:
#    image: test-start-kit.jpg
#    original size: 196684 bytes
#    compressed size: 58563 bytes
#    compression: 71%
