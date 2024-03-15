package models {
    import geom.Point;

    public class MapSearchResult {
        static public const LOCATION:String = "location";
        static public const USER:String = "user";

        private var _label:String;
        private var _point:Point;
        private var _type:String;
        private var _data:Object;

        public function MapSearchResult(label:String, position:Point, type:String = "location", data:Object=null) {
            _label = label;
            _point = position;
            _type = type;
            _data = data;
        }

        public function get data():Object {
          return _data;
        }

        public function get label():String {
            return _label;
        }

        public function get position():Point {
            return _point;
        }

        public function get type():String {
            return _type;
        }
    }
}
