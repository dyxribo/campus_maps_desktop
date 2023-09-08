package structs {

    import geom.Point;
    import structs.AssignableItem;

    public class MappableDesk extends AssignableItem {

        /**
         * TODO: there's not much justifying this class besides the fact that desk
         * locations are an integral concept for this project. maybe i can find some
         * relevant data that only desks have that will justify this. maybe store a
         * boolean value to check if a desk is an electronic standing desk?
         */
        public function MappableDesk() {
            this.type = MappableItem.ITEM_DESK;
            super();
        }

        static public function read_json(json:Object):MappableDesk {
            var item:MappableDesk = new MappableDesk();
            item.id = json.id;
            item.position = Point.read_json(json.position);
            item.assignee = json.assignee;

            return item;
        }

        override public function set id(value:String):void {
          desk_lookup.toss(this._id);
          item_id = this._id = value;
          desk_lookup.put(this.id, this);
        }
    }

}
