
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
function analyze_windows() {
    local log_file="$1"
    
    # Log categorization
    declare -A log_categories=(
        ["CBS_ERRORS"]=$(grep -Ei "CBS|CBS_E_INVALID_PACKAGE|CBS_E_MANIFEST_INVALID_ITEM" "$log_file" | wc -l)
        ["FUNCTION_API_ERRORS"]=$(grep -Ei "ERROR_INVALID_FUNCTION|HRESULT|E_FAIL" "$log_file" | wc -l)
        ["VALIDATION_ERRORS"]=$(grep -Ei "Expecting|Unrecognized|attribute" "$log_file" | wc -l)
        ["TELEMETRY_ERRORS"]=$(grep -Ei "SQM" "$log_file" | wc -l)
        ["CRITICAL"]=$(grep -Ei "critical|fatal|emergency" "$log_file" | wc -l)
        ["ERROR"]=$(grep -Ei "error|severe|failure" "$log_file" | wc -l)
        ["WARNING"]=$(grep -Ei "warning|alert|issue" "$log_file" | wc -l)
        ["INFO"]=$(grep -Ei "info|information|status" "$log_file" | wc -l)
    )

    # Terminal Output
    echo -e "\n${BOLD}${WHITE}📊 LOG ANALYSIS REPORT${NC}"
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
    echo -e "\n${BOLD}${WHITE}🔍 ERROR DETAILS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    
    if [[ ${log_categories[CBS_ERRORS]} -gt 0 ]]; then
        echo -e "\n${BLUE}CBS Errors:${NC}"
        grep -Ei "CBS|CBS_E_INVALID_PACKAGE|CBS_E_MANIFEST_INVALID_ITEM" "$log_file" | head -n 3
    fi
    
    if [[ ${log_categories[FUNCTION_API_ERRORS]} -gt 0 ]]; then
        echo -e "\n${BLUE}Function/API Errors:${NC}"
        grep -Ei "ERROR_INVALID_FUNCTION|HRESULT|E_FAIL" "$log_file" | head -n 3
    fi
    
    generate_html_report_windows "$log_file" "${log_categories[@]}"
}

# HTML Report Generator
function generate_html_report_windows() {
    local log_file="$1"
    local report_file="${log_file%.*}_report.html"
    
    cat > "$report_file" << EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Log Analysis Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #333;
        }
        .dashboard {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            padding: 25px;
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
            <h1 class="text-center">Log Analysis Report</h1>
            
            <div class="row">
                <div class="col-md-6">
                    <div class="chart-container">
                        <canvas id="errorChart"></canvas>
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
                            <th>Error Category</th>
                            <th>Count</th>
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
        const ctx1 = document.getElementById('errorChart').getContext('2d');
        new Chart(ctx1, {
            type: 'bar',
            data: {
                labels: [$(for category in "${!log_categories[@]}"; do echo "'$category',"; done)],
                datasets: [{
                    label: 'Error Count',
                    data: [$(for category in "${!log_categories[@]}"; do echo "${log_categories[$category]},"; done)],
                    backgroundColor: 'rgba(54, 162, 235, 0.7)',
                    borderColor: 'rgba(54, 162, 235, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: 'Error Distribution by Category'
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
                        'rgba(255, 99, 132, 0.7)',
                        'rgba(54, 162, 235, 0.7)',
                        'rgba(255, 206, 86, 0.7)',
                        'rgba(75, 192, 192, 0.7)',
                        'rgba(153, 102, 255, 0.7)',
                        'rgba(255, 159, 64, 0.7)',
                        'rgba(199, 199, 199, 0.7)',
                        'rgba(83, 102, 255, 0.7)'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: 'Overall Error Distribution'
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
function show_help() {
    echo -e "${BOLD}${WHITE}Log Analysis Script Usage${NC}"
    echo -e "\n${CYAN}Command:${NC}"
    echo -e "  ./script.sh <log_file_path>"
    
    echo -e "\n${CYAN}Categories Analyzed:${NC}"
    echo "  - CBS_ERRORS: Component-Based Servicing issues"
    echo "  - FUNCTION_API_ERRORS: System function and API failures"
    echo "  - VALIDATION_ERRORS: Input validation issues"
    echo "  - TELEMETRY_ERRORS: Telemetry tracking errors"
    echo "  - CRITICAL/ERROR/WARNING/INFO: Standard severity levels"
}