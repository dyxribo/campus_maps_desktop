package views.dialog {
    import net.blaxstar.starlib.components.VerticalBox;
    import net.blaxstar.starlib.components.PlainText;
    import net.blaxstar.starlib.components.InputTextField;

    public class BaseDialogView extends VerticalBox {
        private var _dialog_info_type:uint;
        private var _item_name_field:PlainText;
        private var _item_type_field:PlainText;
        private var _item_location:PlainText;

        /**
         * TODO: allow manual editing, if to be uploaded to database
         */
        public function BaseDialogView() {
            super();
            spacing = PADDING;
        }

        override public function add_children():void {
            _item_name_field = new PlainText(this, 0, 0, "item name");
            _item_type_field = new PlainText(this, 0, 0, "item type");
            _item_location = new PlainText(this, 0, 0, "item location");
        }

        public function get info_type():uint {
            return _dialog_info_type;
        }

        public function set info_type(type_id:uint):void {
            _dialog_info_type = type_id;
        }

        public function set_name_field(name:String):void {
            _item_name_field.text = "NAME: " + name;
        }

        public function set_type_field(type:String):void {
            _item_type_field.text = "TYPE: " + type;
        }

        public function set_location_field(location:String):void {
            _item_location.text = "LOCATION: " + location;
        }
    }
}
