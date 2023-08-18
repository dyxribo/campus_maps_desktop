package structs {
  import flash.utils.Dictionary;

  import geom.Point;

  public class WallPlate extends MappableItem {
    static private var _plate_lookup:Map;

    private var _plates:Map;
    private var _jacks:Map;

    public function WallPlate(plate_id:String, position:Point) {
      super(plate_id, MappableItem.ITEM_WALL_PLATE, position);
      this._plates = new Map(String, WallPlate);
      this._jacks = new Map(String, WallJack);
    }

    static public function add_to_directory(val:WallPlate):void {
      if (!WallPlate._plate_lookup.has(val.id)) {
        WallPlate._plate_lookup = new Map(String, WallPlate);
      }
      WallPlate._plate_lookup.put(val.id, val);
    }

    static public function get_plate(plate_id:String):WallPlate {
      if (!WallPlate._plate_lookup || !WallPlate._plate_lookup.has(plate_id))
        return undefined;
      else {
        return WallPlate._plate_lookup.pull(plate_id) as WallPlate;
      }
    }

    public function add_plate(plate:WallPlate):Boolean {
      if (this._plates.has(plate.id)) {
        // TODO: error adding plate
        return false;
      }
      else {
        this._plates.put(plate.id, plate);
      }
      return true;
    }

    public function remove_plate(plate_id:String):Boolean {
      if (this._plates.has(plate_id)) {
        this._plates.toss(plate_id);
        return true;
      }
      else {
        // TODO: error removing plate
        return false;
      }
    }

    public function add_jack(jack:WallJack):Boolean {
      if (this._jacks.has(jack.id)) {
        // TODO: error adding jack
        return false;
      }
      else {
        this._jacks.put(jack.id, jack);
      }
      return true;
    }

    public function remove_jack(jack_id:String):Boolean {
      if (this._jacks.has(jack_id)) {
        this._jacks.toss(jack_id);
        return true;
      }
      else {
        // TODO: error removing jack
        return false;
      }
    }

    override public function write_json():Object {
      var json:Object = super.write_json();

      var jacks:Dictionary = _jacks.get_dictionary();

      for (var key:String in jacks) {
        json.jacks[key] = jacks[key];
      }

      return json;
    }

    static public function read_json(json:Object):WallPlate {
      var item:WallPlate = new WallPlate(
          json.id, Point.read_json(json.position)
        );

      return item;
    }
  }

}