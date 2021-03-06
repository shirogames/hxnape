package nape.shape;
import zpp_nape.Const;
import zpp_nape.ID;
import zpp_nape.util.Array2;
import zpp_nape.util.Circular;
import zpp_nape.util.DisjointSetForest;
import zpp_nape.util.FastHash;
import zpp_nape.util.Flags;
import zpp_nape.util.Lists;
import zpp_nape.util.Math;
import zpp_nape.util.Names;
import zpp_nape.util.Pool;
import zpp_nape.util.Queue;
import zpp_nape.util.RBTree;
import zpp_nape.util.Debug;
import zpp_nape.util.UserData;
import zpp_nape.util.WrapLists;
import zpp_nape.space.Broadphase;
import zpp_nape.space.DynAABBPhase;
import zpp_nape.space.SweepPhase;
import zpp_nape.shape.Circle;
import zpp_nape.shape.Edge;
import zpp_nape.shape.Polygon;
import zpp_nape.shape.Shape;
import zpp_nape.phys.Body;
import zpp_nape.phys.Compound;
import zpp_nape.phys.FeatureMix;
import zpp_nape.phys.FluidProperties;
import zpp_nape.phys.Interactor;
import zpp_nape.phys.Material;
import zpp_nape.geom.AABB;
import zpp_nape.geom.Collide;
import zpp_nape.geom.Convex;
import zpp_nape.geom.ConvexRayResult;
import zpp_nape.space.Space;
import zpp_nape.geom.Cutter;
import zpp_nape.geom.Geom;
import zpp_nape.geom.GeomPoly;
import zpp_nape.geom.Mat23;
import zpp_nape.geom.MarchingSquares;
import zpp_nape.geom.MatMN;
import zpp_nape.geom.MatMath;
import zpp_nape.geom.Monotone;
import zpp_nape.geom.PolyIter;
import zpp_nape.geom.PartitionedPoly;
import zpp_nape.geom.Ray;
import zpp_nape.geom.Simplify;
import zpp_nape.geom.Simple;
import zpp_nape.geom.SweepDistance;
import zpp_nape.geom.Vec2;
import zpp_nape.geom.Vec3;
import zpp_nape.geom.Triangular;
import zpp_nape.geom.VecMath;
import zpp_nape.dynamics.Contact;
import zpp_nape.dynamics.InteractionFilter;
import zpp_nape.dynamics.InteractionGroup;
import zpp_nape.dynamics.SpaceArbiterList;
import zpp_nape.constraint.AngleJoint;
import zpp_nape.constraint.Constraint;
import zpp_nape.dynamics.Arbiter;
import zpp_nape.constraint.DistanceJoint;
import zpp_nape.constraint.LinearJoint;
import zpp_nape.constraint.MotorJoint;
import zpp_nape.constraint.PivotJoint;
import zpp_nape.constraint.LineJoint;
import zpp_nape.constraint.UserConstraint;
import zpp_nape.constraint.WeldJoint;
import zpp_nape.constraint.PulleyJoint;
import zpp_nape.callbacks.Callback;
import zpp_nape.callbacks.CbSetPair;
import zpp_nape.callbacks.CbType;
import zpp_nape.callbacks.CbSet;
import zpp_nape.callbacks.OptionType;
import zpp_nape.callbacks.Listener;
import nape.Config;
import nape.TArray;
import nape.util.Debug;
import nape.util.BitmapDebug;
import nape.space.Broadphase;
import nape.util.ShapeDebug;
import nape.shape.Edge;
import nape.shape.EdgeIterator;
import nape.shape.EdgeList;
import nape.space.Space;
import nape.shape.Polygon;
import nape.shape.ShapeIterator;
import nape.shape.ShapeList;
import nape.shape.ShapeType;
import nape.shape.ValidationResult;
import nape.shape.Shape;
import nape.phys.BodyIterator;
import nape.phys.BodyList;
import nape.phys.BodyType;
import nape.phys.Compound;
import nape.phys.CompoundIterator;
import nape.phys.CompoundList;
import nape.phys.FluidProperties;
import nape.phys.GravMassMode;
import nape.phys.InertiaMode;
import nape.phys.Interactor;
import nape.phys.InteractorIterator;
import nape.phys.InteractorList;
import nape.phys.MassMode;
import nape.phys.Body;
import nape.phys.Material;
import nape.geom.ConvexResult;
import nape.geom.ConvexResultIterator;
import nape.geom.ConvexResultList;
import nape.geom.AABB;
import nape.geom.Geom;
import nape.geom.GeomPolyIterator;
import nape.geom.GeomPolyList;
import nape.geom.GeomVertexIterator;
import nape.geom.IsoFunction;
import nape.geom.MarchingSquares;
import nape.geom.GeomPoly;
import nape.geom.MatMN;
import nape.geom.Mat23;
import nape.geom.Ray;
import nape.geom.RayResultIterator;
import nape.geom.RayResultList;
import nape.geom.RayResult;
import nape.geom.Vec2Iterator;
import nape.geom.Vec2List;
import nape.geom.Vec3;
import nape.geom.Winding;
import nape.dynamics.Arbiter;
import nape.dynamics.ArbiterIterator;
import nape.geom.Vec2;
import nape.dynamics.ArbiterList;
import nape.dynamics.ArbiterType;
import nape.dynamics.Contact;
import nape.dynamics.ContactIterator;
import nape.dynamics.ContactList;
import nape.dynamics.FluidArbiter;
import nape.dynamics.CollisionArbiter;
import nape.dynamics.InteractionFilter;
import nape.dynamics.InteractionGroupIterator;
import nape.dynamics.InteractionGroupList;
import nape.dynamics.InteractionGroup;
import nape.constraint.AngleJoint;
import nape.constraint.ConstraintIterator;
import nape.constraint.ConstraintList;
import nape.constraint.DistanceJoint;
import nape.constraint.LinearJoint;
import nape.constraint.Constraint;
import nape.constraint.LineJoint;
import nape.constraint.PivotJoint;
import nape.constraint.MotorJoint;
import nape.constraint.PulleyJoint;
import nape.constraint.UserConstraint;
import nape.constraint.WeldJoint;
import nape.callbacks.BodyCallback;
import nape.callbacks.Callback;
import nape.callbacks.BodyListener;
import nape.callbacks.CbEvent;
import nape.callbacks.CbTypeIterator;
import nape.callbacks.CbTypeList;
import nape.callbacks.ConstraintCallback;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.ConstraintListener;
import nape.callbacks.InteractionType;
import nape.callbacks.InteractionListener;
import nape.callbacks.ListenerIterator;
import nape.callbacks.ListenerList;
import nape.callbacks.ListenerType;
import nape.callbacks.Listener;
import nape.callbacks.OptionType;
import nape.callbacks.PreFlag;
import nape.callbacks.PreCallback;
import nape.callbacks.PreListener;
/**
 * Shape subtype representing a Circle
 */
