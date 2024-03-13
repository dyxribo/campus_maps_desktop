package structs.location {
    import flash.utils.Dictionary;

    import geom.Point;

    import net.blaxstar.starlib.debug.DebugDaemon;

    import structs.Map;
    import structs.workhours.WorkHours;

    public class MappableUser extends MappableItem {
        private var _first_name:String;
        private var _last_name:String;
        private var _full_name:String;
        private var _username:String;
        private var _email:String;
        private var _desk_phone:String;
        private var _mobile_phone:String;
        private var _team_name:String;
        private var _work_hours:WorkHours;
        private var _domain_string:String;
        /**  possible values are EMP, CONS & AGENCY, which are employee, consultant/temp & vendor, respectively. */
        private var _staffing_type:String;
        private var _title:String;
        /** this is actually a stringified int */
        private var _business_criticality:String;
        private var _is_vip:Boolean;

        private var _desks:Map;
        private var _assets:Map;

        // TODO: user photos?
        // TODO: REMOVE DEBUG STUFF
        public function MappableUser() {
            this.type = MappableItem.ITEM_USER;

            super();
        }

        public function add_desk(desk_id:String):Boolean {
            if (!_desks) {
                _desks = new Map(String, String);
            }
            if (this._desks.has(desk_id)) {
                DebugDaemon.write_warning("error adding desk: the referenced desk already exists for this user (%s, %s).", desk_id, this._username);
                return false;
            } else {
                this._desks.put(desk_id, desk_id);
            }
            return true;
        }

        public function get_desk_id(desk_id:String):String {
            if (_desks.has(desk_id)) {
                return _desks.pull(desk_id) as String;
            }
            return null;
        }

        public function add_asset(asset_id:String):Boolean {
            if (!_assets) {
                _assets = new Map(String, String);
            }
            if (this._assets.has(asset_id)) {
                DebugDaemon.write_warning("error adding asset: the referenced asset already exists for this user (%s, %s).", asset_id, this._username);
                return false;
            } else {
                this._assets.put(asset_id, asset_id);
            }
            return true;
        }

        public function populate_all(first_name:String, last_name:String, username:String, email:String, phone:String, team_name:String, work_hours:WorkHours, is_vip:Boolean):MappableUser {
            _first_name = first_name;
            _last_name = last_name;
            _username = username;
            _email = email;
            _mobile_phone = phone;
            _team_name = team_name;
            _work_hours = work_hours;
            _is_vip = is_vip;
            this.id = username;
            return this;
        }

        static public function read_json(json:Object):MappableUser {
            var user:MappableUser = new MappableUser();
            user.id = json.username;
            user.username = json.username;
            user.email = json.email;
            user.desk_phone = json.desk_phone
            user.mobile_phone = json.mobile_phone;
            // TODO: figure out a way to sync this prop from server
            user.work_hours = WorkHours.read_json(json.work_hours);
            user.full_name = json.full_name;
            user.first_name = json.first_name;
            user.last_name = json.last_name;
            user.domain_string = json.domain_string;
            user.staffing_type = json.staffing_type;
            user.title = json.title;
            user.business_criticality = json.business_criticality;

            for (var id:String in json.desks) {
                user.add_desk(id);
            }

            for (id in json.assets) {
                user.add_asset(id);
            }
            return user;
        }

        override public function write_json():Object {
            var json:Object = super.write_json();

            json.username = this._username;
            json.email = this._email;
            json.phone = this._mobile_phone;
            json.work_hours = this._work_hours;
            json.full_name = this._full_name;
            json.domain_string = this._domain_string;
            json.staffing_type = this._staffing_type;
            json.title = this._title;
            json.business_criticality = this._business_criticality;
            json.desks = {};
            json.assets = {};

            var desk_dict:Dictionary = _desks.get_dictionary();
            var asset_dict:Dictionary = _assets.get_dictionary();

            _desks.iterate(function(key:*, val:*):void {
                json.desks[key] = val;
            });

            _assets.iterate(function(key:*, val:*):void {
                json.assets[key] = val;
            });

            return json;
        }

        override public function set id(value:String):void {
            user_lookup.toss(this._id);
            item_id = this._id = _username = value;
            user_lookup.put(this._id, this);
        }

        public function get first_name():String {
            return this._first_name;
        }

        public function set first_name(value:String):void {
            this._first_name = value;
        }

        public function get last_name():String {
            return this._last_name;
        }

        public function set last_name(value:String):void {
            this._last_name = value;
        }

        public function get username():String {
            return this._username;
        }

        public function set username(value:String):void {
            this._username = value;
        }

        public function get email():String {
            return this._email;
        }

        public function set email(value:String):void {
            this._email = value;
        }

        public function get desk_phone():String {
            return this._desk_phone;
        }

        public function set desk_phone(value:String):void {
            this._desk_phone = value;
        }

        public function get mobile_phone():String {
            return this._mobile_phone;
        }

        public function set mobile_phone(value:String):void {
            this._mobile_phone = value;
        }

        public function get work_hours():WorkHours {
            return this._work_hours;
        }

        public function set work_hours(value:WorkHours):void {
            this._work_hours = value;
        }

        public function get full_name():String {
            return this._full_name;
        }

        public function set full_name(value:String):void {
            this._full_name = value;
        }

        public function get domain_string():String {
            return this._domain_string;
        }

        public function set domain_string(value:String):void {
            this._domain_string = value;
        }

        public function get staffing_type():String {
            return this._staffing_type;
        }

        public function set staffing_type(value:String):void {
            this._staffing_type = value;
        }

        public function get title():String {
            return this._title;
        }

        public function set title(value:String):void {
            this._title = value;
        }

        public function get business_criticality():String {
            return this._business_criticality;
        }

        public function set business_criticality(value:String):void {
            this._business_criticality = value;
        }

        public function get is_vip():Boolean {
            return this._is_vip;
        }

        public function set is_vip(value:Boolean):void {
            this._is_vip = value;
        }

        public function get desks():Array {
            return (_desks) ? _desks.values() : [];
        }

        public function get assets():Array {
            return (_desks) ? _assets.values() : [];
        }
    }

}
