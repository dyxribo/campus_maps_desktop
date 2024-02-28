package structs.location {
    import flash.utils.Dictionary;

    import net.blaxstar.starlib.debug.DebugDaemon;
    import structs.Map;

    public class Building extends Floor {
        private const _LOCATION_LINK_PATTERN:RegExp = /^([a-zA-Z0-9]+)(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?$/;

        public static const BUILDING_MATCH:uint = 0;
        public static const FLOOR_MATCH:uint = 1;
        public static const SUBSECTION_MATCH:uint = 2;
        public static const EXACT_MATCH:uint = 3;
        public static const NO_MATCH:int = -1;

        private var _floors:Map;
        private var _building_id:String;

        // TODO: REMOVE DEBUG STUFF
        public function Building() {
            super();
            this.id = "bldg" + Location.temp_assignments++;
            this.type = MappableItem.ITEM_BUILDING;
            this._floors = new Map(String, Floor);
        }

        public function add_floor(floor:Floor):Floor {
            if (!this._floors.has(floor.id)) {
                this._floors.put(floor.id, floor);
                floor.prefix = building_id;
            } else {
                DebugDaemon.write_log("error adding floor to building object: the specified floor already exists.", DebugDaemon.WARN);
            }
            return floor;
        }

        public function remove_floor(floor:String):Boolean {
            if (!this._floors.has(floor)) {
                DebugDaemon.write_log("error removing floor from building: the referenced floor does not " + "exist in this building.", DebugDaemon.WARN);
                return false;
            }
            this._floors.toss(floor);
            return true;
        }

        public function get_floor(floor:String):Floor {
            if (!this._floors.has(floor)) {
                // TODO: floor does not exist
                DebugDaemon.write_log("floor doesnt exist?: %s ", DebugDaemon.WARN, floor);
                return undefined;
            } else {
                return this._floors.pull(floor) as Floor;
            }
        }

        public function has_floor(id:String):Boolean {
            return this._floors.has(id);
        }

        public function get current_floor():Floor {
            return has_floor(this.floor_id) ? get_floor(this.floor_id) : undefined;
        }

        public function get current_subsection():Subsection {
            return current_floor ? current_floor.get_subsection(this.subsection_id) : undefined;
        }

        public function get current_item():MappableItem {
            return current_subsection ? current_subsection.get_item(this.item_id) : undefined;
        }

        public function get floors():Map {
            return this._floors;
        }

        public function set floors(value:Map):void {
            this._floors = value;
        }

        override public function get_subsection(subsection:String):Subsection {
            var current_floor:Floor = get_floor(floor_id);
            if (current_floor && current_floor.has_subsection(subsection)) {
                return current_floor.get_subsection(subsection);
            }
            return undefined;
        }

        override public function get_item(item:String):MappableItem {
            var current_floor:Floor = get_floor(floor_id);
            var current_subsection:Subsection = current_floor.get_subsection(subsection_id);
            if (current_subsection && current_subsection.has_item(item)) {
                return current_subsection.get_item(item);
            }
            return undefined;
        }

        static public function read_json(json:Object):Building {
            var building:Building = new Building();
            building.id = json.id;

            for (var key:Object in json.floors) {
                var current_floor:Floor = Floor.read_json(json.floors[key]);
                building.add_floor(current_floor);
            }

            return building;
        }

        override public function write_json():Object {
            var json:Object = super.write_json();
            var floors_dict:Dictionary = _floors.get_dictionary();

            json.floors = {};
            for (var key:Object in floors_dict) {
                json.floors[key] = floors_dict[key].write_json();
            }

            return json;
        }

        override public function set id(value:String):void {
            _building_id = this._id = value;
        }

        public function get building_id():String {
            return _building_id;
        }

        public function set building_id(value:String):void {
            _building_id = value;
        }

        override public function get link():String {
            return _building_id;
        }

        override public function destroy():void {
            _floors.iterate(function destroy_all(key:String, item:Floor):void {
                item.destroy();
            });
        }


    }

}