@:final#if nape_swc@:keep #end
class Circle extends Shape{
    /**
     * @private
     */
    public var zpp_inner_zn:ZPP_Circle=null;
    /**
     * Construct a new Circle
     *
     * @param radius The radius of the circle, this value must be positive.
     * @param localCOM The local offset for the circle. (default &#40;0,0&#41;)
     * @param material The material for this circle. (default new Material&#40;&#41;)
     * @param filter The interaction filter for this circle.
     *               (default new InteractionFilter&#40;&#41;)
     * @return The constructed Circle
     * @throws # If radius is not strictly positive
     * @throws # If localCOM is non-null, but has been disposed of.
     */
    #if flib@:keep function flibopts_3(){}
    #end
    public function new(radius:Float,localCOM:Vec2=null,material:Material=null,filter:InteractionFilter=null){
        #if(!NAPE_RELEASE_BUILD)
        Shape.zpp_internalAlloc=true;
        super();
        Shape.zpp_internalAlloc=false;
        #end
        #if NAPE_RELEASE_BUILD 
        super();
        #end
        zpp_inner_zn=new ZPP_Circle();
        zpp_inner_zn.outer=this;
        zpp_inner_zn.outer_zn=this;
        zpp_inner=zpp_inner_zn;
        zpp_inner_i=zpp_inner;
        zpp_inner_i.outer_i=this;
        this.radius=radius;
        if(localCOM==null){
            zpp_inner.localCOMx=0;
            zpp_inner.localCOMy=0;
            {
                #if(NAPE_ASSERT&&!NAPE_RELEASE_BUILD)
                var res={
                    !((zpp_inner.localCOMx!=zpp_inner.localCOMx));
                };
                if(!res)throw "assert("+"!assert_isNaN(zpp_inner.localCOMx)"+") :: "+("vec_set(in n: "+"zpp_inner.localCOM"+",in x: "+"0"+",in y: "+"0"+")");
                #end
            };
            {
                #if(NAPE_ASSERT&&!NAPE_RELEASE_BUILD)
                var res={
                    !((zpp_inner.localCOMy!=zpp_inner.localCOMy));
                };
                if(!res)throw "assert("+"!assert_isNaN(zpp_inner.localCOMy)"+") :: "+("vec_set(in n: "+"zpp_inner.localCOM"+",in x: "+"0"+",in y: "+"0"+")");
                #end
            };
        };
        else{
            {
                #if(!NAPE_RELEASE_BUILD)
                if(localCOM!=null&&localCOM.zpp_disp)throw "Error: "+"Vec2"+" has been disposed and cannot be used!";
                #end
            };
            {
                zpp_inner.localCOMx=localCOM.x;
                zpp_inner.localCOMy=localCOM.y;
                {
                    #if(NAPE_ASSERT&&!NAPE_RELEASE_BUILD)
                    var res={
                        !((zpp_inner.localCOMx!=zpp_inner.localCOMx));
                    };
                    if(!res)throw "assert("+"!assert_isNaN(zpp_inner.localCOMx)"+") :: "+("vec_set(in n: "+"zpp_inner.localCOM"+",in x: "+"localCOM.x"+",in y: "+"localCOM.y"+")");
                    #end
                };
                {
                    #if(NAPE_ASSERT&&!NAPE_RELEASE_BUILD)
                    var res={
                        !((zpp_inner.localCOMy!=zpp_inner.localCOMy));
                    };
                    if(!res)throw "assert("+"!assert_isNaN(zpp_inner.localCOMy)"+") :: "+("vec_set(in n: "+"zpp_inner.localCOM"+",in x: "+"localCOM.x"+",in y: "+"localCOM.y"+")");
                    #end
                };
            };
            ({
                if(({
                    localCOM.zpp_inner.weak;
                })){
                    localCOM.dispose();
                    true;
                }
                else{
                    false;
                }
            });
        }
        if(material==null){
            if(ZPP_Material.zpp_pool==null){
                zpp_inner.material=new ZPP_Material();
                #if NAPE_POOL_STATS ZPP_Material.POOL_TOT++;
                ZPP_Material.POOL_ADDNEW++;
                #end
            }
            else{
                zpp_inner.material=ZPP_Material.zpp_pool;
                ZPP_Material.zpp_pool=zpp_inner.material.next;
                zpp_inner.material.next=null;
                #if NAPE_POOL_STATS ZPP_Material.POOL_CNT--;
                ZPP_Material.POOL_ADD++;
                #end
            }
            zpp_inner.material.alloc();
        };
        else this.material=material;
        if(filter==null){
            if(ZPP_InteractionFilter.zpp_pool==null){
                zpp_inner.filter=new ZPP_InteractionFilter();
                #if NAPE_POOL_STATS ZPP_InteractionFilter.POOL_TOT++;
                ZPP_InteractionFilter.POOL_ADDNEW++;
                #end
            }
            else{
                zpp_inner.filter=ZPP_InteractionFilter.zpp_pool;
                ZPP_InteractionFilter.zpp_pool=zpp_inner.filter.next;
                zpp_inner.filter.next=null;
                #if NAPE_POOL_STATS ZPP_InteractionFilter.POOL_CNT--;
                ZPP_InteractionFilter.POOL_ADD++;
                #end
            }
            zpp_inner.filter.alloc();
        };
        else this.filter=filter;
        zpp_inner_i.insert_cbtype(CbType.ANY_SHAPE.zpp_inner);
    }
    /**
     * Radius of circle
     * <br/><br/>
     * This value must be strictly positive, and attempting to set this value
     * whilst this Circle is part of a static Body inside a Space will result
     * in a debug time error.
     */
    #if nape_swc@:isVar #end
    public var radius(get,set):Float;
    inline function get_radius():Float{
        return zpp_inner_zn.radius;
    }
    inline function set_radius(radius:Float):Float{
        {
            zpp_inner.immutable_midstep("Circle::radius");
            #if(!NAPE_RELEASE_BUILD)
            if(zpp_inner.body!=null&&zpp_inner.body.isStatic()&&zpp_inner.body.space!=null)throw "Error: Cannot modifiy radius of Circle contained in static object once added to space";
            #end
            if(radius!=this.radius){
                #if(!NAPE_RELEASE_BUILD)
                if((radius!=radius))throw "Error: Circle::radius cannot be NaN";
                if(radius<Config.epsilon)throw "Error: Circle::radius ("+radius+") must be > Config.epsilon";
                if(radius>ZPP_Const.FMAX)throw "Error: Circle::radius ("+radius+") must be < PR(Const).FMAX";
                #end
                zpp_inner_zn.radius=radius;
                zpp_inner_zn.invalidate_radius();
            }
        }
        return get_radius();
    }
}
