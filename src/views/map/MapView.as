package views.map {
    import enums.Contexts;

    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.NativeWindowBoundsEvent;
    import flash.utils.Dictionary;

    import geom.Point;

    import modules.Pin;
    import modules.Searchbar;

    import net.blaxstar.starlib.components.Button;
    import net.blaxstar.starlib.components.ContextMenu;
    import net.blaxstar.starlib.components.Dialog;
    import net.blaxstar.starlib.components.ListItem;
    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.io.URL;

    import structs.location.MappableDesk;
    import structs.location.MappableItem;

    import thirdparty.com.greensock.TweenLite;
    import thirdparty.org.osflash.signals.natives.NativeSignal;

    import views.dialog.BaseDialogView;
    import views.dialog.DeskDialogView;
    import app.interfaces.IObserver;
    import app.interfaces.IMapImageLoaderObserver;
    import flash.display.Bitmap;
    import flash.display.Stage;

    /**
     * TODO: documentation, general cleanup, REMOVE DEBUG STUFF
     */
    public class MapView extends Sprite implements IObserver, IMapImageLoaderObserver {

        private const _ZOOM_FACTOR:Number = 0.1;

        / * PRIVATE VAR * /
        private var _image_mask:Sprite;
        private var _image_container:Sprite;
        private var _searchbar:Searchbar;
        private var _context_menu:ContextMenu;
        private var _stage:Stage;


        private var _item_detail_dialog:Dialog;
        private var _target_pin:Pin;
        private var _is_dragging_map:Boolean;

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
        public function MapView(stage:Stage) {
            _stage = stage;
            super();
            init();
        }

        public function get context_menu():ContextMenu {
            return _context_menu;
        }

        private function init():void {
            _image_container = new Sprite();
            _image_mask = new Sprite();
            //_searchbar = new Searchbar();
            _item_detail_dialog = new Dialog(this);
            _context_menu = new ContextMenu();

            add_children();
        }

        private function add_children():void {
            //addChild(_searchbar);
            addChild(_image_container);
            addChild(_image_mask);
            _item_detail_dialog.close();
            //_item_detail_dialog.height = 300;

            _item_detail_dialog.addOption("close", _item_detail_dialog.close, Button.DEPRESSED);
        }

        private function on_pin_click(e:MouseEvent):void {
            _target_pin = e.currentTarget as Pin;
            var assoc_item:MappableItem = _target_pin.linked_item;

            if (_item_detail_dialog.component_container.numChildren > 0 && assoc_item.type !== (_item_detail_dialog.component_container.getChildAt(0) as BaseDialogView).info_type) {

                if (_item_detail_dialog.component_container.numChildren) {
                    _item_detail_dialog.component_container.removeChildren();
                }
            }
            switch (assoc_item.type) {

                case MappableItem.ITEM_DESK:
                    var d:DeskDialogView = new DeskDialogView();

                    d.is_adjustable = (assoc_item as MappableDesk).is_adjustable;
                    d.set_name_field(assoc_item.id);
                    d.set_location_field(assoc_item.link);
                    d.set_assignee_field((assoc_item as MappableDesk).assignee);
                    _item_detail_dialog.message = '';
                    _item_detail_dialog.add_component(d);
                    _item_detail_dialog.auto_resize = true;
                    _item_detail_dialog.title = assoc_item.id + " properties";
                    _item_detail_dialog.move(_target_pin.x + _image_container.x, _target_pin.y + _image_container.y);
                    // TODO: add edit button to dialog in order to modify props. this needs to be authenticated, though.
                    break;

                default:
                    break;
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
            // ! TODO: dialog not appearing, position may be incorrect.
            // ! maybe refactor itemmap?
            _item_detail_dialog.open();
        }

        public function add_pin(pin:Pin):void {
            _image_container.addChild(pin);
            pin.buttonMode = true;
            pin.x = pin.linked_item.position.x;
            pin.y = pin.linked_item.position.y;
            pin.addEventListener(MouseEvent.CLICK, on_pin_click);
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

            }

            if (data.hasOwnProperty('pan_position')) {
                pan_map(data['pan_position'] as Point);
            }

            if (data.hasOwnProperty('new_pin')) {
                add_pin(data['new_pin'] as Pin);
            }

            if (data.hasOwnProperty('current_map_image')) {
                _image_container.addChild(data['current_map_image'] as Bitmap);
                addChild(_image_container);
                addChild(_image_mask);
                _image_container.addChild(_context_menu);
                draw_image_mask();
                _image_container.mask = _image_mask;
                add_image_container_listeners();
            }
        }

        // * GETTERS & SETTERS * //



        // * DELEGATES * //

        public function init_context_menu(contexts:Array):void {
            /**
             * TODO:
             * init image mask if not already
             *
             */
            // set default contexts
            for (var i:int = contexts.length - 1; i > -1; i--) {
                _context_menu.add_context_array(contexts[i], contexts[i][0], on_context_click);
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
                _context_menu.hide(true)
                add_image_container_listeners();
            }
        }

        private function on_context_click(e:MouseEvent):void {
            var list_item:ListItem = (e.currentTarget as ListItem);
            switch (list_item.label) {
                case Contexts.CONTEXT_MAP_GENERAL_ADD_ITEM:
                    trace("item creation");
                    var location:MappableItem = new MappableItem();
                    location.position.x = _context_menu.x;
                    location.position.y = _context_menu.y;
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
