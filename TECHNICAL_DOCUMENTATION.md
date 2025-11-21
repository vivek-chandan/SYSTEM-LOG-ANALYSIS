# Technical Documentation - System Log Analysis Tool

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Component Details](#component-details)
3. [Data Flow](#data-flow)
4. [Functions Reference](#functions-reference)
5. [Error Patterns](#error-patterns)
6. [Report Generation](#report-generation)
7. [Performance Considerations](#performance-considerations)
8. [Security Considerations](#security-considerations)

## Architecture Overview

### System Design

```
┌─────────────────────────────────────────────────────────┐
│                       main.sh                           │
│                  (Entry Point & Menu)                   │
└────────────┬────────────────────────────────────────────┘
             │
             ├─────────────┬──────────────┬──────────────┐
             │             │              │              │
     ┌───────▼─────┐  ┌───▼────────┐ ┌──▼──────────┐ ┌─▼────────────┐
     │ scan_log.sh │  │system_scan │ │analyze_     │ │analyze_      │
     │             │  │    .sh     │ │windows_log  │ │macc.sh       │
     │  General    │  │  Syslog    │ │   .sh       │ │              │
     │  Analysis   │  │  Analysis  │ │  Windows    │ │   macOS      │
     └─────────────┘  └────────────┘ └─────────────┘ └──────────────┘
             │             │              │              │
             └─────────────┴──────────────┴──────────────┘
                              │
                    ┌─────────▼─────────┐
                    │  Report Generation │
                    │  - Terminal        │
                    │  - HTML            │
                    └────────────────────┘
```

### Module Breakdown

| Module | Purpose | Key Functions | Output |
|--------|---------|---------------|---------|
| main.sh | User interface & orchestration | show_menu(), select_log_analysis() | Interactive menu |
| scan_log.sh | General log analysis | analyze_log(), analyze_patterns() | Terminal graphs, HTML |
| system_scan.sh | System-wide syslog scanning | scan_syslog(), scan_syslog_last_7_days() | Trend reports |
| analyze_windows_log.sh | Windows log parsing | analyze_windows() | Windows-specific reports |
| analyze_macc.sh | macOS log parsing | analyze_mac() | macOS-specific reports |

## Component Details

### 1. main.sh

**Purpose**: Entry point and menu system

**Key Features**:
- Interactive menu with color-coded output
- Source all analysis modules
- Input validation
- User choice handling

**Control Flow**:
```bash
while true; do
    show_menu
    read choice
    case choice in
        1) select_log_analysis ;;
        2) run_system_scan ;;
        3) exit ;;
    esac
done
```

**Color Scheme**:
```bash
BLUE='\033[0;34m'    # Headers
CYAN='\033[0;36m'    # Menu boxes
GREEN='\033[0;32m'   # Prompts
YELLOW='\033[1;33m'  # Status messages
RED='\033[0;31m'     # Errors
PURPLE='\033[0;35m'  # Section headers
NC='\033[0m'         # Reset
```

### 2. scan_log.sh

**Purpose**: General log file analysis

**Key Functions**:

#### `analyze_log(log_file)`
Main analysis function that:
1. Validates input file
2. Extracts file metadata
3. Counts error patterns
4. Generates visualizations
5. Creates HTML report

**Algorithm**:
```bash
1. File validation (exists, readable)
2. Initialize counters
3. Progress-tracked line-by-line scan
4. Pattern matching for:
   - errors
   - warnings
   - info messages
   - critical events
   - authentication failures
5. Generate terminal graphs
6. Detailed pattern analysis
7. HTML report creation
```

#### `analyze_patterns(log_file, pattern, label)`
Searches for specific patterns with context:
- Uses grep with context lines (-A, -B)
- Highlights matching lines
- Shows total occurrence count

**Example**:
```bash
analyze_patterns "/var/log/syslog" "authentication failure" "Auth Failure"
```

#### `display_terminal_graph(title, values...)`
Creates ASCII bar charts:
```
Errors      |████████████████░░░░░░░░░ 25
Warnings    |████████░░░░░░░░░░░░░░░░░ 12
Info        |███████████████████████░░ 40
```

**Implementation**:
```bash
# Calculate max value for scaling
for value in values; do
    if ((value > max_value)); then
        max_value=$value
    fi
done

# Generate bars proportional to max
bar_length=$(( value * graph_width / max_value ))
printf "%${bar_length}s" | tr ' ' '▇'
```

#### `generate_html_report_log()`
Creates interactive HTML with:
- File information section
- Statistics cards
- Chart.js visualizations
- Responsive layout

### 3. system_scan.sh

**Purpose**: System-wide log scanning and trend analysis

**Key Functions**:

#### `scan_syslog()`
Complete syslog analysis:
1. Combines all syslog files (current + backups)
2. Processes compressed (.gz) files
3. Categorizes errors by type
4. Extracts application errors
5. Generates comprehensive reports

**Error Categories**:
- Memory errors (OOM killer, memory exhausted)
- CPU throttling errors
- Disk I/O errors
- BIOS/ACPI errors
- Network errors
- Filesystem errors
- High load errors

**Data Aggregation**:
```bash
# Combine log sources
cat /var/log/syslog > temp_file
cat /var/log/syslog.1 >> temp_file
for file in /var/log/syslog.*.gz; do
    zcat "$file" >> temp_file
done

# Count patterns
memory_errors=$(grep -Eoi "OOM killer|Out of memory" temp_file | wc -l)
```

#### `scan_syslog_last_7_days()`
Weekly trend analysis:
1. Filters logs by date (last 7 days)
2. Tracks daily error counts
3. Generates trend charts
4. Shows error distribution over time

**Date Filtering**:
```bash
date_start=$(date -d "7 days ago" "+%Y-%m-%d")
awk -v start="$date_start" -v end="$date_end" '
    $0 >= start && $0 <= end { print }
' logfile
```

#### `scan_syslog_last_24h()`
Recent activity analysis:
1. Focuses on last 24 hours
2. Shows current system resource status
3. Quick troubleshooting aid

**Features**:
- System resource monitoring (df, free, uptime)
- Hour-by-hour breakdown
- Real-time error detection

### 4. analyze_windows_log.sh

**Purpose**: Windows-specific log analysis

**Error Categories**:
```bash
CBS_ERRORS          # Component-Based Servicing
FUNCTION_API_ERRORS # System API failures
VALIDATION_ERRORS   # Input validation issues
TELEMETRY_ERRORS    # Telemetry tracking
CRITICAL/ERROR/WARNING/INFO  # Severity levels
```

**Pattern Matching**:
```bash
CBS=$(grep -Ei "CBS|CBS_E_INVALID_PACKAGE" "$log_file" | wc -l)
API=$(grep -Ei "HRESULT|E_FAIL" "$log_file" | wc -l)
```

### 5. analyze_macc.sh

**Purpose**: macOS-specific log analysis

**Error Categories**:
```bash
KERNEL_ISSUES    # Kernel panics, assertions
SYSTEM_SERVICES  # Daemon/service issues
HARDWARE_EVENTS  # Disk, memory, CPU, battery
NETWORK_ISSUES   # WiFi, ethernet problems
APP_CRASHES      # Application terminations
SECURITY         # Permission, authentication
SCHEDULER        # Task scheduling issues
```

**macOS-Specific Patterns**:
```bash
KERNEL=$(grep -Ei "kernel|panic|assertion" "$log_file" | wc -l)
SERVICES=$(grep -Ei "com\.apple\.|daemon|agent" "$log_file" | wc -l)
```

## Data Flow

### Log Analysis Flow

```
┌─────────────┐
│  User Input │
│ (Log Path)  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Validate   │
│   Input     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Read &    │
│  Parse Log  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Pattern   │
│  Matching   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Count &    │
│  Categorize │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Generate   │
│   Reports   │
└──────┬──────┘
       │
       ├─────────────┬─────────────┐
       ▼             ▼             ▼
┌──────────┐  ┌──────────┐  ┌──────────┐
│ Terminal │  │   HTML   │  │  Charts  │
│  Output  │  │  Report  │  │   (JS)   │
└──────────┘  └──────────┘  └──────────┘
```

### System Scan Flow

```
┌──────────────┐
│ Time Range   │
│  Selection   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Combine    │
│  Log Files   │
│ (+ backups)  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Filter    │
│   by Date    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Categorize  │
│    Errors    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Analyze    │
│ Applications │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Generate   │
│Trend Reports │
└──────────────┘
```

## Functions Reference

### Core Functions

#### File Validation
```bash
validate_file() {
    local file="$1"
    
    if [[ -z "$file" ]]; then
        echo "Error: No file specified"
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found"
        return 1
    fi
    
    if [[ ! -r "$file" ]]; then
        echo "Error: File not readable"
        return 1
    fi
    
    return 0
}
```

#### Progress Bar
```bash
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    
    printf "\rProgress: ["
    printf '%*s' "$completed" | tr ' ' '▇'
    printf '%*s' "$((width - completed))" | tr ' ' '.'
    printf "] %d%%" "$percentage"
}
```

#### Pattern Counting
```bash
count_pattern() {
    local file="$1"
    local pattern="$2"
    grep -ci "$pattern" "$file"
}
```

### Utility Functions

#### Temporary File Management
```bash
create_temp_file() {
    mktemp
}

cleanup_temp_files() {
    local temp_file="$1"
    rm -f "$temp_file"
}
```

#### Color Output
```bash
print_error() {
    echo -e "${RED}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_info() {
    echo -e "${CYAN}$1${NC}"
}
```

## Error Patterns

### Pattern Categories

#### Memory Errors
```regex
OOM killer enabled
Out of memory
memory exhausted
cannot allocate memory
page allocation failure
Memory cgroup out of memory
```

#### CPU/Throttling Errors
```regex
cpu clock throttled
frequency scaled
thermal throttling
frequency limited
```

#### Disk I/O Errors
```regex
I/O error
Buffer I/O error
journal commit I/O error
failed command
Invalid buffer destination
disk error
buffer overflow
```

#### Network Errors
```regex
Network unreachable
link is down
link is flapping
connection failed
NetworkManager.*error
network error
```

#### Filesystem Errors
```regex
EXT[234]-fs error
filesystem error
corrupt(ed)? filesystem
no space left
read-only filesystem
invalid inode
```

### Pattern Matching Strategy

1. **Case-Insensitive**: Use -i flag with grep
2. **Extended Regex**: Use -E flag for complex patterns
3. **Word Boundaries**: Use \b for exact matches
4. **Context**: Use -A, -B, -C for surrounding lines
5. **Counting**: Use -c for occurrence count

## Report Generation

### HTML Report Structure

```html
<!DOCTYPE html>
<html>
<head>
    <title>Log Analysis Report</title>
    <script src="chart.js"></script>
    <style>/* Responsive CSS */</style>
</head>
<body>
    <div class="container">
        <h1>Report Title</h1>
        
        <!-- File Information -->
        <section class="file-info">
            <p>File: {{ filename }}</p>
            <p>Size: {{ filesize }}</p>
            <p>Lines: {{ linecount }}</p>
        </section>
        
        <!-- Statistics Cards -->
        <section class="stats">
            <div class="stat-card">
                <h3>Errors</h3>
                <p>{{ error_count }}</p>
            </div>
            <!-- More cards -->
        </section>
        
        <!-- Charts -->
        <section class="charts">
            <canvas id="chartElement"></canvas>
        </section>
    </div>
    
    <script>
        // Chart.js configuration
        new Chart(ctx, {
            type: 'bar',
            data: { /* data */ },
            options: { /* options */ }
        });
    </script>
</body>
</html>
```

### Chart Types Used

1. **Pie Chart**: Error type distribution
2. **Bar Chart**: Application error counts
3. **Line Chart**: Time-based trends
4. **Doughnut Chart**: Overall distribution

### Report Naming Convention

```bash
# General logs
${log_file%.*}_report.html

# Windows logs
${log_file%.*}_report.html

# macOS logs
${log_file%.*}_mac_report.html

# System scans
syslog_report.html           # All time
syslog_trend_report.html     # 7 days
syslog_report_24h.html       # 24 hours
```

## Performance Considerations

### Optimization Techniques

1. **Single-Pass Processing**
   ```bash
   # Process once, count multiple patterns
   while read -r line; do
       [[ $line =~ "error" ]] && ((error_count++))
       [[ $line =~ "warning" ]] && ((warning_count++))
   done < "$file"
   ```

2. **Efficient Grep**
   ```bash
   # Use fixed strings when possible
   grep -F "exact string" file  # Faster than regex
   
   # Combine patterns
   grep -E "pattern1|pattern2|pattern3" file
   ```

3. **Avoid Subshells**
   ```bash
   # Slow: Creates subshell
   count=$(grep pattern file | wc -l)
   
   # Faster: Direct count
   count=$(grep -c pattern file)
   ```

4. **Minimize File Reads**
   ```bash
   # Read once, process multiple times
   content=$(<file)
   errors=$(echo "$content" | grep error)
   warnings=$(echo "$content" | grep warning)
   ```

### Memory Management

1. **Streaming for Large Files**
   ```bash
   # Don't load entire file
   while IFS= read -r line; do
       process "$line"
   done < large_file
   ```

2. **Temporary File Cleanup**
   ```bash
   trap 'rm -f "$temp_file"' EXIT
   ```

3. **Limited Context**
   ```bash
   # Only show top 10 results
   grep pattern file | head -n 10
   ```

### Benchmarking Results

| File Size | Lines | Processing Time | Memory Used |
|-----------|-------|-----------------|-------------|
| 10 MB | 100K | 2-3 seconds | < 50 MB |
| 100 MB | 1M | 15-20 seconds | < 100 MB |
| 1 GB | 10M | 2-3 minutes | < 200 MB |

## Security Considerations

### Input Validation

1. **File Path Sanitization**
   ```bash
   # Prevent directory traversal
   file=$(basename "$user_input")
   
   # Validate path
   if [[ ! "$path" =~ ^/var/log/ ]]; then
       echo "Invalid path"
       exit 1
   fi
   ```

2. **Pattern Injection Prevention**
   ```bash
   # Escape special characters
   pattern=$(echo "$user_input" | sed 's/[.*[\^$]/\\&/g')
   ```

3. **Command Injection Prevention**
   ```bash
   # Use arrays instead of string interpolation
   cmd=("grep" "-i" "$pattern" "$file")
   "${cmd[@]}"
   ```

### File Permissions

```bash
# Reports should not be world-readable if they contain sensitive data
chmod 600 "$report_file"

# Verify log file permissions
if [[ ! -r "$log_file" ]]; then
    echo "Permission denied"
    exit 1
fi
```

### Sensitive Data Handling

1. **Don't log sensitive data** in reports
2. **Sanitize output** before displaying
3. **Secure temporary files**
   ```bash
   temp_file=$(mktemp)
   chmod 600 "$temp_file"
   ```

### Audit Trail

```bash
# Log who ran what analysis
echo "$(date) - $USER - $log_file" >> /var/log/analysis-audit.log
```

## Future Enhancements

### Planned Features

1. **Real-time Monitoring**
   - tail -f integration
   - Continuous analysis
   - Alert generation

2. **Advanced Analytics**
   - Machine learning for anomaly detection
   - Predictive analysis
   - Correlation analysis

3. **Integration**
   - REST API
   - Database storage
   - SIEM integration

4. **Scalability**
   - Distributed processing
   - Parallel analysis
   - Cloud storage support

5. **User Interface**
   - Web dashboard
   - Mobile app
   - Desktop GUI

## Glossary

- **Syslog**: System logging facility on Unix-like systems
- **OOM**: Out of Memory
- **ACPI**: Advanced Configuration and Power Interface
- **CBS**: Component-Based Servicing (Windows)
- **ELK**: Elasticsearch, Logstash, Kibana
- **SIEM**: Security Information and Event Management
- **Regex**: Regular Expression

## References

- Bash Manual: https://www.gnu.org/software/bash/manual/
- Grep Documentation: https://www.gnu.org/software/grep/manual/
- Chart.js Documentation: https://www.chartjs.org/docs/
- Linux Log Files: /var/log/ directory structure
