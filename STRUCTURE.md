# Architecture Diagram

## System Overview

```
╔════════════════════════════════════════════════════════════════════════╗
║                    SYSTEM LOG ANALYSIS TOOL                            ║
║                         Architecture                                   ║
╚════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────┐
│                           USER INTERFACE                              │
│                                                                       │
│   ╔═══════════════════════════════════════════════════════════╗     │
│   ║                      main.sh                              ║     │
│   ║              Interactive Menu System                      ║     │
│   ║                                                           ║     │
│   ║   1. Analyze a log file                                  ║     │
│   ║   2. Run system scan                                     ║     │
│   ║   3. Exit                                                ║     │
│   ╚═══════════════════════════════════════════════════════════╝     │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
                             │ User Selection
                             │
         ┌───────────────────┴──────────────────┐
         │                                      │
         ▼                                      ▼
┌────────────────────┐              ┌────────────────────┐
│  LOG ANALYSIS PATH │              │ SYSTEM SCAN PATH   │
└────────┬───────────┘              └─────────┬──────────┘
         │                                    │
         │                                    │
    ┌────┴────┬────────┬──────────┐          │
    │         │        │          │          │
    ▼         ▼        ▼          ▼          ▼
┌────────┐┌───────┐┌──────┐  ┌───────┐  ┌────────┐
│General ││Windows││ macOS│  │ Time  │  │ Syslog │
│  Log   ││  Log  ││ Log  │  │ Range │  │Analysis│
└───┬────┘└───┬───┘└──┬───┘  └───┬───┘  └───┬────┘
    │         │        │          │          │
    │         │        │          │          │
    ▼         ▼        ▼          ▼          ▼
```

## Detailed Component Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ANALYSIS LAYER                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐       │
│  │  scan_log.sh   │  │analyze_windows │  │ analyze_macc   │       │
│  │                │  │    _log.sh     │  │     .sh        │       │
│  │ ┌────────────┐ │  │ ┌────────────┐ │  │ ┌────────────┐ │       │
│  │ │analyze_log │ │  │ │analyze_    │ │  │ │analyze_mac │ │       │
│  │ │  ()        │ │  │ │ windows()  │ │  │ │    ()      │ │       │
│  │ └────────────┘ │  │ └────────────┘ │  │ └────────────┘ │       │
│  │ ┌────────────┐ │  │ ┌────────────┐ │  │ ┌────────────┐ │       │
│  │ │analyze_    │ │  │ │generate_   │ │  │ │generate_   │ │       │
│  │ │ patterns() │ │  │ │html_report │ │  │ │html_report │ │       │
│  │ └────────────┘ │  │ │_windows()  │ │  │ │_mac()      │ │       │
│  │ ┌────────────┐ │  │ └────────────┘ │  │ └────────────┘ │       │
│  │ │generate_   │ │  └────────────────┘  └────────────────┘       │
│  │ │html_report │ │                                                │
│  │ │_log()      │ │  ┌────────────────────────────────────┐       │
│  │ └────────────┘ │  │     system_scan.sh                 │       │
│  └────────────────┘  │                                    │       │
│                      │ ┌────────────────────────────────┐ │       │
│                      │ │    scan_syslog()               │ │       │
│                      │ │  (All time analysis)           │ │       │
│                      │ └────────────────────────────────┘ │       │
│                      │ ┌────────────────────────────────┐ │       │
│                      │ │  scan_syslog_last_7_days()     │ │       │
│                      │ │  (Weekly trend analysis)       │ │       │
│                      │ └────────────────────────────────┘ │       │
│                      │ ┌────────────────────────────────┐ │       │
│                      │ │  scan_syslog_last_24h()        │ │       │
│                      │ │  (Daily analysis)              │ │       │
│                      │ └────────────────────────────────┘ │       │
│                      └────────────────────────────────────┘       │
└──────────────────────────────────┬───────────────────────────────────┘
                                   │
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      PROCESSING LAYER                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐ │
│  │   File I/O  │  │   Pattern   │  │    Data     │  │  Visual   │ │
│  │             │  │   Matching  │  │ Aggregation │  │ Rendering │ │
│  │  - Read     │  │             │  │             │  │           │ │
│  │  - Validate │  │  - grep     │  │  - Count    │  │ - Colors  │ │
│  │  - Parse    │  │  - awk      │  │  - Sort     │  │ - Graphs  │ │
│  │  - Filter   │  │  - sed      │  │  - Group    │  │ - Tables  │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘ │
└──────────────────────────────────┬───────────────────────────────────┘
                                   │
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        OUTPUT LAYER                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────┐         ┌────────────────────────┐     │
│  │   Terminal Output      │         │     HTML Reports       │     │
│  │                        │         │                        │     │
│  │  ┌──────────────────┐ │         │  ┌──────────────────┐ │     │
│  │  │  Color-coded     │ │         │  │  Interactive     │ │     │
│  │  │  Error Summary   │ │         │  │  Charts          │ │     │
│  │  └──────────────────┘ │         │  │  (Chart.js)      │ │     │
│  │  ┌──────────────────┐ │         │  └──────────────────┘ │     │
│  │  │  ASCII Graphs    │ │         │  ┌──────────────────┐ │     │
│  │  │  Bar Charts      │ │         │  │  Statistical     │ │     │
│  │  └──────────────────┘ │         │  │  Tables          │ │     │
│  │  ┌──────────────────┐ │         │  └──────────────────┘ │     │
│  │  │  Pattern         │ │         │  ┌──────────────────┐ │     │
│  │  │  Context         │ │         │  │  Responsive      │ │     │
│  │  └──────────────────┘ │         │  │  Design          │ │     │
│  └────────────────────────┘         │  └──────────────────┘ │     │
│                                     └────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌─────────────┐
│    INPUT    │
│  Log File   │
└──────┬──────┘
       │
       │ File Path
       │
       ▼
