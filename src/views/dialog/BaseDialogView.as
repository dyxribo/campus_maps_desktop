package views.dialog {
    import net.blaxstar.starlib.components.VerticalBox;
    import net.blaxstar.starlib.components.PlainText;
    import net.blaxstar.starlib.components.InputTextField;
    import net.blaxstar.starlib.components.Dialog;
    import flash.events.MouseEvent;
    import net.blaxstar.starlib.utils.StringUtil;
    import flash.utils.Dictionary;
    import structs.location.MappableItem;
    import structs.location.MappableUser;
    import net.blaxstar.starlib.components.Component;
    import net.blaxstar.starlib.components.ListItem;

    public class BaseDialogView extends VerticalBox {
        private var _parent_dialog:Dialog;
        private var _dialog_view_cache:Dictionary;
        private var _dialog_info_type:uint;
        private var _item_name_field:PlainText;
        private var _item_type_field:PlainText;
        private var _item_location:PlainText;
        private var _item_assignee:ListItem;

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
            _item_assignee = new ListItem(this, 0, 0, "item assignee");
            _item_assignee.mouseEnabled = true;
            _item_assignee.useHandCursor = true;
            _item_assignee.addEventListener(MouseEvent.CLICK, on_assignee_click);
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

        public function remove_location_field():void {
            removeChild(_item_location);
        }

        public function set_assignee_field(assignee:String):void {
            _item_assignee.label = "ASSIGNED USER: " + assignee;
        }

        public function remove_assignee_field():void {
            removeChild(_item_assignee);
        }

        public function set parent_dialog(dialog:Dialog):void {
            _parent_dialog = dialog;
        }

        public function get parent_dialog():Dialog {
            return _parent_dialog;
        }

        private function on_assignee_click(event:MouseEvent):void {
            if (!_parent_dialog || !_parent_dialog.parent || StringUtil.is_empty_or_null(_item_assignee.label)) {
                return;
            } else {
                var username:String = _item_assignee.label.replace("ASSIGNED USER: ", "");
                if (!_dialog_view_cache || _dialog_view_cache.hasOwnProperty(username)) {
                    // push new user dialog view
                    _dialog_view_cache ||= new Dictionary();
                    var d:Dialog = new Dialog(_parent_dialog.parent);
                    var v:UserDialogView = new UserDialogView();
                    var u:MappableUser = MappableItem.user_lookup.pull(username) as MappableUser;
                    // initialize the information view component for the dialog
                    v.remove_assignee_field();
                    v.set_name_field(u.full_name);
                    v.set_type_field("USER");
                    v.remove_location_field();
                    v.username_field = username;
                    v.phone_field = u.mobile_phone;
                    v.email_field = u.email;
                    v.work_hours_field = u.work_hours;
                    v.vip_status = u.is_vip;
                    // initialize the user info dialog containing the info view
                    d.title = u.username + " properties";
                    d.auto_resize = true;
                    d.add_component(v);
                    d.add_button("close", function():void {
                        d.close();
                        _parent_dialog.enabled = true
                    });
                    _dialog_view_cache[username] = d;
                    _parent_dialog.push_dialog(d);
                } else {
                    d = _dialog_view_cache[username] as Dialog;
                    _parent_dialog.push_dialog(d);
                }
            }
        }
    }
}
