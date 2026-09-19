# ============================================================
# WinTuner
# Windows Tweaking Utility
# Version 1.0.1 (fix: bucle de auto-elevacion)
# PS2EXE Compatible
# ============================================================

# ------------------------------------------------------------
# DETECCION DE ADMIN Y DE RELANZAMIENTO ELEVADO
# ------------------------------------------------------------

$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentPrincipal = New-Object -TypeName Security.Principal.WindowsPrincipal -ArgumentList $currentIdentity
$isAdmin = $currentPrincipal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

# Doble comprobacion: args Y variable de entorno, por si ps2exe no propaga bien $args
# a traves de Start-Process -Verb RunAs en algunos entornos.
$isElevatedRelaunch = ($args -contains "--elevated") -or ($env:WINTUNER_ELEVATED -eq "1")

# ------------------------------------------------------------
# ASSEMBLIES
# ------------------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

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
# ADMIN ACCESS CODE
# ------------------------------------------------------------

$adminAccessCode = "1234"

function Show-AdminAccessCode {

    $codeForm = New-Object System.Windows.Forms.Form

    $codeForm.Text = "WinTuner - Admin Access"
    $codeForm.Size = [System.Drawing.Size]::new(440,280)
    $codeForm.StartPosition = "CenterScreen"
    $codeForm.FormBorderStyle = "FixedDialog"
    $codeForm.MaximizeBox = $false
    $codeForm.MinimizeBox = $false
    $codeForm.BackColor = $bg
    $codeForm.ForeColor = $text

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "Admin Access"
    $title.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        18,
        [System.Drawing.FontStyle]::Bold
    )
    $title.ForeColor = $text
    $title.AutoSize = $true
    $title.Location = [System.Drawing.Point]::new(35,25)

    $description = New-Object System.Windows.Forms.Label
    $description.Text = "Introduce el codigo de administrador para continuar."
    $description.Font = [System.Drawing.Font]::new("Segoe UI",10)
    $description.ForeColor = $muted
    $description.AutoSize = $true
    $description.Location = [System.Drawing.Point]::new(37,65)

    $codeBox = New-Object System.Windows.Forms.TextBox
    $codeBox.Location = [System.Drawing.Point]::new(35,105)
    $codeBox.Size = [System.Drawing.Size]::new(350,35)
    $codeBox.Font = [System.Drawing.Font]::new("Segoe UI",12)
    $codeBox.UseSystemPasswordChar = $true
    $codeBox.BackColor = $panel2
    $codeBox.ForeColor = $text

    $status = New-Object System.Windows.Forms.Label
    $status.Text = ""
    $status.Font = [System.Drawing.Font]::new("Segoe UI",9)
    $status.ForeColor = $danger
    $status.AutoSize = $true
    $status.Location = [System.Drawing.Point]::new(37,145)

    $continueButton = New-Object System.Windows.Forms.Button
    $continueButton.Text = "Continuar"
    $continueButton.Location = [System.Drawing.Point]::new(210,180)
    $continueButton.Size = [System.Drawing.Size]::new(175,40)
    $continueButton.FlatStyle = "Flat"
    $continueButton.FlatAppearance.BorderSize = 0
    $continueButton.BackColor = $accent
    $continueButton.ForeColor = [System.Drawing.Color]::White

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Cancelar"
    $cancelButton.Location = [System.Drawing.Point]::new(35,180)
    $cancelButton.Size = [System.Drawing.Size]::new(160,40)
    $cancelButton.FlatStyle = "Flat"
    $cancelButton.FlatAppearance.BorderSize = 0
    $cancelButton.BackColor = $panel2
    $cancelButton.ForeColor = $text

    $attempts = 0

    $continueButton.Add_Click({

        if ($codeBox.Text -eq $adminAccessCode) {

            $codeForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $codeForm.Close()

        }
        else {

            $attempts++

            $codeBox.Clear()

            if ($attempts -ge 3) {

                [System.Windows.Forms.MessageBox]::Show(
                    "Has superado el numero de intentos.",
                    "WinTuner",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )

                $codeForm.DialogResult =
                    [System.Windows.Forms.DialogResult]::Cancel

                $codeForm.Close()
            }
            else {

                $remaining = 3 - $attempts

                $status.Text =
                    "Codigo incorrecto. Intentos restantes: $remaining"

                $codeBox.Focus()
            }
        }
    })

    $cancelButton.Add_Click({

        $codeForm.DialogResult =
            [System.Windows.Forms.DialogResult]::Cancel

        $codeForm.Close()
    })

    $codeBox.Add_KeyDown({

        param($senderControl,$e)

        if ($e.KeyCode -eq "Enter") {

            $continueButton.PerformClick()

            $e.SuppressKeyPress = $true
        }
    })

    $codeForm.Controls.Add($title)
    $codeForm.Controls.Add($description)
    $codeForm.Controls.Add($codeBox)
    $codeForm.Controls.Add($status)
    $codeForm.Controls.Add($continueButton)
    $codeForm.Controls.Add($cancelButton)

    $codeForm.AcceptButton = $continueButton
    $codeForm.CancelButton = $cancelButton

    $codeBox.Focus()

    return (
        $codeForm.ShowDialog() -eq
        [System.Windows.Forms.DialogResult]::OK
    )
}