┌─────────────────┐
│   VALIDATION    │
│                 │
│ • File exists?  │
│ • Readable?     │
│ • Not empty?    │
└────────┬────────┘
         │
         │ Valid file
         │
         ▼
┌─────────────────┐
│  FILE READING   │
│                 │
│ • Line by line  │
│ • Progress bar  │
│ • Stream mode   │
└────────┬────────┘
         │
         │ Raw lines
         │
         ▼
┌─────────────────┐
│ PATTERN MATCH   │
│                 │
│ • Error regex   │
│ • Warning regex │
│ • Info regex    │
│ • Custom regex  │
└────────┬────────┘
         │
         │ Matched lines
         │
         ▼
┌─────────────────┐
│  CATEGORIZE     │
│                 │
│ • Count types   │
│ • Group apps    │
│ • Sort by freq  │
└────────┬────────┘
         │
         │ Structured data
         │
         ├────────────────┬─────────────────┐
         │                │                 │
         ▼                ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   TERMINAL   │  │     HTML     │  │  TEMPORARY   │
│    OUTPUT    │  │    REPORT    │  │    FILES     │
│              │  │              │  │              │
│ • Colors     │  │ • Charts     │  │ • Cleanup    │
│ • Graphs     │  │ • Tables     │  │   at end     │
│ • Context    │  │ • Responsive │  │              │
└──────────────┘  └──────────────┘  └──────────────┘
```

## Module Interaction Diagram

```
                    ┌─────────────────┐
                    │    main.sh      │
                    │  Entry Point    │
                    └────────┬────────┘
                             │
                             │ source
                             │
         ┌───────────────────┼───────────────────┬────────────────┐
         │                   │                   │                │
         ▼                   ▼                   ▼                ▼
┌────────────────┐  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐
│  scan_log.sh   │  │system_scan.sh  │  │analyze_windows │  │analyze_macc  │
│                │  │                │  │   _log.sh      │  │    .sh       │
│  General Log   │  │  Syslog Scan   │  │  Windows Log   │  │  macOS Log   │
│   Analysis     │  │   Analysis     │  │   Analysis     │  │  Analysis    │
└────────┬───────┘  └────────┬───────┘  └────────┬───────┘  └──────┬───────┘
         │                   │                   │                 │
         │                   │                   │                 │
         └───────────────────┴───────────────────┴─────────────────┘
                             │
                             │ Common Utilities
                             │
         ┌───────────────────┴───────────────────┐
         │                                       │
         ▼                                       ▼
