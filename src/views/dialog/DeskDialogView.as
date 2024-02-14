package views.dialog {
    import net.blaxstar.starlib.components.Checkbox;
    import net.blaxstar.starlib.components.PlainText;

    public class DeskDialogView extends BaseDialogView {


        private var _is_adjustable:PlainText;

        public function DeskDialogView() {
            super();
            _is_adjustable = new PlainText(this);
        }

        public function set is_adjustable(is_adjustable:Boolean):void {
            _is_adjustable.text = "IS ADJUSTABLE: " + is_adjustable;
        }
    }
}
