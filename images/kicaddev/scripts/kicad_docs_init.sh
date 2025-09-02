#!/bin/bash

# KiCad Documentation Structure Generator
# Creates a complete Sphinx documentation structure for KiCad projects

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "\n${BLUE}🔧 KiCad Documentation Structure Generator${NC}"
    echo -e "${BLUE}==============================================${NC}"
}

# Usage function
usage() {
    echo "Usage: $0 [PROJECT_DIR]"
    echo ""
    echo "Creates a complete Sphinx documentation structure for KiCad projects."
    echo ""
    echo "Arguments:"
    echo "  PROJECT_DIR    Path to the KiCad project directory (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  $0                           # Initialize docs in current directory"
    echo "  $0 /path/to/project          # Initialize docs in specific project"
    echo "  $0 4CH-Opto-ISO             # Initialize docs in project subdirectory"
    exit 1
}

# Check if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Determine project directory
PROJECT_DIR="${1:-.}"
PROJECT_DIR=$(realpath "$PROJECT_DIR")

print_header

# Validate project directory
if [[ ! -d "$PROJECT_DIR" ]]; then
    print_error "Project directory does not exist: $PROJECT_DIR"
    exit 1
fi

print_info "Project directory: $PROJECT_DIR"

# Find KiCad project file
KICAD_PROJECT=""
for proj_file in "$PROJECT_DIR"/*.kicad_pro; do
    if [[ -f "$proj_file" ]]; then
        KICAD_PROJECT=$(basename "$proj_file" .kicad_pro)
        break
    fi
done

if [[ -z "$KICAD_PROJECT" ]]; then
    print_error "No KiCad project file (*.kicad_pro) found in $PROJECT_DIR"
    exit 1
fi

print_info "Found KiCad project: $KICAD_PROJECT"

# Create documentation directory structure
DOCS_DIR="$PROJECT_DIR/docs"
SOURCE_DIR="$DOCS_DIR/source"

print_info "Creating documentation directory structure..."

# Create directories
mkdir -p "$SOURCE_DIR"
mkdir -p "$SOURCE_DIR/_static"
mkdir -p "$SOURCE_DIR/_templates"
mkdir -p "$DOCS_DIR/build"

print_success "Created directory structure"

# Create conf.py
print_info "Generating Sphinx configuration..."
cat > "$SOURCE_DIR/conf.py" << 'EOF'
# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import os
import sys

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'PROJECT_NAME_PLACEHOLDER'
copyright = '2024, KiCad Project Team'
author = 'KiCad Project Team'
release = '1.0.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'myst_parser',
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    'sphinx.ext.intersphinx',
]

templates_path = ['_templates']
exclude_patterns = []

# Language settings
language = 'de'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
html_title = f'{project} Dokumentation'

# -- Options for LaTeX output ------------------------------------------------

latex_engine = 'pdflatex'
latex_elements = {
    'papersize': 'a4paper',
    'pointsize': '10pt',
    'fncychap': '\\usepackage[Bjornstrup]{fncychap}',
    'fontenc': '\\usepackage[T1]{fontenc}',
    'inputenc': '\\usepackage[utf8]{inputenc}',
    'babel': '\\usepackage[german]{babel}',
    'preamble': r'''
\usepackage{textcomp}
\DeclareUnicodeCharacter{03BC}{\ensuremath{\mu}}
\DeclareUnicodeCharacter{03A9}{\ensuremath{\Omega}}
\DeclareUnicodeCharacter{03B1}{\ensuremath{\alpha}}
\DeclareUnicodeCharacter{03B2}{\ensuremath{\beta}}
\DeclareUnicodeCharacter{03B3}{\ensuremath{\gamma}}
\DeclareUnicodeCharacter{03B4}{\ensuremath{\delta}}
\DeclareUnicodeCharacter{03B5}{\ensuremath{\varepsilon}}
\DeclareUnicodeCharacter{03B8}{\ensuremath{\theta}}
\DeclareUnicodeCharacter{03BB}{\ensuremath{\lambda}}
\DeclareUnicodeCharacter{03C0}{\ensuremath{\pi}}
\DeclareUnicodeCharacter{03C1}{\ensuremath{\rho}}
\DeclareUnicodeCharacter{03C3}{\ensuremath{\sigma}}
\DeclareUnicodeCharacter{03C4}{\ensuremath{\tau}}
\DeclareUnicodeCharacter{03C6}{\ensuremath{\varphi}}
\DeclareUnicodeCharacter{03C9}{\ensuremath{\omega}}
\DeclareUnicodeCharacter{00B0}{\ensuremath{{}^{\circ}}}
\DeclareUnicodeCharacter{00B5}{\ensuremath{\mu}}
\DeclareUnicodeCharacter{2126}{\ensuremath{\Omega}}
''',
}

latex_documents = [
    ('index', 'PROJECT_NAME_PLACEHOLDER.tex', f'{project} PCB-Projekt',
     'KiCad Project Team', 'manual'),
]

# -- MyST Parser configuration -----------------------------------------------

myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "html_image",
    "html_admonition",
    "replacements",
    "smartquotes",
    "tasklist",
]

# Source file suffixes
source_suffix = {
    '.rst': None,
    '.md': 'myst_parser',
}
EOF

# Replace placeholder with actual project name
sed -i "s/PROJECT_NAME_PLACEHOLDER/$KICAD_PROJECT/g" "$SOURCE_DIR/conf.py"

print_success "Created Sphinx configuration"

# Create main index.rst
print_info "Generating main documentation index..."
cat > "$SOURCE_DIR/index.rst" << EOF
$KICAD_PROJECT PCB-Projekt
$(printf '=%.0s' $(seq 1 ${#KICAD_PROJECT}))================

Willkommen zur technischen Dokumentation des **$KICAD_PROJECT** PCB-Projekts.

.. toctree::
   :maxdepth: 2
   :caption: Inhalt:
   :numbered:

   introduction
   technical-specs  
   manufacturing
   usage

Übersicht
=========

Dieses Dokument beschreibt das $KICAD_PROJECT PCB-Design, einschließlich:

* **Schaltplan und Layout** - Technische Details des PCB-Designs
* **Spezifikationen** - Elektrische und mechanische Eigenschaften  
* **Fertigung** - Produktionsdateien und Herstellungsanweisungen
* **Verwendung** - Installation und Betriebsanleitung

Projektdateien
==============

Die wichtigsten Projektdateien:

* \`$KICAD_PROJECT.kicad_pro\` - KiCad Projektdatei
* \`$KICAD_PROJECT.kicad_sch\` - Schaltplan
* \`$KICAD_PROJECT.kicad_pcb\` - PCB Layout
* \`production/\` - Fertigungsdateien (Gerber, Drill, BOM)
* \`docs/\` - Diese Dokumentation

Quick Start
===========

.. note::
   
   Dieses Projekt wurde mit KiCad 9.0+ entwickelt. Stellen Sie sicher, dass Sie eine kompatible Version verwenden.

1. **Projekt öffnen**: Öffnen Sie \`$KICAD_PROJECT.kicad_pro\` in KiCad
2. **Schaltplan prüfen**: Überprüfen Sie den Schaltplan auf Vollständigkeit
3. **PCB Layout**: Kontrollieren Sie das PCB Layout und die Routing-Regeln
4. **Produktion**: Generieren Sie die Fertigungsdateien bei Bedarf

Indizes und Tabellen
====================

* :ref:\`genindex\`
* :ref:\`modindex\`
* :ref:\`search\`
EOF

print_success "Created main documentation index"

# Create introduction.rst
print_info "Generating introduction documentation..."
cat > "$SOURCE_DIR/introduction.rst" << EOF
Einführung
==========

Das $KICAD_PROJECT ist ein PCB-Design, das mit KiCad entwickelt wurde.

Projektüberblick
---------------

.. admonition:: Projektstatus
   :class: note
   
   Dieses Projekt befindet sich in aktiver Entwicklung.

Das $KICAD_PROJECT PCB wurde für folgende Anwendungsbereiche entwickelt:

* Elektronische Schaltungen
* Prototyping und Entwicklung
* Produktionsreife Designs

Anwendungsgebiete
----------------

Typische Einsatzbereiche:

* **Entwicklung**: Schnelle Prototypenerstellung
* **Produktion**: Serienfertigung möglich
* **Forschung**: Experimentelle Schaltungen

Entwicklungsumgebung
-------------------

Verwendete Tools:

* **KiCad 9.0+**: PCB Design Suite
* **Python**: Automatisierte Skripts
* **Docker**: Containerisierte Build-Umgebung

Dateienstruktur
===============

.. code-block:: text

   $KICAD_PROJECT/
   ├── $KICAD_PROJECT.kicad_pro     # Hauptprojektdatei
   ├── $KICAD_PROJECT.kicad_sch     # Schaltplan
   ├── $KICAD_PROJECT.kicad_pcb     # PCB Layout
   ├── production/                   # Fertigungsdateien
   │   ├── gerbers/                 # Gerber-Dateien
   │   ├── drill/                   # Bohrdateien
   │   ├── bom/                     # Stückliste
   │   └── pdf/                     # PDF-Dokumentation
   └── docs/                        # Diese Dokumentation

Systemanforderungen
==================

**Software:**

* KiCad 9.0 oder höher
* Python 3.8+ (für Skripts)
* Git (für Versionskontrolle)

**Hardware:**

* Mindestens 4GB RAM
* 1GB freier Speicherplatz
* Unterstützte Betriebssysteme: Windows, macOS, Linux

Lizenz
======

Dieses Projekt steht unter einer Open-Source-Lizenz. Details finden Sie in der LICENSE-Datei.
EOF

print_success "Created introduction documentation"

# Create technical-specs.rst
print_info "Generating technical specifications..."
cat > "$SOURCE_DIR/technical-specs.rst" << EOF
Technische Spezifikationen
=========================

Dieses Kapitel beschreibt die technischen Eigenschaften des $KICAD_PROJECT PCB.

Elektrische Eigenschaften
=========================

Versorgungsspannung
~~~~~~~~~~~~~~~~~~

.. list-table:: Spannungsversorgung
   :widths: 30 20 50
   :header-rows: 1

   * - Parameter
     - Wert
     - Bemerkungen
   * - Eingangsspannung
     - 3.3V - 5V
     - DC-Versorgung
   * - Stromaufnahme (typ.)
     - 100mA
     - Bei Nennlast
   * - Stromaufnahme (max.)
     - 500mA
     - Maximale Belastung

PCB-Abmessungen
~~~~~~~~~~~~~~

.. list-table:: Mechanische Abmessungen
   :widths: 30 20 50
   :header-rows: 1

   * - Parameter
     - Wert
     - Toleranz
   * - Länge
     - 50mm
     - ±0.1mm
   * - Breite
     - 30mm
     - ±0.1mm
   * - Dicke
     - 1.6mm
     - Standard PCB

Anschlüsse
~~~~~~~~~

Das PCB verfügt über folgende Anschlussmöglichkeiten:

* **J1**: Hauptstromversorgung (2-polig)
* **J2**: Signaleingang (4-polig)
* **J3**: Signalausgang (4-polig)

Umgebungsbedingungen
-------------------

Betriebstemperatur
~~~~~~~~~~~~~~~~~

* **Minimum**: -10°C
* **Maximum**: +60°C
* **Optimal**: +20°C bis +35°C

Luftfeuchtigkeit
~~~~~~~~~~~~~~~

* **Betrieb**: 10% - 90% rel. Luftfeuchtigkeit (nicht kondensierend)
* **Lagerung**: 5% - 95% rel. Luftfeuchtigkeit

Mechanische Eigenschaften
------------------------

* **Leiterplattenmaterial**: FR4
* **Kupferdicke**: 35μm (1oz)
* **Lötresist**: Grün, beidseitig
* **Bestückungsdruck**: Weiß, einseitig

Zertifizierungen und Standards
-----------------------------

* **RoHS-konform**: Ja
* **Bleifreie Fertigung**: Ja
* **IPC-Standards**: IPC-2221, IPC-2222

Prüfspezifikationen
==================

Elektrische Tests
~~~~~~~~~~~~~~~~

.. list-table:: Elektrische Prüfungen
   :widths: 40 30 30
   :header-rows: 1

   * - Test
     - Sollwert
     - Toleranz
   * - Isolationswiderstand
     - >100MΩ
     - Bei 500V DC
   * - Durchgangsprüfung
     - <1Ω
     - Alle Verbindungen

Mechanische Tests
~~~~~~~~~~~~~~~~

* **Vibrationsprüfung**: Nach IEC 60068-2-6
* **Schockprüfung**: Nach IEC 60068-2-27
* **Temperaturwechsel**: Nach IEC 60068-2-14
EOF

print_success "Created technical specifications"

# Create manufacturing.rst
print_info "Generating manufacturing documentation..."
cat > "$SOURCE_DIR/manufacturing.rst" << EOF
Fertigung und Produktion
=======================

Dieses Kapitel beschreibt die Fertigung und Produktion des $KICAD_PROJECT PCB.

Fertigungsunterlagen
===================

Alle notwendigen Fertigungsunterlagen sind im \`production/\` Verzeichnis verfügbar.

Generierte Dateien
-----------------

Gerber-Dateien
~~~~~~~~~~~~~

Die Gerber-Dateien enthalten alle Layerinformationen:

.. code-block:: text

   production/gerbers/
   ├── $KICAD_PROJECT-F_Cu.gtl          # Oberseite Kupfer
   ├── $KICAD_PROJECT-B_Cu.gbl          # Unterseite Kupfer  
   ├── $KICAD_PROJECT-F_Mask.gts        # Oberseite Lötresist
   ├── $KICAD_PROJECT-B_Mask.gbs        # Unterseite Lötresist
   ├── $KICAD_PROJECT-F_Silkscreen.gto  # Oberseite Bestückungsdruck
   ├── $KICAD_PROJECT-B_Silkscreen.gbo  # Unterseite Bestückungsdruck
   ├── $KICAD_PROJECT-Edge_Cuts.gm1     # Platinenkontur
   └── $KICAD_PROJECT.drl               # Bohrdatei

.. note::
   
   Alle Gerber-Dateien entsprechen dem RS-274X Standard und sind mit gängigen CAM-Systemen kompatibel.

Bohrdateien
~~~~~~~~~~

* **Format**: Excellon
* **Einheiten**: Metrisch (mm)
* **Koordinaten**: Absolut

Dokumentation
~~~~~~~~~~~~

* **PDF-Schaltplan**: Vollständiger Schaltplan
* **PDF-Assembly**: Bestückungsplan
* **PDF-Fab**: Fertigungszeichnung

Bill of Materials (BOM)
~~~~~~~~~~~~~~~~~~~~~~

* **CSV-Format**: Maschinell lesbar
* **HTML-Format**: Interaktive BOM mit Bauteilpositionen
* **Herstellerinformationen**: Bestellnummern und Spezifikationen

Fertigungsparameter
------------------

PCB-Spezifikationen
~~~~~~~~~~~~~~~~~~

.. list-table:: PCB-Parameter
   :widths: 40 30 30
   :header-rows: 1

   * - Parameter
     - Wert
     - Bemerkung
   * - Lagenanzahl
     - 2
     - Standard Doppelseitig
   * - Platinenstärke
     - 1.6mm
     - Standard FR4
   * - Kupferdicke
     - 35μm
     - 1oz Standard
   * - Min. Leiterbahnbreite
     - 0.2mm
     - 8mil
   * - Min. Via-Durchmesser
     - 0.3mm
     - 0.6mm Außendurchmesser
   * - Min. Bohrung
     - 0.2mm
     - Mechanische Bohrung
   * - Oberflächenbehandlung
     - HASL
     - Bleifreie Option verfügbar

Lötparameter
~~~~~~~~~~~

.. list-table:: Löt-Spezifikationen
   :widths: 40 30 30
   :header-rows: 1

   * - Parameter
     - Wert
     - Bemerkung
   * - Reflow-Profil
     - SAC305
     - Bleifreies Lot
   * - Peak-Temperatur
     - 245°C
     - ±5°C
   * - Verweilzeit über 217°C
     - 45-90s
     - Kritisch für Lötqualität
   * - Aufheizrate
     - 1-3°C/s
     - Gleichmäßige Erwärmung
   * - Abkühlrate
     - <4°C/s
     - Vermeidung von Rissen

.. warning::
   
   Temperaturprofile müssen genau eingehalten werden, um Lötfehler zu vermeiden.

Qualitätskontrolle
-----------------

Automatisierte Prüfungen
~~~~~~~~~~~~~~~~~~~~~~~

* **AOI (Automated Optical Inspection)**: Visuelle Kontrolle
* **ICT (In-Circuit Test)**: Elektrische Funktionsprüfung
* **Boundary Scan**: JTAG-basierte Tests (falls verfügbar)

Funktionstests
~~~~~~~~~~~~~

* **Stromaufnahme-Test**: Überprüfung der Leistungsaufnahme
* **Funktionalitäts-Test**: Vollständige Funktionsprüfung
* **Umgebungstest**: Tests unter verschiedenen Bedingungen

Fertigungspartner
----------------

Empfohlene PCB-Hersteller:

* **JLCPCB**: Kostengünstige Prototypen
* **PCBWay**: Professionelle Kleinserien
* **Eurocircuits**: Europäische Fertigung
* **OSH Park**: Open-Source-Hardware-freundlich

.. tip::
   
   Für Prototypen sind 5-10 Stück ausreichend. Für Serien ab 100 Stück sollten Kostenvergleiche durchgeführt werden.

Kostenschätzung
--------------

.. list-table:: Kostenschätzung (ungefähre Werte)
   :widths: 30 25 25 20
   :header-rows: 1

   * - Stückzahl
     - PCB-Kosten
     - Bestückung
     - Gesamt
   * - 5 Stück
     - 2-5€
     - 10-20€
     - 12-25€
   * - 10 Stück
     - 1-3€
     - 8-15€
     - 9-18€
   * - 100 Stück
     - 0.5-1€
     - 5-10€
     - 5.5-11€
   * - 1000 Stück
     - 0.2-0.5€
     - 2-5€
     - 2.2-5.5€

.. note::
   
   Preise variieren je nach Hersteller, Spezifikationen und aktueller Marktlage.
EOF

print_success "Created manufacturing documentation"

# Create usage.rst
print_info "Generating usage documentation..."
cat > "$SOURCE_DIR/usage.rst" << EOF
Verwendung und Installation
===========================

Dieses Kapitel beschreibt die praktische Verwendung des $KICAD_PROJECT PCB.

Vorbereitung
-----------

Benötigte Komponenten
~~~~~~~~~~~~~~~~~~~~

Vor der Installation stellen Sie sicher, dass alle Komponenten verfügbar sind:

* $KICAD_PROJECT PCB (bestückt)
* Stromversorgung (3.3V-5V DC)
* Verbindungskabel
* Anschlussstecker

Werkzeuge
~~~~~~~~

* Lötkolben (falls Anpassungen nötig)
* Multimeter für Tests
* Oszilloskop (optional, für Signalanalyse)
* Antistatik-Schutz

Installation
-----------

Mechanische Montage
~~~~~~~~~~~~~~~~~~

1. **Montageort wählen**
   
   * Trockene, staubfreie Umgebung
   * Temperaturbereich: -10°C bis +60°C
   * Keine direkte Sonneneinstrahlung

2. **Befestigung**
   
   * Verwenden Sie die vorgesehenen Montagelöcher
   * M3 Schrauben empfohlen
   * Abstand zur Gehäusewand: mindestens 5mm

3. **Mechanische Sicherheit**
   
   * Keine scharfen Kanten berühren
   * Komponenten vor mechanischen Stößen schützen
   * Ausreichende Belüftung sicherstellen

Elektrische Anschlüsse
~~~~~~~~~~~~~~~~~~~~~

.. danger::
   
   Vor allen elektrischen Arbeiten die Stromversorgung trennen!

**Stromversorgung (J1):**

.. list-table:: Anschluss J1 - Stromversorgung
   :widths: 15 20 65
   :header-rows: 1

   * - Pin
     - Signal
     - Beschreibung
   * - 1
     - +VDD
     - Positive Versorgungsspannung (3.3V-5V)
   * - 2
     - GND
     - Masse/Ground

**Signaleingang (J2):**

.. list-table:: Anschluss J2 - Eingang
   :widths: 15 20 65
   :header-rows: 1

   * - Pin
     - Signal
     - Beschreibung
   * - 1
     - IN1
     - Signaleingang Kanal 1
   * - 2
     - IN2
     - Signaleingang Kanal 2
   * - 3
     - IN3
     - Signaleingang Kanal 3
   * - 4
     - GND
     - Signalmasse

**Signalausgang (J3):**

.. list-table:: Anschluss J3 - Ausgang
   :widths: 15 20 65
   :header-rows: 1

   * - Pin
     - Signal
     - Beschreibung
   * - 1
     - OUT1
     - Signalausgang Kanal 1
   * - 2
     - OUT2
     - Signalausgang Kanal 2
   * - 3
     - OUT3
     - Signalausgang Kanal 3
   * - 4
     - GND
     - Signalmasse

Grundkonfiguration
-----------------

Spannungsversorgung
~~~~~~~~~~~~~~~~~~

1. **Spannungsprüfung**
   
   Überprüfen Sie die Versorgungsspannung mit einem Multimeter:
   
   * Sollwert: 3.3V - 5.0V DC
   * Toleranz: ±5%
   * Welligkeit: <50mV

2. **Stromaufnahme-Test**
   
   * Leerlauf: <10mA
   * Betrieb: 50-100mA (typisch)
   * Maximum: <500mA

3. **Funktionstest**
   
   * LED-Anzeigen überprüfen
   * Signalausgabe messen
   * Temperatur überwachen

Signalverbindungen
~~~~~~~~~~~~~~~~~

1. **Eingangssignale**
   
   * Spannungspegel: 0V - VDD
   * Impedanz: >10kΩ
   * Frequenzbereich: DC - 100kHz

2. **Ausgangssignale**
   
   * Ausgangsspannung: 0V - VDD
   * Ausgangsstrom: max. 20mA pro Kanal
   * Lastimpedanz: >1kΩ empfohlen

Anwendungsbeispiele
------------------

Beispiel 1: Signalverstärkung
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: text

   Eingangssignal -> J2 (Pin 1) -> Verstärkung -> J3 (Pin 1) -> Ausgangssignal
   
   Verstärkungsfaktor: 2x
   Bandbreite: DC - 50kHz
   
Beispiel 2: Signalfilterung
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: text

   Verrauschtes Signal -> J2 -> Tiefpassfilter -> J3 -> Gefiltertes Signal
   
   Grenzfrequenz: 10kHz
   Dämpfung: -40dB/Dekade

Industrielle Steuerung
~~~~~~~~~~~~~~~~~~~~

Das $KICAD_PROJECT kann in industriellen Steuerungsanlagen eingesetzt werden:

.. code-block:: text

   SPS-Ausgang -> Optokoppler -> $KICAD_PROJECT -> Aktor
   
   Vorteile:
   * Galvanische Trennung
   * Störungsunterdrückung  
   * Signalaufbereitung

.. note::
   
   Bei industriellen Anwendungen sind zusätzliche Schutzmaßnahmen zu beachten.

Fehlerbehebung
=============

Häufige Probleme
~~~~~~~~~~~~~~~

**Problem: Keine Stromversorgung**

* Überprüfen Sie die Kabelverbindungen
* Messen Sie die Eingangsspannung
* Kontrollieren Sie die Sicherungen

**Problem: Kein Ausgangssignal**

* Eingangssignal vorhanden?
* LED-Status überprüfen
* Lastimpedanz kontrollieren

**Problem: Überhitzung**

* Umgebungstemperatur reduzieren
* Belüftung verbessern
* Laststrom verringern

Testverfahren
~~~~~~~~~~~~

**Grundfunktionstest:**

1. Spannungsversorgung anlegen
2. Eingangssignal (1kHz Sinus, 1V) anlegen
3. Ausgang mit Oszilloskop messen
4. Verstärkung und Phase prüfen

**Langzeittest:**

1. Kontinuierlicher Betrieb (24h)
2. Temperaturüberwachung
3. Signalqualität überwachen
4. Drift-Messung

Wartung
------

Regelmäßige Prüfungen
~~~~~~~~~~~~~~~~~~~

* **Monatlich**: Sichtprüfung auf Beschädigungen
* **Halbjährlich**: Elektrische Parameter prüfen
* **Jährlich**: Vollständige Funktionsprüfung

Reinigung
~~~~~~~~

* Druckluft für Staubentfernung
* Isopropanol für Kontaktreinigung
* Keine aggressiven Lösungsmittel verwenden

.. warning::
   
   Vor Reinigungsarbeiten immer die Stromversorgung trennen!
EOF

print_success "Created usage documentation"

# Create requirements.txt for documentation
print_info "Creating Python requirements for documentation..."
cat > "$DOCS_DIR/requirements.txt" << 'EOF'
# Sphinx documentation requirements
sphinx>=8.0.0
sphinx-rtd-theme>=2.0.0
myst-parser>=4.0.0
sphinxcontrib-mermaid>=0.9.0
EOF

print_success "Created Python requirements"

# Create .gitignore for docs
print_info "Creating .gitignore for documentation..."
cat > "$DOCS_DIR/.gitignore" << 'EOF'
# Sphinx build outputs
build/
_build/
.doctrees/

# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF

print_success "Created .gitignore"

# Create Makefile for convenience
print_info "Creating Makefile for documentation..."
cat > "$DOCS_DIR/Makefile" << 'EOF'
# Makefile for Sphinx documentation

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = source
BUILDDIR      = build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

# Custom targets
clean:
	rm -rf $(BUILDDIR)/*

livehtml:
	sphinx-autobuild $(SOURCEDIR) $(BUILDDIR)/html

pdf: latexpdf
	@echo "PDF documentation built in $(BUILDDIR)/latex/"
EOF

print_success "Created Makefile"

# Create README for docs
print_info "Creating documentation README..."
cat > "$DOCS_DIR/README.md" << EOF
# $KICAD_PROJECT Dokumentation

Diese Verzeichnis enthält die Sphinx-basierte Dokumentation für das $KICAD_PROJECT PCB.

## Schnellstart

### HTML-Dokumentation erstellen

\`\`\`bash
# In Docker-Container
kicad_docs_build

# Oder lokal mit Sphinx
cd docs
sphinx-build -b html source build/html
\`\`\`

### PDF-Dokumentation erstellen

\`\`\`bash
# In Docker-Container  
kicad_docs_pdf

# Oder lokal mit Sphinx
cd docs
sphinx-build -b latex source build/latex
cd build/latex
make
\`\`\`

### Live-Vorschau (Entwicklung)

\`\`\`bash
cd docs
sphinx-autobuild source build/html
\`\`\`

Öffnet automatisch http://localhost:8000 mit Live-Reload.

## Dokumentationsstruktur

\`\`\`
docs/
├── source/
│   ├── conf.py              # Sphinx-Konfiguration
│   ├── index.rst            # Hauptseite
│   ├── introduction.rst     # Projekteinführung
│   ├── technical-specs.rst  # Technische Spezifikationen
│   ├── manufacturing.rst    # Fertigungsanweisungen
│   ├── usage.rst           # Verwendungsanleitung
│   ├── _static/            # Statische Dateien
│   └── _templates/         # Sphinx-Templates
├── build/                  # Generierte Dokumentation
├── requirements.txt        # Python-Dependencies
└── Makefile               # Build-Shortcuts
\`\`\`

## Bearbeitung

Die Dokumentation verwendet **reStructuredText** (.rst) Format:

- \`index.rst\` - Hauptinhaltsverzeichnis
- \`introduction.rst\` - Projektübersicht und Einführung  
- \`technical-specs.rst\` - Technische Daten und Spezifikationen
- \`manufacturing.rst\` - Fertigungsdetails und Produktionsdateien
- \`usage.rst\` - Installations- und Bedienungsanleitung

## Sphinx-Erweiterungen

Verfügbare Erweiterungen:

- \`myst_parser\` - Markdown-Unterstützung
- \`sphinx.ext.autodoc\` - Automatische API-Dokumentation  
- \`sphinx.ext.intersphinx\` - Links zu externer Dokumentation

## Anpassung

### Projekt-spezifische Inhalte

Passen Sie die folgenden Dateien an Ihr Projekt an:

- \`source/conf.py\` - Projekt-Metadaten
- \`source/index.rst\` - Projektbeschreibung
- \`source/technical-specs.rst\` - Spezifikationen
- \`source/manufacturing.rst\` - Fertigungsdetails

### Styling

- Theme: \`sphinx_rtd_theme\` (Read the Docs)
- Anpassungen in \`source/_static/\`
- CSS-Overrides möglich

## Build-Befehle

| Befehl | Beschreibung |
|--------|--------------|
| \`make html\` | HTML-Version erstellen |
| \`make latexpdf\` | PDF via LaTeX erstellen |
| \`make clean\` | Build-Verzeichnis leeren |
| \`make livehtml\` | Live-Vorschau starten |

## Fehlerbehandlung

**Häufige Probleme:**

1. **Unicode-Fehler in PDF**: LaTeX-Preamble in \`conf.py\` erweitern
2. **Fehlende Abhängigkeiten**: \`pip install -r requirements.txt\`
3. **Build-Fehler**: \`make clean\` vor erneutem Build

## Docker-Integration

Diese Dokumentation ist für die Verwendung mit dem \`kicaddev-docker\` Container optimiert:

\`\`\`bash
# Dokumentationsstruktur erstellen
docker run --rm -v \$(pwd):/workspace kicaddev-cli kicad_docs_init

# HTML-Dokumentation bauen  
docker run --rm -v \$(pwd):/workspace kicaddev-cli kicad_docs_build

# PDF-Dokumentation bauen
docker run --rm -v \$(pwd):/workspace kicaddev-cli kicad_docs_pdf
\`\`\`
EOF

print_success "Created documentation README"

# Final summary
print_header
print_success "Documentation structure successfully created!"
echo ""
print_info "Created files and directories:"
echo "  📁 $DOCS_DIR/"
echo "  📁 $SOURCE_DIR/"
echo "  📁 $SOURCE_DIR/_static/"
echo "  📁 $SOURCE_DIR/_templates/"
echo "  📄 $SOURCE_DIR/conf.py"
echo "  📄 $SOURCE_DIR/index.rst"
echo "  📄 $SOURCE_DIR/introduction.rst"
echo "  📄 $SOURCE_DIR/technical-specs.rst"
echo "  📄 $SOURCE_DIR/manufacturing.rst"
echo "  📄 $SOURCE_DIR/usage.rst"
echo "  📄 $DOCS_DIR/requirements.txt"
echo "  📄 $DOCS_DIR/Makefile"
echo "  📄 $DOCS_DIR/README.md"
echo "  📄 $DOCS_DIR/.gitignore"
echo ""
print_info "Next steps:"
echo "  1. Customize the documentation content in $SOURCE_DIR/"
echo "  2. Build HTML docs: kicad_docs_build $PROJECT_DIR"
echo "  3. Build PDF docs:  kicad_docs_pdf $PROJECT_DIR"
echo ""
print_info "Docker commands:"
echo "  docker run --rm -v \$(pwd):/workspace kicaddev-cli kicad_docs_build $PROJECT_DIR"
echo "  docker run --rm -v \$(pwd):/workspace kicaddev-cli kicad_docs_pdf $PROJECT_DIR"
echo ""
print_success "Documentation structure ready for KiCad project: $KICAD_PROJECT"
