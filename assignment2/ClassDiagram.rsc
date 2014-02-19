module ClassDiagram

import String;
import Set;
import List;
import Relation;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::TypeSymbol;
import IO;

str settings = "fontname = \"Bitstream Vera Sans\"\nfontsize = 10\nnode [\nfontname = \"Courier New\"\nfontsize = 10\nshape = \"record\"\n]\nedge [\nfontname = \"Courier New\"\nfontsize = 10\n]\n";

/**
 * Turns the String version of a Modifier into a UML string that denotes visibility
 *
 * @todo static
 */
str modifier_to_uml(str modifier){
	switch(modifier){
		case "public()": return "+";
		case "private()": return "-";
		case "protected()": return "#";
		case "static()": return "@";
		case "final()": return "!";
		default: return "?";
	}
}

/**
 * Returns a DOT string representation of the fields in the class
 */
str getFields(M3 model, loc class_loc){
	ret = "";
	
	//Get all containments of type field that are associated with the given class location
	list[loc] class_fields_locs = [ e | e <- model@containment[class_loc], e.scheme == "java+field"];
	//Grab the types and modifiers associated with the found field locations
	class_fields_types = domainR(model@types, toSet(class_fields_locs));
	class_fields_modifiers = domainR(model@modifiers, toSet(class_fields_locs));
	
	//Loop through the found field locations
	for(loc field_loc <- class_fields_locs){
		TypeSymbol field_type = toList(class_fields_types[field_loc])[0];
		
		list[Modifier] field_modifiers = toList(class_fields_modifiers[field_loc]);
		str field_modifier_str = "";
		for(Modifier field_modifier <- field_modifiers){
			field_modifier_str += modifier_to_uml("<field_modifier>");
		}
		//I really need casting here, this is beyond horrible
		str field_name = substring(field_loc.uri, 15 + size(substring(class_loc.uri, 14)), size(field_loc.uri));
		str field_return = replaceAll("<field_type>", "|", "");
		//TODO: It would be nicer if we could add a public() Modifier to the list of modifiers, but I have no idea how to create a new Modifier
		ret += "+<field_modifier_str> <field_name>: <field_return>\\l";
	}
	return ret;
}

/**
 * Returns a DOT string representation of the methods in the class
 */
str getMethods(M3 model, loc class_loc){
	ret = "";
	
	//Get the contructor
	list[loc] class_constructor_locs = [ e | e <- model@containment[class_loc], e.scheme == "java+constructor"];
	//Grab the types and modifiers associated with the found field locations
	class_constructor_types = domainR(model@types, toSet(class_constructor_locs));
	class_constructor_modifiers = domainR(model@modifiers, toSet(class_constructor_locs));
	
	//Loop through the found method locations
	for(loc method_loc <- class_constructor_locs){
		TypeSymbol method_type = toList(class_constructor_types[method_loc])[0];
		
		list[Modifier] method_modifiers = toList(class_constructor_modifiers[method_loc]);
		str method_modifier_str = "";
		for(Modifier method_modifier <- method_modifiers){
			method_modifier_str += modifier_to_uml("<method_modifier>");
		}
		//I really need casting here, this is beyond horrible
		str method_name = substring(method_loc.uri, 21 + size(substring(class_loc.uri, 14)), size(method_loc.uri));
		//method_type[2] should be a TypeSymbol, but is a 'value'
		ret += "<method_modifier_str> <method_name>\\l";
	}
	
	//Get all containments of type method that are associated with the given class location
	list[loc] class_methods_locs = [ e | e <- model@containment[class_loc], e.scheme == "java+method"];
	//Grab the types and modifiers associated with the found field locations
	class_methods_types = domainR(model@types, toSet(class_methods_locs));
	class_methods_modifiers = domainR(model@modifiers, toSet(class_methods_locs));
	
	//Loop through the found method locations
	for(loc method_loc <- class_methods_locs){
		TypeSymbol method_type = toList(class_methods_types[method_loc])[0];
		
		list[Modifier] method_modifiers = toList(class_methods_modifiers[method_loc]);
		str method_modifier_str = "";
		for(Modifier method_modifier <- method_modifiers){
			method_modifier_str += modifier_to_uml("<method_modifier>");
		}
		//I really need casting here, this is beyond horrible
		str method_name = substring(method_loc.uri, 16 + size(substring(class_loc.uri, 14)), size(method_loc.uri));
		//method_type[2] should be a TypeSymbol, but is a 'value'
		str method_return = replaceAll("<method_type[2]>", "|", "");
		ret += "<method_modifier_str> <method_name>: <method_return>\\l";
	}
	return ret;
}