# ------------------------------------------------------------
# START AS ADMINISTRATOR (version simplificada y robusta)
# ------------------------------------------------------------
# FIX: se elimino la rama que usaba $PSCommandPath para relanzar via
# "powershell.exe -File ...". En un .exe compilado con ps2exe, $PSCommandPath
# no es fiable (puede estar vacio o apuntar a una ruta que no existe en la
# maquina del usuario), lo que provocaba relanzamientos fallidos o en bucle.
# Ahora SIEMPRE se relanza el propio .exe actual, y se pasa ademas una
# variable de entorno como respaldo por si el argumento "--elevated" no
# llega correctamente al proceso hijo.

function Start-AsAdministrator {

    try {

        $currentExe =
            [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $currentExe
        $psi.Arguments = "--elevated"
        $psi.Verb = "runas"
        $psi.UseShellExecute = $true

        # Respaldo: si el hijo hereda el entorno (algunos casos de -Verb runas
        # SI heredan variables de entorno del usuario), esto ayuda a detectar
        # el relanzamiento aunque "$args" no se propague bien.
        $env:WINTUNER_ELEVATED = "1"

        [System.Diagnostics.Process]::Start($psi) | Out-Null

        return $true
    }
    catch {

        return $false
    }
}

# ------------------------------------------------------------
# FLUJO DE ACCESO Y ELEVACION
# ------------------------------------------------------------

if (-not $isElevatedRelaunch) {

    if (-not (Show-AdminAccessCode)) {
        exit
    }
}

if (-not $isAdmin) {

    # FIX CRITICO: si ya venimos de un relanzamiento elevado y SEGUIMOS sin
    # ser administrador, algo ha fallado en la deteccion (o el usuario
    # cancelo el UAC en una comprobacion previa). NO reintentamos elevar de
    # nuevo: esto es lo que antes provocaba el bucle infinito de procesos.
    if ($isElevatedRelaunch) {

        [System.Windows.Forms.MessageBox]::Show(
            "WinTuner no pudo confirmar permisos de administrador tras la elevacion.`n`nCierra el programa y vuelve a intentarlo.",
            "WinTuner",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )

        exit
    }

    $elevated = Start-AsAdministrator

    if (-not $elevated) {

        [System.Windows.Forms.MessageBox]::Show(
            "No se pudo iniciar WinTuner como administrador.`n`n(Es posible que hayas cancelado el aviso de UAC.)",
            "WinTuner",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )

        exit
    }

    exit
}

# ------------------------------------------------------------
# SINGLE INSTANCE (mutex)
# ------------------------------------------------------------
# FIX: el mutex ahora solo se reclama aqui, DESPUES de confirmar que este
# es el proceso final (ya con permisos de administrador) que va a mostrar
# la ventana principal. Antes se reclamaba al principio del script, incluso
# en el proceso "temporal" que solo iba a relanzarse y salir, lo cual podia
# causar condiciones de carrera entre el proceso viejo y el nuevo elevado.

$mutexName = "Global\WinTuner_SingleInstance"

$mutex = New-Object System.Threading.Mutex($false, $mutexName)

$gotMutex = $false

try {
    $gotMutex = $mutex.WaitOne(0, $false)
}
catch [System.Threading.AbandonedMutexException] {
    # Un proceso anterior murio sin liberar el mutex correctamente.
    # Lo tratamos como si lo hubieramos adquirido nosotros.
    $gotMutex = $true
}
catch {
    $gotMutex = $false
}

if (-not $gotMutex) {

    [System.Windows.Forms.MessageBox]::Show(
        "WinTuner ya esta abierto.",
        "WinTuner",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )

    exit
}

# ------------------------------------------------------------
# MAIN FORM
# ------------------------------------------------------------

$form = New-Object System.Windows.Forms.Form

$form.Text = "WinTuner"
$form.Size = [System.Drawing.Size]::new(1150,720)
$form.MinimumSize = [System.Drawing.Size]::new(950,620)
$form.StartPosition = "CenterScreen"
$form.BackColor = $bg
$form.ForeColor = $text

# ------------------------------------------------------------
# SIDEBAR
# ------------------------------------------------------------

$sidebarWidth = 225

$sidebar = New-Object System.Windows.Forms.Panel
$sidebar.Location = [System.Drawing.Point]::new(0,0)
$sidebar.Size = [System.Drawing.Size]::new($sidebarWidth,720)
$sidebar.BackColor = $panel
$sidebar.Anchor = (
    [System.Windows.Forms.AnchorStyles]::Top `
    -bor [System.Windows.Forms.AnchorStyles]::Bottom `
    -bor [System.Windows.Forms.AnchorStyles]::Left
)

$form.Controls.Add($sidebar)

# ------------------------------------------------------------
# CONTENT
# ------------------------------------------------------------

$content = New-Object System.Windows.Forms.Panel
$content.Location = [System.Drawing.Point]::new($sidebarWidth,0)
$content.Size = [System.Drawing.Size]::new(
    $form.ClientSize.Width - $sidebarWidth,
    $form.ClientSize.Height
)

$content.BackColor = $bg
$content.AutoScroll = $true
$content.Anchor = (
    [System.Windows.Forms.AnchorStyles]::Top `
    -bor [System.Windows.Forms.AnchorStyles]::Bottom `
    -bor [System.Windows.Forms.AnchorStyles]::Left `
    -bor [System.Windows.Forms.AnchorStyles]::Right
)

$form.Controls.Add($content)

# ------------------------------------------------------------
# LOGO
# ------------------------------------------------------------

$logo = New-Object System.Windows.Forms.Label
$logo.Text = "WinTuner"
    $logo.Font = [System.Drawing.Font]::new(
    "Segoe UI",
    21,
    [System.Drawing.FontStyle]::Bold
)
$logo.ForeColor = $text
$logo.AutoSize = $true
$logo.Location = [System.Drawing.Point]::new(25,25)

$sidebar.Controls.Add($logo)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "Windows Utility"
$subtitle.Font = [System.Drawing.Font]::new("Segoe UI",9)
$subtitle.ForeColor = $muted
$subtitle.AutoSize = $true
$subtitle.Location = [System.Drawing.Point]::new(27,62)

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
        "WinTuner",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
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
    )
}

function Clear-Content {

    $content.Controls.Clear()

    if ($toggleButton) {
        $toggleButton.BringToFront()
    }
}

function New-Title {

    param(
        [string]$Title,
        [string]$Description
    )

    $titleLabel = New-Object System.Windows.Forms.Label

    $titleLabel.Text = $Title
    $titleLabel.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        24,
        [System.Drawing.FontStyle]::Bold
    )
    $titleLabel.ForeColor = $text
    $titleLabel.AutoSize = $true
    $titleLabel.Location = [System.Drawing.Point]::new(35,30)

    $content.Controls.Add($titleLabel)

    $descriptionLabel = New-Object System.Windows.Forms.Label

    $descriptionLabel.Text = $Description
    $descriptionLabel.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        10
    )
    $descriptionLabel.ForeColor = $muted
    $descriptionLabel.AutoSize = $true
    $descriptionLabel.Location = [System.Drawing.Point]::new(37,72)

    $content.Controls.Add($descriptionLabel)
}

function New-Card {

    param(
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height
    )

    $card = New-Object System.Windows.Forms.Panel

    $card.Location = [System.Drawing.Point]::new($X,$Y)
    $card.Size = [System.Drawing.Size]::new($Width,$Height)
    $card.BackColor = $panel

    $content.Controls.Add($card)

    return $card
}

function New-ActionButton {

    param(
        [string]$Text,
        [int]$X,
        [int]$Y,
        [scriptblock]$Action
    )

    $button = New-Object System.Windows.Forms.Button

    $button.Text = $Text
    $button.Location = [System.Drawing.Point]::new($X,$Y)
    $button.Size = [System.Drawing.Size]::new(230,55)

    $button.FlatStyle = "Flat"
    $button.FlatAppearance.BorderSize = 0

    $button.BackColor = $panel2
    $button.ForeColor = $text

    $button.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        10,
        [System.Drawing.FontStyle]::Bold
    )

    $button.Cursor = [System.Windows.Forms.Cursors]::Hand

    $localAction = $Action

    $button.Add_Click({

        try {
            & $localAction
        }
        catch {
            Show-Error $_.Exception.Message
        }
    })

    $button.Add_MouseEnter({

        $this.BackColor = $accent
    })

    $button.Add_MouseLeave({

        $this.BackColor = $panel2
    })

    $content.Controls.Add($button)

    return $button
}

function New-NavButton {

    param(
        [string]$Text,
        [int]$Y,
        [scriptblock]$Action
    )

    $button = New-Object System.Windows.Forms.Button

    $button.Text = $Text
    $button.Location = [System.Drawing.Point]::new(12,$Y)
    $button.Size = [System.Drawing.Size]::new(200,40)

    $button.FlatStyle = "Flat"
    $button.FlatAppearance.BorderSize = 0

    $button.BackColor = $panel
    $button.ForeColor = $muted

    $button.TextAlign =
        [System.Drawing.ContentAlignment]::MiddleLeft

    $button.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        10
    )

    $button.Cursor =
        [System.Windows.Forms.Cursors]::Hand

    $localAction = $Action

    $button.Add_Click({

        & $localAction
    })

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

# ============================================================
# HOME
# ============================================================

function Show-Home {

    Clear-Content

    New-Title `
        "Dashboard" `
        "Bienvenido a WinTuner."

    $hero = New-Card 35 110 840 170

    $heroTitle = New-Object System.Windows.Forms.Label
    $heroTitle.Text = "Optimiza tu PC"
    $heroTitle.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        20,
        [System.Drawing.FontStyle]::Bold
    )
    $heroTitle.ForeColor = $text
    $heroTitle.AutoSize = $true
    $heroTitle.Location = [System.Drawing.Point]::new(25,20)

    $hero.Controls.Add($heroTitle)

    $heroText = New-Object System.Windows.Forms.Label
    $heroText.Text =
        "Herramientas para mantener Windows limpio, rapido y optimizado."
    $heroText.Font = [System.Drawing.Font]::new("Segoe UI",10)
    $heroText.ForeColor = $muted
    $heroText.AutoSize = $true
    $heroText.Location = [System.Drawing.Point]::new(27,62)

    $hero.Controls.Add($heroText)

    $adminLabel = New-Object System.Windows.Forms.Label

        $adminLabel.Text = "[OK] Ejecutando como administrador"
    $adminLabel.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        10,
        [System.Drawing.FontStyle]::Bold
    )

    $adminLabel.ForeColor = $success
    $adminLabel.AutoSize = $true
    $adminLabel.Location = [System.Drawing.Point]::new(27,105)

    $hero.Controls.Add($adminLabel)

    $pcCard = New-Card 35 300 840 150

    $pcTitle = New-Object System.Windows.Forms.Label
    $pcTitle.Text = "Informacion del sistema"
    $pcTitle.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        14,
        [System.Drawing.FontStyle]::Bold
    )
    $pcTitle.ForeColor = $text
    $pcTitle.AutoSize = $true
    $pcTitle.Location = [System.Drawing.Point]::new(20,15)

    $pcCard.Controls.Add($pcTitle)

    $computerName = $env:COMPUTERNAME
    $username = $env:USERNAME

    try {

        $os = Get-CimInstance Win32_OperatingSystem
        $windowsVersion = $os.Caption

    }
    catch {

        $windowsVersion = "Windows"
    }

    $infoText = @"
PC: $computerName
Usuario: $username
Sistema: $windowsVersion
"@

    $pcInfo = New-Object System.Windows.Forms.Label
    $pcInfo.Text = $infoText
    $pcInfo.Font = [System.Drawing.Font]::new("Segoe UI",10)
    $pcInfo.ForeColor = $muted
    $pcInfo.AutoSize = $true
    $pcInfo.Location = [System.Drawing.Point]::new(22,50)

    $pcCard.Controls.Add($pcInfo)

    $statusCard = New-Card 35 470 840 70

    $statusLabel = New-Object System.Windows.Forms.Label

    $statusLabel.Text = "* WinTuner esta listo."
    $statusLabel.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        11,
        [System.Drawing.FontStyle]::Bold
    )

    $statusLabel.ForeColor = $success
    $statusLabel.AutoSize = $true
    $statusLabel.Location = [System.Drawing.Point]::new(22,22)

    $statusCard.Controls.Add($statusLabel)

    New-ActionButton `
        "Modo DEMO" `
        35 `
        565 `
        {
            Show-Demo
        }

    New-ActionButton `
        "Rendimiento" `
        280 `
        565 `
        {
            Show-Performance
        }

    New-ActionButton `
        "Programas de inicio" `
        525 `
        565 `
        {
            Show-Startup
        }

    New-ActionButton `
        "Scan de virus" `
        770 `
        565 `
        {
            Show-VirusScan
        }
}

# ============================================================
# CLEANUP
# ============================================================

function Show-Cleanup {

    Clear-Content

    New-Title `
        "Limpieza" `
        "Libera espacio eliminando archivos temporales y caches."

    New-ActionButton `
        "Temporales de usuario" `
        35 `
        135 `
        {

            $result = [System.Windows.Forms.MessageBox]::Show(
                "Quieres limpiar los archivos temporales de usuario?",
                "WinTuner - Limpieza",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )

            if ($result -ne "Yes") {
                return
            }

            try {

                $tempPath = $env:TEMP

                Get-ChildItem `
                    -Path $tempPath `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Remove-Item `
                        -Recurse `
                        -Force `
                        -ErrorAction SilentlyContinue

                Show-Info "Archivos temporales de usuario limpiados."

            }
            catch {

                Show-Error "No se pudieron limpiar todos los temporales."
            }
        }

    New-ActionButton `
        "Temporales de Windows" `
        280 `
        135 `
        {

            $result = [System.Windows.Forms.MessageBox]::Show(
                "Quieres limpiar los archivos temporales de Windows?",
                "WinTuner - Limpieza",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )

            if ($result -ne "Yes") {
                return
            }

            try {

                $windowsTemp = "C:\Windows\Temp"

                Get-ChildItem `
                    -Path $windowsTemp `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Remove-Item `
                        -Recurse `
                        -Force `
                        -ErrorAction SilentlyContinue

                Show-Info "Temporales de Windows limpiados."

            }
            catch {

                Show-Error "No se pudieron limpiar todos los temporales."
            }
        }

    New-ActionButton `
        "Papelera de reciclaje" `
        525 `
        135 `
        {

            $result = [System.Windows.Forms.MessageBox]::Show(
                "Esto eliminara definitivamente los archivos de la Papelera.`n`nContinuar?",
                "WinTuner - Papelera",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )

            if ($result -ne "Yes") {
                return
            }

            try {

                Clear-RecycleBin `
                    -Force `
                    -ErrorAction SilentlyContinue

                Show-Info "Papelera de reciclaje vaciada."

            }
            catch {

                Show-Error "No se pudo vaciar la Papelera."
            }
        }

    New-ActionButton `
        "Cache de miniaturas" `
        770 `
        135 `
        {

            $result = [System.Windows.Forms.MessageBox]::Show(
                "Quieres limpiar la cache de miniaturas?",
                "WinTuner - Limpieza",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )

            if ($result -ne "Yes") {
                return
            }

            try {

                $thumbnailPath =
                    Join-Path `
                        $env:LOCALAPPDATA `
                        "Microsoft\Windows\Explorer"

                Get-ChildItem `
                    -Path $thumbnailPath `
                    -Filter "thumbcache_*.db" `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Remove-Item `
                        -Force `
                        -ErrorAction SilentlyContinue

                Show-Info "Cache de miniaturas limpiada."

            }
            catch {

                Show-Error "No se pudo limpiar la cache de miniaturas."
            }
        }

    New-ActionButton `
        "DirectX Shader Cache" `
        35 `
        205 `
        {

            $result = [System.Windows.Forms.MessageBox]::Show(
                "Quieres limpiar la cache de DirectX Shader?",
                "WinTuner - Limpieza",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )

            if ($result -ne "Yes") {
                return
            }

            try {

                $shaderCache =
                    Join-Path `
                        $env:LOCALAPPDATA `
                        "D3DSCache"

                Get-ChildItem `
                    -Path $shaderCache `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Remove-Item `
                        -Recurse `
                        -Force `
                        -ErrorAction SilentlyContinue

                Show-Info "DirectX Shader Cache limpiada."

            }
            catch {

                Show-Error "No se pudo limpiar DirectX Shader Cache."
            }
        }

    New-ActionButton `
        "Cache de Windows Update" `
        280 `
        205 `
        {

            $result = [System.Windows.Forms.MessageBox]::Show(
                "Quieres limpiar la cache de Windows Update?",
                "WinTuner - Limpieza",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )

            if ($result -ne "Yes") {
                return
            }

            try {

                Stop-Service `
                    wuauserv `
                    -Force `
                    -ErrorAction SilentlyContinue

                $updatePath =
                    "C:\Windows\SoftwareDistribution\Download"

                Get-ChildItem `
                    -Path $updatePath `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Remove-Item `
                        -Recurse `
                        -Force `
                        -ErrorAction SilentlyContinue

                Start-Service `
                    wuauserv `
                    -ErrorAction SilentlyContinue

                Show-Info "Cache de Windows Update limpiada."

            }
            catch {

                Start-Service `
                    wuauserv `
                    -ErrorAction SilentlyContinue

                Show-Error "No se pudo completar la limpieza de Windows Update."
            }
        }

    New-ActionButton `
        "LIMPIAR TODO" `
        525 `
        205 `
        {

            $result = [System.Windows.Forms.MessageBox]::Show(
                "Se limpiaran temporales, caches y Windows Update.`n`nContinuar?",
                "WinTuner - Limpieza completa",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )

            if ($result -ne "Yes") {
                return
            }

            try {

                Get-ChildItem `
                    -Path $env:TEMP `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Remove-Item `
                        -Recurse `
                        -Force `
                        -ErrorAction SilentlyContinue

                Get-ChildItem `
                    -Path "C:\Windows\Temp" `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Remove-Item `
                        -Recurse `
                        -Force `
                        -ErrorAction SilentlyContinue

                $thumbnailPath =
                    Join-Path `
                        $env:LOCALAPPDATA `
                        "Microsoft\Windows\Explorer"

                Get-ChildItem `
                    -Path $thumbnailPath `
                    -Filter "thumbcache_*.db" `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Remove-Item `
                        -Force `
                        -ErrorAction SilentlyContinue

                $shaderCache =
                    Join-Path `
                        $env:LOCALAPPDATA `
                        "D3DSCache"

                Get-ChildItem `
                    -Path $shaderCache `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Remove-Item `
                        -Recurse `
                        -Force `
                        -ErrorAction SilentlyContinue

                Stop-Service `
                    wuauserv `
                    -Force `
                    -ErrorAction SilentlyContinue

                $updatePath =
                    "C:\Windows\SoftwareDistribution\Download"

                Get-ChildItem `
                    -Path $updatePath `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Remove-Item `
                        -Recurse `
                        -Force `
                        -ErrorAction SilentlyContinue

                Start-Service `
                    wuauserv `
                    -ErrorAction SilentlyContinue

                $recycle =
                    [System.Windows.Forms.MessageBox]::Show(
                        "Quieres vaciar tambien la Papelera de reciclaje?",
                        "WinTuner",
                        [System.Windows.Forms.MessageBoxButtons]::YesNo,
                        [System.Windows.Forms.MessageBoxIcon]::Question
                    )

                if ($recycle -eq "Yes") {

                    Clear-RecycleBin `
                        -Force `
                        -ErrorAction SilentlyContinue
                }

                Show-Info `
                    "Limpieza completa finalizada."

            }
            catch {

                Start-Service `
                    wuauserv `
                    -ErrorAction SilentlyContinue

                Show-Error `
                    "La limpieza termino, pero algunos archivos no pudieron eliminarse."
            }
        }

    $infoCard = New-Card 35 280 840 150

    $infoTitle = New-Object System.Windows.Forms.Label
    $infoTitle.Text = "Limpieza segura"
    $infoTitle.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        14,
        [System.Drawing.FontStyle]::Bold
    )
    $infoTitle.ForeColor = $text
    $infoTitle.AutoSize = $true
    $infoTitle.Location = [System.Drawing.Point]::new(20,15)

    $infoCard.Controls.Add($infoTitle)

    $infoText = New-Object System.Windows.Forms.Label

    $infoText.Text = @"
WinTuner elimina archivos temporales y caches que Windows puede volver a generar.

No se modifican documentos personales, fotos, videos, programas ni archivos importantes.

La Papelera de reciclaje siempre requiere confirmacion.
"@

    $infoText.Font = [System.Drawing.Font]::new("Segoe UI",9)
    $infoText.ForeColor = $muted
    $infoText.AutoSize = $true
    $infoText.Location = [System.Drawing.Point]::new(22,50)

    $infoCard.Controls.Add($infoText)
}

# ============================================================
# DEMO
# ============================================================

function Show-Demo {

    Clear-Content

    New-Title `
        "Modo DEMO" `
        "Simula una optimizacion sin modificar tu sistema."

    $progress = New-Object System.Windows.Forms.ProgressBar

    $progress.Location =
        [System.Drawing.Point]::new(35,135)

    $progress.Size =
        [System.Drawing.Size]::new(840,30)

    $progress.Minimum = 0
    $progress.Maximum = 100
    $progress.Value = 0

    $content.Controls.Add($progress)

    $status = New-Object System.Windows.Forms.Label

    $status.Text = "Preparando..."
    $status.Font = [System.Drawing.Font]::new("Segoe UI",11)
    $status.ForeColor = $text
    $status.AutoSize = $true
    $status.Location =
        [System.Drawing.Point]::new(35,185)

    $content.Controls.Add($status)

    $steps = @(
        "Analizando sistema...",
        "Comprobando memoria...",
        "Analizando disco...",
        "Comprobando red...",
        "Comprobando programas de inicio...",
        "Analisis completado."
    )

    $progress.Value = 0

    foreach ($step in $steps) {

        $status.Text = $step
        $status.Refresh()

        Start-Sleep -Milliseconds 500

        if ($progress.Value -lt 90) {
            $progress.Value += 18
        }
    }

    $progress.Value = 100

    $result = New-Object System.Windows.Forms.Label

        $result.Text =
            "[OK] DEMO completada. No se ha modificado nada."

    $result.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        11,
        [System.Drawing.FontStyle]::Bold
    )

    $result.ForeColor = $success
    $result.AutoSize = $true
    $result.Location =
        [System.Drawing.Point]::new(35,235)

    $content.Controls.Add($result)
}

# ============================================================
# PERFORMANCE
# ============================================================

function Show-Performance {

    Clear-Content

    New-Title `
        "Rendimiento" `
        "Herramientas para mejorar el rendimiento de Windows."

    New-ActionButton `
        "Modo DEMO" `
        35 `
        135 `
        {
            Show-Demo
        }

    New-ActionButton `
        "Alto rendimiento" `
        280 `
        135 `
        {
            Show-Info `
                "Funcion preparada para una futura version."
        }

    New-ActionButton `
        "Game Mode" `
        525 `
        135 `
        {
            Show-Info `
                "Game Mode estara disponible proximamente."
        }

    New-ActionButton `
        "Efectos visuales" `
        770 `
        135 `
        {
            Show-Info `
                "Configuracion de efectos visuales en desarrollo."
        }

    New-ActionButton `
        "Programas de inicio" `
        35 `
        205 `
        {
            Show-Startup
        }
}

