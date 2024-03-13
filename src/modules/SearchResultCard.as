package modules {
    import net.blaxstar.starlib.components.Card;
    import models.MapSearchResult;
    import net.blaxstar.starlib.components.PlainText;
    import net.blaxstar.starlib.components.Button;
    import flash.events.MouseEvent;
    import net.blaxstar.starlib.components.Icon;
    import net.blaxstar.starlib.components.Component;
    import flash.events.Event;
    import net.blaxstar.starlib.components.ListItem;
    import structs.Map;

    public class SearchResultCard extends Card {
        private var _result_display_cache:Vector.<ListItem>;
        private var _previous_view_button:Button;
        private var _close_card_button:Button;

        public function SearchResultCard() {
            super();
            mouseEnabled = false;
            mouseChildren = true;
        }

        override public function draw(e:Event = null):void {
            super.draw();
            component_container.move(PADDING * 4, PADDING * 4);
        }

        public function set_search_results(results:Vector.<MapSearchResult>):void {
            // cache all previous result displays and remove listeners
            var num_result_display:int = component_container.numChildren;
            for (var i:int = 0; i < num_result_display; i++) {
                var item:ListItem = component_container.getChildAt(i) as ListItem;
                if (item.data.hasOwnProperty("type")) {
                    if (item.data.type == MapSearchResult.USER) {
                        item.removeEventListener(MouseEvent.CLICK, on_user_click);
                    } else {
                        item.removeEventListener(MouseEvent.CLICK, on_location_click);
                    }
                    _result_display_cache.push(item);
                }
            }

            component_container.removeChildren();
            // init cache if null
            if (!_result_display_cache) {
                _result_display_cache = new Vector.<ListItem>();
            }

            var num_results:int = results.length;
            // loop through all results
            for (var j:int = 0; j < num_results; j++) {
                var result:MapSearchResult = results[j];
                var result_display:ListItem;
                // if the cache has any objects we can reuse, do so
                if (_result_display_cache.length > 0) {
                    result_display = _result_display_cache.pop();
                    result_display.label = result.label;
                } else {
                    result_display = new ListItem(null, 0, 0, result.label);
                }
                result_display.data = {type: result.type};
                add_child_to_container(result_display);
                result_display.mouseEnabled = true;
                // if the search result is a user, then we can show the info in the card itself, otherwise, we can pan the map to the location
                if (result.type == MapSearchResult.USER) {
                    result_display.addEventListener(MouseEvent.CLICK, on_user_click);
                } else {
                    result_display.addEventListener(MouseEvent.CLICK, on_location_click);
                }
            }

            if (!_close_card_button) {
                _close_card_button = new Button();
                _close_card_button.icon = Icon.CLOSE;
                _close_card_button.on_click.add(on_close_card);
            }

            add_child_native(_close_card_button);

        }

        public function close():void {
            on_close_card();
        }

        private function on_user_click(e:MouseEvent):void {
            if (!_previous_view_button) {
                _previous_view_button = new Button();
                _previous_view_button.icon = Icon.ARROW_BACK;
                _previous_view_button.on_click.add(on_previous_button_click);
            }
            add_child_native(_previous_view_button);
            removeChild(_close_card_button);
            removeChild(component_container);
        }

        private function on_location_click(e:MouseEvent):void {
        }

        private function on_previous_button_click(e:MouseEvent):void {
            add_child_native(component_container);
            add_child_native(_close_card_button);
            removeChild(_previous_view_button);
        }

        private function on_close_card(e:MouseEvent = null):void {
            parent.removeChild(this);
        }
    }
}
