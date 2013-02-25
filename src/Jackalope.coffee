TypeConstraints = require('./TypeConstraints').TypeConstraints
# TODO
# - predicate methods
# ...methods
# ...merge typeconstraints into this file
# ...separate real methods from attributes
# ...create python/jquery like class constructors

Jackalope = {}   
        
Jackalope.Meta =
    extend: ( obj )->
        obj.has = Jackalope.Meta.has    
        obj.Maybe = Jackalope.Meta.Maybe
        obj.prototype.attributes = Jackalope.Meta.attributes
    
    has: (name, args)->
        @prototype.__meta__ ?= { attributes: {} }
        @prototype.__meta__.attributes[name] = args
        
        Jackalope.Attributes.createAccessor @prototype,
            name, args
            
    Maybe: ( type )->
        new TypeConstraints.Maybe type

    attributes: ()->
        return @__attributes ?=
            Jackalope.Attributes.constructAttributes.call this
            
    construct: (ctor_args...)->
        for name, config of @attributes()
            key = if config.init_arg then config.init_arg else name
            
            value = ctor_args[0]?[key]
            
            continue unless value or config.required
        
            if config.required
               throw Error "#{key} is required!" unless value
        
            Jackalope.Attributes.writeValue.call this,
                name, value, config

Jackalope.Traits =
    create: ( trait, proto, name, args )->
        throw Error "trait #{trait} does not exist" unless Jackalope.Traits[trait]
    
        for handle, trait_handler of args.handles
            delete args.handles[handle] if Jackalope.Traits[trait][trait_handler]            
            proto[handle] = Jackalope.Traits.createHandler trait, trait_handler, name
                
    createHandler: ( trait, handler, name )->
        return ( value )->
            Jackalope.Traits[trait][handler]( @[name]() )
            
    Object:
        keys: ( obj )->
            (key for key, value of obj)

        values: ( obj )->
            (value for key, value of obj)

        copy: ( obj )->
            collect = {}
            ( collect[key] = value for key, value of obj )
            
            collect
            
        kv: ( obj )->
            ( [key, value] for key, value of obj )


Jackalope.Attributes =
    createAccessor: ( proto, name, args )->
        proto[name] = ( value ) ->
            Jackalope.Attributes.constructDefault.call( this, name, args ) unless @__values?[name]
            Jackalope.Attributes.constructLazy.call( this, name, args ) unless @__values?[name]
    
            return @__values?[name]
    
        Jackalope.Attributes.createWriter( proto, name, args ) if args.writer
        Jackalope.Attributes.createTraits( proto, name, args ) if args.traits
        Jackalope.Attributes.createHandles( proto, name, args ) if args.handles

    createWriter: ( proto, name, args )->
        proto[args.writer] = ( value )->
            Jackalope.Attributes.writeValue.call( this, name, value, args )
            
            if args.trigger
                throw Error "trigger for #{name} is not a function" unless typeof args.trigger is 'function'
                args.trigger.call this, value
                
    createTraits: ( proto, name, args )->
        for trait in args.traits
            Jackalope.Traits.create trait, proto, name, args
            
    createHandles: ( proto, name, args )->        
        for caller, handler of args.handles
            proto[caller] = ()->
                @[name]()[handler]()
                
    writeValue: ( name, value, args )->
        TypeConstraints.check_type( value, name, args )

        @__values ?= {}
        @__values[name] = value
        
    constructDefault: ( name, args )->
        return unless args.default?
        Jackalope.Attributes.writeValue.call( this, name, args.default, args )

    constructAttributes: ()->
        collect = {}

        for key, value of @__meta__.attributes
            collect[key] = value

        return collect;
    
    constructLazy: ( name, args )->
        return unless args.lazy_build
        Jackalope.Attributes.validateConfigBuild.call this, name, args
        Jackalope.Attributes.writeValue.call( this, name, @["_build_#{name}"](), args )

    validateConfigBuild: ( name, args )->
        if args.lazy_build?
            throw Error "method _build_#{name} not found" unless @["_build_#{name}"]?
        
        

extend = ( Obj )->
    Jackalope.Meta.extend Obj
    
    Obj.create = ()->
        instance = new Obj()
 
        Jackalope.Meta.construct.apply instance, arguments
        return instance


class Jackalope.Class    
    constructor: (args...)->
        Jackalope.Meta.construct.apply this, args

Jackalope.Meta.extend Jackalope.Class
            
exports.Class = Jackalope.Class
exports.extend = extend
