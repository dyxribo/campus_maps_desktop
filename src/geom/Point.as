package geom {
    import flash.geom.Point;

    public class Point {
        private var _x:int;
        private var _y:int;

        public function Point(x:int, y:int) {
            this.x = x;
            this._y = y;
        }

        public function set(x:int, y:int):void {
            this.x = x;
            this._y = y;
        }

        public function copy(point:geom.Point):void {
            this.x = point.x;
            this._y = point._y;
        }

        public function to_native():flash.geom.Point {
            return new flash.geom.Point(this.x, this._y);
        }

        public function clone():geom.Point {
            return new geom.Point(this.x, this._y);
        }

        public function equals(point:geom.Point):Boolean {
            if (this.x == point.x && this._y == point._y) {
                return true;
            }
            return false;
        }

        static public function read_json(json:Object):geom.Point {
            var point:geom.Point = new geom.Point(json.x, json.y);
            return point;
        }

        public function write_json():Object {
            return {"x": this.x,
                    "y": this._y};
        }

        public function get x():int {
            return _x;
        }

        public function set x(value:int):void {
            _x = value;
        }

        public function get y():int {
            return _y;
        }

        public function set y(value:int):void {
            _y = value;
        }
    }

}

