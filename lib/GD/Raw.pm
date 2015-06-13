use NativeCall;

sub LIB {
    given $*VM.name {
       when 'parrot' {
           given $*VM.config<load_ext> {
               when '.so' { return 'libgd.so' }	# Linux
	            when '.bundle' { return 'libgd.dylib' }	# Mac OS
	            default { return 'libgd' }
           }
       }
       default {
          return 'libgd';
       }
    }
}

constant gdAlphaMax is export = 127;
constant gdAlphaOpaque is export = 0;
constant gdAlphaTransparent is export = 127;
constant gdRedMax is export = 255;
constant gdGreenMax is export = 255;
constant gdBlueMax is export = 255;
sub gdTrueColorGetAlpha($c) is export {
    ((($c) +& 0x7F000000) +> 24)
}
sub gdTrueColorGetRed($c) is export {
    ((($c) +& 0xFF0000) +> 16)
}
sub gdTrueColorGetGreen($c) is export {
    ((($c) +& 0x00FF00) +> 8)
}
sub gdTrueColorGetBlue($c) is export {
    (($c) +& 0x0000FF)
}
constant gdEffectReplace is export = 0;
constant gdEffectAlphaBlend is export = 1;
constant gdEffectNormal is export = 2;
constant gdEffectOverlay is export = 3;

class gdImageStruct is repr('CStruct') is export {
    has int32 $.hack1; # Hack! don't know how to represent unsigned char **
    has int32 $.hack2; # Hack! so we pretend we have two ints to get to sx, sy
    has int32 $.sx = -1;
    has int32 $.sy = -1;
}
class gdImagePtr is repr('CStruct') is gdImageStruct { }

sub gdImageSX($img) is export {
    return $img.sx;
}

sub gdImageSY($img) is export {
    return $img.sy;
}

sub fopen( Str $filename, Str $mode )
    returns OpaquePointer
    is native(LIB) is export { ... }

sub fclose(OpaquePointer)
    is native(LIB) is export { ... }

sub gdImageCreateFromJpeg(OpaquePointer $file) 
    returns gdImagePtr
    is native(LIB) is export { ... } 

sub gdImageCreateFromPng(OpaquePointer $file) 
    returns gdImagePtr
    is native(LIB) is export { ... } 

sub gdImageCreateFromGif(OpaquePointer $file)
    returns gdImagePtr
    is native(LIB) is export { ... }

sub gdImageCreateFromBmp(OpaquePointer $file)
    returns gdImagePtr
    is native(LIB) is export { ... }

sub gdImageCreateTrueColor(int32, int32)
    returns gdImagePtr
    is native(LIB) is export { ... }

sub gdImageCreate(int32, int32)
    returns gdImagePtr
    is native(LIB) is export { ... }

sub gdImageJpeg(gdImageStruct $image, OpaquePointer $file, Int $quality where { $_ <= 95 }) 
    is native(LIB) is export { ... }

sub gdImagePng(gdImageStruct $image, OpaquePointer $file)
    is native(LIB) is export { ... }

sub gdImageGif(gdImageStruct $im, OpaquePointer $f)
    is native(LIB) is export { ... }

sub gdImageBmp(gdImageStruct $im, OpaquePointer $f, int32)
    is native(LIB) is export { ... }

sub gdImageCopyResized(gdImageStruct $dst, gdImageStruct $src, 
        int32 $dstX, int32 $dstY,
        int32 $srcX, int32 $srcY, 
        int32 $dstW, int32 $dstH, int32 $srcW, int32 $srcH) 
    is native(LIB) is export { ... }

sub gdImageCopyResampled(gdImageStruct $dst, gdImageStruct $src,
    Int $dstX, Int $dstY, Int $srcX, Int $srcY, Int $dstW, Int $dstH, Int $srcW, Int $srcH)
    is native(LIB) is export { ... }

sub gdImageDestroy(gdImageStruct)
    is native(LIB) is export { ... }

sub gdImageGetTrueColorPixel(gdImagePtr $im, int32 $x, int32 $y)
    returns int
    is native(LIB) is export { * }

sub gdImageSetPixel(gdImagePtr $im, int32 $x, int32 $y, int32 $color)
    # returns void
    is native(LIB) is export { * }


sub gdTrueColorAlpha($r, $g, $b, $a) is export {
    ((($a) +< 24) + 
	 (($r) +< 16) + 
	 (($g) +< 8) + 
	 ($b));
}

sub gdImageColorAllocate(gdImagePtr $im, int32 $r, int32 $g, int32 $b)
    returns int32
    is native(LIB) is export { * }

sub gdImageFilledRectangle(gdImagePtr $im, int32 $x1, int32 $y1, int32 $x2, int32 $y2, int $color)
    #returns void
    is native(LIB) is export { * }

sub gdImageLine(gdImagePtr $im, int32 $x1, int32 $y1, int32 $x2, int32 $y2, int32 $color)
    #returns void
    is native(LIB) is export { * }

class gdPoint is repr('CStruct') is export {
    has int32 $.x is rw = 0;
    has int32 $.y is rw = 0;
}

class gdPointPtr is repr('CStruct') is gdPoint { }

## Re-implement gdImagePolygon until NativeCall has a way 
## to pass array of gdPointPtr
sub gdImagePolygon(gdImagePtr $im, @p, int32 $n, int32 $c) is export
{
	return if $n <= 0;

	gdImageLine($im, @p[0].x, @p[0].y, @p[$n - 1].x, @p[$n - 1].y, $c);
	gdImageOpenPolygon($im, @p, $n, $c);
}

sub gdImageOpenPolygon(gdImagePtr $im, @p, int32 $n, int32 $c) is export
{
	return if $n <= 0;

	my $lx = @p[0].x;
	my $ly = @p[0].y;
    for 1..($n-1) -> $i {
        my ($x, $y) = (@p[$i].x, @p[$i].y);
        gdImageLine($im, $lx, $ly, $x, $y, $c);
        ($lx, $ly) = ($x, $y);
    }
}


=begin pod

=head1 NAME

GD::Raw - Low level language bindings to GD Graphics Library

=head1 SYNOPSIS

    use GD::Raw;
    
    my $fh = fopen("my-image.png", "rb");
    my $img = gdImageCreateFromPng($fh);
    
    say "Image resolution is ", gdImageSX($img), "x", gdImageSX($img);
    
    gdImageDestroy($img);

=head1 DESCRIPTION

C<GD::Raw> is a low level language bindings to LibGD. It does not attempt to 
provide you with an perlish interface, but tries to stay as close to it's C 
origin as possible.

LibGD is large and this module far from covers it all. Feel free to add anything
your missing and submit a pull request!

=end pod
