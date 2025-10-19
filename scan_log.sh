#!/bin/bash

# Color definitions
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'  # No Color

# Function to display fancy headers
function display_header() {
    local title="$1"
    local width=60
    local padding=$(( (width - ${#title}) / 2 ))
    
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
    printf "${BLUE}║${BOLD}${CYAN}%*s%s%*s${NC}${BLUE}║${NC}\n" $padding "" "$title" $padding ""
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}\n"
}

# Function to display progress bar
function show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    #printf "\rProgress: ["
    #printf "%${completed}s" | tr ' ' '▇'
    #printf "%${remaining}s" | tr ' ' '.'
    #printf "] %d%%" $percentage

    printf "\rProgress: ["
printf '%*s' "$completed" | tr ' ' '▇'
printf '%*s' "$remaining" | tr ' ' '.'
printf "] %d%%" "$percentage"

}

# Function to create terminal graphs
function display_terminal_graph() {
    local title="$1"
    shift
    local -a values=("$@")
    local max_value=0
    local graph_width=50

    # Find maximum value for scaling
    for value in "${values[@]}"; do
        if ((value > max_value)); then
            max_value=$value
        fi
    done

    echo -e "\n${PURPLE}${BOLD}$title${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    for ((i=0; i<${#values[@]}; i+=2)); do
        local label="${values[i]}"
        local value="${values[i+1]}"
        local bar_length=0
        
        if ((max_value > 0)); then
            bar_length=$(( value * graph_width / max_value ))
        fi

        # Color based on value
        local color=$GREEN
        if ((value > max_value/2)); then
            color=$RED
        elif ((value > max_value/4)); then
            color=$YELLOW
        fi

        printf "${WHITE}%-15s${NC} |${color}" "$label"
        printf "%${bar_length}s" | tr ' ' '▇'
        printf "${NC} %d\n" "$value"
    done
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to analyze log patterns
# Function to analyze log patterns
function analyze_patterns() {
    local log_file="$1"
    local pattern="$2"
    local label="$3"
    local context_lines=2

    # Input validation
    if [[ -z "$log_file" ]] || [[ -z "$pattern" ]]; then
        echo -e "${RED}Error: Missing required parameters${NC}"
        echo -e "${YELLOW}Usage: analyze_patterns <log_file> <pattern> <label>${NC}"
        return 1
    fi

    if [[ ! -f "$log_file" ]]; then
        echo -e "${RED}Error: Log file not found: $log_file${NC}"
        return 1
    fi

    echo -e "\n${PURPLE}${BOLD}$label Analysis:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Check if pattern exists in file
    if ! grep -qi "$pattern" "$log_file"; then
        echo -e "${YELLOW}No matches found for pattern: $pattern${NC}"
        return 0
    fi

    # Find matches with context
    grep -A $context_lines -B $context_lines -i "$pattern" "$log_file" 2>/dev/null | while IFS= read -r line; do
        if [[ "$line" == "--" ]]; then
            echo -e "${DIM}───────────────────${NC}"
        elif echo "$line" | grep -qi "$pattern"; then
            echo -e "${RED}→ ${line}${NC}"
        else
            echo -e "${DIM}  ${line}${NC}"
        fi
    done

    # Show total count
    local count=$(grep -i "$pattern" "$log_file" | wc -l)
    echo -e "\n${CYAN}Total occurrences: ${YELLOW}$count${NC}"
}

# Function to generate HTML report
function generate_html_report_log() {
    local log_file="$1"
    local error_count="$2"
    local warning_count="$3"
    local info_count="$4"
    local critical_count="$5"
    local alert_count="$6"
    local auth_failure_count="$7"
    
    # Debug information
    echo "DEBUG: Starting HTML report generation..."
    echo "DEBUG: Input parameters:"
    echo "Log file: $log_file"
    echo "Error count: $error_count"
    echo "Warning count: $warning_count"
    echo "Info count: $info_count"
    echo "Critical count: $critical_count"
    echo "Alert count: $alert_count"
    echo "Auth Failures: $auth_failure_count"
    
    # Create report filename based on input log
    local report_file="${log_file%.*}_report.html"
    echo "DEBUG: Report will be saved as: $report_file"
    
    # Get file information
    local file_size=$(du -h "$log_file" | cut -f1)
    local line_count=$(wc -l < "$log_file")
    
    # Create a temporary file for the HTML content
    local temp_file=$(mktemp)
    echo "DEBUG: Created temporary file: $temp_file"
    
    # Write HTML content to temporary file first
    cat > "$temp_file" << EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Log Analysis Report</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }
        .stat-card { 
            border: 1px solid #ddd; 
            padding: 10px; 
            margin: 10px;
            display: inline-block;
            min-width: 200px;
        }
        .chart-container { 
            width: 100%;
            height: 400px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Log Analysis Report</h1>
        
        <div class="file-info">
            <h2>File Information</h2>
            <p>File: ${log_file##*/}</p>
            <p>Size: $file_size</p>
            <p>Lines: $line_count</p>
        </div>

        <div class="stats">
            <div class="stat-card">
                <h3>Errors</h3>
                <p style="color: red;">$error_count</p>
            </div>
            <div class="stat-card">
                <h3>Warnings</h3>
                <p style="color: orange;">$warning_count</p>
            </div>
            <div class="stat-card">
                <h3>Info Messages</h3>
                <p style="color: blue;">$info_count</p>
            </div>
        </div>

        <div class="chart-container">
            <canvas id="myChart"></canvas>
        </div>

        <script>
            const ctx = document.getElementById('myChart');
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: ['Errors', 'Warnings', 'Info', 'Critical', 'Alerts', 'Auth Failures'],
                    datasets: [{
                        label: 'Log Entries',
                        data: [$error_count, $warning_count, $info_count, $critical_count, $alert_count, $auth_failure_count],
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.5)',
                            'rgba(255, 159, 64, 0.5)',
                            'rgba(54, 162, 235, 0.5)',
                            'rgba(153, 102, 255, 0.5)',
                            'rgba(255, 205, 86, 0.5)',
                            'rgba(75, 192, 192, 0.5)'
                        ],
                        borderColor: [
                            'rgb(255, 99, 132)',
                            'rgb(255, 159, 64)',
                            'rgb(54, 162, 235)',
                            'rgb(153, 102, 255)',
                            'rgb(255, 205, 86)',
                            'rgb(75, 192, 192)'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        </script>
    </div>
</body>
</html>
EOL

    # Check if temporary file was created and has content
    if [[ ! -f "$temp_file" ]]; then
        echo "DEBUG: Error - Temporary file was not created"
        return 1
    fi
    
    if [[ ! -s "$temp_file" ]]; then
        echo "DEBUG: Error - Temporary file is empty"
        return 1
    fi
    
    echo "DEBUG: Temporary file size: $(du -h "$temp_file" | cut -f1)"
    
    # Move temporary file to final location
    mv "$temp_file" "$report_file"
    
    # Check if the file was created successfully
    if [[ -f "$report_file" ]] && [[ -s "$report_file" ]]; then
        echo -e "\n${GREEN}HTML report generated successfully: ${WHITE}$report_file${NC}"
        echo -e "File size: $(du -h "$report_file" | cut -f1)"
    else
        echo -e "\n${RED}Error: Failed to generate HTML report${NC}"
        return 1
    fi
}

# Main log analysis function
function analyze_log() {
    local log_file="$1"

    # Input validation
    if [[ -z "$log_file" ]]; then
        echo -e "${RED}Error: No log file specified${NC}"
        return 1
    fi

    if [[ ! -f "$log_file" ]]; then
        echo -e "${RED}Error: File '$log_file' does not exist${NC}"
        return 1
    fi

    if [[ ! -r "$log_file" ]]; then
        echo -e "${RED}Error: File '$log_file' is not readable${NC}"
        return 1
    fi

    # Display main header
    display_header "Log File Analysis"

    # Get file information
    local file_size=$(du -h "$log_file" | cut -f1)
    local line_count=$(wc -l < "$log_file")
    local first_timestamp=$(head -n 1 "$log_file" | grep -oE "^[[:space:]]*[[:alnum:] :-]+")
    local last_timestamp=$(tail -n 1 "$log_file" | grep -oE "^[[:space:]]*[[:alnum:] :-]+")

    # Display file information
    echo -e "${YELLOW}File Information:${NC}"
    echo -e "File: ${WHITE}$log_file${NC}"
    echo -e "Size: ${WHITE}$file_size${NC}"
    echo -e "Lines: ${WHITE}$line_count${NC}"
    echo -e "Period: ${WHITE}$first_timestamp${NC} to ${WHITE}$last_timestamp${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Initialize counters
    local error_count=0
    local warning_count=0
    local info_count=0
    local critical_count=0
    local alert_count=0
    local auth_failure_count=0

    # Count patterns
    echo -e "\n${YELLOW}Analyzing log entries...${NC}"
    
    total_lines=$line_count
    current_line=0
    
    while IFS= read -r line; do
        ((current_line++))
        show_progress $current_line $total_lines

        if echo "$line" | grep -qi "error"; then
            ((error_count++))
        fi
        if echo "$line" | grep -qi "warning"; then
            ((warning_count++))
        fi
        if echo "$line" | grep -qi "info"; then
            ((info_count++))
        fi
        if echo "$line" | grep -qi "critical"; then
            ((critical_count++))
        fi
        if echo "$line" | grep -qi "alert"; then
            ((alert_count++))
        fi
        if echo "$line" | grep -qi "authentication failure"; then
            ((auth_failure_count++))
        fi
    done < "$log_file"
    echo # New line after progress bar

    # Display terminal graphs
    display_terminal_graph "Log Entry Distribution" \
        "Errors" $error_count \
        "Warnings" $warning_count \
        "Info" $info_count \
        "Critical" $critical_count \
        "Alerts" $alert_count \
        "Auth Failures" $auth_failure_count

    # Analyze specific patterns
    analyze_patterns "$log_file" "error" "Error"
    analyze_patterns "$log_file" "warning" "Warning"
    analyze_patterns "$log_file" "authentication failure" "Authentication Failure"

    # Generate HTML report
    generate_html_report_log "$log_file" \
        $error_count $warning_count $info_count \
        $critical_count $alert_count $auth_failure_count
}

