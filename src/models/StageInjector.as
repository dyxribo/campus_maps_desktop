package models {
    import flash.display.Stage;
    import app.interfaces.IInjector;

    public class StageInjector implements IInjector {
        private var _stage:Stage;

        public function StageInjector(stage:Stage) {
            _stage = stage;
        }

        public function get stage():Stage {
            return _stage;
        }
    }
}
