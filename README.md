NAME
====

GD::Raw - Low level language bindings to GD Graphics Library

SYNOPSIS
========

        use GD::Raw;

        my $fh = fopen("my-image.png", "rb");
        my $img = gdImageCreateFromPng($fh);

        say "Image resolution is ", gdImageSX($img), "x", gdImageSX($img);

        gdImageDestroy($img);

DESCRIPTION
===========

`GD::Raw` is a low level language bindings to LibGD. It does not attempt to  provide you with an perlish interface, but tries to stay as close to it's C  origin as possible.

LibGD is large and this module far from covers it all. Feel free to add anything your missing and submit a pull request!


## Installation

You need to install first libgdraw4 (in Ubuntu) or equivalent.

    sudo apt install libgdraw4
