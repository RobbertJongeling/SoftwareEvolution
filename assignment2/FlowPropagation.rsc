module FlowPropagation

import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;
import List;
import Relation;
import lang::java::m3::Core;
import IO;
import String;
import Set;
import List;
import Relation;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::TypeSymbol;
import TypeSymbolHelpers;

//onderstaande code is grotendeels gejat van https://gist.github.com/jurgenvinju/8972255
public loc emptyId = |id:///|;
alias OFG = rel[loc from, loc to];
   
tuple[rel[loc,loc] ass, rel[loc,loc] deps] getOutput(M3 m, Program p) {//program p should be obtained by running createOFG from Java2OFG
	OFG ofg = buildTheGraph(p);
	
	//first without propagation, for dependencies that could use the already existing code //TODO make it happen :P
	deps = {};
	asss = getInitAsss(m);
		
	gen = buildGenTAAC(m,p);
	kill = {};
	//propagate using the gen set to get type of actually allocated objects referenced by program locations
	//backward propagation
	propt = prop(ofg, gen, kill, true);
	asss += getAssocs(m, propt);
	deps += getDeps(m, propt);	
	//forward propagation
	propf = prop(ofg, gen, kill, false);	
	asss += getAssocs(m, propf);
	deps += getDeps(m, propf);
	
	//propagate using the gen set of flow propagation specialization,
	//aimed at determining type of objects stored in weakly typed containers
	//backward propagation
	propWTCt = prop(ofg, buildGenWTC(m,p,true), kill, true);
	asss += getAssocs(m, propWTCt);
	deps += getDeps(m, propWTCt);
	//forward propagation
	propWTCf = prop(ofg, buildGenWTC(m,p,false), kill, false);
	asss += getAssocs(m, propWTCf);
	deps += getDeps(m, propWTCf);
	
	return <asss,deps>;
} 

rel[loc,loc] getInitAsss(M3 m) {
	asss={};
	for(class_loc <- classes(m)) {
		list[loc] class_fields_locs = [e | e<-m@containment[class_loc], e.scheme=="java+field"];
		class_fields_types = domainR(m@types, toSet(class_fields_locs));
		for(loc field_loc <- class_fields_locs) {
			TypeSymbol field_type = toList(class_fields_types[field_loc])[0];
			if(class(l, _) := field_type) {
				rel[loc cls,loc fld] fieldInClass = {<a,f> | <a,f> <- m@containment, f == field_loc};
				asss += <getOneFrom(fieldInClass.cls), l>;
			}
		}
	}
	return asss;
}

/*
 * returns associations from propagated OFG
 */ 
rel[loc,loc] getAssocs(M3 m, OFG g) {
	allFields = {<b,c> | <b,c> <- g, b.scheme == "java+field"}; //field b is of actual type c
	return {<a,c> | <a,b> <- m@containment, <b,c> <- allFields}; //return class a in which field b occurs
}

/*
 * returns dependencies from propagated OFG
 */ 
rel[loc,loc] getDeps(M3 model, OFG g) {
	//get parameters
	allParams = {<b,c> | <b,c> <- g, b.scheme == "java+parameter"}; //Param b is of actual class c
	meths = {<m,c> | <m,b> <- model@containment, <b,c> <- allParams}; //return method m in which b is a parameter b
	paramDeps = {<a,c> | <a,m> <- model@containment, <m,c> <- meths};//return class a in which method m occurs
	
	//get local variables
	allVars = {<v,b> | <v,b> <- g, v.scheme == "java+variable"}; //Variable v is of actual type b
	meths2 = {<m,b> | <m,v> <- model@containment, <v,b> <- allVars}; //return method m in which field b occurs
	varDeps = {<a,b> | <a,m> <- model@containment, <m,b> <- meths2};
	
	return paramDeps + varDeps;
}
 
OFG buildTheGraph(Program p) 
	//a1->f1..ak->fk
	= {<as[i], fps[i]> | newAssign(x, cl, c, as) <- p.statemens, constructor(c, fps) <- p.decls, i <- index(as) }
	//cs.this -> x
	+ { <cl + "this", x> | newAssign(x, cl, _, _) <- p.statemens }
	//y -> x
	+ { <y,x>| assign(x,_,y) <- p.statemens}
	//y -> m.this
	+ { <y, m + "this"> | call(_, _, y, m, _) <- p.statemens}
	//a1->f1 .. ak -> fk
	+ { <as[i], fps[i]> | call(_, _, _, m, as) <- p.statemens, method(m, fps) <- p.decls, i <- index(as) }
	//m.return -> x
	+ { <m + "return", x> | call(x, _, _, m, _) <- p.statemens }
;

/*
 * Builds the gen set according to Figures 3.4 and 3.5 from the book
 */
rel[loc,loc] buildGenWTC(M3 m, Program p, bool back) {
	return back 
		? {<y,c> | assign(_,c,y) <- p.statemens, c in classes(m)} + {<m + "return",c> | call(_,c,_,m,_) <- p.statemens, c in classes(m)} 
		: {<cl + "this", cl> | newAssign(_,cl, _, _) <- p.statemens};
}

/*
 * Builds the gen set according to Figure 3.2 from the book
 */
rel[loc,loc] buildGenTAAC(M3 m, Program p) {
	return {<cl + "this", cl> | newAssign(_,cl, _, _) <- p.statemens, cl in classes(m)};
}

//kill set is always empty for all locations
rel[loc,loc] buildKill(OFG g) {	
	return {};
}

//sketch for flow propagation, stolen from gist/slides
OFG prop(OFG g, rel[loc,loc] gen, rel[loc,loc] kill, bool back) {
	OFG IN = { };
	OFG OUT = gen + (IN - kill);
	gi = g<to,from>;
	set[loc] pred(loc n) = gi[n];
	set[loc] succ(loc n) = g[n];
	
	solve (IN, OUT) {
		IN = { <n,\o> | n <- carrier(g), p <- (back ? pred(n) : succ(n)), \o <- OUT[p] };
		OUT = gen + (IN - kill);
	}
	
	return OUT;
}

