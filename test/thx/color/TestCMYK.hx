
package thx.color;

import utest.Assert;

class TestCMYK {
	public function new() { }

	public function testBasics() {
		var cmyk = CMYK.fromFloats(0.1, 0.2, 0.3, 0.4);
		Assert.equals(0.1, cmyk.cyan);
		Assert.equals(0.2, cmyk.magenta);
		Assert.equals(0.3, cmyk.yellow);
		Assert.equals(0.4, cmyk.black);
	}

	public function testStrings() {
		var cmyk = CMYK.fromFloats(0,1,1,0);
		Assert.equals("cmyk(0,1,1,0)", cmyk.toString());
	}
}
