part of stagexl_particle;

class _ParticleRenderProgram extends RenderProgram {
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertextColor:     Float32(r), Float32(g), Float32(b), Float32(a)

  @override
  String get vertexShaderSource => '''

    precision mediump float;
    uniform mat4 uProjectionMatrix;
    uniform mat4 uGlobalMatrix;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute vec4 aVertexColor;

    varying vec2 vTextCoord;
    varying vec4 vColor; 

    void main() {
      vTextCoord = aVertexTextCoord;
      vColor = aVertexColor;
      gl_Position = vec4(aVertexPosition, 1.0, 1.0) * uGlobalMatrix * uProjectionMatrix;
    }
    ''';

  @override
  String get fragmentShaderSource => '''

    precision mediump float;
    uniform sampler2D uSampler;

    varying vec2 vTextCoord;
    varying vec4 vColor;

    void main() {
      vec4 color = texture2D(uSampler, vTextCoord);
      gl_FragColor = vec4(color.rgb * vColor.rgb * vColor.a, color.a * vColor.a);
    }
    ''';

  //---------------------------------------------------------------------------

  final Matrix3D _globalMatrix = Matrix3D.fromIdentity();

  //---------------------------------------------------------------------------

  set globalMatrix(Matrix globalMatrix) {
    _globalMatrix.copyFrom2D(globalMatrix);
    renderingContext.uniformMatrix4fv(
        uniforms['uGlobalMatrix'], false, _globalMatrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {
    super.activate(renderContext);

    renderingContext.uniform1i(uniforms['uSampler'], 0);

    renderBufferVertex.bindAttribute(attributes['aVertexPosition'], 2, 32, 0);
    renderBufferVertex.bindAttribute(attributes['aVertexTextCoord'], 2, 32, 8);
    renderBufferVertex.bindAttribute(attributes['aVertexColor'], 4, 32, 16);
  }

  //---------------------------------------------------------------------------

  void renderParticle(RenderTextureQuad renderTextureQuad, num x, num y,
      num size, num r, num g, num b, num a) {
    num left = x - size / 2;
    num top = y - size / 2;
    num right = x + size / 2;
    num bottom = y + size / 2;

    var vxList = renderTextureQuad.vxList;
    var ixListCount = 6;
    var vxListCount = 4;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData.length < ixPosition + ixListCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData.length < vxPosition + vxListCount * 8) flush();

    // copy index list

    var ixIndex = renderBufferIndex.position;
    var vxOffset = renderBufferVertex.count;

    if (ixIndex > ixData.length - 6) return;
    ixData[ixIndex + 0] = vxOffset + 0;
    ixData[ixIndex + 1] = vxOffset + 1;
    ixData[ixIndex + 2] = vxOffset + 2;
    ixData[ixIndex + 3] = vxOffset + 0;
    ixData[ixIndex + 4] = vxOffset + 2;
    ixData[ixIndex + 5] = vxOffset + 3;

    renderBufferIndex.position += ixListCount;
    renderBufferIndex.count += ixListCount;

    // copy vertex list

    var vxIndex = renderBufferVertex.position;
    if (vxIndex > vxData.length - 32) return;

    vxData[vxIndex + 00] = left as double;
    vxData[vxIndex + 01] = top as double;
    vxData[vxIndex + 02] = vxList[02];
    vxData[vxIndex + 03] = vxList[03];
    vxData[vxIndex + 04] = r as double;
    vxData[vxIndex + 05] = g as double;
    vxData[vxIndex + 06] = b as double;
    vxData[vxIndex + 07] = a as double;
    vxData[vxIndex + 08] = right as double;
    vxData[vxIndex + 09] = top;
    vxData[vxIndex + 10] = vxList[06];
    vxData[vxIndex + 11] = vxList[07];
    vxData[vxIndex + 12] = r;
    vxData[vxIndex + 13] = g;
    vxData[vxIndex + 14] = b;
    vxData[vxIndex + 15] = a;
    vxData[vxIndex + 16] = right;
    vxData[vxIndex + 17] = bottom as double;
    vxData[vxIndex + 18] = vxList[10];
    vxData[vxIndex + 19] = vxList[11];
    vxData[vxIndex + 20] = r;
    vxData[vxIndex + 21] = g;
    vxData[vxIndex + 22] = b;
    vxData[vxIndex + 23] = a;
    vxData[vxIndex + 24] = left;
    vxData[vxIndex + 25] = bottom;
    vxData[vxIndex + 26] = vxList[14];
    vxData[vxIndex + 27] = vxList[15];
    vxData[vxIndex + 28] = r;
    vxData[vxIndex + 29] = g;
    vxData[vxIndex + 30] = b;
    vxData[vxIndex + 31] = a;

    renderBufferVertex.position += vxListCount * 8;
    renderBufferVertex.count += vxListCount;
  }

  void renderConfetti(RenderTextureQuad renderTextureQuad,
      num x, num y, num hsize, num vsize, num r, num g, num b, num a, num rotation) {

    var vxList = renderTextureQuad.vxList;

    num cosR = cos(rotation);
    num sinR = sin(rotation);

    // Calculate the coordinates of the four corners
    num x1 = x - hsize / 2;
    num y1 = y - vsize / 2;
    num x2 = x + hsize / 2;
    num y2 = y - vsize / 2;
    num x3 = x + hsize / 2;
    num y3 = y + vsize / 2;
    num x4 = x - hsize / 2;
    num y4 = y + vsize / 2;

    // Apply rotation to each point
    var rotatedX1 = x + (x1 - x) * cosR - (y1 - y) * sinR;
    var rotatedY1 = y + (x1 - x) * sinR + (y1 - y) * cosR;

    var rotatedX2 = x + (x2 - x) * cosR - (y2 - y) * sinR;
    var rotatedY2 = y + (x2 - x) * sinR + (y2 - y) * cosR;

    var rotatedX3 = x + (x3 - x) * cosR - (y3 - y) * sinR;
    var rotatedY3 = y + (x3 - x) * sinR + (y3 - y) * cosR;

    var rotatedX4 = x + (x4 - x) * cosR - (y4 - y) * sinR;
    var rotatedY4 = y + (x4 - x) * sinR + (y4 - y) * cosR;

    var ixListCount = 6;
    var vxListCount = 4;

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData.length < ixPosition + ixListCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData.length < vxPosition + vxListCount * 8) flush();

    var ixIndex = renderBufferIndex.position;
    var vxOffset = renderBufferVertex.count;

    if (ixIndex > ixData.length - 6) return;

    ixData[ixIndex + 0] = vxOffset + 0;
    ixData[ixIndex + 1] = vxOffset + 1;
    ixData[ixIndex + 2] = vxOffset + 2;
    ixData[ixIndex + 3] = vxOffset + 0;
    ixData[ixIndex + 4] = vxOffset + 2;
    ixData[ixIndex + 5] = vxOffset + 3;

    renderBufferIndex.position += ixListCount;
    renderBufferIndex.count += ixListCount;

    var vxIndex = renderBufferVertex.position;
    if (vxIndex > vxData.length - 32) return;

    vxData[vxIndex + 00] = rotatedX1 as double;
    vxData[vxIndex + 01] = rotatedY1 as double;
    vxData[vxIndex + 02] = vxList[02];
    vxData[vxIndex + 03] = vxList[03];
    vxData[vxIndex + 04] = r as double;
    vxData[vxIndex + 05] = g as double;
    vxData[vxIndex + 06] = b as double;
    vxData[vxIndex + 07] = a as double;
    vxData[vxIndex + 08] = rotatedX2 as double;
    vxData[vxIndex + 09] = rotatedY2 as double;
    vxData[vxIndex + 10] = vxList[06];
    vxData[vxIndex + 11] = vxList[07];
    vxData[vxIndex + 12] = r;
    vxData[vxIndex + 13] = g;
    vxData[vxIndex + 14] = b;
    vxData[vxIndex + 15] = a;
    vxData[vxIndex + 16] = rotatedX3 as double;
    vxData[vxIndex + 17] = rotatedY3 as double;
    vxData[vxIndex + 18] = vxList[10];
    vxData[vxIndex + 19] = vxList[11];
    vxData[vxIndex + 20] = r;
    vxData[vxIndex + 21] = g;
    vxData[vxIndex + 22] = b;
    vxData[vxIndex + 23] = a;
    vxData[vxIndex + 24] = rotatedX4 as double;
    vxData[vxIndex + 25] = rotatedY4 as double;
    vxData[vxIndex + 26] = vxList[14];
    vxData[vxIndex + 27] = vxList[15];
    vxData[vxIndex + 28] = r;
    vxData[vxIndex + 29] = g;
    vxData[vxIndex + 30] = b;
    vxData[vxIndex + 31] = a;

    renderBufferVertex.position += vxListCount * 8;
    renderBufferVertex.count += vxListCount;
  }
}
