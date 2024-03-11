package structs.location {
    import geom.Point;

    import modules.Pin;

    import net.blaxstar.starlib.style.Color;

    import structs.Map;

    public class MappableItem extends Location {

        static public var item_lookup:Map;
        static public var user_lookup:Map;
        static public var workstation_lookup:Map;
        static public var desk_lookup:Map;
        static public var printer_lookup:Map;
        static public var wall_jack_lookup:Map;
        static public var wall_plate_lookup:Map;
        static public var pin_lookup:Vector.<Pin>;

        static public const ITEM_BUILDING:uint = 0;
        static public const ITEM_FLOOR:uint = 1;
        static public const ITEM_SUBSECTION:uint = 2;
        static public const ITEM_USER:uint = 3;
        static public const ITEM_WORKSTATION:uint = 4;
        static public const ITEM_DESK:uint = 5;
        static public const ITEM_PRINTER:uint = 6;
        static public const ITEM_WALL_JACK:uint = 7;
        static public const ITEM_WALL_PLATE:uint = 8;
        static public const ITEM_GENERIC:uint = 9;

        private var _type:uint;
        private var _position:Point;
        private var _item_id:String;
        private var _prefix:String;
        private var _modified:Boolean;

        public function MappableItem() {
            this._id ||= 'itm' + Location.temp_assignments++;
            this._type ||= MappableItem.ITEM_GENERIC;
            this._position ||= new Point(0, 0);
            add_to_directory(this);
            super();
        }

        static public function add_to_directory(val:MappableItem):void {

            switch (val.type) {
                case ITEM_USER:
                    if (!user_lookup) {
                        user_lookup = new Map(String, MappableUser);
                    }
                    user_lookup.put(val.id, val);
                    break;
                case ITEM_WORKSTATION:
                    if (!workstation_lookup) {
                        workstation_lookup = new Map(String, MappableWorkstation);
                    }
                    workstation_lookup.put(val.id, val);
                    break;
                case ITEM_DESK:
                    if (!desk_lookup) {
                        desk_lookup = new Map(String, MappableDesk);
                    }
                    desk_lookup.put(val.id, val);
                    break;
                case ITEM_PRINTER:
                    if (!printer_lookup) {
                        printer_lookup = new Map(String, MappablePrinter);
                    }
                    printer_lookup.put(val.id, val);
                    break;
                case ITEM_WALL_PLATE:
                    if (!wall_plate_lookup) {
                        wall_plate_lookup = new Map(String, WallPlate);
                    }
                    wall_plate_lookup.put(val.id, val);
                    break;
                case ITEM_WALL_JACK:
                    if (!wall_jack_lookup) {
                        wall_jack_lookup = new Map(String, WallJack);
                    }
                    wall_jack_lookup.put(val.id, val);
                    break;
                default:
                    if (!item_lookup) {
                        item_lookup = new Map(String, MappableItem);
                    }
                    item_lookup.put(val.id, val);
                    break;
            }

            if (!pin_lookup) {
                pin_lookup = new Vector.<Pin>();
            }

            if (!(val is Building) && !(val is Floor) && !(val is Subsection) && !(val is MappableUser)) {
                var pin:Pin = new Pin(null, val);
                pin.on_color = Color.PRODUCT_RED.value;
                pin_lookup.push(pin);
            }
        }

        static public function read_json(json:Object):MappableItem {
            var item:MappableItem = new MappableItem();
            item.id = json.id;
            item.type = json.type;
            item.position = Point.read_json(json.position)

            return item;
        }

        override public function write_json():Object {
            var json:Object = super.write_json();
            json.type = this.type;
            return json;
        }

        public function destroy():void {
            _position.x = _position.y = 0;
        }

        /**
         * destroy all lookups.
         */
        static public function destroy_lookups():void {
            if (item_lookup) {
                item_lookup.destroy();
            }
            if (user_lookup) {
                user_lookup.destroy();
            }
            if (workstation_lookup) {
                workstation_lookup.destroy();
            }
            if (desk_lookup) {
                desk_lookup.destroy();
            }
            if (printer_lookup) {
                printer_lookup.destroy();
            }
            if (wall_jack_lookup) {
                wall_jack_lookup.destroy();
            }
            if (wall_plate_lookup) {
                wall_plate_lookup.destroy();
            }


            pin_lookup.forEach(function delete_all(current_pin:Pin, index:uint, arr:Vector.<Pin>):void {
                current_pin.destroy();
                delete arr[index];
            });
            pin_lookup.length = 0;
            pin_lookup = null;
        }

        public function get link():String {
            return _prefix ? prefix + "_" + _item_id.toUpperCase() : _item_id.toUpperCase();
        }

        /**
         * returns prefix in the format `bldg_fl_ss_`.
         * @return
         */
        public function get prefix():String {
            return _prefix;
        }

        public function set prefix(value:String):void {
            _prefix = value;
        }

        override public function set id(value:String):void {
            _item_id = this._id = value;
        }

        public function get type():uint {
            return this._type;
        }

        public function set type(value:uint):void {
            this._type = value;
        }

        public function get item_id():String {
            return _item_id;
        }

        public function set item_id(value:String):void {
            _item_id = value;
        }

        public function get modified():Boolean {
            return _modified;
        }

        public function set modified(value:Boolean):void {
            _modified = value;
        }
    }

}
