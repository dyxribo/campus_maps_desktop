package thirdparty.com.lorentz.SVG.display {
import flash.geom.Rectangle;

import thirdparty.com.lorentz.SVG.display.base.ISVGViewBox;
import thirdparty.com.lorentz.SVG.display.base.SVGContainer;

public class SVGMask extends SVGContainer implements ISVGViewBox {
		public function SVGMask(){
			super("mask");
		}
		
		public function get svgViewBox():Rectangle {
			return getAttribute("viewBox") as Rectangle;
		}
		public function set svgViewBox(value:Rectangle):void {
			setAttribute("viewBox", value);
		}
	}
}