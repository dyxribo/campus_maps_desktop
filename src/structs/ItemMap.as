package structs {
    import config.SaveData;

    import debug.DebugDaemon;

    import flash.display.Bitmap;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.NativeWindowBoundsEvent;
    import flash.filesystem.File;
    import flash.utils.Dictionary;

    import geom.Point;

    import net.blaxstar.starlib.components.ContextMenu;
    import net.blaxstar.starlib.components.ListItem;
    import net.blaxstar.starlib.io.URL;
    import net.blaxstar.starlib.io.XLoader;
    import net.blaxstar.starlib.utils.StringUtil;

    import thirdparty.com.greensock.TweenLite;
    import thirdparty.org.osflash.signals.Signal;
    import thirdparty.org.osflash.signals.natives.NativeSignal;

    /**
     * /// TODO: documentation
     */
    public class ItemMap extends Sprite {
        public static const SEARCH_DESK:uint = 0;
        public static const SEARCH_USER:uint = 1;
        public static const SEARCH_WORKSTATION:uint = 2;
        public static const SEARCH_PRINTER:uint = 3;
        public static const SEARCH_BUILDING:uint = 4;
        public static const SEARCH_FLOOR:uint = 5;
        public static const SEARCH_SUBSECTION:uint = 6;
        public static const SEARCH_GENERIC_LOCATION:uint = 7;
        public static const SEARCH_ALL:uint = 8;

        private const _LOCATION_LINK_PATTERN:RegExp = /^([a-zA-Z0-9]+)(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?$/;

        private const _ASSET_IMAGE_FOLDER:File = File.applicationDirectory.resolvePath("assets").resolvePath("img");

        private const _ZOOM_FACTOR:Number = 0.1;

        / * PRIVATE VAR * /
        private var _current_location:Building;
        private var _buildings:Map;
        private var _image_loader:XLoader;
        private var _current_map_image:Bitmap;
        private var _image_mask:Sprite;
        private var _image_container:Sprite;
        private var _image_size:Point;
        private var _pan_position:Point;
        private var _context_menu:ContextMenu;

        private var _on_context_menu_roll_out:NativeSignal;
        private var _on_context_menu_release_outside:NativeSignal;
        private var _on_context_menu_defocus:NativeSignal;
        private var _on_image_container_mouse_down:NativeSignal;
        private var _on_image_container_mouse_up:NativeSignal;
        private var _on_image_container_release_outside:NativeSignal;
        private var _on_image_container_scroll_wheel:NativeSignal;
        private var _on_image_container_right_click:NativeSignal;
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
            _image_loader = new XLoader();
            _current_location = new Building();
        }

        /**
         * /// TODO: documentation
         * @param location_id
         * @returns
         */
        public function set_location(location_link:String):void {
            var resolvable:Boolean = navigate_to(location_link);

            if (resolvable) {
                display_map(location_link);
            } else {
                DebugDaemon.write_log("cannot display map: the location link is not resolvable. got: %s", DebugDaemon.ERROR_GENERIC, location_link);
                return;
            }

        }

        /**
         * Searches the entire map's directory for a location using `query`.
         * @param query The search query.
         * @return `MappableItem vector` Search results as a vector of `MappableItem`s.
         */
        public function search(query:String, search_by:uint = SEARCH_ALL):Vector.<MappableItem> {
            var results:Vector.<MappableItem> = new Vector.<MappableItem>();

            // if the query is a direct link, then return the exact match.
            // otherwise, search everything and return what's found.
            var item_reference:MappableItem = test_path(query);
            if (item_reference) {
                // direct link
                results.push(item_reference);
            } else {
                // something else, respect search_by
                switch (search_by) {
                    case SEARCH_ALL:
                    default:
                        // query is not a direct link, so search by id
                        /**
                         * need to search:
                         * desk locations
                         * users
                         * workstations
                         * printers
                         * buildings
                         * floor id only
                         * subsection id only
                         * generic item id only
                         * */

                        var desk:MappableDesk = search_desks(query);
                        var user:MappableUser = search_users(query);
                        var workstation:MappableWorkstation;
                        var printer:MappablePrinter;
                        var bldg:Building;
                        var flr:Floor;
                        var sbsc:Subsection;
                        var gen_itm:MappableItem;

                        if (desk) {
                            results.push(desk)
                        }
                        if (user) {
                            results.push(user)
                        }
                        break;
                    case SEARCH_DESK:
                        desk = search_desks(query);
                        if (desk) {
                            results.push(desk)
                        }
                        break;
                    case SEARCH_USER:
                        user = search_users(query);
                        if (user) {
                            results.push(user);
                        }
                        break;
                    case SEARCH_WORKSTATION:
                        break;
                    case SEARCH_PRINTER:
                        break;
                    case SEARCH_BUILDING:
                        break;
                    case SEARCH_FLOOR:
                        break;
                    case SEARCH_SUBSECTION:
                        break;
                    case SEARCH_GENERIC_LOCATION:
                        break;
                }
            }

            /*
               // then look for approximate matches
               var approximate_matches:Array = findCloseTerms(query);

               if (approximate_matches.length === 1 && (approximate_matches[0] as String) === building.id) {
               // discard the matches if the only one is the exact match we should have found already
               approximate_matches = [];
               } else {
               // otherwise push all the matches to location_results
               for (var i:uint = 0; i < approximate_matches.length; i++) {
               location_results.push(approximate_matches[i]);
               }
               }
             */
            return results;
        }

        /**
         * Navigates the current location to the specified link.
         * @param location_link the location link to navigate to.
         * @return `Boolean`
         */
        public function navigate_to(location_link:String):Boolean {
            var navigable:Boolean = test_path(location_link);

            if (navigable) {
                // full path exists, no need for path checking methods
                var link_elements:Array = location_link.match(this._LOCATION_LINK_PATTERN);

                var building_id:String = link_elements[1];
                var floor_id:String = link_elements[2];
                var subsection_id:String = link_elements[3];
                var item_id:String = link_elements[4];

                _current_location.id = building_id;

                if (floor_id) {
                    var fl:Floor = get_floor(floor_id);
                    _current_location.floor_id = floor_id;
                }

                if (subsection_id) {
                    var ss:Subsection = fl.get_subsection(subsection_id);
                    _current_location.subsection_id = subsection_id;
                }

                if (item_id) {
                    _current_location.item_id = item_id;
                }

                return true;
            }
            // does not exist, throw error
            return false;
        }

        /**
         * Tests a direct location link for validity.
         * @param location_link the location link in the format `BLDG_FL_SS_ITM`.
         * @return `MappableItem | null`
         */
        public function test_path(location_link:String):MappableItem {
            var link_elements:Array = location_link.match(this._LOCATION_LINK_PATTERN);

            if (link_elements.length) {
                var building_id:String = link_elements[1] ? link_elements[1] : '';
                var floor_id:String = link_elements[2] ? link_elements[2] : '';
                var subsection_id:String = link_elements[3] ? link_elements[3] : '';
                var item_id:String = link_elements[4] ? link_elements[4] : '';

                if (!_buildings.has(building_id)) {
                    return null;
                } else {
                    var bldg:Building = _buildings.pull(building_id) as Building;
                    if (floor_id && bldg.has_floor(floor_id)) {
                        var fl:Floor = bldg.get_floor(floor_id);

                        if (subsection_id && fl.has_subsection(subsection_id)) {

                            var ss:Subsection = fl.get_subsection(subsection_id);

                            if (item_id && ss.has_item(item_id)) {
                                return ss.get_item(item_id);
                            } else {
                                return ss;
                            }
                        } else {
                            return fl;
                        }
                    } else {
                        return bldg;
                    }
                }
            }
            return null;
        }

        /**
         *
         * @param username the username to search for.
         * @return `MappableUser | null`
         */
        public function search_users(username:String):MappableUser {
            if (!MappableItem.user_lookup) {
                return null;
            }
            if (MappableItem.user_lookup.has(username)) {
                return (MappableItem.user_lookup.pull(username) as MappableUser);
            }
            return null;
        }

        public function search_desks(desk_id:String):MappableDesk {
            if (!MappableItem.desk_lookup) {
                return null;
            }
            if (MappableItem.desk_lookup.has(desk_id)) {
                return (MappableItem.desk_lookup.pull(desk_id) as MappableDesk);
            }
            return null;
        }

        /**
         * /// TODO: documentation
         * @returns
         */
        public function write_json():Object {
            var json:Object = {last_location:
                    {
                        "building": this._current_location.id,
                        "floor": this._current_location.floor_id,
                        "subsection": this._current_location.subsection_id,
                        "item": this._current_location.item_id,
                        "panned": false,
                        "pan_position": {
                            "x": 0,
                            "y": 0
                        }
                    },
                    buildings: {}};

            var buildings_dict:Dictionary = this._buildings.get_dictionary();
            for (var key:Object in buildings_dict) {
                json.buildings[key] = buildings_dict[key].write_json();
            }

            return json;
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
                if (!_current_map_image) {
                   _image_loader.ON_COMPLETE_GRAPHIC.add(read_json_pan);
                }
            }
        }

        private function read_json_pan(b:Bitmap):void {
          pan();
        }

        private function display_map(floor_link:String):void {

            var floor_map_png:File = _ASSET_IMAGE_FOLDER.resolvePath(_current_location.id).resolvePath(_current_location.floor_id + ".png");

            if (!floor_map_png.exists) {
                DebugDaemon.write_log("cannot display map: the floor map image does not exist: %s.\n" + "the file may be corrupted; try reinstalling.", DebugDaemon.ERROR_IO, floor_map_png.nativePath);
                return;

            } else {

                if (_current_map_image && _current_map_image.parent) {
                    _image_container.removeChild(_current_map_image);
                }

                // TODO: load png data into _current_map_image and display centered
                var img_req:URL = new URL(floor_map_png.nativePath);
                img_req.use_port = false;
                img_req.expected_data_type = URL.GRAPHICS;
                _image_loader.ON_COMPLETE_GRAPHIC.add(on_image);
                _image_loader.queue_files(img_req);
            }

        }

        private function findCloseTerms(query:String, maxDistance:int = 2):Array {
            var closeTerms:Array = [];
            for each (var term:String in["terms"]) {
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
        private function resolve_link(location_link:String):Building {
            var resolvable:Boolean = navigate_to(location_link);

            var link_elements:Array = location_link.match(this._LOCATION_LINK_PATTERN);

            if (link_elements.length) {
                var building_id:String = link_elements[1] ? link_elements[1] : '';
                var floor_id:String = link_elements[2] ? link_elements[2] : '';
                var subsection_id:String = link_elements[3] ? link_elements[3] : '';
                var item_id:String = link_elements[4] ? link_elements[4] : '';

                var location:Building = new Building();
                location.id = building_id;
                location.floor_id = floor_id;
                location.subsection_id = subsection_id;
                location.item_id = item_id;
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
            if (this.floor_in_building(this._current_location.floor_id)) {
                if (this._current_location.get_floor(this._current_location.floor_id).has_subsection(subsection_id)) {
                    return true;
                }
            }
            return false;
        }

        /**
         *
         */
        private function item_in_subsection(item_id:String):Boolean {
            if (this.subsection_in_floor(this._current_location.subsection_id)) {
                if (this._current_location.get_floor(this._current_location.floor_id).get_subsection(this.current_location.subsection_id).has_item(item_id)) {
                    return true;
                }
            }
            return false;
        }

        /**
         *
         */
        private function get_floor(floor_id:String):Floor {
            if (this.floor_in_building(floor_id)) {
                return this._current_location.get_floor(floor_id);
            }
            return null;
        }

        /**
         *
         */
        private function get_subsection(subsection_id:String):Subsection {
            if (this.subsection_in_floor(subsection_id)) {
                return this._current_location.get_floor(this.current_location.floor_id).get_subsection(subsection_id);
            }
            return null;
        }

        /**
         *
         */
        private function get_item(item_id:String):MappableItem {
            if (this.item_in_subsection(item_id)) {
                return this._current_location.get_floor(this.current_location.floor_id).get_subsection(this.current_location.subsection_id).get_item(item_id);
            }
            return null;
        }

        /**
         *
         */
        private function pan():Boolean {
            if (_current_location.position.equals(_pan_position)) {
                return false;
            }

            var center_x:Number = stage.stageWidth / 2;
            var center_y:Number = stage.stageHeight / 2;

            TweenLite.to(_image_container, 0.3, {x: center_x - _pan_position.x, y: center_y - _pan_position.y});

            return true;
        }

        /**
         *
         */
        private function add_image_container_listeners():void {
            _on_image_container_mouse_down ||= new NativeSignal(_image_container, MouseEvent.MOUSE_DOWN, MouseEvent);
            _on_image_container_mouse_up ||= new NativeSignal(_image_container, MouseEvent.MOUSE_UP, MouseEvent);
            _on_image_container_release_outside ||= new NativeSignal(_image_container, MouseEvent.RELEASE_OUTSIDE, MouseEvent);
            _on_image_container_right_click ||= new NativeSignal(_image_container, MouseEvent.RIGHT_CLICK, MouseEvent);
            _on_image_container_scroll_wheel ||= new NativeSignal(_image_container, MouseEvent.MOUSE_WHEEL, MouseEvent);
            _on_viewport_resize ||= new NativeSignal(stage.nativeWindow, NativeWindowBoundsEvent.RESIZE, NativeWindowBoundsEvent);

            _on_image_container_mouse_down.add(on_mouse_down);
            _on_image_container_right_click.add(on_right_click);
            _on_image_container_scroll_wheel.add(on_scroll_wheel);
            _on_viewport_resize.add(on_viewport_resize);
        }

        private function remove_image_container_mouse_listeners():void {
            _on_image_container_mouse_down.remove(on_mouse_down);
            _on_image_container_right_click.remove(on_right_click);
            _on_image_container_scroll_wheel.remove(on_scroll_wheel);
            _on_viewport_resize.remove(on_viewport_resize);
        }

        /**
         *
         */
        private function draw_image_mask():void {
            var g:Graphics = _image_mask.graphics;
            g.beginFill(0);
            g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            g.endFill();
        }

        // * GETTERS & SETTERS * //

        /**
         * /// TODO: documentation
         */
        public function get current_location():Building {
            return this._current_location;
        }

        // * DELEGATES * //

        private function on_image(loaded_image:Bitmap):void {

            if (!_image_mask) {
                _image_mask = new Sprite();
            }

            if (!_image_container) {
                _image_container = new Sprite();
                _context_menu = new ContextMenu();
                _context_menu.hide();

                // register contexts for context menu
                var context_map_general:Array = [Contexts.CONTEXT_MAP_GENERAL_ADD_ITEM,
                    Contexts.CONTEXT_MAP_GENERAL_CREATE_PATH];

                var context_map_item:Array = [Contexts.CONTEXT_MAP_ITEM_RENAME_ITEM,
                    Contexts.CONTEXT_MAP_ITEM_MOVE_ITEM,
                    Contexts.CONTEXT_MAP_ITEM_ARCHIVE_ITEM,
                    Contexts.CONTEXT_MAP_ITEM_DELETE_ITEM];

                _context_menu.add_context_array(context_map_general, Contexts.CONTEXT_MAP_GENERAL, on_context_click);

                _context_menu.add_context_array(context_map_item, Contexts.CONTEXT_MAP_ITEM, on_context_click);

                _context_menu.set_context(Contexts.CONTEXT_MAP_GENERAL);
            }

            _current_map_image = loaded_image;
            _image_container.addChild(_current_map_image);
            addChild(_image_container);
            addChild(_image_mask);
            _image_container.addChild(_context_menu);
            draw_image_mask();
            _image_container.mask = _image_mask;
            add_image_container_listeners();
        }

        private function on_mouse_down(e:MouseEvent):void {
            _on_image_container_mouse_down.remove(on_mouse_down);
            _on_image_container_mouse_up.add(on_mouse_up);
            _on_image_container_release_outside.add(on_mouse_up);
            _image_container.startDrag();

        }

        private function on_mouse_up(e:MouseEvent):void {
            _on_image_container_mouse_up.remove(on_mouse_up);
            _on_image_container_release_outside.remove(on_mouse_up);
            _on_image_container_mouse_down.add(on_mouse_down);
            _image_container.stopDrag();
        }

        private function on_right_click(e:MouseEvent):void {
            e.preventDefault();
            // TODO: display context menu with easy actions

            var mouse_point:Point = new Point(mouseX - _image_container.x, mouseY - _image_container.y);

            _context_menu.move(mouse_point.x, mouse_point.y);
            _context_menu.show();
            add_context_menu_listeners();
            remove_image_container_mouse_listeners();

            DebugDaemon.write_log("point pinged @ %s, %s", DebugDaemon.DEBUG, mouse_point.x, mouse_point.y);
        }

        private function add_context_menu_listeners():void {
            _on_context_menu_roll_out ||= new NativeSignal(_context_menu, MouseEvent.ROLL_OUT, MouseEvent);
            _on_context_menu_release_outside ||= new NativeSignal(_context_menu, MouseEvent.RELEASE_OUTSIDE, MouseEvent);
            _on_context_menu_defocus ||= new NativeSignal(stage, MouseEvent.CLICK, MouseEvent);

            _on_context_menu_roll_out.add(on_context_menu_roll_out);
            _on_context_menu_release_outside.add(on_context_menu_release_outside);
            _on_context_menu_defocus.add(on_context_menu_defocus);
        }

        private function remove_context_menu_listeners():void {
            _on_context_menu_roll_out.remove(on_context_menu_roll_out);
            _on_context_menu_release_outside.remove(on_context_menu_release_outside);
            _on_context_menu_defocus.remove(on_context_menu_defocus);
        }

        private function on_context_menu_roll_out(e:MouseEvent):void {
            _context_menu.clear_selection();
        }

        private function on_context_menu_release_outside(e:MouseEvent):void {
            remove_context_menu_listeners();
            _context_menu.hide(true);
            add_image_container_listeners();
        }

        private function on_context_menu_defocus(e:MouseEvent):void {
            if (e.currentTarget !== _context_menu) {
                _on_context_menu_defocus.remove(on_context_menu_defocus);
                remove_context_menu_listeners();
                _context_menu.hide(true)
                add_image_container_listeners();
            }
        }

        private function on_context_click(e:MouseEvent):void {
            var list_item:ListItem = (e.currentTarget as ListItem);
            switch (list_item.label) {
                case Contexts.CONTEXT_MAP_GENERAL_ADD_ITEM:
                    trace("item creation");
                    var location:MappableItem = new MappableItem();
                    location.position.x = _context_menu.x;
                    location.position.y = _context_menu.y;
                    break;
                case Contexts.CONTEXT_MAP_GENERAL_CREATE_PATH:
                    trace("path creation");
                    break;
                default:
                    break;
            }
            _context_menu.hide(true);
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
