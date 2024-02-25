package structs {
    import debug.DebugDaemon;

    import geom.Point;
    import structs.MappableItem;
    import flash.utils.Dictionary;
    import structs.workhours.WorkHours;

    public class MappableUser extends MappableItem {
        private var _first_name:String;
        private var _last_name:String;
        private var _full_name:String;
        private var _username:String;
        private var _email:String;
        private var _phone:String;
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
        private var _desk_vector_cache:Vector.<MappableDesk>;
        private var _asset_vector_cache:Vector.<MappableMachine>;

        // TODO: user photos?

        public function MappableUser() {
            this.type = MappableItem.ITEM_USER;
            this._username = '';
            this._email = '';
            this._phone = '';
            this._work_hours = new WorkHours();
            this._desks = new Map(String, MappableDesk);
            this._assets = new Map(String, MappableMachine);

            super();
        }

        public function add_desk(desk:MappableDesk):Boolean {
            if (!_desk_vector_cache) {
                _desk_vector_cache = new Vector.<MappableDesk>();
            }
            if (this._desks.has(desk.id)) {
                DebugDaemon.write_log("error adding desk: the referenced desk already exists for this user.", DebugDaemon.WARN);
                return false;
            } else {
                this._desks.put(desk.id, desk);
                this._desk_vector_cache.push(desk);
            }
            return true;
        }

        public function get_desk(desk_id:String):MappableDesk {
            if (_desks.has(desk_id)) {
                return _desks.pull(desk_id) as MappableDesk;
            }
            return null;
        }

        public function add_asset(asset:MappableMachine):Boolean {
            if (!_asset_vector_cache) {
                _asset_vector_cache = new Vector.<MappableMachine>();
            }
            if (this._assets.has(asset.id)) {
                DebugDaemon.write_log("error adding asset: the referenced asset already exists for this user.", DebugDaemon.WARN);
                return false;
            } else {
                this._assets.put(asset.id, asset);
                _asset_vector_cache.push(asset);
            }
            return true;
        }

        public function populate_all(first_name:String, last_name:String, username:String, email:String, phone:String, team_name:String, work_hours:WorkHours, is_vip:Boolean):MappableUser {
            _first_name = first_name;
            _last_name = last_name;
            _username = username;
            _email = email;
            _phone = phone;
            _team_name = team_name;
            _work_hours = work_hours;
            _is_vip = is_vip;
            id = username;
            return this;
        }

        static public function read_json(json:Object):MappableUser {
            var item:MappableUser = new MappableUser();
            item.id = json.id;
            item.position = Point.read_json(json.position);
            item.username = json.username;
            item.email = json.email;
            item.phone = json.phone;
            item.work_hours = json.work_hours;

            for (var id:String in json.desks) {
                var desk:MappableDesk = MappableDesk.read_json(json.desks[id]);
                item.add_desk(desk);
            }

            for (id in json.assets) {
                var asset:MappableMachine = MappableMachine.read_json(json.assets[id]);
                item.add_asset(asset);
            }

            return item;
        }

        override public function write_json():Object {
            var json:Object = super.write_json();

            json.username = this.username;
            json.email = this.email;
            json.phone = this.phone;
            json.work_hours = this.work_hours;

            var desk_dict:Dictionary = _desks.get_dictionary();
            var asset_dict:Dictionary = _assets.get_dictionary();

            for (var desk:MappableDesk in desk_dict) {
                json.desks[desk.id] = desk.write_json();
            }

            for (var asset:MappableMachine in asset_dict) {
                json.assets[asset.id] = asset.write_json();
            }
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

        public function get phone():String {
            return this._phone;
        }

        public function set phone(value:String):void {
            this._phone = value;
        }

        /**
         * start_time: uint, end_time: uint, time_zone: String
         * */
        public function get work_hours():WorkHours {
            return this._work_hours;
        }

        /**
         * start_time: uint, end_time: uint, time_zone: String
         * */
        public function set work_hours(value:WorkHours):void {
            this._work_hours = value;
        }

        public function get desks():Vector.<MappableDesk> {
            return _desk_vector_cache;
        }

        public function get assets():Vector.<MappableMachine> {
            return _asset_vector_cache;
        }
    }

}
