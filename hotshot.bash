#! /bin/bash

# Generates the Hotshot Racing championship standings from data.csv
# Copyright (C) 2021  Yannick Mauray
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Some variables you might want to override with a command line parameter

DATA_CSV=data.csv
BG=bg.tiff
IMAGE_TITLE="2020 Hotshot Racing Winter Championship"
OUTPUT=hotshot_racing.png
KEEP_TMP_FILE=0

# Some variables that you probably won't have to change.

TMP_DIR=/tmp
TMP_CSV=${TMP_DIR}/tmp.csv
ROW_PNG=${TMP_DIR}/row.png
LABEL_PNG=${TMP_DIR}/label.png
MASK_PNG=${TMP_DIR}/mask.png
MAIN_PNG=${TMP_DIR}/main.png
TABLE_HEADER_PNG=${TMP_DIR}/table_header.png
HEADER_PNG=${TMP_DIR}/header.png

# Stuff you really should not touch unless you know what you're doing.

w0=220
w=295
o1=142 # Racer
o2=$((${o1} + ${w0})) # Coast
o3=$((${o2} + ${w})) # Desert
o4=$((${o3} + ${w})) # Jungle
o5=$((${o4} + ${w})) # Mountain
o6=$((${o5} + ${w})) # Championship

function computeScore()
{
    local score=0
    local firsts=0
    local seconds=0
    local thirds=0
    local fourths=0
    local fiths=0
    local sixths=0
    local sevenths=0
    local eights=0

    while [ ! -z "${1}" ]; do
        if [ ! ${1} -eq 0 ]; then
            score=$((${score} + 13 - ${1}))
        fi
        if [ ${1} -eq 1 ]; then
            firsts=$((${firsts} + 1))
        fi
        if [ ${1} -eq 2 ]; then
            seconds=$((${seconds} + 1))
        fi
        if [ ${1} -eq 3 ]; then
            thirds=$((${thirds} + 1))
        fi
        if [ ${1} -eq 4 ]; then
            fourths=$((${fourths} + 1))
        fi
        if [ ${1} -eq 5 ]; then
            fiths=$((${fiths} + 1))
        fi
        if [ ${1} -eq 6 ]; then
            sixths=$((${sixths} + 1))
        fi
        if [ ${1} -eq 7 ]; then
            sevenths=$((${sevenths} + 1))
        fi
        if [ ${1} -eq 8 ]; then
            eights=$((${eights} + 1))
        fi
        shift
    done

    echo ${score},${firsts},${seconds},${thirds},${fourths},${fiths},${sixths},${sevenths},${eights}
}

function makerow()
{
    echo "Make row ${1}"

    local n=${1}
    local bg=${2}
    local racer=${3}
    local coast=${4}
    local tsaoc=${5}
    local desert=${6}
    local tresed=${7}
    local jungle=${8}
    local elgnuj=${9}
    local mountain=${10}
    local niatnuom=${11}
    local season=${12}

    local y0=$((n * 60 + 190))
    local y1=$((y0 + 60 - 1))
    local dx=$((134 - 8 * n))
    local dy=$((n * 60 + 190))

    # Row
    magick -size 1920x1080 canvas:none -fill "${bg}" -draw "rectangle 0,${y0} 1920,${y1}" ${MASK_PNG} -compose multiply -composite ${ROW_PNG}
    
    # Racer name
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size 1920x60 -gravity west label:"${racer}" ${LABEL_PNG}
    magick ${ROW_PNG} ${LABEL_PNG} -geometry +${dx}+${dy} -composite ${ROW_PNG}

    # Coast
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"${coast} / ${tsaoc}" ${LABEL_PNG}
    dx=$((dx+${w0}))
    magick ${ROW_PNG} ${LABEL_PNG} -geometry +${dx}+${dy} -composite ${ROW_PNG}

    # Desert
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"${desert} / ${tresed}" ${LABEL_PNG}
    dx=$((dx+${w}))
    magick ${ROW_PNG} ${LABEL_PNG} -geometry +${dx}+${dy} -composite ${ROW_PNG}

    # Jungle
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"${jungle} / ${elgnuj}" ${LABEL_PNG}
    dx=$((dx+${w}))
    magick ${ROW_PNG} ${LABEL_PNG} -geometry +${dx}+${dy} -composite ${ROW_PNG}

    # Mountain
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"${mountain} / ${niatnuom}" ${LABEL_PNG}
    dx=$((dx+${w}))
    magick ${ROW_PNG} ${LABEL_PNG} -geometry +${dx}+${dy} -composite ${ROW_PNG}

    # Season
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"${season}" ${LABEL_PNG}
    dx=$((dx+${w}))
    magick ${ROW_PNG} ${LABEL_PNG} -geometry +${dx}+${dy} -composite ${ROW_PNG}

    magick ${MAIN_PNG} ${ROW_PNG} -composite ${MAIN_PNG}
}

