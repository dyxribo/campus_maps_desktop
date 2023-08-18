package geom {
public class Point {
  public var x: uint;
  public var y: uint;

  public function Point(x:uint, y:uint) {
    this.x = x;
    this.y = y;
  }

  public function clone():Point {
    return new Point(this.x, this.y);
  }

  static public function read_json(json:Object):Point {
    var point:Point = new Point(json.x, json.y);
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

