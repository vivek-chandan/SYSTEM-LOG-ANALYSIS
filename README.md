# System Log Analysis Tool

A comprehensive Bash-based log analysis tool that provides automated scanning and visualization of system logs across Linux, Windows, and macOS platforms. This tool helps system administrators and DevOps engineers quickly identify and troubleshoot system issues.

## 🚀 Features

### Multi-Platform Support
- **Linux/General Logs**: Analyzes syslog and general log files
- **Windows Logs**: Specialized analysis for Windows event logs
- **macOS Logs**: Tailored analysis for Apple system logs

### Analysis Capabilities
- **Error Pattern Detection**: Automatically identifies common error patterns
- **Trend Analysis**: Tracks error trends over time (24 hours, 7 days, all time)
- **Visual Reports**: Generates interactive HTML reports with charts and graphs
- **Real-time Monitoring**: Color-coded terminal output for quick assessment
- **Statistical Analysis**: Counts and categorizes errors by type

### Report Types
- **Terminal Reports**: Color-coded, formatted output in the terminal
- **HTML Reports**: Interactive web-based reports with Chart.js visualizations
- **Trend Analysis**: Daily/weekly trend reports showing error patterns over time

## 📋 Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Features Breakdown](#features-breakdown)
- [Architecture](#architecture)
- [Output Examples](#output-examples)
- [Contributing](#contributing)
- [License](#license)

## 💻 Installation

### Prerequisites
```bash
# Linux/Unix-based system with Bash shell
# No external dependencies required (uses standard Unix tools)
```

### Setup
```bash
# Clone the repository
git clone https://github.com/vivek-chandan/SYSTEM-LOG-ANALYSIS.git

# Navigate to the directory
cd SYSTEM-LOG-ANALYSIS

# Make scripts executable
chmod +x *.sh

# Run the main script
./main.sh
```

## 🎯 Usage

### Interactive Mode
```bash
./main.sh
```
This launches an interactive menu where you can:
1. Analyze a log file (General, Windows, or Mac)
2. Run system scan (Entire duration, Past week, or Today)
3. Exit

### Log File Analysis

#### General Log Analysis
```bash
# Through the interactive menu:
# Select option 1 → Select option 1 (General) → Enter log file path
# Choose between general scan or specific error search
```

#### Windows Log Analysis
```bash
# Through the interactive menu:
# Select option 1 → Select option 2 (Windows) → Enter log file path
```

#### macOS Log Analysis
```bash
# Through the interactive menu:
# Select option 1 → Select option 3 (Mac) → Enter log file path
```

### System Scan Options

#### Entire System Scan
- Analyzes all available syslog files including backups
- Provides comprehensive error categorization
- Generates visual HTML reports

#### Past Week Scan
- Analyzes logs from the last 7 days
- Shows daily error trends
- Identifies patterns over time

#### Today's Scan (Last 24 Hours)
- Focuses on recent system activity
- Quick troubleshooting for current issues
- Real-time system resource status

## 🔍 Features Breakdown

### 1. Error Categorization

The tool categorizes errors into several types:

**Linux/General:**
- Memory errors (OOM killer, memory exhaustion)
- CPU throttling issues
- Disk I/O errors
- BIOS/ACPI errors
- Network connectivity issues
- Filesystem errors
- High load situations

**Windows:**
- CBS (Component-Based Servicing) errors
- Function/API errors
- Validation errors
- Telemetry issues
- Critical/Error/Warning/Info levels

**macOS:**
- Kernel issues and panics
- System services problems
- Hardware events
- Network issues
- Application crashes
- Security events
- Scheduler events

### 2. Visual Analytics

- **Terminal Graphs**: ASCII-based bar charts showing error distribution
- **HTML Reports**: Interactive charts using Chart.js
  - Pie charts for error type distribution
  - Bar charts for application errors
  - Line graphs for trend analysis
  - Doughnut charts for overall distribution

### 3. Pattern Matching

Uses advanced grep patterns to identify:
- Authentication failures
- Critical system errors
- Application-specific errors
- Time-based trends
- Resource exhaustion issues

## 🏗️ Architecture

### Main Components

```
main.sh              # Entry point, interactive menu system
├── scan_log.sh      # General log analysis functions
├── system_scan.sh   # System-wide scanning (syslog analysis)
├── analyze_windows_log.sh  # Windows-specific analysis
└── analyze_macc.sh  # macOS-specific analysis
```

### Key Functions

**scan_log.sh:**
- `analyze_log()`: Main log analysis function
- `analyze_patterns()`: Pattern matching and context display
- `generate_html_report_log()`: HTML report generation
- `display_terminal_graph()`: Terminal visualization

**system_scan.sh:**
- `scan_syslog()`: Complete syslog analysis
- `scan_syslog_last_7_days()`: Weekly trend analysis
- `scan_syslog_last_24h()`: Recent activity analysis

**analyze_windows_log.sh:**
- `analyze_windows()`: Windows log parsing
- `generate_html_report_windows()`: Windows-specific HTML reports

**analyze_macc.sh:**
- `analyze_mac()`: macOS log analysis
- `generate_html_report_mac()`: macOS-specific HTML reports

## 📊 Output Examples

### Terminal Output
```
╔════════════════════════════════════════╗
║        SYSTEM LOG ERROR SCAN REPORT    ║
╚════════════════════════════════════════╝

Error Type Analysis:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Memory error occurrences              : 5
CPU throttling errors                 : 2
Disk I/O errors                       : 12
Network errors                        : 3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### HTML Report Features
- Interactive pie charts showing error distribution
- Time-series line charts for trend analysis
- Sortable tables with error details
- System information dashboard
- Responsive design for mobile/desktop viewing

## 🎓 Learning Highlights

This project demonstrates proficiency in:
- **Bash Scripting**: Advanced shell programming techniques
- **Log Analysis**: Pattern matching and data extraction
- **Data Visualization**: Terminal and web-based reporting
- **System Administration**: Understanding of Linux/Unix system logs
- **Cross-Platform Knowledge**: Multi-OS log formats
- **HTML/JavaScript**: Report generation with Chart.js
- **Error Handling**: Robust input validation
- **User Experience**: Interactive menu systems

## 🔧 Technical Skills Demonstrated

- Regular expressions (grep, awk, sed)
- File I/O operations
- Process management
- Data aggregation and analysis
- String manipulation
- Control structures (loops, conditionals)
- Functions and modularity
- Color-coded terminal output
- HTML/CSS/JavaScript integration
- Temporary file management
- Error handling and validation

## 🚀 Future Enhancements

Potential improvements that could be discussed in interviews:
- Real-time log monitoring (tail -f integration)
- Email alerts for critical errors
- Database integration for historical analysis
- Machine learning for anomaly detection
- REST API for remote log analysis
- Docker containerization
- Cloud storage integration
- Multi-threaded processing for large files
- Custom alert rules configuration
- Export to CSV/JSON formats

## 📝 Use Cases

1. **System Troubleshooting**: Quickly identify root causes of system issues
2. **Proactive Monitoring**: Detect patterns before they become critical
3. **Audit Compliance**: Generate reports for security audits
4. **Performance Analysis**: Track resource usage trends
5. **DevOps Integration**: Automated log analysis in CI/CD pipelines

## 🤝 Contributing

This is a personal project for demonstration purposes. Feedback and suggestions are welcome!

## 📄 License

This project is open source and available for educational purposes.

## 👨‍💻 Author

Vivek Chandan

## 🔗 Links

- GitHub Repository: [SYSTEM-LOG-ANALYSIS](https://github.com/vivek-chandan/SYSTEM-LOG-ANALYSIS)
