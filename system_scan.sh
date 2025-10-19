if [[ -z "$BLUE" ]]; then
    # Color definitions
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    PURPLE='\033[0;35m'
    NC='\033[0m' # No Color
    BOLD='\033[1m'
    DIM='\033[2m'
fi


function scan_entire_system()
{
    echo "Starting system scan..."
    
    # Example scan operations: checking disk space, CPU usage, memory, etc.
    echo "Checking disk space usage:"
    df -h
    
    echo "Checking memory usage:"
    free -h
    
    echo "Checking CPU load:"
    uptime

    # Add more system scanning logic as needed
    
    echo "System scan completed."
}

function scan_syslog() 
{
    base_path="/var/log/syslog"
    temp_file=$(mktemp)
    
    # Color definitions
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    GRAY='\033[0;37m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
    
    # Box drawing characters
    TOP_LEFT='╔'
    TOP_RIGHT='╗'
    BOTTOM_LEFT='╚'
    BOTTOM_RIGHT='╝'
    HORIZONTAL='═'
    VERTICAL='║'

    # Combine log files
    echo -e "${YELLOW}Combining log files for analysis...${NC}"
    
    # Start with current syslog
    if [[ -f "$base_path" ]]; then
        cat "$base_path" > "$temp_file"
    fi
    
    # Add syslog.1 if it exists
    if [[ -f "${base_path}.1" ]]; then
        cat "${base_path}.1" >> "$temp_file"
    fi
    
    # Add compressed backup files
    for backup_file in ${base_path}.[0-9]*.gz; do
        if [[ -f "$backup_file" ]]; then
            zcat "$backup_file" >> "$temp_file"
        fi
    done
    
    if [[ ! -s "$temp_file" ]]; then
        echo -e "${RED}Error: No syslog files found at $base_path or its backups.${NC}"
        rm "$temp_file"
        return 1
    fi

    # Create header with centered title
    printf "\n${BLUE}"
    printf "╔══════════════════════════════════════════════════╗\n"
    printf "║          System Log Error Scan Report            ║\n"
    printf "╚══════════════════════════════════════════════════╝"
    printf "${NC}\n\n"

    # Display file information
    echo -e "${YELLOW}Analyzing logs from:${NC}"
    if [[ -f "$base_path" ]]; then
        echo -e "- Current log (${base_path})"
    fi
    if [[ -f "${base_path}.1" ]]; then
        echo -e "- Previous log (${base_path}.1)"
    fi
    for backup_file in ${base_path}.[0-9]*.gz; do
        if [[ -f "$backup_file" ]]; then
            echo -e "- Backup: $(basename "$backup_file")"
        fi
    done
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    # Error pattern analysis
    memory_error_count=$(grep -Eoi "OOM killer enabled|Out of memory|memory exhausted|cannot allocate memory" "$temp_file" | wc -l)
    throttling_error_count=$(grep -Eoi "cpu clock throttled|thermal throttling|frequency limited" "$temp_file" | wc -l)
    disk_io_error_count=$(grep -Eoi "Invalid buffer destination|I/O error|disk error|buffer overflow" "$temp_file" | wc -l)
    bios_error_count=$(grep -Eoi "ACPI BIOS Error|BIOS bug|BIOS failed" "$temp_file" | wc -l)
    network_error_count=$(grep -Eoi "Network unreachable|link is down|connection failed|network error" "$temp_file" | wc -l)
    filesystem_error_count=$(grep -Eoi "EXT4-fs error|filesystem error|corrupt|invalid inode" "$temp_file" | wc -l)
    highload_error_count=$(grep -Eoi "blocked for more than|high load detected|system overload" "$temp_file" | wc -l)

    # Display results
    echo -e "\n${PURPLE}${BOLD}Error Type Analysis (Including Backup Logs):${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    printf "${YELLOW}%-40s${NC}: ${RED}%d${NC}\n" "Memory error occurrences" "$memory_error_count"
    printf "${YELLOW}%-40s${NC}: ${RED}%d${NC}\n" "Throttling related error occurrences" "$throttling_error_count"
    printf "${YELLOW}%-40s${NC}: ${RED}%d${NC}\n" "I/O and buffer related error occurrences" "$disk_io_error_count"
    printf "${YELLOW}%-40s${NC}: ${RED}%d${NC}\n" "BIOS related error occurrences" "$bios_error_count"
    printf "${YELLOW}%-40s${NC}: ${RED}%d${NC}\n" "Network related error occurrences" "$network_error_count"
    printf "${YELLOW}%-40s${NC}: ${RED}%d${NC}\n" "Filesystem related error occurrences" "$filesystem_error_count"
    printf "${YELLOW}%-40s${NC}: ${RED}%d${NC}\n" "High Load related error occurrences" "$highload_error_count"

    # Store application errors in a temporary file for both terminal and HTML report
    temp_app_file=$(mktemp)

    # Process and sort application errors
    grep -i "error\|fail\|crash\|exception" "$temp_file" | \
    awk '
    {
        if ($0 ~ /info|debug|notice|success|trying|retry|recovered/) {
            next
        }
        
        if (match($0, /[A-Za-z0-9._-]+\[[0-9]+\]/)) {
            app = substr($0, RSTART, RLENGTH)
            gsub(/\[[0-9]+\]/, "", app)
        } else if (match($0, /[A-Za-z0-9._-]+(:|\[)/)) {
            app = substr($0, RSTART, RLENGTH-1)
        } else {
            app = $1
        }

        # Clean up the application name
        gsub(/[^A-Za-z0-9._-]/, "", app)
        if (length(app) > 0 && app !~ /^[0-9.]+$/) {
            errors[app]++
        }
    }
    END {
        for (app in errors) {
            printf "%s %d\n", app, errors[app]
        }
    }' | sort -rn -k2 > "$temp_app_file"

    # Display Application Errors section
    echo -e "\n${PURPLE}${BOLD}Application Error Analysis:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}Application Errors:${NC}\n"

    # Display the sorted application errors
    while read -r app count; do
        printf "${YELLOW}%-40s${NC}: ${RED}%d${NC}\n" "$app" "$count"
    done < "$temp_app_file"

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Generate HTML report
    html_file="syslog_report.html"
    cat <<EOF > "$html_file"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>System Log Error Report</title>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #333;
            text-align: center;
            padding: 20px;
        }
        .chart-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .files-analyzed {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
    </style>
    <script type="text/javascript">
        google.charts.load("current", {packages:["corechart"]});
        google.charts.setOnLoadCallback(drawCharts);

        function drawCharts() {
            // Error types pie chart
            var errorData = google.visualization.arrayToDataTable([
                ['Error Type', 'Occurrences'],
                ['Memory Error', ${memory_error_count}],
                ['CPU Throttling Error', ${throttling_error_count}],
                ['Disk I/O Error', ${disk_io_error_count}],
                ['BIOS Error', ${bios_error_count}],
                ['Network Error', ${network_error_count}],
                ['Filesystem Error', ${filesystem_error_count}],
                ['High Load Error', ${highload_error_count}]
            ]);

            var errorOptions = {
                title: 'System Log Error Types',
                pieHole: 0.4,
                colors: ['#ff9999', '#66b3ff', '#99ff99', '#ffcc99', '#c2c2f0', '#ffb3e6', '#c2f0c2']
            };

            var errorChart = new google.visualization.PieChart(document.getElementById('error_piechart'));
            errorChart.draw(errorData, errorOptions);

            // Application errors chart
            var appData = new google.visualization.DataTable();
            appData.addColumn('string', 'Application');
            appData.addColumn('number', 'Errors');
            appData.addRows([
                $(head -n 10 "$temp_app_file" | awk '{printf "[\"%s\", %d],", $1, $2}' | sed 's/,$//')
            ]);

            var appOptions = {
                title: 'Top 10 Applications by Error Count',
                chartArea: {width: '70%', height: '80%'},
                legend: { position: 'none' },
                hAxis: { title: 'Error Count' },
                vAxis: { title: 'Application' }
            };

            var appChart = new google.visualization.BarChart(document.getElementById('app_piechart'));
            appChart.draw(appData, appOptions);
        }
    </script>
</head>
<body>
    <h1>System Log Error Report</h1>
    <div class="files-analyzed">
        <h2>Files Analyzed</h2>
        <ul>
            $(if [[ -f "$base_path" ]]; then echo "<li>Current log (${base_path})</li>"; fi)
            $(if [[ -f "${base_path}.1" ]]; then echo "<li>Previous log (${base_path}.1)</li>"; fi)
            $(for f in ${base_path}.[0-9]*.gz; do
                if [[ -f "$f" ]]; then
                    echo "<li>Backup: $(basename "$f")</li>"
                fi
            done)
        </ul>
    </div>
    <div style="display: flex; justify-content: center; flex-wrap: wrap;">
        <div class="chart-container">
            <div id="error_piechart" style="width: 900px; height: 500px;"></div>
        </div>
        <div class="chart-container">
            <div id="app_piechart" style="width: 900px; height: 500px;"></div>
        </div>
    </div>
</body>
</html>
EOF

    # Cleanup temporary files
    rm -f "$temp_app_file"
    rm -f "$temp_file"
    echo -e "${GREEN}HTML report generated:${NC} ${BLUE}$html_file${NC}"
    echo -e "\nNote: This analysis includes data from all available syslog files and their backups"
}



# Color definitions 
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'


function scan_syslog_last_7_days {
    base_path="/var/log/syslog"
    temp_file=$(mktemp)
    
    # Color definitions
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    GRAY='\033[0;37m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
    DIM='\033[2m'
    
    # Get dates in the correct format for comparison
    date_start=$(date -d "7 days ago" "+%Y-%m-%d")
    date_end=$(date "+%Y-%m-%d")

    echo -e "${YELLOW}Combining log files for analysis...${NC}"

    # Build awk script for date filtering and processing
    awk_script='
    BEGIN {
        # Initialize month mapping
        months["Jan"] = "01"; months["Feb"] = "02"; months["Mar"] = "03"
        months["Apr"] = "04"; months["May"] = "05"; months["Jun"] = "06"
        months["Jul"] = "07"; months["Aug"] = "08"; months["Sep"] = "09"
        months["Oct"] = "10"; months["Nov"] = "11"; months["Dec"] = "12"
        
        # Get current year
        "date +%Y" | getline current_year
        close("date")
    }

    # Extract date from log line in YYYY-MM-DD format
    function extract_date(line) {
        if (match(line, /[0-9]{4}-[0-9]{2}-[0-9]{2}/)) {
            return substr(line, RSTART, 10)
        }
        return ""
    }

    {
        # Try to extract ISO format date
        date_str = extract_date($0)
        
        # Only print if date is within range
        if (date_str >= start_date && date_str <= end_date) {
            print $0
        }
    }'

    # Process current syslog
    if [[ -f "$base_path" ]]; then
        awk -v start_date="$date_start" -v end_date="$date_end" "$awk_script" "$base_path" > "$temp_file"
    fi

    # Process syslog.1 if it exists
    if [[ -f "${base_path}.1" ]]; then
        awk -v start_date="$date_start" -v end_date="$date_end" "$awk_script" "${base_path}.1" >> "$temp_file"
    fi

    # Process compressed backup files
    for backup_file in ${base_path}.[0-9]*.gz; do
        if [[ -f "$backup_file" ]]; then
            zcat "$backup_file" | awk -v start_date="$date_start" -v end_date="$date_end" "$awk_script" >> "$temp_file"
        fi
    done

    if [[ ! -s "$temp_file" ]]; then
        echo -e "${RED}Error: No syslog data found for the specified period.${NC}"
        rm "$temp_file"
        return 1
    fi

    echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}${CYAN}     System Log Error Scan (Last 7 Days)   ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"

    echo -e "\n${YELLOW}Analyzing logs from:${NC}"
    if [[ -f "$base_path" ]]; then
        echo -e "- Current log (${base_path})"
    fi
    if [[ -f "${base_path}.1" ]]; then
        echo -e "- Previous log (${base_path}.1)"
    fi
    for backup_file in ${base_path}.[0-9]*.gz; do
        if [[ -f "$backup_file" ]]; then
            echo -e "- Backup: $(basename "$backup_file")"
        fi
    done

    # Add System Resource Status Section
    echo -e "\n${PURPLE}${BOLD}Current System Resource Status:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Disk Space Usage:${NC}"
    df -h | grep -v "tmpfs"
    echo -e "\n${YELLOW}Memory Usage:${NC}"
    free -h
    echo -e "\n${YELLOW}CPU Load:${NC}"
    uptime
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo -e "${YELLOW}Scanning from:${NC} ${BOLD}$date_start${NC}"
    echo -e "${YELLOW}Scanning to  :${NC} ${BOLD}$date_end${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    
    # Initialize arrays
    declare -A daily_error_counts
    declare -A daily_counts
    declare -A total_counts

    # Define error patterns
    declare -A error_types=(
        ["memory"]="(oom-killer|Out of memory|Memory cgroup out of memory|page allocation failure|memory exhausted|cannot allocate memory)"
        ["throttling"]="(cpu clock throttled|frequency scaled|thermal throttling|clock is throttled|frequency limited)"
        ["disk_io"]="(I/O error|Buffer I/O error|journal commit I/O error|failed command|Invalid buffer destination|disk error|buffer overflow)"
        ["bios"]="(ACPI Error|ACPI BIOS Error|BIOS BUG|PCI error|BIOS failed)"
        ["network"]="(Network unreachable|link is (down|flapping)|connection failed|NetworkManager.*error|network error)"
        ["filesystem"]="(EXT[234]-fs error|filesystem error|corrupt(ed)? filesystem|no space left|read-only filesystem|invalid inode)"
        ["highload"]="(blocked for more than|load average|high load|system overload|high load detected)"
    )

    # Initialize counters
    for error_type in "${!error_types[@]}"; do
        total_counts[$error_type]=0
    done

    # Process each day
    for ((i=0; i<7; i++)); do
        current_date=$(date -d "$i days ago" "+%Y-%m-%d")
        
        # Initialize daily counts
        declare -A daily_counts
        daily_total=0
        
        for error_type in "${!error_types[@]}"; do
            # Count errors for each type
            count=$(grep -P "^$current_date" "$temp_file" | grep -Pi "${error_types[$error_type]}" | wc -l)
            daily_counts[$error_type]=$count
            total_counts[$error_type]=$((total_counts[$error_type] + count))
            daily_counts["$current_date,$error_type"]=$count
            daily_total=$((daily_total + count))
        done
        daily_error_counts[$current_date]=$daily_total
    done

    # Display weekly summary
    echo -e "\n${PURPLE}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${BOLD}${CYAN}           Weekly Total Error Summary      ${NC}${PURPLE}║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════╝${NC}"
    
    for error_type in "${!error_types[@]}"; do
        count="${total_counts[$error_type]}"
        if ((count > 20)); then
            color=$RED
        elif ((count > 10)); then
            color=$YELLOW
        else
            color=$GREEN
        fi
        printf "${DIM}%-40s${NC}: ${color}%d${NC}\n" "${error_type/_/ } error occurrences" "${count}"
    done
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"

    # Display daily summary with color-coded bar graphs
    echo -e "\n${PURPLE}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${BOLD}${CYAN}        Daily Error Summary (Last 7 Days)  ${NC}${PURPLE}║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════╝${NC}"
    
    for ((i=0; i<7; i++)); do
        current_date=$(date -d "$i days ago" "+%F")
        total_errors=${daily_error_counts[$current_date]:-0}

        # Determine bar color based on error count
        if ((total_errors < 10)); then
            color=$GREEN
        elif ((total_errors <= 20)); then
            color=$YELLOW
        else
            color=$RED
        fi

        # Create bar graph
        bar_length=$((total_errors > 0 ? (total_errors < 50 ? total_errors : 50) : 1))
        bar_graph=$(printf "%0.s▇" $(seq 1 $bar_length))

        printf "${BOLD}Date:${NC} %-15s ${BOLD}Total Errors:${NC} ${color}%s${NC} ${DIM}%d${NC}\n" \
               "$current_date" "$bar_graph" "$total_errors"
    done
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"

    # Store application errors in a temporary file
    temp_app_file=$(mktemp)

    # Process and sort application errors
    grep -i "error\|fail\|crash\|exception" "$temp_file" | \
    awk '
    {
        if ($0 ~ /info|debug|notice|success|trying|retry|recovered/) {
            next
        }
        
        if (match($0, /[A-Za-z0-9._-]+\[[0-9]+\]/)) {
            app = substr($0, RSTART, RLENGTH)
            gsub(/\[[0-9]+\]/, "", app)
        } else if (match($0, /[A-Za-z0-9._-]+(:|\[)/)) {
            app = substr($0, RSTART, RLENGTH-1)
        } else {
            app = $1
        }

        # Clean up the application name
        gsub(/[^A-Za-z0-9._-]/, "", app)
        if (length(app) > 0 && app !~ /^[0-9.]+$/) {
            errors[app]++
        }
    }
    END {
        for (app in errors) {
            printf "%s %d\n", app, errors[app]
        }
    }' | sort -rn -k2 > "$temp_app_file"

    # Display Application Errors section
    echo -e "\n${PURPLE}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${BOLD}${CYAN}     Top Applications by Error Count       ${NC}${PURPLE}║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════╝${NC}"

    # Display the sorted application errors
    while read -r app count; do
        printf "${YELLOW}%-40s${NC}: ${RED}%d${NC}\n" "$app" "$count"
    done < "$temp_app_file"

    echo -e "${BLUE}═══════════════════════════════════════════${NC}"

    # Prepare data for HTML report
    app_data=$(head -n 10 "$temp_app_file" | \
        awk '{printf "[\"%s\", %d],", $1, $2}' | \
        sed 's/,$//')

    # Generate HTML report
    html_file="syslog_trend_report.html"
    cat <<EOF > "$html_file"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>System Log Error Trends (Last 7 Days)</title>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
        }
        h1, h2 {
            color: #2c3e50;
            text-align: center;
            padding: 20px;
            margin: 0;
            background: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .chart-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 20px auto;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            max-width: 1200px;
        }
        .system-info {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 20px auto;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            max-width: 1200px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .info-card {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 4px;
            border-left: 4px solid #3498db;
        }
    </style>
    <script type="text/javascript">
        google.charts.load('current', {packages:['corechart']});
        google.charts.setOnLoadCallback(drawCharts);

        function drawCharts() {
            // Error types pie chart
            var errorData = google.visualization.arrayToDataTable([
                ['Error Type', 'Count'],
                ['Memory', ${total_counts[memory]}],
                ['Throttling', ${total_counts[throttling]}],
                ['Disk I/O', ${total_counts[disk_io]}],
                ['BIOS', ${total_counts[bios]}],
                ['Network', ${total_counts[network]}],
                ['Filesystem', ${total_counts[filesystem]}],
                ['High Load', ${total_counts[highload]}]
            ]);

            var errorOptions = {
                title: 'Error Type Distribution',
                pieHole: 0.4,
                chartArea: {width: '80%', height: '80%'},
                colors: ['#e74c3c', '#3498db', '#2ecc71', '#f1c40f', '#9b59b6', '#e67e22', '#1abc9c']
            };

            var errorChart = new google.visualization.PieChart(document.getElementById('error_piechart'));
            errorChart.draw(errorData, errorOptions);

            // Application errors chart
            var appData = google.visualization.arrayToDataTable([
                ['Application', 'Error Count'],
                ${app_data}
            ]);

            var appOptions = {
                title: 'Top 10 Applications by Error Count',
                chartArea: {width: '60%', height: '80%'},
                legend: { position: 'none' },
                bars: 'horizontal',  // This makes it a horizontal bar chart
                hAxis: { title: 'Error Count' },
                vAxis: { title: 'Application' }
            };

            var appChart = new google.visualization.BarChart(document.getElementById('app_chart'));
            appChart.draw(appData, appOptions);

            // Daily error trend line chart
            var dailyData = google.visualization.arrayToDataTable([
                ['Date', 'Total Errors'],
                $(for ((i=6; i>=0; i--)); do
                    current_date=$(date -d "$i days ago" "+%Y-%m-%d")
                    echo "['$current_date', ${daily_error_counts[$current_date]:-0}],"
                done)
            ]);

            var dailyOptions = {
                title: 'Daily Error Trends',
                curveType: 'function',
                legend: { position: 'bottom' },
                chartArea: {width: '80%', height: '70%'},
                hAxis: { title: 'Date' },
                vAxis: { title: 'Number of Errors' }
            };

            var lineChart = new google.visualization.LineChart(document.getElementById('daily_linechart'));
            lineChart.draw(dailyData, dailyOptions);
        }
    </script>
</head>
<body>
    <h1>System Log Error Analysis Report</h1>
    
    <div class="system-info">
        <h2>System Information</h2>
        <div class="info-grid">
            <div class="info-card">
                <h3>Scan Period</h3>
                <p><strong>From:</strong> $date_start</p>
                <p><strong>To:</strong> $date_end</p>
            </div>
            <div class="info-card">
                <h3>System Status</h3>
                <p><strong>CPU Load:</strong> $(uptime | cut -d':' -f4-)</p>
                <p><strong>Memory Free:</strong> $(free -h | awk '/^Mem:/ {print $4}')</p>
                <p><strong>Disk Usage:</strong> $(df -h / | awk 'NR==2 {print $5}')</p>
            </div>
            <div class="info-card">
                <h3>Analyzed Files</h3>
                <ul>
                    $(if [[ -f "$base_path" ]]; then echo "<li>Current log ($base_path)</li>"; fi)
                    $(if [[ -f "${base_path}.1" ]]; then echo "<li>Previous log (${base_path}.1)</li>"; fi)
                    $(for f in ${base_path}.[0-9]*.gz; do
                        if [[ -f "$f" ]]; then
                            echo "<li>Backup: $(basename "$f")</li>"
                        fi
                    done)
                </ul>
            </div>
            <div class="info-card">
                <h3>Error Summary</h3>
                <p><strong>Total Errors Found:</strong> $(grep -c "error\|fail\|critical\|emergency\|alert\|panic\|fatal" "$temp_file" || echo 0)</p>
            </div>
        </div>
    </div>

    <div class="chart-container">
        <div id="error_piechart" style="width: 100%; height: 500px;"></div>
    </div>

    <div class="chart-container">
        <div id="daily_linechart" style="width: 100%; height: 500px;"></div>
    </div>

    <div class="chart-container">
        <div id="app_chart" style="width: 100%; height: 500px;"></div>
    </div>
</body>
</html>
EOF

    # Cleanup temporary files
    rm -f "$temp_app_file"
    rm -f "$temp_file"
    echo -e "\n${GREEN}HTML report generated:${NC} ${BLUE}$html_file${NC}"
    echo -e "\nNote: This analysis includes data from all available syslog files and their backups"
}


function generate_html_report {
    local html_file="syslog_trend_report.html"
    local start_date="$1"
    local end_date="$2"
    local temp_file="$3"
    local app_data="$4"
    
    cat <<EOF > "$html_file"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>System Log Error Trends (Last 7 Days)</title>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
        }
        h1, h2 {
            color: #2c3e50;
            text-align: center;
            padding: 20px;
            margin: 0;
            background: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .chart-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 20px auto;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            max-width: 1200px;
        }
        .system-info {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 20px auto;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            max-width: 1200px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .info-card {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 4px;
            border-left: 4px solid #3498db;
        }
    </style>
    <script type="text/javascript">
        google.charts.load('current', {packages:['corechart']});
        google.charts.setOnLoadCallback(drawCharts);

        function drawCharts() {
            // Error types pie chart
            var errorData = google.visualization.arrayToDataTable([
                ['Error Type', 'Count'],
                ['Memory', ${total_counts[memory]}],
                ['Throttling', ${total_counts[throttling]}],
                ['Disk I/O', ${total_counts[disk_io]}],
                ['BIOS', ${total_counts[bios]}],
                ['Network', ${total_counts[network]}],
                ['Filesystem', ${total_counts[filesystem]}],
                ['High Load', ${total_counts[highload]}]
            ]);

            var errorOptions = {
                title: 'Error Type Distribution',
                pieHole: 0.4,
                chartArea: {width: '80%', height: '80%'},
                colors: ['#e74c3c', '#3498db', '#2ecc71', '#f1c40f', '#9b59b6', '#e67e22', '#1abc9c']
            };

            var errorChart = new google.visualization.PieChart(document.getElementById('error_piechart'));
            errorChart.draw(errorData, errorOptions);

            // Applications bar chart
            var appData = google.visualization.arrayToDataTable([
                ['Application', 'Error Count'],
                ${app_data}
            ]);

            var appOptions = {
                title: 'Top 10 Applications by Error Count',
                chartArea: {width: '70%', height: '80%'},
                legend: { position: 'none' },
                hAxis: { title: 'Error Count' },
                vAxis: { title: 'Application' }
            };

            var appChart = new google.visualization.BarChart(document.getElementById('app_barchart'));
            appChart.draw(appData, appOptions);

            // Daily error trend line chart
            var dailyData = google.visualization.arrayToDataTable([
                ['Date', 'Total Errors'],
                $(for ((i=6; i>=0; i--)); do
                    current_date=$(date -d "$i days ago" "+%Y-%m-%d")
                    echo "['$current_date', ${daily_error_counts[$current_date]:-0}],"
                done)
            ]);

            var dailyOptions = {
                title: 'Daily Error Trends',
                curveType: 'function',
                legend: { position: 'bottom' },
                chartArea: {width: '80%', height: '70%'},
                hAxis: { title: 'Date' },
                vAxis: { title: 'Number of Errors' }
            };

            var lineChart = new google.visualization.LineChart(document.getElementById('daily_linechart'));
            lineChart.draw(dailyData, dailyOptions);
        }
    </script>
</head>
<body>
    <h1>System Log Error Analysis Report</h1>
    
    <div class="system-info">
        <h2>System Information</h2>
        <div class="info-grid">
            <div class="info-card">
                <h3>Scan Period</h3>
                <p><strong>From:</strong> $start_date</p>
                <p><strong>To:</strong> $end_date</p>
            </div>
            <div class="info-card">
                <h3>System Status</h3>
                <p><strong>CPU Load:</strong> $(uptime | cut -d':' -f4-)</p>
                <p><strong>Memory Free:</strong> $(free -h | awk '/^Mem:/ {print $4}')</p>
                <p><strong>Disk Usage:</strong> $(df -h / | awk 'NR==2 {print $5}')</p>
            </div>
            <div class="info-card">
                <h3>Analyzed Files</h3>
                <ul>
                    $(if [[ -f "$base_path" ]]; then echo "<li>Current log ($base_path)</li>"; fi)
                    $(if [[ -f "${base_path}.1" ]]; then echo "<li>Previous log (${base_path}.1)</li>"; fi)
                    $(for f in ${base_path}.[0-9]*.gz; do
                        if [[ -f "$f" ]]; then
                            echo "<li>Backup: $(basename "$f")</li>"
                        fi
                    done)
                </ul>
            </div>
        </div>
    </div>

    <div class="chart-container">
        <div id="error_piechart" style="width: 100%; height: 500px;"></div>
    </div>

    <div class="chart-container">
        <div id="daily_linechart" style="width: 100%; height: 500px;"></div>
    </div>

    <div class="chart-container">
        <div id="app_barchart" style="width: 100%; height: 500px;"></div>
    </div>
</body>
</html>
EOF
}

function scan_syslog_last_24h {
    # Define file path
    base_path="/var/log/syslog"
    temp_file=$(mktemp)
    
    # Color definitions
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    GRAY='\033[0;37m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
    DIM='\033[2m'
    
    # Get dates in the correct format for comparison
    current_timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    date_start=$(date -d "24 hours ago" "+%Y-%m-%d %H:%M:%S")
    date_end=$current_timestamp

    echo -e "${YELLOW}Combining log files for analysis...${NC}"

    # Build awk script for date filtering and processing
    awk_script='
    function format_timestamp(line) {
        if (match(line, /[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}/)) {
            timestamp = substr(line, RSTART, 19)
            gsub("T", " ", timestamp)
            return timestamp
        }
        return ""
    }

    {
        timestamp = format_timestamp($0)
        if (timestamp != "" && timestamp >= start_date && timestamp <= end_date) {
            print $0
        }
    }'

    # Process current syslog
    if [[ -f "$base_path" ]]; then
        echo -e "${YELLOW}Processing current syslog file...${NC}"
        awk -v start_date="$date_start" -v end_date="$date_end" "$awk_script" "$base_path" > "$temp_file"
    fi

    # Process syslog.1 if exists
    if [[ -f "${base_path}.1" ]]; then
        echo -e "${YELLOW}Processing previous syslog file...${NC}"
        awk -v start_date="$date_start" -v end_date="$date_end" "$awk_script" "${base_path}.1" >> "$temp_file"
    fi

    # Process compressed backup files if needed
    for backup_file in ${base_path}.[0-9]*.gz; do
        if [[ -f "$backup_file" ]]; then
            echo -e "${YELLOW}Processing backup file: ${backup_file}...${NC}"
            zcat "$backup_file" | awk -v start_date="$date_start" -v end_date="$date_end" "$awk_script" >> "$temp_file"
        fi
    done

    if [[ ! -s "$temp_file" ]]; then
        echo -e "${RED}Error: No syslog data found for the specified period.${NC}"
        rm "$temp_file"
        return 1
    fi

    # Display report header
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}${CYAN}      System Log Error Scan Report (Last 24 Hours) ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}"

    # System Resource Check Section
    echo -e "\n${PURPLE}${BOLD}System Resource Status:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Disk Space Usage:${NC}"
    df -h | grep -v "tmpfs"
    echo -e "\n${YELLOW}Memory Usage:${NC}"
    free -h
    echo -e "\n${YELLOW}CPU Load:${NC}"
    uptime
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Display analyzed files
    echo -e "\n${YELLOW}Analyzing logs from:${NC}"
    if [[ -f "$base_path" ]]; then
        echo -e "- Current log ($base_path)"
    fi
    if [[ -f "${base_path}.1" ]]; then
        echo -e "- Previous log (${base_path}.1)"
    fi
    for backup_file in ${base_path}.[0-9]*.gz; do
        if [[ -f "$backup_file" ]]; then
            echo -e "- Backup: $(basename "$backup_file")"
        fi
    done

    echo -e "\n${YELLOW}Scan Period: ${NC}${BOLD}$date_start to $date_end${NC}\n"

    # Initialize arrays for tracking error counts
    declare -A error_counts
    declare -A unique_errors

    # Define error patterns and their descriptions
    declare -A error_patterns=(
        ["memory"]="OOM killer enabled|Out of memory|memory exhausted|cannot allocate memory"
        ["throttling"]="cpu clock throttled|thermal throttling|frequency limited"
        ["disk_io"]="Invalid buffer destination|I/O error|disk error|buffer overflow"
        ["bios"]="ACPI BIOS|BIOS bug|BIOS failed"
        ["network"]="Network unreachable|link is down|connection failed|network error"
        ["filesystem"]="EXT4-fs error|filesystem error|corrupt|invalid inode"
        ["highload"]="blocked for more than|high load detected|system overload"
    )

    # Process each error type
    for error_type in "${!error_patterns[@]}"; do
        pattern="${error_patterns[$error_type]}"
        matching_errors=$(grep -Pi "$pattern" "$temp_file" | sort -u)
        count=$(echo "$matching_errors" | grep -c '^' || echo 0)
        error_counts[$error_type]=$count
        unique_errors[$error_type]="$matching_errors"
    done

