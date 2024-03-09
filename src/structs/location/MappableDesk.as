package structs.location {

    import geom.Point;

    public class MappableDesk extends AssignableItem {

        private var _is_adjustable:Boolean;

        public function MappableDesk() {
            this.type = MappableItem.ITEM_DESK;
            super();
        }

        static public function read_json(json:Object):MappableDesk {
            var desk:MappableDesk = new MappableDesk();
            desk.id = json.id;
            desk.position = Point.read_json(json.position);
            desk.assignee = json.assignee;
           add_to_directory(desk);
            return desk;
        }

        override public function set id(value:String):void {
            // if we change the id, then we have to change the key in the lookup to find the object when we need to
            desk_lookup.toss(this._id);
            item_id = this._id = value;
            desk_lookup.put(this.id, this);
        }

        public function get is_adjustable():Boolean {
            return _is_adjustable;
        }

        public function set is_adjustable(value:Boolean):void {
            _is_adjustable = value;
        }
    }

}
