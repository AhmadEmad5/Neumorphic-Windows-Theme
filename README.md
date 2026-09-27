# 🌑 Neumorphic Dark (Soft UI) — Windows OS Customization Suite

[![Windows 11 / 10](https://img.shields.io/badge/Windows-11%20%7C%2010%20(1903%2B)-0078D4?logo=windows&logoColor=white)](https://microsoft.com)
[![WinUI 3](https://img.shields.io/badge/WinUI-3.0%20%2F%20Windows%20App%20SDK-0078D7?logo=windows-terminal&logoColor=white)](https://learn.microsoft.com/windows/apps/winui/)
[![.NET Version](https://img.shields.io/badge/.NET-8.0%20%7C%2010.0%20(x64)-512BD4?logo=dotnet&logoColor=white)](https://dotnet.microsoft.com/)
[![Aesthetic](https://img.shields.io/badge/Design-Dark%20Neumorphism%20(Soft%20UI)-18191C?logo=adobe-photoshop&logoColor=white)](#visual-design-language--palette-matrix)
[![Accessibility](https://img.shields.io/badge/WCAG-AA%20Compliant-38BDF8?logo=w3c&logoColor=white)](#visual-design-language--palette-matrix)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A production-ready, ultra-refined, system-wide **Dark Neumorphic (Soft UI)** OS customization and theming suite engineered for **Windows 11 (21H2, 22H2, 23H2, 24H2)** and **Windows 10 (1903+)**.

Unlike superficial skin packs or isolated widgets, this suite transforms the entire Windows operating system into a tactile, sculpted environment where controls appear embossed from or recessed into a deep matte slate canvas (`#18191C`), lit by a unified 135° dual-shadow lighting model with high-contrast readability preservation.

---

## 📸 Interactive Widget & Showcase Preview

| Tactile Rotary Dial HUD | Dynamic LED Bar Visualizer | Active Nav-Pill Toggles |
| :---: | :---: | :---: |
| Real-time circumferential shadow & smooth drag physics | 16 stepped physical LED segments responding to gain | Recessed soft channels with glowing indicators |

> 🌐 **Live Zero-Install Prototype**: You can immediately preview the physics, micro-animations, and visual tokens by opening [`Preview/index.html`](Preview/index.html) in any modern browser!

---

## 🎨 Visual Design Language & Palette Matrix

Neumorphism (Soft UI) avoids floating z-index layers and harsh 1px borders. Instead, elements are extruded or embossed directly from the background canvas using directional dual shadows:
- **Upper-Left Highlight Vector**: Soft, specular light reflection.
- **Lower-Right Occlusion Vector**: Deep, dissipated ambient occlusion shadow.

```
       [ 135° Directional Light Source ]
                     ↘
       ┌───────────────────────────────┐
       │ ░░░ Specular Highlight Edge   │  <- rgba(255, 255, 255, 0.07)
       │                               │
       │     Elevated Matte Surface    │  <- #1E2024
       │                               │
       │   Ambient Occlusion Shadow ▓▓ │  <- rgba(0, 0, 0, 0.65)
       └───────────────────────────────┘
```

### Precision Token Specifications

| Token Name | Hex / RGBA Value | Purpose & Application |
| :--- | :--- | :--- |
| **Base Surface** | `#18191C` (24, 25, 28) | Root desktop canvas, window backdrops, taskbar base |
| **Elevated Surface** | `#1E2024` (30, 32, 36) | Extruded cards, push buttons, thumb caps, dials |
| **Sunken Surface** | `#141517` (20, 21, 23) | Recessed channels, input fields, pressed/active states |
| **Specular Highlight** | `rgba(255, 255, 255, 0.07)` | Soft directional highlight on the 135° top-left rim |
| **Occlusion Shadow** | `rgba(0, 0, 0, 0.65)` | Soft physical drop shadow on the bottom-right rim |
| **Micro-Bezel Outline** | `rgba(255, 255, 255, 0.05)` | 0.5px translucent outline replacing harsh borders |
| **Active Accent (Cyan)** | `#38BDF8` (56, 189, 248) | Indicators, active LED bars, focus rings, toggles |
| **Accent (Ice Blue)** | `#4F80E2` (79, 128, 226) | Secondary interactive states and subtle gradient blends |
| **Typography Primary** | `#E2E8F0` (226, 232, 240) | Crisp, high-contrast readable text (WCAG AA pass) |
| **Typography Muted** | `#64748B` (100, 116, 139) | Subtitles, labels, secondary metadata |

---

## 🏗️ Architectural Layers

The customization suite is organized into 5 structured, modular layers:

```
Windoes Theams/
├── Themes/                                 # Layer 1: Native Windows Visual Style (.theme & .msstyles)
│   ├── Neumorphic.theme                    # Windows desktop root theme file
│   └── Neumorphic/
│       ├── Neumorphic.msstyles.txt         # uxtheme manifest & class layout definitions
│       ├── Neumorphic.rc                   # Win32 resource compiler script for msstyles binary
│       ├── Metrics/
│       │   ├── WindowsStyleBuilder_Metrics.json # Style Builder class/part/state mapping table
│       │   └── HighDPI_Overrides.json     # Asset coordinate scaling for 100%, 125%, 150%, 200% DPI
│       └── Shell/NormalColor/shellstyle.rc # Explorer task pane & header definitions
│
├── Registry/                               # Layer 2: System-Wide Palette & DWM Injections
│   ├── Neumorphic-Colors-DWM.reg           # Full HKCU Colors, Desktop\Colors, DWM dark mode, ClearType
│   ├── Rollback-Default-Colors.reg         # Pristine factory Windows 10/11 default rollback
│   └── Backups/                            # Safety backups auto-created prior to deployment
│
├── ShellHooks/                             # Layer 3: Modern Shell Replacement & Hook Engines
│   ├── StartAllBack/
│   │   └── Neumorphic-StartAllBack.json    # Custom taskbar segments, Start Menu & flyout styles
│   ├── Windhawk/
│   │   ├── windows-11-taskbar-neumorphic.js # Windhawk mod for taskbar item extrusion & pill glow
│   │   └── window-frame-neumorphic.js      # Windhawk mod for caption buttons & dual-shadow frames
│   └── ExplorerBlurMica/
│       └── config.ini                      # Mica/Acrylic blur radii, dark tint, and frame margins
│
├── CompanionApp/                           # Layer 4: Native WinUI 3 Neumorphic Engine (C# / XAML)
│   ├── NeumorphicEngine.csproj             # .NET 8 / 10 + Windows App SDK 1.6 project (Self-Contained x64)
│   ├── App.xaml / App.xaml.cs
│   ├── MainWindow.xaml / MainWindow.xaml.cs # Floating desktop HUD with rotary knob & visualizer
│   ├── Themes/
│   │   ├── NeumorphicTokens.xaml           # XAML Color, Brush, and Shadow resources
│   │   └── NeumorphicStyles.xaml           # ControlTemplates (Buttons, Sliders, Cards, Toggles)
│   └── Helpers/
│       └── WindowHelper.cs                 # Mica/Acrylic DwmSetWindowAttribute & overlay drag handler
│
├── Preview/                                # Layer 5: Standalone Interactive Web Prototype
│   ├── index.html                          # Tactile Audio & System Control Dashboard
│   ├── styles.css                          # Multi-layered box-shadow, extruded dial, segmented bar
│   └── app.js                              # Drag-to-rotate knob, volume readout, audio synthesizer
│
└── Scripts/                                # Layer 6: Automated Deployment & Safe Rollback
    ├── Deploy-NeumorphicOS.ps1             # Automated installation & deployment script
    └── Uninstall-Rollback.ps1              # Reversible safe uninstall & restore script
```

---

## 🛠️ Prerequisites & Requirements

- **Operating System**: Windows 11 (all versions: 21H2, 22H2, 23H2, 24H2) or Windows 10 (version 1903 or newer).
- **Architecture**: `x64` (64-bit).
- **Permissions**: Administrator privileges (required for installing visual style assets into `%SystemRoot%\Resources\Themes`).
- **For Companion App Building**: [.NET SDK 8.0, 9.0, or 10.0+](https://dotnet.microsoft.com/download).

---

## 🚀 Quick Start: Installation & Usage Guide

### Option 1: Automated 1-Click Deployment (Recommended)

1. Open PowerShell as Administrator (`Win + X` → **Terminal (Admin)** or **PowerShell (Admin)**).
2. Execute the automated deployment script:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   & ".\Scripts\Deploy-NeumorphicOS.ps1"
   ```
3. **What the script does automatically:**
   - [x] Validates elevated administrator credentials.
   - [x] Automatically exports an instant safety backup of your existing system palette to `Registry\Backups\`.
   - [x] Copies `Neumorphic.theme` and `Neumorphic/` assets to `%SystemRoot%\Resources\Themes\`.
   - [x] Injects `Neumorphic-Colors-DWM.reg` (classic 3D colors, global dark mode, DWM tint, ClearType calibration).
   - [x] Applies the visual style via Windows Theme API (`rundll32.exe themecui.dll,ThemeRundll`).
   - [x] Smoothly restarts `explorer.exe` to refresh your desktop without requiring a reboot.

---

### Option 2: Deep System Visual Style Skinning (`.msstyles`)

Windows restricts unsigned third-party `.msstyles` on title bars and common controls unless an in-memory theme hook is used. We use **SecureUxTheme** because it operates **100% in-memory** and **never modifies or patches system files on disk**:

1. Download the latest release of **[SecureUxTheme](https://github.com/namazso/SecureUxTheme/releases)**.
2. Run `ThemeTool.exe` as Administrator.
3. Check the options:
   - `Hook LogonUI`
   - `Hook Explorer`
4. Click **Install**.
5. In the theme list, select **Neumorphic Dark (Soft UI)** and click **Apply theme**.

---

### Option 3: Running the Native WinUI 3 Desktop Companion HUD

The Companion App provides a tactile desktop audio HUD with real-time volume calculations, a physical rotary knob, and a stepped LED visualizer:

```powershell
cd CompanionApp
dotnet run
```

*Built-in Capabilities:*
- **📌 Always-on-Top / Overlay Mode**: Pin the HUD over games, IDEs, or full-screen applications.
- **Acrylic / Mica Backdrop**: Uses `DwmSetWindowAttribute` for hardware-accelerated Windows 11 blur.
- **Tactile Drag Physics**: Click and drag the circular rotary dial to dynamically change gain.
- **Keyboard Controls**: `Up/Right` increases gain, `Down/Left` decreases gain, `Home/End` set min/max.

---

### Option 4: Modern Taskbar & Start Menu Hooks

- **StartAllBack**: Copy [`ShellHooks/StartAllBack/Neumorphic-StartAllBack.json`](ShellHooks/StartAllBack/Neumorphic-StartAllBack.json) into `%LOCALAPPDATA%\StartAllBack\Styles` to apply extruded taskbar button pills and sunken search boxes.
- **Windhawk**: Install [Windhawk](https://windhawk.net/), open the Mod Manager, and load:
  - [`windows-11-taskbar-neumorphic.js`](ShellHooks/Windhawk/windows-11-taskbar-neumorphic.js)
  - [`window-frame-neumorphic.js`](ShellHooks/Windhawk/window-frame-neumorphic.js)
- **ExplorerBlurMica**: Copy [`ShellHooks/ExplorerBlurMica/config.ini`](ShellHooks/ExplorerBlurMica/config.ini) into your ExplorerBlurMica directory to enforce dark acrylic blur with 16px corner rounding.

---

## 🔄 1-Click Rollback & Safety Guarantee

Your system safety is paramount. You can revert back to factory default Windows at any time:

1. Open PowerShell as Administrator.
2. Run:
   ```powershell
   & ".\Scripts\Uninstall-Rollback.ps1"
   ```
3. **What the uninstaller does:**
   - Restores the default Windows `aero.theme`.
   - Injects `Rollback-Default-Colors.reg` to reset all classic 3D system colors, DWM tints, and font settings.
   - Cleans up installed files from `%SystemRoot%\Resources\Themes\Neumorphic`.
   - Smoothly restarts `explorer.exe`.

---

## 🔧 Building from Source

To compile the WinUI 3 Companion Engine manually:

```powershell
cd CompanionApp
dotnet build NeumorphicEngine.csproj -c Release
```

The output binary is produced at:
`CompanionApp/bin/Release/net8.0-windows10.0.19041.0/win-x64/NeumorphicEngine.exe`

---

## 🤝 Contributing

Contributions, feature requests, and issue reports are welcome!
1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/NewControlStyle`).
3. Commit your Changes (`git commit -m 'Add Neumorphic DataGrid style'`).
4. Push to the Branch (`git push origin feature/NewControlStyle`).
5. Open a Pull Request.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Crafted with precision for Windows Power Users and UI Enthusiasts.
</p>
