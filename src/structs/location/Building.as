package structs.location {
    import flash.utils.Dictionary;

    import net.blaxstar.starlib.debug.DebugDaemon;
    import structs.Map;

    public class Building extends Floor {

        private var _floors:Map;

        // TODO: REMOVE DEBUG STUFF
        public function Building() {
            super();
            this.id = "building" + Location.temp_assignments++;
            this.type = MappableItem.ITEM_BUILDING;
            this._floors = new Map(String, Floor);
        }

        public function add_floor(floor:Floor):Floor {
            if (!this._floors.has(floor.id)) {
                this._floors.put(floor.id, floor);
                floor.prefix = _id;
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
            add_to_directory(building);
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

        override public function destroy():void {
            _floors.iterate(function destroy_all(key:String, item:Floor):void {
                item.destroy();
            });
        }


    }

}
