# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

wProjectDesktop is a Windows application that creates project-aware virtual desktops with a command palette. It allows users to organize different projects on separate Windows virtual desktops and provides a fuzzy-finder command palette for launching project-specific tools and applications.

## Development Setup

### Prerequisites
- Windows 10/11 with Virtual Desktop support
- AutoHotkey v2
- PowerShell 5.1 or later
- Windows Terminal (optional but recommended)

### Development Mode
To run in development mode without installing:
```powershell
# Set environment variables for development
[Environment]::SetEnvironmentVariable("ahk_wPD", "path\to\AutoHotkey.exe", "User")
[Environment]::SetEnvironmentVariable("wPD_VirtualDesktop_exe", "path\to\VirtualDesktop.exe", "User")

# Run development mode
.\DevMode.ps1

# Or schedule for startup during development
.\DevModeSchedule.ps1
```

### Installation
```powershell
# Standard installation
.\Install.ps1

# Installation with custom config path
.\Install.ps1 -customConfig "C:\MyCustomConfig"
```

### Testing
```powershell
# Install Pester for testing
Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser

# Run tests (test directory structure exists but specific test commands need verification)
# Check tests/ directory for available test files
```

## Architecture

### Core Components

**Startup Flow:**
1. `install.ps1` - Sets up the application in `%LocalAppData%\wProjectDesktop`
2. `src/Startup.ps1` - Main startup script that initializes virtual desktops for configured projects
3. `src/hotkey.ahk` - AutoHotkey script that handles F1 hotkey for command palette activation

**Command Palette System:**
- `src/Palette.ps1` - Main command palette loop using fzf for fuzzy finding
- `DefaultPalette/` - Contains predefined command scripts (PowerShell and Bash)
- Command scripts must implement `Invoke-Command` function with parameters: `$project`, `$spawnWt`, `$projectPath`, `$wtLocated`

**Project Management:**
- `src/ProjectUtils.ps1` - Utilities for reading project configuration from `projects.json`
- Projects are configured in `%LocalAppData%\wProjectDesktop\config\projects.json` (or custom config path)
- Each project gets its own Windows virtual desktop

**State Management:**
- `State/CurrentProject.txt` - Tracks the current active project
- `State/MRU/` - Most Recently Used tracking for command ordering in palette

### Key Files

- `src/Palette.ps1:105` - Main fzf command palette invocation
- `src/ProjectUtils.ps1:1-33` - Project configuration loading from JSON
- `src/hotkey.ahk:32-63` - F1 hotkey handler and desktop state management
- `install.ps1:86-90` - VirtualDesktop.exe dependency download and verification

## Command Development

### Creating New Commands
Commands are PowerShell (.ps1) or Bash (.sh) scripts in the `DefaultPalette/` folder.

**PowerShell Command Template:**
```powershell
function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    # Your command implementation here
    # $project - current project name
    # $spawnWt - Windows Terminal spawn command for the project
    # $projectPath - full path to project directory
    # $wtLocated - Windows Terminal command with directory set
}
```

**Bash Command Template:**
```bash
invoke_command() {
    local project=$1
    local spawnWt=$2
    local projectPath=$3
    local wtLocated=$4
    # Your command implementation here
}
```

### MRU (Most Recently Used) System
Commands are automatically sorted by usage frequency. The system tracks command usage in `State/MRU/` folder with timestamps.

## Configuration

### Project Configuration
Projects are defined in `config/projects.json`:
```json
[
  {
    "Name": "Project Name",
    "Path": "%USERPROFILE%\\projects\\myproject"
  },
  {
    "Name": "Parent Directory",
    "Path": "%USERPROFILE%\\projects",
    "children": true
  }
]
```

When `children: true` is set, all subdirectories become individual projects.

## Dependencies

- **VirtualDesktop Module**: PowerShell module for virtual desktop management
- **VirtualDesktop.exe**: Standalone executable for AutoHotkey integration
- **fzf.exe**: Fuzzy finder for command palette (must be in PATH)
- **AutoHotkey v2**: For hotkey handling and window management

## Common Development Tasks

- **Add new command**: Create `.ps1` file in `DefaultPalette/` with `Invoke-Command` function
- **Modify hotkeys**: Edit `src/hotkey.ahk`
- **Change project configuration**: Edit `config/projects.json`
- **Debug palette issues**: Check `src/Palette.ps1` main loop starting at line 25
- **Desktop switching issues**: Review `src/hotkey.ahk` desktop state checking logic