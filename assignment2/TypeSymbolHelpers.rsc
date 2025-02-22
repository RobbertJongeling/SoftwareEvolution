module TypeSymbolHelpers

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::TypeSymbol;
import Set;
import Relation;
import List;
import String;

/**
 * Returns a user friendly String that represents a TypeSymbol.
 * Not all possible values of TypeSymbol have been implemented in a satisfactory way.
 */
str toString(TypeSymbol t, M3 model){
	if(\class(l, tp) := t){
		if(size(tp) == 0){
			return getOneFrom(invert(model@names)[l]);
		}else{
			//I would have liked to do this in a neat functional way with a mapper() but I couldn't find how I could return a function in Rascal
			list[str] parameters = [];
			for(parameter <- tp){
				parameters += toString(parameter, model);
			}
			return getOneFrom(invert(model@names)[l]) + "[" + intercalate(",", parameters) + "]";
		}
	}else if(\interface(l, tp) := t){
		if(size(tp) == 0){
			return getOneFrom(invert(model@names)[l]);
		}else{
			//I would have liked to do this in a neat functional way with a mapper() but I couldn't find how I could return a function in Rascal
			list[str] parameters = [];
			for(parameter <- tp){
				parameters += toString(parameter, model);
			}
			return getOneFrom(invert(model@names)[l]) + "[" + intercalate(",", parameters) + "]";
		}
	}else if(\enum(l) := t){
		return getOneFrom(invert(model@names)[l]);
	}else if(\method(l, _, _, _) := t){
		return getOneFrom(invert(model@names)[l]);
	}else if(\constructor(l, _) := t){
		return getOneFrom(invert(model@names)[l]);
	}else if(\typeParameter(l, _) := t){
		return getOneFrom(invert(model@names)[l]);
	}else if(\wildcard(_) := t){
		return "wildcard";
	}else if(\capture(_, _) := t){
		return "capture";
	}else if(\interaction(_) := t){
		return "intersection";
	}else if(\union(_) := t){
		return "union";
	}else if(\object() := t){
		return "object";
	}else if(\int() := t){
		return "int";
	}else if(\float() := t){
		return "float";
	}else if(\double() := t){
		return "double";
	}else if(\short() := t){
		return "short";
	}else if(\boolean() := t){
		return "boolean";
	}else if(\char() := t){
		return "char";
	}else if(\byte() := t){
		return "byte";
	}else if(\long() := t){
		return "long";
	}else if(\null() := t){
		return "null";
	}else if(\array(component, dimension) := t){
		return "Array<dimension>[<toString(component, model)>]";
	}else if(\void() := t){
		return "void";
	}else{
		return "?";
	}
}
