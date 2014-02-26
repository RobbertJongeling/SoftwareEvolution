module ClassDiagramIO

import IO;
import ClassDiagram;

public void writeClassDiagramToFile(loc projectLoc, loc fileLoc){
	writeFile(fileLoc, getDot(projectLoc));
}