function makeTableHeader()
{
    echo "Make the table header"

    # Top yellow banner
    magick -size 1920x1080 canvas:none -fill "#cacd00" -draw 'rectangle 0,130 1920,189' ${MASK_PNG} -compose multiply -composite ${ROW_PNG}

    # Racer
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size 1920x60 -gravity west label:"Racer" ${LABEL_PNG}
    magick ${ROW_PNG} ${LABEL_PNG} -geometry +${o1}+130 -composite ${TABLE_HEADER_PNG}

    # Coast
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"Coast" ${LABEL_PNG}
    magick ${TABLE_HEADER_PNG} ${LABEL_PNG} -geometry +${o2}+130 -composite ${TABLE_HEADER_PNG}

    # Desert
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"Desert" ${LABEL_PNG}
    magick ${TABLE_HEADER_PNG} ${LABEL_PNG} -geometry +${o3}+130 -composite ${TABLE_HEADER_PNG}

    # Jungle
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"Jungle" ${LABEL_PNG}
    magick ${TABLE_HEADER_PNG} ${LABEL_PNG} -geometry +${o4}+130 -composite ${TABLE_HEADER_PNG}

    # Mountain
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"Mountain" ${LABEL_PNG}
    magick ${TABLE_HEADER_PNG} ${LABEL_PNG} -geometry +${o5}+130 -composite ${TABLE_HEADER_PNG}

    # Championship
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"Championship" ${LABEL_PNG}
    magick ${TABLE_HEADER_PNG} ${LABEL_PNG} -geometry +${o6}+130 -composite ${TABLE_HEADER_PNG}

    magick ${HEADER_PNG} ${TABLE_HEADER_PNG} -composite ${MAIN_PNG}
}

function usage()
{
    echo
    echo "Usage"
    echo "  ${LAUNCHER}"
    echo
    echo "You can also pass optional paremeters"
    echo "  -d | --data       : location of the data file. Default : ${DATA_CSV}"
    echo "  -b | --background : image to use as the background. Default : ${BG}"
    echo "  -t | --title      : title at the top of the board. Default : \"${IMAGE_TITLE}\""
    echo "  -o | --output     : the final composite file name. Default : ${OUTPUT}"
    echo "  -k | --keep       : keep the temporary files."

    exit 1
}

echo "hotshot.bash  Copyright (C) 2021  Yannick Mauray"
echo "This program comes with ABSOLUTELY NO WARRANTY."
echo "This is free software, and you are welcome to redistribute it"
echo "under certain conditions."
echo ""

readonly LAUNCHER=$(basename "${0}")

while [ $# -gt 0 ]; do
    case "${1}" in
        -d|--data)
            DATA_CSV="${2}"
            shift
            shift;;
        -b|--background)
            BG="${2}"
            shift
            shift;;
        -t|--title)
            IMAGE_TITLE="${2}"
            shift
            shift;;
        -o|--output)
            OUTPUT="${2}"
            shift
            shift;;
        -k|--keep)
            KEEP_TMP_FILE=1
            shift;;
        -h|--help)
            usage;;
        *)
            echo "ERROR! \"${1}\" is not a supported parameter."
            usage;;
    esac
done

# Check if data file exists

if [ ! -f ${DATA_CSV} ]; then
    echo "data.csv not found"
    exit 1
fi

# Create a new CSV file, with scores appended to each line.

rm -f ${TMP_CSV}
touch ${TMP_CSV}
cat ${DATA_CSV} | while read -r line
do
    a=(${line//,/ })
    driver=${a[0]}
    a=(${a[@]:1})
    s=$(computeScore ${a[@]})
    echo ${s},${line} >> ${TMP_CSV}
done

# Image header

echo "Make the header"
magick -size 1920x1080 canvas:none -fill white -draw 'polygon 150,0 0,1080 1770,1080 1920,0' ${MASK_PNG}
magick -size 1920x1080 canvas:none -fill "#fdfd03" -draw 'rectangle 0,15 1920,104' ${MASK_PNG} -compose multiply -composite ${ROW_PNG}
magick -background transparent -fill black -font "Oswald-Bold" -pointsize 50 -size 1758x90 -gravity center label:"${IMAGE_TITLE}" ${LABEL_PNG}
magick ${ROW_PNG} ${LABEL_PNG} -geometry +148+15 -composite ${HEADER_PNG}

makeTableHeader

# Now, let's build each row.

index=0
colorindex=0
color=("#058efe" "#0976e1")
cat ${TMP_CSV} | sort -t "," -k1nr -k2nr -k3nr -k4nr -k5nr -k6nr -k7nr -k8nr -k9nr | sed "s/,.*\(,[A-Z]\)/\1/" | while read line
do
    a=(${line//,/ })
    total=${a[0]}
    driver=${a[1]}
    args="${index} ${color[${colorindex}]} ${driver}"
    for i in 2 3 4 5 6 7 8 9
    do
        if [ ! -z ${a[${i}]} ]; then
            if [ ! ${a[${i}]} -eq 0 ]; then
                args="${args} ${a[$i]}"
            else
                args="${args} -"
            fi
        else
            args="${args} -"
        fi
    done
    args="${args} ${total}"
    index=$((${index} + 1))
    if [ ${colorindex} -eq 0 ]; then
        colorindex=1
    else
        colorindex=0
    fi
    makerow ${args[@]}
done

# Compose the final image

magick ${BG} ${MAIN_PNG} -composite ${OUTPUT}

# Cleanup

if [ ${KEEP_TMP_FILE} -eq 0 ]; then
    rm ${TMP_CSV}
    rm ${ROW_PNG}
    rm ${LABEL_PNG}
    rm ${MASK_PNG}
    rm ${MAIN_PNG}
    rm ${TABLE_HEADER_PNG}
    rm ${HEADER_PNG}
fi
