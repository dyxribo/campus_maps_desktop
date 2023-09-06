package structs {
    import geom.Point;
    import structs.MappablePrinter;
    import structs.MappableMachine;

    public class MappablePrinter extends MappableMachine {
        static public var printer_lookup:Map;

        private var _using_usb:Boolean;

        public function MappablePrinter() {
            super();
            this._using_usb = false;
        }

        static public function add_to_directory(val:MappablePrinter):void {
            if (!MappablePrinter.printer_lookup) {
                MappablePrinter.printer_lookup = new Map(String, MappablePrinter);
            }
            MappablePrinter.printer_lookup.put(val.id, val);
        }

        static public function read_json(json:Object):MappablePrinter {
            var item:MappablePrinter = new MappablePrinter();
            item.id = json.id;
            item.position = json.position;
            item.assignee = json.assignee;
            item.model_name = json.model_name;
            item.mac_address = json.mac_address;
            item.ip_address = json.ip_address;
            item.connected_jack_id = json.connected_jack_id;
            item.using_usb = json.using_usb;

            return item;
        }

        override public function write_json():Object {
            var json:Object = super.write_json();
            json.using_usb = this.using_usb;

            return json;
        }

        public function get using_usb():Boolean {
            return this._using_usb;
        }

        public function set using_usb(value:Boolean):void {
            this._using_usb = value;
        }
    }

}
