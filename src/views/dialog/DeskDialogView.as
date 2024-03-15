package views.dialog {
    import net.blaxstar.starlib.components.PlainText;
    import structs.location.MappableDesk;
    import structs.location.MappableItem;

    public class DeskDialogView extends BaseDialogView {


        private var _is_adjustable:PlainText;

        public function DeskDialogView() {
            super();
            _is_adjustable = new PlainText(this);
            set_type_field("DESK");
        }

        override public function build_view(id:String):void {
          var d:MappableDesk = MappableItem.desk_lookup.pull(id) as MappableDesk;
                    // initialize the information view component for the dialog
                    set_name_field(d.id);
                    set_location_field(d.link);
                    set_assignee_field(d.assignee);
                    set_type_field(d.type_string);
                    is_adjustable = d.is_adjustable;

                    _dialog_view_cache[id] = this;
        }

        public function set is_adjustable(is_adjustable:Boolean):void {
            _is_adjustable.text = "IS ADJUSTABLE: " + is_adjustable;
        }
    }
}
