package structs {
    import geom.Point;
    import structs.Location;

    public class MappableItem extends Location {

        static public var item_lookup:Map;

        static public const ITEM_USER:uint = 0;
        static public const ITEM_WORKSTATION:uint = 1;
        static public const ITEM_DESK:uint = 2;
        static public const ITEM_PRINTER:uint = 3;
        static public const ITEM_WALL_JACK:uint = 4;
        static public const ITEM_WALL_PLATE:uint = 5;
        static public const ITEM_SUBSECTION:uint = 6;
        static public const ITEM_FLOOR:uint = 7;
        static public const ITEM_BUILDING:uint = 8;
        static public const ITEM_GENERIC:uint = 9;

        private var _id:String;
        private var _type:uint;
        private var _position:Point;
        private var _item_id:String;

        public function MappableItem() {

            this._id = 'itm' + Location.temp_assignments++;
            this._type = MappableItem.ITEM_GENERIC;
            this._position = position ? position : new Point(0, 0);

            this.add_to_directory(this);
        }

        protected function add_to_directory(val:MappableItem):void {
            if (!MappableItem.item_lookup) {
                MappableItem.item_lookup = new Map(String, MappableItem);
            }

            MappableItem.item_lookup.put(val.id, val);
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

        public function get link():String {
            return _item_id;
        }

        override public function set id(value:String):void {
            _item_id = super.id = value;
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
    }

}
