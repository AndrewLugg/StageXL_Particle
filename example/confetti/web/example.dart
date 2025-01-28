library example01;

import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_particle/stagexl_particle.dart';

void main() {
  StageXL.stageOptions.renderEngine = RenderEngine.WebGL;
  StageXL.stageOptions.backgroundColor = Color.White;
  var stage = Stage(html.querySelector('#stage') as html.CanvasElement);
  var renderLoop = RenderLoop();
  renderLoop.addStage(stage);

  //-------------------------

  var particleConfig = {
    'type' : 'confetti',
    'maxParticles': 30000,
    'duration': 0.1,
    'lifeSpan': 10,
    'lifespanVariance': 5,
    'startSize': 10,
    'startSizeVariance': 0,
    'finishSize': 10,
    'finishSizeVariance': 0,
    'shape': 'square',
    'emitterType': 0,
    'location': {'x': 0, 'y': 0},
    'locationVariance': {'x': 5, 'y': 5},
    'speed': 50,
    'speedVariance': 100,
    'angle': 90,
    'angleVariance': 360,
    'gravity': {'x': 0, 'y': 100},
    'gravityVariance': {'x': 0, 'y': 50},
    'radialAcceleration': 20,
    'radialAccelerationVariance': 0,
    'tangentialAcceleration': 0,
    'tangentialAccelerationVariance': 0,
    'minRadius': 0,
    'maxRadius': 100,
    'maxRadiusVariance': 0,
    'rotatePerSecond': 50,
    'rotatePerSecondVariance': 0,
    'compositeOperation': 'source-over',
    'confettiColors' : [0xFF26ccff,  0xFFa25afd,  0xFFff5e7e,  0xFF88ff5a,  0xFFfcff42,  0xFFffa62d,  0xFFff36ff]
  };

  var particleEmitter = ParticleEmitter(particleConfig);
  particleEmitter.setEmitterLocation(400, 300);
  stage.addChild(particleEmitter);
  stage.juggler.add(particleEmitter);

  //-------------------------

  var mouseEventListener = (MouseEvent me) {
    if (me.buttonDown)  {
      particleEmitter.setEmitterLocation(me.localX, me.localY);
      particleEmitter.start(0.1);
    }

  };

  var glassPlate = GlassPlate(800, 600);
  glassPlate.onMouseDown.listen(mouseEventListener);
  glassPlate.onMouseMove.listen(mouseEventListener);
  stage.addChild(glassPlate);
}
