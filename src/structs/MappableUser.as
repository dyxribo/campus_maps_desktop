package structs {
  import debug.DebugDaemon;

  import geom.Point;
  import structs.MappableItem;

  public class MappableUser extends MappableItem {
    static public var user_lookup:Map;
    private var _username:String;
    private var _email:String;
    private var _phone:String;
    // start_time: uint, end_time: uint, time_zone: String
    private var _work_hours:Object;
    private var _desks:Vector.<String>;
    private var _assets:Vector.<String>;
    // TODO: user photos?

    public function MappableUser(id:String, position:Point) {
      super(id, MappableItem.ITEM_USER, position);
      user_lookup = new Map(String, MappableUser);

      this._username = '';
      this._email = '';
      this._phone = '';
      this._work_hours = {start_time: 0, end_time: 0, time_zone: ""};
      this._desks = new Vector.<String>();
      this._assets = new Vector.<String>();

      this.add_to_directory(this);
    }

    public function add_desk(desk_id:String):Boolean {
      if (this._desks.indexOf(desk_id) > -1) {
        DebugDaemon.write_log("error adding desk: the referenced desk already exists for this user.",
            DebugDaemon.WARN);
        return false;
      }
      else {
        this._desks.push(desk_id);
      }
      return true;
    }

    public function add_asset(item_id:String):Boolean {
      if (this._assets.indexOf(item_id) > -1) {
        // TODO: error cannot add asset
        DebugDaemon.write_log("error adding asset: the referenced asset already exists for this user.",
            DebugDaemon.WARN);
        return false;
      }
      else {
        this._assets.push(item_id);
      }
      return true;
    }

    static public function add_to_directory(val:MappableUser):void {
      if (!MappableUser.user_lookup) {
        MappableUser.user_lookup = new Map(String, MappableUser);
      }
      MappableUser.user_lookup.put(val.id, val);
    }

    static public function read_json(json:Object):MappableUser {
      var item:MappableUser = new MappableUser(
          json.id, Point.read_json(json.position)
        );
      item.username = json.username;
      item.email = json.email;
      item.phone = json.phone;
      item.work_hours = json.work_hours;
      item.desks = json.desks;
      item.assets = json.assets;

      return item;
    }

    override public function write_json():Object {
      var json:Object = super.write_json();

      json.username = this.username;
      json.email = this.email;
      json.phone = this.phone;
      json.work_hours = this.work_hours;

      for (var i:uint = 0; i < _desks.length; i++) {
        json.desks[_desks[i]] = _desks[i];
      }

      for (var j:uint = 0; j < _assets.length; j++) {
        json.assets[_assets[i]] = _assets[i];
      }
      return json;
    }

    public function get username():String {
      return this._username;
    }

    public function set username(value:String):void {
      this._username = value;
    }

    public function get email():String {
      return this._email;
    }

    public function set email(value:String):void {
      this._email = value;
    }

    public function get phone():String {
      return this._phone;
    }

    public function set phone(value:String):void {
      this._phone = value;
    }

    public function get work_hours():Object {
      return this._work_hours;
    }

    public function set work_hours(value:Object):void {
      this._work_hours = value;
    }

    public function get desks():Vector.<String> {
      return this._desks;
    }

    public function set desks(value:Vector.<String>):void {
      this._desks = value;
    }

    public function get assets():Vector.<String> {
      return this._assets;
    }

    public function set assets(value:Vector.<String>):void {
      this._assets = value;
    }
  }

}