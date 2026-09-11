# ============================================================
# WinTuner
# Windows Tweaking Utility
# Version 1.0
# PS2EXE Compatible
# ============================================================

# ------------------------------------------------------------
# ADMIN CHECK
# ------------------------------------------------------------

$isAdmin = $false

try {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)

    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

    $isAdmin = $principal.IsInRole($adminRole)
}
catch {
    $isAdmin = $false
}

# ------------------------------------------------------------
# ASSEMBLIES
# ------------------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()


# ------------------------------------------------------------
# SINGLE INSTANCE
# ------------------------------------------------------------

$script:mutex = $null
$script:mutexCreated = $false

try {
    $script:mutex = New-Object System.Threading.Mutex(
        $false,
        "Global\WinTuner_SingleInstance"
    )

    $script:mutexCreated = $script:mutex.WaitOne(0, $false)

    if (-not $script:mutexCreated) {
        exit
    }
}
catch {
    exit
}

# ------------------------------------------------------------
# COLORS
# ------------------------------------------------------------

$bg = [System.Drawing.Color]::FromArgb(15,17,22)
$panel = [System.Drawing.Color]::FromArgb(23,26,33)
$panel2 = [System.Drawing.Color]::FromArgb(31,35,44)

$text = [System.Drawing.Color]::FromArgb(242,244,248)
$muted = [System.Drawing.Color]::FromArgb(145,151,163)

$accent = [System.Drawing.Color]::FromArgb(70,130,255)
$success = [System.Drawing.Color]::FromArgb(70,210,140)
$warning = [System.Drawing.Color]::FromArgb(245,180,70)
$danger = [System.Drawing.Color]::FromArgb(235,80,90)

# ------------------------------------------------------------
# MAIN FORM
# ------------------------------------------------------------

$form = New-Object System.Windows.Forms.Form

$form.Text = "WinTuner"
$form.Size = New-Object System.Drawing.Size(1150,720)
$form.MinimumSize = New-Object System.Drawing.Size(950,620)
$form.StartPosition = "CenterScreen"

$form.BackColor = $bg
$form.ForeColor = $text
$form.Font = New-Object System.Drawing.Font(
    "Segoe UI",
    10
)

# ------------------------------------------------------------
# SIDEBAR
# ------------------------------------------------------------

$sidebar = New-Object System.Windows.Forms.Panel

$sidebar.Dock = "Left"
$sidebar.Width = 225
$sidebar.BackColor = $panel

$form.Controls.Add($sidebar)

# ------------------------------------------------------------
# CONTENT
# ------------------------------------------------------------

$content = New-Object System.Windows.Forms.Panel

$content.Dock = "Fill"
$content.BackColor = $bg
$content.AutoScroll = $true

$form.Controls.Add($content)

# Make absolutely sure sidebar remains above content.
$sidebar.BringToFront()

# ------------------------------------------------------------
# LOGO
# ------------------------------------------------------------

$logo = New-Object System.Windows.Forms.Label

$logo.Text = "WinTuner"
$logo.Left = 22
$logo.Top = 22
$logo.Width = 180
$logo.Height = 42

$logo.ForeColor = $text
$logo.Font = New-Object System.Drawing.Font(
    "Segoe UI Semibold",
    22
)

$sidebar.Controls.Add($logo)

# ------------------------------------------------------------
# SUBTITLE
# ------------------------------------------------------------

$subtitle = New-Object System.Windows.Forms.Label

$subtitle.Text = "Windows Utility"
$subtitle.Left = 24
$subtitle.Top = 64
$subtitle.Width = 180
$subtitle.Height = 25

$subtitle.ForeColor = $muted
$subtitle.Font = New-Object System.Drawing.Font(
    "Segoe UI",
    9
)

$sidebar.Controls.Add($subtitle)

# ------------------------------------------------------------
# HELPERS
# ------------------------------------------------------------

