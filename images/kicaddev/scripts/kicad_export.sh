#!/bin/bash
# KiCad production data export script

if [ $# -eq 0 ]; then
    echo "Usage: $0 <kicad-project-file.kicad_pro>"
    exit 1
fi

project_file="$1"
project_dir=$(realpath "$(dirname "$project_file")")
project_name=$(basename "$project_file" .kicad_pro)
output_dir="$project_dir/production"

echo "Exporting production data for $project_name..."

mkdir -p "$output_dir/gerbers"
mkdir -p "$output_dir/drill"
mkdir -p "$output_dir/pdf"
mkdir -p "$output_dir/3d"
mkdir -p "$output_dir/bom"

# Use absolute paths to avoid path duplication issues
pcb_file="$project_dir/${project_name}.kicad_pcb"
sch_file="$project_dir/${project_name}.kicad_sch"

# Export Gerbers and Drill files
echo "📋 Exporting Gerber files..."
kicad-cli pcb export gerbers --output "$output_dir/gerbers/" "$pcb_file"

echo "🕳️  Exporting Drill files..."
kicad-cli pcb export drill --output "$output_dir/drill/" "$pcb_file"

# Create ZIP archive for manufacturing
echo "📦 Creating manufacturing ZIP archive..."
(cd "$output_dir" && zip -r "${project_name}_manufacturing.zip" gerbers/ drill/)

# Export PDFs
echo "📄 Exporting schematic PDF..."
kicad-cli sch export pdf --output "$output_dir/pdf/${project_name}_schematic.pdf" "$sch_file"

echo "📄 Exporting PCB PDF..."
kicad-cli pcb export pdf --layers "F.Cu,B.Cu,F.Silkscreen,B.Silkscreen,Edge.Cuts" --output "$output_dir/pdf/${project_name}_pcb.pdf" "$pcb_file"

# Export 3D view
echo "🎨 Exporting 3D views..."
kicad-cli pcb export step --output "$output_dir/3d/${project_name}.step" "$pcb_file"

# Export Interactive HTML BOM
echo "🌐 Generating Interactive HTML BOM..."
# Use absolute path and specify output directory explicitly
if command -v generate_ibom_headless >/dev/null 2>&1; then
    generate_ibom_headless --dest-dir "$output_dir/bom/" --name-format "${project_name}_ibom" --no-browser "$pcb_file"
else
    # Fallback to regular generate_interactive_bom with xvfb-run
    xvfb-run -a generate_interactive_bom --dest-dir "$output_dir/bom/" --name-format "${project_name}_ibom" --no-browser "$pcb_file"
fi

echo "✅ Production data exported to $output_dir"
echo "📦 Manufacturing ZIP: $output_dir/${project_name}_manufacturing.zip"