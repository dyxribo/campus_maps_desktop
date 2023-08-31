// ActionScript file
package thirdparty.org.jasmineflex.global
{
	import thirdparty.org.jasmineflex.jasmine;

	public function describe(description:String, specDefinitions:Function):* {
		return jasmine.getEnv().describe(description, specDefinitions);
	};
}