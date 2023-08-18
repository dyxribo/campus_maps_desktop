package net.blaxstar.components {
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
  
  import net.blaxstar.colors.Style;
  
  /**
	 * ...
	 * @author Deron Decamp
	 */
	public class ProgressCircle extends Component {
		private const START_WIDTH:uint = 100;
		private const START_HEIGHT:uint = 100;
		private const STEP_DISTANCE:Number = 2 * Math.PI / 100.0;
		
		private var _radius:uint;
		private var _points:Vector.<Point>;
		private var _granularity:Number = 2 * Math.PI / 2;
		private var _track:Sprite;
		private var _trackFill:Sprite;
		private var _percentLoaded:Number;
		
		public function ProgressCircle(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0) {
			super(parent, xpos, ypos);
			
		}
		/** INTERFACE net.blaxstar.components.IComponent ===================== */ 
		
		/**
		 * initializes the component by adding all the children 
		 * and committing the visual changes to be written on the next frame.
		 * created to be overridden.
		 */
		override public function init():void {
			_radius = 10;
			_points = new Vector.<Point>();
			_width_ = START_WIDTH;
			_height_ = START_HEIGHT;
			_percentLoaded = 1;
			_track = new Sprite();
			_trackFill = new Sprite();
			
			super.init();
		}
		/**
		 * initializes and adds all required children of the component.
		 */
		override public function addChildren():void {
			addChildAt(_track, 0);
			addChildAt(_trackFill, 1);
			
			super.addChildren();
		}
		/**
		 * (re)draws the component and applies any pending visual changes.
		 */
		override public function draw(e:Event = null):void {
			drawTrack();
			drawTrackFill()
		}
		
		/** END INTERFACE ===================== */
		
		public function set progress(val:uint):void {
			_percentLoaded = val;
			draw();
		}
		
		public function get progress():uint {
			return  _percentLoaded;
		}
		
		private function drawTrack():void {
			_track.graphics.lineStyle(2, Style.SECONDARY_DARK.value, 1);
			
			for (var angle : Number = 0; angle < progress * STEP_DISTANCE; angle += _granularity) {
				var p:Point = new Point(_radius * Math.cos(angle), _radius * Math.sin(angle));
				_points.push(p);
			}
			
			for (var i:uint = 0; i < _points.length; i++ ) {
				_track.graphics.lineTo(_points[i].x, _points[i].y);
			}
			
		}
		
		private function drawTrackFill():void {
			_trackFill.graphics.lineStyle(2, Style.SECONDARY.value, 1);
			_trackFill.graphics.lineTo(_width_ * (_percentLoaded / 100), 0);
		}
	}

}