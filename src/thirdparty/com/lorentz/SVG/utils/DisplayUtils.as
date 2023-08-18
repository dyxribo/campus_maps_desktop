package thirdparty.com.lorentz.SVG.utils
{
import flash.display.DisplayObject;
import flash.geom.Rectangle;

import thirdparty.com.lorentz.SVG.display.base.SVGElement;

public class DisplayUtils
	{
		public static function safeGetBounds(target:DisplayObject, targetCoordinateSpace:DisplayObject):Rectangle {
			if(target.width == 0 || target.height == 0)
				return new Rectangle();
			
			return target.getBounds(targetCoordinateSpace);
		}
		
		public static function getSVGElement(object:DisplayObject):SVGElement {
			while(object != null && !(object is SVGElement))
				object = object.parent;
			
			return object as SVGElement;
		}
	}
}