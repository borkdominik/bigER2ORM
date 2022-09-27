package org.big.orm.ide.diagram

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.sprotty.SGraph
import org.eclipse.sprotty.SNode
import org.eclipse.sprotty.SEdge

@Accessors
class OrmModelGraph extends SGraph {
	String name

	new() { }
	new((OrmModelGraph) => void initializer) {
		initializer.apply(this);
	}
}

@Accessors
class OrmModelNode extends SNode {
	boolean expanded

	new() { }
	new((OrmModelNode) => void initializer) {
		initializer.apply(this)
	}
}

@Accessors
class OrmModelRelationshipEdge extends SEdge {
	Boolean unidirectional

	new() { }
	new((OrmModelRelationshipEdge) => void initializer) {
		initializer.apply(this)
	}
}