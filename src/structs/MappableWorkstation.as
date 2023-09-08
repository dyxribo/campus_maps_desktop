package structs {
    import geom.Point;
    import structs.MappableItem;
    import structs.MappableMachine;

    public class MappableWorkstation extends MappableMachine {

        private var _hostname:String = '';

        public function MappableWorkstation() {
            this.type = MappableItem.ITEM_WORKSTATION;
            super();
        }

        static public function read_json(json:Object):MappableWorkstation {
            var item:MappableWorkstation = new MappableWorkstation();
            item.id = json.id;
            item.position = Point.read_json(json.location);
            item.assignee = json.assignee;
            item.model_name = json.model_name;
            item.mac_address = json.mac_address;
            item.ip_address = json.ip_address;
            item.connected_jack_id = json.connected_jack_id;
            item.hostname = json.hostname;

            return item;
        }

        override public function write_json():Object {
            var json:Object = super.write_json();
            json.assignee = this.assignee;
            json.model_name = this.model_name;
            json.mac_address = this.mac_address;
            json.ip_address = this.ip_address;
            json.connected_jack_id = this.connected_jack_id;
            json.hostname = this.hostname;

            return json;
        }

        public function get hostname():String {
            return this._hostname;
        }

        public function set hostname(value:String):void {
            this._hostname = value;
        }
    }

}
