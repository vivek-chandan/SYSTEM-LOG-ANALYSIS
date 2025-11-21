# Sample Log Files

This directory contains sample log files for testing and demonstration purposes.

## Files

### 1. application.log
**Purpose**: Simulates typical application server logs

**Contains**:
- Database connection errors
- Authentication failures (brute force attempt)
- Memory allocation errors
- Performance warnings
- Critical system events
- Normal operational messages

**Error Types**:
- 15 ERROR messages
- 12 WARNING messages
- 13 INFO messages
- 3 CRITICAL messages

**Use Cases**:
- Demonstrating general log analysis
- Testing error pattern detection
- Showing authentication failure detection
- Memory issue identification

**Test Command**:
```bash
./main.sh
# Select: 1 (Analyze a log file)
# Select: 1 (General)
# Enter path: sample_logs/application.log
# Select: 1 (Run general scan)
```

---

### 2. system.log
**Purpose**: Simulates system-level Linux logs (similar to /var/log/syslog)

**Contains**:
- Hardware issues (CPU temperature, disk errors)
- Memory problems (OOM killer events)
- Network connectivity issues
- Filesystem errors
- Service failures
- Boot and shutdown events

**Error Types**:
- 14 ERROR messages
- 18 WARNING messages
- 20 INFO messages
- 3 CRITICAL messages

**Use Cases**:
- Testing system-wide analysis features
- Demonstrating hardware error detection
- Resource monitoring capabilities
- Service management issues

**Test Command**:
```bash
./main.sh
# Select: 1 (Analyze a log file)
# Select: 1 (General)
# Enter path: sample_logs/system.log
# Select: 1 (Run general scan)
```

---

### 3. security.log
**Purpose**: Simulates security and authentication logs

**Contains**:
- Failed login attempts
- Brute force attacks
- Privilege escalation attempts
- Unauthorized file access
- SSL certificate issues
- Firewall violations
- Malware detection
- VPN connections

**Error Types**:
- 11 ERROR messages
- 20 WARNING messages
- 26 INFO messages
- 4 CRITICAL messages

**Use Cases**:
- Security event analysis
- Authentication failure pattern detection
- Intrusion detection demonstration
- Security audit capabilities

**Test Command**:
```bash
./main.sh
# Select: 1 (Analyze a log file)
# Select: 1 (General)
# Enter path: sample_logs/security.log
# Select: 2 (Search for a particular error)
# Enter: "authentication failure"
```

---

## Quick Tests

### Test 1: Compare All Sample Logs
```bash
# Test application log
./main.sh << EOF
1
1
sample_logs/application.log
1
EOF

# Test system log
./main.sh << EOF
1
1
sample_logs/system.log
1
EOF

# Test security log
./main.sh << EOF
1
1
sample_logs/security.log
1
EOF
```

### Test 2: Search for Specific Patterns

**Authentication Failures**:
```bash
./main.sh << EOF
1
1
sample_logs/security.log
2
authentication failure
EOF
```

**Memory Errors**:
```bash
./main.sh << EOF
1
1
sample_logs/system.log
2
out of memory
EOF
```

**Critical Events**:
```bash
./main.sh << EOF
1
1
sample_logs/application.log
2
CRITICAL
EOF
```

### Test 3: Verify Error Counts

**Manual Count vs. Tool Count**:
```bash
# Manual count
grep -c "ERROR" sample_logs/application.log    # Should be 15
grep -c "WARNING" sample_logs/application.log  # Should be 12
grep -c "CRITICAL" sample_logs/application.log # Should be 3

# Run tool and compare results
./main.sh
```

## Expected Results

### application.log Analysis
```
Error Type Analysis:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Errors                 : 15
Warnings               : 12
Info                   : 13
Critical               : 3
Alerts                 : 0
Auth Failures          : 5
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Top Error Patterns:
- Database connection failures (3)
- Authentication failures (5)
- Memory allocation errors (1)
- SSL certificate errors (1)
```

### system.log Analysis
```
Error Type Analysis:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Errors                 : 14
Warnings               : 18
Info                   : 20
Critical               : 3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

System Issues Detected:
- OOM killer events (1)
- CPU throttling (1)
- Disk I/O errors (1)
- Network connectivity loss (1)
- Filesystem corruption (1)
```

### security.log Analysis
```
Error Type Analysis:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Errors                 : 11
Warnings               : 20
Info                   : 26
Critical               : 4
Auth Failures          : 6
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Security Events:
- Brute force attempts detected (2)
- Unauthorized access attempts (2)
- Port scans detected (1)
- Malware prevented (1)
```

## Creating Custom Test Logs

### Template for Creating Your Own Test Logs

```bash
cat > sample_logs/custom.log << 'EOF'
2024-01-15 10:00:00 INFO: [Your info message]
2024-01-15 10:01:00 WARNING: [Your warning message]
2024-01-15 10:02:00 ERROR: [Your error message]
2024-01-15 10:03:00 CRITICAL: [Your critical message]
EOF
```

### Best Practices for Test Logs

1. **Use ISO 8601 timestamps**: `YYYY-MM-DD HH:MM:SS`
2. **Include severity levels**: INFO, WARNING, ERROR, CRITICAL
3. **Add context**: Include service names, IPs, error codes
4. **Mix message types**: Don't just include errors
5. **Realistic scenarios**: Base on actual log patterns

## Interview Demonstration Tips

### Quick Demo (5 minutes)
1. Show `application.log` - demonstrates typical analysis
2. Point out: error counting, categorization, HTML report
3. Highlight: authentication failure detection

### Detailed Demo (15 minutes)
1. Analyze all three sample files
2. Compare results between different log types
3. Show specific pattern search
4. Demonstrate HTML report features
5. Explain how patterns are detected

### Problem-Solving Demo
**Scenario**: "There's been a security incident. Find all failed authentication attempts."

**Solution**:
```bash
./main.sh
# Select: 1 → 1 → sample_logs/security.log → 2
# Enter: "failed login"
# Show results: 6 failed attempts from suspicious IPs
# Show action taken: IPs blocked automatically
```

## Customization

### Add More Realistic Data

```bash
# Add more entries to existing logs
cat >> sample_logs/application.log << 'EOF'
2024-01-15 12:00:00 ERROR: New error scenario
EOF

# Create new log type
cat > sample_logs/database.log << 'EOF'
2024-01-15 10:00:00 INFO: Database started
2024-01-15 10:01:00 ERROR: Query timeout
EOF
```

### Simulate Large Files

```bash
# Create large test file
for i in {1..10000}; do
    echo "2024-01-15 10:00:00 ERROR: Test error $i" >> sample_logs/large_test.log
done

# Test performance
time ./main.sh
```

## Verification

After analyzing sample logs, verify:

1. **Accuracy**: Manual grep count matches tool count
2. **Performance**: Analysis completes in reasonable time
3. **HTML Reports**: Generated successfully and viewable
4. **Pattern Detection**: Finds expected patterns
5. **Error Handling**: Handles edge cases gracefully

## Cleanup

```bash
# Remove generated reports
rm -f sample_logs/*.html

# Reset to original state
git checkout sample_logs/
```

## Notes

- These sample logs are **synthetic** and created for testing only
- They represent **realistic scenarios** based on actual log patterns
- Use them to **practice demos** before interviews
- Modify them to **test specific features**
- Create **your own samples** for additional test cases

## License

These sample files are provided for educational and demonstration purposes as part of the System Log Analysis Tool project.