┌─────────────────┐                    ┌─────────────────┐
│ Unix Utilities  │                    │   Libraries     │
│                 │                    │                 │
│ • grep          │                    │ • Color defs    │
│ • awk           │                    │ • Functions     │
│ • sed           │                    │ • Patterns      │
│ • wc            │                    │                 │
│ • sort          │                    │                 │
└─────────────────┘                    └─────────────────┘
```

## Error Detection Flow

```
┌───────────────────────────────────────────────────────────────┐
│                    ERROR DETECTION PIPELINE                    │
└───────────────────────────────────────────────────────────────┘

    Log Line: "2024-01-15 10:00:00 ERROR: Database connection failed"
                              │
                              │
                              ▼
                    ┌─────────────────┐
                    │  Read Line      │
                    │  from Log       │
                    └────────┬────────┘
                             │
                             │
            ┌────────────────┼────────────────┬─────────────┐
            │                │                │             │
            ▼                ▼                ▼             ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │ Match ERROR? │ │Match WARNING?│ │ Match INFO?  │ │Match CRITICAL│
    │     YES      │ │      NO      │ │      NO      │ │      NO      │
    └──────┬───────┘ └──────────────┘ └──────────────┘ └──────────────┘
           │
           │ error_count++
           │
           ▼
    ┌──────────────┐
    │   Extract    │
    │  Timestamp   │
    │  Context     │
    │  Message     │
    └──────┬───────┘
           │
           │
           ▼
    ┌──────────────┐
    │   Store in   │
    │  Error Array │
    └──────┬───────┘
           │
           │
           ▼
    ┌──────────────┐
    │   Generate   │
    │   Report     │
    └──────────────┘
```

## HTML Report Generation Flow

```
┌────────────────────────────────────────────────────────────────┐
│                  HTML REPORT GENERATION                        │
└────────────────────────────────────────────────────────────────┘

┌──────────────┐
│ Analysis     │
│ Complete     │
└──────┬───────┘
       │
       │ Counts: errors=10, warnings=5, info=20
       │
       ▼
┌──────────────────┐
│ Create Temp File │
│ (mktemp)         │
└────────┬─────────┘
         │
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│ Write HTML Structure                                    │
│                                                         │
│ <!DOCTYPE html>                                         │
│ <html>                                                  │
│   <head>                                                │
│     <script src="chart.js"></script>                    │
│     <style>/* CSS */</style>                            │
│   </head>                                               │
│   <body>                                                │
│     <div class="container">                             │
│       <!-- File info -->                                │
│       <!-- Statistics -->                               │
│       <!-- Charts -->                                   │
│     </div>                                              │
│     <script>                                            │
│       new Chart(ctx, {                                  │
│         data: [${error_count}, ${warning_count}]        │
│       });                                               │
│     </script>                                           │
│   </body>                                               │
│ </html>                                                 │
└─────────────────────────┬───────────────────────────────┘
                          │
                          │
                          ▼
                  ┌───────────────┐
                  │ Move to Final │
                  │   Location    │
                  │ (*.html)      │
                  └───────┬───────┘
                          │
                          │
                          ▼
                  ┌───────────────┐
                  │   Success     │
                  │   Message     │
                  └───────────────┘
```

## Time-Based Analysis Flow (System Scan)

```
┌────────────────────────────────────────────────────────────┐
│              TIME-BASED SYSLOG ANALYSIS                    │
└────────────────────────────────────────────────────────────┘

User selects: "Past Week"
       │
       ▼
┌──────────────┐
│ Calculate    │
│ Date Range   │
│              │
│ start: 7 days│
│ end: today   │
└──────┬───────┘
       │
       │
       ▼
┌──────────────────────────┐
│ Combine Log Sources      │
│                          │
│ • /var/log/syslog        │
│ • /var/log/syslog.1      │
│ • /var/log/syslog.*.gz   │
└──────┬───────────────────┘
       │
       │ Combined content → temp_file
       │
       ▼
┌──────────────────────────┐
│ Filter by Date           │
│                          │
│ awk -v start -v end      │
│   '$0 >= start &&        │
│    $0 <= end'            │
└──────┬───────────────────┘
       │
       │ Filtered content
       │
       ▼
┌──────────────────────────┐
│ Daily Analysis Loop      │
│                          │
│ For i=0 to 6:            │
│   date = today - i       │
│   count_errors(date)     │
│   store_in_array(date)   │
└──────┬───────────────────┘
       │
       │ Daily counts array
       │
       ▼
