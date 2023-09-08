package structs {
    import structs.MappableMachine;

    public class MappablePrinter extends MappableMachine {

        private var _using_usb:Boolean;

        public function MappablePrinter() {
            this._using_usb = false;
            this.type = MappableItem.ITEM_PRINTER;
            super();
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
