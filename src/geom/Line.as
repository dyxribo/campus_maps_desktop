package geom {
import geom.Point;

public class Line {
    private var point_a:
            Point;
    private var point_b:
            Point;

    public function Line(point_a
                                 :
                                 Point, point_b
                                 :
                                 Point
    ) {
        this.point_a = point_a;
        this.point_b = point_b;
    }

    public function get begin():Point {
        return this.point_a;
    }

    public function get end():Point {
        return this.point_b;
    }

    public function write_json
    ()
            :
    Object {
        return {
            point_a: this.point_a.write_json(),
            point_b: this.point_b.write_json()
        };
    }
}
}