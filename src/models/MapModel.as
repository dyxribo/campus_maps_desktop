package models {
    import app.interfaces.IMapImageLoaderObserver;
    import app.interfaces.IObserver;
    import app.interfaces.ISubject;

    import config.SaveData;

    import flash.display.Bitmap;
    import flash.filesystem.File;
    import flash.utils.Dictionary;

    import geom.Point;

    import modules.Pin;

    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.utils.StringUtil;

    import structs.Map;
    import structs.location.Building;
    import structs.location.Floor;
    import structs.location.MappableDesk;
    import structs.location.MappableItem;
    import structs.location.MappablePrinter;
    import structs.location.MappableUser;
    import structs.location.MappableWorkstation;
    import structs.location.Subsection;

    import thirdparty.org.osflash.signals.Signal;

    /**
     * TODO: CLASS DOCUMENTATION
     */
    public class MapModel implements ISubject, IMapImageLoaderObserver {
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
        private const _PATH_RESOLUTION_INDEX:Array = [5];
        private const _OBSERVER_LIST:Vector.<IObserver> = new Vector.<IObserver>();

        public const ASSET_IMAGE_FOLDER:File = File.applicationDirectory.resolvePath("assets").resolvePath("img");

        private var _observer_index_lookup:Dictionary;
        private var _previous_session_location_link:String;
        private var _current_location:Building;
        private var _buildings:Map;
        private var _current_map_image:Bitmap;
        private var _bitmap_data_cache:Dictionary;
        private var _image_size:Point;
        private var _pan_position:Point;

        public var on_image_load_request:Signal;
        public var on_json_read_in:Signal;

        /**
         *
         */
        public function MapModel() {
            _observer_index_lookup = new Dictionary();
            on_image_load_request = new Signal();
            _bitmap_data_cache = new Dictionary();

            // TODO (deron.decamp@): savedata. need to save last location viewed and load on model init
        }

        /**
         *
         * @param json
         */
        public function read_json(json:Object):void {
            // if there is a current location, then data is already loaded into the app. reset the values in memory and prepare the variables to be written again
            if (_current_location) {
                _buildings.iterate(function destroy_all(key:String, item:Building):void {
                    item.destroy();
                    delete _buildings[key];
                });

                MappableItem.destroy_lookups();
            } else {
                _buildings = new Map(String, Building);
            }

            for (var key:String in json.buildings) {
                var building_raw:Object = json.buildings[key];
                var building:Building = Building.read_json(building_raw);
                _buildings.put(building.id, building);
            }

            if (json.last_location) {
                _previous_session_location_link = json.last_location;
            } else {
                _previous_session_location_link = json.default_location;
            }

            set_location(_previous_session_location_link);
            this.on_image_load_request.dispatch();
        }


        private function on_map_image_load(b:Bitmap):void {
            current_map_image = b;
            MappableItem.pin_lookup.forEach(function(current_pin:Pin, index:uint, arr:Vector.<Pin>):void {
                notify_observers({'new_pin': current_pin});
            });
        }

        /**
         * Tests a direct location link for validity.
         * @param location_link the location link in the format `BLDG_FL_SS_ITM`.
         * @return `MappableItem | null`
         */
        public function get_location(location_link:String):MappableItem {
            var link_elements:Array = location_link.match(this._LOCATION_LINK_PATTERN);

            if (link_elements && link_elements.length) {
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
         * @param location_id
         * @returns
         */
        public function set_location(location_link:String):void {
            var resolvable:Boolean = test_path(location_link);
            var notification_data:Object = {};

            if (resolvable) {
                // the building and floor have to be resolvable via regex matches to make it here, so we can just assume the matches work
                var link_elements:Array = location_link.match(this._LOCATION_LINK_PATTERN);

                _current_location = _buildings.pull(link_elements[1]) as Building;
                _current_location.floor_id = link_elements[2];

                // nothing after floor is guaranteed, since technically a floor link is valid. so now we just double check for subsections and general mappable items
                if (_PATH_RESOLUTION_INDEX[2] == 1) {
                    // subsection is resolvable, so add that sucker in there
                    _current_location.subsection_id = link_elements[3];
                    _pan_position.copy(_current_location.current_subsection.get_registration_point());
                    notification_data['pan_position'] = _pan_position;
                }

                if (_PATH_RESOLUTION_INDEX[3] == 1) {
                    // this link is resolvable down to the item level! how nice!
                    _current_location.item_id = link_elements[4];
                    _pan_position.copy(_current_location.current_item.position);
                    notification_data['pan_position'] = pan_position;
                }

                notification_data['current_location'] = current_location;
                notify_observers(notification_data);
            } else {
                DebugDaemon.write_error("cannot display map: the location link is not resolvable. got: %s", location_link);
                return;
            }
        }

        /**
         * Navigates the current location to the specified link.
         * @param location_link the location link to navigate to.
         * @return `Boolean`
         */
        public function test_path(location_link:String):Boolean {
            var navigable:Boolean = get_location(location_link);

            var link_elements:Array = location_link.match(this._LOCATION_LINK_PATTERN);

            // if the link matches the proper format, lets break it down and double check
            if (link_elements.length) {
                var building_id:String = link_elements[1] ? link_elements[1] : '';
                var floor_id:String = link_elements[2] ? link_elements[2] : '';
                var subsection_id:String = link_elements[3] ? link_elements[3] : '';
                var item_id:String = link_elements[4] ? link_elements[4] : '';

                // at minimum, we need a building and a floor, since we can't display anything less than a floor map
                if (!_buildings.has(building_id)) {
                    return null;
                } else {
                    var bldg:Building = _buildings.pull(building_id) as Building;
                    // if the link is looking for a floor, and the floor id is valid...
                    if (floor_id && bldg.has_floor(floor_id)) {
                        var fl:Floor = bldg.get_floor(floor_id);
                        // ...and the floor has a subsection and the subsection id is valid...
                        if (subsection_id && fl.has_subsection(subsection_id)) {
                            var ss:Subsection = fl.get_subsection(subsection_id);
                            // and the subsection has an item and the item id is valid...
                            if (item_id && ss.has_item(item_id)) {
                                // then the link is fully resolvable!
                                set_resolution_index(1, 1, 1, 1);
                                return true;
                            } else {
                                // otherwise, the link is resolvable up to the subsection at least!
                                set_resolution_index(1, 1, 1, 0);
                                return true;
                            }
                        } else {
                            // otherwise, the link is resolvable up to the floor at least!
                            set_resolution_index(1, 1, 0, 0);
                            return true;
                        }
                    } else {
                        // otherwise, the building is resolvable, but that's not enough :(
                        set_resolution_index(1, 0, 0, 0);
                        return false;
                    }
                }
            }
            // otherwise we have nothing. all is lost.
            set_resolution_index(0, 0, 0, 0);
            return false;
        }

        /**
         * sets integers which denote the degree of success from the last `test_path()` call.
         * @param building
         * @param floor
         * @param subsection
         * @param item
         */
        private function set_resolution_index(building:int, floor:int, subsection:int, item:int):void {
            _PATH_RESOLUTION_INDEX[0] = building;
            _PATH_RESOLUTION_INDEX[1] = floor;
            _PATH_RESOLUTION_INDEX[2] = subsection;
            _PATH_RESOLUTION_INDEX[3] = item;
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
            var item_reference:MappableItem = get_location(query);
            if (item_reference) {
                // direct link
                results.push(item_reference);
            } else {
                // something else, respect search_by
                switch (search_by) {
                    case SEARCH_ALL:
                    default:
                        // query is prob not a direct link, so search by id
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
                            results.push(user);
                            var user_desks:Array = user.desks;
                            // skip desk enumeration if no desks are present
                            if (user_desks && user_desks.length) {
                                for (var i:int = 0; i < user_desks.length; i++) {
                                    var current_desk:MappableDesk = MappableItem.desk_lookup.pull(user_desks[i]) as MappableDesk;
                                    results.push(current_desk);
                                }
                            }


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
               then look for approximate matches
               var approximate_matches:Array = findCloseTerms(query);

               if (approximate_matches.length === 1 && (approximate_matches[0] as String) === building.id) {
               discard the matches if the only one is the exact match we should have found already
               approximate_matches = [];
               } else {
               otherwise push all the matches to location_results
               for (var i:uint = 0; i < approximate_matches.length; i++) {
               location_results.push(approximate_matches[i]);
               }
               }
             */
            return results;
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

        private function find_close_terms(query:String, maxDistance:int = 2):Array {
            var closeTerms:Array = [];
            for each (var item_id:String in MappableItem.item_lookup) {
                if (StringUtil.levenshtein(query, item_id) <= maxDistance) {
                    closeTerms.push(item_id);
                }
            }

            for each (var desk_id:String in MappableItem.desk_lookup) {
                if (StringUtil.levenshtein(query, desk_id) <= maxDistance) {
                    closeTerms.push(desk_id);
                }
            }

            return closeTerms;
        }

        /**
         *
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
         *
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
         * @return all buildings and child objects in json format.
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

        public function register_observer(observer:IObserver):void {
            // cache the position of the observer in the list for quick removals
            _observer_index_lookup[observer] = _OBSERVER_LIST.push(observer) - 1;
        }

        public function unregister_observer(observer:IObserver):void {
            // instead of splicing, copy last element of array to delete index, then pop the last element off. much faster that way
            _OBSERVER_LIST[_observer_index_lookup[observer]] = _OBSERVER_LIST[_OBSERVER_LIST.length - 1];
            _OBSERVER_LIST.pop();
        }

        public function notify_observers(data:Object):void {
            // reverse loop for maximum speed
            for (var i:int = _OBSERVER_LIST.length - 1; i > -1; i--) {
                _OBSERVER_LIST[i].update(data);
            }
        }

        public function update(data:Object):void {
            if (data.hasOwnProperty('on_map_image_load')) {
                on_map_image_load(data['on_map_image_load'] as Bitmap);
            }
        }

        public function get current_location():Building {
            return _current_location;
        }

        public function set current_location(value:Building):void {
            _current_location = value;
            notify_observers({'current_location': value});
        }

        public function get buildings():Map {
            return _buildings;
        }

        public function set buildings(value:Map):void {
            _buildings = value;
            notify_observers({'buildings': value});
        }

        public function get current_map_image():Bitmap {
            return _current_map_image;
        }

        public function set current_map_image(value:Bitmap):void {
            _current_map_image = value;
            notify_observers({'current_map_image': value});
        }

        public function get bitmap_data_cache():Dictionary {
            return _bitmap_data_cache;
        }

        public function set bitmap_data_cache(value:Dictionary):void {
            _bitmap_data_cache = value;
            notify_observers({'bitmap_data_cache': value});
        }

        public function get image_size():Point {
            return _image_size;
        }

        public function set image_size(value:Point):void {
            _image_size = value;
            notify_observers({'image_size': value});
        }

        public function get pan_position():Point {
            return _pan_position;
        }

        public function set pan_position(value:Point):void {
            _pan_position = value;
            notify_observers({'pan_position': value});
        }

    }
}
