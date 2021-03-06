package thx.color;

using thx.core.Arrays;
using thx.core.Ints;
using thx.core.Floats;
using thx.core.Strings;
import thx.color.parse.ColorParser;

@:access(thx.color.CMY)
@:access(thx.color.CMYK)
@:access(thx.color.HSL)
@:access(thx.color.HSV)
@:access(thx.color.RGB)
@:access(thx.color.Grey)
@:access(thx.color.RGBXA)
@:access(thx.color.XYZ)
abstract RGBX(Array<Float>) {
  public static function create(red : Float, green : Float, blue : Float)
    return new RGBX([red.normalize(), green.normalize(), blue.normalize()]);

  @:from public static function fromFloats(arr : Array<Float>) {
    arr.resize(3);
    return RGBX.create(arr[0], arr[1], arr[2]);
  }

  @:from public static function fromInts(arr : Array<Int>) {
    arr.resize(3);
    return RGBX.create(arr[0] / 255, arr[1] / 255, arr[2] / 255);
  }

  @:from public static function fromString(color : String) {
    var info = ColorParser.parseHex(color);
    if(null == info)
      info = ColorParser.parseColor(color);
    if(null == info)
      return null;

    return try switch info.name {
      case 'rgb':
        RGBX.fromFloats(ColorParser.getFloatChannels(info.channels, 3));
      case _:
        null;
    } catch(e : Dynamic) null;
  }

  inline function new(channels : Array<Float>) : RGBX
    this = channels;

  public var red(get, never) : Int;
  public var green(get, never) : Int;
  public var blue(get, never) : Int;
  public var redf(get, never) : Float;
  public var greenf(get, never) : Float;
  public var bluef(get, never) : Float;

  public function darker(t : Float)
    return new RGBX([
      t.interpolate(redf, 0),
      t.interpolate(greenf, 0),
      t.interpolate(bluef, 0),
    ]);

  public function lighter(t : Float)
    return new RGBX([
      t.interpolate(redf, 1),
      t.interpolate(greenf, 1),
      t.interpolate(bluef, 1),
    ]);

  public function interpolate(other : RGBX, t : Float)
    return new RGBX([
      t.interpolate(redf, other.redf),
      t.interpolate(greenf, other.greenf),
      t.interpolate(bluef, other.bluef)
    ]);

  public function toCSS3() : String
    return toString();

  @:to public function toString() : String
    return 'rgb(${redf*100}%,${greenf*100}%,${bluef*100}%)';

  public function toHex(prefix = "#") : String
    return '$prefix${red.hex(2)}${green.hex(2)}${blue.hex(2)}';

  @:op(A==B) public function equals(other : RGBX)
    return redf.nearEquals(other.redf) && greenf.nearEquals(other.greenf) && bluef.nearEquals(other.bluef);

  public function withAlpha(alpha : Float)
    return new RGBXA(this.concat([alpha.normalize()]));

  public function withRed(newred : Int)
    return new RGBX([newred.normalize(), green, blue]);

  public function withGreen(newgreen : Int)
    return new RGBX([red, newgreen.normalize(), blue]);

  public function withBlue(newblue : Int)
    return new RGBX([red, green, newblue.normalize()]);

  @:to public function toCIELab()
    return toXYZ().toCIELab();

  @:to public function toCIELCh()
    return toCIELab().toCIELCh();

  @:to public function toCMY() : CMY
    return new CMY([
      1 - redf,
      1 - greenf,
      1 - bluef
    ]);

  @:to public function toCMYK() {
    var c = 0.0, y = 0.0, m = 0.0, k;
    if (redf + greenf + bluef == 0) {
      k = 1.0;
    } else {
      k = 1 - redf.max(greenf).max(bluef);
      c = (1 - redf - k)   / (1 - k);
      m = (1 - greenf - k) / (1 - k);
      y = (1 - bluef - k)  / (1 - k);
    }
    return new CMYK([c, m, y, k]);
  }

  @:to public function toGrey()
    return new Grey(redf * .2126 + greenf * .7152 + bluef * .0722);

  public function toPerceivedGrey()
    return new Grey(redf * .299 + greenf * .587 + bluef * .114);

  public function toPerceivedAccurateGrey()
    return new Grey(Math.pow(redf, 2) * .241 + Math.pow(greenf, 2) * .691 + Math.pow(bluef, 2) * .068);

  @:to public function toHSL() {
    var min = redf.min(greenf).min(bluef),
        max = redf.max(greenf).max(bluef),
        delta = max - min,
        h,
        s,
        l = (max + min) / 2;
#if php
    if (delta.nearZero())
#else
    if (delta == 0.0)
#end
      s = h = 0.0;
    else {
      s = l < 0.5 ? delta / (max + min) : delta / (2 - max - min);
      if (redf == max)
        h = (greenf - bluef) / delta + (greenf < blue ? 6 : 0);
      else if (greenf == max)
        h = (bluef - redf) / delta + 2;
      else
        h = (redf - greenf) / delta + 4;
      h *= 60;
    }
    return new HSL([h, s, l]);
  }

  @:to public function toHSV() {
    var min = redf.min(greenf).min(bluef),
      max = redf.max(greenf).max(bluef),
      delta = max - min,
      h : Float,
      s : Float,
      v : Float = max;
    if (delta != 0)
      s = delta / max;
    else {
      s = 0;
      h = -1;
      return new HSV([h, s, v]);
    }

    if (redf == max)
      h = (greenf - bluef) / delta;
    else if (greenf == max)
      h = 2 + (bluef - redf) / delta;
    else
      h = 4 + (redf - greenf) / delta;

    h *= 60;
    if (h < 0)
      h += 360;
    return new HSV([h, s, v]);
  }

  @:to public function toRGB()
    return RGB.createf(redf, greenf, bluef);

  @:to public function toRGBXA()
    return withAlpha(1.0);

  @:to public function toXYZ() {
    var r = redf,
        g = greenf,
        b = bluef;

    r = 100 * (r > 0.04045 ? Math.pow(((r + 0.055) / 1.055), 2.4) : r / 12.92);
    g = 100 * (g > 0.04045 ? Math.pow(((g + 0.055) / 1.055), 2.4) : g / 12.92);
    b = 100 * (b > 0.04045 ? Math.pow(((b + 0.055) / 1.055), 2.4) : b / 12.92);

    return new XYZ([
      r * 0.4124 + g * 0.3576 + b * 0.1805,
      r * 0.2126 + g * 0.7152 + b * 0.0722,
      r * 0.0193 + g * 0.1192 + b * 0.9505
    ]);
  }

  @:to public function toYxy()
    return toXYZ().toYxy();

  function get_red() : Int
    return (redf   * 255).round();
  function get_green() : Int
    return (greenf * 255).round();
  function get_blue() : Int
    return (bluef  * 255).round();

  inline function get_redf() : Float
    return this[0];
  inline function get_greenf() : Float
    return this[1];
  inline function get_bluef() : Float
    return this[2];
}