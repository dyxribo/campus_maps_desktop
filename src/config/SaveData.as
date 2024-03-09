package config {
    import net.blaxstar.starlib.io.URL;
    import net.blaxstar.starlib.io.IOUtil;
    import flash.filesystem.File;
    import flash.utils.ByteArray;
    import flash.net.registerClassAlias;

import net.blaxstar.starlib.io.XLoader;

import thirdparty.org.osflash.signals.Signal;
    import flash.utils.Dictionary;

    public class SaveData {
        static private const VERSION_MAJOR:uint = 0;
        static private const VERSION_MINOR:uint = 9;
        static private const VERSION_REVISION:uint = 1559;
        static private const FILE_EXTENSION:String = '.json';

        public const ON_SAVE:Signal = new Signal();
        public const ON_LOAD:Signal = new Signal();
        public const ON_CLEARED:Signal = new Signal();
        public const ON_INITIALIZED:Signal = new Signal();

        private var _configuration_file_name:String;
        private var _settings:Dictionary;
        private var _loader:XLoader;

        public function SaveData() {
            _configuration_file_name = 'config';
            _loader = new XLoader();

            init();
        }

        public function init():void {
          _settings = new Dictionary();
          _settings['first_run'] = true;
          _settings['current_locale'] = 'en_us';
          _settings['last_location'] = '';
          _settings['map_data_mod_date'] = '';

          if (exists) {
            load();
          } else {
            save();
          }
        }

        public function save():void {
            var json:Object = {};
            var saveBytes:ByteArray = new ByteArray();

            for (var key:String in _settings) {
              json[key] = _settings[key];
            }

            saveBytes.writeUTFBytes(JSON.stringify(json));
            IOUtil.exportFile(saveBytes, _configuration_file_name, FILE_EXTENSION, File.applicationDirectory.nativePath, on_write_out);
        }

        public function clear():void {
            File.applicationDirectory.resolvePath(_configuration_file_name).deleteFile();

            for (var key:String in _settings) {
                _settings[key] = null;
            }
            ON_CLEARED.dispatch();
        }

        public function load():void {
            var url:URL = new URL(File.applicationDirectory.resolvePath(_configuration_file_name).nativePath + FILE_EXTENSION, undefined, true);

            _loader.ON_COMPLETE.add(on_load_in);
            _loader.queue_files(url);
        }

        private function create_save_data():void {
            _settings = new Dictionary();
            current_locale = "en_US";
            save();
            ON_INITIALIZED.dispatch();
        }

        private function on_load_in(data:ByteArray):void {
            _loader.ON_COMPLETE.remove(on_load_in);
            _settings = to_dictionary(JSON.parse(data.readUTFBytes(data.bytesAvailable)));
            ON_LOAD.dispatch();
        }

        private function on_write_out(return_code:uint):void {
            if (return_code == 0) {
                ON_SAVE.dispatch();
            }
        }

        private function to_dictionary(json:Object):Dictionary {
            for (var key:String in json) {
                _settings[key] = json[key];
                delete json[key];
            }
            return _settings;
        }
        // getters; setters /////////////////////////////////////////////////////////////////////////////////////

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
          return File.applicationDirectory.resolvePath(_configuration_file_name).exists;
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
