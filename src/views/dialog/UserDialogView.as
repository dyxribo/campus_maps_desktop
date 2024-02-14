package views.dialog {
    import net.blaxstar.starlib.components.PlainText;
    import net.blaxstar.starlib.components.Checkbox;

    public class UserDialogView extends BaseDialogView {


        private var _username_field:PlainText;
        private var _email_field:PlainText;
        private var _phone_field:PlainText;
        private var _work_hours_field:PlainText;
        private var _is_vip:Checkbox;

        public function UserDialogView() {
            super();
            _username_field = new PlainText(this,0,0,"username");
            _email_field = new PlainText(this,0,0,"email");
            _phone_field = new PlainText(this,0,0,"phone");
            _work_hours_field = new PlainText(this,0,0,"work hours");
            _is_vip = new Checkbox(this);
            _is_showing_bounds_ = true;
        }

        public function set username_field(username:String):void {
            _username_field.text = username;
        }

        public function set email_field(email:String):void {
            _email_field.text = email;
        }

        public function set phone_field(phone:String):void {
            _phone_field.text = phone;
        }

        public function set work_hours_field(work_hours:String):void {
            _work_hours_field.text = work_hours;
        }

        public function set vip_status(is_vip:Boolean):void {
            _is_vip.checked = is_vip;
        }
    }
}
