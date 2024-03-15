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
    import structs.location.MappableItem;
    import structs.location.MappableUser;
    import thirdparty.org.osflash.signals.Signal;
    import geom.Point;
    import views.dialog.UserDialogView;
    import views.dialog.BaseDialogView;

    public class SearchResultCard extends Card {
        static private const _ICON_SIZE:uint = 32;

        private var _previous_cache:Array;
        private var _result_display_cache:Vector.<SearchResultListItem>;
        private var _previous_view_button:Button;
        private var _close_card_button:Button;
        private var _position_dispatcher:Signal;

        public function SearchResultCard() {
            super();
            mouseEnabled = false;
            mouseChildren = true;
            _position_dispatcher = new Signal(String, Point);
            _previous_cache = [];
        }

        override public function draw(e:Event = null):void {
            // * have to move the component container first for everything to be positioned properly, as calculations are done with the containers' y property in mind.
            component_container.move(PADDING, (PADDING*2) + _ICON_SIZE)
            // auto resize if enabled
            if (auto_resize) {
                var totalW:Number = (PADDING * 2) + Math.max(component_container.width, option_container.width);
                var totalH:Number = (PADDING * 3) +
                component_container.height + option_container.height + _ICON_SIZE;

                if (totalW > MIN_WIDTH) {
                    _width_ = totalW;
                }
                if (totalH > MIN_HEIGHT) {
                    _height_ = totalH;
                }
            }
            dispatchEvent(new Event(Event.RESIZE));
            draw_background();

            option_container.move(PADDING, component_container.y + component_container.height + PADDING);
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
                _result_display_cache = new Vector.<SearchResultListItem>();
            }

            var num_results:int = results.length;
            // loop through all results
            for (var j:int = 0; j < num_results; j++) {
                var result:MapSearchResult = results[j];
                var result_item:MappableItem = result.data.item;
                var result_display:SearchResultListItem;
                // if the cache has any objects we can reuse, do so
                if (_result_display_cache.length > 0) {
                    result_display = _result_display_cache.pop();
                    result_display.label = result.label;
                } else {
                    result_display = new SearchResultListItem(result.label);
                }
                // set the object's properties based on type
                if (result_item is MappableUser) {
                  var result_user:MappableUser = result_item as MappableUser;
                  result_display.label = result_user.full_name + "\n" + result_user.email + "\n" + result_user.title;
                } else {
                  result_display.label = result_item.id + "\n" + result_item.type_string + "\n" + result_item.link;
                }
                result_display.data = {type: result.type};
                add_child_to_container(result_display);
                result_display.mouseEnabled = true;
                result_display.data.item = result_item;
                // * if the search result is a user, then we can show the info in the card itself, otherwise, we can pan the map to the location
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
          var item:MappableUser = MappableUser(e.currentTarget.data.item);
            if (!_previous_view_button) {
                _previous_view_button = new Button();
                _previous_view_button.icon = Icon.ARROW_BACK;
                _previous_view_button.on_click.add(on_previous_button_click);
            }
            add_child_native(_previous_view_button);
            removeChild(_close_card_button);
            for (var k:int=0; k < component_container.numChildren; k++) {
              _previous_cache.push(component_container.getChildAt(k));
            }
            component_container.removeChildren();

            var detail_view:UserDialogView = BaseDialogView.get_cached_dialog(item.username) as UserDialogView;

            if (detail_view) {
              component_container.addChild(detail_view);
            } else {
              detail_view = new UserDialogView();
              detail_view.build_view(item.username);
              component_container.addChild(detail_view);
            }
            // TODO: when displaying this view, if the pin click user view is also open, one of the views will disappear. since we're pooling objects in memory, we're only using the same object once, everywhere. i still want to do that, but maybe auto-close one dialog while the other is active.
            commit();
        }

        private function on_location_click(e:MouseEvent):void {
          var item:MappableItem = SearchResultListItem(e.currentTarget).data.item as MappableItem;
          _position_dispatcher.dispatch(item.link, item.position);
        }

        private function on_previous_button_click(e:MouseEvent):void {
            component_container.removeChildren();
            for (var i:int=0; i < _previous_cache.length; i++) {
              component_container.addChild(_previous_cache[i]);
            }
            add_child_native(component_container);
            add_child_native(_close_card_button);
            removeChild(_previous_view_button);
            commit();
        }

        private function on_close_card(e:MouseEvent = null):void {
            parent.removeChild(this);
        }

        public function get on_position_dispatch():Signal {
          return _position_dispatcher;
        }
    }
}
