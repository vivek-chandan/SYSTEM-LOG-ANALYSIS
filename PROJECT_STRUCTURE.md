# Project Structure

This document explains the organization and purpose of each file in the System Log Analysis Tool project.

## Directory Structure

```
SYSTEM-LOG-ANALYSIS/
├── main.sh                      # Main entry point - Interactive menu system
├── scan_log.sh                  # General log file analysis module
├── system_scan.sh               # System-wide syslog scanning module
├── analyze_windows_log.sh       # Windows-specific log analysis
├── analyze_macc.sh              # macOS-specific log analysis
│
├── README.md                    # Project overview and feature list
├── INTERVIEW_GUIDE.md           # Interview Q&A and talking points
├── TECHNICAL_DOCUMENTATION.md   # Detailed technical documentation
├── QUICK_START.md               # Getting started guide
├── DEMO_GUIDE.md                # Demo scenarios and scripts
├── PROJECT_STRUCTURE.md         # This file - project organization
│
└── .git/                        # Git version control directory
```

## File Descriptions

### Core Scripts

#### main.sh
**Purpose**: Entry point and orchestration

**Responsibilities**:
- Display interactive menu
- Handle user input
- Route to appropriate analysis modules
- Source all other scripts
- Manage application flow

**Key Functions**:
- `show_header()` - Display application header
- `show_menu()` - Display main menu
- `select_log_analysis()` - Handle log file analysis path
- `run_system_scan()` - Handle system scan path

**Dependencies**: All other .sh files

**Entry Point**: Yes (run directly with `./main.sh`)

---

#### scan_log.sh
**Purpose**: General log file analysis

**Responsibilities**:
- Analyze individual log files
- Pattern matching and counting
- Terminal visualization
- HTML report generation for log files

**Key Functions**:
- `analyze_log(log_file)` - Main analysis function
- `analyze_patterns(log_file, pattern, label)` - Pattern search with context
- `display_terminal_graph(title, values...)` - ASCII bar charts
- `generate_html_report_log()` - Create HTML report
- `show_progress(current, total)` - Progress bar

**Error Categories Detected**:
- Errors (general)
- Warnings
- Info messages
- Critical events
- Alerts
- Authentication failures

**Outputs**:
- Terminal: Colored, formatted analysis
- HTML: `{logfile}_report.html`

**Dependencies**: None (can be sourced independently)

---

#### system_scan.sh
**Purpose**: System-wide syslog analysis

**Responsibilities**:
- Scan /var/log/syslog and backups
- Time-based filtering (24h, 7 days, all)
- Trend analysis
- System resource monitoring

**Key Functions**:
- `scan_syslog()` - Complete syslog scan
- `scan_syslog_last_7_days()` - Weekly trend analysis
- `scan_syslog_last_24h()` - Recent activity scan
- `scan_entire_system()` - Wrapper for full scan
- `scan_past_week()` - Wrapper for weekly scan
- `scan_today()` - Wrapper for daily scan

**Error Categories Detected**:
- Memory errors (OOM, allocation failures)
- CPU throttling issues
- Disk I/O errors
- BIOS/ACPI errors
- Network connectivity issues
- Filesystem errors
- High load situations

**Outputs**:
- Terminal: Comprehensive analysis with graphs
- HTML Reports:
  - `syslog_report.html` (all time)
  - `syslog_trend_report.html` (7 days)
  - `syslog_report_24h.html` (24 hours)

**Dependencies**: None (can be sourced independently)

**Log Sources**:
- `/var/log/syslog` (current)
- `/var/log/syslog.1` (rotated)
- `/var/log/syslog.*.gz` (compressed backups)

---

#### analyze_windows_log.sh
**Purpose**: Windows event log analysis

**Responsibilities**:
- Parse Windows-specific log formats
- Categorize Windows errors
- Generate Windows-focused reports

**Key Functions**:
- `analyze_windows(log_file)` - Main Windows analysis
- `generate_html_report_windows()` - Windows HTML report
- `show_help()` - Display help information

**Error Categories Detected**:
- CBS errors (Component-Based Servicing)
- Function/API errors (HRESULT, E_FAIL)
- Validation errors
- Telemetry errors
- Critical/Error/Warning/Info levels

**Outputs**:
- Terminal: Windows-specific analysis
- HTML: `{logfile}_report.html` with Windows-themed styling

**Dependencies**: None (can be sourced independently)

---

#### analyze_macc.sh
**Purpose**: macOS system log analysis

**Responsibilities**:
- Parse macOS log formats
- Categorize macOS-specific issues
- Generate macOS-focused reports

