package structs {

  import avmplus.getQualifiedClassName;

  import debug.DebugDaemon;

  import flash.utils.Dictionary;

  public class Map {
    private var key_type:Class;
    private var val_type:Class;
    private var _dict:Dictionary;
    private var _dict_size:uint;
    private var _overwrite:Boolean;

    public function Map(key_class:Class, val_class:Class) {
      key_type = key_class;
      val_type = val_class;
      _dict = new Dictionary();
    }

    public function put(key:Object, value:Object):void {
      if (validate(key, value)) {
        if (!_overwrite) {
          if (!has(key)) {
            _dict[key] = value;
            ++_dict_size;
          }
          else {
            // KEY EXISTS
            DebugDaemon.write_log("couldn't put item in Map: the specified key already exists.", DebugDaemon.WARN);
          }
        }
        else {
          // SET THE KEYS VALUE SINCE OVERWRITING MEANS NO NEED TO CHECK
          _dict[key] = value;
        }
      }
      else {
        // INCORRECT TYPE(S)
        DebugDaemon.write_log("error when putting object in Map: incorrect types were provided. " +
            "\nexpected: <%s, %s>; got: <%s, %s>", DebugDaemon.ERROR_MISUSE, key_type, val_type,
            getQualifiedClassName(key), getQualifiedClassName(value));
      }
    }

    public function pull(key:Object):Object {
      if (has(key)) {
        return _dict[key];
      }
      else {
        return undefined;
      }
    }

    public function has(key:Object):Boolean {
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

    public function get_dictionary():Dictionary {
      return _dict;
    }

    public function literal(param:Array):Map {
      for (var i:uint = 0; i < param.length; i++) {
        var current_tuple:Array = param[i];
        if (current_tuple.length != 2) {
          DebugDaemon.write_log("error creating Map from Literal Object (array item number %s): " +
              "the format is incorrect. " + "valid input is an array of tuples.", DebugDaemon.WARN, i);
        }
        else {
          if (validate(current_tuple[0], current_tuple[1])) {
            put(current_tuple[0], current_tuple[1]);
          }
          else {
            DebugDaemon.write_log("could not add literal key/value pair to map: the one of the " +
                "parameter types are incorrect.");
          }
        }
      }
      return this;
    }

    private function validate(key:Object, value:Object):Boolean {
      return key is key_type && value is val_type;
    }
  }
}
