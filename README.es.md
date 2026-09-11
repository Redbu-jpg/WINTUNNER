# WinTuner

**WinTuner** es una utilidad para Windows diseñada para ofrecer una interfaz gráfica sencilla destinada al mantenimiento, optimización y diagnóstico del sistema.

> 🚧 **Estado del proyecto:** Fase inicial de desarrollo

## ✨ Características

* 🏠 Panel de control
* ⚡ Herramientas de rendimiento
* 🧹 Herramientas de limpieza
* 🌐 Herramientas de red
* 🔒 Herramientas de privacidad
* 🛠️ Herramientas de reparación
* 🧪 Modo DEMO seguro
* 🚀 Visualizador de programas de inicio
* 🦠 Análisis con Microsoft Defender
* 📊 Información del sistema
* 🎨 Interfaz gráfica con Windows Forms

## 🖥️ Requisitos

* Windows 10 o Windows 11
* PowerShell
* Es posible que se requieran privilegios de administrador para algunas herramientas

## 🚀 Ejecución de WinTuner

### PowerShell

Ejecuta:

```powershell
.\WINTUNNER.PS1
```

### Lanzador BAT

También puedes iniciar WinTuner usando:

```text
WINTUNNER.BAT
```

## 🔨 Generación del ejecutable (EXE)

WinTuner se puede compilar utilizando **PS2EXE**.

Instala PS2EXE:

```powershell
Install-Module ps2exe -Scope CurrentUser
```

Luego compila:

```powershell
Invoke-PS2EXE `
    -inputFile ".\WINTUNNER.PS1" `
    -outputFile ".\WinTuner.exe" `
    -STA
```

El ejecutable resultante será:

```text
WinTuner.exe
```

## 📁 Estructura del proyecto

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

## 🧪 Modo DEMO

WinTuner incluye un modo DEMO diseñado para simular el análisis del sistema sin realizar cambios en Windows.

Esto resulta útil para probar la interfaz de forma segura. ## 🗺️ Hoja de ruta

* [x] Interfaz gráfica
* [x] Panel de control
* [x] Modo de demostración (DEMO)
* [x] Visualizador de programas de inicio
* [x] Integración con Microsoft Defender
* [ ] Herramientas de optimización del rendimiento
* [ ] Herramientas de limpieza
* [ ] Optimización de red
* [ ] Herramientas de privacidad
* [ ] Herramientas de reparación de Windows
* [ ] Lanzamiento del ejecutable (EXE) final
* [ ] Gestión de errores mejorada
* [ ] Panel de configuración

## ⚠️ Descargo de responsabilidad

WinTuner es un proyecto independiente y se ofrece para uso educativo y personal.

Algunas funciones pueden modificar la configuración del sistema Windows al ejecutarse. Asegúrate siempre de entender qué hace una herramienta de optimización del sistema antes de aplicar cambios.

Úsalo bajo tu propia responsabilidad.

## 📜 Licencia

Este proyecto está bajo la Licencia MIT.