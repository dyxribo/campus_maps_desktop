package structs {

  import geom.Point;

  import thirdparty.org.osflash.signals.Signal;

  public class Location extends Signal {
    
    static public var directory:Array;
    static public var temp_assignments:uint = 0;

    public var id:String;
    public var position:Point;
    public var current_floor_id:String;
    public var current_subsection_id:String;
    public var current_item_id:String;

    public function Location() {
      super();
      this.id = 'new_location' + Location.temp_assignments++;
      this.position = new Point(0, 0);
      this.current_floor_id = '';
      this.current_subsection_id = '';
      this.current_item_id = '';

      if (!directory) {
        directory = [];
      }
      directory.push(id);
    }

    static public function read_json(json:Object):Location {
      var location:Location = new Location();
      location.id = json.id;
      location.position = Point.read_json(json.position);
      return location;
    }

    public function write_json():Object {
      return {
          "id": this.id,
          "position": this.position.write_json()
        };
    }
  }
}