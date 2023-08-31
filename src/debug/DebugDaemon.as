package debug {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.display.NativeWindow;
import flash.events.Event;

public class DebugDaemon {
    private static const LOG_FILE:File = new File(File.applicationStorageDirectory.nativePath + File.separator + "campus_maps_admin.log");
    public static const OK:uint = 0;
    public static const DEBUG:uint = 1;
    public static const WARN:uint = 2;
    public static const ERROR_GENERIC:uint = 3;
    public static const ERROR_IO:uint = 4;
    public static const ERROR_MISUSE:uint = 5;

    private static var _instance:DebugDaemon;
    private static var _log:Vector.<String>;
    private static var _filestream:FileStream;
    /**
     * TODO: class documentation
     */
    public function DebugDaemon() {
        if (_instance) {
            throw new Error("class is a singleton instance. use DebugDaemon.get_instance().");
        }
        _log = new Vector.<String>();
        _filestream = new FileStream();
    }

    static public function  init(window:NativeWindow=null):void {
        _instance = _instance ? _instance : new DebugDaemon();
        if (window) {
          window.addEventListener(Event.CLOSE, on_app_close);
        }
    }

    static public function get_instance():DebugDaemon {
        if (!_instance) {
            init();
        }

        return _instance;
    }

    static public function write_log(message: String, severity:uint=DebugDaemon.DEBUG, ...format):void {
        var prefix:String = "[".concat(new Date().toUTCString()).concat("]");
        var full_message:String = "";

        switch (severity) {
            case OK:
                prefix = prefix.concat("[OK]");
                break;
            case DEBUG:
                prefix = prefix.concat("[DEBUG]");
                break;
            case WARN:
                prefix = prefix.concat("[WARN]");
                break;
            case ERROR_GENERIC:
            case ERROR_IO:
            case ERROR_MISUSE:
                prefix = prefix.concat("[ERROR]");
                break;
        }
        full_message = printf(prefix.concat(" ").concat(message), format);
        _log.push(full_message);

        if (severity == ERROR_MISUSE || severity == ERROR_IO || severity == ERROR_GENERIC) {
            flush_log();
            throw new Error(full_message, severity);
        }
    }

    static public function flush_log():Boolean {
        _filestream.open(LOG_FILE, FileMode.APPEND);
        for (var i:uint = 0; i < _log.length; i++) {
            try {
                _filestream.writeUTFBytes(_log[i].concat("\n"));
            } catch (e:Error) {
                write_log("error writing log file: %s", DebugDaemon.ERROR_IO, e.message);
            }

        }
        _filestream.close();
        return true;
    }

    static private function on_app_close(e:Event):void {
      write_log("application terminated successfully.", OK);
      flush_log();
    }
}
}
