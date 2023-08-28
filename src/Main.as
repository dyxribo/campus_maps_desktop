package {

import debug.DebugDaemon;

import flash.display.Sprite;

import net.blaxstar.components.Card;

import net.blaxstar.components.InputTextField;
import net.blaxstar.style.Style;
import structs.Building;
import structs.Floor;
import structs.MappableDesk;
import structs.Subsection;
import structs.ItemMap;
import net.blaxstar.networking.APIRequestManager;
import net.blaxstar.components.Dialog;
import flash.events.Event;
import net.blaxstar.components.Button;
import flash.events.MouseEvent;
import net.blaxstar.style.Font;
import net.blaxstar.io.URL;
import debug.printf;
import config.SaveData;
import flash.display.StageScaleMode;
import flash.display.StageAlign;

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

    private function init(e:Event=null):void {
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
      _db_login_prompt.setSize(300,300);
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


        var _current_location:Building = new Building("32OS");
        _current_location.add_floor(new Floor("32OS_11F"));
        _current_location.get_floor("32OS_11F").add_subsection(new Subsection("32OS_11F_WEST"));
        _current_location.get_floor("32OS_11F").get_subsection("32OS_11F_WEST").add_item(new MappableDesk("11W020"));

        DebugDaemon.write_log(JSON.stringify(_current_location.write_json()));
    }

    private function on_login_result(result:String):void {
      DebugDaemon.write_log("login request complete. got: %s", DebugDaemon.DEBUG, result);
    }
}
}
