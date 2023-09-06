package structs {
    import geom.Point;
    import structs.MappableItem;

    public class WallJack extends MappableItem {
        static private var jack_lookup:Map;

        private var _associated_plate:String;
        private var _connected_item_id:String = '';

        public function WallJack() {

            super();
            this._connected_item_id = '';

            if (!WallJack.jack_lookup) {
                WallJack.jack_lookup = new Map(String, WallJack);
            }
            WallJack.jack_lookup.put(id, this);
        }

        static public function get_jack(jack_id:String):WallJack {
            if (!WallJack.jack_lookup || !WallJack.jack_lookup.has(jack_id))
                return undefined;
            else {
                return WallJack.jack_lookup.pull(jack_id) as WallJack;
            }
        }

        public function set_connection(item:String):Boolean {
            this._connected_item_id = item;
            // TODO: check if something is connected and maybe make a flag like allow_replacments for an extra security feature.
            return true;
        }

        public function remove_connection():Boolean {
            this._connected_item_id = '';
            // TODO: check if something is connected and maybe make a flag like lock_connection for an extra security feature.
            return true;
        }

        static public function read_json(json:Object):WallJack {
            var item:WallJack = new WallJack();
            item.id = json.id;
            item.position = Point.read_json(json.position);
            item._connected_item_id = json.connected_item_id;

            return item;
        }

        override public function write_json():Object {
            var json:Object = super.write_json();
            json.id = id;
            json.position = position.write_json();
            json.type = MappableItem.ITEM_WALL_JACK;
            json.plate_id = this._associated_plate;
            json.connected_item_id = this._connected_item_id;
            return json;
        }
    }

}
