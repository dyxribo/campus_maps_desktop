package app.interfaces {

    public interface IMapImageLoaderSubject {
        function register_observer(observer:IMapImageLoaderObserver):void;

        function unregister_observer(observer:IMapImageLoaderObserver):void;

        function notify_observers(data:Object):void;
    }
}
