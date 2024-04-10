package {

    import config.SaveData;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filesystem.File;

    import net.blaxstar.starlib.components.Button;
    import net.blaxstar.starlib.components.Card;
    import net.blaxstar.starlib.components.Dialog;
    import net.blaxstar.starlib.components.InputTextField;
    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.io.URL;
    import net.blaxstar.starlib.networking.APIRequestManager;
    import net.blaxstar.starlib.style.Font;
    import net.blaxstar.starlib.style.Style;

    import views.map.MapView;
    import models.MapModel;
    import controllers.MapController;
    import net.blaxstar.starlib.utils.StringUtil;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import models.AccessInjector;
    import thirdparty.com.lorentz.processing.ProcessExecutor;
    import thirdparty.com.hurlant.util.Base64;
    import net.blaxstar.starlib.networking.APIRequest;
    import net.blaxstar.starlib.style.Color;

    /**
     * TODO: documentation
     */
    public class Main extends Sprite {
        private const _MAP_DATA_FILEPATH:String = File.applicationDirectory.resolvePath('data').resolvePath('app_db.json').nativePath;

        // search
        private var _search_bar:InputTextField;
        private var _search_bar_card:Card;
        // DB login controls
        private var _login_prompt:Dialog;
        private var _login_username_field:InputTextField;
        private var _login_secret_field:InputTextField;
        private var _db_login_submit_button:Button;
        // map
        private var _map_model:MapModel;
        private var _map_view:MapView;
        private var _map_controller:MapController;
        private var _apiman:APIRequestManager;
        private var _savedata:SaveData;
        private var _filestream:FileStream;


        public function Main() {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            DebugDaemon.init(stage.nativeWindow);
            ProcessExecutor.instance.initialize(stage);
            Style.init(this);
            Font.init();

            _savedata = new SaveData();
            _savedata.ON_LOAD.add(begin_auth);

            stage.nativeWindow.title = _savedata.application_title_extended;
            _apiman = new APIRequestManager();
            _filestream = new FileStream();
            _savedata.load();
        }

        private function begin_auth():void {

            _login_prompt = new Dialog(this, "LOGIN TO CAMPUS MAPS");
            _login_username_field = new InputTextField(null, 0, 0, "username");
            _login_secret_field = new InputTextField(null, 0, 0, "password");
            _login_secret_field.display_as_password = true;

            _login_prompt.addChild(_login_username_field);
            _login_prompt.addChild(_login_secret_field);
            _login_prompt.auto_resize = true;
            _login_prompt.draggable = false;

            _login_prompt.move(stage.stageWidth / 2 + _login_prompt.width / 2, 0);


            _login_prompt.add_button("continue as guest", load_map_data, Button.DEPRESSED);
            _db_login_submit_button = _login_prompt.add_button("SUBMIT", on_login_form_submit, Button.GROUNDED);
        }

        private function on_login_form_submit(e:MouseEvent):void {
            DebugDaemon.write_debug("attempting to connect to server as %s...", _login_username_field.text);
            _login_prompt.message_color = Color.PRODUCT_BLUE.value;
            _login_prompt.message = "logging in...";
            _apiman.on_result_signal.add(on_login_result);

            var request:APIRequest = _apiman.build_https_request("blaxstar.net", "server", URL.REQUEST_METHOD_POST, URL.DATA_FORMAT_VARIABLES, "/api/login", null, null, URL.AUTH_BASIC, Base64.encode(_login_username_field.text + ":" + _login_secret_field.text));

            _apiman.send(request);
        }

        private function on_login_result(result:String):void {
            if (result.indexOf("200 OK") != -1) {
                login_success(result);
            } else {
                login_failure(result)
            }
        }

        private function login_success(response:Object):void {

        }

        private function login_failure(response:String):void {
            var server_message:String = JSON.parse(response.substring(response.indexOf("{\"message\":"), response.length)).message;

            _login_prompt.message_color = Color.PRODUCT_RED.value;
            _login_prompt.message = "login failed: " + server_message;
            DebugDaemon.write_debug("login failed. got:\n\n%s", response);
        }

        private function load_map_data(e:Event = null):void {
            _login_prompt.close();
            var map_data_file:File = new File(_MAP_DATA_FILEPATH);
            var map_data:String;
            _filestream.open(map_data_file, FileMode.READ);
            map_data = _filestream.readUTFBytes(_filestream.bytesAvailable);
            _filestream.close();
            init_map(JSON.parse(map_data));
        }

        private function init_map(json:Object):void {
            _map_model = new MapModel();
            _map_view = new MapView(new AccessInjector(stage, true));
            _map_controller = new MapController(_map_model, _map_view);

            load_campus_data(json);
            init_map_display();
        }

        private function init_map_display():void {
            addChild(_map_view);
        }

        private function load_campus_data(json:Object):void {
            // TODO: load app_db. initial sync of pc and usr json with api, integrating it with app_db. sync occasionally. if file changes, loop through users and machines to see what's new.
            _map_model.read_json(json);
        }


    }
}
