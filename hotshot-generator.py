#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# Imports 
#
from genericpath import exists
from gimpfu import *
import os
import sys
import ConfigParser

#
# Read default values from config file
#
config_home = os.getenv('XDG_CONFIG_HOME')
config_file_exists = False
data_file_default = ''
background_file_default = ''

if config_home is None:
    config_home = os.getenv('HOME') + "./config"

if os.path.exists(config_home):
    config_file = config_home + "/hotshot-generator.conf"
    if not os.path.exists(config_file):
        open(config_file, 'a').close()
    if os.path.exists(config_file):
        config_file_exists = True
        config = ConfigParser.ConfigParser()
        config.readfp(open(config_file))
        if config.has_section('hotshot-generator'):
            if config.has_option('hotshot-generator', 'data-file'):
                data_file_default = config.get('hotshot-generator', 'data-file')
            if config.has_option('hotshot-generator', 'background-file'):
                background_file_default = config.get('hotshot-generator', 'background-file')

#
# Main function 
#
def hotshot(data_file, background_file):

    #
    # Write values in config file, if it exists.
    #
    if config_file_exists:
        config = ConfigParser.ConfigParser()
        config.readfp(open(config_file))
        if not config.has_section('hotshot-generator'):
            config.add_section('hotshot-generator')
        config.set('hotshot-generator', 'data-file', data_file)
        config.set('hotshot-generator', 'background-file', background_file)
        with open(config_file, 'wb') as cf:
            config.write(cf)

    #
    # Open the background image, make a copy and close the original
    #
    original_image = pdb.gimp_xcf_load(0, background_file, "Hotshot Racing Standings")
    image = pdb.gimp_image_duplicate(original_image)
    pdb.gimp_image_delete(original_image)

    #
    # Read the data
    #
    with open(data_file) as df:
        lines = iter(df.readlines())
        championship_name = next(lines)

        tracks = next(lines).split(',')

        #
        # Sort the results in order of points, then number of 1st places, of 2nd places, and 3rd places.
        # If there is still a tie, then sort by alphabetical order.
        #
        results = []
        while True:
            try:
                line = next(lines)
                chunks = line.split(',')
                racer_name = chunks[0]
                points = 0
                first_place_finish = 0
                second_place_finish = 0
                third_place_finish = 0
                for i in range(1, len(chunks)):
                    finish = int(chunks[i].strip())

                    # 12 points for 1st place, 11 for second, etc...
                    if (finish > 0):
                        points += 13 - finish
                    # Compute the number of 1st place finish, 2nd place finish, 3rd place finish.
                    if finish == 1: first_place_finish += 1
                    if finish == 2: second_place_finish += 1
                    if finish == 3: third_place_finish += 1

                # Append the tuple to the results array, including the original line .
                results.append((-points, -first_place_finish, -second_place_finish, -third_place_finish, racer_name, line))
            except StopIteration:
                break

    # Sort the results.
    results.sort()

    # Replace the text on the header layer.
    championship_name_layer = pdb.gimp_image_get_layer_by_name(image, "Championship name")
    pdb.gimp_text_layer_set_text(championship_name_layer, championship_name)

    # Prepare some variables to create all the text layers, which are all duplicates
    # of the 'Racer label' layer.
    racer_label_layer = pdb.gimp_image_get_layer_by_name(image, "Racer label")
    racer_label_offx, racer_label_offy = pdb.gimp_drawable_offsets(racer_label_layer)
    offx = racer_label_offx
    offy = racer_label_offy
    index = 0
    max_width = 0
    
    # Go over each result
    for result in results:
        racer_name = result[4]
        index += 1
        # Compute the position of the racer's name layer
        offx -= 125 / 15
        offy += 60
        # Duplicate 'Racer label' layer, and place it properly
        row_group = pdb.gimp_image_get_layer_by_name(image, "Row {}".format(index))
        racer_name_layer = pdb.gimp_layer_copy(racer_label_layer, 0)
        pdb.gimp_layer_set_name(racer_name_layer, "Racer {} name".format(index))
        pdb.gimp_image_insert_layer(image, racer_name_layer, row_group, 0)
        pdb.gimp_text_layer_set_text(racer_name_layer, racer_name)
        pdb.gimp_layer_set_offsets(racer_name_layer, offx, offy)
        # Compute the largest racer name label.
        width = pdb.gimp_drawable_width(racer_name_layer)
        if max_width < width: max_width = width

    # Hide any unused rows
    for i in range(index + 1, 15):
        row_group = pdb.gimp_image_get_layer_by_name(image, "Row {}".format(i))
        pdb.gimp_layer_set_visible(row_group, 0)

    # Compute the width of each result column, including the "Championship" one.
    min_offset = racer_label_offx + max_width + 10
    max_offset = 1884
    num_tracks = len(tracks)
    label_width = (max_offset - min_offset) / (num_tracks + 1)

    # Add the track names in the table header row.
    offset = min_offset
    row_group = pdb.gimp_image_get_layer_by_name(image, "Table header")
    index = 1
    for track in tracks:
        track_name = track.strip()
        track_name_layer = pdb.gimp_layer_copy(racer_label_layer, 0)
        pdb.gimp_layer_set_name(track_name_layer, "Track {} name".format(index))
        pdb.gimp_image_insert_layer(image, track_name_layer, row_group, index)
        pdb.gimp_text_layer_set_text(track_name_layer, track_name)
        pdb.gimp_text_layer_resize(track_name_layer, label_width, 60)
        pdb.gimp_layer_set_offsets(track_name_layer, offset, racer_label_offy)

        # Go over each result
        racer_index = 0
        result_layer_offx = offset
        result_layer_offy = racer_label_offy
        for result in results:
            racer_index += 1
            result_layer_offx -= 125 / 15
            result_layer_offy += 60
            positions = result[5].split(',')
            normal = positions[2 * index - 1].strip() if len(positions) > (2 * index - 1) else " "
            normal = "-" if normal == "0" else normal
            mirrored = positions[2 * index].strip() if len(positions) > (2 * index) else " "
            mirrored = "-" if mirrored == "0" else mirrored
            result_layer = pdb.gimp_layer_copy(racer_label_layer, 0)
            result_row_group = pdb.gimp_image_get_layer_by_name(image, "Row {}".format(racer_index))
            pdb.gimp_layer_set_name(result_layer, "Racer {} Track {} result".format(racer_index, index))
            pdb.gimp_image_insert_layer(image, result_layer, result_row_group, index)
            if normal == " ":
                pdb.gimp_text_layer_set_text(result_layer, "")
            elif mirrored == " ":
                pdb.gimp_text_layer_set_text(result_layer, normal)
            else:
                pdb.gimp_text_layer_set_text(result_layer, "{} / {}".format(normal, mirrored))
            pdb.gimp_text_layer_resize(result_layer, label_width, 60)
            pdb.gimp_layer_set_offsets(result_layer, result_layer_offx, result_layer_offy)

        offset += label_width
        index += 1

    # Add the "Championship" label in the table header row.
    track_name_layer = pdb.gimp_layer_copy(racer_label_layer, 0)
    pdb.gimp_layer_set_name(track_name_layer, "Championship")
    pdb.gimp_image_insert_layer(image, track_name_layer, row_group, index)
    pdb.gimp_text_layer_set_text(track_name_layer, "Championship")
    pdb.gimp_layer_set_offsets(track_name_layer, offset, racer_label_offy)

    # Go over each result
    racer_index = 0
    result_layer_offx = offset
    result_layer_offy = racer_label_offy
    for result in results:
        racer_index += 1
        result_layer_offx -= 125 / 15
        result_layer_offy += 60
        points = -int(result[0])
        result_layer = pdb.gimp_layer_copy(racer_label_layer, 0)
        result_row_group = pdb.gimp_image_get_layer_by_name(image, "Row {}".format(racer_index))
        pdb.gimp_layer_set_name(result_layer, "Racer {} championship result".format(racer_index))
        pdb.gimp_image_insert_layer(image, result_layer, result_row_group, index)
        pdb.gimp_text_layer_set_text(result_layer, "{}".format(points))
        pdb.gimp_text_layer_resize(result_layer, label_width, 60)
        pdb.gimp_layer_set_offsets(result_layer, result_layer_offx, result_layer_offy)

    image.flatten()
    pdb.gimp_display_new(image)

register(
    "hotshot-generator",
    "Hotshot Racing championship standing generator",
    "Creates the standing image",
    "Yannick Mauray",
    "Released under a BSD licence",
    "January 2021",
    "Hotshot Racing standings",
    "",      # Create a new image, don't work on an existing one
    [
        (PF_STRING, "data_file", "Path to config file", data_file_default),
        (PF_STRING, "background_file", "Path to background image", background_file_default),
    ],
    [],
    hotshot, menu="<Image>/File/Create")

main()
