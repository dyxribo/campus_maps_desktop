package geom {

  public class Polygon {

    private var _sides:Vector.<Line>;
    private var _uint_of_sides:uint;
    private var _origin_point:Point;

    public function Polygon(x:uint, y:uint) {

      this._sides = new Vector.<Line>();
      this._uint_of_sides = 0;
      this._origin_point = new Point(x, y);
    }

    public function add_side(side:Line):Boolean {
      if (this._sides.indexOf(side) > -1) {
        return false;
      }
      this._sides.push(side);
      ++this._uint_of_sides;
      return true;
    }

    public function remove_side(side:Line):Boolean {
      if (this._sides.indexOf(side) < 0) {
        return false;
      }
      this._sides.splice(this._sides.indexOf(side), 1);
      --this._uint_of_sides;
      return true;
    }

    public function move(x:uint, y:uint):void {
      this._origin_point.x = x;
      this._origin_point.y = y;
    }

    public function set_all(value:Array):void {
      for (var i:uint = 0; i < _sides.length; i++) {
        _sides.push(value[i]);
      }
      this._uint_of_sides = this._sides.length;
    }

    public function contains_point(point:Point):Boolean {
      var sides:Vector.<Line> = this._sides;
      var is_inside:Boolean = false;

      for (var i:uint = 0; i < sides.length; i++) {
        const point_a:Point = sides[i].begin;
        const point_b:Point = sides[i].end;

        const intersect:Boolean = ((point_a.y > point.y) !== (point_b.y > point.y))
          && (point.x < (point_b.x - point_a.x) * (point.y - point_a.y) / (point_b.y - point_a.y) + point_a.x);

        if (intersect)
          is_inside = !is_inside;
      }

      return is_inside;
    }

    public function get is_closed():Boolean {
      if (this._sides.length < 3) {
        return false;
      }

      for (var i:uint = 0; i < this._sides.length - 1; i++) {
        if (this._sides[i].end.x !== this._sides[i + 1].begin.x ||
            this._sides[i].end.y !== this._sides[i + 1].begin.y) {
          return false;
        }
      }

      var first_side:Line = this._sides[0];
      var last_side:Line = this._sides[this._uint_of_sides - 1];

      return first_side.begin.x === last_side.end.x && first_side.begin.y === last_side.end.y;
    }

    public function read_json(json:Object):Polygon {
      var polygon:Polygon = new Polygon(json.origin_point.x, json.origin_point.y);
      polygon.set_all(json.sides);
      polygon.move(json.origin_point.x, json.origin_point.y);

      return polygon;
    }

    public function write_json():Object {
      return {
          sides: this._sides,
          origin_point: this._origin_point.write_json()
        };
    }
  }

}
