# WinTuner

**WinTuner** is a Windows utility designed to provide a simple graphical interface for system maintenance, optimization and diagnostics.

> 🚧 **Project status:** Early development

## ✨ Features

* 🏠 Dashboard
* ⚡ Performance tools
* 🧹 Cleanup tools
* 🌐 Network tools
* 🔒 Privacy tools
* 🛠️ Repair tools
* 🧪 Safe DEMO mode
* 🚀 Startup program viewer
* 🦠 Microsoft Defender scan
* 📊 System information
* 🎨 Windows Forms graphical interface

## 🖥️ Requirements

* Windows 10 or Windows 11
* PowerShell
* Administrator privileges may be required for some tools

## 🚀 Running WinTuner

### PowerShell

Run:

```powershell
.\WINTUNNER.PS1
```

### BAT launcher

You can also start WinTuner using:

```text
WINTUNNER.BAT
```

## 🔨 Building the EXE

WinTuner can be compiled using **PS2EXE**.

Install PS2EXE:

```powershell
Install-Module ps2exe -Scope CurrentUser
```

Then compile:

```powershell
Invoke-PS2EXE `
    -inputFile ".\WINTUNNER.PS1" `
    -outputFile ".\WinTuner.exe" `
    -STA
```

The resulting executable will be:

```text
WinTuner.exe
```

## 📁 Project Structure

```text
WINTUNNER/
├── WINTUNNER.PS1
├── WINTUNNER.BAT
├── README.md
├── LICENSE
├── .gitignore
└── BAT/
    ├── PERFORMANCE.BAT
    ├── CLEANUP.BAT
    ├── NETWORK.BAT
    ├── PRIVACY.BAT
    └── REPAIR.BAT
```

## 🧪 DEMO Mode

WinTuner includes a DEMO mode designed to simulate system analysis without making changes to Windows.

This is useful for testing the interface safely.

## 🗺️ Roadmap

* [x] Graphical interface
* [x] Dashboard
* [x] DEMO mode
* [x] Startup program viewer
* [x] Microsoft Defender integration
* [ ] Performance optimization tools
* [ ] Cleanup tools
* [ ] Network optimization
* [ ] Privacy tools
* [ ] Windows repair tools
* [ ] Final EXE release
* [ ] Improved error handling
* [ ] Settings panel

## ⚠️ Disclaimer

WinTuner is an independent project and is provided for educational and personal use.

Some features may modify Windows system settings when implemented. Always make sure you understand what a system optimization tool does before applying changes.

Use at your own risk.

## 📜 License

This project is licensed under the MIT License.
