#!/bin/bash

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Ruby Environment Check Script
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Recent Gem and Bundler versions could found here:
# https://github.com/rubygems/rubygems/releases

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

# Print section header
# Usage: section_header "title" "color"
section_header() {
    local title="$1"
    local color="$2"
    local line="=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

    echo ""
    color_log "$line" "$color"
    color_log "$title" "$color"
    color_log "$line" "$color"
}

# Check Ruby version
check_ruby_version() {
    section_header "Ruby Version" "green"
    ruby --version
}

# Check RubyGems version
check_gem_version() {
    section_header "RubyGems Version" "green"
    gem --version
}

# Check Bundler version
check_bundler_version() {
    section_header "Bundler Version" "green"
    if command -v bundle &> /dev/null; then
        bundle --version
    else
        color_log "Bundler is not installed" "red"
    fi
}

# Check Rails version
check_rails_version() {
    section_header "Rails Version" "green"
    if command -v rails &> /dev/null; then
        rails --version
    else
        color_log "Rails is not installed" "red"
    fi
}

# Check YJIT status
check_yjit_status() {
    section_header "YJIT Status" "green"
    
    # Check environment variables
    echo "Environment variables:"
    echo "RUBY_YJIT_ENABLE: ${RUBY_YJIT_ENABLE:-Not set}"
    echo "RUBYOPT: ${RUBYOPT:-Not set}"
    
    # Check if YJIT is actually enabled by running Ruby code
    echo ""
    echo "YJIT enabled in current Ruby process:"
    ruby -e 'puts RubyVM::YJIT.enabled? rescue puts "YJIT not available in this Ruby version"'
}

# Main function
main() {
    section_header "Ruby Environment Check" "blue"
    
    check_ruby_version
    check_gem_version
    check_bundler_version
    check_rails_version
    check_yjit_status
    
    section_header "Check Complete" "blue"
}

# Run the script
main
