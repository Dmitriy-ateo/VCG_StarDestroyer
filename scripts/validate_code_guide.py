#!/usr/bin/env python3
import os
import sys
import re
import time

# Coding Guide validation rules config
CODE_GUIDE_PATH = "CODE_GUIDE.md"
TARGET_DIR = "lib"
REPORT_FILE = "code_validation_report.log"

def validate_file(filepath):
    errors = []
    warnings = []
    
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except Exception as e:
        return [f"Failed to read file: {e}"], []

    # Rule 2.2: CustomPainter shouldRepaint returning true blindly
    if "extends CustomPainter" in content:
        # Check if shouldRepaint returns true without property checks
        # e.g., bool shouldRepaint(...) => true; or return true;
        # We search for shouldRepaint signature followed by a blind return true
        should_repaint_blocks = re.findall(r'shouldRepaint\s*\([^)]*\)\s*(=>|\{)[^}]*\}?', content, re.DOTALL)
        # Better yet, search for "bool shouldRepaint" and "return true;" or "=> true" inside it
        for match in re.finditer(r'bool\s+shouldRepaint\s*\([^)]*\)\s*(\{.*?\}|=>[^;]+;)', content, re.DOTALL):
            block = match.group(1)
            if "return true;" in block or "=> true" in block:
                # Make sure it's not a commented out return
                clean_block = re.sub(r'//.*', '', block)
                clean_block = re.sub(r'/\*.*?\*/', '', clean_block, flags=re.DOTALL)
                if "return true;" in clean_block or "=> true" in clean_block:
                    errors.append(f"VIOLATION (Rule 2.2): CustomPainter shouldRepaint returns 'true' blindly. You must compare mutable properties explicitly.")

    # Rule 2.1: CustomPaint used without RepaintBoundary in the same file
    if "CustomPaint(" in content and "RepaintBoundary" not in content:
        # Exclude small icons or background decorators if any, but log as advisory
        warnings.append(f"ADVISORY (Rule 2.1): 'CustomPaint' widget instantiated, but no 'RepaintBoundary' found in this file. Verify heavy painting is isolated.")

    # Rule 5: Use of Sliders instead of Gestures
    if "lib/screens/" in filepath and "Slider(" in content:
        errors.append(f"VIOLATION (Rule 5): Mechanical 'Slider' widget detected. Use vertical gestural swiping (onPanUpdate) for steering instead.")

    # Rule 6: Standard/Generic solid colors instead of Premium Cyberpunk palette
    # Check for direct references to basic material colors (Colors.red, Colors.green, etc.)
    generic_colors = ["Colors.red", "Colors.green", "Colors.blue", "Colors.yellow", "Colors.orange", "Colors.purple", "Colors.black", "Colors.white"]
    for color in generic_colors:
        if re.search(r'\b' + re.escape(color) + r'\b', content):
            # Ignore white/black if used for text/background layers in specific safe contexts,
            # but warn for others. We'll mark them as advisory style checks.
            warnings.append(f"ADVISORY (Rule 6): Generic solid color '{color}' detected. Prefer curated neon-themed palettes (e.g. 0xFF00FFF5, 0xFFFF2E93, 0xFFFFB703).")

    # Rule 4.1: Step-Based Raytracing & Physics
    if "laser_calculator.dart" in filepath or "physics" in filepath.lower():
        if "maxSteps" not in content and "max_steps" not in content:
            errors.append(f"VIOLATION (Rule 4.1): No step-count safety clamp (e.g., maxSteps) found in laser path loop. Must prevent UI thread locks.")

    # Rule 6: Translucent fills in glassmorphic drawers
    if "drawer" in filepath.lower() or "sliding" in filepath.lower():
        # Check if withOpacity / withValues uses the correct premium range
        opacity_matches = re.findall(r'withOpacity\((0\.\d+)\)', content)
        for val_str in opacity_matches:
            val = float(val_str)
            if val < 0.7 or val > 0.9:
                warnings.append(f"ADVISORY (Rule 6): Translucent panel background opacity is {val}. Recommended range for glassmorphic layers is 0.80 - 0.85.")

    return errors, warnings

