package models {
    import flash.display.Stage;
    import app.interfaces.IInjector;

    public class AccessInjector extends StageInjector implements IInjector {
        private var _has_admin_access:Boolean;

        public function AccessInjector(stage:Stage, has_admin_access:Boolean) {
            _has_admin_access = has_admin_access;
            super(stage);
        }

        public function get admin_access():Boolean {
            return _has_admin_access;
        }
    }
}