# ============================================================
# STARTUP PROGRAMS
# ============================================================

function Show-Startup {

    Clear-Content

    New-Title `
        "Programas de inicio" `
        "Consulta las aplicaciones configuradas para iniciarse con Windows."

    $list = New-Object System.Windows.Forms.ListView

    $list.Location =
        [System.Drawing.Point]::new(35,130)

    $list.Size =
        [System.Drawing.Size]::new(840,450)

    $list.View = "Details"
    $list.FullRowSelect = $true
    $list.GridLines = $true
    $list.BackColor = $panel
    $list.ForeColor = $text

    [void]$list.Columns.Add(
        "Nombre",
        200
    )

    [void]$list.Columns.Add(
        "Comando",
        450
    )

    [void]$list.Columns.Add(
        "Ubicacion",
        150
    )

    try {

        $startupItems =
            Get-CimInstance Win32_StartupCommand `
                -ErrorAction Stop

        foreach ($item in $startupItems) {

            $row = [System.Windows.Forms.ListViewItem]::new(
                $item.Name
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

        Show-Error `
            "No se pudieron obtener los programas de inicio."
    }

    $content.Controls.Add($list)
}

# ============================================================
# VIRUS SCAN
# ============================================================

function Show-VirusScan {

    Clear-Content

    New-Title `
        "Scan de virus" `
        "Analiza tu equipo usando Microsoft Defender."

    $card = New-Card 35 120 840 190

    $title = New-Object System.Windows.Forms.Label

    $title.Text = "Microsoft Defender"
    $title.Font = [System.Drawing.Font]::new(
        "Segoe UI",
        16,
        [System.Drawing.FontStyle]::Bold
    )

    $title.ForeColor = $text
    $title.AutoSize = $true
    $title.Location =
        [System.Drawing.Point]::new(20,20)

    $card.Controls.Add($title)

    $description = New-Object System.Windows.Forms.Label

    $description.Text =
        "Ejecuta un analisis rapido o un analisis completo del sistema."

    $description.Font =
        [System.Drawing.Font]::new("Segoe UI",9)

    $description.ForeColor = $muted
    $description.AutoSize = $true
    $description.Location =
        [System.Drawing.Point]::new(22,58)

    $card.Controls.Add($description)

    $status = New-Object System.Windows.Forms.Label

    $status.Text = "Estado: listo"
    $status.Font =
        [System.Drawing.Font]::new("Segoe UI",10)

    $status.ForeColor = $success
    $status.AutoSize = $true
    $status.Location =
        [System.Drawing.Point]::new(22,95)

    $card.Controls.Add($status)

    $quick = New-Object System.Windows.Forms.Button

    $quick.Text = "Analisis rapido"
    $quick.Location =
        [System.Drawing.Point]::new(22,130)

    $quick.Size =
        [System.Drawing.Size]::new(180,40)

    $quick.FlatStyle = "Flat"
    $quick.FlatAppearance.BorderSize = 0
    $quick.BackColor = $panel2
    $quick.ForeColor = $text

    $card.Controls.Add($quick)

    $full = New-Object System.Windows.Forms.Button

    $full.Text = "Analisis completo"
    $full.Location =
        [System.Drawing.Point]::new(220,130)

    $full.Size =
        [System.Drawing.Size]::new(180,40)

    $full.FlatStyle = "Flat"
    $full.FlatAppearance.BorderSize = 0
    $full.BackColor = $panel2
    $full.ForeColor = $text

    $card.Controls.Add($full)

    $quick.Add_Click({

        try {

            if (-not (Get-Command Start-MpScan -ErrorAction SilentlyContinue)) {

                Show-Error `
                    "Microsoft Defender no esta disponible en este sistema."

                return
            }

            $status.Text = "Estado: ejecutando analisis rapido..."
            $status.ForeColor = $warning
            $status.Refresh()

            Start-MpScan -ScanType QuickScan

            $status.Text = "Estado: analisis rapido completado."
            $status.ForeColor = $success

            Show-Info `
                "El analisis rapido ha terminado."

        }
        catch {

            $status.Text = "Estado: error."
            $status.ForeColor = $danger

            Show-Error `
                "No se pudo ejecutar el analisis rapido.`n`n$($_.Exception.Message)"
        }
    })

    $full.Add_Click({

        try {

            if (-not (Get-Command Start-MpScan -ErrorAction SilentlyContinue)) {

                Show-Error `
                    "Microsoft Defender no esta disponible en este sistema."

                return
            }

            $confirm = [System.Windows.Forms.MessageBox]::Show(
                "El analisis completo puede tardar bastante tiempo.`n`nQuieres continuar?",
                "WinTuner - Microsoft Defender",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )

            if ($confirm -ne "Yes") {
                return
            }

            $status.Text =
                "Estado: ejecutando analisis completo..."

            $status.ForeColor = $warning
            $status.Refresh()

            Start-MpScan -ScanType FullScan

            $status.Text =
                "Estado: analisis completo terminado."

            $status.ForeColor = $success

            Show-Info `
                "El analisis completo ha terminado."

        }
        catch {

            $status.Text = "Estado: error."
            $status.ForeColor = $danger

            Show-Error `
                "No se pudo ejecutar el analisis completo.`n`n$($_.Exception.Message)"
        }
    })
}

