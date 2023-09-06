package structs {
  import geom.Point;
  import structs.AssignableItem;

  public class MappableMachine extends AssignableItem {

    private var _model_name:String = '';
    private var _mac_address:String = '';
    private var _ip_address:String = '';
    private var _connected_jack_id:String = '';

    public function MappableMachine() {
      super();
    }

    static public function read_json(json:Object):MappableMachine {
      var item:MappableMachine = new MappableMachine();
      item.id = json.id;
      item.type = json.type;
      item.position = Point.read_json(json.position);
      item.assignee = json.assignee;
      item.model_name = json.model_name;
      item.mac_address = json.mac_address;
      item.ip_address = json.ip_address;
      item.connected_jack_id = json.connected_jack_id;

      return item;
    }

    override public function write_json():Object {
      var json:Object;
      json = super.write_json();
      json.assignee = this.assignee;
      json.model_name = this.model_name;
      json.mac_address = this.mac_address;
      json.ip_address = this.ip_address;
      json.connected_jack_id = this.connected_jack_id;

      return json;
    }

    public function get model_name():String {
      return this._model_name;
    }

    public function set model_name(value:String):void {
      this._model_name = value;
    }

    public function get mac_address():String {
      return this._mac_address;
    }

    public function set mac_address(value:String):void {
      this._mac_address = value;
    }

    public function get ip_address():String {
      return this._ip_address;
    }

    public function set ip_address(value:String):void {
      this._ip_address = value;
    }

    public function get connected_jack_id():String {
      return this._connected_jack_id;
    }

    public function set connected_jack_id(value:String):void {
      this._connected_jack_id = value;
    }
  }
}