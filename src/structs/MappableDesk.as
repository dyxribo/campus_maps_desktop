package structs {

  import geom.Point;
  import structs.AssignableItem;
  import structs.MappableItem;

  public class MappableDesk extends AssignableItem {
    static public var desk_lookup:Map;

    /**
     * TODO: there's not much justifying this class besides the fact that desk
     * locations are an integral concept for this project. maybe i can find some
     * relevant data that only desks have that will justify this. maybe store a
     * boolean value to check if a desk is an electronic standing desk?
     */
    public function MappableDesk(locationID:String, position:Point = null) {
      super(locationID, MappableItem.ITEM_DESK, position ? position : new Point(0, 0));
      desk_lookup = new Map(String, MappableDesk);
    }

    static public function add_to_directory(val:MappableDesk):void {
      if (!MappableDesk.desk_lookup) {
        MappableDesk.desk_lookup = new Map(String, MappableDesk);
      }
      MappableDesk.desk_lookup.put(val.id, val);
    }

    static public function read_json(json:Object):MappableDesk {
      var item:MappableDesk = new MappableDesk(
          json.id, Point.read_json(json.location)
        );
      item.assignee = json.assignee;

      return item;
    }
  }

}