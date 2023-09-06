package structs {
    import debug.DebugDaemon;

    import flash.utils.Dictionary;

    public class Building extends Floor {
        private const _LOCATION_LINK_PATTERN:RegExp = /^([a-zA-Z0-9]+)(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?(?:_([a-zA-Z0-9]+))?$/;

        public static const BUILDING_MATCH:uint = 0;
        public static const FLOOR_MATCH:uint = 1;
        public static const SUBSECTION_MATCH:uint = 2;
        public static const EXACT_MATCH:uint = 3;
        public static const NO_MATCH:int = -1;

        private var _floors:Map;
        private var _building_id:String;

        public function Building() {
            super();
            this.id = "bldg" + Location.temp_assignments++;
            this.type = MappableItem.ITEM_BUILDING;
            this._floors = new Map(String, Floor);
        }

        public function add_floor(floor:Floor):Floor {
            if (!this._floors.has(floor.id)) {
                this._floors.put(floor.id, floor);
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

        public function navigate_to(location_link:String):int {
            var link_elements:Array = location_link.match(this._LOCATION_LINK_PATTERN);

            if (link_elements.length) {
                var building_id:String = link_elements[1] ? link_elements[1] : '';
                var floor_id:String = link_elements[2] ? link_elements[2] : '';
                var subsection_id:String = link_elements[3] ? link_elements[3] : '';
                var item_id:String = link_elements[4] ? link_elements[4] : '';

                if (building_id != this._building_id) {
                    // throw error, building does not exist
                    return NO_MATCH;
                } else {
                    if (floor_id && has_floor(floor_id)) {
                        var fl:Floor = get_floor(floor_id);
                        this.floor_id = floor_id;

                        if (subsection_id && fl.has_subsection(subsection_id)) {

                            var ss:Subsection = fl.get_subsection(subsection_id);
                            this.subsection_id = subsection_id;

                            if (item_id && ss.has_item(item_id)) {
                                this.item_id = item_id;
                                return EXACT_MATCH;
                            } else {
                                return SUBSECTION_MATCH;
                            }
                        } else {
                            return FLOOR_MATCH;
                        }
                    }
                }
            }
            return BUILDING_MATCH;
        }

        public function get floors():Map {
            return this._floors;
        }

        public function set floors(value:Map):void {
            this._floors = value;
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

            DebugDaemon.write_log("building floors: %s\n\nall floors: %s", DebugDaemon.DEBUG, JSON.stringify(json.floors), JSON.stringify(this._floors));
            return json;
        }

        override public function set id(value:String):void {
            _building_id = super.id = value;
        }

        public function get building_id():String {
            return _building_id;
        }

        public function set building_id(value:String):void {
            _building_id = value;
        }

        override public function get link():String {
            return _building_id + "_" + super.link;
        }

    }

}
