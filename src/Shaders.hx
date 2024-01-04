import sdl.GL;

abstract ShaderProgram(Program) {
	static function compileShader(code:String, type:Int) {
		final shader = GL.createShader(type);

		GL.shaderSource(shader, code);
		GL.compileShader(shader);
		var status = GL.getShaderParameter(shader, GL.COMPILE_STATUS);
		if (status != 1) {
			final log = GL.getShaderInfoLog(shader);
			throw log;
		}
		return shader;
	}

	public function new(vertexShader:String, fragmentShader:String) {
		final shaderProgram = GL.createProgram();
		GL.attachShader(shaderProgram, compileShader(vertexShader, GL.VERTEX_SHADER));
		GL.attachShader(shaderProgram, compileShader(fragmentShader, GL.FRAGMENT_SHADER));
		GL.linkProgram(shaderProgram);

		var status = GL.getProgramParameter(shaderProgram, GL.LINK_STATUS);
		if (status != 1) {
			final log = GL.getProgramInfoLog(shaderProgram);
			throw log;
		}

		this = shaderProgram;
	}

	public function setUniform(name:String, value:Int) {
		final uniform = GL.getUniformLocation(this, name);
		GL.uniform1i(uniform, value);
	}

	public function getAttribLocation(name:String) {
		return GL.getAttribLocation(this, name);
	}

	public function use() {
		GL.useProgram(this);
	}
}
