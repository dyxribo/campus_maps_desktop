package thirdparty.com.lorentz.SVG.display {
import flash.geom.Rectangle;

import thirdparty.com.lorentz.SVG.display.base.ISVGPreserveAspectRatio;
import thirdparty.com.lorentz.SVG.display.base.ISVGViewBox;
import thirdparty.com.lorentz.SVG.display.base.SVGContainer;

public class SVGSymbol extends SVGContainer implements ISVGViewBox, ISVGPreserveAspectRatio {
		public function SVGSymbol(){
			super("symbol");
		}
		
		public function get svgViewBox():Rectangle {
			return getAttribute("viewBox") as Rectangle;
		}
		public function set svgViewBox(value:Rectangle):void {
			setAttribute("viewBox", value);
		}
		
		public function get svgPreserveAspectRatio():String {
			return getAttribute("preserveAspectRatio") as String;
		}
		public function set svgPreserveAspectRatio(value:String):void {
			setAttribute("preserveAspectRatio", value);
		}
	}
}