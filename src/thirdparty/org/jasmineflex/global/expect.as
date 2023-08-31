package thirdparty.org.jasmineflex.global
{
	import thirdparty.org.jasmineflex.jasmine;

	public function expect(actual:*):* {
		return jasmine.getEnv().currentSpec.expect(actual);
	};
}