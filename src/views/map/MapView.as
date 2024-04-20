package views.map {
    import app.interfaces.IInjector;
    import app.interfaces.IMapImageLoaderObserver;
    import app.interfaces.IObserver;

    import enums.Contexts;

    import flash.display.Bitmap;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.NativeWindowBoundsEvent;
    import flash.utils.Dictionary;

    import geom.Point;

    import models.AccessInjector;
    import models.MapSearchResult;
    import models.StageInjector;

    import modules.Pin;
    import modules.SearchResultCard;
    import modules.Searchbar;

    import net.blaxstar.starlib.components.Component;
    import net.blaxstar.starlib.components.ContextMenu;
    import net.blaxstar.starlib.components.Dialog;
    import net.blaxstar.starlib.components.InputTextField;
    import net.blaxstar.starlib.components.ListItem;
    import net.blaxstar.starlib.components.PlainText;
    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.style.Color;

    import structs.location.AssignableItem;
    import structs.location.MappableItem;
    import structs.location.MappableUser;
    import structs.location.Region;

    import thirdparty.com.greensock.TweenLite;
    import thirdparty.org.osflash.signals.Signal;
    import thirdparty.org.osflash.signals.natives.NativeSignal;

    import views.dialog.BaseDialogView;
    import views.dialog.DeskDialogView;
    import net.blaxstar.starlib.components.Dropdown;
    import net.blaxstar.starlib.components.Button;

    /**
     * TODO: documentation, general cleanup, REMOVE DEBUG STUFF
     */
    public class MapView extends Sprite implements IObserver, IMapImageLoaderObserver {

        private const _ZOOM_FACTOR:Number = 0.1;

        // stage injector properties
        private var _stage:Stage;
        // access injector properties
        private var _admin:Boolean;
        // private var 
        private var _context_menu:ContextMenu;
        private var _is_dragging_map:Boolean;
        private var _dialog_view_cache:Dictionary;
        private var _current_location:Region;
        // visual components
        private var _image_mask:Sprite;
        private var _image_container:Sprite;
        private var _searchbar:Searchbar;
        private var _search_result_card:SearchResultCard;
        private var _new_item_dialog:Dialog;
        private var _item_detail_dialog:Dialog;
        private var _detail_dialog_view:BaseDialogView;
        private var _target_pin:Pin;
        // signals
        private var _on_search_signal:Signal;
        private var _on_context_menu_roll_out:NativeSignal;
        private var _on_context_menu_release_outside:NativeSignal;
        private var _on_context_menu_defocus:NativeSignal;
        private var _on_image_container_mouse_down:NativeSignal;
        private var _on_image_container_mouse_up:NativeSignal;
        private var _on_image_container_release_outside:NativeSignal;
        private var _on_image_container_scroll_wheel:NativeSignal;
        private var _on_image_container_right_click:NativeSignal;
        private var _on_pin_click_signal:NativeSignal;
        private var _on_viewport_resize:NativeSignal;

        /**
         * /// TODO: documentation
         * @param directory_data
         */
        public function MapView(injector:IInjector) {
            if (injector is AccessInjector) {
                var a:AccessInjector = AccessInjector(injector);
                _stage = a.stage;
                _admin = a.admin_access;
            } else if (injector is StageInjector) {
                var b:StageInjector = StageInjector(injector);
                _stage = b.stage;
            }

            super();
            init();
        }

        public function get context_menu():ContextMenu {
            return _context_menu;
        }

        private function init():void {
            _dialog_view_cache = new Dictionary(true);
            _on_search_signal = new Signal(String);
            _image_container = new Sprite();
            _image_mask = new Sprite();
            _searchbar = new Searchbar();
            _item_detail_dialog = new Dialog(this);
            _context_menu = new ContextMenu();

            add_children();
        }

        private function add_children():void {
            _item_detail_dialog.close();
            _item_detail_dialog.add_button("close", _item_detail_dialog.close);
        }

        private function on_pin_click(e:MouseEvent):void {
            _target_pin = e.currentTarget as Pin;
            var assoc_item:MappableItem = _target_pin.linked_item;

            if (BaseDialogView.dialog_in_cache(assoc_item.id)) {
                _detail_dialog_view = BaseDialogView.get_cached_dialog(assoc_item.id);
            } else {
                switch (assoc_item.type) {
                    case MappableItem.ITEM_DESK:
                        var d:DeskDialogView = new DeskDialogView();
                        _detail_dialog_view = d;
                        d.parent_dialog = _item_detail_dialog;
                        _item_detail_dialog.message = '';
                        _item_detail_dialog.auto_resize = true;
                        _item_detail_dialog.title = assoc_item.id + " properties";
                        _item_detail_dialog.component_container.removeChildren();
                        _item_detail_dialog.addChild(_detail_dialog_view);
                        d.build_view(assoc_item.id);

                        // TODO: add edit button to dialog in order to modify props. this needs to be authenticated, though.
                        break;

                    default:
                        break;
                }
            }
            if (_search_result_card && _search_result_card.parent) {
                _search_result_card.close();
            }
            /**
             * form components needed:
             *
             * generic:name of item,type of item,location of item
             *
             * variations:
             * user (only shown via references, not on map): full name,username, email,phone,asset list *,desk list *,is_vip,work hours with timezone
             *
             * desk: name,is_adjustable
             *
             * all machines: model,mac address,ip address,connected jack id
             *
             * printer: using_usb
             *
             * workstation: hostname
             *
             * * = can wait for implementation
             */
            _item_detail_dialog.open();
            _item_detail_dialog.move(_target_pin.x + _image_container.x, _target_pin.y + _image_container.y);
        }

        private function item_in_cache(item:MappableItem):BaseDialogView {
            if (_dialog_view_cache[item.id]) {
                return _dialog_view_cache[item.id];
            }
            return null;
        }

        public function add_pin(pin:Pin):void {
            _image_container.addChild(pin);
            pin.buttonMode = true;
            pin.x = pin.linked_item.x;
            pin.y = pin.linked_item.y;
            pin.addEventListener(MouseEvent.CLICK, on_pin_click);
        }

        public function add_name_label(item:MappableItem):void {
            var name:PlainText = new PlainText(_image_container);
            name.color = Color.PRODUCT_RED.value;
            if (item is AssignableItem) {
                var user:MappableUser = MappableItem.user_lookup.pull(AssignableItem(item).assignee) as MappableUser;
                if (user) {
                    name.text = user.full_name;
                } else {
                    name.text = item.id;
                }
            } else {
                name.text = item.id;
            }
            name.move(item.x - (Component.PADDING * 2), item.y - (Component.PADDING * 2));
        }

        /**
         *
         */
        private function pan_map(pan_position:Point):Boolean {
            var center_x:Number = _stage.stageWidth / 2;
            var center_y:Number = _stage.stageHeight / 2;

            TweenLite.to(_image_container, 0.3, {x: center_x - pan_position.x, y: center_y - pan_position.y});

            return true;
        }

        /**
         *
         */
        private function add_image_container_listeners():void {
            _on_image_container_mouse_down ||= new NativeSignal(_image_container, MouseEvent.MOUSE_DOWN, MouseEvent);
            _on_image_container_mouse_up ||= new NativeSignal(_image_container, MouseEvent.MOUSE_UP, MouseEvent);
            _on_image_container_release_outside ||= new NativeSignal(_image_container, MouseEvent.RELEASE_OUTSIDE, MouseEvent);
            _on_image_container_right_click ||= new NativeSignal(_image_container, MouseEvent.RIGHT_CLICK, MouseEvent);
            _on_image_container_scroll_wheel ||= new NativeSignal(_image_container, MouseEvent.MOUSE_WHEEL, MouseEvent);
            _on_viewport_resize ||= new NativeSignal(stage.nativeWindow, NativeWindowBoundsEvent.RESIZE, NativeWindowBoundsEvent);

            _on_image_container_mouse_down.add(on_mouse_down);
            _on_image_container_right_click.add(on_right_click);
            _on_image_container_scroll_wheel.add(on_scroll_wheel);
            _on_viewport_resize.add(on_viewport_resize);
        }

        private function remove_image_container_mouse_listeners():void {
            _on_image_container_mouse_down.remove(on_mouse_down);
            _on_image_container_right_click.remove(on_right_click);
            _on_image_container_scroll_wheel.remove(on_scroll_wheel);
            _on_viewport_resize.remove(on_viewport_resize);
        }

        private function create_new_item_dialog(spawn_point:Point = null):void {
            //  TODO: create seperate options for region/building/floor adds by checking the current view with a flag such as "in_region_view." region pins will be added to its own region map, buildings will be added to a specific region map, and floors won't be added to maps-- however there will be a sort of "floor switcher" that appears on the side of the normal floor view  to switch to a different floor on command. searching for an item on a different floor should also take you to that floor automatically. 

            _new_item_dialog = new Dialog(this);
            _new_item_dialog.title = "NEW MAPPED ITEM";
            _new_item_dialog.auto_resize = true;

            var item_name_input:InputTextField = new InputTextField(_new_item_dialog, 0, 0, "Item Name");
            var item_type_dropdown:Dropdown = new Dropdown(_new_item_dialog, 0, 0, "Item Type");
            var subsection_selection:Dropdown = new Dropdown(_new_item_dialog, 0, 0, _current_location ? _current_location.get_building(_current_location.building_id).get_floor(_current_location.floor_id).link : "set a location...");

            item_type_dropdown.multi_add_string_array(["Subsection", "User", "Workstation", "Desk", "Printer", "Wall Jack", "Wall Plate", "Generic Item"]);
            _new_item_dialog.add_button("CANCEL", _new_item_dialog.close, Button.DEPRESSED);
            _new_item_dialog.add_button("CREATE", function():void {
                item_name_input.text = "";
                _new_item_dialog.close();
            }, Button.GROUNDED);

            if (spawn_point) {
                _new_item_dialog.move(spawn_point.x - (_new_item_dialog.width / 2), spawn_point.y - (_new_item_dialog.height / 2));
            }
        }

        /**
         *
         */
        private function draw_image_mask():void {
            var g:Graphics = _image_mask.graphics;
            g.beginFill(0);
            g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            g.endFill();
        }

        // * PUBLIC * //

        public function update(data:Object):void {

            if (data.hasOwnProperty('current_location')) {
                _current_location = data["current_location"];
            }

            if (data.hasOwnProperty('pan_position')) {
                pan_map(data['pan_position'] as Point);
            }

            if (data.hasOwnProperty('new_pin')) {
                var new_pin:Pin = Pin(data['new_pin']);
                add_name_label(new_pin.linked_item);
                add_pin(new_pin);
            }

            if (data.hasOwnProperty('current_map_image')) {
                _image_container.addChild(data['current_map_image'] as Bitmap);
                addChild(_image_container);
                addChild(_image_mask);
                addChild(_searchbar);
                _searchbar.x = _searchbar.y = Component.PADDING;
                _searchbar.search_signal.add(on_search_init);
                _image_container.addChild(_context_menu);
                draw_image_mask();
                _image_container.mask = _image_mask;
                add_image_container_listeners();
            }
        }

        // * GETTERS & SETTERS * //

        public function get on_search_signal():Signal {
            return _on_search_signal;
        }


        // * DELEGATES * //

        public function on_search_init(search_input:String):void {
            _on_search_signal.dispatch(search_input);
        }

        public function on_search_results(results:Vector.<MapSearchResult>):void {
            // TODO: implement automatic floor switching
            for (var i:int = 0; i < results.length; i++) {
                DebugDaemon.write_debug("found %s @ {%s, %s}.", results[i].label, results[i].position.x, results[i].position.y);
            }
            if (results.length == 1) {
                if (results[0].type == MapSearchResult.LOCATION) {
                    pan_map(results[0].position);
                } else {
                    _search_result_card.set_search_results(results);
                }
            } else {
                if (!_search_result_card) {
                    _search_result_card = new SearchResultCard();
                    _search_result_card.move(Component.PADDING, _searchbar.y + _searchbar.height + Component.PADDING);
                    _search_result_card.auto_resize = true;
                    _search_result_card.on_position_dispatch.add(on_search_select);
                }
                addChild(_search_result_card);
                _search_result_card.set_search_results(results);
            }
            //
            _item_detail_dialog.close();
        }

        private function on_search_select(link:String, position:Point):void {
            pan_map(position);
        }

        public function init_context_menu(contexts:Array):void {
            /**
             * TODO:
             * init image mask if not already
             *
             */
            // set default contexts
            for (var i:int = contexts.length - 1; i > -1; i--) {
                var context:String = contexts[i].pop();
                _context_menu.add_context_array(contexts[i], context, on_context_click);
            }

            _context_menu.set_context(Contexts.CONTEXT_MAP_GENERAL);
            _context_menu.hide();
        }

        private function on_mouse_down(e:MouseEvent):void {
            _on_image_container_mouse_down.remove(on_mouse_down);
            _on_image_container_mouse_up.add(on_mouse_up);
            _on_image_container_release_outside.add(on_mouse_up);
            _image_container.startDrag();
            _is_dragging_map = true;
            _item_detail_dialog.on_enter_frame_signal.add(on_mouse_move);

        }

        private function on_mouse_move(e:Event):void {
            if (_is_dragging_map) {
                if (_item_detail_dialog.parent) {
                    _item_detail_dialog.move(_target_pin.x + _image_container.x, _target_pin.y + _image_container.y);
                }
            }
        }

        private function on_mouse_up(e:MouseEvent):void {
            _is_dragging_map = false;
            _item_detail_dialog.on_enter_frame_signal.remove(on_mouse_move);
            _on_image_container_mouse_up.remove(on_mouse_up);
            _on_image_container_release_outside.remove(on_mouse_up);
            _on_image_container_mouse_down.add(on_mouse_down);
            _image_container.stopDrag();

        }

        private function on_right_click(e:MouseEvent):void {
            if (!_admin) {
                return;
            }
            e.preventDefault();

            // TODO: display context menu with easy actions
            var mouse_point:Point = new Point(mouseX - _image_container.x, mouseY - _image_container.y);

            _context_menu.move(mouse_point.x, mouse_point.y);
            _context_menu.show();
            add_context_menu_listeners();
            remove_image_container_mouse_listeners();

            DebugDaemon.write_log("point pinged @ %s, %s", DebugDaemon.DEBUG, mouse_point.x, mouse_point.y);
        }

        private function add_context_menu_listeners():void {
            _on_context_menu_roll_out ||= new NativeSignal(_context_menu, MouseEvent.ROLL_OUT, MouseEvent);
            _on_context_menu_release_outside ||= new NativeSignal(_context_menu, MouseEvent.RELEASE_OUTSIDE, MouseEvent);
            _on_context_menu_defocus ||= new NativeSignal(stage, MouseEvent.CLICK, MouseEvent);

            _on_context_menu_roll_out.add(on_context_menu_roll_out);
            _on_context_menu_release_outside.add(on_context_menu_release_outside);
            _on_context_menu_defocus.add(on_context_menu_defocus);
        }

        private function remove_context_menu_listeners():void {
            _on_context_menu_roll_out.remove(on_context_menu_roll_out);
            _on_context_menu_release_outside.remove(on_context_menu_release_outside);
            _on_context_menu_defocus.remove(on_context_menu_defocus);
        }

        private function on_context_menu_roll_out(e:MouseEvent):void {
            _context_menu.clear_selection();
        }

        private function on_context_menu_release_outside(e:MouseEvent):void {
            remove_context_menu_listeners();
            _context_menu.hide(true);
            add_image_container_listeners();
        }

        private function on_context_menu_defocus(e:MouseEvent):void {
            if (e.currentTarget !== _context_menu) {
                _on_context_menu_defocus.remove(on_context_menu_defocus);
                remove_context_menu_listeners();
                _context_menu.hide(true);
                add_image_container_listeners();
            }
        }

        private function on_context_click(e:MouseEvent):void {
            var list_item:ListItem = (e.currentTarget as ListItem);
            switch (list_item.label) {
                case Contexts.CONTEXT_MAP_GENERAL_ADD_ITEM:
                    trace("item creation");

                    var location:MappableItem = new MappableItem();
                    location.x = _context_menu.x;
                    location.y = _context_menu.y;

                    if (!_new_item_dialog) {
                        create_new_item_dialog(location.position);
                    } else {
                        _new_item_dialog.open();
                    }


                    break;
                case Contexts.CONTEXT_MAP_GENERAL_CREATE_PATH:
                    trace("path creation");
                    break;
                default:
                    break;
            }
            _context_menu.hide(true);
        }

        private function on_scroll_wheel(e:MouseEvent):void {
            // TODO: implement zoom

        }

        private function on_viewport_resize(e:NativeWindowBoundsEvent):void {
            _image_mask.width = stage.stageWidth;
            _image_mask.height = stage.stageHeight;
        }
    }

}
