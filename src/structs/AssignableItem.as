package structs {
  import geom.Point;

  public class AssignableItem extends MappableItem {
    private var _assignee:String = '';

    public function AssignableItem(id:String, type:uint, position:Point) {
      super(id, type, position);
    }

    static public function read_json(json:Object):AssignableItem {
      var item:AssignableItem = new AssignableItem(
          json.id, json.type, Point.read_json(json.location)
        );
      item.assignee = json.assignee;

      return item;
    }

    override public function write_json():Object {
      var json:Object = super.write_json();
      json.assignee = this._assignee;

      return json;
    }

    public function get assignee():String {
      return this._assignee;
    }

    public function set assignee(username:String):void {
      this._assignee = username;
    }
  }

}
