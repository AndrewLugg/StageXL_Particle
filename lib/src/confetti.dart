part of stagexl_particle;

class _Confetti extends _Particle {
  Random random = Random();

  String shape = 'square'; // 'square' or 'circle'
  num _flip = 1.0;
  late num _flipSpeed = 0.01;
  late num _rotationSpeed;
  num _individualRotation = 0.0;
  late num _individualGravityVarianceX;
  late num _individualGravityVarianceY;
  late _ParticleColor _startColor;

  _Confetti(ParticleEmitter particleEmitter) : super(particleEmitter) {
    // Assign properties from _Particle as needed
    _startColor = _ParticleColor.fromARGB(particleEmitter._confettiColors![
        random.nextInt(particleEmitter._confettiColors!
            .length)]); // Randomly assign one of the confetti colors
    shape = random.nextBool() ? 'square' : 'circle'; // Randomly choose shape
  }
  @override
  void _initParticle() {
    _flipSpeed = Random().nextDouble() * 0.05;
    _rotationSpeed = (Random().nextDouble() - 0.5) * 4;
    _individualGravityVarianceX =
        Random().nextDouble() * _particleEmitter._gravityVarianceX * 2 -
            _particleEmitter._gravityVarianceX;
    _individualGravityVarianceY =
        Random().nextDouble() * _particleEmitter._gravityVarianceY * 2 -
            _particleEmitter._gravityVarianceY;
    super._initParticle();
    _colorR = _startColor.red;
    _colorG = _startColor.green;
    _colorB = _startColor.blue;
    _colorA = _startColor.alpha;
  }

  @override
  bool _advanceParticle(num passedTime) {
    var pe = _particleEmitter;
    var restTime = _totalTime - _currentTime;
    if (restTime <= 0.0) return false;
    if (restTime <= passedTime) passedTime = restTime;

    _currentTime += passedTime;

    var distanceX = _x - _startX;
    var distanceY = _y - _startY;
    num distanceScalar = sqrt(distanceX * distanceX + distanceY * distanceY);
    if (distanceScalar < 0.01) distanceScalar = 0.01;
    distanceX = distanceX / distanceScalar;
    distanceY = distanceY / distanceScalar;

    var gravityX = pe._gravityX + _individualGravityVarianceX;
    var gravityY = pe._gravityY + _individualGravityVarianceY;

    _velocityX += passedTime *
        (gravityX +
            distanceX * _radialAcceleration -
            distanceY * _tangentialAcceleration);
    _velocityY += passedTime *
        (gravityY +
            distanceY * _radialAcceleration +
            distanceX * _tangentialAcceleration);
    _x += _velocityX * passedTime;
    _y += _velocityY * passedTime;

    if (_flip > 1.0 && !_flipSpeed.isNegative) {
      _flipSpeed = -_flipSpeed;
    } else if (_flip < 0.0 && _flipSpeed.isNegative) {
      _flipSpeed = -_flipSpeed;
    }
    _flip += _flipSpeed;

    _individualRotation += 2 * passedTime * _rotationSpeed;

    _size += _sizeDelta * passedTime;

    _colorR += _colorDeltaR * passedTime;
    _colorG += _colorDeltaG * passedTime;
    _colorB += _colorDeltaB * passedTime;
    _colorA += _colorDeltaA * passedTime;

    return true;
  }

  @override
  void _renderParticleCanvas(CanvasRenderingContext2D context) {
    context
      ..save()
      ..translate(_x, _y)
      ..rotate(_individualRotation)
      ..scale(_size, _size);

    if (shape == 'square') {
      // Draw a square for the confetti
      context.beginPath();
      context.rect(-5, -5, 10, 10); // Centered square with a size of 10
      context.fill();
    } else if (shape == 'circle') {
      // Draw a circle for the confetti
      context.beginPath();
      context.arc(0, 0, 5, 0, 2 * pi); // Centered circle with a radius of 5
      context.fill();
    }

    context.restore();
  }

  @override
  void _renderParticleWegGL(_ParticleRenderProgram renderProgram) {
    renderProgram.renderConfetti(
        _particleEmitter._renderTextureQuads[0],
        _x,
        _y,
        _size * _flip,
        _size,
        _colorR,
        _colorG,
        _colorB,
        _colorA,
        _individualRotation);
  }
}
