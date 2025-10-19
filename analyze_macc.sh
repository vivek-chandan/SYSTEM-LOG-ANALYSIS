#!/bin/bash

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Main Log Analysis Function
function analyze_mac() {
    local log_file="$1"
    
    # Mac-specific log categorization
    declare -A log_categories=(
        ["KERNEL_ISSUES"]=$(grep -Ei "kernel|panic|assertion|failure" "$log_file" | wc -l)
        ["SYSTEM_SERVICES"]=$(grep -Ei "com\.apple\.|daemon|agent|service" "$log_file" | wc -l)
        ["HARDWARE_EVENTS"]=$(grep -Ei "disk|memory|cpu|battery|thermal|fan|power|sleep|wake" "$log_file" | wc -l)
        ["NETWORK_ISSUES"]=$(grep -Ei "network|wifi|ethernet|connection|disconnect|timeout|dns" "$log_file" | wc -l)
        ["APP_CRASHES"]=$(grep -Ei "crash|terminated|exit|killed" "$log_file" | wc -l)
        ["CRITICAL"]=$(grep -Ei "critical|fatal|emergency" "$log_file" | wc -l)
        ["ERROR"]=$(grep -Ei "error|fail|severe" "$log_file" | wc -l)
        ["WARNING"]=$(grep -Ei "warning|warn|alert" "$log_file" | wc -l)
        ["SECURITY"]=$(grep -Ei "security|permission|authorize|authenticate" "$log_file" | wc -l)
        ["SCHEDULER"]=$(grep -Ei "scheduler_evaluate_activity|schedule|task|job" "$log_file" | wc -l)
    )

    # Terminal Output
    echo -e "\n${BOLD}${WHITE}📊 MAC LOG ANALYSIS REPORT${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    
    printf "${BOLD}%-25s %s${NC}\n" "CATEGORY" "COUNT"
    echo -e "${CYAN}───────────────────────────────────────${NC}"
    
    for category in "${!log_categories[@]}"; do
        count=${log_categories[$category]}
        if [[ $count -gt 0 ]]; then
            printf "%-25s %d\n" "$category" "$count"
        fi
    done
    
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    
    # Error Context Display
    echo -e "\n${BOLD}${WHITE}🔍 DETAILED LOG ANALYSIS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    
    if [[ ${log_categories[KERNEL_ISSUES]} -gt 0 ]]; then
        echo -e "\n${BLUE}Kernel Issues:${NC}"
        grep -Ei "kernel|panic|assertion|failure" "$log_file" | head -n 3
    fi
    
    if [[ ${log_categories[APP_CRASHES]} -gt 0 ]]; then
        echo -e "\n${BLUE}Application Crashes:${NC}"
        grep -Ei "crash|terminated|exit|killed" "$log_file" | head -n 3
    fi

    if [[ ${log_categories[SECURITY]} -gt 0 ]]; then
        echo -e "\n${BLUE}Security Events:${NC}"
        grep -Ei "security|permission|authorize|authenticate" "$log_file" | head -n 3
    fi
    
     generate_html_report_mac "$log_file" "${log_categories[@]}"
}

# HTML Report Generator
function  generate_html_report_mac() {
    local log_file="$1"
    local report_file="${log_file%.*}_mac_report.html"
    
    cat > "$report_file" << EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Mac Log Analysis Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            background-color: #f8f9fa;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen-Sans, Ubuntu, Cantarell, sans-serif;
            color: #333;
        }
        .dashboard {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 30px;
            margin: 20px 0;
        }
        .chart-container {
            position: relative;
            margin: 20px 0;
            height: 400px;
        }
        h1, h2 {
            color: #2c3e50;
            margin-bottom: 20px;
        }
        .table {
            margin-top: 20px;
            border-radius: 8px;
            overflow: hidden;
        }
        .table th {
            background-color: #f8f9fa;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="container py-4">
        <div class="dashboard">
            <h1 class="text-center">Mac System Log Analysis</h1>
            
            <div class="row">
                <div class="col-md-6">
                    <div class="chart-container">
                        <canvas id="eventChart"></canvas>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="chart-container">
                        <canvas id="distributionChart"></canvas>
                    </div>
                </div>
            </div>

            <div class="table-responsive mt-4">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Category</th>
                            <th>Event Count</th>
                        </tr>
                    </thead>
                    <tbody>
                        $(for category in "${!log_categories[@]}"; do
                            echo "<tr><td>$category</td><td>${log_categories[$category]}</td></tr>"
                        done)
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        const ctx1 = document.getElementById('eventChart').getContext('2d');
        new Chart(ctx1, {
            type: 'bar',
            data: {
                labels: [$(for category in "${!log_categories[@]}"; do echo "'$category',"; done)],
                datasets: [{
                    label: 'Event Count',
                    data: [$(for category in "${!log_categories[@]}"; do echo "${log_categories[$category]},"; done)],
                    backgroundColor: 'rgba(0, 122, 255, 0.7)',
                    borderColor: 'rgba(0, 122, 255, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: 'Event Distribution by Category'
                    }
                }
            }
        });

        const ctx2 = document.getElementById('distributionChart').getContext('2d');
        new Chart(ctx2, {
            type: 'doughnut',
            data: {
                labels: [$(for category in "${!log_categories[@]}"; do echo "'$category',"; done)],
                datasets: [{
                    data: [$(for category in "${!log_categories[@]}"; do echo "${log_categories[$category]},"; done)],
                    backgroundColor: [
                        'rgba(0, 122, 255, 0.7)',    // Blue
                        'rgba(88, 86, 214, 0.7)',    // Purple
                        'rgba(255, 45, 85, 0.7)',    // Red
                        'rgba(52, 199, 89, 0.7)',    // Green
                        'rgba(255, 149, 0, 0.7)',    // Orange
                        'rgba(175, 82, 222, 0.7)',   // Purple
                        'rgba(255, 59, 48, 0.7)',    // Red
                        'rgba(90, 200, 250, 0.7)',   // Blue
                        'rgba(255, 204, 0, 0.7)',    // Yellow
                        'rgba(88, 86, 214, 0.7)'     // Purple
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: 'Overall Event Distribution'
                    }
                }
            }
        });
    </script>
</body>
</html>
EOL

    echo -e "\n${GREEN}✅ HTML Report Generated: ${WHITE}$report_file${NC}"
}

# Help Function
function show_mac_help() {
    echo -e "${BOLD}${WHITE}Mac Log Analysis Script Usage${NC}"
    echo -e "\n${CYAN}Command:${NC}"
    echo -e "  ./script.sh <log_file_path>"
    
    echo -e "\n${CYAN}Categories Analyzed:${NC}"
    echo "  - KERNEL_ISSUES: Kernel-related problems and panics"
    echo "  - SYSTEM_SERVICES: System service and daemon events"
    echo "  - HARDWARE_EVENTS: Hardware-related events and issues"
    echo "  - NETWORK_ISSUES: Network connectivity problems"
    echo "  - APP_CRASHES: Application crash reports"
    echo "  - CRITICAL/ERROR/WARNING: Severity levels"
    echo "  - SECURITY: Security-related events"
    echo "  - SCHEDULER: Scheduling and task management events"
}

# Only show help if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
        show_mac_help
        exit 0
    fi

    if [[ ! -f "$1" ]]; then
        echo -e "${RED}Error: Log file not found${NC}"
        exit 1
    fi

    analyze_mac "$1"
fi