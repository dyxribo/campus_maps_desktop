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
    import structs.location.Region;

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
        private const _LOCATION_LINK_PATTERN:RegExp = /^([a-zA-Z0-9]+)(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?$/;
        private const _PATH_RESOLUTION_TABLE:Array = [6];
        private const _PATH_RESOLUTION_CACHE:Array = [6];
        private const _OBSERVER_LIST:Vector.<IObserver> = new Vector.<IObserver>();

        public const ASSET_IMAGE_FOLDER:File = File.applicationDirectory.resolvePath("assets").resolvePath("img");

        private var _observer_index_lookup:Dictionary;
        private var _resolution_index:int;
        private var _previous_session_location_link:String;
        private var _current_location:Region;
        private var _regions:Map;
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
                _regions.iterate(function destroy_all(key:String, item:Region):void {
                    item.destroy();
                    delete _regions[key];
                });

                MappableItem.destroy_lookups();
            } else {
                _regions = new Map(String, Region);
            }

            for (var key:String in json.regions) {
                var region_literal:Object = json.regions[key];
                var region:Region = Region.read_json(region_literal);
                _regions.put(region.id, region);
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
         *
         * @param location_id
         * @returns
         */
        public function set_location(location_link:String):void {
            var resolvable:Boolean = test_path(location_link);
            var notification_data:Object = {};

            if (resolvable) {
                // the path_resultion_cache array was recently updated by the test_path call, so the index values will be defined
                _current_location = _PATH_RESOLUTION_CACHE[0] as Region;
                _pan_position ||= new Point(0, 0);
                // nothing after region is guaranteed, so now we just double check for building, floor, subsections and general mappable items
                if (_PATH_RESOLUTION_TABLE[1] == 1) {
                    // set the building since its resolvable
                    var matched_building:Building = _PATH_RESOLUTION_CACHE[1];
                    _current_location.building_id = matched_building.id;
                    _pan_position.set(matched_building.x, matched_building.y);
                }

                if (_PATH_RESOLUTION_TABLE[2] == 1) {
                    // set the floor since its resolvable
                    var matched_floor:Floor = _PATH_RESOLUTION_CACHE[2];
                    _current_location.floor_id = matched_floor.id;
                    _pan_position.set(matched_floor.x, matched_floor.y);
                }

                if (_PATH_RESOLUTION_TABLE[3] == 1) {
                    // subsection is resolvable, so add that sucker in there
                    var matched_subsection:Subsection = _PATH_RESOLUTION_CACHE[3];
                    _current_location.subsection_id = matched_subsection.id;
                    _pan_position.set(matched_subsection.x, matched_subsection.y);
                }

                if (_PATH_RESOLUTION_TABLE[4] == 1) {
                    // this link is resolvable down to the item level! how nice!
                    var matched_item:MappableItem = _PATH_RESOLUTION_CACHE[4];
                    _current_location.item_id = matched_item.id;
                    _pan_position.set(matched_item.x, matched_item.y);

                }
                // set the notification data and dispatch
                notification_data['pan_position'] = pan_position;
                notification_data['current_location'] = current_location;
                notify_observers(notification_data);
            } else {
                DebugDaemon.write_debug("cannot display map: the location link is not resolvable. got: %s", location_link);
                return;
            }
        }

        /**
         * Navigates the current location to the specified link.
         * @param location_link the location link to navigate to.
         * @return `Boolean`
         */
        public function test_path(location_link:String):Boolean {

            var link_elements:Array = location_link.match(this._LOCATION_LINK_PATTERN);

            // if the link matches the proper format, lets break it down and double check
            if (link_elements.length) {
                // the first element is the original string, so skip index 0
                var region_id:String = link_elements[1] ? link_elements[1] : '';
                var building_id:String = link_elements[2] ? link_elements[2] : '';
                var floor_id:String = link_elements[3] ? link_elements[3] : '';
                var subsection_id:String = link_elements[4] ? link_elements[4] : '';
                var item_id:String = link_elements[5] ? link_elements[5] : '';

                if (!_regions.has(region_id)) {
                    return null;
                } else {
                    var matched_region:Region = _regions.pull(region_id) as Region;
                    // if the building id is valid (building exists in this region)...
                    if (building_id && matched_region.has_building(building_id)) {
                        var matched_building:Building = matched_region.get_building(building_id) as Building;
                        // ...and the floor id is valid...
                        if (floor_id && matched_building.has_floor(floor_id)) {
                            var matched_floor:Floor = matched_building.get_floor(floor_id);
                            // ...and the subsection id is valid...
                            if (subsection_id && matched_floor.has_subsection(subsection_id)) {
                                var matched_subsection:Subsection = matched_floor.get_subsection(subsection_id);
                                // and item id is valid...
                                if (item_id && matched_subsection.has_item(item_id)) {
                                    // then the link is fully resolvable!
                                    var matched_item:MappableItem = matched_subsection.get_item(item_id);

                                    set_resolution_index(1, 1, 1, 1, 1);
                                    set_resolution_cache(matched_region, matched_building, matched_floor, matched_subsection, matched_item);
                                    return true;
                                } else {
                                    // otherwise, the link is resolvable up to the subsection at least!
                                    set_resolution_index(1, 1, 1, 1);
                                    set_resolution_cache(matched_region, matched_building, matched_floor, matched_subsection);
                                    return true;
                                }
                            } else {
                                // otherwise, the link is resolvable up to the floor at least!
                                set_resolution_index(1, 1, 1);
                                set_resolution_cache(matched_region, matched_building, matched_floor);
                                return true;
                            }
                        } else {
                            // otherwise, the link is resolvable up to the building at least!
                            set_resolution_index(1, 1);
                            set_resolution_cache(matched_region, matched_building);
                            return true;
                        }
                    } else {
                        // otherwise, the link is resolvable only up to the region
                        set_resolution_index(1);
                        set_resolution_cache(matched_region);
                        return true;
                    }
                }
            }
            // otherwise we have nothing. all is lost.
            set_resolution_index();
            set_resolution_cache();
            return false;
        }

        /**
         * caches the located map items from the last `test_path()` call.
         * @param building
         * @param floor
         * @param subsection
         * @param item
         */
        private function set_resolution_cache(region:Region = null, building:Building = null, floor:Floor = null, subsection:Subsection = null, item:MappableItem = null):void {
            _PATH_RESOLUTION_CACHE[0] = region;
            _PATH_RESOLUTION_CACHE[1] = building;
            _PATH_RESOLUTION_CACHE[2] = floor;
            _PATH_RESOLUTION_CACHE[3] = subsection;
            _PATH_RESOLUTION_CACHE[4] = item;
        }

        /**
         * sets integers which denote the degree of success from the last `test_path()` call.
         * @param building
         * @param floor
         * @param subsection
         * @param item
         */
        private function set_resolution_index(region:int = 0, building:int = 0, floor:int = 0, subsection:int = 0, item:int = 0):void {
            _PATH_RESOLUTION_TABLE[0] = region;
            _PATH_RESOLUTION_TABLE[1] = building;
            _PATH_RESOLUTION_TABLE[2] = floor;
            _PATH_RESOLUTION_TABLE[3] = subsection;
            _PATH_RESOLUTION_TABLE[4] = item;
            _resolution_index = region + building + floor + subsection + item;
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
            var link_resolvable:Boolean = test_path(query);

            var item_reference:MappableItem;
            if (link_resolvable) {
                // push result based on the level of resolvability defined from `test_path()`
                if (_resolution_index == 1) {
                    item_reference = _PATH_RESOLUTION_CACHE[0];
                } else if (_resolution_index == 2) {
                    item_reference = _PATH_RESOLUTION_CACHE[1];
                } else if (_resolution_index == 3) {
                    item_reference = _PATH_RESOLUTION_CACHE[2];
                } else if (_resolution_index == 4) {
                    item_reference = _PATH_RESOLUTION_CACHE[3];
                } else if (_resolution_index == 5) {
                    item_reference = _PATH_RESOLUTION_CACHE[4];
                } else {
                    return results;
                }
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
               var approximate_matches:Array = find_close_terms(query);

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
            MappableItem.item_lookup.iterate(function():void {
                if (StringUtil.levenshtein(query, item_id) <= maxDistance) {
                    closeTerms.push(item_id);
                }
            })
            for each (var item_id:String in MappableItem.item_lookup) {

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
         * @param region_id
         * @returns
         */
        private function region_exists(region_id:String):Boolean {
            return this._regions.has(region_id);
        }

        /**
         * checks if the building with the provided id exists in the current region.
         * @param building_id the building id to search.
         * @returns true if the building is found, false otherwise.
         */
        private function building_in_region(building_id:String):Boolean {
            if (this._current_location) {
                return this._current_location.has_building(building_id);
            }
            return false;
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
                return this._current_location.get_floor(this._current_location.floor_id).has_subsection(subsection_id);
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
                    regions: {}};

            var buildings_dict:Dictionary = this._regions.get_dictionary();
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

        public function get current_location():Region {
            return _current_location;
        }

        public function set current_location(value:Region):void {
            _current_location = value;
            notify_observers({'current_location': value});
        }

        public function get regions():Map {
            return _regions;
        }

        public function set regions(value:Map):void {
            _regions = value;
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
