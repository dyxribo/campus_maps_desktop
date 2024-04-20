package structs.location {
    import geom.Point;
    import structs.location.AssignableItem;

    public class MappableMachine extends AssignableItem {
        private var _hostname:String = '';
        private var _model_name:String = '';
        private var _serial_number:String;
        private var _mac_address:String = '';
        private var _ip_address:String = '';
        private var _dns_domain:String;
        private var _internet_facing:Boolean;
        private var _inventory_status:String;
        private var _connected_jack_id:String = '';

        public function MappableMachine() {
            super();
        }

        static public function read_json(json:Object):MappableMachine {
            var machine:MappableMachine = new MappableMachine();
            machine.id = json.id;
            machine.type = json.type;
            machine._position = Point.read_json(json.position);
            machine.assignee = json.assignee;
            machine.model_name = json.model_name;
            machine.mac_address = json.mac_address;
            machine.ip_address = json.ip_address;
            machine.connected_jack_id = json.connected_jack_id;
            add_to_directory(machine);
            return machine;
        }

        override public function write_json():Object {
            var json:Object;
            json = super.write_json();
            json.assignee = this.assignee;
            json.model_name = this.model_name;
            json.mac_address = this.mac_address;
            json.ip_address = this.ip_address;
            json.internet_facing = this._internet_facing;
            json.hardware_status = this._inventory_status;
            json.dns_domain = this._dns_domain;
            json.serial_number = this._serial_number;
            json.hostname = this._hostname;
            json.connected_jack_id = this.connected_jack_id;

            return json;
        }

        public function get model_name():String {
            return this._model_name;
        }

        public function set model_name(value:String):void {
            this._model_name = value;
        }

        public function get mac_address():String {
            return this._mac_address;
        }

        public function set mac_address(value:String):void {
            this._mac_address = value;
        }

        public function get ip_address():String {
            return this._ip_address;
        }

        public function set ip_address(value:String):void {
            this._ip_address = value;
        }

        public function get dns_domain():String {
            return this._dns_domain;
        }

        public function set dns_domain(value:String):void {
            this._dns_domain = value;
        }

        public function get serial_number():String {
            return this._serial_number;
        }

        public function set serial_number(value:String):void {
            this._serial_number = value;
        }

        public function get internet_facing():Boolean {
            return this._internet_facing;
        }

        public function set internet_facing(value:Boolean):void {
            this._internet_facing = value;
        }

        public function get inventory_status():String {
            return this._inventory_status;
        }

        public function set inventory_status(value:String):void {
            this._inventory_status = value;
        }

        public function get hostname():String {
            return this._hostname;
        }

        public function set hostname(value:String):void {
            this._hostname = value;
        }

        public function get connected_jack_id():String {
            return this._connected_jack_id;
        }

        public function set connected_jack_id(value:String):void {
            this._connected_jack_id = value;
        }
    }
}
