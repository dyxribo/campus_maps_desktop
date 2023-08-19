package net.blaxstar.sql
{
import flash.events.Event;
import flash.events.IOErrorEvent;

import thirdparty.org.osflash.signals.Signal;
import thirdparty.com.maclema.mysql.Connection;
import thirdparty.com.maclema.mysql.ResultSet;
import thirdparty.com.maclema.mysql.events.MySqlErrorEvent;
import net.blaxstar.networking.NetUtil;
import thirdparty.com.maclema.mysql.Statement;
import thirdparty.com.maclema.mysql.MySqlToken;
import thirdparty.com.maclema.mysql.events.MySqlEvent;

/**
	 * ...
	 * @author Deron Decamp
	 */

	public class SQLDaemon
	{
		//vars
		public const ON_ERROR:Signal = new Signal(String);
		public const ON_CONNECT:Signal = new Signal();
		public const ON_DISCONNECT:Signal = new Signal();
		public const ON_RESULT:Signal = new Signal(ResultSet);

		private var connection:Connection;
		private var backlog:Vector.<String>;

		//constructor
		public function SQLDaemon()
		{

		}

		//public
		public function connect(host:String, user:String, pass:String, db_name:String, port:uint = 3306, policy_port:uint = 80):void
		{
			if (port > 65535)
			{
				return;
			}

			if (connection)
			{
				disconnect();
			}

			NetUtil.load_policy_file(host, policy_port);
			connection = new Connection(host, port, user, pass, db_name);
			backlog = new Vector.<String>();

			connection.addEventListener(IOErrorEvent.IO_ERROR, on_io_error);
			connection.addEventListener(MySqlErrorEvent.SQL_ERROR, on_sql_error);
			connection.addEventListener(Event.CONNECT, on_connect);
			connection.addEventListener(Event.CLOSE, on_close);
			connection.connect();
		}

		public function disconnect():void
		{
			if (!connection)
			{
				return;
			}

			connection.disconnect();
			connection = null;
			backlog = null;
		}

		public function query(q:String):void
		{
			if (!q || q == "")
			{
				return;
			}

			if (backlog.length > 0 || connection.busy)
			{
				backlog.push(query);
			}
			else
			{
				var statement:Statement = connection.createStatement();
				var token:MySqlToken = statement.executeQuery(q);

				token.addEventListener(MySqlErrorEvent.SQL_ERROR, on_sql_error);
				token.addEventListener(MySqlEvent.RESULT, on_result);
				token.addEventListener(MySqlEvent.RESPONSE, on_response);
			}
		}

		//private
		private function on_io_error(e:IOErrorEvent):void
		{
			disconnect();
			ON_ERROR.dispatch(e.text);
		}

		private function on_sql_error(e:MySqlErrorEvent):void
		{
			if (!connection.connected)
			{
				disconnect();
			}
			ON_ERROR.dispatch(e.msg);
		}

		private function on_connect(e:Event):void
		{
			ON_CONNECT.dispatch();
			send_next();
		}

		private function on_close(e:Event):void
		{
			disconnect();
			ON_DISCONNECT.dispatch();
		}

		private function on_response(e:MySqlEvent):void
		{
			ON_RESULT.dispatch(e.resultSet);
			send_next();
		}

		private function on_result(e:MySqlEvent):void
		{
			ON_RESULT.dispatch(e.resultSet);
			send_next();
		}

		private function send_next():void
		{
			if (!connection || backlog.length == 0)
			{
				return;
			}

			query(backlog.splice(0, 1)[0]);
		}
	}
}
