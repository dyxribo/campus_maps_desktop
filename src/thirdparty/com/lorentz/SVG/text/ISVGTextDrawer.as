package thirdparty.com.lorentz.SVG.text
{
import thirdparty.com.lorentz.SVG.data.text.SVGDrawnText;
import thirdparty.com.lorentz.SVG.data.text.SVGTextToDraw;

public interface ISVGTextDrawer
	{
		function start():void;
		
		function drawText(data:SVGTextToDraw):SVGDrawnText;
		
		function end():void;
	}
}