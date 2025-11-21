# Quick Start Guide - System Log Analysis Tool

## Table of Contents
1. [Installation](#installation)
2. [First Run](#first-run)
3. [Common Use Cases](#common-use-cases)
4. [Sample Commands](#sample-commands)
5. [Understanding Output](#understanding-output)
6. [Troubleshooting](#troubleshooting)

## Installation

### Prerequisites
- Unix/Linux operating system
- Bash shell (version 4.0 or higher)
- Standard Unix utilities (grep, awk, sed, etc.)

### Quick Install

```bash
# Clone the repository
git clone https://github.com/vivek-chandan/SYSTEM-LOG-ANALYSIS.git

# Navigate to directory
cd SYSTEM-LOG-ANALYSIS

# Make scripts executable
chmod +x *.sh

# Run the tool
./main.sh
```

### Verify Installation

```bash
# Check Bash version (should be 4.0+)
bash --version

# Verify required tools
which grep awk sed
```

## First Run

### Starting the Application

```bash
./main.sh
```

You'll see an interactive menu:

```
╔════════════════════════════════════════╗
║            SYSTEM MENU                 ║
╚════════════════════════════════════════╝

  ╔════════════════════════════════╗
  ║ Select an option:              ║
  ╠════════════════════════════════╣
  ║ 1) Analyze a log file          ║
  ║ 2) Run system scan             ║
  ║ 3) Exit                        ║
  ╚════════════════════════════════╝
```

### Menu Navigation

- **Option 1**: Analyze a specific log file (General, Windows, or Mac)
- **Option 2**: Scan system logs (syslog) for different time periods
- **Option 3**: Exit the program

## Common Use Cases

### Use Case 1: Quick System Health Check

**Scenario**: You want to check if there are any errors in the last 24 hours.

**Steps**:
1. Run `./main.sh`
2. Select option `2` (Run system scan)
3. Select option `3` (Today)
4. Review the terminal output
5. Open the generated HTML report: `syslog_report_24h.html`

**Expected Output**:
- System resource status (disk, memory, CPU)
- Error categorization
- Application error counts
- HTML report with charts

### Use Case 2: Analyze Application Logs

**Scenario**: You have an application log file and want to find all errors.

**Steps**:
1. Run `./main.sh`
2. Select option `1` (Analyze a log file)
3. Select option `1` (General)
4. Enter the path to your log file (e.g., `/var/log/myapp.log`)
5. Select option `1` (Run general scan)

**Expected Output**:
- Error count
- Warning count
- Info message count
- Pattern analysis
- HTML report: `myapp_report.html`

### Use Case 3: Search for Specific Errors

**Scenario**: You're troubleshooting authentication issues.

**Steps**:
1. Run `./main.sh`
2. Select option `1` (Analyze a log file)
3. Select option `1` (General)
4. Enter the path to your log file
5. Select option `2` (Search for a particular error)
6. Enter: `authentication failure`

**Expected Output**:
- All occurrences of "authentication failure"
- Context lines (before and after each match)
- Total occurrence count

### Use Case 4: Weekly Trend Analysis

**Scenario**: You want to see error trends over the past week.

**Steps**:
1. Run `./main.sh`
2. Select option `2` (Run system scan)
3. Select option `2` (One week)

**Expected Output**:
- Weekly error summary by category
- Daily error breakdown with bar graphs
- Top applications by error count
- HTML trend report: `syslog_trend_report.html`

### Use Case 5: Complete System Audit

**Scenario**: Full system log analysis including all historical data.

**Steps**:
1. Run `./main.sh`
2. Select option `2` (Run system scan)
3. Select option `1` (Entire duration)

**Expected Output**:
- Complete error analysis from all syslog files
- Error type distribution
- Application error analysis
- HTML report: `syslog_report.html`

## Sample Commands

### Direct Script Execution

While the tool is designed for interactive use, you can also source the scripts directly:

```bash
# Analyze a specific log file
source scan_log.sh
analyze_log "/var/log/syslog"

# Run a pattern search
source scan_log.sh
analyze_patterns "/var/log/auth.log" "failed password" "Auth Failures"

# Run system scan
source system_scan.sh
scan_syslog_last_24h
```

### Automated Execution

For scheduled scans, create a wrapper script:

```bash
#!/bin/bash
# auto_scan.sh

cd /path/to/SYSTEM-LOG-ANALYSIS
source system_scan.sh
scan_syslog_last_24h > /var/log/daily_scan_$(date +%Y%m%d).log
```

Schedule with cron:
```bash
# Run daily at 2 AM
0 2 * * * /path/to/auto_scan.sh
```

## Understanding Output

### Terminal Output

#### Color Coding

- **🔵 Blue**: Headers and section dividers
- **🔷 Cyan**: Menu boxes and separators
- **🟢 Green**: Success messages and prompts
- **🟡 Yellow**: Information and file paths
- **🔴 Red**: Errors and high-priority issues
- **🟣 Purple**: Section titles

#### Progress Indicators

```
Progress: [██████████████████████....] 75%
```
- Shows analysis progress for large files
- Updates in real-time

#### Terminal Graphs

```
Memory error           |████████████░░░░░░░░ 15
CPU throttling         |██░░░░░░░░░░░░░░░░░░ 3
Disk I/O error         |████████████████████ 25
```
- Bar length proportional to error count
- Colors indicate severity

### HTML Reports

#### Report Sections

1. **Header**: Report title and generation time
2. **File Information**: Name, size, line count
3. **Statistics Cards**: Quick summary numbers
4. **Charts**: Visual representation of data
5. **Tables**: Detailed error breakdown

#### Chart Types

**Pie Chart**: Shows distribution of error types
```
Used for: Understanding which error category is most common
```

**Bar Chart**: Compares error counts
```
Used for: Ranking applications by error frequency
```

**Line Chart**: Shows trends over time
```
Used for: Identifying patterns in daily errors
```

#### Interpreting Charts

- **Red segments**: High-priority errors
- **Yellow segments**: Medium-priority warnings
- **Blue segments**: Informational messages

### Example Output Interpretation

```
Error Type Analysis:
Memory error occurrences              : 45
CPU throttling errors                 : 12
Disk I/O errors                       : 8
```

**What this means**:
- Memory is the primary issue (45 occurrences)
- CPU is being throttled (possible overheating)
- Some disk problems but less severe

**Action Items**:
1. Investigate memory usage (check for memory leaks)
2. Check CPU temperatures
3. Run disk diagnostics

## Troubleshooting

### Common Issues

#### Issue 1: Permission Denied

**Error**:
```
Error: File '/var/log/syslog' is not readable
```

**Solution**:
```bash
# Run with sudo
sudo ./main.sh

# Or give yourself read permissions
sudo chmod +r /var/log/syslog
```

#### Issue 2: Command Not Found

**Error**:
```
bash: ./main.sh: No such file or directory
```

**Solution**:
```bash
# Make sure you're in the correct directory
pwd
ls -la main.sh

# Make script executable
chmod +x main.sh
```

#### Issue 3: No Errors Found

**Output**:
```
Total occurrences: 0
```

**Possible Causes**:
1. Log file is empty
2. Wrong log format
3. Date range doesn't match log entries

**Solution**:
```bash
# Verify log has content
wc -l /path/to/logfile

# Check log format
head /path/to/logfile

# Try different time range or general analysis
```

#### Issue 4: HTML Report Not Generated

**Error**:
```
Error: Failed to generate HTML report
```

**Solution**:
```bash
# Check disk space
df -h

# Check permissions in current directory
ls -ld .

# Verify write permissions
touch test_file && rm test_file
```

#### Issue 5: Garbled Characters in Terminal

**Issue**: Special characters don't display correctly

**Solution**:
```bash
# Set locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Run again
./main.sh
```

### Debug Mode

Enable debugging to see what's happening:

```bash
# Run with debug output
bash -x ./main.sh

# Or add to the script
set -x  # Enable debug mode
set +x  # Disable debug mode
```

### Getting Help

1. **Check Documentation**:
   - README.md - Overview
   - INTERVIEW_GUIDE.md - Q&A
   - TECHNICAL_DOCUMENTATION.md - Details

2. **Verify Environment**:
   ```bash
   # Check Bash version
   bash --version
   
   # Verify tools
   which grep awk sed wc cat
   ```

3. **Test with Sample Data**:
   ```bash
   # Create test log
   echo "2024-01-01 10:00:00 ERROR: Test error" > test.log
   echo "2024-01-01 10:01:00 WARNING: Test warning" >> test.log
   
   # Analyze
   source scan_log.sh
   analyze_log test.log
   ```

## Tips and Best Practices

### Performance Tips

1. **For Large Files** (> 1GB):
   - Use specific time ranges instead of "entire duration"
   - Consider splitting logs before analysis
   - Run during off-peak hours

2. **For Faster Analysis**:
   - Use specific error search instead of general scan
   - Limit to recent time periods
   - Process compressed logs directly (no need to decompress first)

### Analysis Best Practices

1. **Start Broad, Then Narrow**:
   - First run: General scan
   - Second run: Focus on specific error types
   - Third run: Search for exact patterns

2. **Compare Time Periods**:
   - Run weekly scans to identify trends
   - Compare daily reports to spot anomalies
   - Archive reports for historical comparison

3. **Regular Monitoring**:
   - Schedule daily scans
   - Review weekly trends
   - Investigate sudden spikes

### Report Management

1. **Organization**:
   ```bash
   # Create reports directory
   mkdir -p reports/$(date +%Y-%m)
   
   # Move reports after generation
   mv *.html reports/$(date +%Y-%m)/
   ```

2. **Archiving**:
   ```bash
   # Compress old reports
   tar -czf reports_2024-01.tar.gz reports/2024-01/
   ```

3. **Cleanup**:
   ```bash
   # Remove reports older than 30 days
   find reports/ -name "*.html" -mtime +30 -delete
   ```

## Quick Reference Card

### Most Common Commands

```bash
# Start the tool
./main.sh

# Quick 24-hour check
./main.sh → 2 → 3

# Analyze specific file
./main.sh → 1 → 1 → [filepath] → 1

# Weekly trends
./main.sh → 2 → 2

# Search for specific error
./main.sh → 1 → 1 → [filepath] → 2 → [pattern]
```

### Key File Locations

```
./main.sh                    - Main entry point
./scan_log.sh                - Log analysis functions
./system_scan.sh             - System scan functions
./analyze_windows_log.sh     - Windows analysis
./analyze_macc.sh            - macOS analysis

Reports:
*.html                       - Generated HTML reports
/var/log/syslog             - System logs (Linux)
```

### Exit Codes

- `0`: Success
- `1`: File not found or not readable
- `1`: Invalid input
- Other: Script-specific error

## Next Steps

After completing this quick start:

1. **Review** the [README.md](README.md) for comprehensive overview
2. **Study** the [INTERVIEW_GUIDE.md](INTERVIEW_GUIDE.md) for interview prep
3. **Deep Dive** into [TECHNICAL_DOCUMENTATION.md](TECHNICAL_DOCUMENTATION.md) for details
4. **Practice** with sample log files
5. **Customize** for your specific needs

## Additional Resources

- Bash Scripting Guide: https://tldp.org/LDP/abs/html/
- Regular Expressions: https://www.regular-expressions.info/
- Chart.js Documentation: https://www.chartjs.org/
- Linux Log Files: https://www.cyberciti.biz/faq/linux-log-files-location-and-how-do-i-view-logs-files/

---

**Remember**: The best way to learn is by doing. Try different log files, experiment with options, and review the generated reports!
