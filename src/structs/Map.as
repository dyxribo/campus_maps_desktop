package structs {

    import avmplus.getQualifiedClassName;

    import flash.utils.Dictionary;

    import net.blaxstar.starlib.debug.DebugDaemon;

    public class Map {
        private var _key_type:Class;
        private var _val_type:Class;
        private var _dict:Dictionary;
        private var _dict_size:uint;
        private var _overwrite:Boolean;

        // TODO: REMOVE DEBUG STUFF
        public function Map(key_class:Class, val_class:Class) {
            _key_type = key_class;
            _val_type = val_class;
            _dict = new Dictionary();
        }

        public function put(key:Object, value:Object):void {
            if (validate(key, value)) {
                if (!_overwrite) {
                    if (!has(key)) {
                        if (_key_type == String) {
                            key = String(key).toLowerCase();
                        }
                        _dict[key] = value;
                        ++_dict_size;
                    } else {
                        // KEY EXISTS
                        DebugDaemon.write_log("couldn't put item in Map: the specified key already exists: %s", DebugDaemon.WARN, key);
                    }
                } else {
                    // SET THE KEYS VALUE, SINCE OVERWRITING MEANS NO NEED TO CHECK
                    _dict[key] = value;
                }
            } else {
                // INCORRECT TYPE(S)
                DebugDaemon.write_error("error when putting object in Map: incorrect types were provided. " + "\nexpected: <%s, %s>; got: <%s, %s>", _key_type, _val_type, getQualifiedClassName(key), getQualifiedClassName(value));
            }
        }

        public function pull(key:Object):Object {
            if (has(key)) {
                if (key is String) {
                    key = String(key).toLowerCase();
                }
                return _dict[key];
            } else {
                return undefined;
            }
        }

        public function has(key:Object):Boolean {
            if (key is String) {
                key = String(key).toLowerCase();
            }
            return !!_dict[key];
        }

        public function toss(plate_id:String):Boolean {
            if (!has(plate_id))
                return false;
            delete _dict[plate_id];
            --_dict_size;
            return true;
        }

        public function get size():uint {
            return _dict_size;
        }

        public function get overwrite():Boolean {
            return _overwrite;
        }

        public function set overwrite(value:Boolean):void {
            _overwrite = value;
        }

        public function get_dictionary():Dictionary {
            return _dict;
        }

        public function keys():Array {
            var keys_array:Array = [];
            iterate(function(key:*, val:*):void {
                keys_array.push(key);
            });
            return keys_array;
        }

        public function values():Array {
            var values_array:Array = [];
            iterate(function(key:*, val:*):void {
                values_array.push(val);
            });
            return values_array;
        }

        public function literal(param:Array):Map {
            for (var i:uint = 0; i < param.length; i++) {
                var current_tuple:Array = param[i];
                if (current_tuple.length != 2) {
                    DebugDaemon.write_warning("error creating Map from Literal Object (array item number %s): " + "the format is incorrect. " + "valid input is an array of tuples.", i);
                } else {
                    if (validate(current_tuple[0], current_tuple[1])) {
                        put(current_tuple[0], current_tuple[1]);
                    } else {
                        DebugDaemon.write_error("could not add literal key/value pair to map (array item %s: [%s, %s]): the one of the parameter types are incorrect.", i, current_tuple[0], current_tuple[1]);
                    }
                }
            }
            return this;
        }

        public function iterate(for_each:Function):void {
            for (var key:* in _dict) {
                var itm:* = _dict[key];
                for_each.apply(null, [key, itm]);
            }
        }

        public function destroy():void {
            iterate(function delete_all(key:String, item:*):void {
                delete _dict[key];
            });
        }

        private function validate(key:Object, value:Object):Boolean {
            return key is _key_type && value is _val_type;
        }
    }
}
