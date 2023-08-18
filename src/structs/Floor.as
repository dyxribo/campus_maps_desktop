package structs {
  import debug.DebugDaemon;

  import flash.utils.Dictionary;

  import geom.Point;
  import structs.Location;

  public class Floor extends Location {

    static public var DIRECTORY:Map = new Map(String, String).literal([
          ['32OS_11F', '11F'],
          ['32OS_12F', '12F'],
          ['32OS_14F', '14F'],
          ['ISELIN_4F', '4F'],
          ['SF_43F', '43F']
        ]);

    private var _subsections:Map;
    private var _on_single_vlan:Boolean;

    public function Floor(id:String) {
      super();
      this.id = id;
      this._subsections = new Map(String, Subsection);
      this._on_single_vlan = this._subsections.size <= 1;
    }

    public function add_subsection(subsection:Subsection):Boolean {
      if (this._subsections.has(subsection.id)) {
        DebugDaemon.write_log("error adding subsection: cannot add a subsection that already exists.",
            DebugDaemon.WARN);
        return false;
      }
      else {
        this._subsections.put(subsection.id, subsection);
        if (this._subsections.size > 1) {
          this._on_single_vlan = false;
        }
        return true;
      }
    }

    public function remove_subsection(subsection_id:String):Boolean {
      if (!this._subsections.has(subsection_id)) {
        DebugDaemon.write_log("error removing subsection: the specified subsection does not exist.",
            DebugDaemon.WARN);
        return false;
      }
      else {
        this._subsections.toss(subsection_id);
        if (this._subsections.size < 2) {
          this._on_single_vlan = true;
        }
        return true;
      }
    }

    public function get_subsection(subsection:String):Subsection {
      if (!this._subsections.has(subsection)) {
        // TODO: subsection does not exist
        return undefined;
      }
      else {
        return this._subsections.pull(subsection) as Subsection;
      }
    }

    public function has_subsection(subsection_id:String):Boolean {
      return this._subsections.has(subsection_id);
    }

    public function get subsections():Map {
      return this._subsections;
    }

    public function set subsections(value:Map):void {
      this._subsections = value;
    }

    static public function read_json(json:Object):Floor {
      var floor:Floor = new Floor(json.id);

      for (var key:Object in json.subsections) {
        var current_subsection:Subsection = Subsection.read_json(json.subsections[key]);
        floor.subsections.put(key, current_subsection);
      }

      return floor;
    }

    override public function write_json():Object {
      var json:Object = super.write_json();
      var subsections_dict:Dictionary = _subsections.get_dictionary();

      json.subsections = {};
        for (var key:Object in subsections_dict) {
          json.subsections[key] = _subsections.pull(key).write_json();
        }

        return json;
      }

    }

  }