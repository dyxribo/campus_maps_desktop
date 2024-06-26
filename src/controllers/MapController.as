package controllers {
    import app.interfaces.IMapImageLoaderObserver;
    import app.interfaces.IMapImageLoaderSubject;

    import enums.Contexts;

    import flash.display.Bitmap;
    import flash.filesystem.File;
    import flash.geom.Matrix;
    import flash.utils.Dictionary;

    import models.MapModel;

    import net.blaxstar.starlib.io.URL;
    import net.blaxstar.starlib.io.XLoader;

    import views.map.MapView;
    import structs.location.MappableItem;
    import models.MapSearchResult;
    import structs.location.MappableUser;
    import flash.utils.ByteArray;
    import flash.display.BitmapData;

    public class MapController implements IMapImageLoaderSubject {
        private const _OBSERVER_LIST:Vector.<IMapImageLoaderObserver> = new Vector.<IMapImageLoaderObserver>();
        private var _observer_index_lookup:Dictionary;
        private var _model:MapModel;
        private var _view:MapView;
        private var _image_loader:XLoader;

        public function MapController(model:MapModel, view:MapView) {
            this._model = model;
            this._view = view;

            init();
        }

        private function init():void {
            _observer_index_lookup = new Dictionary();
            register_observer(_view);
            register_observer(_model);
            _model.register_observer(_view);
            _image_loader = new XLoader();
            _model.on_image_load_request.add(load_map_image);
            _view.on_search_signal.add(on_search_init);
        }

        private function on_search_init(search_input:String):void {
            var results:Vector.<MappableItem> = _model.search(search_input, MapModel.SEARCH_ALL);
            var formatted_results:Vector.<MapSearchResult> = new Vector.<MapSearchResult>();

            for (var i:int = 0; i < results.length; i++) {
                var current_result:MappableItem = results[i];
                var current_msr:MapSearchResult = new MapSearchResult(current_result.id, current_result.position, (current_result is MappableUser) ? MapSearchResult.USER : MapSearchResult.LOCATION, {"item": current_result});
                formatted_results.push(current_msr);
            }

            _view.on_search_results(formatted_results);
        }

        private function load_map_image():void {
            if (!_model.current_location) {
                // TODO: display error, map not found.
                return;
            }

            var floor_map_png:File = _model.ASSET_IMAGE_FOLDER.resolvePath(_model.current_location.id).resolvePath(_model.current_location.building_id).resolvePath(_model.current_location.floor_id + ".png");

            var img_req:URL = new URL(true);
            img_req.endpoint = floor_map_png.nativePath;
            img_req.use_port = false;
            img_req.content_type = URL.DATA_FORMAT_GRAPHICS;
            _image_loader.ON_COMPLETE_GRAPHIC.add(on_image);
            _image_loader.queue_files(img_req);
        }

        private function on_image(loaded_image_bytes:BitmapData):void {
            // if the image was loaded, then it wasn't in the bmd cache, so put it there
            var img:Bitmap = new Bitmap(loaded_image_bytes);
            _model.bitmap_data_cache[_model.current_location.floor_id] = img;

            if (!_view.context_menu.has_context(Contexts.CONTEXT_MAP_GENERAL)) {
                // register contexts for context menu
                var context_map_general:Array = [Contexts.CONTEXT_MAP_GENERAL_ADD_ITEM,
                    Contexts.CONTEXT_MAP_GENERAL_CREATE_PATH, Contexts.CONTEXT_MAP_GENERAL];

                var context_map_item:Array = [Contexts.CONTEXT_MAP_ITEM_RENAME_ITEM,
                    Contexts.CONTEXT_MAP_ITEM_MOVE_ITEM,
                    Contexts.CONTEXT_MAP_ITEM_ARCHIVE_ITEM,
                    Contexts.CONTEXT_MAP_ITEM_DELETE_ITEM, Contexts.CONTEXT_MAP_ITEM];


                _view.init_context_menu([context_map_general, context_map_item]);
            }

            img.cacheAsBitmap = true;
            img.cacheAsBitmapMatrix = new Matrix();
            notify_observers({'on_map_image_load': img});
        }

        public function register_observer(observer:IMapImageLoaderObserver):void {
            // cache the position of the observer in the list for quick removals
            _observer_index_lookup[observer] = _OBSERVER_LIST.push(observer) - 1;
        }

        public function unregister_observer(observer:IMapImageLoaderObserver):void {
            // instead of splicing, copy last element of array to delete index, then pop the last element off. much faster that way
            _OBSERVER_LIST[_observer_index_lookup[observer]] = _OBSERVER_LIST[_OBSERVER_LIST.length - 1];
            _OBSERVER_LIST.pop();
        }

        public function notify_observers(data:Object):void {
            // reverse loop for maximum speed
            for (var i:int = _OBSERVER_LIST.length - 1; i > -1; i--) {
                _OBSERVER_LIST[i].update(data);
            }
        }
    }
}
