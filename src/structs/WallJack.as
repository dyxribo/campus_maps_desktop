package structs {
    import geom.Point;
    import structs.MappableItem;

    public class WallJack extends MappableItem {

        private var _associated_plate:String;
        private var _connected_item_id:String = '';

        public function WallJack() {
            this._connected_item_id = '';
            this.type = MappableItem.ITEM_WALL_JACK;
            super();
            add_to_directory(this);
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