function Show-Error {
    param(
        [string]$Message
    )

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        "WinTuner - Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}

function Show-Info {
    param(
        [string]$Message
    )

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        "WinTuner",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function Clear-Content {

    $content.Controls.Clear()

    $toggleButton.BringToFront()
}

function New-Title {

    param(
        [string]$Title,
        [string]$Description
    )

    $titleLabel = New-Object System.Windows.Forms.Label

    $titleLabel.Text = $Title
    $titleLabel.Left = 35
    $titleLabel.Top = 30
    $titleLabel.Width = 700
    $titleLabel.Height = 45

    $titleLabel.ForeColor = $text
    $titleLabel.Font = New-Object System.Drawing.Font(
        "Segoe UI Semibold",
        24
    )

    $content.Controls.Add($titleLabel)

    if ($Description) {

        $descriptionLabel = New-Object System.Windows.Forms.Label

        $descriptionLabel.Text = $Description
        $descriptionLabel.Left = 38
        $descriptionLabel.Top = 78
        $descriptionLabel.Width = 750
        $descriptionLabel.Height = 30

        $descriptionLabel.ForeColor = $muted
        $descriptionLabel.Font = New-Object System.Drawing.Font(
            "Segoe UI",
            10
        )

        $content.Controls.Add($descriptionLabel)
    }
}

function New-Card {

    param(
        [int]$Left,
        [int]$Top,
        [int]$Width,
        [int]$Height
    )

    $card = New-Object System.Windows.Forms.Panel

    $card.Left = $Left
    $card.Top = $Top
    $card.Width = $Width
    $card.Height = $Height

    $card.BackColor = $panel

    $content.Controls.Add($card)

    return $card
}

# ------------------------------------------------------------
# ACTION BUTTON
# ------------------------------------------------------------

function New-ActionButton {

    param(
        [string]$ButtonText,
        [int]$Left,
        [int]$Top,
        [scriptblock]$Action
    )

    $button = New-Object System.Windows.Forms.Button

    $button.Text = $ButtonText
    $button.Left = $Left
    $button.Top = $Top

    $button.Width = 210
    $button.Height = 48

    $button.FlatStyle = "Flat"
    $button.FlatAppearance.BorderSize = 0

    $button.BackColor = $panel2
    $button.ForeColor = $text

    $button.Font = New-Object System.Drawing.Font(
        "Segoe UI Semibold",
        10
    )

    # Store the action in a normal script variable.
    $localAction = $Action

    $button.Add_MouseEnter({
        $this.BackColor = $accent
    })

    $button.Add_MouseLeave({
        $this.BackColor = $panel2
    })

    $button.Add_Click({

        try {

            if ($null -ne $localAction) {
                & $localAction
            }

        }
        catch {

            Show-Error $_.Exception.Message
        }
    })

    $content.Controls.Add($button)

    return $button
}

# ------------------------------------------------------------
# NAVIGATION BUTTON
# ------------------------------------------------------------

function New-NavButton {

    param(
        [string]$ButtonText,
        [int]$Top
    )

    $button = New-Object System.Windows.Forms.Button

    $button.Text = $ButtonText

    $button.Left = 12
    $button.Top = $Top

    $button.Width = 200
    $button.Height = 42

    $button.FlatStyle = "Flat"
    $button.FlatAppearance.BorderSize = 0

    $button.BackColor = $panel
    $button.ForeColor = $muted

    $button.TextAlign = "MiddleLeft"

    $button.Padding = New-Object System.Windows.Forms.Padding(
        18,0,0,0
    )

    $button.Font = New-Object System.Drawing.Font(
        "Segoe UI Semibold",
        10
    )

    $button.Add_MouseEnter({

        $this.BackColor = $panel2
        $this.ForeColor = $text
    })

    $button.Add_MouseLeave({

        $this.BackColor = $panel
        $this.ForeColor = $muted
    })

    $sidebar.Controls.Add($button)

    return $button
}

# ------------------------------------------------------------
# HOME
# ------------------------------------------------------------

function Show-Home {

    Clear-Content

    New-Title `
        "Dashboard" `
        "Bienvenido a WinTuner"

    # HERO

    $hero = New-Card `
        35 `
        125 `
        840 `
        150

    $heroTitle = New-Object System.Windows.Forms.Label

    $heroTitle.Text = "Optimiza tu PC"
    $heroTitle.Left = 25
    $heroTitle.Top = 25
    $heroTitle.Width = 500
    $heroTitle.Height = 40

    $heroTitle.ForeColor = $text
    $heroTitle.Font = New-Object System.Drawing.Font(
        "Segoe UI Semibold",
        20
    )

    $hero.Controls.Add($heroTitle)

    $heroText = New-Object System.Windows.Forms.Label

    $heroText.Text = "Herramientas para mantenimiento, rendimiento y diagnostico."
    $heroText.Left = 27
    $heroText.Top = 70
    $heroText.Width = 650
    $heroText.Height = 30

    $heroText.ForeColor = $muted

    $hero.Controls.Add($heroText)

    # ADMIN STATUS

    $adminLabel = New-Object System.Windows.Forms.Label

    if ($isAdmin) {

        $adminLabel.Text = "● Ejecutando como administrador"
        $adminLabel.ForeColor = $success

    }
    else {

        $adminLabel.Text = "● Ejecutando sin privilegios de administrador"
        $adminLabel.ForeColor = $warning
    }

    $adminLabel.Left = 27
    $adminLabel.Top = 105
    $adminLabel.Width = 500
    $adminLabel.Height = 25

    $hero.Controls.Add($adminLabel)

    # PC INFO

    $pc = New-Card `
        35 `
        295 `
        405 `
        145

    $pcTitle = New-Object System.Windows.Forms.Label

    $pcTitle.Text = "Sistema"
    $pcTitle.Left = 20
    $pcTitle.Top = 18
    $pcTitle.Width = 300
    $pcTitle.Height = 30

    $pcTitle.Font = New-Object System.Drawing.Font(
        "Segoe UI Semibold",
        14
    )

    $pc.Controls.Add($pcTitle)

    $computerName = $env:COMPUTERNAME

    $pcInfo = New-Object System.Windows.Forms.Label

    $pcInfo.Text = "PC: $computerName`r`nUsuario: $env:USERNAME`r`nWindows: $([Environment]::OSVersion.Version)"

    $pcInfo.Left = 20
    $pcInfo.Top = 55
    $pcInfo.Width = 360
    $pcInfo.Height = 70

    $pcInfo.ForeColor = $muted

    $pc.Controls.Add($pcInfo)

    # STATUS

    $status = New-Card `
        470 `
        295 `
        405 `
        145

    $statusTitle = New-Object System.Windows.Forms.Label

    $statusTitle.Text = "Estado"
    $statusTitle.Left = 20
    $statusTitle.Top = 18
    $statusTitle.Width = 300
    $statusTitle.Height = 30

    $statusTitle.Font = New-Object System.Drawing.Font(
        "Segoe UI Semibold",
        14
    )

    $status.Controls.Add($statusTitle)

    $statusText = New-Object System.Windows.Forms.Label

    $statusText.Text = "WinTuner esta listo para trabajar."
    $statusText.Left = 20
    $statusText.Top = 58
    $statusText.Width = 350
    $statusText.Height = 60

    $statusText.ForeColor = $success

    $status.Controls.Add($statusText)

    # QUICK ACTIONS

    $quickTitle = New-Object System.Windows.Forms.Label

    $quickTitle.Text = "Acciones rapidas"
    $quickTitle.Left = 35
    $quickTitle.Top = 465
    $quickTitle.Width = 400
    $quickTitle.Height = 30

    $quickTitle.Font = New-Object System.Drawing.Font(
        "Segoe UI Semibold",
        14
    )

    $content.Controls.Add($quickTitle)

    New-ActionButton `
        "Modo DEMO" `
        35 `
        510 `
        {
            Show-Demo
        }

    New-ActionButton `
        "Rendimiento" `
        260 `
        510 `
        {
            Show-Performance
        }

    New-ActionButton `
        "Programas de inicio" `
        485 `
        510 `
        {
            Show-Startup
        }

    New-ActionButton `
        "Scan de virus" `
        710 `
        510 `
        {
            Show-VirusScan
        }
}

# ------------------------------------------------------------
# DEMO
# ------------------------------------------------------------

function Show-Demo {

    Clear-Content

    New-Title `
        "Modo DEMO" `
        "Simulacion segura: no modifica Windows."

    $card = New-Card `
        35 `
        125 `
        840 `
        360

    $label = New-Object System.Windows.Forms.Label

    $label.Text = "Preparado"
    $label.Left = 30
    $label.Top = 30
    $label.Width = 700
    $label.Height = 35

    $label.Font = New-Object System.Drawing.Font(
        "Segoe UI Semibold",
        14
    )

    $card.Controls.Add($label)

    $progress = New-Object System.Windows.Forms.ProgressBar

    $progress.Left = 30
    $progress.Top = 85

    $progress.Width = 760
    $progress.Height = 28

    $progress.Minimum = 0
    $progress.Maximum = 100

    $card.Controls.Add($progress)

    $steps = @(
        "Analizando sistema...",
        "Comprobando memoria...",
        "Analizando disco...",
        "Comprobando red...",
        "Comprobando programas de inicio...",
        "Analisis completado."
    )

    $i = 0

    foreach ($step in $steps) {

        $label.Text = $step

        $progress.Value = [Math]::Min(
            100,
            (($i + 1) * 100 / $steps.Count)
        )

        [System.Windows.Forms.Application]::DoEvents()

        Start-Sleep -Milliseconds 500

        $i++
    }

    $label.Text = "✓ DEMO completada. No se ha modificado nada."

    $label.ForeColor = $success
}

# ------------------------------------------------------------
# PERFORMANCE
# ------------------------------------------------------------

function Show-Performance {

    Clear-Content

    New-Title `
        "Rendimiento" `
        "Herramientas de optimizacion."

    New-ActionButton `
        "Modo DEMO" `
        35 `
        130 `
        {
            Show-Demo
        }

    New-ActionButton `
        "Alto rendimiento" `
        260 `
        130 `
        {
            Show-Info "Funcion preparada para una futura version."
        }

    New-ActionButton `
        "Game Mode" `
        485 `
        130 `
        {
            Show-Info "Game Mode estara disponible proximamente."
        }

    New-ActionButton `
        "Efectos visuales" `
        710 `
        130 `
        {
            Show-Info "Configuracion de efectos visuales en desarrollo."
        }

    New-ActionButton `
        "Programas de inicio" `
        35 `
        200 `
        {
            Show-Startup
        }
}

# ------------------------------------------------------------
# STARTUP PROGRAMS
# ------------------------------------------------------------

function Show-Startup {

    Clear-Content

    New-Title `
        "Programas de inicio" `
        "Aplicaciones configuradas para iniciarse con Windows."

    $list = New-Object System.Windows.Forms.ListView

    $list.Left = 35
    $list.Top = 125

    $list.Width = 840
    $list.Height = 450

    $list.View = "Details"
    $list.FullRowSelect = $true
    $list.GridLines = $true

    $list.BackColor = $panel
    $list.ForeColor = $text

    [void]$list.Columns.Add(
        "Nombre",
        220
    )

    [void]$list.Columns.Add(
        "Comando",
        400
    )

    [void]$list.Columns.Add(
        "Ubicacion",
        180
    )

    $content.Controls.Add($list)

    try {

        $startup = Get-CimInstance `
            Win32_StartupCommand `
            -ErrorAction Stop

        foreach ($item in $startup) {

            $row = New-Object System.Windows.Forms.ListViewItem(
                [string]$item.Name
            )

            [void]$row.SubItems.Add(
                [string]$item.Command
            )

            [void]$row.SubItems.Add(
                [string]$item.Location
            )

            [void]$list.Items.Add($row)
        }
    }
    catch {

        Show-Error $_.Exception.Message
    }
}

# ------------------------------------------------------------
# VIRUS SCAN
# ------------------------------------------------------------

function Show-VirusScan {

    Clear-Content

    New-Title `
        "Scan de virus" `
        "Microsoft Defender."

    $card = New-Card `
        35 `
        125 `
        840 `
        330

    $title = New-Object System.Windows.Forms.Label

    $title.Text = "Microsoft Defender"
    $title.Left = 25
    $title.Top = 25
    $title.Width = 500
    $title.Height = 35

    $title.Font = New-Object System.Drawing.Font(
        "Segoe UI Semibold",
        18
    )

    $card.Controls.Add($title)

    $description = New-Object System.Windows.Forms.Label

    $description.Text = "Selecciona el tipo de analisis que quieres realizar."
    $description.Left = 27
    $description.Top = 70
    $description.Width = 650
    $description.Height = 30

    $description.ForeColor = $muted

    $card.Controls.Add($description)

    $quick = New-Object System.Windows.Forms.Button

    $quick.Text = "Analisis rapido"

    $quick.Left = 27
    $quick.Top = 120

    $quick.Width = 200
    $quick.Height = 48

    $quick.FlatStyle = "Flat"
    $quick.FlatAppearance.BorderSize = 0

    $quick.BackColor = $panel2
    $quick.ForeColor = $text

    $card.Controls.Add($quick)

    $full = New-Object System.Windows.Forms.Button

    $full.Text = "Analisis completo"

    $full.Left = 245
    $full.Top = 120

    $full.Width = 200
    $full.Height = 48

    $full.FlatStyle = "Flat"
    $full.FlatAppearance.BorderSize = 0

    $full.BackColor = $panel2
    $full.ForeColor = $text

    $card.Controls.Add($full)

    $status = New-Object System.Windows.Forms.Label

    $status.Text = "Listo."
    $status.Left = 27
    $status.Top = 190
    $status.Width = 700
    $status.Height = 30

    $status.ForeColor = $success

    $card.Controls.Add($status)

    $progress = New-Object System.Windows.Forms.ProgressBar

    $progress.Left = 27
    $progress.Top = 235

    $progress.Width = 700
    $progress.Height = 25

    $progress.Minimum = 0
    $progress.Maximum = 100

    $card.Controls.Add($progress)

    # QUICK SCAN

    $quick.Add_Click({

        try {

            $status.Text = "Iniciando analisis rapido..."
            $status.ForeColor = $warning

            $progress.Style = "Marquee"

            [System.Windows.Forms.Application]::DoEvents()

            $defender = Get-Command `
                Start-MpScan `
                -ErrorAction SilentlyContinue

            if ($null -eq $defender) {

                $progress.Style = "Blocks"

                $status.Text = "Microsoft Defender no esta disponible."
                $status.ForeColor = $danger

                return
            }

            Start-MpScan -ScanType QuickScan

            $progress.Style = "Blocks"
            $progress.Value = 100

            $status.Text = "Analisis rapido iniciado correctamente."
            $status.ForeColor = $success
        }
        catch {

            $progress.Style = "Blocks"

            $status.Text = "Error al iniciar el analisis."

            Show-Error $_.Exception.Message
        }
    })

    # FULL SCAN

    $full.Add_Click({

        try {

            $status.Text = "Iniciando analisis completo..."
            $status.ForeColor = $warning

            $progress.Style = "Marquee"

            [System.Windows.Forms.Application]::DoEvents()

            $defender = Get-Command `
                Start-MpScan `
                -ErrorAction SilentlyContinue

            if ($null -eq $defender) {

                $progress.Style = "Blocks"

                $status.Text = "Microsoft Defender no esta disponible."
                $status.ForeColor = $danger

                return
            }

            Start-MpScan -ScanType FullScan

            $progress.Style = "Blocks"
            $progress.Value = 100

            $status.Text = "Analisis completo iniciado correctamente."
            $status.ForeColor = $success
        }
        catch {

            $progress.Style = "Blocks"

            $status.Text = "Error al iniciar el analisis."

            Show-Error $_.Exception.Message
        }
    })
}

# ------------------------------------------------------------
# SIMPLE PLACEHOLDER PAGE
# ------------------------------------------------------------

function Show-ComingSoon {

    param(
        [string]$Section
    )

    Clear-Content

    New-Title `
        $Section `
        "Esta seccion esta en desarrollo."

    $card = New-Card `
        35 `
        125 `
        840 `
        180

    $label = New-Object System.Windows.Forms.Label

    $label.Text = "🚧 $Section`r`n`r`nEsta herramienta estara disponible en una futura version."
    $label.Left = 25
    $label.Top = 25
    $label.Width = 760
    $label.Height = 120

    $label.ForeColor = $muted

    $card.Controls.Add($label)
}

# ------------------------------------------------------------
# NAVIGATION
# ------------------------------------------------------------

$homeButton = New-NavButton `
    "Inicio" `
    110

$performanceButton = New-NavButton `
    "Rendimiento" `
    160

$cleanButton = New-NavButton `
    "Limpieza" `
    210

$networkButton = New-NavButton `
    "Red" `
    260

$privacyButton = New-NavButton `
    "Privacidad" `
    310

$repairButton = New-NavButton `
    "Reparacion" `
    360

$demoButton = New-NavButton `
    "Modo DEMO" `
    410

# ------------------------------------------------------------
# NAV EVENTS
# ------------------------------------------------------------

$homeButton.Add_Click({

    try {
        Show-Home
    }
    catch {
        Show-Error $_.Exception.Message
    }
})

$performanceButton.Add_Click({

    try {
        Show-Performance
    }
    catch {
        Show-Error $_.Exception.Message
    }
})

$cleanButton.Add_Click({

    try {
        Show-ComingSoon "Limpieza"
    }
    catch {
        Show-Error $_.Exception.Message
    }
})

$networkButton.Add_Click({

    try {
        Show-ComingSoon "Red"
    }
    catch {
        Show-Error $_.Exception.Message
    }
})

$privacyButton.Add_Click({

    try {
        Show-ComingSoon "Privacidad"
    }
    catch {
        Show-Error $_.Exception.Message
    }
})

$repairButton.Add_Click({

    try {
        Show-ComingSoon "Reparacion"
    }
    catch {
        Show-Error $_.Exception.Message
    }
})

$demoButton.Add_Click({

    try {
        Show-Demo
    }
    catch {
        Show-Error $_.Exception.Message
    }
})

# ------------------------------------------------------------
# SIDEBAR FOOTER
# ------------------------------------------------------------

$version = New-Object System.Windows.Forms.Label

$version.Text = "WinTuner v1.0"

$version.Left = 25
$version.Top = 625

$version.Width = 170
$version.Height = 25

$version.ForeColor = $muted

$sidebar.Controls.Add($version)

# ------------------------------------------------------------
# SIDEBAR TOGGLE
# ------------------------------------------------------------

$toggleButton = New-Object System.Windows.Forms.Button

$toggleButton.Text = "☰"

$toggleButton.Width = 48
$toggleButton.Height = 40

$toggleButton.Left = 235
$toggleButton.Top = 12

$toggleButton.FlatStyle = "Flat"
$toggleButton.FlatAppearance.BorderSize = 0

$toggleButton.BackColor = $panel2
$toggleButton.ForeColor = $text

$toggleButton.Font = New-Object System.Drawing.Font(
    "Segoe UI Semibold",
    12
)

$form.Controls.Add($toggleButton)

# ------------------------------------------------------------
# SIDEBAR ANIMATION
# ------------------------------------------------------------

$script:sidebarExpanded = $true

$sidebarTimer = New-Object System.Windows.Forms.Timer

$sidebarTimer.Interval = 10

$sidebarTimer.Add_Tick({

    if ($script:sidebarExpanded) {

        if ($sidebar.Width -lt 225) {

            $sidebar.Width += 15

        }
        else {

            $sidebar.Width = 225
            $sidebarTimer.Stop()
        }

        $toggleButton.Left = $sidebar.Width + 10
    }
    else {

        if ($sidebar.Width -gt 0) {

            $sidebar.Width -= 15

        }
        else {

            $sidebar.Width = 0
            $sidebarTimer.Stop()
        }

        $toggleButton.Left = $sidebar.Width + 10
    }

    $sidebar.BringToFront()
    $toggleButton.BringToFront()
})

$toggleButton.Add_Click({

    $script:sidebarExpanded = -not $script:sidebarExpanded

    $sidebarTimer.Start()
})

# ------------------------------------------------------------
# FORM SHOWN
# ------------------------------------------------------------

$form.Add_Shown({

    $sidebar.BringToFront()
    $toggleButton.BringToFront()

})

# ------------------------------------------------------------
# START
# ------------------------------------------------------------

Show-Home

$sidebar.BringToFront()
$toggleButton.BringToFront()

# ------------------------------------------------------------
# RUN
# ------------------------------------------------------------

try {

    [void]$form.ShowDialog()
}
catch {

    Show-Error $_.Exception.Message
}
finally {

    if ($script:mutex) {

        try {

            if ($script:mutexCreated) {
                $script:mutex.ReleaseMutex()
            }

        }
        catch {}

        try {
            $script:mutex.Dispose()
        }
        catch {}
    }
}
```

