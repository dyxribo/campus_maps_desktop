package config {
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.Dictionary;

    import net.blaxstar.starlib.io.XLoader;

    import thirdparty.org.osflash.signals.Signal;

    public class SaveData {
        static private const VERSION_MAJOR:uint = 0;
        static private const VERSION_MINOR:uint = 9;
        static private const VERSION_REVISION:uint = 2109;
        static private const _CONFIG_FILE:File = File.applicationStorageDirectory.resolvePath("config.json");

        public const ON_SAVE:Signal = new Signal();
        public const ON_LOAD:Signal = new Signal();
        public const ON_CLEARED:Signal = new Signal();
        public const ON_INITIALIZED:Signal = new Signal();

        private var _settings:Dictionary;
        private var _loader:XLoader;
        private var _filestream:FileStream;

        public function SaveData() {
            _loader = new XLoader();

            _filestream = new FileStream();
            init();
        }

        public function init():void {
            _settings ||= new Dictionary();

            if (exists) {
                load();
            } else {
                _settings['first_run'] = true;
                _settings['current_locale'] = 'en_us';
                _settings['last_location'] = '';
                _settings['map_data_mod_date'] = '';
                save();
            }
        }

        public function save():void {
            var json:Object = {};

            for (var key:String in _settings) {
                json[key] = _settings[key];
            }
            var savedata_string:String = JSON.stringify(json);

            _filestream.open(_CONFIG_FILE, FileMode.WRITE);
            _filestream.writeUTFBytes(savedata_string);
            _filestream.close();

            ON_SAVE.dispatch();
        }

        public function clear():void {
            _CONFIG_FILE.deleteFile();

            for (var key:String in _settings) {
                _settings[key] = null;
            }

            ON_CLEARED.dispatch();
        }

        public function load():void {
            var savedata_string:String;

            _filestream.open(_CONFIG_FILE, FileMode.READ);
            savedata_string = _filestream.readUTFBytes(_filestream.bytesAvailable);
            _filestream.close();

            on_load_in(savedata_string);
        }

        private function create_save_data():void {
            _settings = new Dictionary();
            current_locale = "en_US";
            save();
            ON_INITIALIZED.dispatch();
        }

        private function on_load_in(savedata_string:String):void {
            var savedata_json:Object = JSON.parse(savedata_string);
            consume_json(savedata_json);
            ON_LOAD.dispatch();
        }

        private function consume_json(json:Object):Dictionary {
            for (var key:String in json) {
                _settings[key] = json[key];
                delete json[key];
            }
            return _settings;
        }

        // * GETTERS & SETTERS * //

        public function get application_title():String {
            return 'CAMPUS MAPS ADMIN';
        }

        public function get application_title_extended():String {
            return application_title + ' ' + version;
        }

        public function get version():String {
            return 'v' + VERSION_MAJOR.toString() + '.' + VERSION_MINOR.toString() + ' build ' + VERSION_REVISION.toString();
        }

        public function get exists():Boolean {
            return _CONFIG_FILE.exists;
        }

        /**
         * checks if this is the first time that the program was run.
         */
        public function get first_run():Boolean {
            return _settings.first_run;
        }

        public function set first_run(val:Boolean):void {
            _settings.first_run = val;
        }

        public function get current_locale():String {
            return _settings.current_locale;
        }

        public function set current_locale(val:String):void {
            _settings.current_locale = val;
        }

        public function get last_location():String {
            return _settings.last_location;
        }

        public function set last_location(val:String):void {
            _settings.last_location = val;
        }

        public function get map_data_mod_date():String {
            return _settings.mdmd;
        }

        public function set map_data_mod_date(val:String):void {
            _settings.mdmd = val;
        }
    }
}
