module FlowPropagation

import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;
import List;
import Relation;
import lang::java::m3::Core;
import IO;

//onderstaande code is grotendeels gejat van https://gist.github.com/jurgenvinju/8972255
public loc emptyId = |id:///|;
alias OFG = rel[loc from, loc to];
 
str getAssociations(M3 model, Program program) {
	str ret = "";
	ret += "edge[arrowhead = \"open\"; style= \"solid\"]\n";
	//TODO voor elke gevonden association uit getAssocOutput een lijn tekenen
	return ret;
}
  
rel[loc,loc] getAssocOutput(M3 m, Program p) {//program p should be obtained by running createOFG from Java2OFG
	OFG ofg = buildTheGraph(p);
	
	gen = buildGenTAAC(m,p);
	kill = {};
	//propagate using the gen set to get type of actually allocated objects referenced by program locations
	//backward propagation
	propt = prop(ofg, gen, kill, true);
	toReturn = getAssocs(m, propt);
	//forward propagation
	propf = prop(ofg, gen, kill, false);	
	toReturn += getAssocs(m, propf);
	
	//propagate using the gen set of flow propagation specialization,
	//aimed at determining type of objects stored in weakly typed containers
	//backward propagation
	propWTCt = prop(ofg, buildGenWTC(m,p,true), kill, true);
	toReturn += getAssocs(m, propWTCt);
	//forward propagation
	propWTCf = prop(ofg, buildGenWTC(m,p,false), kill, false);
	toReturn += getAssocs(m, propWTCf);
	
	return toReturn;
} 

/*
 * returns associations from propagated OFG
 */ 
rel[loc,loc] getAssocs(M3 m, OFG g) {
	allFields = {<b,a> | <b,a> <- g, b.scheme == "java+field"}; //field b is of actual type a
	return {<c,a> | <c,b> <- m@containment, <b,a> <- allFields}; //return class c in which field b occurs
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
	//m.return -> x, geen idee of dit ergens op slaat
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

//kill set is alwaus empty for all locations
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

