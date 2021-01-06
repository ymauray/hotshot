#! /bin/bash

if [ ! -f data.csv ]; then
    echo "data.csv not found"
    exit 1
fi

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

rm -f tmp.csv
cat data.csv | while read -r line
do
    a=(${line//,/ })
    driver=${a[0]}
    a=(${a[@]:1})
    s=$(computeScore ${a[@]})
    echo ${s},${line} >> tmp.csv
done

if [ ! -f transparent.png ]; then
    echo "Make a transparent image for compositing purposes"
    magick -size 1920x1080 canvas:none transparent.png
fi

if [ ! -f mask.png ]; then
    echo "Make the main mask"
    magick -size 1920x1080 canvas:none -fill white -draw 'polygon 150,0 0,1080 1770,1080 1920,0' mask.png
fi

if [ ! -f header.png ]; then
    echo "Make the header"
    magick -size 1920x1080 canvas:none -fill "#fdfd03" -draw 'rectangle 0,15 1920,104' mask.png -compose multiply -composite row.png
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 50 -size 1758x90 -gravity center label:"2020 Hotshot Racing Winter Championship" label.png
    magick row.png label.png -geometry +148+15 -composite header.png
fi

w0=220
w=295
o1=142 # Racer
o2=$((${o1} + ${w0})) # Coast
o3=$((${o2} + ${w})) # Desert
o4=$((${o3} + ${w})) # Jungle
o5=$((${o4} + ${w})) # Mountain
o6=$((${o5} + ${w})) # Championship

if [ ! -f table_header.png ]; then
    echo "Make the table header"
    magick -size 1920x1080 canvas:none -fill "#cacd00" -draw 'rectangle 0,130 1920,189' mask.png -compose multiply -composite row.png
    
    # Racer
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size 1920x60 -gravity west label:"Racer" label.png
    magick row.png label.png -geometry +${o1}+130 -composite table_header.png
    
    # Coast
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"Coast" label.png
    magick table_header.png label.png -geometry +${o2}+130 -composite table_header.png
    
    # Desert
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"Desert" label.png
    magick table_header.png label.png -geometry +${o3}+130 -composite table_header.png

    # Jungle
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"Jungle" label.png
    magick table_header.png label.png -geometry +${o4}+130 -composite table_header.png

    # Mountain
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"Mountain" label.png
    magick table_header.png label.png -geometry +${o5}+130 -composite table_header.png

    # Championship
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"Championship" label.png
    magick table_header.png label.png -geometry +${o6}+130 -composite table_header.png
fi

magick header.png table_header.png -composite main.png

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
    magick -size 1920x1080 canvas:none -fill "${bg}" -draw "rectangle 0,${y0} 1920,${y1}" mask.png -compose multiply -composite row.png
    
    # Racer name
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size 1920x60 -gravity west label:"${racer}" label.png
    magick row.png label.png -geometry +${dx}+${dy} -composite row.png

    # Coast
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"${coast} / ${tsaoc}" label.png
    dx=$((dx+${w0}))
    magick row.png label.png -geometry +${dx}+${dy} -composite row.png

    # Desert
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"${desert} / ${tresed}" label.png
    dx=$((dx+${w}))
    magick row.png label.png -geometry +${dx}+${dy} -composite row.png

    # Jungle
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"${jungle} / ${elgnuj}" label.png
    dx=$((dx+${w}))
    magick row.png label.png -geometry +${dx}+${dy} -composite row.png

    # Mountain
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"${mountain} / ${niatnuom}" label.png
    dx=$((dx+${w}))
    magick row.png label.png -geometry +${dx}+${dy} -composite row.png

    # Season
    magick -background transparent -fill black -font "Oswald-Bold" -pointsize 40 -size ${w}x60 -gravity center label:"${season}" label.png
    dx=$((dx+${w}))
    magick row.png label.png -geometry +${dx}+${dy} -composite row.png

    magick main.png row.png -composite main.png
}

index=0
colorindex=0
color=("#058efe" "#0976e1")
cat tmp.csv | sort -t "," -k1nr -k2nr -k3nr -k4nr -k5nr -k6nr -k7nr -k8nr -k9nr | sed "s/,.*\(,[A-Z]\)/\1/" | while read line
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

magick bg.tiff main.png -composite hotshot_racing.png