┌──────────────────────────┐
│ Generate Trend Report    │
│                          │
│ • Daily bar graphs       │
│ • Line chart (trend)     │
│ • Error type pie chart   │
└──────┬───────────────────┘
       │
       │
       ▼
┌──────────────────────────┐
│ Output:                  │
│ syslog_trend_report.html │
└──────────────────────────┘
```

## Performance Optimization Points

```
┌─────────────────────────────────────────────────────────┐
│                PERFORMANCE HOTSPOTS                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. File Reading                                        │
│     ┌────────────────────────────────────┐            │
│     │ while IFS= read -r line; do        │            │
│     │   process_line                     │            │
│     │ done < large_file                  │            │
│     └────────────────────────────────────┘            │
│     ✓ Optimized: Streaming (low memory)               │
│                                                         │
│  2. Pattern Matching                                    │
│     ┌────────────────────────────────────┐            │
│     │ grep -E "pattern1|pattern2"        │            │
│     └────────────────────────────────────┘            │
│     ✓ Optimized: Combined patterns                     │
│                                                         │
│  3. Counting                                            │
│     ┌────────────────────────────────────┐            │
│     │ count=$(grep -c pattern file)      │            │
│     └────────────────────────────────────┘            │
│     ✓ Optimized: Direct count (no pipe)               │
│                                                         │
│  4. Temporary Files                                     │
│     ┌────────────────────────────────────┐            │
│     │ temp=$(mktemp)                     │            │
│     │ trap 'rm -f $temp' EXIT            │            │
│     └────────────────────────────────────┘            │
│     ✓ Optimized: Automatic cleanup                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  SECURITY LAYERS                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Layer 1: Input Validation                             │
│  ┌──────────────────────────────────────────────┐     │
│  │ • File path validation                       │     │
│  │ • Existence check                            │     │
│  │ • Permission check                           │     │
│  │ • Pattern sanitization                       │     │
│  └──────────────────────────────────────────────┘     │
│                                                         │
│  Layer 2: Safe Execution                               │
│  ┌──────────────────────────────────────────────┐     │
│  │ • No eval() or shell injection              │     │
│  │ • Quoted variables                           │     │
│  │ • Array usage for commands                   │     │
│  └──────────────────────────────────────────────┘     │
│                                                         │
│  Layer 3: File Operations                              │
│  ┌──────────────────────────────────────────────┐     │
│  │ • Read-only access to logs                   │     │
│  │ • Secure temp files (600 permissions)        │     │
│  │ • Cleanup on exit                            │     │
│  └──────────────────────────────────────────────┘     │
│                                                         │
│  Layer 4: Output Sanitization                          │
│  ┌──────────────────────────────────────────────┐     │
│  │ • HTML escaping (if needed)                  │     │
│  │ • Report permissions (600)                   │     │
│  │ • No sensitive data in reports               │     │
│  └──────────────────────────────────────────────┘     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Deployment Architecture (Future)

```
┌────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT OPTIONS                          │
└────────────────────────────────────────────────────────────────┘

Option 1: Standalone Script (Current)
┌──────────────┐
│ Single Server│
│   ./main.sh  │
└──────────────┘

Option 2: Centralized Monitoring
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Server 1    │     │  Server 2    │     │  Server 3    │
│  (Agent)     │────▶│  (Agent)     │────▶│  (Agent)     │
└──────────────┘     └──────────────┘     └──────────────┘
        │                    │                    │
        └────────────────────┴────────────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │   Central    │
                    │  Dashboard   │
                    └──────────────┘

Option 3: Cloud-Based
┌──────────────┐
│   AWS/GCP    │
│   Lambda     │
│              │
│ Scheduled    │
│ Analysis     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  S3/Cloud    │
│  Storage     │
│  (Reports)   │
└──────────────┘
```

## Conclusion

This architecture demonstrates:
- **Modular Design**: Separation of concerns
- **Scalability**: Easy to extend with new modules
- **Performance**: Optimized for large files
- **Security**: Multiple validation layers
- **Maintainability**: Clear structure and documentation

When presenting this in interviews, highlight how each architectural decision was made to solve specific problems while maintaining code quality and user experience.
