package {

    import config.SaveData;

    import controllers.MapController;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    import models.AccessInjector;
    import models.MapModel;

    import net.blaxstar.starlib.components.Button;
    import net.blaxstar.starlib.components.Dialog;
    import net.blaxstar.starlib.components.HorizontalBox;
    import net.blaxstar.starlib.components.Icon;
    import net.blaxstar.starlib.components.InputTextField;
    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.gui.CheckeredSurface;
    import net.blaxstar.starlib.io.URL;
    import net.blaxstar.starlib.networking.APIRequest;
    import net.blaxstar.starlib.networking.APIRequestManager;
    import net.blaxstar.starlib.style.Color;
    import net.blaxstar.starlib.style.Font;
    import net.blaxstar.starlib.style.Style;
    import net.blaxstar.starlib.utils.StringUtil;

    import thirdparty.com.hurlant.util.Base64;
    import thirdparty.com.lorentz.processing.ProcessExecutor;

    import views.map.MapView;
    import net.blaxstar.starlib.debug.printf;
    import flash.desktop.NativeApplication;

    /**
     * TODO: documentation
     */
    public class Main extends Sprite {
        // static const
        // regex
        static private const _auth_tkn_regex:RegExp = /^(Authorization: Bearer )([A-Za-z0-9-_]*\.[A-Za-z0-9-_]*\.[A-Za-z0-9-_]*$)/gm;
        static private const _ref_tkn_regex:RegExp = /^(X-REF-TOK: )([A-Za-z0-9-_]*\.[A-Za-z0-9-_]*\.[A-Za-z0-9-_]*$)/gm;
        static private const _ref_response_body_regex:RegExp = /^({username: [a-zA-Z0-9]+, admin: (0|1)})$/gm;
        static private const _response_body_regex:RegExp = /^({[a-zA-Z0-9{}:\" ,.]*}?)$/gm;
        // files
        private const _MAP_DATA_FILEPATH:String = File.applicationDirectory.resolvePath('data').resolvePath('app_db.json').nativePath;
        static private const _MAP_DATA_FILE:File = File.applicationStorageDirectory.resolvePath("app_db.json");
        static private const _AT_FILE:File = File.applicationStorageDirectory.resolvePath("at");
        static private const _RT_FILE:File = File.applicationStorageDirectory.resolvePath("rt");
        // private
        // forms
        private var _login_prompt:Dialog;
        private var _signup_dialog:Dialog;
        private var _login_username_field:InputTextField;
        private var _login_secret_field:InputTextField;
        private var _signup_username_field:InputTextField;
        private var _signup_secret_field:InputTextField;
        private var _signup_email_field:InputTextField;
        private var _signup_form_submit_button:Button;
        private var _signup_form_cancel_button:Button;
        private var _login_form_submit_button:Button;
        private var _login_form_signup_button:Button;
        private var _login_form_guest_button:Button;
        // map
        private var _map_model:MapModel;
        private var _map_view:MapView;
        private var _map_controller:MapController;
        private var _apiman:APIRequestManager;
        private var _savedata:SaveData;
        private var _filestream:FileStream;
        private var _user_access:AccessInjector;

        // ui/ux
        private var _initial_surface:CheckeredSurface;

        public function Main() {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // set the default alignment and scaling values for the stage
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            _initial_surface = new CheckeredSurface();
            _savedata = new SaveData();
            _apiman = new APIRequestManager();
            _filestream = new FileStream();
            // init processexecutor for drawing SVG icons, style for component theming, fonts for formatting all text, and debugdaemon for application logging
            ProcessExecutor.instance.initialize(stage);
            Style.init(this);
            Font.init();
            DebugDaemon.init(stage.nativeWindow, _savedata.application_title_extended.split(' ').join('_'));
            // apply an accessible surface for the background, load savedata, and set the window title
            _initial_surface.apply_to(this);
            _savedata.ON_LOAD.add(check_auth);
            stage.nativeWindow.title = _savedata.application_title_extended;

            _savedata.load();
        }

        private function check_auth():void {
            _savedata.ON_LOAD.remove(check_auth);
            // if we have tokens already, try to authenticate and refresh them
            if (_AT_FILE.exists || _RT_FILE.exists) {
                attempt_tkn_refresh();
            } else {
                // ...otherwise show the login prompt
                begin_auth();
            }

        }

        private function attempt_tkn_refresh():void {
            // strings for holding the tokens
            var at_str:String;
            var rt_str:String;
            var at_bytes:ByteArray = new ByteArray();
            var rt_bytes:ByteArray = new ByteArray();
            // uncompress both files and load them into the vars if possible
            if (_AT_FILE.exists) {
                at_str = read_at_file();
            }

            if (_RT_FILE.exists) {
                rt_str = read_rt_file();
            }
            // send them to the endpoint for refresh
            var request:APIRequest = _apiman.build_https_request("blaxstar.net", "server", URL.REQUEST_METHOD_POST, URL.DATA_FORMAT_JSON, "/api/rftkn", null, null, URL.AUTH_NONE, "");
            request.add_custom_header("X-REF-TOK", rt_str);

            _apiman.on_result_signal.add(on_refresh_response);
            _apiman.send(request);
        }

        private function begin_auth():void {
            // only create the components if the login prompt doesn't exist already
            if (!_login_prompt) {
                // a dialog is a simple window with an optional title, message, draggability and dialog buttons functionality built in. it also has a container for component layout so lets put them to good use.
                _login_prompt = new Dialog(this, "LOGIN TO CAMPUS MAPS");
                _login_prompt.auto_resize = true;
                _login_prompt.draggable = false;

                _login_username_field = new InputTextField(_login_prompt, 0, 0, "username");
                _login_secret_field = new InputTextField(_login_prompt, 0, 0, "password");
                _login_secret_field.display_as_password = true;
                // ten hut, front and center
                _login_prompt.move(width / 2 - _login_prompt.width / 2, height / 2 - _login_prompt.width / 2);
                // add buttons and their listeners
                _login_form_guest_button = _login_prompt.add_button("continue as guest", load_map_data, Button.DEPRESSED);
                _login_form_signup_button = _login_prompt.add_button("sign up", begin_signup_flow, Button.GROUNDED);
                _login_form_submit_button = _login_prompt.add_button("submit", on_login_form_submit, Button.GROUNDED);
            }
            _login_prompt.open();
        }

        private function begin_signup_flow(e:MouseEvent):void {
            // same deal as the login prompt, only create the components if the signup dialog wasn't already created
            if (!_signup_dialog) {
                _signup_dialog = new Dialog(null, "SIGN UP FOR CAMPUS MAPS");
                _signup_dialog.auto_resize = true;

                _signup_username_field = new InputTextField(_signup_dialog, 0, 0, "username");
                _signup_email_field = new InputTextField(_signup_dialog, 0, 0, "email");
                // lets make a horizontal box for placing the password field and a button for toggling the password visible side-by-side. we'll also hide the password by default for security reasons
                var secret_field_container:HorizontalBox = new HorizontalBox(_signup_dialog);
                _signup_secret_field = new InputTextField(secret_field_container, 0, 0, "password");
                _signup_secret_field.display_as_password = true;
                // toggle button with a lock icon, might change to eyeball but everyone and their mother uses those
                var _view_secret_toggle:Button = new Button(secret_field_container);
                _view_secret_toggle.icon = Icon.LOCK;
                // toggle listener as an anon function
                _view_secret_toggle.on_click.add(function toggle_secret(e:MouseEvent):void {
                    _view_secret_toggle.icon = (_view_secret_toggle.get_icon().src == Icon.LOCK ? Icon.LOCK_OPEN : Icon.LOCK);
                    _signup_secret_field.display_as_password = !_signup_secret_field.display_as_password;
                });
                // cancel and submit buttons
                _signup_dialog.add_button("cancel", on_signup_cancel, Button.DEPRESSED);
                _signup_form_submit_button = _signup_dialog.add_button("submit", on_signup_form_submit, Button.GROUNDED);
            }
            // remove the listener from the login form since this form will be the focus, and add this dialog to it as a child dialog, preventing input on the parent
            _apiman.on_result_signal.remove(on_login_form_submit);
            _login_prompt.push_dialog(_signup_dialog);
        }

        private function load_map_data(e:Event = null):void {
            // the maps gonna load soon, so get this sucker out of here. it might not actually be here if the refresh token did its job, so lets make sure to check for that
            if (_login_prompt && _login_prompt.parent) {
                _login_prompt.close();
            }
            // we should probably check for updates first, but only if logged in. if its first run and not logged in, quit (there's no way to retrieve the map without authentication using the current api)
            if (_savedata.first_run || !_MAP_DATA_FILE.exists) {
                if (!_user_access) {
                    var closing_prompt:Dialog = new Dialog(this);
                    closing_prompt.auto_resize = true;
                    closing_prompt.title = "ERROR";
                    closing_prompt.message = "cannot find map data, login required to sync!";
                    closing_prompt.add_button("QUIT", function():void {
                        DebugDaemon.write_warning("cannot find map data, login required to sync!");
                        NativeApplication.nativeApplication.exit(0);
                    }, Button.GROUNDED);

                }
                _savedata.first_run = false;
                _savedata.save();
            }

            sync_map_data();

        }

        private function sync_map_data():void {
            // we dont need any auth to get a map, the route is totally open
            var request:APIRequest = _apiman.build_https_request("blaxstar.net", "server", URL.REQUEST_METHOD_GET, URL.DATA_FORMAT_TEXT, "/api/getmap", null, null, URL.AUTH_TOKEN, read_at_file());

            _apiman.on_result_signal.add(on_map_sync);
            _apiman.send(request);
        }

        private function init_map(json:Object):void {
            _map_model = new MapModel();
            _map_view = new MapView(new AccessInjector(stage, true));
            _map_controller = new MapController(_map_model, _map_view);

            load_campus_data(json);
            init_map_display();
        }

        private function init_map_display():void {
            addChild(_map_view);
        }

        private function load_campus_data(json:Object):void {
            // TODO: load app_db. initial sync of json via api. sync occasionally, as well as on authentication. if file changes, loop through users and machines to see what's new.
            _map_model.read_json(json);
        }

        private function read_at_file():String {
            if (_AT_FILE.exists) {
                var at_str:String;
                var at_bytes:ByteArray = new ByteArray();
                _filestream.open(_AT_FILE, FileMode.READ);
                _filestream.readBytes(at_bytes);
                _filestream.close();
                at_bytes.uncompress('lzma');
                at_bytes.position = 0;
                at_str = at_bytes.readUTFBytes(at_bytes.bytesAvailable);
                return at_str;
            }
            return "";
        }

        private function read_rt_file():String {
            if (_RT_FILE.exists) {
                var rt_str:String;
                var rt_bytes:ByteArray = new ByteArray();
                _filestream.open(_RT_FILE, FileMode.READ);
                _filestream.readBytes(rt_bytes);
                _filestream.close();
                rt_bytes.position = 0;
                rt_bytes.uncompress('lzma');

                rt_str = rt_bytes.readUTFBytes(rt_bytes.bytesAvailable);
                return rt_str;
            }
            return "";
        }

        private function parse_auth_response(response:String):void {
            parse_auth_response_headers(response);
            parse_response_body(response);
        }

        private function parse_auth_response_headers(response:String):void {
            var at_bytes:ByteArray = new ByteArray();
            var rt_bytes:ByteArray = new ByteArray();

            var at:String = String(response.match(_auth_tkn_regex).pop()).replace("Authorization: Bearer ", "");
            var rt:String = String(response.match(_ref_tkn_regex).pop()).replace("X-REF-TOK: ", "");

            at_bytes.writeUTFBytes(at);
            at_bytes.compress('lzma');

            rt_bytes.writeUTFBytes(rt);
            rt_bytes.compress('lzma');

            _filestream.open(_AT_FILE, FileMode.WRITE);
            _filestream.writeBytes(at_bytes);
            _filestream.close();

            _filestream.open(_RT_FILE, FileMode.WRITE);
            _filestream.writeBytes(rt_bytes);
            _filestream.close();
        }

        private function parse_response_body(response:String):String {
            var body:String = response.split("\r\n\r\n").pop();
            if (response.indexOf("200 OK") > -1) {
                _user_access = new AccessInjector(stage, parseInt(JSON.parse(body).admin));
                return body;
            }
            return body;
        }

        private function parse_response_message(response:String):String {
            return JSON.parse(parse_response_body(response)).message;
        }

        private function set signup_form_enabled(value:Boolean):void {
            _signup_dialog.option_container.enabled = _signup_dialog.component_container.enabled = value;
        }

        private function set login_form_enabled(value:Boolean):void {
            _login_form_submit_button.enabled = _login_form_signup_button.enabled = _login_form_guest_button.enabled = _login_prompt.component_container.enabled = value;
        }

        // ! DELEGATES ! //

        private function on_map_sync(response:String):void {
            _apiman.on_result_signal.remove(on_map_sync);
            if (response.indexOf("200 OK") > -1) {
                var parsed_body_string:String = parse_response_body(response);
                var parsed_body_json:Object = JSON.parse(parsed_body_string);
                var map_data:Object = JSON.parse(parsed_body_json.data);

                _filestream.open(_MAP_DATA_FILE, FileMode.WRITE);
                _filestream.writeUTFBytes(JSON.stringify(parsed_body_json.data));
                _filestream.close();

                init_map(map_data);
            } else {
                // failure, possibly invalid token
                on_login_form_response(response);
            }
        }

        private function on_login_form_submit(e:MouseEvent):void {
            DebugDaemon.write_debug("attempting to connect to server as %s...", _login_username_field.text);
            _login_prompt.message_color = Color.PRODUCT_BLUE.value;
            _login_prompt.message = "logging in...";
            _apiman.on_result_signal.add(on_login_form_response);

            var request:APIRequest = _apiman.build_https_request("blaxstar.net", "server", URL.REQUEST_METHOD_POST, URL.DATA_FORMAT_TEXT, "/api/login", null, null, URL.AUTH_BASIC, Base64.encode(_login_username_field.text + ":" + _login_secret_field.text));

            login_form_enabled = false;
            _apiman.send(request);
        }

        private function on_login_form_response(response:String):void {
            _apiman.on_result_signal.remove(on_login_form_response);
            if (response.indexOf("200 OK") > -1) {
                login_success(response);
            } else {
                login_failure(response)
            }
        }

        private function login_success(response:String):void {
            // auto parse the auth (jwt) headers and body into their respective files and properties and load the initial map
            parse_auth_response(response);
            load_map_data();
        }

        private function login_failure(response:String):void {
            // set the message color to a certain companies' shade of red and display the error. also write this to the log
            _login_prompt.message_color = Color.PRODUCT_RED.value;
            _login_prompt.message = "login failed: " + parse_response_message(response);
            DebugDaemon.write_debug("login failed. got:\n\n%s", response);
        }

        private function on_refresh_response(response:String):void {
            _apiman.on_result_signal.remove(on_refresh_response);
            if (response.indexOf("200 OK") > -1) {
                // success
                parse_auth_response(response);
                trace(_user_access);
                load_map_data();
            } else {
                // failure
                begin_auth();
                _login_prompt.message_color = Color.PRODUCT_RED.value;
                _login_prompt.message = "invalid token; please login again.";
            }
        }

        private function on_signup_cancel(e:MouseEvent):void {
            _apiman.on_result_signal.remove(on_signup_form_response);
            _apiman.on_result_signal.add(on_login_form_response);
            _login_prompt.pop_dialog();
        }

        private function on_signup_form_submit(e:MouseEvent):void {
            if (!StringUtil.is_valid_email(_signup_email_field.text)) {
                _signup_dialog.message_color = Color.PRODUCT_RED.value;
                _signup_dialog.message = "invalid email; please double-check.";
                return;
            }
            _signup_dialog.message_color = Color.PRODUCT_BLUE.value;
            _signup_dialog.message = "registering with server...";

            signup_form_enabled = false;

            var request:APIRequest = _apiman.build_https_request("blaxstar.net", "server", URL.REQUEST_METHOD_POST, URL.DATA_FORMAT_JSON, "/api/register", null, {username: _signup_username_field.text, secret: _signup_secret_field.text, email: _signup_email_field.text}, URL.AUTH_NONE, "");


            _apiman.on_result_signal.add(on_signup_form_response);
            _apiman.send(request);
        }

        private function on_signup_form_response(response:String):void {
            if (response.indexOf("200 OK")) {
                _apiman.on_result_signal.remove(on_signup_form_response);
                _login_prompt.pop_dialog();
                _login_prompt.message_color = Color.PRODUCT_GREEN.value;
                _login_prompt.message = "signup success! please check your email for an activation link.";
            } else {
                signup_form_enabled = true;
                _signup_dialog.message_color = Color.PRODUCT_RED.value;
                _signup_dialog.message = "there was an error: " + parse_response_message(response);
            }
        }

    }
}
