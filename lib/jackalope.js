(function() {
  var Jackalope, TypeConstraints, extend,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Jackalope = {};

  Jackalope.Meta = {
    extend: function(obj) {
      obj.has = Jackalope.Meta.has;
      obj.Maybe = Jackalope.Meta.Maybe;
      return obj.prototype.attributes = Jackalope.Meta.attributes;
    },
    has: function(name, args) {
      var _base, _ref;
      if ((_ref = (_base = this.prototype).__meta__) == null) {
        _base.__meta__ = {
          attributes: {}
        };
      }
      this.prototype.__meta__.attributes[name] = args;
      return Jackalope.Attributes.createAccessor(this.prototype, name, args);
    },
    Maybe: function(type) {
      return new TypeConstraints.Maybe(type);
    },
    attributes: function() {
      var _ref;
      return (_ref = this.__attributes) != null ? _ref : this.__attributes = Jackalope.Attributes.constructAttributes.call(this);
    },
    construct: function() {
      var config, ctor_args, key, name, value, _ref, _ref1, _results;
      ctor_args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = this.attributes();
      _results = [];
      for (name in _ref) {
        config = _ref[name];
        key = config.init_arg ? config.init_arg : name;
        value = (_ref1 = ctor_args[0]) != null ? _ref1[key] : void 0;
        if (!(value || config.required)) {
          continue;
        }
        if (config.required) {
          if (!value) {
            throw Error("" + key + " is required!");
          }
        }
        _results.push(Jackalope.Attributes.writeValue.call(this, name, value, config));
      }
      return _results;
    }
  };

  Jackalope.Traits = {
    create: function(trait, proto, name, args) {
      var handle, trait_handler, _ref, _results;
      if (!Jackalope.Traits[trait]) {
        throw Error("trait " + trait + " does not exist");
      }
      _ref = args.handles;
      _results = [];
      for (handle in _ref) {
        trait_handler = _ref[handle];
        if (Jackalope.Traits[trait][trait_handler]) {
          delete args.handles[handle];
        }
        _results.push(proto[handle] = Jackalope.Traits.createHandler(trait, trait_handler, name));
      }
      return _results;
    },
    createHandler: function(trait, handler, name) {
      return function(value) {
        return Jackalope.Traits[trait][handler](this[name]());
      };
    },
    Object: {
      keys: function(obj) {
        var key, value, _results;
        _results = [];
        for (key in obj) {
          value = obj[key];
          _results.push(key);
        }
        return _results;
      },
      values: function(obj) {
        var key, value, _results;
        _results = [];
        for (key in obj) {
          value = obj[key];
          _results.push(value);
        }
        return _results;
      },
      copy: function(obj) {
        var collect, key, value;
        collect = {};
        for (key in obj) {
          value = obj[key];
          collect[key] = value;
        }
        return collect;
      },
      kv: function(obj) {
        var key, value, _results;
        _results = [];
        for (key in obj) {
          value = obj[key];
          _results.push([key, value]);
        }
        return _results;
      }
    }
  };

  Jackalope.Attributes = {
    createAccessor: function(proto, name, args) {
      proto[name] = function(value) {
        var _ref, _ref1, _ref2;
        if (!((_ref = this.__values) != null ? _ref[name] : void 0)) {
          Jackalope.Attributes.constructDefault.call(this, name, args);
        }
        if (!((_ref1 = this.__values) != null ? _ref1[name] : void 0)) {
          Jackalope.Attributes.constructLazy.call(this, name, args);
        }
        return (_ref2 = this.__values) != null ? _ref2[name] : void 0;
      };
      if (args.writer) {
        Jackalope.Attributes.createWriter(proto, name, args);
      }
      if (args.traits) {
        Jackalope.Attributes.createTraits(proto, name, args);
      }
      if (args.handles) {
        return Jackalope.Attributes.createHandles(proto, name, args);
      }
    },
    createWriter: function(proto, name, args) {
      return proto[args.writer] = function(value) {
        Jackalope.Attributes.writeValue.call(this, name, value, args);
        if (args.trigger) {
          if (typeof args.trigger !== 'function') {
            throw Error("trigger for " + name + " is not a function");
          }
          return args.trigger.call(this, value);
        }
      };
    },
    createTraits: function(proto, name, args) {
      var trait, _i, _len, _ref, _results;
      _ref = args.traits;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        trait = _ref[_i];
        _results.push(Jackalope.Traits.create(trait, proto, name, args));
      }
      return _results;
    },
    createHandles: function(proto, name, args) {
      var caller, handler, _ref, _results;
      _ref = args.handles;
      _results = [];
      for (caller in _ref) {
        handler = _ref[caller];
        _results.push(proto[caller] = function() {
          return this[name]()[handler]();
        });
      }
      return _results;
    },
    writeValue: function(name, value, args) {
      var _ref;
      TypeConstraints.check_type(value, name, args);
      if ((_ref = this.__values) == null) {
        this.__values = {};
      }
      return this.__values[name] = value;
    },
    constructDefault: function(name, args) {
      if (args["default"] == null) {
        return;
      }
      return Jackalope.Attributes.writeValue.call(this, name, args["default"], args);
    },
    constructAttributes: function() {
      var collect, key, value, _ref;
      collect = {};
      _ref = this.__meta__.attributes;
      for (key in _ref) {
        value = _ref[key];
        collect[key] = value;
      }
      return collect;
    },
    constructLazy: function(name, args) {
      if (!args.lazy_build) {
        return;
      }
      Jackalope.Attributes.validateConfigBuild.call(this, name, args);
      return Jackalope.Attributes.writeValue.call(this, name, this["_build_" + name](), args);
    },
    validateConfigBuild: function(name, args) {
      if (args.lazy_build != null) {
        if (this["_build_" + name] == null) {
          throw Error("method _build_" + name + " not found");
        }
      }
    }
  };

  extend = function(Obj) {
    Jackalope.Meta.extend(Obj);
    return Obj.create = function() {
      var instance;
      instance = new Obj();
      Jackalope.Meta.construct.apply(instance, arguments);
      return instance;
    };
  };

  Jackalope.Class = (function() {

    function Class() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      Jackalope.Meta.construct.apply(this, args);
    }

    return Class;

  })();

  Jackalope.Meta.extend(Jackalope.Class);

  exports.Class = Jackalope.Class;

  exports.extend = extend;

  TypeConstraints = (function() {

    function TypeConstraints() {}

    TypeConstraints.check_type = function(value, name, args) {
      if (!args.isa) {
        throw "No 'isa' for " + name;
      }
      if (TypeConstraints[args.isa]) {
        return TypeConstraints[args.isa](value, name, args);
      }
      if (args.isa instanceof TypeConstraints.Type) {
        return args.isa.check_type(value, name);
      }
      return TypeConstraints.__Instance(value, name, args);
    };

    TypeConstraints.assert = function(ok, value, name, args) {
      var an;
      if (!ok) {
        if ((typeof args.isa === 'string' && args.isa[0].match(/aeou/)) || 'a') {
          an = 'an';
        }
        throw "Assertion failed for " + ("'" + name + "', '" + value + "' is not " + an + " " + args.isa);
      }
      return true;
    };

    TypeConstraints.Str = function(value, name, args) {
      return TypeConstraints.assert(typeof value === 'string' || value instanceof String, value, name, args);
    };

    TypeConstraints.Bool = function(value, name, args) {
      return TypeConstraints.assert(typeof value === 'boolean', value, name, args);
    };

    TypeConstraints.Number = function(value, name, args) {
      return TypeConstraints.assert(typeof value === 'number' && !isNaN(value), value, name, args);
    };

    TypeConstraints.Int = function(value, name, args) {
      return TypeConstraints.assert(typeof value === 'number' && value % 1 === 0, value, name, args);
    };

    TypeConstraints.Object = function(value, name, args) {
      return TypeConstraints.assert(typeof value === 'object' && value !== null, value, name, args);
    };

    TypeConstraints.Array = function(value, name, args) {
      return TypeConstraints.assert(value instanceof Array, value, name, args);
    };

    TypeConstraints.Function = function(value, name, args) {
      return TypeConstraints.assert(typeof value === 'function', value, name, args);
    };

    TypeConstraints.__Instance = function(value, name, args) {
      TypeConstraints.assert(typeof value === 'object', value, name, {
        isa: "instance of something"
      });
      return TypeConstraints.assert(value instanceof args.isa, value, name, args);
    };

    return TypeConstraints;

  }).call(this);

  TypeConstraints.Type = (function(_super) {

    __extends(Type, _super);

    function Type(isa) {
      this.isa = isa;
    }

    Type.prototype.check_type = function(value, name, args) {
      return TypeConstraints.check_type(value, name, args);
    };

    return Type;

  })(TypeConstraints);

  TypeConstraints.Type.Maybe = (function(_super) {

    __extends(Maybe, _super);

    function Maybe(isa) {
      this.isa = isa;
    }

    Maybe.prototype.check_type = function(value, name) {
      if (value == null) {
        return true;
      }
      return Maybe.__super__.check_type.call(this, value, name, {
        isa: this.isa
      });
    };

    return Maybe;

  })(TypeConstraints.Type);

  TypeConstraints.Maybe = function(type) {
    return new TypeConstraints.Type.Maybe(type);
  };

  exports.TypeConstraints = TypeConstraints;

}).call(this);
