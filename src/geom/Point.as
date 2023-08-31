package geom {
import flash.geom.Point;

public class Point {
  public var x: uint;
  public var y: uint;

  public function Point(x:uint, y:uint) {
    this.x = x;
    this.y = y;
  }

  public function from_native(native_point:flash.geom.Point):geom.Point {
    this.x = native_point.x;
    this.y = native_point.y;
    return this;
  }

  public function to_native():flash.geom.Point {
    return new flash.geom.Point(this.x, this.y);
  }
  public function clone():geom.Point {
    return new geom.Point(this.x, this.y);
  }

  public function equals(point:geom.Point):Boolean {
    if (this.x == point.x && this.y == point.y) {
      return true;
    }
    return false;
  }

  static public function read_json(json:Object):geom.Point {
    var point:geom.Point = new geom.Point(json.x, json.y);
    return point;
  }

  public function write_json():Object {
    return {
      "x": this.x,
      "y": this.y
    };
  }
}

}

