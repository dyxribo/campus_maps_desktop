package thirdparty.com.lorentz.SVG.data.filters
{
import flash.filters.BitmapFilter;

import thirdparty.com.lorentz.SVG.utils.ICloneable;

public interface ISVGFilter extends ICloneable
	{
		function getFlashFilter():BitmapFilter;
	}
}