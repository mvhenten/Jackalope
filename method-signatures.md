### NOTES

The following is a tought experiment about syntax.
methods with named arguments and syntax checking, wouldn't dat be awesome?

the following syntax could achieve that in a unubtrusive manner:


    class Point extends Jackalope.Class
        @has 'x',
            isa: 'Int'
            required: true
            writer: '_setX'

        @has 'y',
            isa: 'Int'
            required: true
            writer: '_setY'

       @method 'translate', translation: Point, (args)->
         @_setX( @x() + args.x() )
         @_setY( @y() + args.y() )

       @method 'setXY', x: 'Int', y: 'Int', ( args ) ->
         @_setX( args.x )
         @_setY( args.y )

       @method 'rotate', Point, angle: 'Degrees', ( center, args ) ->
         translation = @_getTranslation( center, 0, 0 );
         rotation  = args.angle * ( Math.PI / 180 )
         # ... more math

    my point = new Point( x: 232, y: 351 );

    # plain named arguments
    point.translate( translation: new Point( -2, 2 ) )

    # positional arguments
    point.setXY( 32, 34 );

    # mixing positional and named arguments
    point.rotate( new Point( 32, 45 ), angle: 90 );


How about defaults? the following seems a bit clunky:

    class Point extends Jackalope.Class
       @method 'fade', duration: { 'Int': 90 }, opacity: 'Int', (args)->

This is not intuitive:

    class Point extends Jackalope.Class
       @method 'fade', duration: 'Int', 22, opacity: 'Int', (args)->

I like this the most: ( most elegant solution? )

    [ Default, Class ] = Jackalope.export 'Default', 'Class'

    class Point extends Class
       @method 'fade', duration: Default('Int', 33), opacity: 'Int', (args)->

### Javascript

This will look hidious in javascript:

    var Point, point, _ref, __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) {
      for (var key in parent) {
        if (__hasProp.call(parent, key)) child[key] = parent[key];
      }
      function ctor() {
        this.constructor = child;
      }
      ctor.prototype = parent.prototype;
      child.prototype = new ctor();
      child.__super__ = parent.prototype;
      return child;
    };

    Point = (function(_super) {
      __extends(Point, _super);

      function Point() {
        _ref = Point.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Point.has('x', {
        isa: 'Int',
        required: true,
        writer: '_setX'
      });

      Point.has('y', {
        isa: 'Int',
        required: true,
        writer: '_setY'
      });

      return Point;

    })(Jackalope.Class);

    this.method('translate', {
      translation: Point
    },
    function(args) {
      this._setX(this.x() + args.x());
      return this._setY(this.y() + args.y());
    });

    this.method('setXY', {
      x: 'Int',
      y: 'Int'
    },
    function(args) {
      this._setX(args.x);
      return this._setY(args.y);
    });

    this.method('rotate', Point, {
      angle: 'Degrees'
    },
    function(center, args) {
      var rotation, translation;

      translation = this._getTranslation(center, 0, 0);
      return rotation = args.angle * (Math.PI / 180);
    });

    my(point = new Point({
      x: 232,
      y: 351
    }));

    point.translate({
      translation: new Point(-2, 2)
    });

    point.setXY(32, 34);

    point.rotate(new Point(32, 45), {
      angle: 90
    });
