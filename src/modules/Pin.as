package modules {
    import flash.display.DisplayObjectContainer;

    import net.blaxstar.starlib.components.LED;

    import structs.location.MappableItem;

    public class Pin extends LED {
        private var _linked_item:MappableItem;

        public function Pin(parent:DisplayObjectContainer = null, linked_item:MappableItem = null) {
            if (linked_item) {
                _linked_item = linked_item;
            }
            super(parent);
        }

        public function on_click():void {

        }

        override public function destroy():void {
            _linked_item = null;
            super.destroy();
        }

        public function get linked_item():MappableItem {
            return _linked_item;
        }

        public function set linked_item(value:MappableItem):void {
            _linked_item = value;
        }

    }
}
