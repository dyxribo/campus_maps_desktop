package net.blaxstar.style
{
import flash.display.DisplayObjectContainer;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import thirdparty.org.osflash.signals.Signal;

/**
	 * ...
	 * @author Deron D. (SnaiLegacy)
	 * decamp.deron@gmail.com
	 */
	public class Style
	{
		// static
    static public const ON_THEME_UPDATE:Signal = new Signal();
		static public const LIGHT:uint = 0;
		static public const DARK:uint = 1;

		static public var CURRENT_THEME:uint = LIGHT;
		/*
		 * Color that appears most frequently across app screens and components.
		 */
		static public var PRIMARY:RGBA;
		/**
		 * Used for contrast between UI elements (primary color).
		 */
		static public var PRIMARY_LIGHT:RGBA;
		/**
		 * Used for contrast between UI elements (primary color).
		 */
		static public var PRIMARY_DARK:RGBA;
		/**
		 * Optional color that appears sparingly across app screens and components.
		 * Best used for components like floating action buttons, sliders, switches,
		 * highlighting selected text, progress bars, links, and headlines.
		 */
		static public var SECONDARY:RGBA;

		/**
		 * Used for contrast between UI elements (secondary).
		 */
		static public var SECONDARY_LIGHT:RGBA;
		/**
		 * Used for contrast between UI elements (secondary).
		 */
		static public var SECONDARY_DARK:RGBA;

		/**
		 * Color that is applied to the background of scrollable content.
		 */
		static public var BACKGROUND:RGBA;
		/**
		 * Color that is applied to surfaces of components, such as cards, sheets, and menus.
		 */
		static public var SURFACE:RGBA;
		/**
		 * Color that is applied to the surfaces of components in the "hover" state (usually buttons).
		 */
		static public var GLOW:RGBA;
		/**
		 * Color that is applied to components with errors to display.
		 */
		static public var ERROR:RGBA;
		/**
		 * Color that is applied to plain text.
		 */
		static public var TEXT:RGBA;

		static public function init(main:DisplayObjectContainer, theme:uint=Style.DARK):void
		{
			setTheme(theme);
			main.stage.color = BACKGROUND.value;
			main.stage.align = StageAlign.TOP_LEFT;
			main.stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		static public function setTheme(style:uint):void
		{
			switch (style)
			{
				case DARK:
					PRIMARY = Color.DARK_GREY;
					PRIMARY_LIGHT = PRIMARY.tint();
					PRIMARY_DARK = PRIMARY.shade();
					SECONDARY = Color.MAGENTA;
					SECONDARY_LIGHT = SECONDARY.tint();
					SECONDARY_DARK = SECONDARY.shade();
					BACKGROUND = PRIMARY;
					SURFACE = PRIMARY;
					GLOW = BACKGROUND.tint();
					ERROR = Color.PRODUCT_RED;
					TEXT = Color.EGGSHELL;
					CURRENT_THEME = DARK;
					break;
				case LIGHT:
				default:
					PRIMARY = Color.EGGSHELL;
					PRIMARY_LIGHT = PRIMARY.tint();
					PRIMARY_DARK = PRIMARY.shade();
					SECONDARY = Color.PRODUCT_BLUE;
					SECONDARY_LIGHT = SECONDARY.tint();
					SECONDARY_DARK = SECONDARY.shade();
					BACKGROUND = PRIMARY;
					SURFACE = Color.WHITE;
					GLOW = BACKGROUND.shade();
					ERROR = Color.PRODUCT_RED;
					TEXT = Color.DARK_GREY;
					CURRENT_THEME = LIGHT;
					break;
			}
      ON_THEME_UPDATE.dispatch();
		}
	}
}
