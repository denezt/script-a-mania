# Resource Optimizer

A lightweight PowerShell utility that keeps a system active and monitors runtime activity through a background scheduler. The tool periodically triggers harmless system activity while providing runtime visibility and logging support.

This project is designed to be simple, portable, and easy to integrate into automation workflows.

---

# Features

* Lightweight background activity management
* Runtime monitoring and status display
* Configurable activity interval
* Scheduler wrapper for persistent execution
* Simple PowerShell-based architecture
* Easy installation with minimal dependencies

---

# Project Structure

```
resource-optimizer/
│
├─ resource_optimizer.ps1
│     Main activity monitoring script
│
├─ resource_optimizer_scheduler.ps1
│     Background launcher and scheduler
│
└─ README.md
      Project documentation
```

---

# Installation

## 1. Identify Your Home Directory

Run the following command to determine your PowerShell home directory:

```powershell
echo $HOME
```

---

## 2. Copy the Scripts

Move both scripts into your home directory:

```powershell
cp resource_* $HOME
```

---

## 3. Navigate to the Directory

```powershell
cd $HOME
```

---

## 4. Launch the Scheduler

Start the optimizer scheduler:

```powershell
.\resource_optimizer_scheduler.ps1
```

This launches the optimizer process and begins activity monitoring.

---

# Automatic Startup Configuration

You can configure the optimizer to start automatically when you log in.

## Option 1 — Windows Startup Folder

Create a shortcut that launches the scheduler script.

Example command for the shortcut target:

```
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "$HOME\resource_optimizer_scheduler.ps1"
```

Place the shortcut in:

```
C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
```

---

## Option 2 — Scheduled Task (Recommended)

You can register the optimizer as a scheduled task that runs at login.

```powershell
$Action = New-ScheduledTaskAction `
  -Execute "powershell.exe" `
  -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File $HOME\resource_optimizer_scheduler.ps1"

$Trigger = New-ScheduledTaskTrigger -AtLogOn

Register-ScheduledTask `
  -TaskName "ResourceOptimizer" `
  -Action $Action `
  -Trigger $Trigger `
  -Description "Launch Resource Optimizer at login"
```

This method ensures the script launches automatically and runs silently.

---

## Running in Development Mode

Run the script directly to view console monitoring output.

```powershell
.\resource_optimizer.ps1
```

This mode displays runtime metrics including:

* current time
* activity events
* elapsed runtime
* monitoring output

---

## Extending the Script

Possible enhancements include:

* randomized activity intervals
* CPU and memory monitoring
* system idle detection
* logging to file
* system tray controls
* pause / resume functionality

Because the project is pure PowerShell, it integrates easily into automation pipelines and administrative tooling.

---

# Execution Policy

If scripts cannot run due to policy restrictions, enable local script execution:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

# Contributing

Contributions are welcome. Improvements may include:

* performance enhancements
* additional monitoring capabilities
* improved scheduling behavior
* cross-platform support

Please open an issue or submit a pull request.

---

# License

This project is released under the MIT License.


