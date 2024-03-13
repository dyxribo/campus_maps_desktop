package models {
    import geom.Point;

    public class MapSearchResult {
        static public const LOCATION:String = "location";
        static public const USER:String = "user";

        private var _label:String;
        private var _point:Point;
        private var _type:String;

        public function MapSearchResult(label:String, position:Point, type:String = "location") {
            _label = label;
            _point = position;
            _type = type;
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
