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

    /**
     * TODO: documentation
     */
    public class Main extends Sprite {
        private var _search_bar:InputTextField;
        private var _search_bar_card:Card;

        // DB login controls
        private var _db_login_prompt:Dialog;
        private var _db_login_username_field:InputTextField;
        private var _db_login_password_field:InputTextField;
        private var _db_login_submit_button:Button;

        private var _map_model:MapModel;
        private var _map_view:MapView;
        private var _map_controller:MapController;
        private var _apiman:APIRequestManager;
        private var _savedata:SaveData;


        public function Main() {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            DebugDaemon.init(stage.nativeWindow);
            Style.init(this);
            Font.init();

            _savedata = new SaveData();
            stage.nativeWindow.title = _savedata.application_title_extended;
            _apiman = new APIRequestManager();

            begin_auth();
            //init_map();
        }

        private function begin_auth():void {

            _db_login_prompt = new Dialog(this, "Login to Campus Maps");
            _db_login_username_field = new InputTextField(null, 0, 0, "username");
            _db_login_password_field = new InputTextField(null, 0, 0, "password");
            _db_login_password_field.display_as_password = true;
            _db_login_submit_button = new Button(null, 0, 0, "SUBMIT");
            _db_login_prompt.add_component(_db_login_username_field);
            _db_login_prompt.add_component(_db_login_password_field);
            _db_login_prompt.add_component(_db_login_submit_button);
            _db_login_prompt.set_size(300, 300);
            _db_login_prompt.draggable = false;

            _db_login_submit_button.on_click.add(on_login_form_submit);

        }

        private function on_login_form_submit(e:MouseEvent):void {
            DebugDaemon.write_debug("attempting to connect to sql server as %s...", _db_login_username_field.text);
            // TODO: submit form to api endpoint, wait for response
            _apiman.data_format = URL.DATA_FORMAT_TEXT;
            _apiman.use_port = false;
            _apiman.on_result_signal.add(on_login_result);
            _apiman.send_https_request("https://google.com");
            //File.applicationDirectory.resolvePath('data').resolvePath('app_db.json').nativePath
            // wait for response

        }

        private function on_login_result(result:String):void {
            init_map(JSON.parse(result));
        }

        private function init_map(json:Object):void {
            _map_model = new MapModel();
            _map_view = new MapView(stage);
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
