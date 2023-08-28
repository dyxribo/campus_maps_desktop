package structs {
  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.utils.Dictionary;
  import geom.Point;
  import net.blaxstar.utils.StringUtil;
  import thirdparty.org.osflash.signals.ISlot;
  import thirdparty.org.osflash.signals.Signal;
  import config.SaveData;
  import flash.filesystem.File;
  import debug.DebugDaemon;
  import net.blaxstar.io.XLoader;
  import net.blaxstar.io.URL;
  import thirdparty.com.greensock.TweenLite;
  import thirdparty.org.osflash.signals.natives.NativeSignal;
  import flash.events.MouseEvent;
  import flash.display.Graphics;
  import flash.events.NativeWindowBoundsEvent;

  /**
   * /// TODO: documentation
   */
    public class ItemMap extends Sprite {
    private const _LOCATION_LINK_PATTERN:RegExp =
      /^([a-zA-Z0-9]+)(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?$/;
    private const _ASSET_IMAGE_FOLDER:File =
    File.applicationDirectory.resolvePath("assets").resolvePath("img");
    private const _ZOOM_FACTOR:Number = 0.1;

    private var _current_location:Building;
    private var _buildings:Map;
    private var _image_loader:XLoader;
    private var _current_map_image:Bitmap;
    private var _image_mask:Sprite;
    private var _image_container:Sprite;
    private var _image_size:Point;
    private var _pan_position:Point;
    private var _dispatcher:Signal;
    private var _on_mouse_down:NativeSignal;
    private var _on_mouse_up:NativeSignal;
    private var _on_release_outside:NativeSignal;
    private var _on_scroll_wheel:NativeSignal;
    private var _on_right_click:NativeSignal;
    private var _on_viewport_resize:NativeSignal;

    /**
     * /// TODO: documentation
     * @param directory_data
     */
    public function ItemMap(savedata:SaveData) {
      // TODO | (deron.decamp@): savedata. need to save last location viewed and
      // TODO | load on app start.

      super();
      _buildings = new Map(String, Building);
      _dispatcher = new Signal(Building);

      _image_loader = new XLoader();

      // TODO| load default map graphic from savedata, otherwise load last
      // TODO| visited location via set_location.
      display_map("32OS_11F");
    }

    /**
     * /// TODO: documentation
     * @param location_id
     * @returns
     */
    public function set_location(location_link:String):void {
      if (this._current_location.id == location_link) {
        return;
      }

      var matches:Building = this.split_link_to_building(location_link);
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
      var matches:Building = this.split_link_to_building(query);
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

    private function display_map(floor_link:String):void {
      // maps should be all floors obviously,
      // so the floor id is what 'map_id' should be referencing.
      var target_location:Building = split_link_to_building(floor_link);

      if (!target_location ||
      !target_location.id ||
      !target_location.current_floor_id) {
        DebugDaemon.write_log(
          "cannot display map: the location link is malformed. got: %s",
          DebugDaemon.ERROR_GENERIC, floor_link);
          return;
      }

      // TODO: uncomment, this is just removed until i can create the mapdata
      /*
      if (!building_exists(target_location.id) ||
          !(_buildings.pull(target_location.id) as Building)
          .has_floor(target_location.current_floor_id)) {
          DebugDaemon.write_log(
          "cannot display map: the location referenced in the link does not " +
          "exist. got: %s", DebugDaemon.ERROR_GENERIC, floor_link);
      }*/

      var floor_map_png:File = _ASSET_IMAGE_FOLDER.resolvePath(
        target_location.id).resolvePath(target_location.current_floor_id + ".png");

      if (!floor_map_png.exists) {
        DebugDaemon.write_log(
          "cannot display map: the floor map image does not exist: %s.\n" +
          "the file may be corrupted; try reinstalling.",
          DebugDaemon.ERROR_IO, floor_map_png.nativePath);

          return;
      } else {

        if(_current_map_image && _current_map_image.parent) {
          removeChild(_current_map_image);
        }

        // TODO: load png data into _current_map_image and display centered
        var img_req:URL = new URL(floor_map_png.nativePath);
        img_req.use_port = false;
        img_req.expected_data_type = URL.GRAPHICS;

        var img_vec:Vector.<URL> = new Vector.<URL>();
        img_vec.push(img_req);

        _image_loader.ON_COMPLETE.add(on_image);
        _image_loader.queue_files(img_vec);
      }
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
    private function split_link_to_building(location_link:String):Building {
      var link_elements:Array = location_link.match(this._LOCATION_LINK_PATTERN);

      if (link_elements.length) {
        var building_id:String = link_elements[1] ? link_elements[1] : '';
        var floor_id:String = link_elements[2] ? link_elements[2] : '';
        var subsection_id:String = link_elements[3] ? link_elements[3] : '';
        var item_id:String = link_elements[4] ? link_elements[4] : '';
        var location:Building = new Building(building_id);
        location.current_floor_id = floor_id;
        location.current_subsection_id = subsection_id;
        location.current_item_id = item_id;
        return location;
      }

      return null;
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
      return null;
    }

    private function get_subsection(subsection_id:String):Subsection {
      if (this.subsection_in_floor(subsection_id)) {
        return this._current_location.get_floor(this.current_location.current_floor_id)
          .get_subsection(subsection_id);
      }
      return null;
    }

    private function get_item(item_id:String):MappableItem {
      if (this.item_in_subsection(item_id)) {
        return this._current_location.get_floor(this.current_location.current_floor_id).
          get_subsection(this.current_location.current_subsection_id).get_item(item_id);
      }
      return null;
    }

    private function pan():Boolean {
      if (_current_location.position.equals(_pan_position)) {
        return false;
      }
      TweenLite.to(_current_map_image, 0.3, {x: _pan_position.x});
      _current_map_image.x = -_pan_position.x;
      return true;
    }

    private function add_image_container_listeners():void {
      _on_mouse_down = new NativeSignal(_image_container, MouseEvent.MOUSE_DOWN, MouseEvent);
      _on_mouse_up = new NativeSignal(_image_container, MouseEvent.MOUSE_UP, MouseEvent);
      _on_release_outside = new NativeSignal(_image_container, MouseEvent.RELEASE_OUTSIDE, MouseEvent);
      _on_right_click = new NativeSignal(_image_container, MouseEvent.RIGHT_CLICK, MouseEvent);
      _on_scroll_wheel = new NativeSignal(_image_container, MouseEvent.MOUSE_WHEEL, MouseEvent);
      _on_viewport_resize = new NativeSignal(stage.nativeWindow,
      NativeWindowBoundsEvent.RESIZE, NativeWindowBoundsEvent);

      _on_mouse_down.add(on_mouse_down);
      _on_right_click.add(on_right_click);
      _on_scroll_wheel.add(on_scroll_wheel);
      _on_viewport_resize.add(on_viewport_resize);
    }

    private function draw_image_mask():void {
      var g:Graphics = _image_mask.graphics;
      g.beginFill(0);
      g.drawRect(0,0,stage.stageWidth, stage.stageHeight);
      g.endFill();
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
        pan();
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

    private function on_image(url:URL, data:Bitmap):void {
      if (!_image_mask) {
        _image_mask = new Sprite();
      }

      if (!_image_container) {
        _image_container = new Sprite();
      }

      _current_map_image = data as Bitmap;
      addChild(_image_container);
      _image_container.addChild(_current_map_image);
      addChild(_image_mask);
      draw_image_mask();
      _image_container.mask = _image_mask;

      add_image_container_listeners();
    }

    private function on_mouse_down(e:MouseEvent):void {
      _on_mouse_down.remove(on_mouse_down);
      _on_mouse_up.add(on_mouse_up);
      _on_release_outside.add(on_mouse_up);
      _image_container.startDrag();

    }

    private function on_mouse_up(e:MouseEvent):void {
      _on_mouse_up.remove(on_mouse_up);
      _on_release_outside.remove(on_mouse_up);
      _on_mouse_down.add(on_mouse_down);
      _image_container.stopDrag();
    }

    private function on_right_click(e:MouseEvent):void {
      // TODO: display context menu with easy actions
      e.preventDefault();
      DebugDaemon.write_log("point pinged @ %s, %s",
      DebugDaemon.DEBUG, mouseX - _image_container.x,
      mouseY - _image_container.y);
    }

    private function on_scroll_wheel(e:MouseEvent):void {
      // TODO: implement zoom
    }

    private function on_viewport_resize(e:NativeWindowBoundsEvent):void {
      _image_mask.width = stage.stageWidth;
      _image_mask.height = stage.stageHeight;
    }

  }

}
