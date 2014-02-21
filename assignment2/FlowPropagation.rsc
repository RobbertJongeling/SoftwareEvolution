module FlowPropagation

import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;
import List;
import Relation;
import lang::java::m3::Core;
import IO;

//onderstaande code is grotendeels gejat van https://gist.github.com/jurgenvinju/8972255

alias OFG = rel[loc from, loc to];
 
OFG buildGraph(Program p) 
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

bool backwards() {
	//TODO for given parameter node (//TODO) return true if backwards propagation, else false
}

rel[loc,loc] buildGen() {
	//TODO for given parameter node (//TODO) return gen set
}

rel[loc,loc] buildKill() {
	//TODO for given parameter node (//TODO) return kill set
}

//sketch for flow propagation, stolen from gist
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