def run_validation():
    print("====================================================")
    print("CODE GUIDE COMPLIANCE REPORT")
    print(f"Timestamp: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    print("====================================================")
    
    total_files = 0
    all_errors = {}
    all_warnings = {}
    
    for root, dirs, files in os.walk(TARGET_DIR):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                total_files += 1
                errors, warnings = validate_file(filepath)
                if errors:
                    all_errors[filepath] = errors
                if warnings:
                    all_warnings[filepath] = warnings
                    
    # Write report to log file
    with open(REPORT_FILE, 'w', encoding='utf-8') as rf:
        rf.write("====================================================\n")
        rf.write("CODE GUIDE COMPLIANCE REPORT\n")
        rf.write(f"Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        rf.write(f"Total dart files scanned: {total_files}\n")
        rf.write("====================================================\n\n")
        
        if not all_errors and not all_warnings:
            rf.write("✓ SUCCESS: 100% compliant with CODE_GUIDE.md! No violations or advisories.\n")
            print("✓ SUCCESS: 100% compliant with CODE_GUIDE.md! No violations or advisories.")
        else:
            if all_errors:
                rf.write("✖ CRITICAL VIOLATIONS:\n")
                print("\033[91m✖ CRITICAL VIOLATIONS:\033[0m")
                for path, errs in all_errors.items():
                    rf.write(f"  File: {path}\n")
                    print(f"  File: \033[1m{path}\033[0m")
                    for err in errs:
                        rf.write(f"    - {err}\n")
                        print(f"    \033[91m- {err}\033[0m")
                rf.write("\n")
                print()
                
            if all_warnings:
                rf.write("⚠ STYLE & PERFORMANCE ADVISORIES:\n")
                print("\033[93m⚠ STYLE & PERFORMANCE ADVISORIES:\033[0m")
                for path, warns in all_warnings.items():
                    rf.write(f"  File: {path}\n")
                    print(f"  File: \033[1m{path}\033[0m")
                    for warn in warns:
                        rf.write(f"    - {warn}\n")
                        print(f"    \033[93m- {warn}\033[0m")
                rf.write("\n")
                print()
                
            rf.write(f"Summary: {len(all_errors)} files with violations, {len(all_warnings)} files with advisories.\n")
            print(f"Summary: {len(all_errors)} files with violations, {len(all_warnings)} files with advisories.")
            
    print("====================================================")
    print(f"Report saved to: {REPORT_FILE}")
    print("====================================================")
    
    return len(all_errors) == 0

def watch_files():
    print(f"Starting code guide watcher on directory '{TARGET_DIR}' recursively...")
    print("Will validate code on file additions or modifications.")
    
    # Store initial modification times
    file_mtimes = {}
    for root, dirs, files in os.walk(TARGET_DIR):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                file_mtimes[filepath] = os.path.getmtime(filepath)
                
    # Run initial validation
    run_validation()
    
    try:
        while True:
            time.sleep(2)
            changed = False
            current_files = set()
            
            for root, dirs, files in os.walk(TARGET_DIR):
                for file in files:
                    if file.endswith('.dart'):
                        filepath = os.path.join(root, file)
                        current_files.add(filepath)
                        
                        # Check if file is new or modified
                        mtime = os.path.getmtime(filepath)
                        if filepath not in file_mtimes or mtime > file_mtimes[filepath]:
                            print(f"\n[Watcher] Change detected in: {filepath}")
                            file_mtimes[filepath] = mtime
                            changed = True
                            
            # Check for deleted files
            deleted_files = set(file_mtimes.keys()) - current_files
            for filepath in deleted_files:
                print(f"\n[Watcher] File deleted: {filepath}")
                del file_mtimes[filepath]
                changed = True
                
            if changed:
                run_validation()
                
    except KeyboardInterrupt:
        print("\nWatcher stopped.")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--watch":
        watch_files()
    else:
        success = run_validation()
        sys.exit(0 if success else 1)
