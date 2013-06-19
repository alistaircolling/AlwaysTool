package
{
	import mx.core.FontAsset;
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.text.Font;
	import flash.utils.describeType;

	public class MyFonts extends Sprite
	{
		[Embed(source="../assets/Arial.ttf", mimeType="application/x-font-truetype", fontName="Arial", unicodeRange="U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E", embedAsCFF="false")] // Basic Latin ; chars=""
		public  var Arial:Class;
		[Embed(systemFont="ITC Avant Garde Gothic", mimeType="application/x-font", fontName="iTCAvantGardeGothic", unicodeRange="U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E", embedAsCFF="false")] // Basic Latin ; chars=""
		public  var iTCAvantGardeGothic:Class;

		public function MyFonts()
		{
			FontAsset;
			Security.allowDomain("*");
			var xml:XML = describeType(this);
			for (var i:uint = 0; i < xml.variable.length(); i++)
			{
				Font.registerFont(this[xml.variable[i].@name]);
			}
		}
	}
}