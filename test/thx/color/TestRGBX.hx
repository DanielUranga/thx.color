package thx.color;

import utest.Assert;
import thx.color.RGBXA;

class TestRGBX {
  public function new() { }

  public function testBasics() {
    var red = RGBX.create(1, 0, 0);
    Assert.equals(0xFF, red.red);
    Assert.equals(0x00, red.green);
    Assert.equals(0x00, red.blue);
  }

  public function testStrings() {
    var color = RGBX.create(0, 0, 1);
    Assert.equals("rgb(0%,0%,100%)", color.toCSS3());
    Assert.equals("#0000FF", color.toHex());
    Assert.equals("rgb(0%,0%,100%)", color.toString());
  }

  public function testFromString() {
    Assert.isTrue(RGBX.create(0,1,0).equals("#00ff00"));
    Assert.isTrue(RGBX.create(0,1,0).equals("#0f0"));
    Assert.isTrue(RGBX.create(0,1,0).equals("rgb(0,100%,0)"));
    Assert.isTrue(RGBX.create(0,1,0).equals("rgb(0,255,0)"));
    Assert.isTrue(RGBXA.create(0,1,0,1).equals("#ff00ff00"));
    Assert.isTrue(RGBXA.create(0,1,0,1).equals("#f0f0"));
    Assert.isTrue(RGBXA.create(0,1,0,0.5).equals("rgba(0,255,0,50%)"));
    Assert.isTrue(RGBXA.create(0,1,0,0.5).equals("rgba(0,100%,0,0.5)"));
  }
}