**Key Functions**:
- `analyze_mac(log_file)` - Main macOS analysis
- `generate_html_report_mac()` - macOS HTML report
- `show_mac_help()` - Display help information

**Error Categories Detected**:
- Kernel issues and panics
- System service problems (daemons, agents)
- Hardware events (disk, memory, CPU, battery)
- Network issues (WiFi, ethernet)
- Application crashes
- Security events (permissions, authentication)
- Scheduler events

**Outputs**:
- Terminal: macOS-specific analysis
- HTML: `{logfile}_mac_report.html` with Apple-themed styling

**Dependencies**: None (can be sourced independently)

---

### Documentation Files

#### README.md
**Purpose**: Project overview and marketing

**Target Audience**: 
- Potential employers
- GitHub visitors
- First-time users

**Contents**:
- Feature highlights
- Installation instructions
- Usage examples
- Architecture overview
- Learning highlights
- Future enhancements

**When to Reference**: First introduction to the project

---

#### INTERVIEW_GUIDE.md
**Purpose**: Interview preparation

**Target Audience**: You (the developer)

**Contents**:
- Elevator pitch
- Common interview questions with answers
- Technical deep-dive explanations
- Talking points
- Demo scenarios
- Related technologies

**When to Use**: 
- Before interviews
- During interview preparation
- As a reference during technical discussions

---

#### TECHNICAL_DOCUMENTATION.md
**Purpose**: Detailed technical reference

**Target Audience**:
- Technical interviewers
- Developers wanting to understand implementation
- You (for reference)

**Contents**:
- Architecture diagrams
- Component details
- Data flow
- Function reference
- Error patterns
- Performance considerations
- Security considerations

**When to Use**:
- Deep technical discussions
- Code review scenarios
- Architecture questions

---

#### QUICK_START.md
**Purpose**: Getting started quickly

**Target Audience**:
- New users
- Interviewers wanting to try the tool

**Contents**:
- Installation steps
- First run guide
- Common use cases
- Sample commands
- Troubleshooting
- Quick reference

**When to Use**:
- Live demos
- Helping others get started
- Quick reference during interviews

---

#### DEMO_GUIDE.md
**Purpose**: Interview demonstration scripts

**Target Audience**: You (the developer)

**Contents**:
- 5-minute quick demo
- 15-minute full demo
- Sample log files
- Talking points
- Technical question demos
- Problem-solving demonstrations

**When to Use**:
- Preparing for demos
- Practicing presentations
- During actual interviews

---

#### PROJECT_STRUCTURE.md
**Purpose**: Explain project organization

**Target Audience**:
- Developers
- Interviewers interested in code organization
- Contributors

**Contents**:
- Directory structure
- File descriptions
- Dependencies
- Data flow
- Module relationships

**When to Use**:
- Questions about project organization
- Code review discussions
- Architecture explanations

---

## Module Dependencies

### Dependency Graph

```
main.sh
├── requires: scan_log.sh
├── requires: system_scan.sh
├── requires: analyze_windows_log.sh
└── requires: analyze_macc.sh

scan_log.sh
└── standalone (no dependencies)

system_scan.sh
└── standalone (no dependencies)

analyze_windows_log.sh
└── standalone (no dependencies)

analyze_macc.sh
└── standalone (no dependencies)
```

### Execution Paths

#### Path 1: Log File Analysis
```
User → main.sh → select_log_analysis()
              ├── Option 1 (General) → scan_log.sh → analyze_log()
              ├── Option 2 (Windows) → analyze_windows_log.sh → analyze_windows()
              └── Option 3 (Mac) → analyze_macc.sh → analyze_mac()
```

#### Path 2: System Scan
```
User → main.sh → run_system_scan()
              ├── Option 1 (All) → system_scan.sh → scan_entire_system() → scan_syslog()
              ├── Option 2 (Week) → system_scan.sh → scan_past_week() → scan_syslog_last_7_days()
              └── Option 3 (Today) → system_scan.sh → scan_today() → scan_syslog_last_24h()
```

## Data Flow

### Input → Processing → Output

```
┌─────────────────┐
│   User Input    │
│  - File path    │
│  - Options      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Validation     │
│  - File exists  │
│  - Readable     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  File Reading   │
│  - Line by line │
│  - Progress bar │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Pattern Match   │
│  - grep/awk     │
│  - Counting     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Aggregation    │
│  - Categorize   │
│  - Sort         │
└────────┬────────┘
         │
         ├──────────────┬──────────────┐
         ▼              ▼              ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  Terminal   │  │    HTML     │  │   Charts    │
│   Output    │  │   Report    │  │  (Chart.js) │
└─────────────┘  └─────────────┘  └─────────────┘
```