/**
 * Returns a DOT string representation of the given class
 */
str getClass(M3 model, loc class){
	str ret = "";
	
	//Note: I'm very much assuming that loc is actually a class here
	str classname = substring(class.uri, 14);
	ret += "<classname> [\n";
	ret += "label = \"{<classname>|";
	ret += getFields(model, class);
	ret += "|";
	ret += getMethods(model, class);
	ret += "}\"\n";
	ret += "]\n";
	
	return ret;
}

/**
 * Returns a DOT string representation of all the classes inside the model
 */
str getClasses(M3 model){
	str ret = "";
	
	list[loc] mod_classes = toList(classes(model));
	for(loc mod_class <- mod_classes){
		ret += getClass(model, mod_class);
	}
	
	return ret;
}

/**
 * Checks if an element is a part of the project
 */
bool isPartOfProject(M3 model, str element){
	return element in {n | <n,l> <- model@names, l in classes(model)};
}

/**
 * Returns a DOT string representation of the Depends relations in the model
 */
str getDepends(M3 model){
	set[tuple[str,str]] dependencies = {};
	
	for(tuple[loc,loc] depends <- model@methodInvocation){
		str path_a = substring(depends[0].uri, findFirst(depends[0].uri, ":///") + 4);
		str class_a = substring(path_a, 0, findFirst(path_a, "/"));
		str path_b = substring(depends[1].uri, findFirst(depends[1].uri, ":///") + 4);
		str element_b = substring(path_b, 0, findFirst(path_b, "/"));
		
		if(class_a != element_b && isPartOfProject(model, element_b)){
			dependencies += <class_a, element_b>;
		}
	}
	
	str ret = "";
	ret += "edge[arrowhead = \"open\"; style = \"dashed\"]\n";
	for(dependency <- dependencies){
		ret += "<dependency[0]> -\> <dependency[1]>;\n";
	}
	return ret;
}

/**
 * Returns a DOT string representation of the Extends relations in the model
 */
str getExtends(M3 model){
	str ret = "";
	ret += "edge[arrowhead = \"empty\"]\n";
	for(tuple[loc,loc] extends <- model@extends){
		str class_a = substring(extends[0].uri, 14);
		str class_b = substring(extends[1].uri, 14);
		ret += "<class_a> -\> <class_b>;\n";
	}
	return ret;
}

/**
 * Returns a DOT string representation of the Implements relations in the model
 *
 * @todo: Does Rascal have inheretance? Is there any way I can de-couple the getImplements and getExtends methods?
 */
str getImplements(M3 model){
	str ret = "";
	ret += "edge[arrowhead = \"empty\"; style = \"dashed\"]\n";
	for(tuple[loc,loc] implements <- model@implements){
		str class_a = substring(implements[0].uri, 14);
		str class_b = substring(implements[1].uri, 14);
		ret += "<class_a> -\> <class_b>;\n";
	}
	return ret;
}

/**
 * Returns a DOT digraph containing a UML class diagram of the given model
 *
 * The diagram includes
 * - Classes
 * - Fields
 * - Methods
 */
public str getDot(M3 model){
	str ret = "digraph classes{\n";
	ret += settings;
	ret += getClasses(model);
	ret += getDepends(model);
	ret += getExtends(model);
	ret += getImplements(model);
	ret += "}";
	return ret;
}
