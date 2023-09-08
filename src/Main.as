package {

    import debug.DebugDaemon;

    import flash.display.Sprite;

    import net.blaxstar.starlib.components.Card;

    import net.blaxstar.starlib.components.InputTextField;
    import net.blaxstar.starlib.style.Style;
    import structs.Building;
    import structs.Floor;
    import structs.MappableDesk;
    import structs.Subsection;
    import structs.ItemMap;
    import net.blaxstar.starlib.networking.APIRequestManager;
    import net.blaxstar.starlib.components.Dialog;
    import flash.events.Event;
    import net.blaxstar.starlib.components.Button;
    import flash.events.MouseEvent;
    import net.blaxstar.starlib.style.Font;
    import net.blaxstar.starlib.io.URL;
    import debug.printf;
    import config.SaveData;
    import flash.display.StageScaleMode;
    import flash.display.StageAlign;
    import structs.MappableUser;
    import geom.Point;

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

        private var _item_map:ItemMap;
        private var _apiman:APIRequestManager;
        private var _savedata:SaveData;


        public function Main() {
            _savedata = new SaveData();
            stage.nativeWindow.title = _savedata.application_title_extended;

            _apiman = new APIRequestManager();
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            DebugDaemon.init(stage.nativeWindow);
            Style.init(this);
            Font.init();

            //begin_auth();
            init_map();
        }

        private function begin_auth():void {
            _db_login_prompt = new Dialog(this, "Login to Campus Maps");

            _db_login_username_field = new InputTextField(null, 0, 0, "username");
            _db_login_password_field = new InputTextField(null, 0, 0, "password");
            _db_login_password_field.display_as_password = true;
            _db_login_submit_button = new Button(null, 0, 0, "SUBMIT");

            _db_login_prompt.addComponent(_db_login_username_field);
            _db_login_prompt.addComponent(_db_login_password_field);
            _db_login_prompt.addComponent(_db_login_submit_button);
            _db_login_prompt.set_size(300, 300);
            _db_login_prompt.draggable = false;

            _db_login_submit_button.on_click.add(on_login_form_submit);
        }

        private function on_login_form_submit(e:MouseEvent):void {
            DebugDaemon.write_log("attempting to connect to sql server as %s...", DebugDaemon.DEBUG, _db_login_username_field.text);
            // submit form
            _apiman.expected_data_type = URL.TEXT;
            _apiman.on_result_signal.add(on_login_result);
            _apiman.query("testquery");
            // wait for response
        }

        private function init_map():void {
            init_map_display();
            init_campus_data();
        }

        private function init_map_display():void {
            _item_map = new ItemMap(_savedata);
            addChild(_item_map);
        }

        private function init_campus_data():void {
            var json:Object = {
              panned: true,
              pan_position: {
                x: 1058,
                y: 127
              },
              buildings: {

              }
            };
            var current_location:Building = new Building();
            var fl:Floor = new Floor();
            var ss_w:Subsection = new Subsection();
            var desk:MappableDesk = new MappableDesk();
            var user:MappableUser = new MappableUser();
            user.email = "dyxribo@google.com";
            user.id = "dyxribo";
            user.phone = "3478336485";
            user.work_hours = { start_time: 10, end_time: 6, time_zone: "est"};
            user.position = new Point(1058, 127);
            fl.id = "11F";
            ss_w.id = "WEST";
            desk.id = "11W020";
            desk.assignee = "dyxribo";
            current_location.id = "32OS";
            current_location.add_floor(fl);
            fl.add_subsection(ss_w);
            ss_w.add_item(user);
            ss_w.add_item(desk);
            json.buildings[current_location.id] = current_location.write_json();
            _item_map.read_json(json);
            _item_map.set_location(fl.link);
            trace(_item_map.search("11W020")[0].item_id);

            // TODO| load default map graphic from savedata, otherwise load last
            // TODO| visited location via set_location.



            DebugDaemon.write_log(desk.link);
        }

        private function on_login_result(result:String):void {
            DebugDaemon.write_log("login request complete. got: %s", DebugDaemon.DEBUG, result);
        }
    }
}
