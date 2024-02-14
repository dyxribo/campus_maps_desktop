package structs {
    import debug.DebugDaemon;

    import flash.utils.Dictionary;

    import structs.Location;
    import structs.MappableUser;
    import structs.MappableDesk;
    import structs.MappableItem;
    import structs.MappableWorkstation;
    import structs.MappablePrinter;
    import structs.WallJack;
    import structs.WallPlate;

    public class Subsection extends MappableItem {
        //private var _bounds:Polygon;
        private var _items:Map;
        private var _subsection_id:String;

        public function Subsection() {
            super();
            this.id = "sbsc" + Location.temp_assignments++;
            this.type = MappableItem.ITEM_SUBSECTION;
            this._items = new Map(String, MappableItem);
        }

        public function add_item(item:MappableItem):Boolean {
            if (this._items.has(item.id)) {
                DebugDaemon.write_log("error adding item to subsection: cannot add more than one item with the same key.", DebugDaemon.WARN);
                return false;
            }
            this._items.put(item.id, item);
            item.prefix = prefix + "_" + _subsection_id;
            return true;
        }

        public function remove_item(item:MappableItem):Boolean {
            if (!this._items.has(item.id)) {
                DebugDaemon.write_log("can not remove item from subsection: the referenced item " + "does not exist in this subsection. (%s, %s)", DebugDaemon.WARN, item.id, this.id);
                return false;
            }
            this._items.toss(item.id);
            return true;
        }

        public function has_item(item:String):Boolean {
            return this._items.has(item);
        }

        public function get_item(item:String):MappableItem {
            if (!this._items.has(item)) {
                // TODO: item does not exist
                return undefined;
            } else {
                return this._items.pull(item) as MappableItem;
            }
        }

        static public function read_json(json:Object):Subsection {
            var subsection:Subsection = new Subsection();
            subsection.id = json.id;
            subsection._items = new Map(String, MappableItem);
            subsection.prefix = json.prefix;

            for (var key:Object in json.items) {
                var current_item:Object = json.items[key];

                switch (current_item.type) {
                    case MappableItem.ITEM_USER:
                        subsection.add_item(MappableUser.read_json(current_item));
                        break;
                    case MappableItem.ITEM_WORKSTATION:
                        subsection.add_item(MappableWorkstation.read_json(current_item));
                        break;
                    case MappableItem.ITEM_DESK:
                        subsection.add_item(MappableDesk.read_json(current_item));
                        break;
                    case MappableItem.ITEM_PRINTER:
                        subsection.add_item(MappablePrinter.read_json(current_item));
                        break;
                    case MappableItem.ITEM_WALL_JACK:
                        subsection.add_item(WallJack.read_json(current_item));
                        break;
                    case MappableItem.ITEM_WALL_PLATE:
                        subsection.add_item(WallPlate.read_json(current_item));
                        break;
                    case MappableItem.ITEM_GENERIC:
                    default:
                        subsection.add_item(MappableItem.read_json(current_item));
                        break;
                }
            }
            return subsection;
        }

        override public function write_json():Object {
            var items_json:Object = {};
            // Object.defineProperty(json, 'bounds', this.bounds.build_json());
            var items_dict:Dictionary = _items.get_dictionary();
            for (var key:Object in items_dict) {

                items_json[key] = items_dict[key].write_json();
            }
            var json:Object = super.write_json();
            json.items = items_json;
            json.prefix = prefix;
            return json;
        }

        override public function destroy():void {
            _items.iterate(function destroy_all(key:String, item:MappableItem):void {
                item.destroy();
            });
            _items = null;
        }

        override public function set id(value:String):void {
            _subsection_id = this._id = value;
        }

        public function get subsection_id():String {
            return _subsection_id;
        }

        public function set subsection_id(value:String):void {
            _subsection_id = value;
        }

        override public function get link():String {
            return prefix ? prefix + "_" + _subsection_id : _subsection_id;
        }
    }

}
