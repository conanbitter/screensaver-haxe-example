import Window;
import Shaders;

class Main {
	static final VERTEX_SHADER:String = '
	#version 150

    uniform int width;
	uniform int height;

    in vec2 vert;
    in vec4 vertColor;

    out vec4 fragColor;

    void main() {
		
        gl_Position = vec4(vert.x/float(width)*2.0-1.0, vert.y/float(height)*2.0-1.0, 0.0, 1.0);
        fragColor = vertColor;
	}';

	static final FRAGMENT_SHADER:String = '
	#version 150

    in vec4 fragColor;

    out vec4 outputColor;

    void main() {
        outputColor = fragColor;
    }';

	static function main() {
		var wnd = new Window("Lines", 1280, 720);
		var shader = new ShaderProgram(VERTEX_SHADER, FRAGMENT_SHADER);
		shader.setUniform("width", 1280);
		wnd.run();
	}
}