# ============================================================
# COMING SOON
# ============================================================

function Show-ComingSoon {

    param(
        [string]$Section
    )

    Clear-Content

    New-Title `
        $Section `
        "Esta seccion estara disponible proximamente."

    $card = New-Card 35 135 840 160

    $label = New-Object System.Windows.Forms.Label

    $label.Text = "[EN CONSTRUCCION] $Section`n`nFuncion en desarrollo."

    $label.Font =
        [System.Drawing.Font]::new(
            "Segoe UI",
            14,
            [System.Drawing.FontStyle]::Bold
        )

    $label.ForeColor = $text
    $label.AutoSize = $true
    $label.Location =
        [System.Drawing.Point]::new(25,25)

    $card.Controls.Add($label)
}

# ============================================================
# NAVIGATION
# ============================================================

New-NavButton `
    "Inicio" `
    110 `
    {
        Show-Home
    }

New-NavButton `
    "Rendimiento" `
    160 `
    {
        Show-Performance
    }

New-NavButton `
    "Limpieza" `
    210 `
    {
        Show-Cleanup
    }

New-NavButton `
    "Red" `
    260 `
    {
        Show-ComingSoon "Red"
    }

New-NavButton `
    "Privacidad" `
    310 `
    {
        Show-ComingSoon "Privacidad"
    }

New-NavButton `
    "Reparacion" `
    360 `
    {
        Show-ComingSoon "Reparacion"
    }

