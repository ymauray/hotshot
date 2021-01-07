Hotshot Racing Tournament Standings generator
=============================================

This script uses ImageMagick to generate an image of the Wimpy's World of Linux Gaming Hotshot Racing Championship.

It reads its data from `data.csv`, sorts it, and creates an image.

Pre-requisite
-------------
You will need the font "Oswald-Bold" installed on your system. You can get it for free [from Google Fonts](https://fonts.google.com/specimen/Oswald).

You can check that the font is installed with the command 
```bash
magick -list font | grep Oswald-Bold
```

You will also need [ImageMagick](https://imagemagick.org/script/download.php#unix) installed. I use the appimage, I saved it in `/opt/ImageMagick` and installed it using `update-alternative` : 
```
sudo update-alternatives --install /usr/local/bin/magick magick /opt/ImageMagick/magick 50
```

Running the script
------------------

Provided that the `magick` command is in the path and the `Oswald-Bold` font is installed, simply run the script with :
```
bash ./hotshot.bash
```
A few `png` files will be created, and the final one is called `hotshot_racing.png`

The data
--------
`data.csv` contains the results of the different legs of the championship. The format is very simple :

```csv
racer name,position,position,position,...
```

where `position` is the finishing position of the racer for that leg.

For example, at the time of writing, the file is :

```csv
Wimpy,2,3,1,2,1,3
FrenchguyCH,1,1,3,1,2,4
TwoD,4,5,4,3,4,1
BigCalm,3,6,6,5,6,6
Popey,0,2,2,4,0,0
Rpodcast,0,0,7,7,3,5
Madhens,0,0,8,8,8,8
Bigpod,0,0,0,0,5,2
UnwiseGeek,0,0,5,6,0,0
Hydromalis,0,0,0,0,7,7
AndCatchFire,0,4,0,0,0,0
```

The script assigns 12 points for first place, 11 for second, etc.

In case of a tie, the racer with the most 1st places is in front. If it's still a tie, then the racer with the most 2nd places is in front, and so on.

The script will read up to 8 results - 4 tournaments (Coast, Desert, Jungle and Mountain) in the normal and mirrored configuration.