# Display Error Type Analysis in a Double Rectangle Box with Custom Colors and Proper Indentation
echo -e "\n${PURPLE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${BOLD}         ERROR TYPE ANALYSIS               ${PURPLE}║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════╝${NC}\n"


# Print error types and counts with proper indentation and column alignment
for error_type in "${!error_patterns[@]}"; do
    count=${error_counts[$error_type]}

    # Set the color based on the error type
    error_color="${YELLOW}"  # Default color for all error types

    # Format output with a colon aligned with counts
    printf "${PURPLE} ${BOLD}${error_color}%-40s${NC} : ${RED}%-5d${NC}\n" "${error_type^} related errors" "$count"
done



    # Store application errors in a temporary file
    temp_app_file=$(mktemp)

    # Process and sort application errors
    grep -i "error\|fail\|crash\|exception" "$temp_file" | \
    awk '
    {
        if ($0 ~ /info|debug|notice|success|trying|retry|recovered/) {
            next
        }
        
        if (match($0, /[A-Za-z0-9._-]+\[[0-9]+\]/)) {
            app = substr($0, RSTART, RLENGTH)
            gsub(/\[[0-9]+\]/, "", app)
        } else if (match($0, /[A-Za-z0-9._-]+(:|\[)/)) {
            app = substr($0, RSTART, RLENGTH-1)
        } else {
            app = $1
        }

        # Clean up the application name
        gsub(/[^A-Za-z0-9._-]/, "", app)
        if (length(app) > 0 && app !~ /^[0-9.]+$/) {
            errors[app]++
        }
    }
    END {
        for (app in errors) {
            printf "%s %d\n", app, errors[app]
        }
    }' | sort -rn -k2 > "$temp_app_file"

    # Display Application Errors section
    echo -e "\n${PURPLE}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${BOLD}${CYAN}     Top Applications by Error Count      ${NC}${PURPLE} ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════╝${NC}"

   # Display the sorted application errors
    while read -r app count; do
        printf "${YELLOW}%-40s${NC}: ${RED}%d${NC}\n" "$app" "$count"
    done < "$temp_app_file"

    echo -e "${BLUE}═══════════════════════════════════════════${NC}"

    # Prepare data for HTML report
    app_data=$(head -n 10 "$temp_app_file" | \
        awk '{printf "[\"%s\", %d],", $1, $2}' | \
        sed 's/,$//')

    # Generate HTML report
    html_file="syslog_report_24h.html"
    cat <<EOF > "$html_file"


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>System Log Error Report (Last 24 Hours)</title>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
        }
        .chart-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 20px auto;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            max-width: 1200px;
        }
        h1, h2 {
            text-align: center;
            color: #333;
        }
        .system-info {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 20px auto;
            max-width: 1200px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .card {
            background: white;
            border-radius: 8px;
            padding: 15px;
            margin: 10px 0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .resource-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .error-summary {
            padding: 15px;
            margin-top: 20px;
            border-radius: 4px;
            background-color: #f8f9fa;
        }
        .error-summary h3 {
            margin-top: 0;
            color: #2c3e50;
        }
    </style>
    <script type="text/javascript">
        google.charts.load('current', {packages:['corechart']});
        google.charts.setOnLoadCallback(drawCharts);

        function drawCharts() {
            // Error types pie chart
            var errorData = google.visualization.arrayToDataTable([
                ['Error Type', 'Count'],
                ['Memory', ${error_counts[memory]:-0}],
                ['Throttling', ${error_counts[throttling]:-0}],
                ['Disk I/O', ${error_counts[disk_io]:-0}],
                ['BIOS', ${error_counts[bios]:-0}],
                ['Network', ${error_counts[network]:-0}],
                ['Filesystem', ${error_counts[filesystem]:-0}],
                ['High Load', ${error_counts[highload]:-0}]
            ]);

            var errorOptions = {
                title: 'Error Distribution (Last 24 Hours)',
                pieHole: 0.4,
                colors: ['#e74c3c', '#3498db', '#2ecc71', '#f1c40f', '#9b59b6', '#e67e22', '#1abc9c'],
                chartArea: {width: '80%', height: '80%'},
                legend: {position: 'right'}
            };

            var errorChart = new google.visualization.PieChart(document.getElementById('error_distribution'));
            errorChart.draw(errorData, errorOptions);

            // Application errors chart
            var appData = google.visualization.arrayToDataTable([
                ['Application', 'Errors'],
                ${app_data}
            ]);

            var appOptions = {
                title: 'Top Applications by Error Count',
                chartArea: {width: '60%', height: '80%'},
                legend: {position: 'none'},
                bars: 'horizontal',
                hAxis: {title: 'Error Count'},
                vAxis: {title: 'Application'}
            };

            var appChart = new google.visualization.BarChart(document.getElementById('app_chart'));
            appChart.draw(appData, appOptions);
        }
    </script>
</head>
<body>
    <h1>System Log Error Report (Last 24 Hours)</h1>
    
    <div class="system-info">
        <h2>System Information</h2>
        <div class="resource-grid">
            <div class="card">
                <h3>Scan Period</h3>
                <p><strong>From:</strong> $date_start</p>
                <p><strong>To:</strong> $date_end</p>
            </div>
            <div class="card">
                <h3>System Status</h3>
                <p><strong>CPU Load:</strong> $(uptime | cut -d':' -f4-)</p>
                <p><strong>Memory Free:</strong> $(free -h | awk '/^Mem:/ {print $4}')</p>
                <p><strong>Disk Usage:</strong> $(df -h / | awk 'NR==2 {print $5}')</p>
            </div>
            <div class="card">
                <h3>Files Analyzed</h3>
                <ul>
                    $(if [[ -f "$base_path" ]]; then echo "<li>Current log ($base_path)</li>"; fi)
                    $(if [[ -f "${base_path}.1" ]]; then echo "<li>Previous log (${base_path}.1)</li>"; fi)
                    $(for f in ${base_path}.[0-9]*.gz; do
                        if [[ -f "$f" ]]; then
                            echo "<li>Backup: $(basename "$f")</li>"
                        fi
                    done)
                </ul>
            </div>
            <div class="card">
                <h3>Error Summary</h3>
                <p><strong>Total Errors Found:</strong> $(grep -c "error\|fail\|critical\|emergency\|alert\|panic\|fatal" "$temp_file" || echo 0)</p>
            </div>
        </div>
    </div>

    <div class="chart-container">
        <div id="error_distribution" style="width: 100%; height: 500px;"></div>
    </div>

    <div class="chart-container">
        <div id="app_chart" style="width: 100%; height: 500px;"></div>
    </div>
</body>
</html>
EOF

    # Cleanup temporary files
    rm -f "$temp_app_file"
    rm -f "$temp_file"
    
    echo -e "\n${GREEN}HTML report generated:${NC} ${BLUE}$html_file${NC}"
    echo -e "\nNote: This analysis includes data from all available syslog files and their backups"
    
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}${CYAN}                  Scan Complete                    ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}\n"
}

function scan_past_week()
{
    scan_syslog_last_7_days
}

function scan_entire_system()
{
    scan_syslog
}

function scan_today()
{
    scan_syslog_last_24h
}
