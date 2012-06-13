TypeConstraints = require('./TypeConstraints').TypeConstraints
# TODO
# - predicate
# - init_arg
# - trigger
# - handles
# - native traits
# ...methods
# ...move attributes into separate namespace ( attribute namespace )
# ...separate real methods from attributes
#

class Jackalope    

    constructor: (ctor_args...)->
        for name, config of @attributes()
            value = ctor_args[0]?[name]
            
            continue unless value or config.required
        
            if config.required
               throw "#{name} is required!" unless value
        
            Jackalope.Meta.writeValue.call this,
                name, value, config




        
Jackalope.Meta =
    has: (name, args)->
        @prototype.__meta__ ?= { attributes: {} }
        @prototype.__meta__.attributes[name] = args
        
        Jackalope.Meta.createAccessor @prototype,
            name, args

    attributes: ()->
        return @__attributes ?=
            Jackalope.Meta.constructAttributes.call this
            
    constructor: (ctor_args...)->
        for name, config of @attributes()
            value = ctor_args[0]?[name]
            
            continue unless value or config.required
        
            if config.required
               throw "#{name} is required!" unless value
        
            Jackalope.Meta.writeValue.call this,
                name, value, config

    createAccessor: ( proto, name, args )->
        proto[name] = ( value ) ->
            Jackalope.Meta.constructDefault.call( this, name, args ) unless @__values?[name]
            Jackalope.Meta.constructLazy.call( this, name, args ) unless @__values?[name]
    
            return @__values?[name]
    
        Jackalope.Meta.createWriter( proto, name, args ) if args.writer

    createWriter: ( proto, name, args )->
        proto[args.writer] = ( value )->
            Jackalope.Meta.writeValue.call( this, name, value, args )

    writeValue: ( name, value, args )->
        TypeConstraints.check_type( value, name, args )

        @__values ?= {}
        @__values[name] = value
        
    constructDefault: ( name, args )->
        return unless args.default
        Jackalope.Meta.writeValue.call( this, name, args.default, args )

    constructAttributes: ()->
        collect = {}

        for key, value of @__meta__.attributes
            collect[key] = value

        return collect;
    
    constructLazy: ( name, args )->
        return unless args.lazy_build
        Jackalope.Meta.validateConfigBuild.call this, name, args
        Jackalope.Meta.writeValue.call( this, name, @["_build_#{name}"](), args )

    validateConfigBuild: ( name, args )->
        if args.lazy_build?
            throw "method _build_#{name} not found" unless @["_build_#{name}"]?

extend = ( inst )->
    inst.has = Jackalope.Meta.has
    
    inst.prototype.attributes = Jackalope.Meta.attributes
    inst.prototype.constructor = Jackalope.prototype.constructor


class Jackalope.Base
    # but with mixin             
    extend this
    
            
exports.Jackalope = Jackalope.Base
