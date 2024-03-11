package modules {
    import flash.display.Sprite;
    import net.blaxstar.starlib.components.InputTextField;
    import net.blaxstar.starlib.components.Card;
    import flash.events.Event;
    import net.blaxstar.starlib.components.Component;
    import net.blaxstar.starlib.components.Button;
    import net.blaxstar.starlib.components.HorizontalBox;
    import net.blaxstar.starlib.components.Icon;
    import flash.events.MouseEvent;
    import thirdparty.org.osflash.signals.Signal;

    public class Searchbar extends Sprite {
        private var _search_card:Card;
        private var _layout_box:HorizontalBox;
        private var _search_input:InputTextField;
        private var _search_button:Button;
        private var _input_string:String;
        private var _search_dispatcher:Signal;

        public function Searchbar() {
            init();
        }

        private function init():void {
            _search_dispatcher = new Signal(String);
            add_children();
        }

        private function add_children():void {
            _search_card = new Card(this);
            _layout_box = new HorizontalBox();
            _search_input = new InputTextField();
            _search_button = new Button();
            _search_button.icon = Icon.SEARCH;
            _search_button.on_click.add(on_search_button_click);
            _search_card.auto_resize = false;
            _search_input.hint_text = "Search Location or Item...";

            _layout_box.addChild(_search_input);
            _layout_box.addChild(_search_button);
            _search_card.add_child_to_container(_layout_box);

            _search_card.component_container.move(Component.PADDING, Component.PADDING);
            _search_card.set_size((Component.PADDING * 2) + _layout_box.width, (Component.PADDING * 2) + _layout_box.height);
            addChild(_search_card);
        }

        private function on_search_button_click(e:MouseEvent):void {
            // * obtain and dispatch search results
            if (!_search_dispatcher) {
                _search_dispatcher = new Signal(String);
            }
            _search_dispatcher.dispatch(_search_input.text);
        }

        private function draw():void {
            width = _search_card.width;
            height = _search_card.height;
        }

        public function get search_signal():Signal {
            return _search_dispatcher;
        }

    }
}
