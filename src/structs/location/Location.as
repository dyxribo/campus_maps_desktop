package structs.location {

    import geom.Point;

    import thirdparty.org.osflash.signals.Signal;
    import net.blaxstar.starlib.utils.StringUtil;
    import flash.display.Sprite;

    public class Location extends Signal {

        static public var directory:Array;
        static public var temp_assignments:uint = 0;

        protected var _id:String;
        protected var _position:Point;
        protected var _is_modified:Boolean;

        //public var current_subsection_id:String;
        //public var current_item_id:String;

        public function Location() {
            super();
            this._id ||= 'new_location' + Location.temp_assignments++;
            this._position ||= new Point(0, 0);
            //this.current_floor_id = '';
            //this.current_subsection_id = '';
            //this.current_item_id = '';

            if (!directory) {
                directory = [];
            }
            directory.push(id);
        }

        static public function read_json(json:Object):Location {
            var location:Location = new Location();
            location.id = json.id;
            location._position = Point.read_json(json.position);
            return location;
        }

        public function write_json():Object {
            return {"id": this.id,
                    "position": this._position.write_json()};
        }

        public function get id():String {
            return _id;
        }

        public function set id(value:String):void {
            if (this._id != value) {
                this._is_modified = true;
            }
            this._id = value;
        }

        public function get position():Point {
            return _position;
        }

        public function get x():int {
            return _position.x;
        }

        public function set x(value:int):void {
            if (_position.x != value) {
                _is_modified = true;
            }
            _position.x = value;
        }

        public function get y():int {
            return _position.y;
        }

        public function set y(value:int):void {
            if (_position.y != value) {
                _is_modified = true;
            }
            _position.y = value;
        }
    }
}
