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
    import com.sociodox.utils.Base64;
    import net.blaxstar.starlib.utils.StringUtil;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import models.AccessInjector;
    import thirdparty.com.lorentz.processing.ProcessExecutor;

    /**
     * TODO: documentation
     */
    public class Main extends Sprite {
        private const _MAP_DATA_FILEPATH:String = File.applicationDirectory.resolvePath('data').resolvePath('app_db.json').nativePath;

        // search
        private var _search_bar:InputTextField;
        private var _search_bar_card:Card;
        // DB login controls
        private var _db_login_prompt:Dialog;
        private var _db_login_username_field:InputTextField;
        private var _db_login_password_field:InputTextField;
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
            _savedata.ON_LOAD.add(load_map_data);

            stage.nativeWindow.title = _savedata.application_title_extended;
            _apiman = new APIRequestManager();
            _filestream = new FileStream();
            _savedata.load();

            //begin_auth();
        }

        private function begin_auth():void {

            _db_login_prompt = new Dialog(this, "Login to Campus Maps");
            _db_login_username_field = new InputTextField(null, 0, 0, "username");
            _db_login_password_field = new InputTextField(null, 0, 0, "password");
            _db_login_password_field.display_as_password = true;
            _db_login_submit_button = new Button(null, 0, 0, "SUBMIT");
            _db_login_prompt.addChild(_db_login_username_field);
            _db_login_prompt.addChild(_db_login_password_field);
            _db_login_prompt.addChild(_db_login_submit_button);
            _db_login_prompt.set_size(300, 300);
            _db_login_prompt.draggable = false;

            _db_login_submit_button.on_click.add(on_login_form_submit);

        }

        private function on_login_form_submit(e:MouseEvent):void {
            DebugDaemon.write_debug("attempting to connect to server as %s...", _db_login_username_field.text);
            // TODO: submit form to api endpoint, wait for response. exclusively for syncing asset data and updates from the server.
            _apiman.data_format = URL.DATA_FORMAT_TEXT;
            _apiman.fake_signal.add(test_on_login_result);
            _apiman.send_https_request("daiwa.test.com");
            // TODO: credentials; basic with hashing & token: https://github.com/charlesbihis/actionscript-oauth2
        }

        private function test_on_login_result(result:String):void {
            var decoded_response:String = Base64.decode(result).toString()
            if (!StringUtil.is_empty_or_null(decoded_response)) {
                login_success(result);

            } else {
                login_failure(result)
            }

            init_map(JSON.parse(result));
        }

        private function login_success(response:Object):void {

        }

        private function login_failure(response:Object):void {

        }

        private function load_map_data():void {
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
