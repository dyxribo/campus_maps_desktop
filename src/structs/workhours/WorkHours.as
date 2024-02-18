package structs.workhours {

    public class WorkHours {

        private var _start_time:String;
        private var _end_time:String;
        private var _time_zone:String;

        public function WorkHours() {
        }

        public function populate_all(start_time:String, end_time:String, time_zone:String):WorkHours {
            _start_time = start_time;
            _end_time = end_time;
            _time_zone = time_zone;

            return this;
        }

        public function get start_time():String {
            return _start_time;
        }

        public function set start_time(value:String):void {
            _start_time = value;
        }

        public function get end_time():String {
            return _end_time;
        }

        public function set ent_time(value:String):void {
            _end_time = value;
        }

        public function get time_zone():String {
            return _time_zone;
        }

        public function set time_zone(value:String):void {
            _time_zone = value;
        }

    }
}
