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
 
void drawArcs(p) {
	OFG ofg = buildGraph(p);
	//while changes ofzo?
	for (r <- ofg) {
	//als ik die sketch goed begrijp
	//die assignments werken natuurlijk niet maar het is pseudocode
		outVoorDeFromLoc = prop(ofg, buildGen(p,r.from), buildKill(p,r.from), backwards(r.from));
		outVoorDeToLoc = prop(ofg, buildGen(p,r.to), buildKill(p,r.to), backwards(r.to));
	}
	//dan zou je nu voor elke loc een outset moeten hebben en dan arcs tekenen van out naar loc
	//tenminste in het geval van assosciations, ik weet niet hoe het bij die andere dingen werkt
	
	//deze functie zou dan ook niet echt void zijn maar meer dot stuff teruggooien die arcs moet tekenen
} 
 
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

rel[loc,loc] buildGen(Program p, loc n) {//blijkbaar mag je iets niet 'node' noemen :/
	//if(node of form cs.this) then return c, else return empty	
}

//kill set is alwaus empty for all locations
rel[loc,loc] buildKill(Program p, loc n) {	
	return <emptyID,emptyID>;
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

