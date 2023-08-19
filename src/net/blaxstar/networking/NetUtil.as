package net.blaxstar.networking
{
import flash.system.Security;

/**
	 * ...
	 * @author Deron D. (SnaiLegacy)
	 * decamp.deron@gmail.com
	 */
	public class NetUtil
	{
		static public function load_policy_file(host:String, port:uint):void
		{
			if (port > 65535)
			{
				return;
			}

			try
			{
				Security.allowDomain(host);
				Security.allowInsecureDomain(host);
			}
			catch (e:Error)
			{

			}

			if (host.search("://") > -1)
			{
				Security.loadPolicyFile(host + ":" + port);
				Security.loadPolicyFile(host + ":" + port + "/crossdomain.xml");
			}
			else
			{
				Security.loadPolicyFile("xmlsocket://" + host + ":" + port);
				Security.loadPolicyFile("https://" + host + ":" + port);
				Security.loadPolicyFile("http://" + host + ":" + port);

				Security.loadPolicyFile("xmlsocket://" + host + ":" + port + "/crossdomain.xml");
				Security.loadPolicyFile("https://" + host + ":" + port + "/crossdomain.xml");
				Security.loadPolicyFile("http://" + host + ":" + port + "/crossdomain.xml");
			}
		}

	}

}
