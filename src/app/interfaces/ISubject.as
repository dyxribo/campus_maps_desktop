package app.interfaces {

    public interface ISubject {
        function register_observer(observer:IObserver):void;

        function unregister_observer(observer:IObserver):void;

        function notify_observers(data:Object):void;
    }
}
