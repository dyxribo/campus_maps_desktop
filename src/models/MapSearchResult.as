package models {
    import geom.Point;

    public class MapSearchResult {
        private var _label:String;
        private var _point:Point;

        public function MapSearchResult(label:String, position:Point) {
            _label = label;
            _point = position;
        }

        public function get label():String {
            return _label;
        }

        public function get position():Point {
            return _point;
        }
    }
}
