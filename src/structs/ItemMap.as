package structs {
  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.utils.Dictionary;

  import geom.Point;

  import net.blaxstar.utils.StringUtil;

  import thirdparty.org.osflash.signals.ISlot;

  import thirdparty.org.osflash.signals.Signal;

  /**
   * /// TODO: documentation
   */
  public class ItemMap extends Sprite {
    private const _LOCATION_LINK_PATTERN:RegExp =
      /^([a-zA-Z0-9]+)_([a-zA-Z0-9]+)_([a-zA-Z0-9]+)_([a-zA-Z0-9]+)$/;

    private var _current_location:Building;
    private var _buildings:Map;
    private var _current_map_image:Bitmap;
    private var _image_container:Sprite;
    private var _image_size:Point;
    private var _pan_position:Point;
    private var _dispatcher:Signal;

    /**
     * /// TODO: constructor documentation
     * @param directory_data
     */
    public function ItemMap(directory_data:Object) {
      // TODO (deron.decamp@): savedata. need to save last location viewed and
      // load on app start. initially, this can be JSON; should change to
      // protobufs later for better performance.

      super();
      _buildings = new Map(String, Building);
      _dispatcher = new Signal(Building);
      read_json(directory_data);
    }

    /**
     * /// TODO: documentation
     * @param location_id
     * @returns
     */
    public function set_location(location_id:String):void {
      if (this._current_location.id == location_id) {
        return;
      }

      var matches:Building = this.match_format(location_id);
      var building_id:String = matches.id;
      var floor_id:String = matches.current_floor_id;
      var subsection_id:String = matches.current_subsection_id;
      var item_id:String = matches.current_item_id;

      if (this._buildings.has(building_id)) {
        this._current_location = this._buildings.pull(building_id) as Building;

        if (this.floor_in_building(floor_id)) {
          this._current_location.current_floor_id = floor_id;

          if (this.subsection_in_floor(subsection_id)) {
            this._current_location.current_subsection_id = subsection_id;

            if (this.item_in_subsection(item_id)) {
              this._current_location.current_item_id = item_id;
            }
            else {
              this._current_location.current_item_id = '';
            }
          }
          else {
            this._current_location.current_subsection_id = '';
          }
        }
        else {
          this._current_location.current_floor_id = '';
        }
        this.dispatch(this._current_location);
      }
    }

    /**
     * /// TODO: documentation
     * @param query
     */
    public function find_location(query:String):Vector.<Building> {
      var location_results:Vector.<Building> = new Vector.<Building>();

      // look for exact match first
      var matches:Building = this.match_format(query);
      var building:Building;

      if (this.building_exists(matches.id)) {
        building = this._buildings.pull(matches.id) as Building;

        if (this.floor_in_building(matches.current_floor_id)) {
          building.current_floor_id = matches.current_floor_id;

          if (this.subsection_in_floor(matches.current_subsection_id)) {
            building.current_subsection_id = matches.current_subsection_id;

            if (this.item_in_subsection(matches.current_item_id)) {
              building.current_item_id = matches.current_item_id;
            }
          }
        }
        location_results.push(building);
      }
      // then look for approximate matches
      var approximate_matches:Array = findCloseTerms(query, Location.directory);

      if (approximate_matches.length === 1 && (approximate_matches[0] as String) === building.id) {
        // discard the matches if the only one is the exact match we should have found already
        approximate_matches = [];
      }
      else {
        // otherwise push all the matches to location_results
        for (var i:uint = 0; i < approximate_matches.length; i++) {
          location_results.push(approximate_matches[i]);
        }
      }
      return location_results;
    }

    public function dispatch(...value_objects):void {
      _dispatcher.dispatch(value_objects);
    }

    public function add(listener:Function):ISlot {
      return _dispatcher.add(listener);
    }

    public function remove(listener:Function):ISlot {
      return _dispatcher.remove(listener);
    }

    public function removeAll():void {
      _dispatcher.removeAll();
    }

    private function findCloseTerms(query:String, terms:Array, maxDistance:int = 2):Array {
      var closeTerms:Array = [];
      for each (var term:String in terms) {
        if (StringUtil.levenshtein(query, term) <= maxDistance) {
          closeTerms.push(term);
        }
      }
      return closeTerms;
    }

    /**
     * /// TODO: documentation
     * @param search_string
     * @returns
     */
    private function match_format(search_string:String):Building {
      var matches:Array = search_string.match(this._LOCATION_LINK_PATTERN);
      if (matches) {
        var building_id:String = matches[1] ? matches[1] : '';
        var floor_id:String = matches[3] ? matches[3] : '';
        var subsection_id:String = matches[5] ? matches[5] : '';
        var item_id:String = matches[7] ? matches[7] : '';
        var location:Building = new Building(building_id);
        location.current_floor_id = floor_id;
        location.current_subsection_id = subsection_id;
        location.current_item_id = item_id;
        return location;
      }
      return new Building('');
    }

    /**
     * /// TODO: documentation
     * @param building_id
     * @returns
     */
    private function building_exists(building_id:String):Boolean {
      return this._buildings.has(building_id);
    }

    /**
     * checks if the floor with the provided id exists in the current building.
     * @param floor_id the floor id to search.
     * @returns true if the floor is found, false otherwise.
     */
    private function floor_in_building(floor_id:String):Boolean {
      if (this._current_location) {
        return this._current_location.has_floor(floor_id);
      }
      return false;
    }

    /**
     * /// TODO: documentation
     * @param subsection_id
     * @returns
     */
    private function subsection_in_floor(subsection_id:String):Boolean {
      if (this.floor_in_building(this._current_location.current_floor_id)) {
        if (
            this._current_location
            .get_floor(this._current_location.current_floor_id).has_subsection(subsection_id)
          ) {
          return true;
        }
      }
      return false;
    }

    private function item_in_subsection(item_id:String):Boolean {
      if (this.subsection_in_floor(this._current_location.current_subsection_id)) {
        if (
            this._current_location
            .get_floor(this._current_location.current_floor_id).get_subsection(this.current_location.current_subsection_id).has_item(item_id)
          ) {
          return true;
        }
      }
      return false;
    }

    private function get_floor(floor_id:String):Floor {
      if (this.floor_in_building(floor_id)) {
        return this._current_location.get_floor(floor_id);
      }
      return undefined;
    }

    private function get_subsection(subsection_id:String):Subsection {
      if (this.subsection_in_floor(subsection_id)) {
        return this._current_location.get_floor(this.current_location.current_floor_id)
          .get_subsection(subsection_id);
      }
      return undefined;
    }

    private function get_item(item_id:String):MappableItem {
      if (this.item_in_subsection(item_id)) {
        return this._current_location.get_floor(this.current_location.current_floor_id).
          get_subsection(this.current_location.current_subsection_id).get_item(item_id);
      }
      return undefined;
    }

    /**
     * /// TODO: documentation
     */
    public function get current_location():Building {
      return this._current_location;
    }

    /**
     * /// TODO: documentation
     * @param json
     */
    public function read_json(json:Object):void {

      for (var key:String in json.buildings) {
        var building_raw:Object = json.buildings[key];
        var building:Building = Building.read_json(building_raw);
        _buildings.put(building.id, building);
      }
      if (json.last_location) {
        set_location(json.last_location as String);
      }
      if (json.panned) {
        this._pan_position = Point.read_json(json.pan_position);
      }
    }

    /**
     * /// TODO: documentation
     * @returns
     */
    public function write_json():Object {
      var json:Object = {
          last_location:
          {
            "building": this._current_location.id,
            "floor": this._current_location.current_floor_id,
            "subsection": this._current_location.current_subsection_id,
            "item": this._current_location.current_item_id,
            "panned": false,
            "pan_position": {
              "x": 0,
              "y": 0
            }
          },
          buildings: {}
          };

        var buildings_dict:Dictionary = this._buildings.get_dictionary();
        for (var key:Object in buildings_dict) {
          json.buildings[key] = buildings_dict[key].write_json();
        }

        return json;
      }
    }

  }