## File Interaction Matrix

| Script | Calls | Called By | Inputs | Outputs |
|--------|-------|-----------|--------|---------|
| main.sh | All scripts | User | User choices | Terminal menu |
| scan_log.sh | None | main.sh | Log file path | Terminal + HTML |
| system_scan.sh | None | main.sh | Time range | Terminal + HTML |
| analyze_windows_log.sh | None | main.sh | Log file path | Terminal + HTML |
| analyze_macc.sh | None | main.sh | Log file path | Terminal + HTML |

## Color Scheme

All scripts use consistent color coding:

```bash
BLUE='\033[0;34m'    # Headers and boxes
CYAN='\033[0;36m'    # Menu items and separators
GREEN='\033[0;32m'   # Success and prompts
YELLOW='\033[1;33m'  # Information and warnings
RED='\033[0;31m'     # Errors and critical issues
PURPLE='\033[0;35m'  # Section headers
NC='\033[0m'         # No color (reset)
BOLD='\033[1m'       # Bold text
DIM='\033[2m'        # Dimmed text
WHITE='\033[1;37m'   # Highlighted text
```

## Naming Conventions

### Functions
- `snake_case` - All function names
- Descriptive names indicating purpose
- Verbs for actions (e.g., `analyze_log`, `generate_report`)

### Variables
- `snake_case` - All variable names
- Descriptive names
- All caps for constants (e.g., `BLUE`, `NC`)
- Local scope with `local` keyword

### Files
- `snake_case.sh` - All script files
- Descriptive names indicating module purpose
- `.sh` extension for all shell scripts
- `.md` extension for all documentation

## Report File Naming

### Generated Reports

| Source | Report Type | Filename |
|--------|-------------|----------|
| General log | Single file | `{original_name}_report.html` |
| Windows log | Single file | `{original_name}_report.html` |
| macOS log | Single file | `{original_name}_mac_report.html` |
| System scan | All time | `syslog_report.html` |
| System scan | 7 days | `syslog_trend_report.html` |
| System scan | 24 hours | `syslog_report_24h.html` |

## Temporary Files

All modules use temporary files for intermediate processing:

```bash
# Create
temp_file=$(mktemp)

# Use
process_data > "$temp_file"

# Cleanup
rm -f "$temp_file"
```

**Location**: `/tmp/` (system temporary directory)

**Lifecycle**: Created at start of function, deleted at end

## Version Control

### Git Structure

```
.git/
├── HEAD                 # Current branch pointer
├── config              # Repository configuration
├── refs/               # Branch references
│   ├── heads/          # Local branches
│   └── remotes/        # Remote branches
└── objects/            # Git objects (commits, trees, blobs)
```

### Recommended Branching

```
main                    # Stable release branch
├── develop            # Development branch
├── feature/*          # Feature branches
└── hotfix/*           # Hotfix branches
```

## Future Structure Considerations

As the project grows, consider:

1. **Configuration Directory**:
   ```
   config/
   ├── error_patterns.conf
   ├── thresholds.conf
   └── colors.conf
   ```

2. **Library Directory**:
   ```
   lib/
   ├── validation.sh
   ├── formatting.sh
   └── utilities.sh
   ```

3. **Test Directory**:
   ```
   tests/
   ├── test_scan_log.sh
   ├── test_system_scan.sh
   └── sample_logs/
   ```

4. **Output Directory**:
   ```
   reports/
   ├── 2024-01/
   └── 2024-02/
   ```

## Quick Reference

### To Add a New Analysis Module

1. Create `analyze_newtype_log.sh`
2. Implement `analyze_newtype(log_file)` function
3. Implement `generate_html_report_newtype()` function
4. Add to `main.sh`:
   - Source the script
   - Add menu option
   - Add case statement handler

### To Add a New Error Pattern

1. Open appropriate analysis script
2. Add pattern to grep command
3. Add counter variable
4. Add to display output
5. Add to HTML report data

### To Modify Report Style

1. Open `generate_html_report_*()` function
2. Modify `<style>` section
3. Update Chart.js options
4. Test with sample data

## Conclusion

This project structure is designed for:
- **Modularity**: Each script can function independently
- **Maintainability**: Clear separation of concerns
- **Extensibility**: Easy to add new analysis types
- **Documentation**: Comprehensive guides for all audiences
- **Professionalism**: Well-organized for portfolio presentation

When discussing this project in interviews, emphasize the thoughtful organization and how it demonstrates your software engineering best practices.
