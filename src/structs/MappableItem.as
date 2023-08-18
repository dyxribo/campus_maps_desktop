package structs {
  import geom.Point;
  import structs.Location;
  public class MappableItem {

    static public var item_lookup:Map;
    static public var ITEM_USER:uint = 0;
    static public var ITEM_WORKSTATION:uint = 1;
    static public var ITEM_DESK:uint = 2;
    static public var ITEM_PRINTER:uint = 3;
    static public var ITEM_WALL_JACK:uint = 4;
    static public var ITEM_WALL_PLATE:uint = 5;
    static public var ITEM_GENERIC:uint = 6;

    private var _id:String;
    private var _type:uint;
    private var _position:Point;

    public function MappableItem(id:String, type:uint, position:Point) {

      this._id = id;
      this._type = type;
      this._position = position ? position : new Point(0, 0);

      this.add_to_directory(this);
    }

    protected function add_to_directory(val:MappableItem):void {
      if (!MappableItem.item_lookup) {
        MappableItem.item_lookup = new Map(String, MappableItem);
      }

      MappableItem.item_lookup.put(val.id, val);
    }

    static public function read_json(json:Object):MappableItem {
      var item:MappableItem = new MappableItem(
          json.id, json.type, Point.read_json(json.position)
        );

      return item;
    }

    public function write_json():Object {
      return {
          id: this.id,
          type: this.type,
          location: this.position.write_json()
        };
    }

    public function get id():String {
      return this._id;
    }

    public function set id(value:String):void {
      this._id = value;
    }

    public function get type():uint {
      return this._type;
    }

    public function set type(value:uint):void {
      this._type = value;
    }

    public function get position():Point {
      return this._position;
    }

    public function set position(value:Point):void {
      this._position = value;
    }
  }

}
