import { RectangularNode, SGraph } from 'sprotty';
import { LibavoidEdge } from 'sprotty-routing-libavoid';


export class OrmModelGraph extends SGraph {
    name: string;
}

export class OrmModelNode extends RectangularNode {
    expanded: boolean;
}

export class OrmModelRelationshipEdge extends LibavoidEdge {
    unidirectional: boolean;
}