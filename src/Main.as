package {

import debug.DebugDaemon;

import flash.display.Bitmap;
import flash.display.Sprite;
import geom.Point;

import net.blaxstar.components.Card;

import net.blaxstar.components.InputTextField;
import net.blaxstar.input.InputEngine;
import net.blaxstar.style.Style;
import structs.Building;
import structs.Floor;
import structs.MappableDesk;
import structs.Subsection;

public class Main extends Sprite {

    private var _search_bar:InputTextField;
    private var _search_bar_card:Card;


    public function Main() {
        init();
    }

    private function init():void {
        DebugDaemon.init();
        Style.init(Style.LIGHT, this);
        init_campus_data();
    }

    private function display_ui():void {

    }

    private function init_campus_data():void {
        var _current_location:Building = new Building("32OS");
        _current_location.add_floor(new Floor("32OS_11F"));
        _current_location.get_floor("32OS_11F").add_subsection(new Subsection("32OS_11F_WEST"));
        _current_location.get_floor("32OS_11F").get_subsection("32OS_11F_WEST").add_item(new MappableDesk("11W020"));

        DebugDaemon.write_log(JSON.stringify(_current_location.write_json()));
    }
}
}
