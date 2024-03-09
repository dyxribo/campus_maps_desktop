package views.dialog {
    import net.blaxstar.starlib.components.PlainText;
    import net.blaxstar.starlib.components.Checkbox;
    import structs.workhours.WorkHours;

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
            _is_vip.label = "VIP";
            _is_vip.enabled = false;
        }

        public function set username_field(username:String):void {
            _username_field.text = "USERNAME: " + username;
        }

        public function set email_field(email:String):void {
            _email_field.text = "EMAIL: " + email;
        }

        public function set phone_field(phone:String):void {
            _phone_field.text = "PHONE: " + phone;
        }

        public function set work_hours_field(work_hours:WorkHours):void {
            _work_hours_field.text = "Work hours: " + work_hours.start_time + "-" + work_hours.end_time + " " + work_hours.time_zone;
        }

        public function set vip_status(is_vip:Boolean):void {
            _is_vip.checked = is_vip;
        }
    }
}
