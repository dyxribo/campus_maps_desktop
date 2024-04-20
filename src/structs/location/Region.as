package structs.location {
    import flash.utils.Dictionary;

    import net.blaxstar.starlib.debug.DebugDaemon;
    import structs.Map;

    public class Region extends Building {
        private const _LOCATION_LINK_PATTERN:RegExp = /^([a-zA-Z0-9]+)(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?$/;

        private var _buildings:Map;
        private var _current_building_id:String;
        private var _current_floor_id:String;
        private var _current_subsection_id:String;
        private var _current_item_id:String;

        // TODO: REMOVE DEBUG STUFF
        public function Region() {
            super();
            this.id = "bldg" + Location.temp_assignments++;
            this.type = MappableItem.ITEM_BUILDING;
            this._buildings = new Map(String, Floor);
        }

        public function add_building(building:Building):Building {
            if (!this._buildings.has(building.id)) {
                this._buildings.put(building.id, building);
                building.prefix = id;
            } else {
                DebugDaemon.write_warning("error adding Building to Region object: the specified building already exists.");
            }
            return building;
        }

        public function remove_building(building:String):Boolean {
            if (!this._buildings.has(building)) {
                DebugDaemon.write_warning("error removing Building from Region: the referenced building (%s) does not exist in this Region (%s).", building, id);
                return false;
            }
            this._buildings.toss(building);
            return true;
        }

        public function get_building(building_id:String):Building {
            if (!this._buildings.has(building_id)) {
                // TODO: floor does not exist
                DebugDaemon.write_warning("building doesnt exist?: %s ", building_id);
                return undefined;
            } else {
                return this._buildings.pull(building_id) as Building;
            }
        }

        public function has_building(id:String):Boolean {
            return this._buildings.has(id);
        }

        public function get buildings():Map {
            return this._buildings;
        }

        static public function read_json(json:Object):Region {
            var region:Region = new Region();
            region.id = json.id;

            for (var key:Object in json.buildings) {
                var current_building:Building = Building.read_json(json.buildings[key]);
                region.add_building(current_building);
            }
            add_to_directory(region);
            return region;
        }

        override public function write_json():Object {
            var json:Object = super.write_json();
            var floors_dict:Dictionary = _buildings.get_dictionary();

            json.floors = {};
            for (var key:Object in floors_dict) {
                json.floors[key] = floors_dict[key].write_json();
            }

            return json;
        }

        override public function set id(value:String):void {
            this._id = value;
        }

        public function get building_id():String {
            return this._current_building_id;
        }

        public function set building_id(value:String):void {
            this._current_building_id = value;
        }

        public function get floor_id():String {
            return this._current_floor_id;
        }

        public function set floor_id(value:String):void {
            this._current_floor_id = value;
        }

        public function get subsection_id():String {
            return this._current_subsection_id;
        }

        public function set subsection_id(value:String):void {
            this._current_subsection_id = value;
        }

        public function get item_id():String {
            return this._current_item_id;
        }

        public function set item_id(value:String):void {
            this._current_item_id = value;
        }

        override public function get link():String {
            // overriding this because the link for the root object (region) is simply its own id
            return this._id;
        }

        override public function destroy():void {
            _buildings.iterate(function destroy_all(key:String, item:Building):void {
                item.destroy();
            });
        }


    }

}