New-NavButton `
    "Modo DEMO" `
    410 `
    {
        Show-Demo
    }

# ------------------------------------------------------------
# SIDEBAR FOOTER
# ------------------------------------------------------------

$footer = New-Object System.Windows.Forms.Label

$footer.Text = "WinTuner v1.0"
$footer.Font = [System.Drawing.Font]::new(
    "Segoe UI",
    9
)

$footer.ForeColor = $muted
$footer.AutoSize = $true
$footer.Location =
    [System.Drawing.Point]::new(25,625)

$sidebar.Controls.Add($footer)

# ============================================================
# SIDEBAR TOGGLE
# ============================================================

$sidebarExpanded = $true

$toggleButton = New-Object System.Windows.Forms.Button

$toggleButton.Text = "="

$toggleButton.Location =
    [System.Drawing.Point]::new(
        $sidebarWidth + 10,
        12
    )

$toggleButton.Size =
    [System.Drawing.Size]::new(48,40)

$toggleButton.FlatStyle = "Flat"
$toggleButton.FlatAppearance.BorderSize = 0
$toggleButton.BackColor = $panel2
$toggleButton.ForeColor = $text

$toggleButton.Font =
    [System.Drawing.Font]::new(
        "Segoe UI",
        14,
        [System.Drawing.FontStyle]::Bold
    )

$toggleButton.Cursor =
    [System.Windows.Forms.Cursors]::Hand

$form.Controls.Add($toggleButton)

$toggleButton.BringToFront()

# ============================================================
# SIDEBAR ANIMATION
# ============================================================

$sidebarTimer = New-Object System.Windows.Forms.Timer

$sidebarTimer.Interval = 10

$sidebarTimer.Add_Tick({

    if ($sidebarExpanded) {

        if ($sidebar.Width -lt 225) {

            $sidebar.Width += 15
            $content.Left = $sidebar.Width
            $content.Width =
                $form.ClientSize.Width - $sidebar.Width

            $toggleButton.Left =
                $sidebar.Width + 10

        }
        else {

            $sidebarTimer.Stop()
        }
    }
    else {

        if ($sidebar.Width -gt 70) {

            $sidebar.Width -= 15
            $content.Left = $sidebar.Width
            $content.Width =
                $form.ClientSize.Width - $sidebar.Width

            $toggleButton.Left =
                $sidebar.Width + 10

        }
        else {

            $sidebarTimer.Stop()
        }
    }
})

$toggleButton.Add_Click({

    $sidebarExpanded = -not $sidebarExpanded

    $sidebarTimer.Start()
})

# ============================================================
# FORM RESIZE
# ============================================================

$form.Add_Resize({

    if ($sidebarExpanded) {

        $sidebar.Width = 225
        $content.Left = 225
        $content.Width =
            $form.ClientSize.Width - 225

        $toggleButton.Left = 235
    }
    else {

        $sidebar.Width = 70
        $content.Left = 70
        $content.Width =
            $form.ClientSize.Width - 70

        $toggleButton.Left = 80
    }
})

# ============================================================
# SHOW MAIN WINDOW
# ============================================================

Show-Home

try {

    [void]$form.ShowDialog()
}
finally {

    # FIX: cleanup garantizado pase lo que pase (cierre normal, excepcion, etc.)
    if ($mutex) {

        try {
            if ($gotMutex) {
                $mutex.ReleaseMutex()
            }
        }
        catch {
        }

        $mutex.Dispose()
    }
}