package structs.location {
    import flash.utils.Dictionary;

    import net.blaxstar.starlib.debug.DebugDaemon;

    import structs.Map;
    import geom.Point;

    public class Subsection extends MappableItem {
        private var _items:Map;

        // TODO: REMOVE DEBUG STUFF
        public function Subsection() {
            super();
            this.id = "subsection" + Location.temp_assignments++;
            this.type = MappableItem.ITEM_SUBSECTION;
            this._items = new Map(String, MappableItem);
        }

        public function add_item(item:MappableItem):Boolean {
            if (this._items.has(item.id)) {
                DebugDaemon.write_log("error adding item to subsection: cannot add more than one item with the same key.", DebugDaemon.WARN);
                return false;
            }
            this._items.put(item.id, item);
            item.prefix = prefix + "_" + this._id;
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
            subsection._position = Point.read_json(json.position);
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
        }

        override public function get link():String {
            return prefix ? prefix + "_" + this._id : this._id;
        }
    }

}
