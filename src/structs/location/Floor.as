package structs.location {
    import flash.utils.Dictionary;

    import net.blaxstar.starlib.debug.DebugDaemon;

    import structs.Map;

    public class Floor extends Subsection {

        private var _subsections:Map;
        private var _on_single_vlan:Boolean;

        // TODO: REMOVE DEBUG STUFF
        public function Floor() {
            super();
            this.id = "floor" + Location.temp_assignments++;
            this.type = MappableItem.ITEM_FLOOR;
            this._subsections = new Map(String, Subsection);
            this._on_single_vlan = false;
        }

        public function add_subsection(subsection:Subsection):Boolean {
            if (this._subsections.has(subsection.id)) {
                DebugDaemon.write_log("error adding subsection: cannot add a subsection that already exists.", DebugDaemon.WARN);
                return false;
            } else {
                this._subsections.put(subsection.id, subsection);
                subsection.prefix = prefix + "_" + this._id;
                if (this._subsections.size > 1) {
                    this._on_single_vlan = false;
                }
                return true;
            }
        }

        public function remove_subsection(subsection_id:String):Boolean {
            if (!this._subsections.has(subsection_id)) {
                DebugDaemon.write_log("error removing subsection: the specified subsection does not exist.", DebugDaemon.WARN);
                return false;
            } else {
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
            } else {
                return this._subsections.pull(subsection) as Subsection;
            }
        }

        public function has_subsection(subsection_id:String):Boolean {
            return this._subsections.has(subsection_id);
        }

        override public function destroy():void {
            _subsections.iterate(function destroy_all(key:String, item:Subsection):void {
                item.destroy();
            });
        }

        public function get subsections():Map {
            return this._subsections;
        }

        public function set subsections(value:Map):void {
            this._subsections = value;
        }

        static public function read_json(json:Object):Floor {
            var floor:Floor = new Floor();
            floor.id = json.id;

            for (var key:Object in json.subsections) {
                var current_subsection:Subsection = Subsection.read_json(json.subsections[key]);
                floor.subsections.put(key, current_subsection);
            }
            add_to_directory(floor);
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

        override public function get link():String {
            return prefix ? prefix + "_" + this._id : this._id;
        }

        override public function set id(value:String):void {
            this._id = value;
        }
    }

}
