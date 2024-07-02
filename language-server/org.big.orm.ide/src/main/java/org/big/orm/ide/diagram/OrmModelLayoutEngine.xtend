package org.big.orm.ide.diagram

import org.eclipse.elk.core.options.CoreOptions
import org.eclipse.elk.core.options.Direction
import org.eclipse.sprotty.Action
import org.eclipse.sprotty.SModelRoot
import org.eclipse.sprotty.layout.ElkLayoutEngine
import org.eclipse.sprotty.layout.SprottyLayoutConfigurator
import org.eclipse.elk.alg.libavoid.options.LibavoidOptions
import org.eclipse.elk.core.options.EdgeRouting
import org.eclipse.elk.alg.layered.options.LayeredOptions
import org.eclipse.sprotty.MoveAction
import org.eclipse.elk.core.options.PortAlignment
import org.eclipse.elk.core.options.PortConstraints
import org.eclipse.elk.core.options.PortSide

class OrmModelLayoutEngine extends ElkLayoutEngine {

	override layout(SModelRoot root, Action cause) {

		if (root instanceof OrmModelGraph) {
			
			if (!(cause instanceof MoveAction)) {
				val layeredConfigurator = new SprottyLayoutConfigurator
			
				layeredConfigurator.configureByType('graph')
					.setProperty(CoreOptions.ALGORITHM, LayeredOptions.ALGORITHM_ID)
					.setProperty(CoreOptions.DIRECTION, Direction.DOWN)
					.setProperty(CoreOptions.SPACING_NODE_NODE, 30.0)
					.setProperty(LayeredOptions.SPACING_EDGE_NODE_BETWEEN_LAYERS, 30.0)
					.setProperty(CoreOptions.EDGE_ROUTING, EdgeRouting.ORTHOGONAL)
				layeredConfigurator.configureByType('node')
					.setProperty(CoreOptions.PORT_ALIGNMENT_DEFAULT, PortAlignment.CENTER)
					.setProperty(CoreOptions.PORT_CONSTRAINTS, PortConstraints.FREE)
				layeredConfigurator.configureByType('port')
					.setProperty(CoreOptions.PORT_SIDE, PortSide.EAST)
					.setProperty((CoreOptions.PORT_BORDER_OFFSET), 3.0)
					
				layout(root, layeredConfigurator, cause)
			}
			
			val libavoidConfigurator = new SprottyLayoutConfigurator
			
			libavoidConfigurator.configureByType('graph')
				.setProperty(CoreOptions.ALGORITHM, LibavoidOptions.ALGORITHM_ID)
				.setProperty(CoreOptions.EDGE_ROUTING, EdgeRouting.ORTHOGONAL)
				.setProperty(LibavoidOptions.SEGMENT_PENALTY, 50.0)
				.setProperty(LibavoidOptions.CROSSING_PENALTY, 50.0)
				.setProperty(LibavoidOptions.CLUSTER_CROSSING_PENALTY, 30.0)
				.setProperty(LibavoidOptions.IDEAL_NUDGING_DISTANCE, 24.0)
				.setProperty(LibavoidOptions.SHAPE_BUFFER_DISTANCE, 25.0)
				.setProperty(LibavoidOptions.NUDGE_ORTHOGONAL_SEGMENTS_CONNECTED_TO_SHAPES, true)
				.setProperty(LibavoidOptions.NUDGE_ORTHOGONAL_TOUCHING_COLINEAR_SEGMENTS, false)
				
			layout(root, libavoidConfigurator, cause)
		}
	}
}