package thirdparty.org.jasmineflex.global
{
	import thirdparty.org.jasmineflex.jasmine;

	public function xdescribe(description:String, specDefinitions:Function):* {
		return jasmine.getEnv().xdescribe(description, specDefinitions);
	};
}