package structs.location {
    import geom.Point;

    public class MappableWorkstation extends MappableMachine {


        private var _address_width:String;
        private var _ram:String;
        private var _cpu_clock_speed:String;
        private var _total_disk_space:String;

        private var _cpu_core_count:String;

        private var _is_virtual:Boolean;
        private var _operating_system:String;

        public function MappableWorkstation() {
            this.type = MappableItem.ITEM_WORKSTATION;
            super();
        }

        static public function read_json(json:Object):MappableWorkstation {
            var item:MappableWorkstation = new MappableWorkstation();
            item.id = json.id;
            item._position = Point.read_json(json.location);
            item.assignee = json.assignee;
            item.model_name = json.model_name;
            item.mac_address = json.mac_address;
            item.ip_address = json.ip_address;
            item.connected_jack_id = json.connected_jack_id;
            item.hostname = json.hostname;
            item.address_width = json._address_width;
            item.ram = json._ram;
            item.cpu_clock_speed = json._cpu_clock_speed;
            item.total_disk_space = json._total_disk_space;
            item.dns_domain = json._dns_domain;
            item.serial_number = json._serial_number;
            item.cpu_core_count = json._cpu_core_count;
            item.internet_facing = json._internet_facing;
            item.inventory_status = json._inventory_status;
            item.is_virtual = json._is_virtual;
            item.operating_system = json._operating_system;

            return item;
        }

        override public function write_json():Object {
            var json:Object = super.write_json();

            json.address_width = this._address_width;
            json.ram = this._ram;
            json.cpu_clock_speed = this._cpu_clock_speed;
            json.total_disk_space = this._total_disk_space;
            json.cpu_core_count = this._cpu_core_count;
            json.is_virtual = this._is_virtual;
            json.operating_system = this._operating_system;

            return json;
        }

        public function get address_width():String {
            return this._address_width;
        }

        public function set address_width(value:String):void {
            this._address_width = value;
        }

        public function get ram():String {
            return this._ram;
        }

        public function set ram(value:String):void {
            this._ram = value;
        }

        public function get cpu_clock_speed():String {
            return this._cpu_clock_speed;
        }

        public function set cpu_clock_speed(value:String):void {
            this._cpu_clock_speed = value;
        }

        public function get total_disk_space():String {
            return this._total_disk_space;
        }

        public function set total_disk_space(value:String):void {
            this._total_disk_space = value;
        }

        public function get cpu_core_count():String {
            return this._cpu_core_count;
        }

        public function set cpu_core_count(value:String):void {
            this._cpu_core_count = value;
        }

        public function get is_virtual():Boolean {
            return this._is_virtual;
        }

        public function set is_virtual(value:Boolean):void {
            this._is_virtual = value;
        }

        public function get operating_system():String {
            return this._operating_system;
        }

        public function set operating_system(value:String):void {
            this._operating_system = value;
        }

    }

}
