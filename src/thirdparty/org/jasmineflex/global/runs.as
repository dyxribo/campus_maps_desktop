package thirdparty.org.jasmineflex.global
{
	import thirdparty.org.jasmineflex.jasmine;

	public function runs(func:Function) {
		jasmine.getEnv().currentSpec.runs(func);
	};
}