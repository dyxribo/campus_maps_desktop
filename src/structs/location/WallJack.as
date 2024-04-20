package structs.location {
    import geom.Point;

    public class WallJack extends MappableItem {

        private var _associated_plate:String;
        private var _connected_machine_id:String = '';

        public function WallJack() {
            this._connected_machine_id = '';
            this.type = MappableItem.ITEM_WALL_JACK;
            super();
            add_to_directory(this);
        }

        public function set_connection(item:String):Boolean {
            this._connected_machine_id = item;
            // TODO: check if something is connected and maybe make a flag like allow_replacments for an extra security feature.
            return true;
        }

        public function remove_connection():Boolean {
            this._connected_machine_id = '';
            // TODO: check if something is connected and maybe make a flag like lock_connection for an extra security feature.
            return true;
        }

        static public function read_json(json:Object):WallJack {
            var item:WallJack = new WallJack();
            item.id = json.id;
            item._position = Point.read_json(json.position);
            item._connected_machine_id = json.connected_item_id;
            item._associated_plate = json.associated_plate;

            return item;
        }

        override public function write_json():Object {
            var json:Object = super.write_json();
            json.associated_plate = this._associated_plate;
            json.connected_item_id = this._connected_machine_id;
            return json;
        }
    }

}
