package structs.location {
    import flash.utils.Dictionary;

    import structs.Map;
    import geom.Point;

    public class WallPlate extends MappableItem {
        static private var _plate_lookup:Map;

        static private var _plates:Map;
        static private var _jacks:Map;

        public function WallPlate() {

            type = MappableItem.ITEM_WALL_PLATE;
            _plates = new Map(String, WallPlate);
            _jacks = new Map(String, WallJack);

            super();
            add_to_directory(this);
        }

        public function add_plate(plate:WallPlate):Boolean {
            if (_plates.has(plate.id)) {
                // TODO: error adding plate
                return false;
            } else {
                _plates.put(plate.id, plate);
            }
            return true;
        }

        public function remove_plate(plate_id:String):Boolean {
            if (_plates.has(plate_id)) {
                _plates.toss(plate_id);
                return true;
            } else {
                // TODO: error removing plate
                return false;
            }
        }

        public function add_jack(jack:WallJack):Boolean {
            if (_jacks.has(jack.id)) {
                // TODO: error adding jack
                return false;
            } else {
                _jacks.put(jack.id, jack);
            }
            return true;
        }

        public function remove_jack(jack_id:String):Boolean {
            if (_jacks.has(jack_id)) {
                _jacks.toss(jack_id);
                return true;
            } else {
                // TODO: write error
                return false;
            }
        }

        override public function write_json():Object {
            var json:Object = super.write_json();

            var plates:Dictionary = _plates.get_dictionary();
            var jacks:Dictionary = _jacks.get_dictionary();

            for (var key:String in plates) {
                json.plates[key] = plates[key];
            }

            for (key in jacks) {
                json.jacks[key] = jacks[key];
            }

            return json;
        }

        static public function read_json(json:Object):WallPlate {
            var item:WallPlate = new WallPlate();
            item.id = json.id;
            item._position = Point.read_json(json.position);

            for (var plate:String in json.plates) {
                _plates.put(plate, json[plate]);
            }

            for (var jack:String in json.jacks) {
                _jacks.put(jack, json[jack]);
            }

            return item;
        }
    }

}
